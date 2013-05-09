local os = os;
local print = print;

module("checks")

function fatal(var, error_text, error_ext_text)
  if not var then
    if error_ext_text then
      error_text = error_text..(error_ext_text or "Undefined error")
    end
    print(error_text or "Undefined error")
    os.exit(1)
  end
end;


return _M;