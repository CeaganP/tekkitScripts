--constantly display commands
--https://stackoverflow.com/questions/21075743/compare-string-if-theres-at-most-one-wrong-character-in-lua
--cDisplay
print("Program Begin")
function compstr(w1, w2)
    if w1 == nil or w2 == nil then
      return true
    end
	
    if w1 == nil and not w2 == nil then
      return false
    end
    if w2 == nil and not w1 == nil then
      return false
    end
	
    if not w1:len() == w2:len() then
        return false
    end
    for i = 1, w1:len() do
        if not w1:sub(i, i) == w2:sub(i, i) then
           return w1:sub(i + 1) == w2:sub(i + 1)
        end
    end
    return true
end

function startsWith(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

print("Where are your modules? [top, left, bottom, right]")
print("Screen: ")
local screenLoc = read()
print("Wireless: ")
local rednetLoc = read()

print("\nEntering Primary Loop")

local screen = peripheral.wrap(screenLoc)
screen.clear()
screen.setCursorPos(1,1)
screen.write("Update Log")
local x,y=1,2
screen.setCursorPos(x,y)

function screenWrite(message)
  screen.write(message)
  y = y + 1
  screen.setCursorPos(x,y)
end

local prevMsg={}

rednet.open(renetLoc, 50)
while true do
  y = 1
  screen.setCursorPos(x,y)

  screenWrite("Turtle Update Log")
  for k,v in pairs(prevMsg) do 
    screenWrite(k.." "..v)
  end   
    
  local id,msg=rednet.receive()
  prevMsg[id]=msg
  print("message received ["..id.."] -- "..msg)
  screen.clear()
end

print("Program End")
