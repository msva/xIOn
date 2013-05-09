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
local log = require "util.logger".init("l10n");
local lfs = require("lfs");

local translations_cache = {};
local source_path = (xIOn and xIOn.paths and xIOn.paths.source) or ".";

local language = language or config.language or "ru";
local fallback_language = fallback_language or config.fallback_language or "en";
local d_mod =  "general";
local g_mod;
module("l10n");

local function get_langpath(lang, mod)
	local lang = lang;
	local mod = mod or d_mod;
	local path_separator = assert(package.config:match("^([^\n]+)") , "package.config not in standard form")
	local path = source_path.."/".."locales".."/"..lang.."/"..mod..".lua";
        path = path:gsub("/", path_separator);
	return path;
end;

local function checks(lang, mod)
	local lang = lang;
	local mod = mod;
	if (type(lang) ~= "string") then
		lang = fallback_language;
	end;
--[[
	if (lfs.attributes(get_langpath(lang, g_mod))) then
		mod = g_mod;
	end;
]]
	if (type(fallback_language) ~= "string") then
		lang = "en";
	end;
	if (not lfs.attributes(get_langpath(lang, mod))) then
		lang = "en";
		mod = d_mod;
		if (not lfs.attributes(get_langpath(lang, mod))) then
			log("error","I can't find any useful translations!")
		end;
	end;
	return lang, mod;
end;

local function localize(lang, mod, text)
	local lang, mod = checks(lang, mod);
	local translation = (translations_cache and translations_cache[lang] and translations_cache[lang][mod]) or nil;
	if translation then
		return translation[text];
	end;
	local func = assert(loadfile(get_langpath(lang, mod)));
	setfenv(func, {});
	translation = func();
	if type(translation) ~= "table" then
		log("error","Broken '"..lang.."' translation!");
	end;
	translations_cache[lang] = {};
	translations_cache[lang][mod] = translation;
	log("info","Successfully loaded '%s' translation", lang);
	return translation[text];
end;

local function tr(text, num)
	local translated;
	local lang, mod = language, g_mod;
-- checks(language, g_mod)
	if not num then
		translated = localize(lang, mod, text);
		translated = translated or localize(lang, d_mod, text);
		translated = translated or localize(fallback_language, mod, text);
		translated = translated or localize(fallback_language, d_mod, text);
		if not translated then
			log("error","Broken '"..lang.."' translation!");
		end;
	else
		if language == "en" then
			numeric = text..(num ~= 1 and "%2" or "%1");	-- in English all plural numeric endings are "s" (?)
		else
		-- Possibly, working only for Russian. Needs testing and rewriting to work with other languages, if so.
			if num%10 == 1 and not (num >= 11 and num <= 14) then numeric = text.."%1"; end;
			if num%10 > 1 and num%10 < 5 and not (num >= 11 and num <= 14) then numeric = text.."%2"; end;
			if num%10 == 0 or num%10 >= 5 or (num >= 11 and num <= 14) then numeric = text.."%5"; end;
			translated = localize(lang, mod, numeric) or localize(lang, d_mod, numeric) or localize(fallback_language, mod, numeric) or localize(fallback_language, d_mod, numeric);
		end;

	end;
	return translated or text;
end;

function init(name)
	g_mod = name;
	return tr;
end;

local function reload_translations_cache()
	for lang in pairs(translations_cache) do
		for mod in pairs(lang) do
			local lang, mod = checks(lang, mod);
			local func = assert(loadfile(get_langpath(lang, mod)));
			setfenv(func, {});
			translations_cache[lang][mod] = func();
			log("info","Successfully reloaded translation cache for module '%s' in locale '%s'", mod, lang);
		end;
	end;
end;
if xIOn and xIOn.events then
	xIOn.events.add_handler("config-reloaded", reload_translations_cache);
end;

return _M;
