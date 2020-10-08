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

-- parse definitions table and generate rules. this code may be non optimal
for ruleIdx,ruleDef in ipairs(rulesTable) do
	assert(type(ruleDef)=="table","rule definition at position #"..ruleIdx.." must be a table")
	assert((type(ruleDef.rx)=="nil" and type(ruleDef.re2)=="string") or (type(ruleDef.rx)=="string" and type(ruleDef.re2)=="nil"),"rule definition at position #"..ruleIdx.." must contain 'rx' of 're2' regexp definition")

	-- create regex rule selector, using either standard regex or re2 engines
	local regexRule
	local regexDebug -- for printing verbose messages about added rules
	if(type(ruleDef.rx)=="string") then
		regexDebug="regex rule: '"..ruleDef.rx.."';"
		regexRule=RegexRule(ruleDef.rx)
	else
		regexDebug="re2 rule: '"..ruleDef.re2.."';"
		regexRule=RE2Rule(ruleDef.re2)
	end

	local mainActionDebug -- for printing verbose messages about added actiom
	local mainAction
	if (type(ruleDef.p)=="string" and type(ruleDef.d)=="nil") then
		mainAction=PoolAction(ruleDef.p)
		mainActionDebug=" into pool "..ruleDef.p
	elseif (type(ruleDef.p)=="nil" and type(ruleDef.d)=="number") then
		if (ruleDef.d<0) then
			mainAction=DropAction()
			mainActionDebug=" to be dropped"
		else
			mainAction=RCodeAction(ruleDef.d)
			mainActionDebug=" to instant answer with DNSRCode: "..ruleDef.d
		end
	else
		assert(false, "rule definition at position #"..ruleIdx.." must contain either 'p' pool-action definition or 'd' drop-action definition")
	end

	assert((type(ruleDef.t)=="nil" and type(ruleDef.nt)=="table") or
		(type(ruleDef.t)=="table" and type(ruleDef.nt)=="nil") or
		(type(ruleDef.t)=="nil" and type(ruleDef.nt)=="nil"),
		"rule definition at position #"..ruleIdx.." must contain qtype definition as either 't' or 'nt' table, or neither")

	assert(type(ruleDef.dl)=="nil" or type(ruleDef.dl)=="number", "rule definition at position #"..ruleIdx.." delay definition is not a number")

	if (type(ruleDef.t)=="nil" and type(ruleDef.nt)=="nil") then
		-- add extra delay rule
		if (type(ruleDef.dl)=="number") then
			local delay=math.ceil(math.abs(ruleDef.dl))
			print("Adding "..regexDebug.." delay: "..delay.." ms")
			addAction(regexRule,DelayAction(delay))
		end

		-- add simple regexp rule without matching queries against qtypes
		print("Adding "..regexDebug..mainActionDebug)
		addAction(regexRule,mainAction)
	else
		-- add action with qname-regexp and qtypes matching
		local qtDebug=" matching QTypes: " -- for printing verbose messages about added rules
		local qt -- temporary value storing table with qtypes
		local qtrules={} --table with QTypeRule rules
		local qtrules_added=false --for checking against empty qtypes table
		local finalRule
		if (type(ruleDef.t)=="table") then qt=ruleDef.t else qtDebug=" NOT"..qtDebug; qt=ruleDef.nt end

		-- iterate over 't' or 'nt' table, create QTypeRules and save it to qtrules table
		for qi,q in ipairs(qt) do
			assert(type(q)=="number","rule definition at position #"..ruleIdx.." contains invalid DNSQtype at position #"..qi)
			qtDebug=qtDebug..q..","
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

		-- add extra delay rule
		if (type(ruleDef.dl)=="number") then
			local delay=math.ceil(math.abs(ruleDef.dl))
			print("Adding "..regexDebug..qtDebug.."; delay: "..delay.." ms")
			addAction(finalRule,DelayAction(delay))
		end

		-- add regexp rule with matching queries against list of qtypes
		print("Adding "..regexDebug..qtDebug..mainActionDebug)
		addAction(finalRule,mainAction)
	end
end

-- run dnsdist.post.lua config file before adding last rule for any dns-query not handled with rules generated before
dofile("/etc/dnsdist.post.lua")

-- add action that will generate negative response for all other non-matched queries
--addAction(AllRule(),SetNegativeAndSOAAction(true,"dnsdist",1800,"dnsdist","dnsdist",0,86400,7200,3600000,1800))
addAction(AllRule(),RCodeAction(DNSRCode.NXDOMAIN))
