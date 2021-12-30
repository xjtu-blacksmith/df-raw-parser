local p = {}

p.parse = function(raw)
  local data = {}
  local cur_level = 0
  local link = {}  -- buffer for current parents' link
  for i, line in ipairs(raw) do
    if string.match(line, "%[[%a%d_: ]+%]") then
      local _, level = string.gsub(line, '\t', "")  -- count level by tab
      if not level then level = 0 end
      l, r = string.find(line, "%[[%a_]+")
      attr = string.sub(line, l+1, r)  -- acquire attr
      line = line:sub(r+2)  -- remove attr
      l, _ = string.find(line, ']')  -- find the end of token
      if l then
        val = string.sub(line, 1, l-1)  -- get val
      else
        val = ""  -- token with no value
      end
      if level == 0 then
        if attr == "OBJECT" then
          data.val = val  -- database property
        else
          data[val] = {}
          data[val].val = "" -- not attributes
          data[val].tab = {} -- a new item list
          link = { val }  -- recover link list
        end
      elseif level >= cur_level then
        local cursor = p.fw_link(data, link)
        p.plug_value(cursor, attr, val)
        if not level == cur_level then table.insert(link, attr) end
      else -- rollback to lower level
        for _ = level+1, cur_level-1 do
          table.remove(link, #link)  -- rollback to the level on the top
        end
        local cursor = p.fw_link(data, link)
        p.plug_value(cursor, attr, val)
        table.insert(link, attr) -- add link
      end
      cur_level = level  -- reset level buffer
    end
  end
  return data
end

p.fw_link = function(data, link)
  local cursor = data
  for i = 1, #link do
    cursor = cursor[link[i]].tab
  end
  return cursor
end

p.plug_value = function(cursor, attr, val)
  local str = val
  if string.find(str, ':') then  -- colon still exists
    local val_table = {}  -- store separated value
    while #str > 0 do
      local _, r = string.find(str, "[%a%d_ ]+")  -- usually the left one is 1
      if r then
        table.insert(val_table, string.sub(str, 1, r))
        str = str:sub(r+2)
      end
    end
    str = val_table
  end
  -- check color string
  local i = 1
  while #str>2 and i<=#str do
    if tonumber(str[i]) and tonumber(str[i+1]) and tonumber(str[i+2]) then
      str[i] = str[i] .. ':' .. str[i+1] .. ':' .. str[i+2]
      table.remove(str, i+1)
      table.remove(str, i+1)
    end
    i = i+1
  end
  cursor[attr] = {}
  cursor[attr].val = str
  cursor[attr].tab = {}
end

p.read_file = function(path)
  local texts = {}
  for line in io.lines(path) do
    table.insert(texts, line)
  end
  return texts
end

-- source: <https://www.tutorialspoint.com/how-to-split-a-string-in-lua-programming>
p.split = function(input, sep)
  if sep == nil then
      sep = "%s"
   end
   local t = {}
   for str in string.match(input, "([^" .. sep .. "]+)") do
      table.insert(t, str)
   end
   return t
end

-- source: <https://stackoverflow.com/a/55653719>
p.dump = function(value, call_indent)
  if not call_indent then 
    call_indent = ""
  end
  local indent = call_indent .. "  "
  local output = ""
  if type(value) == "table" then
      output = output .. "{"
      local first = true
      for inner_key, inner_value in pairs ( value ) do
        if not first then 
          output = output .. ", "
        else
          first = false
        end
        output = output .. "\n" .. indent
        output = output  .. inner_key .. " = " .. p.dump ( inner_value, indent ) 
      end
      output = output ..  "\n" .. call_indent .. "}"
  elseif type (value) == "userdata" then
    output = "userdata"
  else 
    output =  value
  end
  return output 
end

return p
