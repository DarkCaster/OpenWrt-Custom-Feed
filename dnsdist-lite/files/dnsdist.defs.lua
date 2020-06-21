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

--[[ matches table example, rules will be generated from top to bottom 
definitions={
	{rx="regex",p=pools.lc,t={DNSQtype,DNSQtype,...}} -- match request name against regular regexps, and provided dnsqtypes
	{re2="regex",p=pools.bp,nt={DNSQtype,DNSQtype,...}} -- match request name against regexps using re2 engine, and dnsqtype mus be NOT among provided list
}
--]]

-- table with definitions for regexp matching-rules
definitions={
	{rx="google.com",d=DNSRCode.NOERROR,t={DNSQType.A}},
	{rx="google.com",p=pools.bp,t={DNSQType.MX}},
	{rx="google.com",p=pools.lc},
}
