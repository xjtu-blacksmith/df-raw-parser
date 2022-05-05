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
    local token = p.getRaw (db, name, token1, token2)
    if token then
        return token
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
    if token and (type(token)=="table") then
        return token[tostring(index)]  -- consider the case when non-number index exists
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
    local token = args[3]
    local pattern = ""
    local list = {}
    if #args == 4 then
        pattern = args[4]
        list = p.getRaw (db, name, token)
    else
        local token2 = args[4]
        pattern = args[5]
        list = p.getRaw (db, name, token, token2)
    end
    local res = {}
    -- replace the pattern with keys and values
    if list then
        for k, v in pairs(list) do
            local element = tostring(pattern)
            element = string.gsub(element, '\\1', tostring(k))
            element = string.gsub(element, '\\2', tostring(v))
            element = string.gsub(element, '\\t1', tostring(p.trans({args={k}})))
            element = string.gsub(element, '\\t2', tostring(p.trans({args={v}})))
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
    local dict = mw.loadData('Module:raw/token_dict')
    local trans_res = dict[token]  -- directly lookup dict (table)
    if trans_res then return trans_res else return token end
end

return p