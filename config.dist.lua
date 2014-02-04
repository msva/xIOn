-- write all config variables in lowercase

--[[
JID:
	If using component mode, then JID should be without resource. Otherwise — with it.
PASSWORD:
	obviously, jid's password;
]]--

--[[
MODE:
	use "client" for "bot" mode.
	and "component" for "component" aka "transport" mode.
]]--
mode = "client";

--[[
DEBUG:
	true for enable debug and false for disable
]]--
debug = true;

--[[
LANGUAGE:
	bot's default language
]]--
language = "ru";


--[[
LIB_PLUGINS:
	list (table) of Verse's plugins, that will be loaded on bot's start
	sometimes load order is required
]]--
lib_plugins = {
  "presence",
  "receipts",
  "uptime",
  "roster",
--  "groupchat", -- MUC
--  "private", -- XML Storage
  "vcard",
  "vcard_update",
  "disco", --[[ BEFORE ADHOC!!! ]]
  "adhoc",
--  "blocking",
--  "jingle",
--  "jingle_ibb",
--  "jingle_s5b",
--  "jingle_ft",
--  "proxy65",
  "ping",
  "pubsub",
  "version",
  "pep",
  "time"
}
