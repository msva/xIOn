xIOn = {};
local DB = require "libs.DB";
local cmds = require "plugins.commands"

local ok, fun = pcall(function()
        local unb64 = require("util.encodings").base64.decode;
        assert(unb64("SGVsbG8=") == "Hello")
        return unb64;
end);

if not ok then
        ok, fun = pcall(function() return require("mime").unb64; end);
        if not ok then
                error("Could not find a base64 decoder")
        end
end
unb64 = fun;

local xmlns_lib = require "libs.xmlns"
stanza = require "util.stanza";
local check = require "util.checks".fatal;
local log = require "util.logger".init("core");
local chunk, err = loadfile("config.lua");

check(chunk, "File or syntax error: ", err);
config = {};
setfenv(chunk, setmetatable(config, {__index = _G}));
local ok, err = pcall(chunk);
check(ok, "Error while processing config: ", err);
setmetatable(config, nil);
check(config.xmpp.jid, "Bot's JID is not set!");
check(config.xmpp.password ,"Bot's password for JID is not set!");
check(config.xmpp.mode, "Bot's work mode is not set!");

xIOn.XMPP = require "verse".init(config.xmpp.mode); -- XMPP client library
xIOn.XMPP.connection = xIOn.XMPP.new(xIOn.XMPP.new_logger("xmpp"));

if not xIOn.XMPP.connection then
  error[[Somewhy you have broken distribution of xIOn]]
end

for _,plug in ipairs(config.xmpp.lib_plugins) do
	xIOn.XMPP.connection:add_plugin(plug)
end

local identity = {
  category = 'client',
  type='bot',
  name='xIOn'
};

local version = {
  name = "xIOn",
  version = "0.0.5",
  platform = "ZOG"
};

xIOn.XMPP.connection.version:set(version);
xIOn.XMPP.connection:set_identity(identity);
xIOn.XMPP.connection.caps.node = 'http://xion.im/about';

xIOn.XMPP.connection:add_disco_feature(xmlns_geoloc_notify);
xIOn.XMPP.connection:add_disco_feature(xmlns_adhoc);
xIOn.XMPP.connection:add_disco_feature(xmlns_xhtml);

local function printor(str) return function() print(str) end end
xIOn.XMPP.roster = {
			add = function(jid) xIOn.XMPP.connection.roster:add_contact(jid) end;
			sub = function(jid) xIOn.XMPP.connection:send(xIOn.XMPP.presence{to=jid, type="subscribe"}); end;
			unsub = function(jid) xIOn.XMPP.connection:send(xIOn.XMPP.presence{to=jid, type="unsubscribe"}); end;
			auth = function(jid) xIOn.XMPP.connection:send(xIOn.XMPP.presence{to=jid, type="subscribed"}); end;
			unauth = function(jid) xIOn.XMPP.connection:send(xIOn.XMPP.presence{to=jid, type="unsubscribed"}); end;
			del = function(jid) xIOn.XMPP.connection.roster:delete_contact(jid) end;
			setnick = function(jid,nick)
				local item = xIOn.XMPP.connection.roster.items[jid];
				if not item then print("no jid "..jid); return; end
				xIOn.XMPP.connection.roster:add_contact(jid, nick, item.groups or {}, printor("saved"));
			end;
			addgroup = function(jid,group)
				local item = xIOn.XMPP.connection.roster.items[jid];
				local groups = item.groups or {};
				table.insert(groups, group);
				xIOn.XMPP.connection.roster:add_contact(jid, item.name, groups, printor("saved"));
			end;
			delgroup = function(jid,group)
				local item = xIOn.XMPP.connection.roster.items[jid];
				local groups = item.groups;
				if not groups then return end;
				for i = 1,#groups do
					if groups[i] == group then
						table.remove(groups, i);
						break
					end
				end
				xIOn.XMPP.connection.roster:add_contact(jid, item.name, groups, printor("saved"));
			end;
			list = function(param)
				if param == "" then
					param = nil
				end
				if param then
					param = param:gsub("%-","%%-")
				end
				for jid, item in pairs(xIOn.XMPP.connection.roster.items) do
					local name, host = item.name or split_jid(jid);
					local groups = table.concat(item.groups or {}, ", ");
					if not param or ( (name and name:match(param)) or jid:match(param) ) then
						return jid, name or host, groups;
					end
				end
			end;
			listgroups = function(param)
				local groups = {};
				for jid, item in pairs(xIOn.XMPP.connection.roster.items) do
					for i = 1,#item.groups do
						groups[item.groups[i]] = ( groups[item.groups[i]] or 0 ) + 1;
					end
				end
				for group, size in pairs(groups) do
					return group, size
				end
			end;
			show = function(barejid)
				local item = xIOn.XMPP.connection.roster.items[barejid];
				if not item then
					print("No such contact: "..tostring(barejid));
					return;
				end

				for k,v in pairs(item) do
					return k,type(v) == "table" and table.concat(v, ", ") or v
				end
			end;
--[[
			export = function()
				local stored_roster = { [false] = { version = xIOn.XMPP.connection.roster.ver } }
				for jid, item in pairs(xIOn.XMPP.connection.roster.items) do
					stored_roster[jid] = {
						name = item.name;
						subscription = item.subscription;
						groups = { unpack(item.groups) };
					}
				end
				print("return "..require"util.serialization".serialize(stored_roster));
			end
]]
		}

