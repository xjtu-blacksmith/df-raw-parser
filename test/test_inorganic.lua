package.path = './?.lua'
p = require('raw_parser')
dict = require('inorganic_tokens')
data = {}
files = {
    'inorganic_stone_mineral.txt',
    'inorganic_stone_gem.txt',
    'inorganic_stone_layer.txt',
    'inorganic_stone_soil.txt',
    'inorganic_metal.txt',
    'inorganic_other.txt',
}
for _, file in ipairs(files) do
    -- read raw file
    raw = p.read_file('raw/' .. file)
    data = p.parse(raw, dict, data)
    print(file .. ' processed!')
end

-- write out data
f = io.output('out/inorganic.lua')
f:write('return ' .. p.dump(data, "", true))
f:close()

-- test data info
print(data['NATIVE_SILVER']['ITEM_SYMBOL'])  -- '*'
print(data['GALENA']['USE_MATERIAL_TEMPLATE/STONE_TEMPLATE']['STATE_NAME_ADJ/ALL_SOLID'])  -- galena
print(data['GALENA']['USE_MATERIAL_TEMPLATE/STONE_TEMPLATE']['ENVIRONMENT']['IGNEOUS_EXTRUSIVE'][1])  -- vein
print(data['SPHALERITE']['IS_STONE']) -- true