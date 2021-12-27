local p = {}

p.parse = function(raw)
  local attr_pattern = "%[[%a_]+:[%a_:]%]"
  local data = {}
  local cur_level = 0
  local link = {}  -- buffer for current parents' link
  for i, line in ipairs(raw) do
    local cursor = data
    if string.match(line, attr_pattern) then
      l, r = string.find(line, "%[[%a_]+:")
      attr = string.sub(line, l, r)  -- acquire attr
      attr = string.sub(attr, 2) -- remove left [
      line = string.sub(line, r+1)  -- remove attr
      l, _ = string.find(line, ']')  -- find the end of token
      val = string.sub(line, 1, l-1)  -- get val
      _, level = string.find(line, '\t')
      if level > cur_level then
        for i, ele in ipairs(links) do
          -- find the place of data to put
        end
        -- put the data
      else
        if level == 0 then
          link = {val}
        end
      end
      cur_level = level
    end
  end
  return data
end

p.read_file = function(path)
  local texts = {}
  for line in io.lines(path) do
    print(line)
    table.insert(texts, line)
  end
  return texts
end

return p
