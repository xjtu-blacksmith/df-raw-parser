local p = {}

p.parse = function(raw)
  local data = {}
  local cur_level = 0
  local link = {}  -- buffer for current parents' link
  for i, line in ipairs(raw) do
    if string.match(line, "%[[%a_]+:[%a_:]+%]") then
      local _, level = string.gsub(line, '\t', "")  -- count level by tab
      if not level then level = 0 end
      l, r = string.find(line, "%[[%a_]+[:%]]")
      attr = string.sub(line, l+1, r-1)  -- acquire attr
      line = string.sub(line, r+1)  -- remove attr
      l, _ = string.find(line, ']')  -- find the end of token
      val = string.sub(line, 1, l-1)  -- get val
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
        cursor[attr] = {}
        cursor[attr].val = val  -- value for correpsonding attributes
        cursor[attr].tab = {}  -- sub table
        if not level == cur_level then table.insert(link, attr) end
      else -- rollback to lower level
        for _ = level+1, cur_level-1 do
          table.remove(link, #link)  -- rollback to the level on the top
        end
        local cursor = p.fw_link(data, link)
        cursor[attr] = {}
        cursor[attr].val = val  -- value for correpsonding attributes
        cursor[attr].tab = {}  -- sub table
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

p.read_file = function(path)
  local texts = {}
  for line in io.lines(path) do
    table.insert(texts, line)
  end
  return texts
end

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
