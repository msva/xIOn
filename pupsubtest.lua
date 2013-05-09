#!/usr/bin/env luajit
local jid, password = "1111@localhost/2222", "1111";
require "verse".init("client"); -- XMPP client library
c = verse.new();
c:add_plugin("uptime");
c:add_plugin("roster");
--c:add_plugin("groupchat");
c:add_plugin("private");
c:add_plugin("vcard");
c:add_plugin("vcard_update");
--c:add_plugin("adhoc");
--c:add_plugin("blocking");
--c:add_plugin("jingle");
--c:add_plugin("jingle_ibb");
--c:add_plugin("jingle_s5b");
--c:add_plugin("jingle_ft");
--c:add_plugin("proxy65");
c:add_plugin("ping");
c:add_plugin("pubsub");
c:add_plugin("version");
c:add_plugin("disco");
c:add_plugin("pep");
c:add_plugin("time");
c:hook("authentication-failure", function (err) print("Failed to log in! Error: "..tostring(err.condition)); end);
c:hook("disconnected", function () print("Disconnected!"); os.exit(); end);
--c.connect_host = "::1";
--c.connect_host = "2a01:4f8:150:3fff::10";
--c.connect_port = "5222";
enable_debug = true;
if enable_debug then
	verse.set_log_handler(print);
	c:hook("outgoing-raw", print, math.huge);
	c:hook("incoming-raw", print, math.huge);
end

local xmlns_base = "http://jabber.org/protocol";
local xmlns_disco = xmlns_base.."/disco";
local xmlns_disco_info = xmlns_disco.."#info";
local xmlns_disco_items = xmlns_disco.."#items";
local xmlns_version = "jabber:iq:version";
local xmlns_time = "urn:xmpp:time";
local xmlns_caps = xmlns_base.."/caps";
local xmlns_mood = xmlns_base.."/mood";
local xmlns_activity = xmlns_base.."/activity";
local xmlns_tune = xmlns_base.."/tune";
local xmlns_geoloc = xmlns_base.."/geoloc";
local xmlns_tune_notify = xmlns_tune.."+notify";
local xmlns_mood_notify = xmlns_mood.."+notify";
local xmlns_activity_notify = xmlns_activity.."+notify";
local xmlns_geoloc_notify = xmlns_geoloc.."+notify";

local identity = {category = 'client', type='bot', name='MoonTalk'};

c.version:set{ name = "MoonTalk", version = "0.0.1", platform = "LuaJIT" };
c:set_identity(identity)
c.caps.node = 'http://mva.name/MoonTalk/'

c:add_disco_feature(xmlns_geoloc_notify)

c:connect_client(jid, password);

c:hook("ready", function ()
	c:hook_pep(xmlns_mood, function (event)
		if not event.item.tags[1] then
			print(event.from.." has unset his mood.");
			return;
		end

		local text = event.item:get_child_text("text");
		if (text ~= nil and text ~= "") then text = " ("..tostring(text)..")"; else text = ""; end;
		local mood = event.item.tags[1];
		local name = mood and mood.name or nil;
		if (name ~= nil and name ~= "") then name = " is in "..name:gsub("%f[%W]_%f[%w]"," ").." mood"; else name = " has brokenly unset his mood"; end;
		print(event.from..name..text);
	end);

	c:hook_pep(xmlns_activity, function (event)
		if not event.item.tags[1] then
			print(event.from.." has unset his activity.");
			return;
		end

		local text = event.item:get_child_text("text");
		if (text ~= nil and text ~= "") then text = " ("..tostring(text)..")"; else text = ""; end;
		local activity = event.item.tags[1];
		local extended_activity = activity and event.item.tags[1].tags[1] or nil;
		local name = activity and activity.name or nil;
		local extended_name = extended_activity and extended_activity.name or nil;
		if name ~= nil and extended_name ~= nil then
			name = " is "..name:gsub("%f[%W]_%f[%w]", " ")..": "..extended_name:gsub("%f[%W]_%f[%w]"," ");
		elseif name ~= nil and extended_name == nil then
			name = " is "..name:gsub("%f[%W]_%f[%w]"," ");
		else
			name = " has brokenly unset his activity";
			text = "";
		end;
		print(event.from..name..text);
	end);

	c:hook_pep(xmlns_tune, function (event)
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
			if length_sec < 10 then length_sec_str = "0"..length_sec; else length_sec_str = tostring(length_sec); end
		local track_tag = event.item:get_child("track");
		local track_text = track_tag and track_tag:get_text();
		local uri_tag = event.item:get_child("uri");
		local uri_text = uri_tag and uri_tag:get_text();

		if ((not title_text) or (not artist_text)) and (not uri_text) then
			source_text = nil;
			rating_text = nil;
			length_text = nil;
			track_text = nil;
			listening = "Send a bad Tune PEP";
		end
		if source_text or rating_text or length_text or track_text or uri_text then
			--[[
			TODO:
				* rating fuction (stars like ★ for full-star and ☆ for half-star instead numbers)
				* time fuction (years, centuries, milleniums). Take from plugin, that I wrote for Riddim.
				* localization (from Riddim too).
			]]
			ext_lst = " ("..
				(source_text and ("from «"..source_text.."», ") or "")..
				(uri_text and ("URI: "..uri_text..", ") or "")..
				(length_text and ("Length: "..length_min_str..":"..length_sec_str..", ") or "")..
				(track_text and ("Track: "..track_text..", ") or "")..
				(rating_text and ("Rating: "..rating_text..", ") or "")..
			")";
			ext_lst = ext_lst:gsub(", %)", ")");
			listening = " listening to "..(title_text and (title_text..(artist_text and " by "..(artist_text or ""))) or "radiostream")..ext_lst;
		end
		print(event.from..listening);
	 end);

	c:hook_pep(xmlns_geoloc, function (event)
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
	end);



	c:send(verse.presence());
	c:publish_pep(verse.stanza("tune", { xmlns = xmlns_tune })
		:tag("title"):text("Тишина"):up()
		:tag("artist"):text("Пустота"):up()
		:tag("source"):text("Небытие"):up()
		:tag("rating"):text("10"):up()
		:tag("length"):text("300"):up()
		:tag("uri"):text("http://localhost/"):up()
		:tag("track"):text("1"):up()
	);

	c:publish_pep(verse.stanza("mood", { xmlns = xmlns_mood })
		:tag("neutral"):up()
		:tag("text"):text("O_o"):up()
	);

	c:publish_pep(verse.stanza("activity", { xmlns = xmlns_activity })
		:tag("drinking"):tag("having_a_beer"):up():up()
		:tag("text"):text("Пейте пиво пенное!"):up()
	);

	c:publish_pep(verse.stanza("geoloc", { xmlns = xmlns_geoloc })
		:tag("room"):text("Серверная"):up()
		:tag("country"):text("Германия"):up()
		:tag("countrycode"):text("DE"):up()
	);

--	c:query_time("mva@pirate-party.ru/Psi+", function(rslt)
--			print("TZO: "..rslt.offset);
--			print("TS: "..rslt.utc);
--	 end)
        local node = c.pubsub("pubsub.localhost", "princely_musings");
        node:subscribe("1111@localhost");
end);
verse.loop()