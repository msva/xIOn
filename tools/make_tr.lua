local trname = "general";
local in_filename = arg[1];
local out_filename, out_file;
local in_file = assert(io.input(in_filename))
local lll = {};
for line in in_file:lines() do
	for name in line:gmatch([=[l10n['"].init%(['"](.*)['"]%)]=]) do
		trname = name;
		lll[trname] = {};
	end;
	for lq,tr,rq,plur in line:gmatch([=[tr%((['"])(.-[^\])(%1),?%s?(.-)%)]=]) do
		if #plur>0 then
			lll[trname][tr..'%1'] = [=[[]=]..lq..tr.."%1"..rq..[=[]]=];
			lll[trname][tr..'%2'] = [=[[]=]..lq..tr.."%2"..rq..[=[]]=];
			lll[trname][tr..'%5'] = [=[[]=]..lq..tr.."%5"..rq..[=[]]=];
		else
			lll[trname][tr] = [=[[]=]..lq..tr..rq..[=[]]=];
		end
	end;
end;

if pcall(io.close,in_file) then
	print("File "..in_filename.." successfully parsed.")
else
	print("Something crappy happened when translation generator tried to close "..in_filename..".")
end

for tn,tr in pairs(lll) do
	out_filename="locales/templates/"..tn..".lua";
--	out_file=assert(io.output(out_filename))
	io.write("return {",'\n');
for n,line in pairs(tr) do
	io.write(line..' = "";','\n');
end;
	io.write("}",'\n');
--	if pcall(io.close,out_file) then
--		print("Translation for "..tn.." has been successfully written!");
--	else
--		print("Something weird is occurred! Please, check, if translation for "..tn.." written correctly.")
--	end
end;
