local p = {}

p.parse = function(raw)
  local data = {}
  local cur_level = 0
  local link = {}  -- buffer for current parents' link
  local anchor = ""  -- last anchor to be added
  for i, line in ipairs(raw) do
    local _, level = string.gsub(line, '\t', "")  -- count level by tab
    if not level then level = 0 end
    local first_token_in_line = true
    for token in string.gmatch(line, "%[[%a%d_: ]+%]") do

      l, r = token:find("%[[%a_]+")
      attr = token:sub(l+1, r)  -- acquire attr
      l, r = token:find(':.*]')  -- find the end of token
      if l then
        val = token:sub(l+1, r-1)  -- get val, without the first charcter (: or ])
      else
        val = ""  -- token with no value
      end

      -- preprocessing
      -- add item (attr - val) to database
      if attr == "OBJECT" then
        data.val = val
        break  -- directly move to next line
      end
      if level == 0 then
        if attr == data.val then  -- basic item
          attr = val
          val = ""
          link = {}  -- clear link list
        else  -- not basic item, absent tab appears
          level = 1
        end
      end
      if (not first_token_in_line) and (not attr == anchor) then  -- neither the first token in line nor the same as before
        level = level -  1  -- reset level to higher level
      end

      -- processing link list
      if level > cur_level then  -- lower level, add last anchor to link
        table.insert(link, anchor)
      elseif level < cur_level then  -- rollback to higher level
        for _ = level, cur_level-1 do
          table.remove(link, #link)  -- rollback to the level on the top
        end
      end

      -- plug token into database
      local cursor = p.fw_link(data, link)
      attr = p.plug_value(cursor, attr, val)
      anchor = attr -- reset the anchor

      first_token_in_line = false  -- no longer the first one
      cur_level = level  -- reset level buffer
      -- print(attr, val, level, anchor, p.dump(link)) 
    end
  
  -- if i > 50 then break end
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

p.is_color = function( a, b, c )
  if tonumber(a) and tostring(a):len() == 1 then
    if tonumber(b) and tostring(b):len() == 1 then
      if tonumber(c) and tostring(c):len() == 1 then
        return true
      end
    end
  end
  return false
end

p.plug_value = function(cursor, attr, value)

  -- check if multiple values exist
  local val = value
  if string.find(val, ':') then  -- colon still exists
    local val_table = {}  -- store separated value
    while #val > 0 do
      local _, r = string.find(val, "[%a%d_ ]+")  -- usually the left one is 1
      if r then
        table.insert(val_table, string.sub(val, 1, r))
        val = val:sub(r+2)
      end
    end
    val = val_table

    -- check color string
    local i = 1
    while #val >2 and i<=#val do
      if p.is_color(val[i], val[i+1], val[i+2]) then
        val[i] = val[i] .. ':' .. val[i+1] .. ':' .. val[i+2]
        table.remove(val, i+2)
        table.remove(val, i+1)
      end
      i = i+1
    end
    -- if only one element, reset to single val
    if #val == 1 then val = val[1] end
  end

  -- check template
  local key = attr
  if key == 'USE_MATERIAL_TEMPLATE' then
    key = key .. '/' .. val[1]  -- connect the key with the template type
    table.remove(val, 1) -- remove template type name from table
  end

  -- plug in key-val pair
  cursor[key] = {}
  cursor[key].val = val 
  cursor[key].tab = {}
  return key  -- for modification
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
p.dump = function(value, call_indent, compress)
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
          output = output .. ","
          if not compress then output = output .. "" end
        else
          first = false
        end
        if not compress then
          output = output .. "\n" .. indent
        end
        local equal = "="
        if not compress then equal = " = " end
        output = output  .. '["' .. inner_key .. '"]' .. equal .. p.dump ( inner_value, indent, compress ) 
      end
      if not compress then
        output = output ..  "\n" .. call_indent
      end
      output = output .. "}"
  elseif type (value) == "userdata" then
    output = "userdata"
  else 
    if tonumber(value) or not value then output = value
    else output = '"' .. value .. '"' end
  end
  return output 
end

return p
