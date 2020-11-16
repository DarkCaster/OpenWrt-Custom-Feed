-- just an example, not for production use
setLocal("127.0.0.1:5300")
addLocal("192.168.1.1:5300")
--setLocal("127.0.0.1:53") -- for use as default resolver
--addLocal("192.168.1.1:53") -- for use as default resolver
controlSocket("127.0.0.1:5199")
webserver("192.168.1.1:5198", "password", "magickey", {}, "192.168.1.0/24, 192.168.5.0/24")
setACL({"127.0.0.1/8","192.168.1.0/24","192.168.5.0/24"})

-- define pools of DNS servers
pools={
	lc="local",
	ext="external",
	isp="isp",
}

setVerboseHealthChecks(true)

-- define dns servers
newServer({address="1.1.1.1", pool={pools.ext}, name="cloudflare1", mustResolve=false, checkTimeout=2500, checkInterval=20, maxCheckFailures=2, qps=4, order=10})
newServer({address="1.0.0.1", pool={pools.ext}, name="cloudflare2", mustResolve=false, checkTimeout=2500, checkInterval=21, maxCheckFailures=2, qps=50, order=10})
newServer({address="8.8.8.8", pool={pools.ext}, name="google1", mustResolve=false, checkTimeout=2500, checkInterval=40, maxCheckFailures=2, qps=3, order=20})
newServer({address="8.8.4.4", pool={pools.ext}, name="google2", mustResolve=false, checkTimeout=2500, checkInterval=41, maxCheckFailures=2, qps=3, order=20})
newServer({address="208.67.222.222", pool={pools.ext}, name="opendns1", mustResolve=false, checkTimeout=5000, checkInterval=60, maxCheckFailures=2, qps=2, order=30})
newServer({address="208.67.220.220", pool={pools.ext}, name="opendns2", mustResolve=false, checkTimeout=5000, checkInterval=61, maxCheckFailures=2, qps=2, order=30})

-- at this example we assume that local dnsmask resolver is already set to port 5353
newServer({address="127.0.0.1:5353", pool={pools.lc}, name="local", checkName="openwrt.", mustResolve=true, checkTimeout=5000, checkInterval=5, maxCheckFailures=2, qps=100, order=10})

newServer({address="127.0.0.1:5353", pool={pools.isp}, name="isp", mustResolve=true, checkTimeout=5000, checkInterval=62, maxCheckFailures=2, qps=10000, order=10})
newServer({address="8.8.8.8", pool={pools.isp}, name="isp", mustResolve=false, checkTimeout=5000, checkInterval=63, maxCheckFailures=2, qps=50, order=20})

setPoolServerPolicy(firstAvailable, pools.lc)
setPoolServerPolicy(firstAvailable, pools.ext)
setPoolServerPolicy(firstAvailable, pools.isp)

setCacheCleaningPercentage(50)
setStaleCacheEntriesTTL(300)

extPC=newPacketCache(250,{temporaryFailureTTL=5, staleTTL=30})
locPC=newPacketCache(250,{temporaryFailureTTL=5, staleTTL=30})

getPool(pools.ext):setCache(extPC)
getPool(pools.isp):setCache(locPC)

-- example definitions for regexp matching-rules
-- rules will be created by logic at dnsdist.cfg.lua script
definitions={
--[[
	-- queries to google.com. will be processed with regular regexp engine (rx field name, use re2 field name for use libre2 engine)
	{rx="google.com",d=-1,t={DNSQType.MX, DNSQType.NS}}, -- drop queries with qtypes DNSQType.NS or DNSQType.MX completely
	{rx="google.com",d=DNSRCode.NOERROR,t={DNSQType.A,DNSQType.ANY}}, -- answer instantly with NOERROR response for queries of type A (ipv4) or ANY
	{rx="google.com",p=pools.ext,t={DNSQType.TXT}}, -- forward DNSQType.TXT queries to dns servers from "bypass" pool
	{rx="google.com",p=pools.lc}, -- any other queries to google.com will be forwarded to dns servers from "local" pool
	-- queries to example.com: forward queries of types NOT equal to AAAA or ANY to local pool, answer to other queries with NOERROR with 1000ms delay
	{rx="example.com",p=pools.lc,nt={DNSQType.AAAA,DNSQType.ANY}},
	{rx="example.com",dl=1000,d=DNSRCode.NOERROR},
	-- queries to youtube.com: log answers (la) via logger object (created by newRemoteLogger), and delay answer (dla) by 100ms. delay answers will be performed after any other answer-actions (loggins so far)
	{rx="example.com",dla=100,la=logger},
]]--
	-- local subnet
	{re2="(?i)^.*\\.lan$",p=pools.lc},
	{re2="(?i)^[^\\.]*$",p=pools.lc},
	-- overrides
	{re2="(?i)^(.+\\.|)ipv6-test\\.com$",p=pools.ext},
	{re2="(?i)^(.+\\.|)mozilla\\.[a-z]*$",p=pools.ext},
	{re2="(?i)^(.+\\.|)firefox\\.[a-z]*$",p=pools.ext},
	{re2="(?i)^(.+\\.|)mozaws\\.net*$",p=pools.ext},
	-- disable ipv6 answers for all other requests
	{re2=".*",d=DNSRCode.NOERROR,t={DNSQType.AAAA}},
	-- com zone
	{re2="(?i)^.*.com$",p=pools.isp},
	-- all other addresses
	{re2=".*",p=pools.ext},
}
