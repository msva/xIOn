if not xIOn then
  error[[You should include core.xIOn, but not libs.DB directly, to use DB object]]
end

xIOn.DB = {}; --TODO: db-module
local psto = require "plugins.psto";

function xIOn.DB:write_post(post)
  --[[ TODO:
      write post in DB.
      xIOn:user_options(psto_notation)
  ]]--
  post.id = ("%x"):format(os.date("%s"))..tostring(math.random(97,122)):char();
  --math.random(10000000);
  return post
end;

function xIOn.DB:read_post(post)
  --[[ TODO:
      read post from DB.
      xIOn:user_options(psto_notation)
  post.id = psto(post.id);
  ]]--
  return post
end;

function xIOn.DB:is_subscribed(sender, post)
  return ((math.random(2) > 1) and true or false);
end;

return xIOn.DB;
