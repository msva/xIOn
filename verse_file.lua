package.preload['util.encodings']=(function(...)
local function e()
error("Function not implemented");
end
local t=require"mime";
module"encodings"
stringprep={};
base64={encode=t.b64,decode=e};
return _M;
end)
package.preload['util.hashes']=(function(...)
local e=require"util.sha1";
return{sha1=e.sha1};
end)
package.preload['util.sha1']=(function(...)
local h=string.len
local a=string.char
local g=string.byte
local k=string.sub
local s=math.floor
local t=require"bit"
local q=t.bnot
local e=t.band
local y=t.bor
local n=t.bxor
local o=t.lshift
local i=t.rshift
local d,m,f,c,l
local function p(t,e)
return o(t,e)+i(t,32-e)
end
local function u(i)
local t,o
local t=""
for n=1,8 do
o=e(i,15)
if(o<10)then
t=a(o+48)..t
else
t=a(o+87)..t
end
i=s(i/16)
end
return t
end
local function j(t)
local i,o
local n=""
i=h(t)*8
t=t..a(128)
o=56-e(h(t),63)
if(o<0)then
o=o+64
end
for e=1,o do
t=t..a(0)
end
for t=1,8 do
n=a(e(i,255))..n
i=s(i/256)
end
return t..n
end
local function b(w)
local r,t,a,o,u,h,s,v
local i,i
local i={}
while(w~="")do
for e=0,15 do
i[e]=0
for t=1,4 do
i[e]=i[e]*256+g(w,e*4+t)
end
end
for e=16,79 do
i[e]=p(n(n(i[e-3],i[e-8]),n(i[e-14],i[e-16])),1)
end
r=d
t=m
a=f
o=c
u=l
for l=0,79 do
if(l<20)then
h=y(e(t,a),e(q(t),o))
s=1518500249
elseif(l<40)then
h=n(n(t,a),o)
s=1859775393
elseif(l<60)then
h=y(y(e(t,a),e(t,o)),e(a,o))
s=2400959708
else
h=n(n(t,a),o)
s=3395469782
end
v=p(r,5)+h+u+s+i[l]
u=o
o=a
a=p(t,30)
t=r
r=v
end
d=e(d+r,4294967295)
m=e(m+t,4294967295)
f=e(f+a,4294967295)
c=e(c+o,4294967295)
l=e(l+u,4294967295)
w=k(w,65)
end
end
local function a(e,t)
e=j(e)
d=1732584193
m=4023233417
f=2562383102
c=271733878
l=3285377520
b(e)
local e=u(d)..u(m)..u(f)
..u(c)..u(l);
if t then
return e;
else
return(e:gsub("..",function(e)
return string.char(tonumber(e,16));
end));
end
end
_G.sha1={sha1=a};
return _G.sha1;
end)
package.preload['lib.adhoc']=(function(...)
local n,h=require"util.stanza",require"util.uuid";
local e="http://jabber.org/protocol/commands";
local i={}
local s={};
function _cmdtag(o,i,t,a)
local e=n.stanza("command",{xmlns=e,node=o.node,status=i});
if t then e.attr.sessionid=t;end
if a then e.attr.action=a;end
return e;
end
function s.new(e,a,t,o)
return{name=e,node=a,handler=t,cmdtag=_cmdtag,permission=(o or"user")};
end
function s.handle_cmd(o,s,a)
local e=a.tags[1].attr.sessionid or h.generate();
local t={};
t.to=a.attr.to;
t.from=a.attr.from;
t.action=a.tags[1].attr.action or"execute";
t.form=a.tags[1]:child_with_ns("jabber:x:data");
local t,h=o:handler(t,i[e]);
i[e]=h;
local a=n.reply(a);
if t.status=="completed"then
i[e]=nil;
cmdtag=o:cmdtag("completed",e);
elseif t.status=="canceled"then
i[e]=nil;
cmdtag=o:cmdtag("canceled",e);
elseif t.status=="error"then
i[e]=nil;
a=n.error_reply(a,t.error.type,t.error.condition,t.error.message);
s.send(a);
return true;
else
cmdtag=o:cmdtag("executing",e);
end
for t,e in pairs(t)do
if t=="info"then
cmdtag:tag("note",{type="info"}):text(e):up();
elseif t=="warn"then
cmdtag:tag("note",{type="warn"}):text(e):up();
elseif t=="error"then
cmdtag:tag("note",{type="error"}):text(e.message):up();
elseif t=="actions"then
local t=n.stanza("actions");
for a,e in ipairs(e)do
if(e=="prev")or(e=="next")or(e=="complete")then
t:tag(e):up();
else
module:log("error",'Command "'..o.name..
'" at node "'..o.node..'" provided an invalid action "'..e..'"');
end
end
cmdtag:add_child(t);
elseif t=="form"then
cmdtag:add_child((e.layout or e):form(e.values));
elseif t=="result"then
cmdtag:add_child((e.layout or e):form(e.values,"result"));
elseif t=="other"then
cmdtag:add_child(e);
end
end
a:add_child(cmdtag);
s.send(a);
return true;
end
return s;
end)
package.preload['util.rsm']=(function(...)
local h=require"util.stanza".stanza;
local o,n=tostring,tonumber;
local s=type;
local r=pairs;
local i='http://jabber.org/protocol/rsm';
local t;
do
local function e(e)
return n((e:get_text()));
end
local function a(e)
return e:get_text();
end
t={
after=a;
before=function(e)
return e:get_text()or true;
end;
max=e;
index=e;
first=function(e)
return{index=n(e.attr.index);e:get_text()};
end;
last=a;
count=e;
}
end
local s=setmetatable({
first=function(t,e)
if s(e)=="table"then
t:tag("first",{index=e.index}):text(e[1]):up();
else
t:tag("first"):text(o(e)):up();
end
end;
},{
__index=function(e,t)
return function(a,e)
a:tag(t):text(o(e)):up();
end
end;
});
local function a(e)
local a={};
for o in e:childtags()do
local e=o.name;
local t=e and t[e];
if t then
a[e]=t(o);
end
end
return a;
end
local function n(e)
local a=h("set",{xmlns=i});
for e,o in r(e)do
if t[e]then
s[e](a,o);
end
end
return a;
end
local function t(e)
local e=e:get_child("set",i);
if e and#e.tags>0 then
return a(e);
end
end
return{parse=a,generate=n,get=t};
end)
package.preload['util.stanza']=(function(...)
local t=table.insert;
local e=table.concat;
local d=table.remove;
local w=table.concat;
local s=string.format;
local f=string.match;
local u=tostring;
local l=setmetatable;
local e=getmetatable;
local n=pairs;
local i=ipairs;
local o=type;
local e=next;
local e=print;
local e=unpack;
local p=string.gsub;
local e=string.char;
local m=string.find;
local e=os;
local c=not e.getenv("WINDIR");
local r,a;
if c then
local t,e=pcall(require,"util.termcolours");
if t then
r,a=e.getstyle,e.getstring;
else
c=nil;
end
end
local y="urn:ietf:params:xml:ns:xmpp-stanzas";
module"stanza"
stanza_mt={__type="stanza"};
stanza_mt.__index=stanza_mt;
local e=stanza_mt;
function stanza(a,t)
local t={name=a,attr=t or{},tags={}};
return l(t,e);
end
local h=stanza;
function e:query(e)
return self:tag("query",{xmlns=e});
end
function e:body(t,e)
return self:tag("body",e):text(t);
end
function e:tag(e,a)
local a=h(e,a);
local e=self.last_add;
if not e then e={};self.last_add=e;end
(e[#e]or self):add_direct_child(a);
t(e,a);
return self;
end
function e:text(t)
local e=self.last_add;
(e and e[#e]or self):add_direct_child(t);
return self;
end
function e:up()
local e=self.last_add;
if e then d(e);end
return self;
end
function e:reset()
self.last_add=nil;
return self;
end
function e:add_direct_child(e)
if o(e)=="table"then
t(self.tags,e);
end
t(self,e);
end
function e:add_child(t)
local e=self.last_add;
(e and e[#e]or self):add_direct_child(t);
return self;
end
function e:get_child(t,a)
for o,e in i(self.tags)do
if(not t or e.name==t)
and((not a and self.attr.xmlns==e.attr.xmlns)
or e.attr.xmlns==a)then
return e;
end
end
end
function e:get_child_text(t,e)
local e=self:get_child(t,e);
if e then
return e:get_text();
end
return nil;
end
function e:child_with_name(t)
for a,e in i(self.tags)do
if e.name==t then return e;end
end
end
function e:child_with_ns(t)
for a,e in i(self.tags)do
if e.attr.xmlns==t then return e;end
end
end
function e:children()
local e=0;
return function(t)
e=e+1
return t[e];
end,self,e;
end
function e:childtags(a,e)
e=e or self.attr.xmlns;
local t=self.tags;
local i,o=1,#t;
return function()
for o=i,o do
local t=t[o];
if(not a or t.name==a)
and(not e or e==t.attr.xmlns)then
i=o+1;
return t;
end
end
end;
end
function e:maptags(o)
local a,t=self.tags,1;
local n,i=#self,#a;
local e=1;
while t<=i do
if self[e]==a[t]then
local o=o(self[e]);
if o==nil then
d(self,e);
d(a,t);
n=n-1;
i=i-1;
else
self[e]=o;
a[e]=o;
end
e=e+1;
t=t+1;
end
end
return self;
end
local d
do
local e={["'"]="&apos;",["\""]="&quot;",["<"]="&lt;",[">"]="&gt;",["&"]="&amp;"};
function d(t)return(p(t,"['&<>\"]",e));end
_M.xml_escape=d;
end
local function p(o,e,h,a,r)
local i=0;
local s=o.name
t(e,"<"..s);
for o,n in n(o.attr)do
if m(o,"\1",1,true)then
local o,s=f(o,"^([^\1]*)\1?(.*)$");
i=i+1;
t(e," xmlns:ns"..i.."='"..a(o).."' ".."ns"..i..":"..s.."='"..a(n).."'");
elseif not(o=="xmlns"and n==r)then
t(e," "..o.."='"..a(n).."'");
end
end
local i=#o;
if i==0 then
t(e,"/>");
else
t(e,">");
for i=1,i do
local i=o[i];
if i.name then
h(i,e,h,a,o.attr.xmlns);
else
t(e,a(i));
end
end
t(e,"</"..s..">");
end
end
function e.__tostring(t)
local e={};
p(t,e,p,d,nil);
return w(e);
end
function e.top_tag(t)
local e="";
if t.attr then
for t,a in n(t.attr)do if o(t)=="string"then e=e..s(" %s='%s'",t,d(u(a)));end end
end
return s("<%s%s>",t.name,e);
end
function e.get_text(e)
if#e.tags==0 then
return w(e);
end
end
function e.get_error(a)
local o,e,t;
local a=a:get_child("error");
if not a then
return nil,nil,nil;
end
o=a.attr.type;
for a in a:childtags()do
if a.attr.xmlns==y then
if not t and a.name=="text"then
t=a:get_text();
elseif not e then
e=a.name;
end
if e and t then
break;
end
end
end
return o,e or"undefined-condition",t;
end
function e.__add(e,t)
return e:add_direct_child(t);
end
do
local e=0;
function new_id()
e=e+1;
return"lx"..e;
end
end
function preserialize(e)
local a={name=e.name,attr=e.attr};
for i,e in i(e)do
if o(e)=="table"then
t(a,preserialize(e));
else
t(a,e);
end
end
return a;
end
function deserialize(a)
if a then
local s=a.attr;
for e=1,#s do s[e]=nil;end
local h={};
for e in n(s)do
if m(e,"|",1,true)and not m(e,"\1",1,true)then
local t,a=f(e,"^([^|]+)|(.+)$");
h[t.."\1"..a]=s[e];
s[e]=nil;
end
end
for e,t in n(h)do
s[e]=t;
end
l(a,e);
for t,e in i(a)do
if o(e)=="table"then
deserialize(e);
end
end
if not a.tags then
local e={};
for n,i in i(a)do
if o(i)=="table"then
t(e,i);
end
end
a.tags=e;
end
end
return a;
end
local function m(a)
local o,i={},{};
for t,e in n(a.attr)do o[t]=e;end
local o={name=a.name,attr=o,tags=i};
for e=1,#a do
local e=a[e];
if e.name then
e=m(e);
t(i,e);
end
t(o,e);
end
return l(o,e);
end
clone=m;
function message(t,e)
if not e then
return h("message",t);
else
return h("message",t):tag("body"):text(e):up();
end
end
function iq(e)
if e and not e.id then e.id=new_id();end
return h("iq",e or{id=new_id()});
end
function reply(e)
return h(e.name,e.attr and{to=e.attr.from,from=e.attr.to,id=e.attr.id,type=((e.name=="iq"and"result")or e.attr.type)});
end
do
local a={xmlns=y};
function error_reply(e,o,i,t)
local e=reply(e);
e.attr.type="error";
e:tag("error",{type=o})
:tag(i,a):up();
if(t)then e:tag("text",a):text(t):up();end
return e;
end
end
function presence(e)
return h("presence",e);
end
if c then
local h=r("yellow");
local c=r("red");
local l=r("red");
local t=r("magenta");
local r=" "..a(h,"%s")..a(t,"=")..a(c,"'%s'");
local h=a(t,"<")..a(l,"%s").."%s"..a(t,">");
local l=h.."%s"..a(t,"</")..a(l,"%s")..a(t,">");
function e.pretty_print(t)
local e="";
for a,t in i(t)do
if o(t)=="string"then
e=e..d(t);
else
e=e..t:pretty_print();
end
end
local a="";
if t.attr then
for e,t in n(t.attr)do if o(e)=="string"then a=a..s(r,e,u(t));end end
end
return s(l,t.name,a,e,t.name);
end
function e.pretty_top_tag(e)
local t="";
if e.attr then
for e,a in n(e.attr)do if o(e)=="string"then t=t..s(r,e,u(a));end end
end
return s(h,e.name,t);
end
else
e.pretty_print=e.__tostring;
e.pretty_top_tag=e.top_tag;
end
return _M;
end)
package.preload['util.timer']=(function(...)
local u=require"net.server".addtimer;
local i=require"net.server".event;
local l=require"net.server".event_base;
local n=math.min
local c=math.huge
local s=require"socket".gettime;
local h=table.insert;
local e=table.remove;
local e,r=ipairs,pairs;
local d=type;
local o={};
local e={};
module"timer"
local t;
if not i then
function t(a,o)
local i=s();
a=a+i;
if a>=i then
h(e,{a,o});
else
local e=o();
if e and d(e)=="number"then
return t(e,o);
end
end
end
u(function()
local a=s();
if#e>0 then
for a,t in r(e)do
h(o,t);
end
e={};
end
local e=c;
for h,i in r(o)do
local s,i=i[1],i[2];
if s<=a then
o[h]=nil;
local a=i(a);
if d(a)=="number"then
t(a,i);
e=n(e,a);
end
else
e=n(e,s-a);
end
end
return e;
end);
else
local a=(i.core and i.core.LEAVE)or-1;
function t(o,t)
local e;
e=l:addevent(nil,0,function()
local t=t();
if t then
return 0,t;
elseif e then
return a;
end
end
,o);
end
end
add_task=t;
return _M;
end)
package.preload['util.termcolours']=(function(...)
local l,r=table.concat,table.insert;
local t,d=string.char,string.format;
local h=ipairs;
local s=io.write;
local e;
if os.getenv("WINDIR")then
e=require"util.windows";
end
local o=e and e.get_consolecolor and e.get_consolecolor();
module"termcolours"
local n={
reset=0;bright=1,dim=2,underscore=4,blink=5,reverse=7,hidden=8;
black=30;red=31;green=32;yellow=33;blue=34;magenta=35;cyan=36;white=37;
["black background"]=40;["red background"]=41;["green background"]=42;["yellow background"]=43;["blue background"]=44;["magenta background"]=45;["cyan background"]=46;["white background"]=47;
bold=1,dark=2,underline=4,underlined=4,normal=0;
}
local i={
["0"]=o,
["1"]=7+8,
["1;33"]=2+4+8,
["1;31"]=4+8
}
local a=t(27).."[%sm%s"..t(27).."[0m";
function getstring(t,e)
if t then
return d(a,t,e);
else
return e;
end
end
function getstyle(...)
local e,t={...},{};
for a,e in h(e)do
e=n[e];
if e then
r(t,e);
end
end
return l(t,";");
end
local a="0";
function setstyle(e)
e=e or"0";
if e~=a then
s("\27["..e.."m");
a=e;
end
end
if e then
function setstyle(t)
t=t or"0";
if t~=a then
e.set_consolecolor(i[t]or o);
a=t;
end
end
if not o then
function setstyle(e)end
end
end
return _M;
end)
package.preload['util.uuid']=(function(...)
local e=math.random;
local a=tostring;
local e=os.time;
local n=os.clock;
local i=require"util.hashes".sha1;
module"uuid"
local t=0;
local function o()
local e=e();
if t>=e then e=t+1;end
t=e;
return e;
end
local function e(e)
return i(e..n()..a({}),true);
end
local t=e(o());
local function a(a)
t=e(t..a);
end
local function e(e)
if#t<e then a(o());end
local a=t:sub(0,e);
t=t:sub(e+1);
return a;
end
local function t()
return("%x"):format(e(1):byte()%4+8);
end
function generate()
return e(8).."-"..e(4).."-4"..e(3).."-"..(t())..e(3).."-"..e(12);
end
seed=a;
return _M;
end)
package.preload['net.dns']=(function(...)
local s=require"socket";
local j=require"util.timer";
local e,w=pcall(require,"util.windows");
local E=(e and w)or os.getenv("WINDIR");
local u,_,y,a,n=
coroutine,io,math,string,table;
local v,h,o,c,r,p,q,x,t,e,z=
ipairs,next,pairs,print,setmetatable,tostring,assert,error,unpack,select,type;
local e={
get=function(t,...)
local a=e('#',...);
for a=1,a do
t=t[e(a,...)];
if t==nil then break;end
end
return t;
end;
set=function(a,...)
local i=e('#',...);
local s,o=e(i-1,...);
local t,n;
for i=1,i-2 do
local i=e(i,...)
local e=a[i]
if o==nil then
if e==nil then
return;
elseif h(e,h(e))then
t=nil;n=nil;
elseif t==nil then
t=a;n=i;
end
elseif e==nil then
e={};
a[i]=e;
end
a=e
end
if o==nil and t then
t[n]=nil;
else
a[s]=o;
return o;
end
end;
};
local d,l=e.get,e.set;
local k=15;
module('dns')
local t=_M;
local i=n.insert
local function m(e)
return(e-(e%256))/256;
end
local function b(e)
local t={};
for o,e in o(e)do
t[o]=e;
t[e]=e;
t[a.lower(e)]=e;
end
return t;
end
local function f(i)
local e={};
for o,i in o(i)do
local t=a.char(m(o),o%256);
e[o]=t;
e[i]=t;
e[a.lower(i)]=t;
end
return e;
end
t.types={
'A','NS','MD','MF','CNAME','SOA','MB','MG','MR','NULL','WKS',
'PTR','HINFO','MINFO','MX','TXT',
[28]='AAAA',[29]='LOC',[33]='SRV',
[252]='AXFR',[253]='MAILB',[254]='MAILA',[255]='*'};
t.classes={'IN','CS','CH','HS',[255]='*'};
t.type=b(t.types);
t.class=b(t.classes);
t.typecode=f(t.types);
t.classcode=f(t.classes);
local function g(e,o,i)
if a.byte(e,-1)~=46 then e=e..'.';end
e=a.lower(e);
return e,t.type[o or'A'],t.class[i or'IN'];
end
local function b(t,a,i)
a=a or s.gettime();
for o,e in o(t)do
if e.tod then
e.ttl=y.floor(e.tod-a);
if e.ttl<=0 then
n.remove(t,o);
return b(t,a,i);
end
elseif i=='soft'then
q(e.ttl==0);
t[o]=nil;
end
end
end
local e={};
e.__index=e;
e.timeout=k;
local function k(e)
local e=e.type and e[e.type:lower()];
if z(e)~="string"then
return"<UNKNOWN RDATA TYPE>";
end
return e;
end
local f={
LOC=e.LOC_tostring;
MX=function(e)
return a.format('%2i %s',e.pref,e.mx);
end;
SRV=function(e)
local e=e.srv;
return a.format('%5d %5d %5d %s',e.priority,e.weight,e.port,e.target);
end;
};
local q={};
function q.__tostring(e)
local t=(f[e.type]or k)(e);
return a.format('%2s %-5s %6i %-28s %s',e.class,e.type,e.ttl,e.name,t);
end
local k={};
function k.__tostring(t)
local e={};
for a,t in o(t)do
i(e,p(t)..'\n');
end
return n.concat(e);
end
local f={};
function f.__tostring(e)
local a=s.gettime();
local t={};
for n,e in o(e)do
for n,e in o(e)do
for o,e in o(e)do
b(e,a);
i(t,p(e));
end
end
end
return n.concat(t);
end
function e:new()
local t={active={},cache={},unsorted={}};
r(t,e);
r(t.cache,f);
r(t.unsorted,{__mode='kv'});
return t;
end
function t.random(...)
y.randomseed(y.floor(1e4*s.gettime()));
t.random=y.random;
return t.random(...);
end
local function y(e)
e=e or{};
e.id=e.id or t.random(0,65535);
e.rd=e.rd or 1;
e.tc=e.tc or 0;
e.aa=e.aa or 0;
e.opcode=e.opcode or 0;
e.qr=e.qr or 0;
e.rcode=e.rcode or 0;
e.z=e.z or 0;
e.ra=e.ra or 0;
e.qdcount=e.qdcount or 1;
e.ancount=e.ancount or 0;
e.nscount=e.nscount or 0;
e.arcount=e.arcount or 0;
local t=a.char(
m(e.id),e.id%256,
e.rd+2*e.tc+4*e.aa+8*e.opcode+128*e.qr,
e.rcode+16*e.z+128*e.ra,
m(e.qdcount),e.qdcount%256,
m(e.ancount),e.ancount%256,
m(e.nscount),e.nscount%256,
m(e.arcount),e.arcount%256
);
return t,e.id;
end
local function m(t)
local e={};
for t in a.gmatch(t,'[^.]+')do
i(e,a.char(a.len(t)));
i(e,t);
end
i(e,a.char(0));
return n.concat(e);
end
local function z(o,a,e)
o=m(o);
a=t.typecode[a or'a'];
e=t.classcode[e or'in'];
return o..a..e;
end
function e:byte(e)
e=e or 1;
local t=self.offset;
local o=t+e-1;
if o>#self.packet then
x(a.format('out of bounds: %i>%i',o,#self.packet));
end
self.offset=t+e;
return a.byte(self.packet,t,o);
end
function e:word()
local e,t=self:byte(2);
return 256*e+t;
end
function e:dword()
local o,a,t,e=self:byte(4);
return 16777216*o+65536*a+256*t+e;
end
function e:sub(e)
e=e or 1;
local t=a.sub(self.packet,self.offset,self.offset+e-1);
self.offset=self.offset+e;
return t;
end
function e:header(t)
local e=self:word();
if not self.active[e]and not t then return nil;end
local e={id=e};
local t,a=self:byte(2);
e.rd=t%2;
e.tc=t/2%2;
e.aa=t/4%2;
e.opcode=t/8%16;
e.qr=t/128;
e.rcode=a%16;
e.z=a/16%8;
e.ra=a/128;
e.qdcount=self:word();
e.ancount=self:word();
e.nscount=self:word();
e.arcount=self:word();
for a,t in o(e)do e[a]=t-t%1;end
return e;
end
function e:name()
local t,a=nil,0;
local e=self:byte();
local o={};
while e>0 do
if e>=192 then
a=a+1;
if a>=20 then x('dns error: 20 pointers');end;
local e=((e-192)*256)+self:byte();
t=t or self.offset;
self.offset=e+1;
else
i(o,self:sub(e)..'.');
end
e=self:byte();
end
self.offset=t or self.offset;
return n.concat(o);
end
function e:question()
local e={};
e.name=self:name();
e.type=t.type[self:word()];
e.class=t.class[self:word()];
return e;
end
function e:A(e)
local t,i,o,n=self:byte(4);
e.a=a.format('%i.%i.%i.%i',t,i,o,n);
end
function e:AAAA(a)
local e={};
for t=1,a.rdlength,2 do
local t,a=self:byte(2);
n.insert(e,("%02x%02x"):format(t,a));
end
e=n.concat(e,":"):gsub("%f[%x]0+(%x)","%1");
local t={};
for e in e:gmatch(":[0:]+:")do
n.insert(t,e)
end
if#t==0 then
a.aaaa=e;
return
elseif#t>1 then
n.sort(t,function(e,t)return#e>#t end);
end
a.aaaa=e:gsub(t[1],"::",1):gsub("^0::","::"):gsub("::0$","::");
end
function e:CNAME(e)
e.cname=self:name();
end
function e:MX(e)
e.pref=self:word();
e.mx=self:name();
end
function e:LOC_nibble_power()
local e=self:byte();
return((e-(e%16))/16)*(10^(e%16));
end
function e:LOC(e)
e.version=self:byte();
if e.version==0 then
e.loc=e.loc or{};
e.loc.size=self:LOC_nibble_power();
e.loc.horiz_pre=self:LOC_nibble_power();
e.loc.vert_pre=self:LOC_nibble_power();
e.loc.latitude=self:dword();
e.loc.longitude=self:dword();
e.loc.altitude=self:dword();
end
end
local function m(e,i,t)
e=e-2147483648;
if e<0 then i=t;e=-e;end
local n,o,t;
t=e%6e4;
e=(e-t)/6e4;
o=e%60;
n=(e-o)/60;
return a.format('%3d %2d %2.3f %s',n,o,t/1e3,i);
end
function e.LOC_tostring(e)
local t={};
i(t,a.format(
'%s    %s    %.2fm %.2fm %.2fm %.2fm',
m(e.loc.latitude,'N','S'),
m(e.loc.longitude,'E','W'),
(e.loc.altitude-1e7)/100,
e.loc.size/100,
e.loc.horiz_pre/100,
e.loc.vert_pre/100
));
return n.concat(t);
end
function e:NS(e)
e.ns=self:name();
end
function e:SOA(e)
end
function e:SRV(e)
e.srv={};
e.srv.priority=self:word();
e.srv.weight=self:word();
e.srv.port=self:word();
e.srv.target=self:name();
end
function e:PTR(e)
e.ptr=self:name();
end
function e:TXT(e)
e.txt=self:sub(self:byte());
end
function e:rr()
local e={};
r(e,q);
e.name=self:name(self);
e.type=t.type[self:word()]or e.type;
e.class=t.class[self:word()]or e.class;
e.ttl=65536*self:word()+self:word();
e.rdlength=self:word();
if e.ttl<=0 then
e.tod=self.time+30;
else
e.tod=self.time+e.ttl;
end
local a=self.offset;
local t=self[t.type[e.type]];
if t then t(self,e);end
self.offset=a;
e.rdata=self:sub(e.rdlength);
return e;
end
function e:rrs(t)
local e={};
for t=1,t do i(e,self:rr());end
return e;
end
function e:decode(t,o)
self.packet,self.offset=t,1;
local t=self:header(o);
if not t then return nil;end
local t={header=t};
t.question={};
local n=self.offset;
for e=1,t.header.qdcount do
i(t.question,self:question());
end
t.question.raw=a.sub(self.packet,n,self.offset-1);
if not o then
if not self.active[t.header.id]or not self.active[t.header.id][t.question.raw]then
return nil;
end
end
t.answer=self:rrs(t.header.ancount);
t.authority=self:rrs(t.header.nscount);
t.additional=self:rrs(t.header.arcount);
return t;
end
e.delays={1,3};
function e:addnameserver(e)
self.server=self.server or{};
i(self.server,e);
end
function e:setnameserver(e)
self.server={};
self:addnameserver(e);
end
function e:adddefaultnameservers()
if E then
if w and w.get_nameservers then
for t,e in v(w.get_nameservers())do
self:addnameserver(e);
end
end
if not self.server or#self.server==0 then
self:addnameserver("208.67.222.222");
self:addnameserver("208.67.220.220");
end
else
local e=_.open("/etc/resolv.conf");
if e then
for e in e:lines()do
e=e:gsub("#.*$","")
:match('^%s*nameserver%s+(.*)%s*$');
if e then
e:gsub("%f[%d.](%d+%.%d+%.%d+%.%d+)%f[^%d.]",function(e)
self:addnameserver(e)
end);
end
end
end
if not self.server or#self.server==0 then
self:addnameserver("127.0.0.1");
end
end
end
function e:getsocket(t)
self.socket=self.socket or{};
self.socketset=self.socketset or{};
local e=self.socket[t];
if e then return e;end
local a;
e,a=s.udp();
if not e then
return nil,a;
end
if self.socket_wrapper then e=self.socket_wrapper(e,self);end
e:settimeout(0);
e:setsockname('*',0);
e:setpeername(self.server[t],53);
self.socket[t]=e;
self.socketset[e]=t;
return e;
end
function e:voidsocket(e)
if self.socket[e]then
self.socketset[self.socket[e]]=nil;
self.socket[e]=nil;
elseif self.socketset[e]then
self.socket[self.socketset[e]]=nil;
self.socketset[e]=nil;
end
end
function e:socket_wrapper_set(e)
self.socket_wrapper=e;
end
function e:closeall()
for t,e in v(self.socket)do
self.socket[t]=nil;
self.socketset[e]=nil;
e:close();
end
end
function e:remember(e,t)
local o,n,a=g(e.name,e.type,e.class);
if t~='*'then
t=n;
local t=d(self.cache,a,'*',o);
if t then i(t,e);end
end
self.cache=self.cache or r({},f);
local a=d(self.cache,a,t,o)or
l(self.cache,a,t,o,r({},k));
i(a,e);
if t=='MX'then self.unsorted[a]=true;end
end
local function i(e,t)
return(e.pref==t.pref)and(e.mx<t.mx)or(e.pref<t.pref);
end
function e:peek(o,t,a)
o,t,a=g(o,t,a);
local e=d(self.cache,a,t,o);
if not e then return nil;end
if b(e,s.gettime())and t=='*'or not h(e)then
l(self.cache,a,t,o,nil);
return nil;
end
if self.unsorted[e]then n.sort(e,i);end
return e;
end
function e:purge(e)
if e=='soft'then
self.time=s.gettime();
for t,e in o(self.cache or{})do
for t,e in o(e)do
for t,e in o(e)do
b(e,self.time,'soft')
end
end
end
else self.cache=r({},f);end
end
function e:query(t,e,a)
t,e,a=g(t,e,a)
if not self.server then self:adddefaultnameservers();end
local n=z(t,e,a);
local o=self:peek(t,e,a);
if o then return o;end
local o,i=y();
local o={
packet=o..n,
server=self.best_server,
delay=1,
retry=s.gettime()+self.delays[1]
};
self.active[i]=self.active[i]or{};
self.active[i][n]=o;
local n=u.running();
if n then
l(self.wanted,a,e,t,n,true);
end
local i,h=self:getsocket(o.server)
if not i then
return nil,h;
end
i:send(o.packet)
if j and self.timeout then
local r=#self.server;
local s=1;
j.add_task(self.timeout,function()
if d(self.wanted,a,e,t,n)then
if s<r then
s=s+1;
self:servfail(i);
o.server=self.best_server;
i,h=self:getsocket(o.server);
if i then
i:send(o.packet);
return self.timeout;
end
end
self:cancel(a,e,t,n,true);
end
end)
end
return true;
end
function e:servfail(e)
local a=self.socketset[e]
self:voidsocket(e);
self.time=s.gettime();
for e,t in o(self.active)do
for o,e in o(t)do
if e.server==a then
e.server=e.server+1
if e.server>#self.server then
e.server=1;
end
e.retries=(e.retries or 0)+1;
if e.retries>=#self.server then
t[o]=nil;
else
local t=self:getsocket(e.server);
if t then t:send(e.packet);end
end
end
end
end
if a==self.best_server then
self.best_server=self.best_server+1;
if self.best_server>#self.server then
self.best_server=1;
end
end
end
function e:settimeout(e)
self.timeout=e;
end
function e:receive(t)
self.time=s.gettime();
t=t or self.socket;
local e;
for a,t in o(t)do
if self.socketset[t]then
local t=t:receive();
if t then
e=self:decode(t);
if e and self.active[e.header.id]
and self.active[e.header.id][e.question.raw]then
for a,t in o(e.answer)do
if t.name:sub(-#e.question[1].name,-1)==e.question[1].name then
self:remember(t,e.question[1].type)
end
end
local t=self.active[e.header.id];
t[e.question.raw]=nil;
if not h(t)then self.active[e.header.id]=nil;end
if not h(self.active)then self:closeall();end
local e=e.question[1];
local t=d(self.wanted,e.class,e.type,e.name);
if t then
for t in o(t)do
l(self.yielded,t,e.class,e.type,e.name,nil);
if u.status(t)=="suspended"then u.resume(t);end
end
l(self.wanted,e.class,e.type,e.name,nil);
end
end
end
end
end
return e;
end
function e:feed(a,t,e)
self.time=s.gettime();
local e=self:decode(t,e);
if e and self.active[e.header.id]
and self.active[e.header.id][e.question.raw]then
for a,t in o(e.answer)do
self:remember(t,e.question[1].type);
end
local t=self.active[e.header.id];
t[e.question.raw]=nil;
if not h(t)then self.active[e.header.id]=nil;end
if not h(self.active)then self:closeall();end
local e=e.question[1];
if e then
local t=d(self.wanted,e.class,e.type,e.name);
if t then
for t in o(t)do
l(self.yielded,t,e.class,e.type,e.name,nil);
if u.status(t)=="suspended"then u.resume(t);end
end
l(self.wanted,e.class,e.type,e.name,nil);
end
end
end
return e;
end
function e:cancel(t,a,i,e,o)
local t=d(self.wanted,t,a,i);
if t then
if o then
u.resume(e);
end
t[e]=nil;
end
end
function e:pulse()
while self:receive()do end
if not h(self.active)then return nil;end
self.time=s.gettime();
for i,t in o(self.active)do
for a,e in o(t)do
if self.time>=e.retry then
e.server=e.server+1;
if e.server>#self.server then
e.server=1;
e.delay=e.delay+1;
end
if e.delay>#self.delays then
t[a]=nil;
if not h(t)then self.active[i]=nil;end
if not h(self.active)then return nil;end
else
local t=self.socket[e.server];
if t then t:send(e.packet);end
e.retry=self.time+self.delays[e.delay];
end
end
end
end
if h(self.active)then return true;end
return nil;
end
function e:lookup(a,o,t)
self:query(a,o,t)
while self:pulse()do
local e={}
for t,a in v(self.socket)do
e[t]=a
end
s.select(e,nil,4)
end
return self:peek(a,o,t);
end
function e:lookupex(o,e,t,a)
return self:peek(e,t,a)or self:query(e,t,a);
end
function e:tohostname(e)
return t.lookup(e:gsub("(%d+)%.(%d+)%.(%d+)%.(%d+)","%4.%3.%2.%1.in-addr.arpa."),"PTR");
end
local i={
qr={[0]='query','response'},
opcode={[0]='query','inverse query','server status request'},
aa={[0]='non-authoritative','authoritative'},
tc={[0]='complete','truncated'},
rd={[0]='recursion not desired','recursion desired'},
ra={[0]='recursion not available','recursion available'},
z={[0]='(reserved)'},
rcode={[0]='no error','format error','server failure','name error','not implemented'},
type=t.type,
class=t.class
};
local function n(t,e)
return(i[e]and i[e][t[e]])or'';
end
function e.print(t)
for o,e in o{'id','qr','opcode','aa','tc','rd','ra','z',
'rcode','qdcount','ancount','nscount','arcount'}do
c(a.format('%-30s','header.'..e),t.header[e],n(t.header,e));
end
for t,e in v(t.question)do
c(a.format('question[%i].name         ',t),e.name);
c(a.format('question[%i].type         ',t),e.type);
c(a.format('question[%i].class        ',t),e.class);
end
local h={name=1,type=1,class=1,ttl=1,rdlength=1,rdata=1};
local e;
for s,i in o({'answer','authority','additional'})do
for s,t in o(t[i])do
for h,o in o({'name','type','class','ttl','rdlength'})do
e=a.format('%s[%i].%s',i,s,o);
c(a.format('%-30s',e),t[o],n(t,o));
end
for t,o in o(t)do
if not h[t]then
e=a.format('%s[%i].%s',i,s,t);
c(a.format('%-30s  %s',p(e),p(o)));
end
end
end
end
end
function t.resolver()
local t={active={},cache={},unsorted={},wanted={},yielded={},best_server=1};
r(t,e);
r(t.cache,f);
r(t.unsorted,{__mode='kv'});
return t;
end
local e=t.resolver();
t._resolver=e;
function t.lookup(...)
return e:lookup(...);
end
function t.tohostname(...)
return e:tohostname(...);
end
function t.purge(...)
return e:purge(...);
end
function t.peek(...)
return e:peek(...);
end
function t.query(...)
return e:query(...);
end
function t.feed(...)
return e:feed(...);
end
function t.cancel(...)
return e:cancel(...);
end
function t.settimeout(...)
return e:settimeout(...);
end
function t.socket_wrapper_set(...)
return e:socket_wrapper_set(...);
end
return t;
end)
package.preload['net.adns']=(function(...)
local c=require"net.server";
local o=require"net.dns";
local e=require"util.logger".init("adns");
local t,t=table.insert,table.remove;
local i,s,l=coroutine,tostring,pcall;
local function u(a,a,t,e)return(e-t)+1;end
module"adns"
function lookup(d,t,r,h)
return i.wrap(function(a)
if a then
e("debug","Records for %s already cached, using those...",t);
d(a);
return;
end
e("debug","Records for %s not in cache, sending query (%s)...",t,s(i.running()));
local a,n=o.query(t,r,h);
if a then
i.yield({h or"IN",r or"A",t,i.running()});
e("debug","Reply for %s (%s)",t,s(i.running()));
end
if a then
a,n=l(d,o.peek(t,r,h));
else
e("error","Error sending DNS query: %s",n);
a,n=l(d,nil,n);
end
if not a then
e("error","Error in DNS response handler: %s",s(n));
end
end)(o.peek(t,r,h));
end
function cancel(t,a,i)
e("warn","Cancelling DNS lookup for %s",s(t[3]));
o.cancel(t[1],t[2],t[3],t[4],a);
end
function new_async_socket(a,i)
local s="<unknown>";
local n={};
local t={};
function n.onincoming(a,e)
if e then
o.feed(t,e);
end
end
function n.ondisconnect(a,o)
if o then
e("warn","DNS socket for %s disconnected: %s",s,o);
local t=i.server;
if i.socketset[a]==i.best_server and i.best_server==#t then
e("error","Exhausted all %d configured DNS servers, next lookup will try %s again",#t,t[1]);
end
i:servfail(a);
end
end
t=c.wrapclient(a,"dns",53,n);
if not t then
e("warn","handler is nil");
end
t.settimeout=function()end
t.setsockname=function(e,...)return a:setsockname(...);end
t.setpeername=function(e,...)s=(...);local a=a:setpeername(...);e:set_send(u);return a;end
t.connect=function(e,...)return a:connect(...)end
t.send=function(t,o)
local t=a.getpeername;
e("debug","Sending DNS query to %s",(t and t(a))or"<unconnected>");
return a:send(o);
end
return t;
end
o.socket_wrapper_set(new_async_socket);
return _M;
end)
package.preload['net.server']=(function(...)
local d=function(e)
return _G[e]
end
local le=function(e)
for t,a in pairs(e)do
e[t]=nil
end
end
local C,e=require("util.logger").init("socket"),table.concat;
local i=function(...)return C("debug",e{...});end
local de=function(...)return C("warn",e{...});end
local e=collectgarbage
local he=1
local L=d"type"
local S=d"pairs"
local re=d"ipairs"
local b=d"tonumber"
local l=d"tostring"
local e=d"collectgarbage"
local o=d"os"
local e=d"table"
local a=d"string"
local t=d"coroutine"
local Q=o.difftime
local K=math.min
local me=math.huge
local ce=e.concat
local e=e.remove
local ue=a.len
local be=a.sub
local ge=t.wrap
local ve=t.yield
local q=d"ssl"
local x=d"socket"or require"socket"
local Y=x.gettime
local pe=(q and q.wrap)
local ye=x.bind
local we=x.sleep
local fe=x.select
local e=(q and q.newcontext)
local P
local V
local ee
local G
local B
local Z
local c
local te
local ae
local oe
local ne
local J
local s
local ie
local e
local R
local se
local v
local h
local D
local r
local n
local H
local k
local w
local f
local a
local o
local g
local U
local M
local T
local A
local X
local u
local O
local N
local I
local _
local z
local W
local F
local j
local E
v={}
h={}
r={}
D={}
n={}
k={}
w={}
H={}
a=0
o=0
g=0
U=0
M=0
T=1
A=0
O=51e3*1024
N=25e3*1024
I=12e5
_=6e4
z=6*60*60
W=false
j=1e3
E=30
oe=function(f,t,y,u,v,m,c)
c=c or j
local d=0
local w,e=f.onconnect,f.ondisconnect
local p=t.accept
local e={}
e.shutdown=function()end
e.ssl=function()
return m~=nil
end
e.sslctx=function()
return m
end
e.remove=function()
d=d-1
end
e.close=function()
for a,e in S(n)do
if e.serverport==u then
e.disconnect(e,"server closed")
e:close(true)
end
end
t:close()
o=s(r,t,o)
a=s(h,t,a)
n[t]=nil
e=nil
t=nil
i"server.lua: closed server handler and removed sockets from list"
end
e.ip=function()
return y
end
e.serverport=function()
return u
end
e.socket=function()
return t
end
e.readbuffer=function()
if d>c then
i("server.lua: refused new client connection: server full")
return false
end
local t,a=p(t)
if t then
local a,o=t:getpeername()
t:settimeout(0)
local t,n,e=R(e,f,t,a,u,o,v,m)
if e then
return false
end
d=d+1
i("server.lua: accepted new client connection from ",l(a),":",l(o)," to ",l(u))
if w then
return w(t);
end
return;
elseif a then
i("server.lua: error with new client connection: ",l(a))
return false
end
end
return e
end
R=function(I,v,t,F,J,S,z,j)
t:settimeout(0)
local y
local _
local x
local Y
local B=v.onincoming
local V=v.onstatus
local b=v.ondisconnect
local K=v.ondrain
local p={}
local d=0
local Q
local L
local D
local m=0
local g=false
local A=false
local R,C=0,0
local T=O
local O=N
local e=p
e.dispatch=function()
return B
end
e.disconnect=function()
return b
end
e.setlistener=function(a,t)
B=t.onincoming
b=t.ondisconnect
V=t.onstatus
K=t.ondrain
end
e.getstats=function()
return C,R
end
e.ssl=function()
return Y
end
e.sslctx=function()
return j
end
e.send=function(n,i,o,a)
return y(t,i,o,a)
end
e.receive=function(o,a)
return _(t,o,a)
end
e.shutdown=function(a)
return x(t,a)
end
e.setoption=function(i,a,o)
if t.setoption then
return t:setoption(a,o);
end
return false,"setoption not implemented";
end
e.close=function(u,l)
if not e then return true;end
a=s(h,t,a)
k[e]=nil
if d~=0 then
if not(l or L)then
e.sendbuffer()
if d~=0 then
if e then
e.write=nil
end
Q=true
return false
end
else
y(t,ce(p,"",1,d),1,m)
end
end
if t then
f=x and x(t)
t:close()
o=s(r,t,o)
n[t]=nil
t=nil
else
i"server.lua: socket already closed"
end
if e then
w[e]=nil
H[e]=nil
e=nil
end
if I then
I.remove()
end
i"server.lua: closed client handler and removed socket from list"
return true
end
e.ip=function()
return F
end
e.serverport=function()
return J
end
e.clientport=function()
return S
end
local I=function(i,a)
m=m+ue(a)
if m>T then
H[e]="send buffer exceeded"
e.write=G
return false
elseif t and not r[t]then
o=c(r,t,o)
end
d=d+1
p[d]=a
if e then
w[e]=w[e]or u
end
return true
end
e.write=I
e.bufferqueue=function(t)
return p
end
e.socket=function(a)
return t
end
e.set_mode=function(a,t)
z=t or z
return z
end
e.set_send=function(a,t)
y=t or y
return y
end
e.bufferlen=function(o,t,a)
T=a or T
O=t or O
return m,O,T
end
e.lock_read=function(i,o)
if o==true then
local o=a
a=s(h,t,a)
k[e]=nil
if a~=o then
g=true
end
elseif o==false then
if g then
g=false
a=c(h,t,a)
k[e]=u
end
end
return g
end
e.pause=function(t)
return t:lock_read(true);
end
e.resume=function(t)
return t:lock_read(false);
end
e.lock=function(i,a)
e.lock_read(a)
if a==true then
e.write=G
local a=o
o=s(r,t,o)
w[e]=nil
if o~=a then
A=true
end
elseif a==false then
e.write=I
if A then
A=false
I("")
end
end
return g,A
end
local g=function()
local a,t,o=_(t,z)
if not t or(t=="wantread"or t=="timeout")then
local o=a or o or""
local a=ue(o)
if a>O then
b(e,"receive buffer exceeded")
e:close(true)
return false
end
local a=a*he
C=C+a
M=M+a
k[e]=u
return B(e,o,t)
else
i("server.lua: client ",l(F),":",l(S)," read error: ",l(t))
L=true
b(e,t)
f=e and e:close()
return false
end
end
local m=function()
local v,a,h,n,c;
local c;
if t then
n=ce(p,"",1,d)
v,a,h=y(t,n,1,m)
c=(v or h or 0)*he
R=R+c
U=U+c
f=W and le(p)
else
v,a,c=false,"closed",0;
end
if v then
d=0
m=0
o=s(r,t,o)
w[e]=nil
if K then
K(e)
end
f=D and e:starttls(nil)
f=Q and e:close()
return true
elseif h and(a=="timeout"or a=="wantwrite")then
n=be(n,h+1,m)
p[1]=n
d=1
m=m-h
w[e]=u
return true
else
i("server.lua: client ",l(F),":",l(S)," write error: ",l(a))
L=true
b(e,a)
f=e and e:close()
return false
end
end
local u;
function e.set_sslctx(y,t)
j=t;
local d,w
u=ge(function(t)
local n
for l=1,E do
o=(w and s(r,t,o))or o
a=(d and s(h,t,a))or a
d,w=nil,nil
f,n=t:dohandshake()
if not n then
i("server.lua: ssl handshake done")
e.readbuffer=g
e.sendbuffer=m
f=V and V(e,"ssl-handshake-complete")
if y.autostart_ssl and v.onconnect then
v.onconnect(y);
end
a=c(h,t,a)
return true
else
if n=="wantwrite"then
o=c(r,t,o)
w=true
elseif n=="wantread"then
a=c(h,t,a)
d=true
else
break;
end
n=nil;
ve()
end
end
i("server.lua: ssl handshake error: ",l(n or"handshake too long"))
b(e,"ssl handshake failed")
f=e and e:close(true)
return false
end
)
end
if q then
e.starttls=function(f,m)
if m then
e:set_sslctx(m);
end
if d>0 then
i"server.lua: we need to do tls, but delaying until send buffer empty"
D=true
return
end
i("server.lua: attempting to start tls on "..l(t))
local m,d=t
t,d=pe(t,j)
if not t then
i("server.lua: error while starting tls on client: ",l(d or"unknown error"))
return nil,d
end
t:settimeout(0)
y=t.send
_=t.receive
x=P
n[t]=e
a=c(h,t,a)
a=s(h,m,a)
o=s(r,m,o)
n[m]=nil
e.starttls=nil
D=nil
Y=true
e.readbuffer=u
e.sendbuffer=u
u(t)
end
e.readbuffer=g
e.sendbuffer=m
if j then
i"server.lua: auto-starting ssl negotiation..."
e.autostart_ssl=true;
e:starttls(j);
end
else
e.readbuffer=g
e.sendbuffer=m
end
y=t.send
_=t.receive
x=(Y and P)or t.shutdown
n[t]=e
a=c(h,t,a)
return e,t
end
P=function()
end
G=function()
return false
end
c=function(a,t,e)
if not a[t]then
e=e+1
a[e]=t
a[t]=e
end
return e;
end
s=function(e,i,t)
local o=e[i]
if o then
e[i]=nil
local a=e[t]
e[t]=nil
if a~=i then
e[a]=o
e[o]=a
end
return t-1
end
return t
end
J=function(e)
o=s(r,e,o)
a=s(h,e,a)
n[e]=nil
e:close()
end
local function m(a,t,o)
local e;
local i=t.sendbuffer;
function t.sendbuffer()
i();
if e and t.bufferlen()<o then
a:lock_read(false);
e=nil;
end
end
local i=a.readbuffer;
function a.readbuffer()
i();
if not e and t.bufferlen()>=o then
e=true;
a:lock_read(true);
end
end
end
te=function(t,e,d,l,r)
local o
if L(d)~="table"then
o="invalid listener table"
end
if L(e)~="number"or not(e>=0 and e<=65535)then
o="invalid port"
elseif v[t..":"..e]then
o="listeners on '["..t.."]:"..e.."' already exist"
elseif r and not q then
o="luasec not found"
end
if o then
de("server.lua, [",t,"]:",e,": ",o)
return nil,o
end
t=t or"*"
local o,s=ye(t,e)
if s then
de("server.lua, [",t,"]:",e,": ",s)
return nil,s
end
local s,d=oe(d,o,t,e,l,r,j)
if not s then
o:close()
return nil,d
end
o:settimeout(0)
a=c(h,o,a)
v[t..":"..e]=s
n[o]=s
i("server.lua: new "..(r and"ssl "or"").."server listener on '[",t,"]:",e,"'")
return s
end
ae=function(t,e)
return v[t..":"..e];
end
ie=function(t,e)
local a=v[t..":"..e]
if not a then
return nil,"no server found on '["..t.."]:"..l(e).."'"
end
a:close()
v[t..":"..e]=nil
return true
end
Z=function()
for t,e in S(n)do
e:close()
n[t]=nil
end
a=0
o=0
g=0
v={}
h={}
r={}
D={}
n={}
end
ne=function()
return T,A,O,N,I,_,z,W,j,E
end
se=function(e)
if L(e)~="table"then
return nil,"invalid settings table"
end
T=b(e.timeout)or T
A=b(e.sleeptime)or A
O=b(e.maxsendlen)or O
N=b(e.maxreadlen)or N
I=b(e.checkinterval)or I
_=b(e.sendtimeout)or _
z=b(e.readtimeout)or z
W=e.cleanqueue
j=e._maxclientsperserver or j
E=e._maxsslhandshake or E
return true
end
B=function(e)
if L(e)~="function"then
return nil,"invalid listener function"
end
g=g+1
D[g]=e
return true
end
ee=function()
return M,U,a,o,g
end
local t;
local function l(e)
t=not not e;
end
V=function(a)
if t then return"quitting";end
if a then t="once";end
local e=me;
repeat
local a,o,s=fe(h,r,K(T,e))
for t,e in re(o)do
local t=n[e]
if t then
t.sendbuffer()
else
J(e)
i"server.lua: found no handler and closed socket (writelist)"
end
end
for t,e in re(a)do
local t=n[e]
if t then
t.readbuffer()
else
J(e)
i"server.lua: found no handler and closed socket (readlist)"
end
end
for e,t in S(H)do
e.disconnect()(e,t)
e:close(true)
end
le(H)
u=Y()
if u-F>=K(e,1)then
e=me;
for t=1,g do
local t=D[t](u)
if t then e=K(e,t);end
end
F=u
else
e=e-(u-F);
end
we(A)
until t;
if a and t=="once"then t=nil;return;end
return"quitting"
end
local function h()
return V(true);
end
local function y()
return"select";
end
local s=function(t,e,d,a,h,i)
local e=R(nil,a,t,e,d,"clientport",h,i)
n[t]=e
if not i then
o=c(r,t,o)
if a.onconnect then
local i=e.sendbuffer;
e.sendbuffer=function()
o=s(r,t,o);
e.sendbuffer=i;
a.onconnect(e);
if#e:bufferqueue()>0 then
return i();
end
end
end
end
return e,t
end
local a=function(a,o,i,n,h)
local t,e=x.tcp()
if e then
return nil,e
end
t:settimeout(0)
f,e=t:connect(a,o)
if e then
local e=s(t,a,o,i)
else
R(nil,i,t,a,o,"clientport",n,h)
end
end
d"setmetatable"(n,{__mode="k"})
d"setmetatable"(k,{__mode="k"})
d"setmetatable"(w,{__mode="k"})
F=Y()
X=Y()
B(function()
local e=Q(u-X)
if e>I then
X=u
for e,t in S(w)do
if Q(u-t)>_ then
e.disconnect()(e,"send timeout")
e:close(true)
end
end
for e,t in S(k)do
if Q(u-t)>z then
e.disconnect()(e,"read timeout")
e:close()
end
end
end
end
)
local function t(e)
local t=C;
if e then
C=e;
end
return t;
end
return{
addclient=a,
wrapclient=s,
loop=V,
link=m,
step=h,
stats=ee,
closeall=Z,
addtimer=B,
addserver=te,
getserver=ae,
setlogger=t,
getsettings=ne,
setquitting=l,
removeserver=ie,
get_backend=y,
changesettings=se,
}
end)
package.preload['util.xmppstream']=(function(...)
local e=require"lxp";
local t=require"util.stanza";
local b=t.stanza_mt;
local o=tostring;
local h=table.insert;
local v=table.concat;
local k=table.remove;
local w=setmetatable;
local u=require"util.logger".init("xmppstream");
local y=pcall(e.new,{StartDoctypeDecl=false});
if not y then
u("warn","The version of LuaExpat on your system leaves Prosody "
.."vulnerable to denial-of-service attacks. You should upgrade to "
.."LuaExpat 1.1.1 or higher as soon as possible. See "
.."http://prosody.im/doc/depends#luaexpat for more information.");
end
local p=error;
module"xmppstream"
local f=e.new;
local g={
["http://www.w3.org/XML/1998/namespace"]="xml";
};
local a="http://etherx.jabber.org/streams";
local s="\1";
local d="^([^"..s.."]*)"..s.."?(.*)$";
_M.ns_separator=s;
_M.ns_pattern=d;
function new_sax_handlers(t,e)
local n={};
local f=t.log or u;
local m=e.streamopened;
local c=e.streamclosed;
local r=e.error or function(t,e)p("XML stream error: "..o(e));end;
local q=e.handlestanza;
local a=e.stream_ns or a;
local l=e.stream_tag or"stream";
if a~=""then
l=a..s..l;
end
local x=a..s..(e.error_tag or"error");
local j=e.default_ns;
local s={};
local o,e={};
local i=0;
function n:StartElement(u,a)
if e and#o>0 then
h(e,v(o));
o={};
end
local n,o=u:match(d);
if o==""then
n,o="",n;
end
if n~=j or i>0 then
a.xmlns=n;
i=i+1;
end
for e=1,#a do
local t=a[e];
a[e]=nil;
local e,o=t:match(d);
if o~=""then
e=g[e];
if e then
a[e..":"..o]=a[t];
a[t]=nil;
end
end
end
if not e then
if t.notopen then
if u==l then
i=0;
if m then
m(t,a);
end
else
r(t,"no-stream");
end
return;
end
if n=="jabber:client"and o~="iq"and o~="presence"and o~="message"then
r(t,"invalid-top-level-element");
end
e=w({name=o,attr=a,tags={}},b);
else
h(s,e);
local t=e;
e=w({name=o,attr=a,tags={}},b);
h(t,e);
h(t.tags,e);
end
end
function n:CharacterData(t)
if e then
h(o,t);
end
end
function n:EndElement(a)
if i>0 then
i=i-1;
end
if e then
if#o>0 then
h(e,v(o));
o={};
end
if#s==0 then
if a~=x then
q(t,e);
else
r(t,"stream-error",e);
end
e=nil;
else
e=k(s);
end
else
if a==l then
if c then
c(t);
end
else
local a,e=a:match(d);
if e==""then
a,e="",a;
end
r(t,"parse-error","unexpected-element-close",e);
end
e,o=nil,{};
s={};
end
end
local function a(e)
r(t,"parse-error","restricted-xml","Restricted XML, see RFC 6120 section 11.1.");
if not e.stop or not e:stop()then
p("Failed to abort parsing");
end
end
if y then
n.StartDoctypeDecl=a;
end
n.Comment=a;
n.ProcessingInstruction=a;
local function a()
e,o=nil,{};
s={};
end
local function o(a,e)
t=e;
f=e.log or u;
end
return n,{reset=a,set_session=o};
end
function new(e,t)
local t,a=new_sax_handlers(e,t);
local e=f(t,s);
local o=e.parse;
return{
reset=function()
e=f(t,s);
o=e.parse;
a.reset();
end,
feed=function(a,t)
return o(e,t);
end,
set_session=a.set_session;
};
end
return _M;
end)
package.preload['util.jid']=(function(...)
local a=string.match;
local s=require"util.encodings".stringprep.nodeprep;
local h=require"util.encodings".stringprep.nameprep;
local r=require"util.encodings".stringprep.resourceprep;
local o={
[" "]="\\20";['"']="\\22";
["&"]="\\26";["'"]="\\27";
["/"]="\\2f";[":"]="\\3a";
["<"]="\\3c";[">"]="\\3e";
["@"]="\\40";["\\"]="\\5c";
};
local n={};
for e,t in pairs(o)do n[t]=e;end
module"jid"
local function t(e)
if not e then return;end
local o,t=a(e,"^([^@/]+)@()");
local t,i=a(e,"^([^@/]+)()",t)
if o and not t then return nil,nil,nil;end
local a=a(e,"^/(.+)$",i);
if(not t)or((not a)and#e>=i)then return nil,nil,nil;end
return o,t,a;
end
split=t;
function bare(e)
local t,e=t(e);
if t and e then
return t.."@"..e;
end
return e;
end
local function i(e)
local e,t,a=t(e);
if t then
t=h(t);
if not t then return;end
if e then
e=s(e);
if not e then return;end
end
if a then
a=r(a);
if not a then return;end
end
return e,t,a;
end
end
prepped_split=i;
function prep(e)
local t,e,a=i(e);
if e then
if t then
e=t.."@"..e;
end
if a then
e=e.."/"..a;
end
end
return e;
end
function join(t,e,a)
if t and e and a then
return t.."@"..e.."/"..a;
elseif t and e then
return t.."@"..e;
elseif e and a then
return e.."/"..a;
elseif e then
return e;
end
return nil;
end
function compare(a,e)
local o,i,n=t(a);
local e,t,a=t(e);
if((e~=nil and e==o)or e==nil)and
((t~=nil and t==i)or t==nil)and
((a~=nil and a==n)or a==nil)then
return true
end
return false
end
function escape(e)return e and(e:gsub(".",o));end
function unescape(e)return e and(e:gsub("\\%x%x",n));end
return _M;
end)
package.preload['util.events']=(function(...)
local i=pairs;
local n=table.insert;
local d=table.sort;
local r=setmetatable;
local h=next;
module"events"
function new()
local t={};
local e={};
local function s(o,a)
local e=e[a];
if not e or h(e)==nil then return;end
local t={};
for e in i(e)do
n(t,e);
end
d(t,function(a,t)return e[a]>e[t];end);
o[a]=t;
return t;
end;
r(t,{__index=s});
local function s(o,n,i)
local a=e[o];
if a then
a[n]=i or 0;
else
a={[n]=i or 0};
e[o]=a;
end
t[o]=nil;
end;
local function n(a,i)
local o=e[a];
if o then
o[i]=nil;
t[a]=nil;
if h(o)==nil then
e[a]=nil;
end
end
end;
local function a(e)
for e,t in i(e)do
s(e,t);
end
end;
local function h(e)
for t,e in i(e)do
n(t,e);
end
end;
local function o(e,...)
local e=t[e];
if e then
for t=1,#e do
local e=e[t](...);
if e~=nil then return e;end
end
end
end;
return{
add_handler=s;
remove_handler=n;
add_handlers=a;
remove_handlers=h;
fire_event=o;
_handlers=t;
_event_map=e;
};
end
return _M;
end)
package.preload['util.dataforms']=(function(...)
local t=setmetatable;
local e,i=pairs,ipairs;
local h,n=tostring,type;
local r=table.concat;
local e=require"util.stanza";
module"dataforms"
local a='jabber:x:data';
local s={};
local o={__index=s};
function new(e)
return t(e,o);
end
function s.form(t,s,o)
local e=e.stanza("x",{xmlns=a,type=o or"form"});
if t.title then
e:tag("title"):text(t.title):up();
end
if t.instructions then
e:tag("instructions"):text(t.instructions):up();
end
for t,o in i(t)do
local a=o.type or"text-single";
e:tag("field",{type=a,var=o.name,label=o.label});
local t=(s and s[o.name])or o.value;
if t then
if a=="hidden"then
if n(t)=="table"then
e:tag("value")
:add_child(t)
:up();
else
e:tag("value"):text(h(t)):up();
end
elseif a=="boolean"then
e:tag("value"):text((t and"1")or"0"):up();
elseif a=="fixed"then
elseif a=="jid-multi"then
for a,t in i(t)do
e:tag("value"):text(t):up();
end
elseif a=="jid-single"then
e:tag("value"):text(t):up();
elseif a=="text-single"or a=="text-private"then
e:tag("value"):text(t):up();
elseif a=="text-multi"then
for t in t:gmatch("([^\r\n]+)\r?\n*")do
e:tag("value"):text(t):up();
end
elseif a=="list-single"then
local a=false;
if n(t)=="string"then
e:tag("value"):text(t):up();
else
for o,t in i(t)do
if n(t)=="table"then
e:tag("option",{label=t.label}):tag("value"):text(t.value):up():up();
if t.default and(not a)then
e:tag("value"):text(t.value):up();
a=true;
end
else
e:tag("option",{label=t}):tag("value"):text(h(t)):up():up();
end
end
end
elseif a=="list-multi"then
for a,t in i(t)do
if n(t)=="table"then
e:tag("option",{label=t.label}):tag("value"):text(t.value):up():up();
if t.default then
e:tag("value"):text(t.value):up();
end
else
e:tag("option",{label=t}):tag("value"):text(h(t)):up():up();
end
end
end
end
if o.required then
e:tag("required"):up();
end
e:up();
end
return e;
end
local e={};
function s.data(n,t)
local o={};
for t in t:childtags()do
local a;
for o,e in i(n)do
if e.name==t.attr.var then
a=e.type;
break;
end
end
local e=e[a];
if e then
o[t.attr.var]=e(t);
end
end
return o;
end
e["text-single"]=
function(t)
local t=t:child_with_name("value");
if t then
return t[1];
end
end
e["text-private"]=
e["text-single"];
e["jid-single"]=
e["text-single"];
e["jid-multi"]=
function(a)
local t={};
for e in a:childtags()do
if e.name=="value"then
t[#t+1]=e[1];
end
end
return t;
end
e["text-multi"]=
function(a)
local t={};
for e in a:childtags()do
if e.name=="value"then
t[#t+1]=e[1];
end
end
return r(t,"\n");
end
e["list-single"]=
e["text-single"];
e["list-multi"]=
function(a)
local t={};
for e in a:childtags()do
if e.name=="value"then
t[#t+1]=e[1];
end
end
return t;
end
e["boolean"]=
function(t)
local t=t:child_with_name("value");
if t then
if t[1]=="1"or t[1]=="true"then
return true;
else
return false;
end
end
end
e["hidden"]=
function(e)
local e=e:child_with_name("value");
if e then
return e[1];
end
end
return _M;
end)
package.preload['util.caps']=(function(...)
local d=require"util.encodings".base64.encode;
local l=require"util.hashes".sha1;
local n,s,h=table.insert,table.sort,table.concat;
local r=ipairs;
module"caps"
function calculate_hash(e)
local i,o,a={},{},{};
for t,e in r(e)do
if e.name=="identity"then
n(i,(e.attr.category or"").."\0"..(e.attr.type or"").."\0"..(e.attr["xml:lang"]or"").."\0"..(e.attr.name or""));
elseif e.name=="feature"then
n(o,e.attr.var or"");
elseif e.name=="x"and e.attr.xmlns=="jabber:x:data"then
local t={};
local o;
for a,e in r(e.tags)do
if e.name=="field"and e.attr.var then
local a={};
for t,e in r(e.tags)do
e=#e.tags==0 and e:get_text();
if e then n(a,e);end
end
s(a);
if e.attr.var=="FORM_TYPE"then
o=a[1];
elseif#a>0 then
n(t,e.attr.var.."\0"..h(a,"<"));
else
n(t,e.attr.var);
end
end
end
s(t);
t=h(t,"<");
if o then t=o.."\0"..t;end
n(a,t);
end
end
s(i);
s(o);
s(a);
if#i>0 then i=h(i,"<"):gsub("%z","/").."<";else i="";end
if#o>0 then o=h(o,"<").."<";else o="";end
if#a>0 then a=h(a,"<"):gsub("%z","<").."<";else a="";end
local e=i..o..a;
local t=d(l(e));
return t,e;
end
return _M;
end)
package.preload['util.vcard']=(function(...)
local n=require"util.stanza";
local a,r=table.insert,table.concat;
local h=type;
local e,s,m=next,pairs,ipairs;
local c,u,d,l;
local f="\n";
local i;
local function e()
error"Not implemented"
end
local function e()
error"Not implemented"
end
local function p(e)
return e:gsub("[,:;\\]","\\%1"):gsub("\n","\\n");
end
local function y(e)
return e:gsub("\\?[\\nt:;,]",{
["\\\\"]="\\",
["\\n"]="\n",
["\\r"]="\r",
["\\t"]="\t",
["\\:"]=":",
["\\;"]=";",
["\\,"]=",",
[":"]="\29",
[";"]="\30",
[","]="\31",
});
end
local function w(e)
local a=n.stanza(e.name,{xmlns="vcard-temp"});
local t=i[e.name];
if t=="text"then
a:text(e[1]);
elseif h(t)=="table"then
if t.types and e.TYPE then
if h(e.TYPE)=="table"then
for o,t in s(t.types)do
for o,e in s(e.TYPE)do
if e:upper()==t then
a:tag(t):up();
break;
end
end
end
else
a:tag(e.TYPE:upper()):up();
end
end
if t.props then
for o,t in s(t.props)do
if e[t]then
a:tag(t):up();
end
end
end
if t.value then
a:tag(t.value):text(e[1]):up();
elseif t.values then
local o=t.values;
local i=o.behaviour=="repeat-last"and o[#o];
for o=1,#e do
a:tag(t.values[o]or i):text(e[o]):up();
end
end
end
return a;
end
local function t(e)
local t=n.stanza("vCard",{xmlns="vcard-temp"});
for a=1,#e do
t:add_child(w(e[a]));
end
return t;
end
function l(e)
if not e[1]or e[1].name then
return t(e)
else
local a=n.stanza("xCard",{xmlns="vcard-temp"});
for o=1,#e do
a:add_child(t(e[o]));
end
return a;
end
end
function c(t)
t=t
:gsub("\r\n","\n")
:gsub("\n ","")
:gsub("\n\n+","\n");
local h={};
local e;
for t in t:gmatch("[^\n]+")do
local t=y(t);
local s,t,n=t:match("^([-%a]+)(\30?[^\29]*)\29(.*)$");
n=n:gsub("\29",":");
if#t>0 then
local o={};
for a,i,n in t:gmatch("\30([^=]+)(=?)([^\30]*)")do
a=a:upper();
local e={};
for t in n:gmatch("[^\31]+")do
e[#e+1]=t
e[t]=true;
end
if i=="="then
o[a]=e;
else
o[a]=true;
end
end
t=o;
end
if s=="BEGIN"and n=="VCARD"then
e={};
h[#h+1]=e;
elseif s=="END"and n=="VCARD"then
e=nil;
elseif i[s]then
local o=i[s];
local i={name=s};
e[#e+1]=i;
local s=e;
e=i;
if o.types then
for o,a in m(o.types)do
local a=a:lower();
if(t.TYPE and t.TYPE[a]==true)
or t[a]==true then
e.TYPE=a;
end
end
end
if o.props then
for o,a in m(o.props)do
if t[a]then
if t[a]==true then
e[a]=true;
else
for o,t in m(t[a])do
e[a]=t;
end
end
end
end
end
if o=="text"or o.value then
a(e,n);
elseif o.values then
local t="\30"..n;
for t in t:gmatch("\30([^\30]*)")do
a(e,t);
end
end
e=s;
end
end
return h;
end
local function n(e)
local t={};
for a=1,#e do
t[a]=p(e[a]);
end
t=r(t,";");
local a="";
for e,t in s(e)do
if h(e)=="string"and e~="name"then
a=a..(";%s=%s"):format(e,h(t)=="table"and r(t,",")or t);
end
end
return("%s%s:%s"):format(e.name,a,t)
end
local function o(t)
local e={};
a(e,"BEGIN:VCARD")
for o=1,#t do
a(e,n(t[o]));
end
a(e,"END:VCARD")
return r(e,f);
end
function u(e)
if e[1]and e[1].name then
return o(e)
else
local a={};
for t=1,#e do
a[t]=o(e[t]);
end
return r(a,f);
end
end
local function n(o)
local e=o.name;
local t=i[e];
local e={name=e};
if t=="text"then
e[1]=o:get_text();
elseif h(t)=="table"then
if t.value then
e[1]=o:get_child_text(t.value)or"";
elseif t.values then
local t=t.values;
if t.behaviour=="repeat-last"then
for t=1,#o.tags do
a(e,o.tags[t]:get_text()or"");
end
else
for i=1,#t do
a(e,o:get_child_text(t[i])or"");
end
end
elseif t.names then
local t=t.names;
for a=1,#t do
if o:get_child(t[a])then
e[1]=t[a];
break;
end
end
end
if t.props_verbatim then
for t,a in s(t.props_verbatim)do
e[t]=a;
end
end
if t.types then
local t=t.types;
e.TYPE={};
for i=1,#t do
if o:get_child(t[i])then
a(e.TYPE,t[i]:lower());
end
end
if#e.TYPE==0 then
e.TYPE=nil;
end
end
if t.props then
local t=t.props;
for i=1,#t do
local t=t[i]
local o=o:get_child_text(t);
if o then
e[t]=e[t]or{};
a(e[t],o);
end
end
end
else
return nil
end
return e;
end
local function o(e)
local e=e.tags;
local t={};
for o=1,#e do
a(t,n(e[o]));
end
return t
end
function d(e)
if e.attr.xmlns~="vcard-temp"then
return nil,"wrong-xmlns";
end
if e.name=="xCard"then
local a={};
local e=e.tags;
for t=1,#e do
a[t]=o(e[t]);
end
return a
elseif e.name=="vCard"then
return o(e)
end
end
i={
VERSION="text",
FN="text",
N={
values={
"FAMILY",
"GIVEN",
"MIDDLE",
"PREFIX",
"SUFFIX",
},
},
NICKNAME="text",
PHOTO={
props_verbatim={ENCODING={"b"}},
props={"TYPE"},
value="BINVAL",
},
BDAY="text",
ADR={
types={
"HOME",
"WORK",
"POSTAL",
"PARCEL",
"DOM",
"INTL",
"PREF",
},
values={
"POBOX",
"EXTADD",
"STREET",
"LOCALITY",
"REGION",
"PCODE",
"CTRY",
}
},
LABEL={
types={
"HOME",
"WORK",
"POSTAL",
"PARCEL",
"DOM",
"INTL",
"PREF",
},
value="LINE",
},
TEL={
types={
"HOME",
"WORK",
"VOICE",
"FAX",
"PAGER",
"MSG",
"CELL",
"VIDEO",
"BBS",
"MODEM",
"ISDN",
"PCS",
"PREF",
},
value="NUMBER",
},
EMAIL={
types={
"HOME",
"WORK",
"INTERNET",
"PREF",
"X400",
},
value="USERID",
},
JABBERID="text",
MAILER="text",
TZ="text",
GEO={
values={
"LAT",
"LON",
},
},
TITLE="text",
ROLE="text",
LOGO="copy of PHOTO",
AGENT="text",
ORG={
values={
behaviour="repeat-last",
"ORGNAME",
"ORGUNIT",
}
},
CATEGORIES={
values="KEYWORD",
},
NOTE="text",
PRODID="text",
REV="text",
SORTSTRING="text",
SOUND="copy of PHOTO",
UID="text",
URL="text",
CLASS={
names={
"PUBLIC",
"PRIVATE",
"CONFIDENTIAL",
},
},
KEY={
props={"TYPE"},
value="CRED",
},
DESC="text",
};
i.LOGO=i.PHOTO;
i.SOUND=i.PHOTO;
return{
from_text=c;
to_text=u;
from_xep54=d;
to_xep54=l;
lua_to_text=u;
lua_to_xep54=l;
text_to_lua=c;
text_to_xep54=function(...)return l(c(...));end;
xep54_to_lua=d;
xep54_to_text=function(...)return u(d(...))end;
};
end)
package.preload['util.logger']=(function(...)
local e=pcall;
local e=string.find;
local e,i,e=ipairs,pairs,setmetatable;
module"logger"
local t,e={},{};
local a={};
local o;
function init(e)
local a=o(e,"debug");
local i=o(e,"info");
local n=o(e,"warn");
local o=o(e,"error");
local e=#e;
return function(e,t,...)
if e=="debug"then
return a(t,...);
elseif e=="info"then
return i(t,...);
elseif e=="warn"then
return n(t,...);
elseif e=="error"then
return o(t,...);
end
end
end
function o(i,o)
local a=e[o];
if not a then
a={};
e[o]=a;
end
local e=t[i];
local e=function(t,...)
if e then
for a=1,#e do
if e[a](i,o,t,...)==false then
return;
end
end
end
for e=1,#a do
a[e](i,o,t,...);
end
end
return e;
end
function reset()
for e in i(t)do t[e]=nil;end
for t,e in i(e)do
for t=1,#e do
e[t]=nil;
end
end
for e in i(a)do a[e]=nil;end
end
function add_level_sink(t,a)
if not e[t]then
e[t]={a};
else
e[t][#e[t]+1]=a;
end
end
function add_name_sink(e,a,o)
if not t[e]then
t[e]={a};
else
t[e][#t[e]+1]=a;
end
end
function add_name_pattern_sink(e,t,o)
if not a[e]then
a[e]={t};
else
a[e][#a[e]+1]=t;
end
end
_M.new=o;
return _M;
end)
package.preload['util.datetime']=(function(...)
local e=os.date;
local i=os.time;
local u=os.difftime;
local t=error;
local d=tonumber;
module"datetime"
function date(t)
return e("!%Y-%m-%d",t);
end
function datetime(t)
return e("!%Y-%m-%dT%H:%M:%SZ",t);
end
function time(t)
return e("!%H:%M:%S",t);
end
function legacy(t)
return e("!%Y%m%dT%H:%M:%S",t);
end
function parse(o)
if o then
local n,l,r,h,s,t,a;
n,l,r,h,s,t,a=o:match("^(%d%d%d%d)-?(%d%d)-?(%d%d)T(%d%d):(%d%d):(%d%d)%.?%d*([Z+%-].*)$");
if n then
local u=u(i(e("*t")),i(e("!*t")));
local o=0;
if a~=""and a~="Z"then
local a,t,e=a:match("([+%-])(%d%d):?(%d*)");
if not a then return;end
if#e~=2 then e="0";end
t,e=d(t),d(e);
o=t*60*60+e*60;
if a=="-"then o=-o;end
end
t=(t+u)-o;
return i({year=n,month=l,day=r,hour=h,min=s,sec=t,isdst=false});
end
end
end
return _M;
end)
package.preload['verse.plugins.tls']=(function(...)
local a=require"verse";
local t="urn:ietf:params:xml:ns:xmpp-tls";
function a.plugins.tls(e)
local function o(o)
if e.authenticated then return;end
if o:get_child("starttls",t)and e.conn.starttls then
e:debug("Negotiating TLS...");
e:send(a.stanza("starttls",{xmlns=t}));
return true;
elseif not e.conn.starttls and not e.secure then
e:warn("SSL libary (LuaSec) not loaded, so TLS not available");
elseif not e.secure then
e:debug("Server doesn't offer TLS :(");
end
end
local function i(t)
if t.name=="proceed"then
e:debug("Server says proceed, handshake starting...");
e.conn:starttls({mode="client",protocol="sslv23",options="no_sslv2"},true);
end
end
local function a(t)
if t=="ssl-handshake-complete"then
e.secure=true;
e:debug("Re-opening stream...");
e:reopen();
end
end
e:hook("stream-features",o,400);
e:hook("stream/"..t,i);
e:hook("status",a,400);
return true;
end
end)
package.preload['verse.plugins.sasl']=(function(...)
local i=require"mime".b64;
local o="urn:ietf:params:xml:ns:xmpp-sasl";
function verse.plugins.sasl(e)
local function n(t)
if e.authenticated then return;end
e:debug("Authenticating with SASL...");
local t,a
if e.username then
t="PLAIN"
a=i("\0"..e.username.."\0"..e.password);
else
t="ANONYMOUS"
end
e:debug("Selecting %s mechanism...",t);
local t=verse.stanza("auth",{xmlns=o,mechanism=t});
if a then
t:text(a);
end
e:send(t);
return true;
end
local function a(t)
if t.name=="success"then
e.authenticated=true;
e:event("authentication-success");
elseif t.name=="failure"then
local a=t.tags[1];
local t=t:get_child_text("text");
e:event("authentication-failure",{condition=a.name,text=t});
end
e:reopen();
return true;
end
e:hook("stream-features",n,300);
e:hook("stream/"..o,a);
return true;
end
end)
package.preload['verse.plugins.bind']=(function(...)
local t=require"verse";
local o=require"util.jid";
local a="urn:ietf:params:xml:ns:xmpp-bind";
function t.plugins.bind(e)
local function i(i)
if e.bound then return;end
e:debug("Binding resource...");
e:send_iq(t.iq({type="set"}):tag("bind",{xmlns=a}):tag("resource"):text(e.resource),
function(t)
if t.attr.type=="result"then
local t=t
:get_child("bind",a)
:get_child_text("jid");
e.username,e.host,e.resource=o.split(t);
e.jid,e.bound=t,true;
e:event("bind-success",{jid=t});
elseif t.attr.type=="error"then
local a=t:child_with_name("error");
local a,t,o=t:get_error();
e:event("bind-failure",{error=t,text=o,type=a});
end
end);
end
e:hook("stream-features",i,200);
return true;
end
end)
package.preload['verse.plugins.session']=(function(...)
local o=require"verse";
local a="urn:ietf:params:xml:ns:xmpp-session";
function o.plugins.session(e)
local function i(t)
local t=t:get_child("session",a);
if t and not t:get_child("optional")then
local function i(t)
e:debug("Establishing Session...");
e:send_iq(o.iq({type="set"}):tag("session",{xmlns=a}),
function(t)
if t.attr.type=="result"then
e:event("session-success");
elseif t.attr.type=="error"then
local a=t:child_with_name("error");
local o,t,a=t:get_error();
e:event("session-failure",{error=t,text=a,type=o});
end
end);
return true;
end
e:hook("bind-success",i);
end
end
e:hook("stream-features",i);
return true;
end
end)
package.preload['verse.plugins.legacy']=(function(...)
local a=require"verse";
local n=require"util.uuid".generate;
local o="jabber:iq:auth";
function a.plugins.legacy(e)
function handle_auth_form(t)
local i=t:get_child("query",o);
if t.attr.type~="result"or not i then
local o,t,a=t:get_error();
e:debug("warn","%s %s: %s",o,t,a);
end
local t={
username=e.username;
password=e.password;
resource=e.resource or n();
digest=false,sequence=false,token=false;
};
local o=a.iq({to=e.host,type="set"})
:tag("query",{xmlns=o});
if#i>0 then
for a in i:childtags()do
local a=a.name;
local i=t[a];
if i then
o:tag(a):text(t[a]):up();
elseif i==nil then
local t="feature-not-implemented";
e:event("authentication-failure",{condition=t});
return false;
end
end
else
for t,e in pairs(t)do
if e then
o:tag(t):text(e):up();
end
end
end
e:send_iq(o,function(a)
if a.attr.type=="result"then
e.resource=t.resource;
e.jid=t.username.."@"..e.host.."/"..t.resource;
e:event("authentication-success");
e:event("bind-success",e.jid);
else
local a,t,a=a:get_error();
e:event("authentication-failure",{condition=t});
end
end);
end
function handle_opened(t)
if not t.version then
e:send_iq(a.iq({type="get"})
:tag("query",{xmlns="jabber:iq:auth"})
:tag("username"):text(e.username),
handle_auth_form);
end
end
e:hook("opened",handle_opened);
end
end)
package.preload['verse.plugins.compression']=(function(...)
local a=require"verse";
local i=require"zlib";
local e="http://jabber.org/features/compress"
local t="http://jabber.org/protocol/compress"
local e="http://etherx.jabber.org/streams";
local e=9;
local function n(o)
local i,e=pcall(i.deflate,e);
if i==false then
local t=a.stanza("failure",{xmlns=t}):tag("setup-failed");
o:send(t);
o:error("Failed to create zlib.deflate filter: %s",tostring(e));
return
end
return e
end
local function r(e)
local i,o=pcall(i.inflate);
if i==false then
local t=a.stanza("failure",{xmlns=t}):tag("setup-failed");
e:send(t);
e:error("Failed to create zlib.inflate filter: %s",tostring(o));
return
end
return o
end
local function h(e,o)
function e:send(i)
local i,o,n=pcall(o,tostring(i),'sync');
if i==false then
e:close({
condition="undefined-condition";
text=o;
extra=a.stanza("failure",{xmlns=t}):tag("processing-failed");
});
e:warn("Compressed send failed: %s",tostring(o));
return;
end
e.conn:write(o);
end;
end
local function d(e,s)
local n=e.data
e.data=function(i,o)
e:debug("Decompressing data...");
local s,o,h=pcall(s,o);
if s==false then
e:close({
condition="undefined-condition";
text=o;
extra=a.stanza("failure",{xmlns=t}):tag("processing-failed");
});
stream:warn("%s",tostring(o));
return;
end
return n(i,o);
end;
end
function a.plugins.compression(e)
local function i(o)
if not e.compressed then
local o=o:child_with_name("compression");
if o then
for o in o:children()do
local o=o[1]
if o=="zlib"then
e:send(a.stanza("compress",{xmlns=t}):tag("method"):text("zlib"))
e:debug("Enabled compression using zlib.")
return true;
end
end
session:debug("Remote server supports no compression algorithm we support.")
end
end
end
local function o(t)
if t.name=="compressed"then
e:debug("Activating compression...")
local t=n(e);
if not t then return end
local a=r(e);
if not a then return end
h(e,t);
d(e,a);
e.compressed=true;
e:reopen();
elseif t.name=="failure"then
e:warn("Failed to establish compression");
end
end
e:hook("stream-features",i,250);
e:hook("stream/"..t,o);
end
end)
package.preload['verse.plugins.smacks']=(function(...)
local i=require"verse";
local o="urn:xmpp:sm:2";
function i.plugins.smacks(e)
local s={};
local n=0;
local a=0;
local function d(t)
if t.attr.xmlns=="jabber:client"or not t.attr.xmlns then
a=a+1;
e:debug("Increasing handled stanzas to %d for %s",a,t:top_tag());
end
end
local function r()
e:debug("smacks: connection lost");
e.stream_management_supported=nil;
if e.resumption_token then
e:debug("smacks: have resumption token, reconnecting in 1s...");
e.authenticated=nil;
i.add_task(1,function()
e:connect(e.connect_host or e.host,e.connect_port or 5222);
end);
return true;
end
end
local function h(t)
if t.name=="r"then
e:debug("Ack requested... acking %d handled stanzas",a);
e:send(i.stanza("a",{xmlns=o,h=tostring(a)}));
elseif t.name=="a"then
local t=tonumber(t.attr.h);
if t>n then
local a=#s;
for t=n+1,t do
table.remove(s,1);
end
e:debug("Received ack: New ack: "..t.." Last ack: "..n.." Unacked stanzas now: "..#s.." (was "..a..")");
n=t;
else
e:warn("Received bad ack for "..t.." when last ack was "..n);
end
elseif t.name=="enabled"then
e.smacks=true;
local n=e.send;
function e.send(a,t)
a:warn("SENDING");
if not t.attr.xmlns then
s[#s+1]=t;
local e=n(a,t);
n(a,i.stanza("r",{xmlns=o}));
return e;
end
return n(a,t);
end
e:hook("stanza",d);
if t.attr.id then
e.resumption_token=t.attr.id;
e:hook("disconnected",r,100);
end
elseif t.name=="resumed"then
e:debug("Resumed successfully");
e:event("resumed");
else
e:warn("Don't know how to handle "..o.."/"..t.name);
end
end
local function n()
if not e.smacks then
e:debug("smacks: sending enable");
e:send(i.stanza("enable",{xmlns=o,resume="true"}));
end
end
local function s(t)
if t:get_child("sm",o)then
e.stream_management_supported=true;
if e.smacks and e.bound then
e:debug("Resuming stream with %d handled stanzas",a);
e:send(i.stanza("resume",{xmlns=o,
h=a,previd=e.resumption_token}));
return true;
else
e:hook("bind-success",n,1);
end
end
end
e:hook("stream-features",s,250);
e:hook("stream/"..o,h);
end
end)
package.preload['verse.plugins.keepalive']=(function(...)
local t=require"verse";
function t.plugins.keepalive(e)
e.keepalive_timeout=e.keepalive_timeout or 300;
t.add_task(e.keepalive_timeout,function()
e.conn:write(" ");
return e.keepalive_timeout;
end);
end
end)
package.preload['verse.plugins.disco']=(function(...)
local a=require"verse";
local l=require("mime").b64;
local r=require("util.sha1").sha1;
local n="http://jabber.org/protocol/caps";
local e="http://jabber.org/protocol/disco";
local o=e.."#info";
local i=e.."#items";
function a.plugins.disco(e)
e:add_plugin("presence");
local t={
__index=function(a,e)
local t={identities={},features={}};
if e=="identities"or e=="features"then
return a[false][e]
end
a[e]=t;
return t;
end,
};
local s={
__index=function(a,t)
local e={};
a[t]=e;
return e;
end,
};
e.disco={
cache={},
info=setmetatable({
[false]={
identities={
{category='client',type='pc',name='Verse'},
},
features={
[n]=true,
[o]=true,
[i]=true,
},
},
},t);
items=setmetatable({[false]={}},s);
};
e.caps={}
e.caps.node='http://code.matthewwild.co.uk/verse/'
local function d(t,e)
if t.category<e.category then
return true;
elseif e.category<t.category then
return false;
end
if t.type<e.type then
return true;
elseif e.type<t.type then
return false;
end
if(not t['xml:lang']and e['xml:lang'])or
(e['xml:lang']and t['xml:lang']<e['xml:lang'])then
return true
end
return false
end
local function h(t,e)
return t.var<e.var
end
local function s(t)
local o=e.disco.info[t or false].identities;
table.sort(o,d)
local a={};
for e in pairs(e.disco.info[t or false].features)do
a[#a+1]={var=e};
end
table.sort(a,h)
local e={};
for a,t in pairs(o)do
e[#e+1]=table.concat({
t.category,t.type or'',
t['xml:lang']or'',t.name or''
},'/');
end
for a,t in pairs(a)do
e[#e+1]=t.var
end
e[#e+1]='';
e=table.concat(e,'<');
return(l(r(e)))
end
setmetatable(e.caps,{
__call=function(...)
local t=s()
e.caps.hash=t;
return a.stanza('c',{
xmlns=n,
hash='sha-1',
node=e.caps.node,
ver=t
})
end
})
function e:set_identity(t,a)
self.disco.info[a or false].identities={t};
e:resend_presence();
end
function e:add_identity(a,t)
local t=self.disco.info[t or false].identities;
t[#t+1]=a;
e:resend_presence();
end
function e:add_disco_feature(t,a)
local t=t.var or t;
self.disco.info[a or false].features[t]=true;
e:resend_presence();
end
function e:remove_disco_feature(t,a)
local t=t.var or t;
self.disco.info[a or false].features[t]=nil;
e:resend_presence();
end
function e:add_disco_item(t,e)
local e=self.disco.items[e or false];
e[#e+1]=t;
end
function e:remove_disco_item(a,e)
local e=self.disco.items[e or false];
for t=#e,1,-1 do
if e[t]==a then
table.remove(e,t);
end
end
end
function e:jid_has_identity(a,e,t)
local o=self.disco.cache[a];
if not o then
return nil,"no-cache";
end
local a=self.disco.cache[a].identities;
if t then
return a[e.."/"..t]or false;
end
for t in pairs(a)do
if t:match("^(.*)/")==e then
return true;
end
end
end
function e:jid_supports(e,t)
local e=self.disco.cache[e];
if not e or not e.features then
return nil,"no-cache";
end
return e.features[t]or false;
end
function e:get_local_services(o,a)
local e=self.disco.cache[self.host];
if not(e)or not(e.items)then
return nil,"no-cache";
end
local t={};
for i,e in ipairs(e.items)do
if self:jid_has_identity(e.jid,o,a)then
table.insert(t,e.jid);
end
end
return t;
end
function e:disco_local_services(a)
self:disco_items(self.host,nil,function(t)
if not t then
return a({});
end
local e=0;
local function o()
e=e-1;
if e==0 then
return a(t);
end
end
for a,t in ipairs(t)do
if t.jid then
e=e+1;
self:disco_info(t.jid,nil,o);
end
end
if e==0 then
return a(t);
end
end);
end
function e:disco_info(e,t,s)
local a=a.iq({to=e,type="get"})
:tag("query",{xmlns=o,node=t});
self:send_iq(a,function(n)
if n.attr.type=="error"then
return s(nil,n:get_error());
end
local i,a={},{};
for e in n:get_child("query",o):childtags()do
if e.name=="identity"then
i[e.attr.category.."/"..e.attr.type]=e.attr.name or true;
elseif e.name=="feature"then
a[e.attr.var]=true;
end
end
if not self.disco.cache[e]then
self.disco.cache[e]={nodes={}};
end
if t then
if not self.disco.cache[e].nodes[t]then
self.disco.cache[e].nodes[t]={nodes={}};
end
self.disco.cache[e].nodes[t].identities=i;
self.disco.cache[e].nodes[t].features=a;
else
self.disco.cache[e].identities=i;
self.disco.cache[e].features=a;
end
return s(self.disco.cache[e]);
end);
end
function e:disco_items(t,o,n)
local a=a.iq({to=t,type="get"})
:tag("query",{xmlns=i,node=o});
self:send_iq(a,function(e)
if e.attr.type=="error"then
return n(nil,e:get_error());
end
local a={};
for e in e:get_child("query",i):childtags()do
if e.name=="item"then
table.insert(a,{
name=e.attr.name;
jid=e.attr.jid;
node=e.attr.node;
});
end
end
if not self.disco.cache[t]then
self.disco.cache[t]={nodes={}};
end
if o then
if not self.disco.cache[t].nodes[o]then
self.disco.cache[t].nodes[o]={nodes={}};
end
self.disco.cache[t].nodes[o].items=a;
else
self.disco.cache[t].items=a;
end
return n(a);
end);
end
e:hook("iq/"..o,function(i)
local t=i.tags[1];
if i.attr.type=='get'and t.name=="query"then
local t=t.attr.node;
local n=e.disco.info[t or false];
if t and t==e.caps.node.."#"..e.caps.hash then
n=e.disco.info[false];
end
local s,n=n.identities,n.features
local t=a.reply(i):tag("query",{
xmlns=o,
node=t,
});
for a,e in pairs(s)do
t:tag('identity',e):up()
end
for a in pairs(n)do
t:tag('feature',{var=a}):up()
end
e:send(t);
return true
end
end);
e:hook("iq/"..i,function(o)
local t=o.tags[1];
if o.attr.type=='get'and t.name=="query"then
local n=e.disco.items[t.attr.node or false];
local t=a.reply(o):tag('query',{
xmlns=i,
node=t.attr.node
})
for a=1,#n do
t:tag('item',n[a]):up()
end
e:send(t);
return true
end
end);
local t;
e:hook("ready",function()
if t then return;end
t=true;
e:disco_local_services(function(t)
for a,t in ipairs(t)do
local a=e.disco.cache[t.jid];
if a then
for a in pairs(a.identities)do
local a,o=a:match("^(.*)/(.*)$");
e:event("disco/service-discovered/"..a,{
type=o,jid=t.jid;
});
end
end
end
e:event("ready");
end);
return true;
end,50);
e:hook("presence-out",function(t)
if not t:get_child("c",n)then
t:reset():add_child(e:caps()):reset();
end
end,10);
end
end)
package.preload['verse.plugins.version']=(function(...)
local o=require"verse";
local a="jabber:iq:version";
local function i(e,t)
e.name=t.name;
e.version=t.version;
e.platform=t.platform;
end
function o.plugins.version(e)
e.version={set=i};
e:hook("iq/"..a,function(t)
if t.attr.type~="get"then return;end
local t=o.reply(t)
:tag("query",{xmlns=a});
if e.version.name then
t:tag("name"):text(tostring(e.version.name)):up();
end
if e.version.version then
t:tag("version"):text(tostring(e.version.version)):up()
end
if e.version.platform then
t:tag("os"):text(e.version.platform);
end
e:send(t);
return true;
end);
function e:query_version(i,t)
t=t or function(t)return e:event("version/response",t);end
e:send_iq(o.iq({type="get",to=i})
:tag("query",{xmlns=a}),
function(o)
if o.attr.type=="result"then
local e=o:get_child("query",a);
local o=e and e:get_child_text("name");
local a=e and e:get_child_text("version");
local e=e and e:get_child_text("os");
t({
name=o;
version=a;
platform=e;
});
else
local e,a,o=o:get_error();
t({
error=true;
condition=a;
text=o;
type=e;
});
end
end);
end
return true;
end
end)
package.preload['verse.plugins.ping']=(function(...)
local o=require"verse";
local i="urn:xmpp:ping";
function o.plugins.ping(e)
function e:ping(t,a)
local n=socket.gettime();
e:send_iq(o.iq{to=t,type="get"}:tag("ping",{xmlns=i}),
function(e)
if e.attr.type=="error"then
local o,e,i=e:get_error();
if e~="service-unavailable"and e~="feature-not-implemented"then
a(nil,t,{type=o,condition=e,text=i});
return;
end
end
a(socket.gettime()-n,t);
end);
end
return true;
end
end)
package.preload['verse.plugins.uptime']=(function(...)
local o=require"verse";
local t="jabber:iq:last";
local function a(e,t)
e.starttime=t.starttime;
end
function o.plugins.uptime(e)
e.uptime={set=a};
e:hook("iq/"..t,function(a)
if a.attr.type~="get"then return;end
local t=o.reply(a)
:tag("query",{seconds=tostring(os.difftime(os.time(),e.uptime.starttime)),xmlns=t});
e:send(t);
return true;
end);
function e:query_uptime(i,a)
a=a or function(t)return e:event("uptime/response",t);end
e:send_iq(o.iq({type="get",to=i})
:tag("query",{xmlns=t}),
function(e)
local t=e:get_child("query",t);
if e.attr.type=="result"then
local e=t.attr.seconds;
a({
seconds=e or nil;
});
else
local t,o,e=e:get_error();
a({
error=true;
condition=o;
text=e;
type=t;
});
end
end);
end
return true;
end
end)
package.preload['verse.plugins.blocking']=(function(...)
local o=require"verse";
local a="urn:xmpp:blocking";
function o.plugins.blocking(e)
e.blocking={};
function e.blocking:block_jid(i,t)
e:send_iq(o.iq{type="set"}
:tag("block",{xmlns=a})
:tag("item",{jid=i})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:unblock_jid(i,t)
e:send_iq(o.iq{type="set"}
:tag("unblock",{xmlns=a})
:tag("item",{jid=i})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:unblock_all_jids(t)
e:send_iq(o.iq{type="set"}
:tag("unblock",{xmlns=a})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:get_blocked_jids(t)
e:send_iq(o.iq{type="get"}
:tag("blocklist",{xmlns=a})
,function(e)
local a=e:get_child("blocklist",a);
if not a then return t and t(false);end
local e={};
for t in a:childtags()do
e[#e+1]=t.attr.jid;
end
return t and t(e);
end
,function(e)return t and t(false);end
);
end
end
end)
package.preload['verse.plugins.jingle']=(function(...)
local a=require"verse";
local e=require"util.sha1".sha1;
local e=require"util.timer";
local o=require"util.uuid".generate;
local i="urn:xmpp:jingle:1";
local h="urn:xmpp:jingle:errors:1";
local t={};
t.__index=t;
local e={};
local e={};
function a.plugins.jingle(e)
e:hook("ready",function()
e:add_disco_feature(i);
end,10);
function e:jingle(i)
return a.eventable(setmetatable(base or{
role="initiator";
peer=i;
sid=o();
stream=e;
},t));
end
function e:register_jingle_transport(e)
end
function e:register_jingle_content_type(e)
end
local function u(n)
local s=n:get_child("jingle",i);
local o=s.attr.sid;
local r=s.attr.action;
local o=e:event("jingle/"..o,n);
if o==true then
e:send(a.reply(n));
return true;
end
if r~="session-initiate"then
local t=a.error_reply(n,"cancel","item-not-found")
:tag("unknown-session",{xmlns=h}):up();
e:send(t);
return;
end
local l=s.attr.sid;
local o=a.eventable{
role="receiver";
peer=n.attr.from;
sid=l;
stream=e;
};
setmetatable(o,t);
local d;
local r,h;
for t in s:childtags()do
if t.name=="content"and t.attr.xmlns==i then
local i=t:child_with_name("description");
local a=i.attr.xmlns;
if a then
local e=e:event("jingle/content/"..a,o,i);
if e then
r=e;
end
end
local a=t:child_with_name("transport");
local i=a.attr.xmlns;
h=e:event("jingle/transport/"..i,o,a);
if r and h then
d=t;
break;
end
end
end
if not r then
e:send(a.error_reply(n,"cancel","feature-not-implemented","The specified content is not supported"));
return true;
end
if not h then
e:send(a.error_reply(n,"cancel","feature-not-implemented","The specified transport is not supported"));
return true;
end
e:send(a.reply(n));
o.content_tag=d;
o.creator,o.name=d.attr.creator,d.attr.name;
o.content,o.transport=r,h;
function o:decline()
end
e:hook("jingle/"..l,function(e)
if e.attr.from~=o.peer then
return false;
end
local e=e:get_child("jingle",i);
return o:handle_command(e);
end);
e:event("jingle",o);
return true;
end
function t:handle_command(a)
local t=a.attr.action;
e:debug("Handling Jingle command: %s",t);
if t=="session-terminate"then
self:destroy();
elseif t=="session-accept"then
self:handle_accepted(a);
elseif t=="transport-info"then
e:debug("Handling transport-info");
self.transport:info_received(a);
elseif t=="transport-replace"then
e:error("Peer wanted to swap transport, not implemented");
else
e:warn("Unhandled Jingle command: %s",t);
return nil;
end
return true;
end
function t:send_command(t,o,e)
local t=a.iq({to=self.peer,type="set"})
:tag("jingle",{
xmlns=i,
sid=self.sid,
action=t,
initiator=self.role=="initiator"and self.stream.jid or nil,
responder=self.role=="responder"and self.jid or nil,
}):add_child(o);
if not e then
self.stream:send(t);
else
self.stream:send_iq(t,e);
end
end
function t:accept(o)
local t=a.iq({to=self.peer,type="set"})
:tag("jingle",{
xmlns=i,
sid=self.sid,
action="session-accept",
responder=e.jid,
})
:tag("content",{creator=self.creator,name=self.name});
local a=self.content:generate_accept(self.content_tag:child_with_name("description"),o);
t:add_child(a);
local a=self.transport:generate_accept(self.content_tag:child_with_name("transport"),o);
t:add_child(a);
local a=self;
e:send_iq(t,function(t)
if t.attr.type=="error"then
local a,t,a=t:get_error();
e:error("session-accept rejected: %s",t);
return false;
end
a.transport:connect(function(t)
e:warn("CONNECTED (receiver)!!!");
a.state="active";
a:event("connected",t);
end);
end);
end
e:hook("iq/"..i,u);
return true;
end
function t:offer(t,o)
local e=a.iq({to=self.peer,type="set"})
:tag("jingle",{xmlns=i,action="session-initiate",
initiator=self.stream.jid,sid=self.sid});
e:tag("content",{creator=self.role,name=t});
local t=self.stream:event("jingle/describe/"..t,o);
if not t then
return false,"Unknown content type";
end
e:add_child(t);
local t=self.stream:event("jingle/transport/".."urn:xmpp:jingle:transports:s5b:1",self);
self.transport=t;
e:add_child(t:generate_initiate());
self.stream:debug("Hooking %s","jingle/"..self.sid);
self.stream:hook("jingle/"..self.sid,function(e)
if e.attr.from~=self.peer then
return false;
end
local e=e:get_child("jingle",i);
return self:handle_command(e)
end);
self.stream:send_iq(e,function(e)
if e.type=="error"then
self.state="terminated";
local a,t,e=e:get_error();
return self:event("error",{type=a,condition=t,text=e});
end
end);
self.state="pending";
end
function t:terminate(e)
local e=a.stanza("reason"):tag(e or"success");
self:send_command("session-terminate",e,function(e)
self.state="terminated";
self.transport:disconnect();
self:destroy();
end);
end
function t:destroy()
self:event("terminated");
self.stream:unhook("jingle/"..self.sid,self.handle_command);
end
function t:handle_accepted(e)
local e=e:child_with_name("transport");
self.transport:handle_accepted(e);
self.transport:connect(function(e)
self.stream:debug("CONNECTED (initiator)!")
self.state="active";
self:event("connected",e);
end);
end
function t:set_source(a,o)
local function t()
local e,i=a();
if e and e~=""then
self.transport.conn:send(e);
elseif e==""then
return t();
elseif e==nil then
if o then
self:terminate();
end
self.transport.conn:unhook("drained",t);
a=nil;
end
end
self.transport.conn:hook("drained",t);
t();
end
function t:set_sink(t)
self.transport.conn:hook("incoming-raw",t);
self.transport.conn:hook("disconnected",function(e)
self.stream:debug("Closing sink...");
local e=e.reason;
if e=="closed"then e=nil;end
t(nil,e);
end);
end
end)
package.preload['verse.plugins.jingle_ft']=(function(...)
local n=require"verse";
local i=require"ltn12";
local h=package.config:sub(1,1);
local a="urn:xmpp:jingle:apps:file-transfer:1";
local o="http://jabber.org/protocol/si/profile/file-transfer";
function n.plugins.jingle_ft(t)
t:hook("ready",function()
t:add_disco_feature(a);
end,10);
local s={type="file"};
function s:generate_accept(t,e)
if e and e.save_file then
self.jingle:hook("connected",function()
local e=i.sink.file(io.open(e.save_file,"w+"));
self.jingle:set_sink(e);
end);
end
return t;
end
local s={__index=s};
t:hook("jingle/content/"..a,function(t,e)
local e=e:get_child("offer"):get_child("file",o);
local e={
name=e.attr.name;
size=tonumber(e.attr.size);
};
return setmetatable({jingle=t,file=e},s);
end);
t:hook("jingle/describe/file",function(e)
local t;
if e.timestamp then
t=os.date("!%Y-%m-%dT%H:%M:%SZ",e.timestamp);
end
return n.stanza("description",{xmlns=a})
:tag("offer")
:tag("file",{xmlns=o,
name=e.filename,
size=e.size,
date=t,
hash=e.hash,
})
:tag("desc"):text(e.description or"");
end);
function t:send_file(n,t)
local e,a=io.open(t);
if not e then return e,a;end
local o=e:seek("end",0);
e:seek("set",0);
local a=i.source.file(e);
local e=self:jingle(n);
e:offer("file",{
filename=t:match("[^"..h.."]+$");
size=o;
});
e:hook("connected",function()
e:set_source(a,true);
end);
return e;
end
end
end)
package.preload['verse.plugins.jingle_s5b']=(function(...)
local t=require"verse";
local o="urn:xmpp:jingle:transports:s5b:1";
local d="http://jabber.org/protocol/bytestreams";
local h=require"util.sha1".sha1;
local r=require"util.uuid".generate;
local function l(e,o)
local function n()
e:unhook("connected",n);
return true;
end
local function s(t)
e:unhook("incoming-raw",s);
if t:sub(1,2)~="\005\000"then
return e:event("error","connection-failure");
end
e:event("connected");
return true;
end
local function i(t)
e:unhook("incoming-raw",i);
if t~="\005\000"then
local a="version-mismatch";
if t:sub(1,1)=="\005"then
a="authentication-failure";
end
return e:event("error",a);
end
e:send(string.char(5,1,0,3,#o)..o.."\0\0");
e:hook("incoming-raw",s,100);
return true;
end
e:hook("connected",n,200);
e:hook("incoming-raw",i,100);
e:send("\005\001\000");
end
local function n(a,e,i)
local e=t.new(nil,{
streamhosts=e,
current_host=0;
});
local function t(o)
if o then
return a(nil,o.reason);
end
if e.current_host<#e.streamhosts then
e.current_host=e.current_host+1;
e:debug("Attempting to connect to "..e.streamhosts[e.current_host].host..":"..e.streamhosts[e.current_host].port.."...");
local t,a=e:connect(
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port
);
if not t then
e:debug("Error connecting to proxy (%s:%s): %s",
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port,
a
);
else
e:debug("Connecting...");
end
l(e,i);
return true;
end
e:unhook("disconnected",t);
return a(nil);
end
e:hook("disconnected",t,100);
e:hook("connected",function()
e:unhook("disconnected",t);
a(e.streamhosts[e.current_host],e);
end,100);
t();
return e;
end
function t.plugins.jingle_s5b(e)
e:hook("ready",function()
e:add_disco_feature(o);
end,10);
local a={};
function a:generate_initiate()
self.s5b_sid=r();
local o=t.stanza("transport",{xmlns=o,
mode="tcp",sid=self.s5b_sid});
local t=0;
for a,i in pairs(e.proxy65.available_streamhosts)do
t=t+1;
o:tag("candidate",{jid=a,host=i.host,
port=i.port,cid=a,priority=t,type="proxy"}):up();
end
e:debug("Have %d proxies",t)
return o;
end
function a:generate_accept(e)
local a={};
self.s5b_peer_candidates=a;
self.s5b_mode=e.attr.mode or"tcp";
self.s5b_sid=e.attr.sid or self.jingle.sid;
for e in e:childtags()do
a[e.attr.cid]={
type=e.attr.type;
jid=e.attr.jid;
host=e.attr.host;
port=tonumber(e.attr.port)or 0;
priority=tonumber(e.attr.priority)or 0;
cid=e.attr.cid;
};
end
local e=t.stanza("transport",{xmlns=o});
return e;
end
function a:connect(i)
e:warn("Connecting!");
local a={};
for t,e in pairs(self.s5b_peer_candidates or{})do
a[#a+1]=e;
end
if#a>0 then
self.connecting_peer_candidates=true;
local function s(a,e)
self.jingle:send_command("transport-info",t.stanza("content",{creator=self.creator,name=self.name})
:tag("transport",{xmlns=o,sid=self.s5b_sid})
:tag("candidate-used",{cid=a.cid}));
self.onconnect_callback=i;
self.conn=e;
end
local e=h(self.s5b_sid..self.peer..e.jid,true);
n(s,a,e);
else
e:warn("Actually, I'm going to wait for my peer to tell me its streamhost...");
self.onconnect_callback=i;
end
end
function a:info_received(a)
e:warn("Info received");
local s=a:child_with_name("content");
local i=s:child_with_name("transport");
if i:get_child("candidate-used")and not self.connecting_peer_candidates then
local a=i:child_with_name("candidate-used");
if a then
local function r(i,e)
if self.jingle.role=="initiator"then
self.jingle.stream:send_iq(t.iq({to=i.jid,type="set"})
:tag("query",{xmlns=d,sid=self.s5b_sid})
:tag("activate"):text(self.jingle.peer),function(i)
if i.attr.type=="result"then
self.jingle:send_command("transport-info",t.stanza("content",s.attr)
:tag("transport",{xmlns=o,sid=self.s5b_sid})
:tag("activated",{cid=a.attr.cid}));
self.conn=e;
self.onconnect_callback(e);
else
self.jingle.stream:error("Failed to activate bytestream");
end
end);
end
end
self.jingle.stream:debug("CID: %s",self.jingle.stream.proxy65.available_streamhosts[a.attr.cid]);
local t={
self.jingle.stream.proxy65.available_streamhosts[a.attr.cid];
};
local e=h(self.s5b_sid..e.jid..self.peer,true);
n(r,t,e);
end
elseif i:get_child("activated")then
self.onconnect_callback(self.conn);
end
end
function a:disconnect()
if self.conn then
self.conn:close();
end
end
function a:handle_accepted(e)
end
local t={__index=a};
e:hook("jingle/transport/"..o,function(e)
return setmetatable({
role=e.role,
peer=e.peer,
stream=e.stream,
jingle=e,
},t);
end);
end
end)
package.preload['verse.plugins.proxy65']=(function(...)
local e=require"util.events";
local r=require"util.uuid";
local h=require"util.sha1";
local i={};
i.__index=i;
local o="http://jabber.org/protocol/bytestreams";
local n;
function verse.plugins.proxy65(t)
t.proxy65=setmetatable({stream=t},i);
t.proxy65.available_streamhosts={};
local e=0;
t:hook("disco/service-discovered/proxy",function(a)
if a.type=="bytestreams"then
e=e+1;
t:send_iq(verse.iq({to=a.jid,type="get"})
:tag("query",{xmlns=o}),function(a)
e=e-1;
if a.attr.type=="result"then
local e=a:get_child("query",o)
:get_child("streamhost").attr;
t.proxy65.available_streamhosts[e.jid]={
jid=e.jid;
host=e.host;
port=tonumber(e.port);
};
end
if e==0 then
t:event("proxy65/discovered-proxies",t.proxy65.available_streamhosts);
end
end);
end
end);
t:hook("iq/"..o,function(a)
local e=verse.new(nil,{
initiator_jid=a.attr.from,
streamhosts={},
current_host=0;
});
for t in a.tags[1]:childtags()do
if t.name=="streamhost"then
table.insert(e.streamhosts,t.attr);
end
end
local function o()
if e.current_host<#e.streamhosts then
e.current_host=e.current_host+1;
e:connect(
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port
);
n(t,e,a.tags[1].attr.sid,a.attr.from,t.jid);
return true;
end
e:unhook("disconnected",o);
t:send(verse.error_reply(a,"cancel","item-not-found"));
end
function e:accept()
e:hook("disconnected",o,100);
e:hook("connected",function()
e:unhook("disconnected",o);
local e=verse.reply(a)
:tag("query",a.tags[1].attr)
:tag("streamhost-used",{jid=e.streamhosts[e.current_host].jid});
t:send(e);
end,100);
o();
end
function e:refuse()
end
t:event("proxy65/request",e);
end);
end
function i:new(t,s)
local e=verse.new(nil,{
target_jid=t;
bytestream_sid=r.generate();
});
local a=verse.iq{type="set",to=t}
:tag("query",{xmlns=o,mode="tcp",sid=e.bytestream_sid});
for t,e in ipairs(s or self.proxies)do
a:tag("streamhost",e):up();
end
self.stream:send_iq(a,function(a)
if a.attr.type=="error"then
local a,t,o=a:get_error();
e:event("connection-failed",{conn=e,type=a,condition=t,text=o});
else
local a=a.tags[1]:get_child("streamhost-used");
if not a then
end
e.streamhost_jid=a.attr.jid;
local a,i;
for o,t in ipairs(s or self.proxies)do
if t.jid==e.streamhost_jid then
a,i=t.host,t.port;
break;
end
end
if not(a and i)then
end
e:connect(a,i);
local function a()
e:unhook("connected",a);
local t=verse.iq{to=e.streamhost_jid,type="set"}
:tag("query",{xmlns=o,sid=e.bytestream_sid})
:tag("activate"):text(t);
self.stream:send_iq(t,function(t)
if t.attr.type=="result"then
e:event("connected",e);
else
end
end);
return true;
end
e:hook("connected",a,100);
n(self.stream,e,e.bytestream_sid,self.stream.jid,t);
end
end);
return e;
end
function n(i,e,a,t,o)
local t=h.sha1(a..t..o);
local function a()
e:unhook("connected",a);
return true;
end
local function o(t)
e:unhook("incoming-raw",o);
if t:sub(1,2)~="\005\000"then
return e:event("error","connection-failure");
end
e:event("connected");
return true;
end
local function i(a)
e:unhook("incoming-raw",i);
if a~="\005\000"then
local t="version-mismatch";
if a:sub(1,1)=="\005"then
t="authentication-failure";
end
return e:event("error",t);
end
e:send(string.char(5,1,0,3,#t)..t.."\0\0");
e:hook("incoming-raw",o,100);
return true;
end
e:hook("connected",a,200);
e:hook("incoming-raw",i,100);
e:send("\005\001\000");
end
end)
package.preload['verse.plugins.jingle_ibb']=(function(...)
local e=require"verse";
local i=require"util.encodings".base64;
local s=require"util.uuid".generate;
local n="urn:xmpp:jingle:transports:ibb:1";
local o="http://jabber.org/protocol/ibb";
assert(i.encode("This is a test.")=="VGhpcyBpcyBhIHRlc3Qu","Base64 encoding failed");
assert(i.decode("VGhpcyBpcyBhIHRlc3Qu")=="This is a test.","Base64 decoding failed");
local t=table.concat
local a={};
local t={__index=a};
local function h(a)
local t=setmetatable({stream=a},t)
t=e.eventable(t);
return t;
end
function a:initiate(e,t,a)
self.block=2048;
self.stanza=a or'iq';
self.peer=e;
self.sid=t or tostring(self):match("%x+$");
self.iseq=0;
self.oseq=0;
local e=function(e)
return self:feed(e)
end
self.feeder=e;
print("Hooking incomming IQs");
local t=self.stream;
t:hook("iq/"..o,e)
if a=="message"then
t:hook("message",e)
end
end
function a:open(t)
self.stream:send_iq(e.iq{to=self.peer,type="set"}
:tag("open",{
xmlns=o,
["block-size"]=self.block,
sid=self.sid,
stanza=self.stanza
})
,function(e)
if t then
if e.attr.type~="error"then
t(true)
else
t(false,e:get_error())
end
end
end);
end
function a:send(n)
local a=self.stanza;
local t;
if a=="iq"then
t=e.iq{type="set",to=self.peer}
elseif a=="message"then
t=e.message{to=self.peer}
end
local e=self.oseq;
self.oseq=e+1;
t:tag("data",{xmlns=o,sid=self.sid,seq=e})
:text(i.encode(n));
if a=="iq"then
self.stream:send_iq(t,function(e)
self:event(e.attr.type=="result"and"drained"or"error");
end)
else
stream:send(t)
self:event("drained");
end
end
function a:feed(t)
if t.attr.from~=self.peer then return end
local a=t[1];
if a.attr.sid~=self.sid then return end
local n;
if a.name=="open"then
self:event("connected");
self.stream:send(e.reply(t))
return true
elseif a.name=="data"then
local o=t:get_child_text("data",o);
local a=tonumber(a.attr.seq);
local n=self.iseq;
if o and a then
if a~=n then
self.stream:send(e.error_reply(t,"cancel","not-acceptable","Wrong sequence. Packet lost?"))
self:close();
self:event("error");
return true;
end
self.iseq=a+1;
local a=i.decode(o);
if self.stanza=="iq"then
self.stream:send(e.reply(t))
end
self:event("incoming-raw",a);
return true;
end
elseif a.name=="close"then
self.stream:send(e.reply(t))
self:close();
return true
end
end
function a:close()
self.stream:unhook("iq/"..o,self.feeder)
self:event("disconnected");
end
function e.plugins.jingle_ibb(a)
a:hook("ready",function()
a:add_disco_feature(n);
end,10);
local t={};
function t:_setup()
local e=h(self.stream);
e.sid=self.sid or e.sid;
e.stanza=self.stanza or e.stanza;
e.block=self.block or e.block;
e:initiate(self.peer,self.sid,self.stanza);
self.conn=e;
end
function t:generate_initiate()
print("ibb:generate_initiate() as "..self.role);
local t=s();
self.sid=t;
self.stanza='iq';
self.block=2048;
local e=e.stanza("transport",{xmlns=n,
sid=self.sid,stanza=self.stanza,["block-size"]=self.block});
return e;
end
function t:generate_accept(t)
print("ibb:generate_accept() as "..self.role);
local e=t.attr;
self.sid=e.sid or self.sid;
self.stanza=e.stanza or self.stanza;
self.block=e["block-size"]or self.block;
self:_setup();
return t;
end
function t:connect(t)
if not self.conn then
self:_setup();
end
local e=self.conn;
print("ibb:connect() as "..self.role);
if self.role=="initiator"then
e:open(function(a,...)
assert(a,table.concat({...},", "));
t(e);
end);
else
t(e);
end
end
function t:info_received(e)
print("ibb:info_received()");
end
function t:disconnect()
if self.conn then
self.conn:close()
end
end
function t:handle_accepted(e)end
local t={__index=t};
a:hook("jingle/transport/"..n,function(e)
return setmetatable({
role=e.role,
peer=e.peer,
stream=e.stream,
jingle=e,
},t);
end);
end
end)
package.preload['verse.plugins.pubsub']=(function(...)
local i=require"verse";
local e=require"util.jid".bare;
local n=table.insert;
local o="http://jabber.org/protocol/pubsub";
local e="http://jabber.org/protocol/pubsub#owner";
local a="http://jabber.org/protocol/pubsub#event";
local e="http://jabber.org/protocol/pubsub#errors";
local e={};
local s={__index=e};
function i.plugins.pubsub(e)
e.pubsub=setmetatable({stream=e},s);
e:hook("message",function(t)
local o=t.attr.from;
for t in t:childtags("event",a)do
local t=t:get_child("items");
if t then
local a=t.attr.node;
for t in t:childtags("item")do
e:event("pubsub/event",{
from=o;
node=a;
item=t;
});
end
end
end
end);
return true;
end
function e:create(e,t,a)
return self:service(e):node(t):create(nil,a);
end
function e:subscribe(e,o,t,a)
return self:service(e):node(o):subscribe(t,nil,a);
end
function e:publish(e,t,a,o,i)
return self:service(e):node(t):publish(a,nil,o,i);
end
local a={};
local t={__index=a};
function e:service(e)
return setmetatable({stream=self.stream,service=e},t)
end
local function t(e,n,s,a,r,h,t)
local e=i.iq{type=e or"get",to=n}
:tag("pubsub",{xmlns=s or o})
if a then e:tag(a,{node=r,jid=h});end
if t then e:tag("item",{id=t~=true and t or nil});end
return e;
end
function a:subscriptions(e)
self.stream:send_iq(t(nil,self.service,nil,"subscriptions")
,e and function(t)
if t.attr.type=="result"then
local t=t:get_child("pubsub",o);
local t=t and t:get_child("subscriptions");
local a={};
if t then
for t in t:childtags("subscription")do
local e=self:node(t.attr.node)
e.subscription=t;
n(a,e);
end
end
e(a);
else
e(false,t:get_error());
end
end or nil);
end
function a:affiliations(a)
self.stream:send_iq(t(nil,self.service,nil,"affiliations")
,a and function(e)
if e.attr.type=="result"then
local e=e:get_child("pubsub",o);
local e=e and e:get_child("affiliations")or{};
local t={};
if e then
for e in e:childtags("affiliation")do
local a=self:node(e.attr.node)
a.affiliation=e;
n(t,a);
end
end
a(t);
else
a(false,e:get_error());
end
end or nil);
end
local e={};
local o={__index=e};
function a:node(e)
return setmetatable({stream=self.stream,service=self.service,node=e},o)
end
function s:__call(e,t)
local e=self:service(e);
return t and e:node(t)or e;
end
function e:hook(a,o)
local function t(e)
if(not e.service or e.from==self.service)and e.node==self.node then
return a(e)
end
end
self.stream:hook("pubsub/event",t,o);
return t;
end
function e:unhook(e)
self.stream:unhook("pubsub/event",e);
end
function e:create(e,a)
if e~=nil then
error("Not implemented yet.");
else
self.stream:send_iq(t("set",self.service,nil,"create",self.node),a);
end
end
function e:configure(e,a)
if e~=nil then
error("Not implemented yet.");
end
self.stream:send_iq(t("set",self.service,nil,e==nil and"default"or"configure",self.node),a);
end
function e:publish(a,e,o,i)
if e~=nil then
error("Node configuration is not implemented yet.");
end
self.stream:send_iq(t("set",self.service,nil,"publish",self.node,nil,a or true)
:add_child(o)
,i);
end
function e:subscribe(o,a,e)
if a~=nil then
error("Subscription configuration is not implemented yet.");
end
self.stream:send_iq(t("set",self.service,nil,"subscribe",self.node,o,id)
,e);
end
function e:subscription(e)
error("Not implemented yet.");
end
function e:affiliation(e)
error("Not implemented yet.");
end
function e:unsubscribe(e,a)
self.stream:send_iq(t("set",self.service,nil,"unsubscribe",self.node,e)
,a);
end
function e:configure_subscription(e,e)
error("Not implemented yet.");
end
function e:items(e,e)
error("Not implemented yet.");
end
function e:item(e,e)
error("Not implemented yet.");
end
function e:retract(e,e)
error("Not implemented yet.");
end
function e:purge(e)
error("Not implemented yet.");
end
function e:delete(e)
error("Not implemented yet.");
end
end)
package.preload['verse.plugins.pep']=(function(...)
local e=require"verse";
local t="http://jabber.org/protocol/pubsub";
local t=t.."#event";
function e.plugins.pep(e)
e:add_plugin("disco");
e:add_plugin("pubsub");
e.pep={};
e:hook("pubsub/event",function(t)
return e:event("pep/"..t.node,{from=t.from,item=t.item.tags[1]});
end);
function e:hook_pep(t,o,i)
local a=e.events._handlers["pep/"..t];
if not(a)or#a==0 then
e:add_disco_feature(t.."+notify");
end
e:hook("pep/"..t,o,i);
end
function e:unhook_pep(t,a)
e:unhook("pep/"..t,a);
local a=e.events._handlers["pep/"..t];
if not(a)or#a==0 then
e:remove_disco_feature(t.."+notify");
end
end
function e:publish_pep(t,a)
return e.pubsub:service(nil):node(a or t.attr.xmlns):publish(nil,nil,t)
end
end
end)
package.preload['verse.plugins.adhoc']=(function(...)
local o=require"verse";
local n=require"lib.adhoc";
local t="http://jabber.org/protocol/commands";
local r="jabber:x:data";
local a={};
a.__index=a;
local i={};
function o.plugins.adhoc(e)
e:add_plugin("disco");
e:add_disco_feature(t);
function e:query_commands(a,o)
e:disco_items(a,t,function(a)
e:debug("adhoc list returned")
local t={};
for o,a in ipairs(a)do
t[a.node]=a.name;
end
e:debug("adhoc calling callback")
return o(t);
end);
end
function e:execute_command(i,o,t)
local e=setmetatable({
stream=e,jid=i,
command=o,callback=t
},a);
return e:execute();
end
local function r(t,e)
if not(e)or e=="user"then return true;end
if type(e)=="function"then
return e(t);
end
end
function e:add_adhoc_command(o,a,h,s)
i[a]=n.new(o,a,h,s);
e:add_disco_item({jid=e.jid,node=a,name=o},t);
return i[a];
end
local function s(a)
local t=a.tags[1];
local t=t.attr.node;
local t=i[t];
if not t then return;end
if not r(a.attr.from,t.permission)then
e:send(o.error_reply(a,"auth","forbidden","You don't have permission to execute this command"):up()
:add_child(t:cmdtag("canceled")
:tag("note",{type="error"}):text("You don't have permission to execute this command")));
return true
end
return n.handle_cmd(t,{send=function(t)return e:send(t)end},a);
end
e:hook("iq/"..t,function(e)
local t=e.attr.type;
local a=e.tags[1].name;
if t=="set"and a=="command"then
return s(e);
end
end);
end
function a:_process_response(e)
if e.type=="error"then
self.status="canceled";
self.callback(self,{});
end
local e=e:get_child("command",t);
self.status=e.attr.status;
self.sessionid=e.attr.sessionid;
self.form=e:get_child("x",r);
self.note=e:get_child("note");
self.callback(self);
end
function a:execute()
local e=o.iq({to=self.jid,type="set"})
:tag("command",{xmlns=t,node=self.command});
self.stream:send_iq(e,function(e)
self:_process_response(e);
end);
end
function a:next(a)
local e=o.iq({to=self.jid,type="set"})
:tag("command",{
xmlns=t,
node=self.command,
sessionid=self.sessionid
});
if a then e:add_child(a);end
self.stream:send_iq(e,function(e)
self:_process_response(e);
end);
end
end)
package.preload['verse.plugins.presence']=(function(...)
local a=require"verse";
function a.plugins.presence(e)
e.last_presence=nil;
e:hook("presence-out",function(t)
if not t.attr.to then
e.last_presence=t;
end
end,1);
function e:resend_presence()
if last_presence then
e:send(last_presence);
end
end
function e:set_status(t)
local a=a.presence();
if type(t)=="table"then
if t.show then
a:tag("show"):text(t.show):up();
end
if t.prio then
a:tag("priority"):text(tostring(t.prio)):up();
end
if t.msg then
a:tag("status"):text(t.msg):up();
end
end
e:send(a);
end
end
end)
package.preload['verse.plugins.private']=(function(...)
local a=require"verse";
local t="jabber:iq:private";
function a.plugins.private(i)
function i:private_set(o,i,e,n)
local t=a.iq({type="set"})
:tag("query",{xmlns=t});
if e then
if e.name==o and e.attr and e.attr.xmlns==i then
t:add_child(e);
else
t:tag(o,{xmlns=i})
:add_child(e);
end
end
self:send_iq(t,n);
end
function i:private_get(o,i,n)
self:send_iq(a.iq({type="get"})
:tag("query",{xmlns=t})
:tag(o,{xmlns=i}),
function(e)
if e.attr.type=="result"then
local e=e:get_child("query",t);
local e=e:get_child(o,i);
n(e);
end
end);
end
end
end)
package.preload['verse.plugins.roster']=(function(...)
local i=require"verse";
local d=require"util.jid".bare;
local a="jabber:iq:roster";
local o="urn:xmpp:features:rosterver";
local n=table.insert;
function i.plugins.roster(t)
local s=false;
local e={
items={};
ver="";
};
t.roster=e;
t:hook("stream-features",function(e)
if e:get_child("ver",o)then
s=true;
end
end);
local function h(t)
local e=i.stanza("item",{xmlns=a});
for a,t in pairs(t)do
if a~="groups"then
e.attr[a]=t;
else
for a=1,#t do
e:tag("group"):text(t[a]):up();
end
end
end
return e;
end
local function r(e)
local t={};
local a={};
t.groups=a;
local o=e.attr.jid;
for e,a in pairs(e.attr)do
if e~="xmlns"then
t[e]=a
end
end
for e in e:childtags("group")do
n(a,e:get_text())
end
return t;
end
function e:load(t)
e.ver,e.items=t.ver,t.items;
end
function e:dump()
return{
ver=e.ver,
items=e.items,
};
end
function e:add_contact(s,o,n,e)
local o={jid=s,name=o,groups=n};
local a=i.iq({type="set"})
:tag("query",{xmlns=a})
:add_child(h(o));
t:send_iq(a,function(t)
if not e then return end
if t.attr.type=="result"then
e(true);
else
local a,t,o=t:get_error();
e(nil,{a,t,o});
end
end);
end
function e:delete_contact(o,n)
o=(type(o)=="table"and o.jid)or o;
local s={jid=o,subscription="remove"}
if not e.items[o]then return false,"item-not-found";end
t:send_iq(i.iq({type="set"})
:tag("query",{xmlns=a})
:add_child(h(s)),
function(e)
if not n then return end
if e.attr.type=="result"then
n(true);
else
local a,e,t=e:get_error();
n(nil,{a,e,t});
end
end);
end
local function h(t)
local t=r(t);
e.items[t.jid]=t;
end
local function r(t)
local a=e.items[t];
e.items[t]=nil;
return a;
end
function e:fetch(o)
t:send_iq(i.iq({type="get"}):tag("query",{xmlns=a,ver=s and e.ver or nil}),
function(t)
if t.attr.type=="result"then
local t=t:get_child("query",a);
if t then
e.items={};
for t in t:childtags("item")do
h(t)
end
e.ver=t.attr.ver or"";
end
o(e);
else
local e,a,t=stanza:get_error();
o(nil,{e,a,t});
end
end);
end
t:hook("iq/"..a,function(o)
local s,n=o.attr.type,o.attr.from;
if s=="set"and(not n or n==d(t.jid))then
local s=o:get_child("query",a);
local n=s and s:get_child("item");
if n then
local o,a;
local i=n.attr.jid;
if n.attr.subscription=="remove"then
o="removed"
a=r(i);
else
o=e.items[i]and"changed"or"added";
h(n)
a=e.items[i];
end
e.ver=s.attr.ver;
if a then
t:event("roster/item-"..o,a);
end
end
t:send(i.reply(o))
return true;
end
end);
end
end)
package.preload['verse.plugins.register']=(function(...)
local t=require"verse";
local i="jabber:iq:register";
function t.plugins.register(e)
local function a(o)
if o:get_child("register","http://jabber.org/features/iq-register")then
e:send_iq(t.iq({to=e.host_,type="set"})
:tag("query",{xmlns=i})
:tag("username"):text(e.username):up()
:tag("password"):text(e.password):up()
,function(t)
if t.attr.type=="result"then
e:event("registration-success");
else
local o,t,a=t:get_error();
e:debug("Registration failed: %s",t);
e:event("registration-failure",{type=o,condition=t,text=a});
end
end);
else
e:debug("In-band registration not offered by server");
e:event("registration-failed",{condition="service-unavailable"});
end
e:unhook("stream-features",a);
return true;
end
e:hook("stream-features",a,310);
end
end)
package.preload['verse.plugins.groupchat']=(function(...)
local i=require"verse";
local r=require"events";
local n=require"util.jid";
local t={};
t.__index=t;
local h="urn:xmpp:delay";
local s="http://jabber.org/protocol/muc";
function i.plugins.groupchat(o)
o:add_plugin("presence")
o.rooms={};
o:hook("stanza",function(e)
local a=n.bare(e.attr.from);
if not a then return end
local t=o.rooms[a]
if not t and e.attr.to and a then
t=o.rooms[e.attr.to.." "..a]
end
if t and t.opts.source and e.attr.to~=t.opts.source then return end
if t then
local o=select(3,n.split(e.attr.from));
local n=e:get_child_text("body");
local i=e:get_child("delay",h);
local a={
room_jid=a;
room=t;
sender=t.occupants[o];
nick=o;
body=n;
stanza=e;
delay=(i and i.attr.stamp);
};
local t=t:event(e.name,a);
return t or(e.name=="message")or nil;
end
end,500);
function o:join_room(n,h,a)
if not h then
return false,"no nickname supplied"
end
a=a or{};
local e=setmetatable({
stream=o,jid=n,nick=h,
subject=nil,
occupants={},
opts=a,
events=r.new()
},t);
if a.source then
self.rooms[a.source.." "..n]=e;
else
self.rooms[n]=e;
end
local a=e.occupants;
e:hook("presence",function(o)
local t=o.nick or h;
if not a[t]and o.stanza.attr.type~="unavailable"then
a[t]={
nick=t;
jid=o.stanza.attr.from;
presence=o.stanza;
};
local o=o.stanza:get_child("x",s.."#user");
if o then
local e=o:get_child("item");
if e and e.attr then
a[t].real_jid=e.attr.jid;
a[t].affiliation=e.attr.affiliation;
a[t].role=e.attr.role;
end
end
if t==e.nick then
e.stream:event("groupchat/joined",e);
else
e:event("occupant-joined",a[t]);
end
elseif a[t]and o.stanza.attr.type=="unavailable"then
if t==e.nick then
e.stream:event("groupchat/left",e);
if e.opts.source then
self.rooms[e.opts.source.." "..n]=nil;
else
self.rooms[n]=nil;
end
else
a[t].presence=o.stanza;
e:event("occupant-left",a[t]);
a[t]=nil;
end
end
end);
e:hook("message",function(a)
local t=a.stanza:get_child_text("subject");
if not t then return end
t=#t>0 and t or nil;
if t~=e.subject then
local o=e.subject;
e.subject=t;
return e:event("subject-changed",{from=o,to=t,by=a.sender,event=a});
end
end,2e3);
local t=i.presence():tag("x",{xmlns=s}):reset();
self:event("pre-groupchat/joining",t);
e:send(t)
self:event("groupchat/joining",e);
return e;
end
o:hook("presence-out",function(e)
if not e.attr.to then
for a,t in pairs(o.rooms)do
t:send(e);
end
e.attr.to=nil;
end
end);
end
function t:send(e)
if e.name=="message"and not e.attr.type then
e.attr.type="groupchat";
end
if e.name=="presence"then
e.attr.to=self.jid.."/"..self.nick;
end
if e.attr.type=="groupchat"or not e.attr.to then
e.attr.to=self.jid;
end
if self.opts.source then
e.attr.from=self.opts.source
end
self.stream:send(e);
end
function t:send_message(e)
self:send(i.message():tag("body"):text(e));
end
function t:set_subject(e)
self:send(i.message():tag("subject"):text(e));
end
function t:leave(e)
self.stream:event("groupchat/leaving",self);
local t=i.presence({type="unavailable"});
if e then
t:tag("status"):text(e);
end
self:send(t);
end
function t:admin_set(o,t,a,e)
self:send(i.iq({type="set"})
:query(s.."#admin")
:tag("item",{nick=o,[t]=a})
:tag("reason"):text(e or""));
end
function t:set_role(t,e,a)
self:admin_set(t,"role",e,a);
end
function t:set_affiliation(e,t,a)
self:admin_set(e,"affiliation",t,a);
end
function t:kick(e,t)
self:set_role(e,"none",t);
end
function t:ban(e,t)
self:set_affiliation(e,"outcast",t);
end
function t:event(e,t)
self.stream:debug("Firing room event: %s",e);
return self.events.fire_event(e,t);
end
function t:hook(a,t,e)
return self.events.add_handler(a,t,e);
end
end)
package.preload['verse.plugins.vcard']=(function(...)
local i=require"verse";
local o=require"util.vcard";
local t="vcard-temp";
function i.plugins.vcard(a)
function a:get_vcard(n,e)
a:send_iq(i.iq({to=n,type="get"})
:tag("vCard",{xmlns=t}),e and function(a)
local i,i;
vCard=a:get_child("vCard",t);
if a.attr.type=="result"and vCard then
vCard=o.from_xep54(vCard)
e(vCard)
else
e(false)
end
end or nil);
end
function a:set_vcard(e,n)
local t;
if type(e)=="table"and e.name then
t=e;
elseif type(e)=="string"then
t=o.to_xep54(o.from_text(e)[1]);
elseif type(e)=="table"then
t=o.to_xep54(e);
error("Converting a table to vCard not implemented")
end
if not t then return false end
a:debug("setting vcard to %s",tostring(t));
a:send_iq(i.iq({type="set"})
:add_child(t),n);
end
end
end)
package.preload['verse.plugins.vcard_update']=(function(...)
local n=require"verse";
local e,i="vcard-temp","vcard-temp:x:update";
local e,t=pcall(function()return require("util.hashes").sha1;end);
if not e then
e,t=pcall(function()return require("util.sha1").sha1;end);
if not e then
error("Could not find a sha1()")
end
end
local s=t;
local e,t=pcall(function()
local e=require("util.encodings").base64.decode;
assert(e("SGVsbG8=")=="Hello")
return e;
end);
if not e then
e,t=pcall(function()return require("mime").unb64;end);
if not e then
error("Could not find a base64 decoder")
end
end
local h=t;
function n.plugins.vcard_update(e)
e:add_plugin("vcard");
e:add_plugin("presence");
local t;
function update_vcard_photo(o)
local a;
for e=1,#o do
if o[e].name=="PHOTO"then
a=o[e][1];
break
end
end
if a then
local a=s(h(a),true);
t=n.stanza("x",{xmlns=i})
:tag("photo"):text(a);
e:resend_presence()
else
t=nil;
end
end
local a=e.set_vcard;
local a;
e:hook("ready",function(t)
if a then return;end
a=true;
e:get_vcard(nil,function(t)
if t then
update_vcard_photo(t)
end
e:event("ready");
end);
return true;
end,3);
e:hook("presence-out",function(e)
if t and not e:get_child("x",i)then
e:add_child(t);
end
end,10);
end
end)
package.preload['verse.plugins.carbons']=(function(...)
local a=require"verse";
local o="urn:xmpp:carbons:1";
local n="urn:xmpp:forward:0";
local s=os.time;
local r=require"util.datetime".parse;
local h=require"util.jid".bare;
function a.plugins.carbons(e)
local t={};
t.enabled=false;
e.carbons=t;
function t:enable(i)
e:send_iq(a.iq{type="set"}
:tag("enable",{xmlns=o})
,function(e)
local e=e.attr.type=="result";
if e then
t.enabled=true;
end
if i then
i(e);
end
end or nil);
end
function t:disable(i)
e:send_iq(a.iq{type="set"}
:tag("disable",{xmlns=o})
,function(e)
local e=e.attr.type=="result";
if e then
t.enabled=false;
end
if i then
i(e);
end
end or nil);
end
local i;
e:hook("bind-success",function()
i=h(e.jid);
end);
e:hook("message",function(t)
local a=t:get_child(nil,o);
if t.attr.from==i and a then
a=a.name;
local t=t:get_child("forwarded",n);
local o=t and t:get_child("message","jabber:client");
local t=t:get_child("delay","urn:xmpp:delay");
local t=t and t.attr.stamp;
t=t and r(t);
if o then
return e:event("carbon",{
dir=a,
stanza=o,
timestamp=t or s(),
});
end
end
end,1);
end
end)
package.preload['verse.plugins.archive']=(function(...)
local e=require"verse";
local t=require"util.stanza";
local a="urn:xmpp:mam:tmp"
local c="urn:xmpp:forward:0";
local u="urn:xmpp:delay";
local n=require"util.uuid".generate;
local l=require"util.datetime".parse;
local h=require"util.datetime".datetime;
local s=require"util.rsm";
local i=tonumber;
local d={};
function e.plugins.archive(o)
function o:query_archive(o,e,r)
local n=n();
local t=t.iq{type="get",to=o}
:tag("query",{xmlns=a,queryid=n});
local o=e["with"];
if o then
t:tag("with"):text(o):up();
end
local i,o=i(e["start"]),i(e["end"]);
if i then
t:tag("start"):text(h(i)):up();
end
if o then
t:tag("end"):text(h(o)):up();
end
t:add_child(s.generate(e));
local e={};
local function o(o)
local t=o:get_child("result",a);
if t and t.attr.queryid==n then
local a=o:get_child("forwarded",c);
local o=t.attr.id;
local t=a:get_child("delay",u);
local t=t and l(t.attr.stamp)or nil;
local a=a:get_child("message","jabber:client")
e[#e+1]={id=o,stamp=t,message=a};
return true
end
end
self:hook("message",o,1);
self:send_iq(t,function(t)
self:unhook("message",o);
local a=t.tags[1]and s.get(t.tags[1]);
for t,a in pairs(a or d)do e[t]=a;end
r(t.attr.type=="result"and#e,e);
return true
end);
end
local i={
always=true,[true]="always",
never=false,[false]="never",
roster="roster",
}
local function s(t)
local e={};
local a=t.attr.default;
if a then
e[false]=i[a];
end
local a=t:get_child("always");
if a then
for t in a:childtags("jid")do
local t=t:get_text();
e[t]=true;
end
end
local t=t:get_child("never");
if t then
for t in t:childtags("jid")do
local t=t:get_text();
e[t]=false;
end
end
return e;
end
local function n(o)
local e
e,o[false]=o[false],nil;
if e~=nil then
e=i[e];
end
local i=t.stanza("prefs",{xmlns=a,default=e})
local a=t.stanza("always");
local e=t.stanza("never");
for t,o in pairs(o)do
(o and a or e):tag("jid"):text(t):up();
end
return i:add_child(a):add_child(e);
end
function o:archive_prefs_get(o)
self:send_iq(t.iq{type="get"}:tag("prefs",{xmlns=a}),
function(e)
if e and e.attr.type=="result"and e.tags[1]then
local t=s(e.tags[1]);
o(t,e);
else
o(nil,e);
end
end);
end
function o:archive_prefs_set(e,a)
self:send_iq(t.iq{type="set"}:add_child(n(e)),a);
end
end
end)
package.preload['verse.plugins.time']=(function(...)
local o=require"verse";
local a="urn:xmpp:time";
function o.plugins.time(e)
e:hook("iq/"..a,function(t)
if t.attr.type~="get"then return;end
local t=o.reply(t)
:tag("time",{xmlns=a});
t:tag("utc"):text(tostring(os.date("!%FT%TZ"))):up();
t:tag("tzo"):text(tostring(os.date("%z"):gsub("(%d%d)(%d%d)","%1:%2"))):up();
e:send(t);
return true;
end);
function e:query_time(i,t)
t=t or function(t)return e:event("time/response",t);end
e:send_iq(o.iq({type="get",to=i})
:tag("time",{xmlns=a}),
function(e)
local a=e:get_child("time",a);
if e.attr.type=="result"then
local e=a:get_child_text("utc");
if not e then
t({
error=true;
condition="service-unavailable";
type="cancel";
text="Remote client doesn't support XEP-0202";
});
else
local a=a:get_child_text("tzo")or"+00:00";
local e,i,o,s,n,h=e:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+).?%d*Z");
local d,r,a=a:match("([+%-])(%d%d):?(%d*)");
local a=tonumber(d..(r or 0)*60*60+(a or 0)*60);
local e=os.time({year=e;month=i;day=o;hour=s;min=n;sec=h;isdst=false;});
t({
utc=e or nil;
offset=a or nil;
});
end
else
local o,a,e=e:get_error();
t({
error=true;
condition=a;
text=e;
type=o;
});
end
end);
end
return true;
end
end)
package.preload['verse.plugins.receipts']=(function(...)
local o=require"verse";
local a="urn:xmpp:receipts";
function o.plugins.receipts(e)
e:add_plugin("disco");
local function i(t)
if t:get_child("request",a)then
e:send(o.reply(t)
:tag("received",{xmlns=a,id=t.attr.id}));
end
end
e:add_disco_feature(a);
e:hook("message",i,1e3);
end end)
package.preload['net.httpclient_listener']=(function(...)
local i=require"util.logger".init("httpclient_listener");
local o,n=table.concat,table.insert;
local s=require"net.connlisteners".register;
local a={};
local e={};
local t={default_port=80,default_mode="*a"};
function t.onconnect(t)
local e=a[t];
local a={e.method or"GET"," ",e.path," HTTP/1.1\r\n"};
if e.query then
n(a,4,"?"..e.query);
end
t:write(o(a));
local a={[2]=": ",[4]="\r\n"};
for i,e in pairs(e.headers)do
a[1],a[3]=i,e;
t:write(o(a));
end
t:write("\r\n");
if e.body then
t:write(e.body);
end
end
function t.onincoming(o,t)
local e=a[o];
if not e then
i("warn","Received response from connection %s with no request attached!",tostring(o));
return;
end
if t and e.reader then
e:reader(t);
end
end
function t.ondisconnect(t,e)
local e=a[t];
if e and e.conn then
e:reader(nil);
end
a[t]=nil;
end
function t.register_request(t,e)
i("debug","Attaching request %s to connection %s",tostring(e.id or e),tostring(t));
a[t]=e;
end
s("httpclient",t);
end)
package.preload['net.connlisteners']=(function(...)
local c=(CFG_SOURCEDIR or".").."/net/";
local u=require"net.server";
local a=require"util.logger".init("connlisteners");
local i=tostring;
local l=type
local h=ipairs
local n,r,s=
dofile,xpcall,error
local d=debug.traceback;
module"connlisteners"
local e={};
function register(t,o)
if e[t]and e[t]~=o then
a("debug","Listener %s is already registered, not registering any more",t);
return false;
end
e[t]=o;
a("debug","Registered connection listener %s",t);
return true;
end
function deregister(t)
e[t]=nil;
end
function get(t)
local o=e[t];
if not o then
local s,n=r(function()n(c..t:gsub("[^%w%-]","_").."_listener.lua")end,d);
if not s then
a("error","Error while loading listener '%s': %s",i(t),i(n));
return nil,n;
end
o=e[t];
end
return o;
end
function start(i,e)
local a,t=get(i);
if not a then
s("No such connection module: "..i..(t and(" ("..t..")")or""),0);
end
local o=(e and e.interface)or a.default_interface or"*";
if l(o)=="string"then o={o};end
local r=(e and e.port)or a.default_port or s("Can't start listener "..i.." because no port was specified, and it has no default port",0);
local s=(e and e.mode)or a.default_mode or 1;
local n=(e and e.ssl)or nil;
local i=e and e.type=="ssl";
if i and not n then
return nil,"no ssl context";
end
ok,t=true,{};
for e,o in h(o)do
local e
e,t[o]=u.addserver(o,r,a,s,i and n or nil);
ok=ok and e;
end
return ok,t;
end
return _M;
end)
package.preload['util.httpstream']=(function(...)
local t=coroutine;
local s=tonumber;
local h=t.create(function()end);
t.resume(h);
module("httpstream")
local function c(l,o,u)
local e=t.yield();
local function i()
local a=e:find("\r\n",nil,true);
while not a do
e=e..t.yield();
a=e:find("\r\n",nil,true);
end
local t=e:sub(1,a-1);
e=e:sub(a+2);
return t;
end
local function h(a)
while#e<a do
e=e..t.yield();
end
local t=e:sub(1,a);
e=e:sub(a+1);
return t;
end
local function r()
local a={};
while true do
local e=i();
if e==""then break;end
local e,o=e:match("^([^%s:]+): *(.*)$");
if not e then t.yield("invalid-header-line");end
e=e:lower();
a[e]=a[e]and a[e]..","..o or o;
end
return a;
end
if not o or o=="server"then
while true do
local e=i();
local o,e,i=e:match("^(%S+)%s+(%S+)%s+HTTP/(%S+)$");
if not o then t.yield("invalid-status-line");end
e=e:gsub("^//+","/");
local a=r();
local t=s(a["content-length"]);
t=t or 0;
local t=h(t);
l({
method=o;
path=e;
httpversion=i;
headers=a;
body=t;
});
end
elseif o=="client"then
while true do
local a=i();
local d,a,o=a:match("^HTTP/(%S+)%s+(%d%d%d)%s+(.*)$");
a=s(a);
if not a then t.yield("invalid-status-line");end
local n=r();
local u=not
((u and u().method=="HEAD")
or(a==204 or a==304 or a==301)
or(a>=100 and a<200));
local o;
if u then
local a=s(n["content-length"]);
if n["transfer-encoding"]=="chunked"then
o="";
while true do
local e=i():match("^%x+");
if not e then t.yield("invalid-chunk-size");end
e=s(e,16)
if e==0 then break;end
o=o..h(e);
if i()~=""then t.yield("invalid-chunk-ending");end
end
local e=r();
elseif a then
o=h(a);
else
repeat
local t=t.yield();
e=e..t;
until t=="";
o,e=e,"";
end
end
l({
code=a;
httpversion=d;
headers=n;
body=o;
responseversion=d;
responseheaders=n;
});
end
else t.yield("unknown-parser-type");end
end
function new(n,a,o,i)
local e=t.create(c);
t.resume(e,n,o,i)
return{
feed=function(n,i)
if not i then
if o=="client"then t.resume(e,"");end
e=h;
return a();
end
local o,t=t.resume(e,i);
if t then
e=h;
return a(t);
end
end;
};
end
return _M;
end)
package.preload['net.http']=(function(...)
local y=require"socket"
local w=require"mime"
local p=require"socket.url"
local b=require"util.httpstream".new;
local v=require"net.server"
local e=require"net.connlisteners".get;
local i=e("httpclient")or error("No httpclient listener!");
local a,u=table.insert,table.concat;
local n,h=pairs,ipairs;
local r,l,f,m,s,o,t=
tonumber,tostring,xpcall,select,debug.traceback,string.char,string.format;
local d=require"util.logger".init("http");
module"http"
function urlencode(e)return e and(e:gsub("%W",function(e)return t("%%%02x",e:byte());end));end
function urldecode(e)return e and(e:gsub("%%(%x%x)",function(e)return o(r(e,16));end));end
local function e(e)
return e and(e:gsub("%W",function(e)
if e~=" "then
return t("%%%02x",e:byte());
else
return"+";
end
end));
end
function formencode(o)
local t={};
if o[1]then
for i,o in h(o)do
a(t,e(o.name).."="..e(o.value));
end
else
for o,i in n(o)do
a(t,e(o).."="..e(i));
end
end
return u(t,"&");
end
function formdecode(e)
if not e:match("=")then return urldecode(e);end
local o={};
for e,t in e:gmatch("([^=&]*)=([^&]*)")do
e,t=e:gsub("%+","%%20"),t:gsub("%+","%%20");
e,t=urldecode(e),urldecode(t);
a(o,{name=e,value=t});
o[e]=t;
end
return o;
end
local function c(e,a,t)
if not e.parser then
if not a then return;end
local function o(t)
if e.callback then
for a,t in n(t)do e[a]=t;end
e.callback(t.body,t.code,e,t);
e.callback=nil;
end
destroy_request(e);
end
local function t(t)
if e.callback then
e.callback(t or"connection-closed",0,e);
e.callback=nil;
end
destroy_request(e);
end
local function a()
return e;
end
e.parser=b(o,t,"client",a);
end
e.parser:feed(a);
end
local function u(e)d("error","Traceback[http]: %s: %s",l(e),s());end
function request(e,t,h)
local e=p.parse(e);
if not(e and e.host)then
h(nil,0,e);
return nil,"invalid-url";
end
if not e.path then
e.path="/";
end
local s,a,o;
a={
["Host"]=e.host;
["User-Agent"]="Prosody XMPP Server";
};
if e.userinfo then
a["Authorization"]="Basic "..w.b64(e.userinfo);
end
if t then
e.onlystatus=t.onlystatus;
o=t.body;
if o then
s="POST";
a["Content-Length"]=l(#o);
a["Content-Type"]="application/x-www-form-urlencoded";
end
if t.method then s=t.method;end
if t.headers then
for t,e in n(t.headers)do
a[t]=e;
end
end
end
e.method,e.headers,e.body=s,a,o;
local a=e.scheme=="https";
local o=r(e.port)or(a and 443 or 80);
local t=y.tcp();
t:settimeout(10);
local s,n=t:connect(e.host,o);
if not s and n~="timeout"then
h(nil,0,e);
return nil,n;
end
e.handler,e.conn=v.wrapclient(t,e.host,o,i,"*a",a and{mode="client",protocol="sslv23"});
e.write=function(...)return e.handler:write(...);end
e.callback=function(a,t,i,o)d("debug","Calling callback, status %s",t or"---");return m(2,f(function()return h(a,t,i,o)end,u));end
e.reader=c;
e.state="status";
i.register_request(e.handler,e);
return e;
end
function destroy_request(e)
if e.conn then
e.conn=nil;
e.handler:close()
i.ondisconnect(e.handler,"closed");
end
end
_M.urlencode=urlencode;
return _M;
end)
package.preload['verse.bosh']=(function(...)
local n=require"util.xmppstream".new;
local a=require"util.stanza";
require"net.httpclient_listener";
local o=require"net.http";
local e=setmetatable({},{__index=verse.stream_mt});
e.__index=e;
local h="http://etherx.jabber.org/streams";
local s="http://jabber.org/protocol/httpbind";
local i=5;
function verse.new_bosh(a,t)
local t={
bosh_conn_pool={};
bosh_waiting_requests={};
bosh_rid=math.random(1,999999);
bosh_outgoing_buffer={};
bosh_url=t;
conn={};
};
function t:reopen()
self.bosh_need_restart=true;
self:flush();
end
local t=verse.new(a,t);
return setmetatable(t,e);
end
function e:connect()
self:_send_session_request();
end
function e:send(e)
self:debug("Putting into BOSH send buffer: %s",tostring(e));
self.bosh_outgoing_buffer[#self.bosh_outgoing_buffer+1]=a.clone(e);
self:flush();
end
function e:flush()
if self.connected
and#self.bosh_waiting_requests<self.bosh_max_requests
and(#self.bosh_waiting_requests==0
or#self.bosh_outgoing_buffer>0
or self.bosh_need_restart)then
self:debug("Flushing...");
local t=self:_make_body();
local e=self.bosh_outgoing_buffer;
for o,a in ipairs(e)do
t:add_child(a);
e[o]=nil;
end
self:_make_request(t);
else
self:debug("Decided not to flush.");
end
end
function e:_make_request(t)
local e,t=o.request(self.bosh_url,{body=tostring(t)},function(o,e,a)
if e~=0 then
self.inactive_since=nil;
return self:_handle_response(o,e,a);
end
local e=os.time();
if not self.inactive_since then
self.inactive_since=e;
elseif e-self.inactive_since>self.bosh_max_inactivity then
return self:_disconnected();
else
self:debug("%d seconds left to reconnect, retrying in %d seconds...",
self.bosh_max_inactivity-(e-self.inactive_since),i);
end
timer.add_task(i,function()
self:debug("Retrying request...");
for t,e in ipairs(self.bosh_waiting_requests)do
if e==a then
table.remove(self.bosh_waiting_requests,t);
break;
end
end
self:_make_request(t);
end);
end);
if e then
table.insert(self.bosh_waiting_requests,e);
else
self:warn("Request failed instantly: %s",t);
end
end
function e:_disconnected()
self.connected=nil;
self:event("disconnected");
end
function e:_send_session_request()
local e=self:_make_body();
e.attr.hold="1";
e.attr.wait="60";
e.attr["xml:lang"]="en";
e.attr.ver="1.6";
e.attr.from=self.jid;
e.attr.to=self.host;
e.attr.secure='true';
o.request(self.bosh_url,{body=tostring(e)},function(e,t)
if t==0 then
return self:_disconnected();
end
local e=self:_parse_response(e)
if not e then
self:warn("Invalid session creation response");
self:_disconnected();
return;
end
self.bosh_sid=e.attr.sid;
self.bosh_wait=tonumber(e.attr.wait);
self.bosh_hold=tonumber(e.attr.hold);
self.bosh_max_inactivity=tonumber(e.attr.inactivity);
self.bosh_max_requests=tonumber(e.attr.requests)or self.bosh_hold;
self.connected=true;
self:event("connected");
self:_handle_response_payload(e);
end);
end
function e:_handle_response(a,t,e)
if self.bosh_waiting_requests[1]~=e then
self:warn("Server replied to request that wasn't the oldest");
for t,a in ipairs(self.bosh_waiting_requests)do
if a==e then
self.bosh_waiting_requests[t]=nil;
break;
end
end
else
table.remove(self.bosh_waiting_requests,1);
end
local e=self:_parse_response(a);
if e then
self:_handle_response_payload(e);
end
self:flush();
end
function e:_handle_response_payload(t)
local e=t.tags;
for t=1,#e do
local e=e[t];
if e.attr.xmlns==h then
self:event("stream-"..e.name,e);
elseif e.attr.xmlns then
self:event("stream/"..e.attr.xmlns,e);
else
self:event("stanza",e);
end
end
if t.attr.type=="terminate"then
self:_disconnected({reason=t.attr.condition});
end
end
local a={
stream_ns="http://jabber.org/protocol/httpbind",stream_tag="body",
default_ns="jabber:client",
streamopened=function(e,t)e.notopen=nil;e.payload=verse.stanza("body",t);return true;end;
handlestanza=function(t,e)t.payload:add_child(e);end;
};
function e:_parse_response(e)
self:debug("Parsing response: %s",e);
if e==nil then
self:debug("%s",debug.traceback());
self:_disconnected();
return;
end
local t={notopen=true,stream=self};
local a=n(t,a);
a:feed(e);
return t.payload;
end
function e:_make_body()
self.bosh_rid=self.bosh_rid+1;
local e=verse.stanza("body",{
xmlns=s;
content="text/xml; charset=utf-8";
sid=self.bosh_sid;
rid=self.bosh_rid;
});
if self.bosh_need_restart then
self.bosh_need_restart=nil;
e.attr.restart='true';
end
return e;
end
end)
package.preload['verse.client']=(function(...)
local t=require"verse";
local o=t.stream_mt;
local d=require"util.jid".split;
local r=require"net.adns";
local e=require"lxp";
local a=require"util.stanza";
t.message,t.presence,t.iq,t.stanza,t.reply,t.error_reply=
a.message,a.presence,a.iq,a.stanza,a.reply,a.error_reply;
local s=require"util.xmppstream".new;
local n="http://etherx.jabber.org/streams";
local function h(e,t)
return e.priority<t.priority or(e.priority==t.priority and e.weight>t.weight);
end
local i={
stream_ns=n,
stream_tag="stream",
default_ns="jabber:client"};
function i.streamopened(e,t)
e.stream_id=t.id;
if not e:event("opened",t)then
e.notopen=nil;
end
return true;
end
function i.streamclosed(e)
return e:event("closed");
end
function i.handlestanza(t,e)
if e.attr.xmlns==n then
return t:event("stream-"..e.name,e);
elseif e.attr.xmlns then
return t:event("stream/"..e.attr.xmlns,e);
end
return t:event("stanza",e);
end
function o:reset()
if self.stream then
self.stream:reset();
else
self.stream=s(self,i);
end
self.notopen=true;
return true;
end
function o:connect_client(e,a)
self.jid,self.password=e,a;
self.username,self.host,self.resource=d(e);
self:add_plugin("tls");
self:add_plugin("sasl");
self:add_plugin("bind");
self:add_plugin("session");
function self.data(t,e)
local a,t=self.stream:feed(e);
if a then return;end
self:debug("debug","Received invalid XML (%s) %d bytes: %s",tostring(t),#e,e:sub(1,300):gsub("[\r\n]+"," "));
self:close("xml-not-well-formed");
end
self:hook("connected",function()self:reopen();end);
self:hook("incoming-raw",function(e)return self.data(self.conn,e);end);
self.curr_id=0;
self.tracked_iqs={};
self:hook("stanza",function(e)
local t,a=e.attr.id,e.attr.type;
if t and e.name=="iq"and(a=="result"or a=="error")and self.tracked_iqs[t]then
self.tracked_iqs[t](e);
self.tracked_iqs[t]=nil;
return true;
end
end);
self:hook("stanza",function(e)
local a;
if e.attr.xmlns==nil or e.attr.xmlns=="jabber:client"then
if e.name=="iq"and(e.attr.type=="get"or e.attr.type=="set")then
local o=e.tags[1]and e.tags[1].attr.xmlns;
if o then
a=self:event("iq/"..o,e);
if not a then
a=self:event("iq",e);
end
end
if a==nil then
self:send(t.error_reply(e,"cancel","service-unavailable"));
return true;
end
else
a=self:event(e.name,e);
end
end
return a;
end,-1);
self:hook("outgoing",function(e)
if e.name then
self:event("stanza-out",e);
end
end);
self:hook("stanza-out",function(e)
if not e.attr.xmlns then
self:event(e.name.."-out",e);
end
end);
local function e()
self:event("ready");
end
self:hook("session-success",e,-1)
self:hook("bind-success",e,-1);
local e=self.close;
function self:close(t)
if not self.notopen then
self:send("</stream:stream>");
end
return e(self);
end
local function t()
self:connect(self.connect_host or self.host,self.connect_port or 5222);
end
if not(self.connect_host or self.connect_port)then
r.lookup(function(a)
if a then
local e={};
self.srv_hosts=e;
for a,t in ipairs(a)do
table.insert(e,t.srv);
end
table.sort(e,h);
local a=e[1];
self.srv_choice=1;
if a then
self.connect_host,self.connect_port=a.target,a.port;
self:debug("Best record found, will connect to %s:%d",self.connect_host or self.host,self.connect_port or 5222);
end
self:hook("disconnected",function()
if self.srv_hosts and self.srv_choice<#self.srv_hosts then
self.srv_choice=self.srv_choice+1;
local e=e[self.srv_choice];
self.connect_host,self.connect_port=e.target,e.port;
t();
return true;
end
end,1e3);
self:hook("connected",function()
self.srv_hosts=nil;
end,1e3);
end
t();
end,"_xmpp-client._tcp."..(self.host)..".","SRV");
else
t();
end
end
function o:reopen()
self:reset();
self:send(a.stanza("stream:stream",{to=self.host,["xmlns:stream"]='http://etherx.jabber.org/streams',
xmlns="jabber:client",version="1.0"}):top_tag());
end
function o:send_iq(t,a)
local e=self:new_id();
self.tracked_iqs[e]=a;
t.attr.id=e;
self:send(t);
end
function o:new_id()
self.curr_id=self.curr_id+1;
return tostring(self.curr_id);
end
end)
package.preload['verse.component']=(function(...)
local o=require"verse";
local a=o.stream_mt;
local h=require"util.jid".split;
local e=require"lxp";
local t=require"util.stanza";
local d=require"util.sha1".sha1;
o.message,o.presence,o.iq,o.stanza,o.reply,o.error_reply=
t.message,t.presence,t.iq,t.stanza,t.reply,t.error_reply;
local r=require"util.xmppstream".new;
local s="http://etherx.jabber.org/streams";
local i="jabber:component:accept";
local n={
stream_ns=s,
stream_tag="stream",
default_ns=i};
function n.streamopened(e,t)
e.stream_id=t.id;
if not e:event("opened",t)then
e.notopen=nil;
end
return true;
end
function n.streamclosed(e)
return e:event("closed");
end
function n.handlestanza(t,e)
if e.attr.xmlns==s then
return t:event("stream-"..e.name,e);
elseif e.attr.xmlns or e.name=="handshake"then
return t:event("stream/"..(e.attr.xmlns or i),e);
end
return t:event("stanza",e);
end
function a:reset()
if self.stream then
self.stream:reset();
else
self.stream=r(self,n);
end
self.notopen=true;
return true;
end
function a:connect_component(e,n)
self.jid,self.password=e,n;
self.username,self.host,self.resource=h(e);
function self.data(t,e)
local t,o=self.stream:feed(e);
if t then return;end
a:debug("debug","Received invalid XML (%s) %d bytes: %s",tostring(o),#e,e:sub(1,300):gsub("[\r\n]+"," "));
a:close("xml-not-well-formed");
end
self:hook("incoming-raw",function(e)return self.data(self.conn,e);end);
self.curr_id=0;
self.tracked_iqs={};
self:hook("stanza",function(e)
local t,a=e.attr.id,e.attr.type;
if t and e.name=="iq"and(a=="result"or a=="error")and self.tracked_iqs[t]then
self.tracked_iqs[t](e);
self.tracked_iqs[t]=nil;
return true;
end
end);
self:hook("stanza",function(e)
local t;
if e.attr.xmlns==nil or e.attr.xmlns=="jabber:client"then
if e.name=="iq"and(e.attr.type=="get"or e.attr.type=="set")then
local a=e.tags[1]and e.tags[1].attr.xmlns;
if a then
t=self:event("iq/"..a,e);
if not t then
t=self:event("iq",e);
end
end
if t==nil then
self:send(o.error_reply(e,"cancel","service-unavailable"));
return true;
end
else
t=self:event(e.name,e);
end
end
return t;
end,-1);
self:hook("opened",function(e)
print(self.jid,self.stream_id,e.id);
local e=d(self.stream_id..n,true);
self:send(t.stanza("handshake",{xmlns=i}):text(e));
self:hook("stream/"..i,function(e)
if e.name=="handshake"then
self:event("authentication-success");
end
end);
end);
local function e()
self:event("ready");
end
self:hook("authentication-success",e,-1);
self:connect(self.connect_host or self.host,self.connect_port or 5347);
self:reopen();
end
function a:reopen()
self:reset();
self:send(t.stanza("stream:stream",{to=self.jid,["xmlns:stream"]='http://etherx.jabber.org/streams',
xmlns=i,version="1.0"}):top_tag());
end
function a:close(t)
if not self.notopen then
self:send("</stream:stream>");
end
local e=self.conn.disconnect();
self.conn:close();
e(conn,t);
end
function a:send_iq(t,a)
local e=self:new_id();
self.tracked_iqs[e]=a;
t.attr.id=e;
self:send(t);
end
function a:new_id()
self.curr_id=self.curr_id+1;
return tostring(self.curr_id);
end
end)
pcall(require,"luarocks.require");
pcall(require,"ssl");
local a=require"net.server";
local n=require"util.events";
local o=require"util.logger";
module("verse",package.seeall);
local e=_M;
_M.server=a;
local t={};
t.__index=t;
stream_mt=t;
e.plugins={};
function e.init(...)
for e=1,select("#",...)do
local t=pcall(require,"verse."..select(e,...));
if not t then
error("Verse connection module not found: verse."..select(e,...));
end
end
return e;
end
local i=0;
function e.new(o,a)
local t=setmetatable(a or{},t);
i=i+1;
t.id=tostring(i);
t.logger=o or e.new_logger("stream"..t.id);
t.events=n.new();
t.plugins={};
t.verse=e;
return t;
end
e.add_task=require"util.timer".add_task;
e.logger=o.init;
e.new_logger=o.init;
e.log=e.logger("verse");
local function s(o,...)
local e,a,t=0,{...},select('#',...);
return(o:gsub("%%(.)",function(o)if e<=t then e=e+1;return tostring(a[e]);end end));
end
function e.set_log_handler(e,t)
t=t or{"debug","info","warn","error"};
o.reset();
if io.type(e)=="file"then
local t=e;
function e(e,a,o)
t:write(e,"\t",a,"\t",o,"\n");
end
end
if e then
local function i(a,o,t,...)
return e(a,o,s(t,...));
end
for t,e in ipairs(t)do
o.add_level_sink(e,i);
end
end
end
function _default_log_handler(a,t,o)
return io.stderr:write(a,"\t",t,"\t",o,"\n");
end
e.set_log_handler(_default_log_handler,{"error"});
local function o(t)
e.log("error","Error: %s",t);
e.log("error","Traceback: %s",debug.traceback());
end
function e.set_error_handler(e)
o=e;
end
function e.loop()
return xpcall(a.loop,o);
end
function e.step()
return xpcall(a.step,o);
end
function e.quit()
return a.setquitting(true);
end
function t:listen(e,t)
e=e or"localhost";
t=t or 0;
local a,o=a.addserver(e,t,new_listener(self,"server"),"*a");
if a then
self:debug("Bound to %s:%s",e,t);
self.server=a;
end
return a,o;
end
function t:connect(t,o)
t=t or"localhost";
o=tonumber(o)or 5222;
local i=socket.tcp()
i:settimeout(0);
local n,e=i:connect(t,o);
if not n and e~="timeout"then
self:warn("connect() to %s:%d failed: %s",t,o,e);
return self:event("disconnected",{reason=e})or false,e;
end
local t=a.wrapclient(i,t,o,new_listener(self),"*a");
if not t then
self:warn("connection initialisation failed: %s",e);
return self:event("disconnected",{reason=e})or false,e;
end
self:set_conn(t);
return true;
end
function t:set_conn(t)
self.conn=t;
self.send=function(a,e)
self:event("outgoing",e);
e=tostring(e);
self:event("outgoing-raw",e);
return t:write(e);
end;
end
function t:close()
if not self.conn then
e.log("error","Attempt to close disconnected connection - possibly a bug");
return;
end
local e=self.conn.disconnect();
self.conn:close();
e(conn,reason);
end
function t:debug(...)
return self.logger("debug",...);
end
function t:info(...)
return self.logger("info",...);
end
function t:warn(...)
return self.logger("warn",...);
end
function t:error(...)
return self.logger("error",...);
end
function t:event(e,...)
self:debug("Firing event: "..tostring(e));
return self.events.fire_event(e,...);
end
function t:hook(e,...)
return self.events.add_handler(e,...);
end
function t:unhook(t,e)
return self.events.remove_handler(t,e);
end
function e.eventable(e)
e.events=n.new();
e.hook,e.unhook=t.hook,t.unhook;
local t=e.events.fire_event;
function e:event(e,...)
return t(e,...);
end
return e;
end
function t:add_plugin(t)
if self.plugins[t]then return true;end
if require("verse.plugins."..t)then
local e,a=e.plugins[t](self);
if e~=false then
self:debug("Loaded %s plugin",t);
self.plugins[t]=true;
else
self:warn("Failed to load %s plugin: %s",t,a);
end
end
return self;
end
function new_listener(t)
local a={};
function a.onconnect(a)
if t.server then
local e=e.new();
a:setlistener(new_listener(e));
e:set_conn(a);
t:event("connected",{client=e});
else
t.connected=true;
t:event("connected");
end
end
function a.onincoming(a,e)
t:event("incoming-raw",e);
end
function a.ondisconnect(a,e)
t.connected=false;
t:event("disconnected",{reason=e});
end
function a.ondrain(e)
t:event("drained");
end
function a.onstatus(a,e)
t:event("status",e);
end
return a;
end
return e;
