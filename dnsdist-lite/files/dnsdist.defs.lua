-- TODO: not finished example

-- listen on 127.0.0.1:777, allow access from 
setLocal("127.0.0.1:7777")
setACL({"127.0.0.1/8","192.168.1.0/24"})

-- define pools of DNS servers
pools={
	lc="local",
	bp="bypass",
}

-- define dns servers
newServer({address="127.0.0.53:53", pool={pools.lc},name="systemd-resolved",setCD=true}) -- TODO: checkfunction, check retries, etc
newServer({address="8.8.8.8:53", pool=pools.bp,name="google"})

-- table with definitions for regexp matching-rules
definitions={
	-- queries to google.com. will be processed with regular regexp engine (rx field name, use re2 field name for use libre2 engine)
	{rx="google.com",d=-1,t={DNSQType.MX, DNSQType.NS}}, -- drop queries with qtypes DNSQType.NS or DNSQType.MX completely
	{rx="google.com",d=DNSRCode.NOERROR,t={DNSQType.A,DNSQType.ANY}}, -- answer instantly with NOERROR response for queries of type A (ipv4) or ANY
	{rx="google.com",p=pools.bp,t={DNSQType.TXT}}, -- forward DNSQType.TXT queries to dns servers from "bypass" pool
	{rx="google.com",p=pools.lc}, -- any other queries to google.com will be forwarded to dns servers from "local" pool
	-- queries to example.com
	{rx="example.com",p=pools.lc,nt={DNSQType.A,DNSQType.ANY}} -- all queries with qtypes NOT equal to DNSQType.A or DNSQType.ANY will be forwarded to "local" pool
}
