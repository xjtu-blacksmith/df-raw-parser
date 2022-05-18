local p = {}

p.getRaw = function (db, name, token1, token2)
    local data = mw.loadData('Module:raw/' .. db)
    if not data[name] then return nil end
    local token_db = data[name]
    if not token1 then token1 = 'NAME' end  -- default token
    if not token2 then
    	if token_db[token1] then
        	return token_db[token1] -- first level
        else
        	return nil
        end
    else
        if token_db[token1] and token_db[token1][token2] then
        	return token_db[token1][token2] -- second level
        else
        	return nil
        end
    end
end

p.dfRaw = function ( frame )
    local args = frame.args
	if frame == mw.getCurrentFrame() then
		args = frame:getParent().args
	end
    local db = args[1]
    local name = args[2]
    local token1 = args[3]
    local token2 = args[4]
    return p.getRaw( db, name, token1, token2 )
end

p.tagValue = function (frame)
    local args = frame.args
	if frame == mw.getCurrentFrame() then
		args = frame:getParent().args
	end
    local db = args[1]
    local name = args[2]
    local token1 = args[3]
    local token2 = args[4]
    local notfound = args["notfound"]
    local token = p.getRaw (db, name, token1, token2)
    if token then
        return token
    elseif notfound then
        return notfound
    else
    	return ""
    end
end

p.tagEntry = function( frame )
    local args = frame.args
	if frame == mw.getCurrentFrame() then
		args = frame:getParent().args
	end
    local db = args[1]
    local name = args[2]
    local token_name = args[3]
    local index = 0
    local token2 = ""
    local token = {}
    if tonumber(args[4]) then
      index = args[4]
      token = p.getRaw (db, name, token_name)
    else
      token2 = args[4]
      index = args[5]
      token = p.getRaw (db, name, token_name, token2)
    end
    local notfound = args["notfound"]
    if token and (type(token)=="table") then
        return token[tostring(index)]  -- consider the case when non-number index exists
    elseif notfound then
        return notfound
    else
    	return ""
    end
end

p.tagFor = function ( frame )
    local args = frame.args
	if frame == mw.getCurrentFrame() then
		args = frame:getParent().args
	end
    local db = args[1]
    local name = args[2]
    local pattern = args[3]
    local token1 = args[4]
    local token2 = args[5]  -- may be empty
    local list = p.getRaw (db, name, token1, token2)
    local res = {}
    -- replace the pattern with keys and values
    if list then
        for k, v in pairs(list) do
            local element = tostring(pattern)
            element = string.gsub(element, '\\0', tostring(k))
            element = string.gsub(element, '\\t0', tostring(p.trans({args={k}})))
            if (type(v) == 'table') then -- value as a table
	        	for i = 1,9 do
	        		element = string.gsub(element, '\\' .. tostring(i), tostring(v[tostring(i)]))
	        		element = string.gsub(element, '\\t' .. tostring(i), tostring(p.trans({args={v[tostring(i)]}})))
        		end
	        else
	            element = string.gsub(element, '\\1', tostring(v))
	            element = string.gsub(element, '\\t1', tostring(p.trans({args={v}})))
        	end
            table.insert(res, element)
        end
        return table.concat(res)
    else
        return ""
    end
end

p.tag = function( frame )
    local args = frame.args
	if frame == mw.getCurrentFrame() then
		args = frame:getParent().args
	end
    local db = args[1]
    local name = args[2]
    local token1 = args[3]
    local token2 = args[4]
    local token = p.getRaw (db, name, token1, token2)
    if token then  -- tag exists
        return "true"  -- representing true
    else
        return ""  -- empty string means false for wikitext
    end
end

p.trans = function (frame)
    local args = frame.args
    if frame == mw.getCurrentFrame() then
		args = frame:getParent().args
	end
    local token = args[1]  -- only one param
    if not token then -- empty token
    	return ""
	end
    local dict = mw.loadData('Module:raw/token_dict')
    local trans_res = dict[token]  -- directly lookup dict (table)
    if trans_res then
    	return trans_res
    else
    	return token
	end
end

return p
