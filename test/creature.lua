package.path = './?.lua'
p = require('raw_parser')
dict = require('creature_tokens')
data = {}
files = {
    'creature_amphibians.txt',
    'creature_annelids.txt',
    'creature_birds.txt',
    'creature_birds_new.txt',
    'creature_bug_slug_new.txt',
    'creature_desert_new.txt',
    'creature_domestic.txt',
    'creature_equipment.txt',
    'creature_fanciful.txt',
    'creature_insects.txt',
    'creature_large_mountain.txt',
    'creature_large_ocean.txt',
    'creature_large_riverlake.txt',
    'creature_large_temperate.txt',
    'creature_large_tropical.txt',
    'creature_large_tundra.txt',
    'creature_mountain_new.txt',
    'creature_next_underground.txt',
    'creature_ocean_new.txt',
    'creature_other.txt',
    'creature_reptiles.txt',
    'creature_riverlakepool_new.txt',
    'creature_small_mammal_new.txt',
    'creature_small_mammals.txt',
    'creature_small_ocean.txt',
    'creature_small_riverlake.txt',
    'creature_standard.txt',
    'creature_subterranean.txt',
    'creature_temperate_new.txt',
    'creature_tropical_new.txt',
    'creature_tundra_taiga_new.txt',
}
for _, file in ipairs(files) do
    -- read raw file
    raw = p.read_file('raw/' .. file)
    data = p.parse(raw, dict, data)
    print(file .. ' processed!')
end

-- write out data
f = io.output('out/creature.lua')
f:write('return ' .. p.dump(data, "", true))
f:close()

-- test data info