function xIOn:default_hooks()
  xIOn.XMPP.connection:hook("authentication-failure", function (err)
    print("Failed to log in! Error:"..tostring(err.condition));
  end);
  xIOn.XMPP.connection:hook("disconnected", function () print("Disconnected!"); os.exit(); end);

  if config.xmpp.debug then
    xIOn.XMPP.set_log_handler(print);
    xIOn.XMPP.connection:hook("outgoing-raw", print, math.huge);
    xIOn.XMPP.connection:hook("incoming-raw", print, math.huge);
  end
end

local T = require "core.l10n".init("core");
language = config.xmpp.language or "ru";

--if config.xmpp.debug then
  log('info', "LANG: '"..language.."'");
--end



function xIOn.XMPP.bare_jid(jid)
  return jid:gsub("(.*@.*%.?.*)/.*","%1")
end
function xIOn.XMPP.jid2nick(jid)
  return jid:gsub("(.*)@.*%..*/?.*","%1")
end

function xIOn:connect(mode, jid, password)
  if mode == "client" then
    xIOn.XMPP.connection:connect_client(jid, password)
  elseif mode == "component" then
    xIOn.XMPP.connection:connect_component(jid, password)
  else
    error([[We can work only as "component" or as "client", but you've defined ]]
    ..(mode or "nothing")..[[ as mode]]);
  end
end

function xIOn:get_nick_by_id(id)
  --TODO
  return id;
end

function xIOn:get_user_id(jid)
  --TODO
  return jid:match("(.*)@.*");
end

function xIOn:get_user_settings(id, name)
  --TODO
  return 1
end

function xIOn:tags_to_string(tags,event)
  local res = table.concat(tags, ", *");
  return #res>0 and "*"..res or nil;
end

function xIOn:tags_to_html(tags,event)
  local stype = event.stanza.attr.type;
  local res;
  for _, tag in ipairs(tags) do
    res = (res and
      (res
      ..[[<span]]
        ..[[ class="tag"]]
        ..[[ style="text-decoration: none; color: #008E00; font-weight: bold;]]
      ..[[ ">, </span>]])
        or "")
      ..[[<a]]
        ..[[ class="tag"]]
        ..[[ style="text-decoration: none; color: #008E00; font-weight: bold;"]]
        ..[[ title="Получить последние сообщения с тегом *]]..tag..[["]]
        ..[[ href="xmpp:]]..config.xmpp.jid..[[?message;type=]]..stype..[[;body=*]]
          ..tag..[[">]]
      .."*"..tag
      ..[[</a>]]
  end
  return (res and #res>0) and res or nil;
end

function xIOn:tag_exists(tags, tag)
  local res=false;
  for k,v in pairs(tags) do
    if (v==tag) then
      res = true;
      break;
    end;
  end;
  return res;
end

function xIOn:get_user_privacy_mode(user)
  --TODO
  --[[
        1: normal
        2: whitelisted mode
  ]]--
  return 1;
end

function xIOn:get_post_privacy_mode(author,tags)
  local mode;
  --[[
        1: always-public
        2: public-by-user-privacy-mode
        3: private-by-user-privacy-mode
        4: always-private-group
        5: always-private
        6: depends-on-user-privacy-mode
  ]]--
  if xIOn:tag_exists(tags,"public") then
    mode = 1;
  elseif xIOn:get_user_privacy_mode(author) == 2 and xIOn:tag_exists(tags,"public") then
    mode = 2;
  elseif xIOn:get_user_privacy_mode(author) == 2 and not xIOn:tag_exists(tags,"public") then
    mode = 3;
  elseif xIOn:tag_exists(tags, "private") then
    if xIOn:tag_exists(tags, "group") then
      mode = 4;
    else
      mode = 5;
    end; --[[ if private group ]]
  else
    mode = 6;
  end --[[ if tags ]]
  return mode;
end

function xIOn:get_post_write_mode(tags)
  local mode;
  --[[
        false: Read Only
        true: Write Allowed
  ]]--
  if xIOn:tag_exists(tags,"readonly") then
    mode = false;
  else
    mode = true;
  end
  return mode;
end

function xIOn:last_user_messages(type,event,param)
  --TODO
  --[[ Type:
          "recommendations"
          "tags"
  ]]--
  return 1;
end

function xIOn:parse_post(event)
  --TODO
  local tags,dest,text,tags_w = {}, {}, "", "";
  local err;

  if event.body:sub(1,1) == "*" then
    if event.body:match("%*%*") then
      tags_w, text = (event.body.."\n"):match("(*[^\r\n]*)%*%*(.+)\n");
    else
      tags_w, text = (event.body.."\n"):match("(*[^\r\n]*)[\r\n]+([^%s].*)\n");
    end;
    tags_w = tags_w or event.body;
    tags_w = tags_w or "";
    text = text or "";
  else
    text = event.body;
    text = text or "";
  end


  if event.html then
    print(11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111);
  end

--print("tags_w: ",tags_w,'\ntext:',text)

  for tag in (tags_w.."\n"):gmatch("*([^%s]*[^*\r\n]*[^*%s]+)[%s]") do
    table.insert(tags,tag)
  end;

  for hashtag in text:gmatch([[#([^%s'",]+)]]) do
    table.insert(tags,hashtag);
  end;

  for dst in ("\n"..text):gmatch("[\n%s"..[['"]@([^%s'";:,#]+[:]*[^%s'";:,#]+)]]) do
    --[[TODO: Avoid long unreadable patterns]]
    table.insert(dest,dst);
  end;


  text = text and stanza.xml_escape(text) or "";
  text = text:gsub("\n","<br/>")
--  print(type(text))

  local author = xIOn:get_user_id(event.sender.jid);

  local post = {
    tags = tags,
    author = author,
    text = text,
    dest = dest,
    privacy = xIOn:get_post_privacy_mode(author,tags),
    writeable = xIOn:get_post_write_mode(tags),
    err = err;
  }
  return post
end;

function xIOn:write_post(post,event)
  --TODO
  if not post or not event then return end;
  local author = xIOn:get_nick_by_id(post.author)
  local sjid = event.sender.jid;
  local _S = {};
    _S.stanza_type = event.stanza.attr.type;
    _S.jid = config.xmpp.jid;
  local post_links = require "core.tpl".init("post_links",_S);
  if post.err then
    xIOn:send_message(sjid, _S.stanza_type, "\n"
        .."Ошибка:"
        .."\n"
        ..post.text);
  else
	post = xIOn.DB:write_post(post); --TODO: post= -> post.id=
	_S.post_id = post.id;
	xIOn:send_html_message(
      sjid,
      _S.stanza_type,
      "\nСообщение опубликовано!\n"
      .."#"..post.id,
      [[<div class="post">Сообщение опубликовано</div>]]
--      ..(event.html and [[<div>]]..stanza.xml_escape(event.html)..[[</div>]] or '')
--      ..(stanza.xml_escape(stanza))
      ..[[<div class="post_links">]]
      ..post_links("read")
      ..post_links("delimiter")
      ..post_links("delete")
      ..post_links("delimiter")
      ..post_links("unsubscribe")
      ..post_links("delimiter")
      ..post_links("edit")
      ..[[</div>]]
    );
	for barejid,user in pairs(xIOn.XMPP.connection.roster.items) do
--		if (user.jid ~= xIOn.XMPP.bare_jid(event.sender.jid)) and (user.subscription == "both") then
		j,n,usergroups = xIOn.XMPP.roster.list(user.name);
--		if (user.jid == xIOn.XMPP.bare_jid(event.sender.jid)) and (user.subscription == "both") then
		if (user.subscription == "both") and not(usergroups:match("OFF")) then
			post.author = xIOn.XMPP.connection.roster.items[xIOn.XMPP.bare_jid(event.sender.jid)].name or xIOn.XMPP.jid2nick(event.sender.jid);
			post.avatar = userinfo[xIOn.XMPP.bare_jid(event.sender.jid)].avatar;
			post.time = userinfo[xIOn.XMPP.bare_jid(event.sender.jid)].time;
			xIOn:read_post(post,event,user.jid); --TODO: remove
		end
	end
  end;
end;

function xIOn:read_post(post,event,receiver)
  --TODO: remake that
-- post = xIOn.DB:read_post(id)

--[[
    local xhtml = false;
  local html_cap = xIOn:get_user_settings(author, "xhtml");

  if (html_cap == 1) or (html_cap == 2) then
    xhtml = true;
  end

]]


  post = xIOn.DB:read_post(post)
  ----------- read:post --------------
    local _S = {};
    _S.post_id = post.id;
    _S.stanza_type = event.stanza.attr.type;
    _S.jid = config.xmpp.jid;
    local sjid = receiver or event.sender.jid;
    local post_links = require "core.tpl".init("post_links",_S);

    local author = xIOn:get_nick_by_id(post.author)
    local sender = xIOn:get_nick_by_id(xIOn:get_user_id(sjid));
--  post.text = post.text and stanza.xml_escape(post.text) or "";
    local tags_s;
    if post.xhtml then
      tags_s = xIOn:tags_to_html(post.tags,event);
    else
      tags_s = xIOn:tags_to_string(post.tags,event);
    end

	xIOn:send_html_message(
      sjid,
      _S.stanza_type,
 --     (post.xhtml
 --       and
 --         "Ваше сообщение"
 --       or
--      "\nАктивирован тестовый режим. Ваше сообщение:\n"
--    ..
      "\n@"..author
      ..(tags_s and ("\n"..tags_s) or "")
      .."\n"..post.text.."\n\n"
      .."#"..post.id,
--)
--      [[<div class="post">Активирован тестовый режим. Ваше сообщение:</div>]]
--        ..
      [[<br />]]..
      [[<a]]
          ..[[ style="text-decoration: none; color: #0055FF; font-weight: bold;"]]
          ..[[ title="Инфо о пользователе @]]..author..[["]]
          ..[[ href="xmpp:]]..config.xmpp.jid..[[?message;type=]].._S.stanza_type..[[;body=%40]]..author..[[">@]]..author.."</a>:"
      ..(tags_s and ([[<div class="post_tags">  ]]..tags_s.."</div>") or "")
      ..[[<br /><div class="avatar_wrapper"><div class="avatar" style="background: url(]]..post.avatar..[[) 100% 100% no-repeat; background-size: cover; width: 50px; height: 50px;"></div></div>]]
      ..[[<div class="post_text">]]..post.text.."</div><br />"
      ..[[<div class="post_links">]]
      ..post_links("read")
      ..(
        (author == sender) and post_links("delimiter")
          ..post_links("delete") or [[]]
      )
      ..post_links("delimiter")
      ..(
        xIOn.DB:is_subscribed(sender,post.id) and
        post_links("subscribe") or
        post_links("unsubscribe")
      )
      ..(
        (author == sender) and post_links("delimiter")
          ..post_links("edit") or [[]]
      )
      ..post_links("delimiter")
      ..post_links("bookmark")
      ..[[</div>]]
      );
------------------------------------

  --[[

      xIOn.XMPP.stanza("div", {class="post"})
--        :tag("br"):up()
        :tag("div", {class="post_text"}):text("Сообщение опубликовано!"):up()
--        :tag("br"):up()
        :tag("div", {
          class = "post_links"
        })
        :tag("a", {
          class="post_read_link",
          style="text-decoration: none; color: #C05800; font-weight: bold;",
          href="xmpp:"..config.xmpp.jid.."?message;type="..event.stanza.attr.type..";body=%23"..post.id.."+"
        }):text("#"..post.id):up()
        :tag("span"):text(" "):up()
        :tag("a", {
          class="post_del_link",
          style="text-decoration: none; color: #C05800; font-weight: bold;",
          href="xmpp:"..config.xmpp.jid.."?message;type="..event.stanza.attr.type..";body=D%20%23"..post.id
        }):text("D"):up()
        :tag("span"):text(" "):up()
        :tag("a", {
          class="post_unsub_link",
          style="text-decoration: none; color: #C05800; font-weight: bold;",
          href="xmpp:"..config.xmpp.jid.."?message;type="..event.stanza.attr.type..";body=U%20%23"..post.id
        }):text("U")


    xIOn.XMPP.stanza("div", {class="post"})
      :tag("div", {class="post_tags"}):text(
      "\nАктивирован тестовый режим. Ваше сообщение:\n"
      .."@"..xIOn:get_nick_by_id(post.author)
      ..(tags_s and ("\nТеги: "..tags_s) or "")
      .."\nТекст:\n"..post.text.."\n\n"
        ):up()
        :tag("div", {
          class = "post_links"
        })
        :tag("a", {
          class="post_read_link",
          style="text-decoration: none; color: #C05800; font-weight: bold;",
          href="xmpp:"..config.xmpp.jid.."?message;type="..event.stanza.attr.type..";body=%23"..post.id.."+"
        }):text("#"..post.id):up()


      ]]
end;

function xIOn:top_blogs(event)
  --TODO
  xIOn:send_message(event.sender.jid,event.stanza.attr.type,"\n".."TOP10 ещё не реализован в виду отсутствия пользователей")
end

function xIOn:print_help()
  if (not cmds) and (not help_points) then
    return "Помощь временно не работает."
  end
  local help_text = "";
  help_text = "\n".."Команды, поддерживаемые ботом:"
  for cm,f in pairs(cmds) do
    help_text = help_text.."\n".."    "..cm.." — "..cmds[cm]("info");
  end
  help_text=help_text.."\n".."Дополнительные пункты справки:"
  for hp,f in pairs(help_points) do
    help_text = help_text.."\n".."    "..hp.." — "..help_points[hp]("info");
  end
  help_text=help_text.."\n\n".."Более подробную справку по командам можно "
    .."посмотреть набрав «help <команда>» или «? <команда>»."
    .."\n\n"
    .."Дополнительные пункты справки командами не являются, но прочитать их "
    .."содержимое можно таким же способом."
  return help_text
end;

function xIOn:set_user_param(event)
  --TODO
end;

function xIOn:send(s)
  return xIOn.XMPP.connection:send(s);
end;

function xIOn:send_presence(to, type)
  return xIOn:send(xIOn.XMPP.presence({ to = to, type = type }));
end;

function xIOn:send_iq(s, callback, errback)
  return xIOn.XMPP.connection:send_iq(s, callback, errback);
end;

function xIOn:send_message(to, type, text)
  xIOn:send(xIOn.XMPP.message({ to = to, type = type }):tag("body"):text(text));
end;

function xIOn:send_html_message(to, type, fallback_text, html)
--xIOn:send_message(to,type,fallback_text);
  stanza.noesc();
  xIOn:send(stanza.message({to = to, type = type})
    :tag("body"):text(fallback_text):up()
    :tag("html",{xmlns = xmlns_xhtml})
    :tag("body",{xmlns = xmlns_xhtml_body})
    :text(html)
  );
  stanza.doesc();
end;

function xIOn:ready_hook()
  xIOn.XMPP.connection:hook("ready", function ()

    xIOn.XMPP.connection:hook_pep(xmlns_mood, function (event)
      -- Other event, than we generate on stanza hook and so other, then we use in IO.
      if config.xmpp.jid:match(event.from) then
        -- Ignore self peps
        return
      end
      if not event.item.tags[1] then
        print(event.from.." has unset his mood.");
        return;
      end
  
      local text = event.item:get_child_text("text");
  
      if (text ~= nil and text ~= "") then
        text = " ("..tostring(text)..")";
      else
        text = "";
      end;
  
      local mood = event.item.tags[1];
      local name = mood and mood.name or nil;

      if (name ~= nil and name ~= "") then
        name = "is in "..name:gsub("%f[%W]_%f[%w]"," ").." mood";
      else
        name = "has brokenly unset his mood";
      end;
  
      print(event.from..name..text);
    end); --[[hook mood]]--
  
    xIOn.XMPP.connection:hook_pep(xmlns_activity, function (event)
      -- Other event, than we generate on stanza hook and so other, then we use in IO.
      if config.xmpp.jid:match(event.from) then
        -- Ignore self peps
        return
      end
  
      if not event.item.tags[1] then
        print(event.from.." has unset his activity.");
        return;
      end
      local text = event.item:get_child_text("text");
      if (text ~= nil and text ~= "") then
        text = " ("..tostring(text)..")";
      else
        text = "";
      end;
      local activity = event.item.tags[1];
      local extended_activity = activity and event.item.tags[1].tags[1] or nil;
      local name = activity and activity.name or nil;
      local extended_name = extended_activity and extended_activity.name or nil;
      if name ~= nil and extended_name ~= nil then
        name = " is "..name:gsub("%f[%W]_%f[%w]","")
          ..": "..extended_name:gsub("%f[%W]_%f[%w]"," ");
      elseif name ~= nil and extended_name == nil then
        name = " is "..name:gsub("%f[%W]_%f[%w]"," ");
      else
        name = " has brokenly unset his activity";
        text = "";
      end;
      print(event.from..name..text);
    end); --[[hook activity]]--
  
    xIOn.XMPP.connection:hook_pep(xmlns_tune, function (event)
      -- Other event, than we generate on stanza hook and so other, then we use in IO.
      if config.xmpp.jid:match(event.from) then
        -- Ignore self peps
        return
      end
  
      if not event.item.tags[1] then
        print(event.from.." has stopped to listening anything.");
        return;
      end
  
      local artist_tag = event.item:get_child("artist");
      local artist_text = artist_tag and artist_tag:get_text();
      local title_tag = event.item:get_child("title");
      local title_text = title_tag and title_tag:get_text();
      local source_tag = event.item:get_child("source");
      local source_text = source_tag and source_tag:get_text();
      local rating_tag = event.item:get_child("rating");
      local rating_text = rating_tag and rating_tag:get_text();
      local length_tag = event.item:get_child("length");
      local length_text = length_tag and length_tag:get_text();
      local length_num = tonumber(length_text) or 0;
      local length_min = math.floor(length_num/60);
      local length_sec = length_num%60;
      local length_min_str = tostring(length_min);
      local length_sec_str = nil;
        if length_sec < 10 then
          length_sec_str = "0"..length_sec;
        else
          length_sec_str = tostring(length_sec);
        end
      local track_tag = event.item:get_child("track");
      local track_text = track_tag and track_tag:get_text();
      local uri_tag = event.item:get_child("uri");
      local uri_text = uri_tag and uri_tag:get_text();
  
      if ((not title_text) or ((not artist_text) and (not source_text))) and (not uri_text) then
        source_text = nil;
        rating_text = nil;
        length_text = nil;
        track_text = nil;
        listening = " sent a bad Tune PEP";
      end
      if source_text or rating_text or length_text or track_text or uri_text then
      --[[
          TODO:
            * rating function (stars like ★ for full-star and ☆ for half-star instead numbers)
            * time function (years, centuries, milleniums). Take from plugin, that I wrote for Riddim.
            * localization (from Riddim too).
        ]]
--[[
    if config.xmpp.debug then
      log("debug","source",source_text)
      log("debug","uri",uri_text)
      log("debug","length",length_text)
      log("debug","track",track_text)
      log("debug","rating",rating_text)
      log("debug","artist",artist_text)
      log("debug","title",title_text)
    end
]]
          ext_lst = " ("
          ..(source_text and ("from «"..source_text.."», ") or "")
          ..(uri_text and ("URI: "..uri_text..", ") or "")
          ..(length_text and ("Length: "..length_min_str..":"..length_sec_str..", ") or "")
          ..(track_text and ("Track: "..track_text..", ") or "")
          ..(rating_text and ("Rating: "..rating_text..", ") or "")
          ..")";
        ext_lst = ext_lst:gsub(", %)", ")");
        listening = " is listening to "
        ..(title_text and (title_text
        ..(artist_text and " by "..artist_text or "")) or
        "radiostream")..ext_lst;
      end
      print(event.from..listening);
    end); --[[tune hook]]

    xIOn.XMPP.connection:hook_pep(xmlns_geoloc, function (event)
      -- Other event, than we generate on stanza hook and so other, then we use in IO.
      if config.xmpp.jid:match(event.from) then
        -- Ignore self peps
        return
      end

      if not event.item.tags[1] then
        print(event.from.." goes to nowhere.");
        return;
      end;

      local accuracy_tag = event.item:get_child("accuracy");
      local accuracy_text = accuracy_tag and accuracy_tag:get_text();
      local alt_tag = event.item:get_child("alt");
      local alt_text = alt_tag and alt_tag:get_text();
      local area_tag = event.item:get_child("area");
      local area_text = area_tag and area_tag:get_text();
      local bearing_tag = event.item:get_child("bearing");
      local bearing_text = bearing_tag and bearing_tag:get_text();
      local building_tag  = event.item:get_child("building");
      local building_text  = building_tag and building_tag:get_text();
      local country_tag = event.item:get_child("country");
      local country_text = country_tag and country_tag:get_text();
      local countrycode_tag = event.item:get_child("countrycode");
      local countrycode_text = countrycode_tag and countrycode_tag:get_text();
      local datum_tag = event.item:get_child("datum");
      local datum_text = datum_tag and datum_tag:get_text();
      local description_tag = event.item:get_child("description");
      local description_text = description_tag and description_tag:get_text();
      local error_tag = event.item:get_child("error");
      local error_text = error_tag and error_tag:get_text();
      local floor_tag = event.item:get_child("floor");
      local floor_text = floor_tag and floor_tag:get_text();
      local lat_tag = event.item:get_child("lat");
      local lat_text = lat_tag and lat_tag:get_text();
      local locality_tag = event.item:get_child("locality");
      local locality_text = locality_tag and locality_tag:get_text();
      local lon_tag = event.item:get_child("lon");
      local lon_text = lon_tag and lon_tag:get_text();
      local postalcode_tag = event.item:get_child("postalcode");
      local postalcode_text = postalcode_tag and postalcode_tag:get_text();
      local region_tag = event.item:get_child("region");
      local region_text = region_tag and region_tag:get_text();
      local room_tag = event.item:get_child("room");
      local room_text = room_tag and room_tag:get_text();
      local speed_tag = event.item:get_child("speed");
      local speed_text = speed_tag and speed_tag:get_text();
      local street_tag = event.item:get_child("street");
      local street_text = street_tag and street_tag:get_text();
      local text_tag = event.item:get_child("text");
      local text_text = text_tag and text_tag:get_text();
      local timestamp_tag = event.item:get_child("timestamp");
      local timestamp_text = timestamp_tag and timestamp_tag:get_text();
      local uri_tag = event.item:get_child("uri");
      local uri_text = uri_tag and uri_tag:get_text();

      print(event.from.."'s alt: "..(alt_text or ""));
    --[[
      TODO:
        * обработка всех тегов.
        * складывание их в базу вместо вывода в консоль.
      ]]
    end); --[[geoloc hook]]

--[[
    local function random_handler(command, event)
        local form = dataforms.new {
            title = "About you",
            { name = "first", type = "text-single", label = "First Name" },
            { name = "last", type = "text-single", label = "Last Name" },
        }
        if event.form then
            local data = form:data(event.form)
            if data.last then
                ret = {
                  info = ("Thanks mr %s"):format(data.last),
                  status = "executing";
                };
            else
                ret = {
                  form = form,
                  status = "executing";
                };
            end
            return ret;
        else
            return {
              form = form,
              status = "executing";
            };
        end
    end

  xIOn.XMPP.connection:add_adhoc_command("Submit your name", "random", random_handler);
]]--


    xIOn.XMPP.connection:hook("stanza", function (stanza)
      local body = stanza:get_child("body");
      local html_tag = stanza:get_child("html");
      local html_body = html_tag and html_tag:get_child("body");
      local event = {
        sender = { jid = stanza.attr.from };
        body = (body and body:get_text()) or nil;
        stanza = stanza;
        html = (html_body and html_body) or nil;
      };
      if stanza.name == "message" then
        if event.body then
          local cmd = event.body:sub(1,1):match("[@?*#!]");
          if not cmd then
            cmd = tostring(event.body:match("([^%s]+)"));
          end
          cmd = cmds[cmd:lower()];
          if not (type(cmd) == "function") then
            cmd = cmds["*"];
          end; --[[if cmd function]]
          cmd(event);
        end; --[[if event body]]
      end --[[if stanza message]]
    end) --[[hook stanza]]

    --xIOn.XMPP.connection:send(xIOn.XMPP.presence());
    xIOn.XMPP.connection:send(xIOn.XMPP.presence():add_child(xIOn.XMPP.connection:caps()));
	if config.xmpp.prio then
		xIOn.XMPP.connection:set_status({ prio = tostring(config.xmpp.prio) })
	end
    xIOn.XMPP.connection:publish_pep(xIOn.XMPP.stanza("tune", { xmlns = xmlns_tune })
      :tag("title"):text("Тишина"):up()
      :tag("artist"):text("Пустота"):up()
      :tag("source"):text("Небытие"):up()
      :tag("rating"):text("10"):up()
      :tag("length"):text("300"):up()
      :tag("uri"):text("http://localhost/"):up()
      :tag("track"):text("1"):up()
    );

    xIOn.XMPP.connection:publish_pep(xIOn.XMPP.stanza("mood", { xmlns = xmlns_mood })
      :tag("neutral"):up()
      :tag("text"):text("O_o"):up()
    );

    xIOn.XMPP.connection:publish_pep(xIOn.XMPP.stanza("activity", { xmlns = xmlns_activity })
      :tag("drinking"):tag("having_a_beer"):up():up()
      :tag("text"):text("Пейте пиво пенное!"):up()
    );

    xIOn.XMPP.connection:publish_pep(xIOn.XMPP.stanza("geoloc", { xmlns = xmlns_geoloc })
      :tag("room"):text("Серверная"):up()
      :tag("country"):text("Германия"):up()
      :tag("countrycode"):text("DE"):up()
    );

	--[[
    local node = xIOn.XMPP.connection.pubsub("pubsub.localhost", "princely_musings");
        node:subscribe("1111@localhost");
]]--

    xIOn.XMPP.connection:hook("presence", function (stanza)
      if stanza.attr.type ~= 'subscribe' then return nil; end
      xIOn:send_presence(stanza.attr.from, 'subscribed');
    end);

		userinfo = {};
    xIOn.XMPP.connection.roster:fetch(function(roster)
--          xIOn.XMPP.roster = roster;

	for barejid,user in pairs(roster.items) do
		userinfo[barejid] = {};
		local avatar, user_time;
		xIOn.XMPP.connection:query_time(barejid, function(rslt)
			userinfo[barejid].time = rslt and rslt.utc or 0;
		end)

		xIOn.XMPP.connection:get_vcard(barejid, function(vCard)
			local data, dtype;
			for i=1,#vCard do
				if vCard[i].name == "PHOTO" then
					data = vCard[i][1];
					data = data:gsub("\n","");
					dtype = vCard[i].TYPE[1];
					break
				end
			end
			if data then
				userinfo[barejid].avatar = 'data:'..dtype..';base64,'..data;
			else
				userinfo[barejid].avatar = 'data:image/svg+xml;base64,'..
				'PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+DQo8IS0tIENyZWF0ZWQgd2l0aCBJbmtzY2FwZSAoaHR0cDovL3d3dy5pbmtzY2FwZS5vcmcvKSAtLT4NCg0KPHN2Zw0KICAgeG1sbnM6c3ZnPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyINCiAgIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyINCiAgIHZlcnNpb249IjEuMCINCiAgIHdpZHRoPSI1NzlwdCINCiAgIGhlaWdodD0iNTc5cHQiDQogICB2aWV3Qm94PSIwIDAgNTc5IDU3OSINCiAgIGlkPSJzdmcyIj48ZGVmcw0KICAgaWQ9ImRlZnMxMiIgLz4NCjxwYXRoDQogICBkPSJNIDMyLjMwODU1MiwyODkuNjcxNDkgMjg5LjMzMDU4LDU0Ni42OTM1MiA1NDYuMzk1NDUsMjg5LjYyODY0IEMgNDYwLjY3OTc3LDIwNC4wMTA2NyAzNzUuMTMzNDQsMTE4LjIyMzA1IDI4OS4zNzM0MywzMi42NDk0ODEgTCAzMi4zMDg1NTIsMjg5LjY3MTQ5IHoiDQogICBpZD0icGF0aDQiDQogICBzdHlsZT0iZmlsbDojZmZmZmZmO3N0cm9rZTpub25lIiAvPg0KPHBhdGgNCiAgIGQ9Ik0gMTQ3LjY1OSwxNDguMDEyIDYsMjg5LjY3MiAxNDcuNjY5LDQzMS4zNCAyODkuMzI4LDU3MyA0MzEuMDE2LDQzMS4zMTIgNTcyLjcwNCwyODkuNjI0IDQzMS4wNjMsMTQ3Ljk4NCBDIDM1My4xNjYsNzAuMDg2IDI4OS40MDQsNi4zNDMgMjg5LjM3NSw2LjM0MyBjIC0wLjAyOSwwIC02My43OTksNjMuNzUzIC0xNDEuNzE2LDE0MS42NjkgeiBNIDQwOC42MjIsMTcwLjQyNSA1MjcuODIxLDI4OS42MjQgNDA4LjU3NCw0MDguODcxIDI4OS4zMjgsNTI4LjEwOCAxNzAuMTM5LDQwOC44NjIgNTAuOTQ5LDI4OS42MDYgMTcwLjEzOSwxNzAuNDE3IGMgNjUuNTU3LC02NS41NTggMTE5LjIwOCwtMTE5LjE5IDExOS4yMzcsLTExOS4xOSAwLjAyOSwwIDUzLjY4OCw1My42NDEgMTE5LjI0NiwxMTkuMTk4IHoiDQogICBpZD0icGF0aDYiDQogICBzdHlsZT0iZmlsbDojODA4MDgwO3N0cm9rZTpub25lIiAvPg0KPHBhdGgNCiAgIGQ9Im0gMjkyLjYyNSwxNDIuNDM3NSBjIC0zMC40MzgsMCAtNzUuMDkzNzUsMjAuOTcyMjUgLTc1LjA5Mzc1LDU3LjY1NjI1IDAsMTUuMzcyIDguNDQ5LDI1LjE1NjI1IDIwLjYyNSwyNS4xNTYyNSAyMS42NDQsMCAyNi4wNTk3NSwtMzQuNTkzNzUgNTQuNDY4NzUsLTM0LjU5Mzc1IDE0LjIwNCwwIDI4LjA2MjUsMTEuMTg5NSAyOC4wNjI1LDI2LjU2MjUgMCwyMC4yNjQgLTEzLjUzNDUsMjUuODQ0NSAtMjcuMDYyNSwyOS42ODc1IC0xMy44NjcsMy44NDMgLTI3LjQwNjI1LDUuOTUzMjUgLTI3LjQwNjI1LDE4LjUzMTI1IGwgMCwzNC45Mzc1IGMgMCwxMy45NzMgOS4xNTUsMjQuMDkzNzUgMjQuMzc1LDI0LjA5Mzc1IDE0LjIwNSwwIDI0LjM0Mzc1LC0xMC4xMTk3NSAyNC4zNDM3NSwtMjQuMDkzNzUgbCAwLC0xMi41OTM3NSBjIDM0LjgzNCwtOS4wODMgNTguNSwtMzEuNzgzNSA1OC41LC03MC41NjI1IDAsLTQ2LjgxNiAtMzcuMTg0NSwtNzQuNzgxMjUgLTgwLjgxMjUsLTc0Ljc4MTI1IHogbSAtMS4zNDM3NSwyMDEuNSBjIC0wLjQ5NjYxLC0xMGUtNCAtMC45ODE1LDAuMDEyMiAtMS40Mzc1LDAuMDMxMiAtNy41MDIsMC4zMjEgLTE0LjU5MDI1LDMuNTA5NzUgLTIwLjE1NjI1LDkuMDkzNzUgLTEuNjgyLDEuNjgyIC0yLjczOTUsMi45ODQ3NSAtNC4wNjI1LDQuOTY4NzUgLTMuMDcxLDQuNjIgLTQuNzQwNSw5LjEwNyAtNS41NjI1LDE1LjEyNSAtMC4xNiwxLjIxIC0wLjE3LDYuNjkwMjUgMCw4LjAzMTI1IDAuODEzLDYuNjE1IDMuMjM0LDEyLjQ2MyA3LjI1LDE3LjUgMC45NzQsMS4yMjkgMi45NTYyNSwzLjI4MTUgNC4xNTYyNSw0LjMxMjUgMy42MjgsMy4xMDggOC4wMTIyNSw1LjQzNTI1IDEyLjQwNjI1LDYuNTMxMjUgMi44NzMsMC43MTggNC4zNTk3NSwwLjg3NSA3LjQ2ODc1LDAuODc1IDMuMDYzLDAgNC42MzE3NSwtMC4xNjQ3NSA3LjM0Mzc1LC0wLjg0Mzc1IDcuMzksLTEuODQzIDE0LjAyNTUsLTYuNTk0NzUgMTguNDM3NSwtMTMuMjE4NzUgMy4yNTEsLTQuODk1IDUuMTI0LC0xMC4zMzM3NSA1LjYyNSwtMTYuMzQzNzUgMC4xMzIsLTEuNjE2IDAuMDQyOCwtNS43MDggLTAuMTU2MjUsLTcuMTI1IC0wLjU1OCwtNC4xMSAtMS41NDU3NSwtNy40NTcyNSAtMy4yMTg3NSwtMTAuOTA2MjUgLTQuNzE1LC05LjY4NiAtMTMuNzExMjUsLTE2LjM3MzI1IC0yMy45MDYyNSwtMTcuNzgxMjUgLTEuMTEyMjUsLTAuMTQ4NSAtMi42OTc2NywtMC4yNDYwNiAtNC4xODc1LC0wLjI1IHoiDQogICBpZD0icGF0aDgiDQogICBzdHlsZT0iZmlsbDojNDA0MDQwO3N0cm9rZTpub25lIiAvPg0KPC9zdmc+DQo=';
			end
		end)
	end

	end);

end); --[[ xIOn.XMPP.connection:hook ]]

end

return xIOn;
