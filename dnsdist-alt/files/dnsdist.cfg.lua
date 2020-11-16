--[[

sample dnsdist configuration-script for generating rules
for matching dns-queries' qnames against regexps (using built-in or re2 engine)
and also for optional matching against list of qtypes
matched queries will be forwarded to configured pools of dns-servers
for all unmatched queries NXDOMAIN response will be returned

please, place all regexp-definitions and other config (backend dns-servers and pool-configs, acls, etc...)
into dnsdist.defs.lua config file: it will be executed first
also, you may add some other configs and rules into dnsdist.post.lua

WARNING: this is highly experimental stuff, and may not work as you expected
consider not to use this script in production env, you have been warned

]]--

-- table names with matches
rulesDefTableName="definitions"

-- load "definitions" table from dnsdist.defs.lua config file, and configure other stuff before generating rules
dofile("/etc/dnsdist.defs.lua")

assert(rulesDefTableName~=nil and rulesDefTableName~="rulesTable", "rulesDefTableName is invalid")

rulesTable=loadstring("return " .. rulesDefTableName)()

assert(type(rulesTable)=="table","global table with name '" .. rulesDefTableName .. "' is not found")

function tryAddQueryDelay(ruleIdx,ruleDef,regexRule)
	assert(type(ruleDef.dl)=="nil" or type(ruleDef.dl)=="number", "rule definition at position #"..ruleIdx.." delay definition is not a number")
	if (type(ruleDef.dl)=="number") then
		local delay=math.ceil(math.abs(ruleDef.dl))
		addAction(regexRule,DelayAction(delay))
	end
end

function tryAddResponseDelay(ruleIdx,ruleDef,regexRule)
	assert(type(ruleDef.dla)=="nil" or type(ruleDef.dla)=="number", "rule definition at position #"..ruleIdx.." answer delay definition is not a number")
	if (type(ruleDef.dla)=="number") then
		local delay=math.ceil(math.abs(ruleDef.dla))
		addResponseAction(regexRule,DelayResponseAction(delay))
	end
end

-- parse definitions table and generate rules. this code may be non optimal
for ruleIdx,ruleDef in ipairs(rulesTable) do
	assert(type(ruleDef)=="table","rule definition at position #"..ruleIdx.." must be a table")
	assert((type(ruleDef.rx)=="nil" and type(ruleDef.re2)=="string") or (type(ruleDef.rx)=="string" and type(ruleDef.re2)=="nil"),"rule definition at position #"..ruleIdx.." must contain 'rx' of 're2' regexp definition")

	-- create regex rule selector, using either standard regex or re2 engines
	local regexRule
	if(type(ruleDef.rx)=="string") then
		print("Pocessing definition #"..ruleIdx.." -> regex rule: '"..ruleDef.rx.."';")
		regexRule=RegexRule(ruleDef.rx)
	elseif(type(ruleDef.re2)=="string") then
		print("Pocessing definition #"..ruleIdx.." -> re2 rule: '"..ruleDef.re2.."';")
		regexRule=RE2Rule(ruleDef.re2)
	else
		assert(false, "unsupported rule definition at position #"..ruleIdx)
	end

	-- create main actions for queries and responses
	local queryAction
	local respAction
	if (type(ruleDef.p)=="nil" and type(ruleDef.d)=="number") then
		-- query action
		if (ruleDef.d<0) then queryAction=DropAction() else queryAction=RCodeAction(ruleDef.d) end
		-- no response action will be created when droping queries
	elseif (type(ruleDef.p)=="string" and type(ruleDef.d)=="nil")  then
		queryAction=PoolAction(ruleDef.p)
		-- response action (currently only logging)
		if (type(ruleDef.la)~="nil") then
			respAction=RemoteLogResponseAction(ruleDef.la)
		end
	else
		assert(false, "rule definition at position #"..ruleIdx.." must contain either 'p' pool-action definition or 'd' drop-action definition")
	end

	assert((type(ruleDef.t)=="nil" and type(ruleDef.nt)=="table") or
		(type(ruleDef.t)=="table" and type(ruleDef.nt)=="nil") or
		(type(ruleDef.t)=="nil" and type(ruleDef.nt)=="nil"),
		"rule definition at position #"..ruleIdx.." must contain qtype definition as either 't' or 'nt' table, or neither")

	if (type(ruleDef.t)=="nil" and type(ruleDef.nt)=="nil") then
		-- simple regexp rules without matching queries against qtypes
		tryAddQueryDelay(ruleIdx,ruleDef,regexRule)
		addAction(regexRule,queryAction)
		if (type(respAction)~="nil") then
			addResponseAction(regexRule,respAction)
			tryAddResponseDelay(ruleIdx,ruleDef,regexRule)
		end
	else
		-- create action with qname-regexp and qtypes matching
		local qtrules={}
		local finalRule

		local qt -- temporary value storing table with qtypes
		if (type(ruleDef.t)=="table") then qt=ruleDef.t else qt=ruleDef.nt end

		-- iterate over 't' or 'nt' table, create QTypeRules and save it to qtrules table
		local qtrules_added=false -- for checking against empty qtypes table
		for qi,q in ipairs(qt) do
			assert(type(q)=="number","rule definition at position #"..ruleIdx.." contains invalid DNSQtype at position #"..qi)
			table.insert(qtrules,QTypeRule(q))
			qtrules_added=true
		end
		assert(qtrules_added==true,"rule definition at position #"..ruleIdx.." do not contain non-empty table with valid DNSQtype entries")

		-- generate final rule
		if (type(ruleDef.t)=="table") then
			finalRule=AndRule({regexRule,OrRule(qtrules)})
		else
			finalRule=AndRule({regexRule,NotRule(OrRule(qtrules))})
		end

		-- add final rules and optional delays
		tryAddQueryDelay(ruleIdx,ruleDef,finalRule)
		addAction(finalRule,queryAction)
		if (type(respAction)~="nil") then
			addResponseAction(finalRule,respAction)
			tryAddResponseDelay(ruleIdx,ruleDef,finalRule)
		end
	end
end

-- run dnsdist.post.lua config file before adding last rule for any dns-query not handled with rules generated before
dofile("/etc/dnsdist.post.lua")

-- add action that will generate negative response for all other non-matched queries
--addAction(AllRule(),SetNegativeAndSOAAction(true,"dnsdist",1800,"dnsdist","dnsdist",0,86400,7200,3600000,1800))
addAction(AllRule(),RCodeAction(DNSRCode.NXDOMAIN))
