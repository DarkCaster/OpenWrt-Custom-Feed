-- TODO: not finished example

-- listen on 127.0.0.1:777, allow access from 
setLocal("127.0.0.1:5300")
addLocal('192.168.1.1:5300')
setACL({"127.0.0.1/8","192.168.1.0/24"})

-- define pools of DNS servers
pools={
	lc="local",
	ext="external",
}

setVerboseHealthChecks(true)

-- define dns servers
newServer({address="1.1.1.1", pool={pools.ext}, name="cloudflare1", mustResolve=false, checkTimeout=2500, checkInterval=20, maxCheckFailures=2, qps=10, order=10})
newServer({address="1.0.0.1", pool={pools.ext}, name="cloudflare2", mustResolve=false, checkTimeout=2500, checkInterval=21, maxCheckFailures=2, qps=20, order=10})
newServer({address="8.8.8.8", pool={pools.ext}, name="google1", mustResolve=false, checkTimeout=2500, checkInterval=40, maxCheckFailures=2, qps=25, order=20})
newServer({address="8.8.4.4", pool={pools.ext}, name="google2", mustResolve=false, checkTimeout=2500, checkInterval=41, maxCheckFailures=2, qps=25, order=20})
newServer({address="208.67.222.222", pool={pools.ext}, name="opendns1", mustResolve=false, checkTimeout=5000, checkInterval=60, maxCheckFailures=2, qps=5, order=30})
newServer({address="208.67.220.220", pool={pools.ext}, name="opendns2", mustResolve=false, checkTimeout=5000, checkInterval=61, maxCheckFailures=2, qps=5, order=30})

newServer({address="127.0.0.1", pool={pools.lc}, name="dnsmasq", mustResolve=true, checkTimeout=2500, checkInterval=30, maxCheckFailures=2, qps=100, order=10
})
newServer({address="8.8.8.8", pool={pools.lc}, name="fallback", mustResolve=false, checkTimeout=5000, checkInterval=62, maxCheckFailures=2, qps=5, order=10
})

setPoolServerPolicy(firstAvailable, pools.lc)
setPoolServerPolicy(firstAvailable, pools.ext)

setCacheCleaningPercentage(50)
setStaleCacheEntriesTTL(300)

extPC=newPacketCache(250,{temporaryFailureTTL=5, staleTTL=30})
locPC=newPacketCache(250,{temporaryFailureTTL=5, staleTTL=30})

getPool(pools.ext):setCache(extPC)
getPool(pools.lc):setCache(locPC)

-- table with definitions for regexp matching-rules
definitions={
	-- queries to google.com. will be processed with regular regexp engine (rx field name, use re2 field name for use libre2 engine)
	{rx="google.com",d=-1,t={DNSQType.MX, DNSQType.NS}}, -- drop queries with qtypes DNSQType.NS or DNSQType.MX completely
	{rx="google.com",d=DNSRCode.NOERROR,t={DNSQType.A,DNSQType.ANY}}, -- answer instantly with NOERROR response for queries of type A (ipv4) or ANY
	{rx="google.com",p=pools.ext,t={DNSQType.TXT}}, -- forward DNSQType.TXT queries to dns servers from "bypass" pool
	{rx="google.com",p=pools.lc}, -- any other queries to google.com will be forwarded to dns servers from "local" pool
	-- queries to example.com
	{rx="example.com",p=pools.lc,nt={DNSQType.A,DNSQType.ANY}} -- all queries with qtypes NOT equal to DNSQType.A or DNSQType.ANY will be forwarded to "local" pool
}
