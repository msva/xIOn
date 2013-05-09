#!/usr/bin/env lua
--[[
TODO: make it to work with LuaJIT2! ;)
]]

local NOCOLOR=os.getenv("NOCOLOR");
local colors, ENDCOL, COLS, NCLB, LB;

if NOCOLOR == 0 or NOCOLOR == "false" or NOCOLOR == "no" then
	NOCOLOR = nil
end

local function unset_colors()
	colors = {
		black = '';
		red = '';
		green = '';
		yellow = '';
		blue = '';
		magenta = '';
		cyan = '';
		white = '';

		black_bg = '';
		red_bg = '';
		green_bg = '';
		yellow_bg = '';
		blue_bg = '';
		magenta_bg = '';
		cyan_bg = '';
		white_bg = '';

		black_inv = '';
		red_inv = '';
		green_inv = '';
		yellow_inv = '';
		blue_inv = '';
		magenta_inv = '';
		cyan_inv = '';
		white_inv = '';

		black_bg_inv = '';
		red_bg_inv = '';
		green_bg_inv = '';
		yellow_bg_inv = '';
		blue_bg_inv = '';
		magenta_bg_inv = '';
		cyan_bg_inv = '';
		white_bg_inv = '';

		bold = '';
		underline = '';
		blink = '';
		reveerse = '';
		invisible = '';

		good = '';
		warn = '';
		bad = '';
		highlight = '';
		brackets = '';
		normal = '';
		none = normal;
	}

	LB = '\n';
	NCLB = '';
	COLS = 80;
	ENDCOL = '';
end

local function set_colors()
	colors = {
		black = '\27[30m';
		red = '\27[31m';
		green = '\27[32m';
		yellow = '\27[33m';
		blue = '\27[34m';
		magenta = '\27[35m';
		cyan = '\27[36m';
		white = '\27[37m';

		black_bg = '\27[40m';
		red_bg = '\27[41m';
		green_bg = '\27[42m';
		yellow_bg = '\27[43m';
		blue_bg = '\27[44m';
		magenta_bg = '\27[45m';
		cyan_bg = '\27[46m';
		white_bg = '\27[47m';

		black_inv = '\27[90m';
		red_inv = '\27[91m';
		green_inv = '\27[92m';
		yellow_inv = '\27[93m';
		blue_inv = '\27[94m';
		magenta_inv = '\27[95m';
		cyan_inv = '\27[96m';
		white_inv = '\27[97m';

		black_bg_inv = '\27[100m';
		red_bg_inv = '\27[101m';
		green_bg_inv = '\27[102m';
		yellow_bg_inv = '\27[103m';
		blue_bg_inv = '\27[104m';
		magenta_bg_inv = '\27[105m';
		cyan_bg_inv = '\27[106m';
		white_bg_inv = '\27[107m';

		bold = '\27[1m';
		underline = '\27[4m';
		blink = '\27[5m';
		reverse = '\27[7m';
		invisible = '\27[8m';

		good = '\27[32;01m';
		warn = '\27[33;01m';
		bad = '\27[31;01m';
		highlight = '\27[36;01m';
		brackets = '\27[34;01m';
		normal = '\27[m';
		none = normal
	}

	LB = '\n';
	NCLB = LB;
	COLS=tonumber(os.getenv("COLUMNS")) or 0;
	if COLS == 0 then
		COLS = tonumber(io.popen("(set -- $((stty size </dev/tty) || echo 24 80); echo $2) 2>/dev/null"):read());
		COLS = (COLS and COLS > 0 and COLS or 80);
	end
        ENDCOL="\27[A\27["..(COLS-8).."C"
end

if not NOCOLOR then
	set_colors();
else
	unset_colors();
end

local function cat(...)
	local ag = '';
	for a=1,#arg do
		ag = ag .. arg[a] or '';
	end
	return ag;
end

function norm(...)
	return(colors.normal..cat(...))
end

function good(...)
	return(colors.good..cat(...)..colors.normal)
end

function warn(...)
	return(colors.warn..cat(...)..colors.normal)
end

function bad(...)
	return(colors.bad..cat(...)..colors.normal)
end

function brackets(...)
	return(colors.brackets..'[ '..colors.normal..cat(...)..colors.brackets..' ]'..colors.normal)
end

function status_brackets(...)
	ret = cat(...)
	local ENDCOL = ENDCOL;
	if ENDCOL == "" then
		for c=1,COLS-#ret-16 do
			ENDCOL = ENDCOL.." ";
		end
	else
		ENDCOL="\27[A\27["..(COLS-#ret-6).."C"
	end

	return(NCLB..ENDCOL..colors.brackets..'[ '..colors.normal..ret..colors.brackets..' ]'..colors.normal)
end

function highlight(...)
	return(colors.highlight..cat(...)..colors.normal)
end

function einfo(...)
	local LB = LB;
	for a=1,#arg do
		if a == #arg then
			LB = NCLB;
		end
--		io.write(colors.good,"*",colors.normal," ",arg[a],LB)
		io.write(good("*")," ",arg[a],LB)
	end
end

function ewarn(...)
	local LB = LB;
	for a=1,#arg do
		if a == #arg then
			LB = NCLB;
		end
		io.write(warn("*")," ",arg[a],LB)
--		io.write(colors.warn,"*",colors.normal," ",arg[a],LB)
	end
end

function eerror(...)
	local LB = LB;
	for a=1,#arg do
		if a == #arg then
			LB = NCLB;
		end
		io.write(bad("*")," ",arg[a],LB)
--		io.write(colors.bad,"*",colors.normal," ",arg[a],LB)
	end
end

ebegin = einfo

local function _eend(retval,efunc,...)
	local msg;

	if ENDCOL == "" then
		for c=1,COLS-21 do
			ENDCOL = ENDCOL.." ";
		end
	end

	if retval == 0 then
		msg=brackets(good("ok"));
--		msg=colors.brackets.."[ "..colors.good.."ok"..colors.brackets.." ]"..colors.normal;
	else
		msg=brackets(bad("!!"));
--		msg=colors.brackets.."[ "..colors.bad.."!!"..colors.brackets.." ]"..colors.normal;
		if efunc then
			io.write(NOCOLOR and '\n' or '');
			efunc(...)
		end
	end

	io.write(ENDCOL,msg,"\n");
	os.exit(retval)
end

function eend(retval,...)
	local retval = retval or 0;

	_eend(retval,eerror,...)
end

function die(...)
	eerror(...)
	os.exit(1)
end
