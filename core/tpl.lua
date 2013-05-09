-- xIOn Miniblog service
-- Copyright (C) 2012 Vadim A. Misbakh-Soloviov
--
-- This project is GPLv3+ licensed.
-- Some code solutions is inspired by Prosody project
-- by Matthew Wild, Waqas Hussain, Kim Alvefur and me.
--

if not config then
  print[[It is error in configuration]]
  return 1;
end

local type = type;
local loadfile = loadfile;
local assert = assert;
local setfenv = setfenv;
local pairs = pairs;
local package = package;
local xIOn = _G.xIOn;
local log = require "util.logger".init("template_engine");
local lfs = require("lfs");

local templates_cache = {};
local source_path = (xIOn and xIOn.paths and xIOn.paths.source) or ".";
local templates_path = source_path.."/templates/"

module("tpl");

local function checks(template)
    if (type(template) ~= "string") then
      log("error","Bad template is called (not even the string)")
    end;
    if (not lfs.attributes(templates_path..template..".lua")) then
      log("error","I can't find any useful template with requested name ("..template..")!");
    end;
    return template;
end;

local function tpl_load(tpl_name, block)
    local tpl_name = checks(tpl_name);
    local template = (templates_cache and templates_cache[tpl_name]) or nil;
    if template then
        return template[block];
    end;
    local func = assert(loadfile(templates_path..tpl_name..".lua"));
    setfenv(func, {});
    template = func();
    if type(template) ~= "table" then
        log("error","Broken '"..tpl_name.."' template!");
    end;
    templates_cache[tpl_name] = {};
    templates_cache[tpl_name] = template;
    log("info","Successfully loaded '%s' template", tpl_name);
    return template[block];
end;

local function placeholders(block)
  if (type(block) ~= "string") then
    log("error","We just rendered broken block (type: %s)!",type(block));
    return "";
  end
  return block:gsub("__VAR:([%a_]+)__",_S);
end

local function render(block)
    local rendered;
    local tpl_name = tpl;
    rendered = placeholders(tpl_load(tpl_name, block))
    if not rendered then
      log("error","Broken '%s' template!", tpl_name);
    end;
    return rendered or block;
end;

function init(name, exchange)
    tpl = name;
    _S = exchange;
    return render;
end;

local function reload_templates_cache()
    for tpl_name in pairs(templates_cache) do
      local tpl_name = checks(tpl_name);
      local func = assert(loadfile(templates_path..tpl_name..".lua"));
      setfenv(func, {});
      templates_cache[tpl_name] = func();
      log("info","Successfully reloaded templates cache");
    end;
end;

if xIOn and xIOn.events then
    xIOn.events.add_handler("config-reloaded", reload_templates_cache);
end;

return _M;
