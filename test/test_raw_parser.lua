p = require('raw_parser')
raw = p.read_file('raw/plant_standard.txt')
data = p.parse(raw)
print(p.dump(data))