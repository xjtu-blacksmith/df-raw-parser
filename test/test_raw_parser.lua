package.path = './?.lua'
p = require('raw_parser')
dict = require('plant_tokens')
data = {}
files = {
    'plant_crops.txt',
    'plant_garden.txt',
    'plant_grasses.txt',
    'plant_new_trees.txt',
    'plant_standard.txt'
}
for _, file in ipairs(files) do
    -- read raw file
    raw = p.read_file('raw/' .. file)
    data = p.parse(raw, dict, data)
    print(file .. ' processed!')
end

-- write out data
f = io.output('out/plant.lua')
f:write('return ' .. p.dump(data))
-- f:write('return ' .. p.dump(data, "", true))
f:close()

-- test data info