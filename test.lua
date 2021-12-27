a = 5
local b = 5

function joke()
  c = 5
  local d = 5
end

joke()
print(c, d)

do
  local a = 6
  b = 6
  print(a, b)
end

print(a, b)
