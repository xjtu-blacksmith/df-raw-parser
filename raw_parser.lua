local p = {}

p.parse = function(raw, dict, given_data)
  local data = given_data
  if not data then  -- data not given, create from empty table
    data = {}
  end
  -- local cur_level = 0
  local link = {}  -- buffer for current parents' link
  local anchor = ""  -- last anchor to be added
  local type = ""
  local entry = ""
  local parent = ""  -- for sub_tokens
  local parent_key = ""
  for i, line in ipairs(raw) do
    local heading_space = string.match(line, "^%s+")
    if not heading_space then heading_space = "" end
    -- local _, level = string.gsub(heading_space, '\t', "")  -- count level by tab
    -- if not level then level = 0 end
    for token in string.gmatch(line, "%[[^%]]+%]") do

      l, r = token:find("%[[^:%]]+")
      attr = token:sub(l+1, r)  -- acquire attr
      l, r = token:find(':.*]')  -- find the end of token
      if l then
        val = token:sub(l+1, r-1)  -- get val, without the first charcter (: or ])
      else
        val = "TRUE"  -- token with no value, just indicate exists
      end

      -- preprocessing
      -- add item (attr - val) to database
      if attr == "OBJECT" then
        type = val
        break  -- directly move to next line
      end
      
      -- entry name
      if attr == type then
        attr = val
        val = type  -- set value as item type
        entry = attr
        data[attr] = {}
        parent = "" -- clear parent token
        break
      end

      -- plug token into database
      if p.is_token(dict, attr) then
        local is_parent = false
        if not (next(dict[attr]) == nil) then
          is_parent = true
        end
        -- only update parent key when it has sub-tokens
        if is_parent then
          parent = attr
          parent_key = p.plug_value(data[entry], attr, val, true)
        else
          p.plug_value(data[entry], attr, val) -- do not update parent_keys
        end
      elseif p.is_token(dict, attr, parent) then
        p.plug_value(data[entry][parent_key], attr, val)  -- sub-token cannot be parent
      else
        print('[WARNING] ' .. attr .. ' is not reconized, ignore')
      end

      -- print(attr, val, parent) 
    end
  
  -- if i > 50 then break end
  end
  return data
end

p.is_token = function(dict, token, parent)
  if dict[token] then
    return true
  elseif parent then
    if (not (parent == "")) and dict[parent][token] then
      return true
    end
  end
  return false
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

p.plug_value = function(cursor, attr, value, is_parent)

  -- check if multiple values exist
  local val = value
  if string.find(val, ':') then  -- colon still exists
    local val_table = {}  -- store separated value
    while #val > 0 do
      local _, r = string.find(val, "[^:%]]+")  -- usually the left one is 1
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
  end

  -- check template
  local key = attr
  -- key names to reduce redundancy
  local special_keys = {
    ['USE_MATERIAL_TEMPLATE'] = 2,
    ['STATE_NAME_ADJ'] = 1,
    ['GROWTH'] = 1,
    ['METAL_ORE'] = 2,
  }
  -- key names to make list
  local list_keys = { 'ENVIRONMENT' }
  for special_key, sp_idx in pairs(special_keys) do
    if key == special_key then
      if type(val) == 'string' then
        key = key .. '/' .. val
      else
        key = key .. '/' .. val[sp_idx]  -- connect the key with the template type
        table.remove(val, sp_idx) -- remove template type name from table
      end
      break
    end
  end
  for i, list_key in ipairs(list_keys) do
    if key == list_key then
      if not cursor[key] then
        cursor[key] = {}
      end
      cursor = cursor[key]
      if type(val) == 'string' then
        key = val
        val = 'TRUE'
      else
        key = val[1]
        table.remove(val, 1)
      end
    end
  end

  -- if only one element, reset to single val
  if type(val) == 'table' and #val == 1 then
    val = val[1]
  end

  -- plug in key-val pair
  -- check multiple definition
  if not cursor[key] then
    if is_parent then
      cursor[key] = {}  -- create a table first
      cursor[key].THIS = val -- the value of token itself is store in THIS
    else
      cursor[key] = val -- no sub-tokens, just plug in the value
    end
  else -- key already exists, multiple values
    local cursor2 = cursor[key]
    if is_parent then
      cursor2 = cursor2.THIS
    end
    if type(cursor2) == "table" then
      table.insert(cursor2, val)
    else  -- only the second value, create a table
      cursor2 = {cursor2, val}
    end
  end

  return key  -- for modification
end

p.read_file = function(path)
  local texts = {}
  for line in io.lines(path) do
    table.insert(texts, line)
  end
  return texts
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
    elseif (#value == 3) and (string.find(value, "'.*'")) then  -- symbol with quotes
      value = string.sub(value, 2, 2)
      output = string.byte(value)  -- other symbol: remove symbol
    else output = '"' .. value .. '"' end
  end
  return output 
end

return p
