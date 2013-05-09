--[[
  Inspired by: http://xkcd.org/1179/
]]

function unix2period_string(value)
--[[ Timestamp to translated string ]]
  local timeDiff = function(t2,t1)
    local d1,d2,carry,diff = os.date('*t',t1),os.date('*t',t2),false,{}
    local colMax = {60,60,24,os.date('*t',os.time{year=d1.year,month=d1.month+1,day=0}).day,12}
    d2.hour = d2.hour - (d2.isdst and 1 or 0) + (d1.isdst and 1 or 0) -- handle dst
    for i,v in ipairs({'sec','min','hour','day','month','year'}) do
      diff[v] = d2[v] - d1[v] + (carry and -1 or 0)
      carry = diff[v] < 0
      if carry then diff[v] = diff[v] + colMax[i] end
    end
    return diff
  end;

  local td=timeDiff(value,0);
  upt=td.sec.." "..tr("second",td.sec);
  if td.min>0 then upt=td.min.." "..tr("minute",td.min)..tr(" and ")..upt; end;
  if td.hour>0 then upt=td.hour.." "..tr("hour",td.hour)..", "..upt; end;
  if td.day>0 then upt=td.day.." "..tr("day",td.day)..", "..upt; end;
  if td.month>0 then upt=td.month.." "..tr("month",td.month)..", "..upt; end;
  if td.year>0 then upt=td.year.." "..tr("year",td.year)..", "..upt; end;
  return upt;
end
