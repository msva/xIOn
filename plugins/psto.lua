return function (num)
	local digits = {
		["1"] = "o";
		["2"] = "t";
		["3"] = "h";
		["4"] = "f";
		["5"] = "i";
		["6"] = "s";
		["7"] = "e";
		["8"] = "g";
		["9"] = "n";
		["0"] = "z";
	};
	local postnum = "";
	for d = 1,string.len(num) do
		postnum = postnum..digits[string.sub(num,d,d)];
	end;
	return postnum;
end;
