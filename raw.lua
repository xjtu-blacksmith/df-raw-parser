local p = {}

p.getRaw = function (db, name, token1, token2)
    local data = mw.loadData('Module:raw/' .. db)
    local dict = mw.loadData('Module:raw/' .. db .. '_tokens')
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
    local index = args[4]
    local token = p.getRaw (db, name, token_name)
    if token then
        return token[index]
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

p.getStateDescription = function ( frame )
    local args = frame.args
	if frame == mw.getCurrentFrame() then
		args = frame:getParent().args
	end
    local token = args[1]
    local entry = args[2]
    local state = args[3]
    if entry == 'NAME' then
        return token['STATE_NAME_ADJ/' .. state]
    end
    return ""  -- default: empty string
end

return p