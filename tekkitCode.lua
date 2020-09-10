C:\Users\Ceagan\AppData\Roaming\.technic\modpacks\tekkit\mods\ComputerCraft\lua\rom\programs

co = coroutine.create(function ()
  while input = nil do 
    redstone.setOutput("left", true)
    sleep(1)
    redstone.setOutput("left", false)
    sleep(1)
  end
end)

coroutine.resume(co)  

--
function leftFlicker()
  while not redstone.getInput("back") do
    redstone.setOutput("left", true)
	sleep(1)
    redstone.setOutput("left", false)
	sleep(1)
  end
end

parallel.waitForAll(leftFlicker)

--http://www.computercraft.info/forums2/index.php?/topic/23184-sensorlog-logging-nearby-players-printing-as-a-table/
--SENSORS
--computercraft.info/forums2/index.php?/topic/9490-how-to-use-ccsensors/
--sensor controller reference
sensor = peripheral.wrap("right")
for value in pairs(sensor) do
  print(value)
end

--https://www.computercraft.info/wiki/Startup
--https://computercraft.info/wiki/Turtle_(API)
--https://www.computercraft.info/wiki/Clear
--wireless turtle
rednet.open("right", 50)
term.clear()
while true do
  term.setCursorPos(1,1)  
  print("awaiting code to execute...")
  local id, msg = rednet.receive() 
  term.clear()
  print("wireless transmission received...")
  local f,err = loadstring(msg)
  if err==nil then  print("function assigned...")  
  else print(err) end
  local v,err = pcall(f)
  if not v then  print("code failed to compile...", err)  end
end

--used with GPS to navigate to specified location
--drive
rednet.open("top", 50)

drive=[[
local currentLoc=vector.new(gps.locate(3,true))

while currentLoc.x~=loc.x do
  rednet.broadcast("aligning x axis")

  local xdiff=math.abs(currentLoc.x-loc.x)
  local isForward=true

  if math.abs(currentLoc.x-loc.x)>0 then
	if isForward then
	  turtle.forward()
	else 
	  turtle.back()
	end
	
	if xdiff<math.abs(currentLoc.x-loc.x) then
	  isForward = not isForward
	elseif xdiff==math.abs(currentLoc.x-loc.x) then
	  turtle.turnRight()
	end	
  end
end
while currentLoc.z~=loc.z do
  rednet.broadcast("aligning z axis")
  local isForward=true
  local zdiff=math.abs(currentLoc.z-loc.z)
  if math.abs(currentLoc.z-loc.z)>0 then
	if isForward then
	  turtle.forward()
	else 
	  turtle.back()
	end
	
	if zdiff<math.abs(currentLoc.z-loc.Z) then
	  isForward = not isForward
	elseif zdiff==math.abs(currentLoc.z-loc.z) then
	  turtle.turnRight()
	end	
  end		  
end 

if currentLoc.z==loc.z and currentLoc.x==loc.x then
  rednet.broadcast("arrived at the start")
end
]]
rednet.broadcast(drive)

--sent from the HOST computer, place all possible blocks
--placer
rednet.open("top", 50)

placeAll = [[
local loc=vector.new(gps.locate(3,true))
local slots = {1,2,3,4,5,6,7,8,9}
local wallHitCount=0
local isFinished=false
for slot,val in pairs(slots) do
  print("executing "..slot.." index "..val)
  if turtle.getItemCount(slot) > 0 then
    rednet.broadcast("placing slot "..slot.." "..turtle.getItemCount(slot))
  end

  turtle.select(slot)
  while not isFinished and turtle.getItemCount(slot) > 0 do
    while not isFinished and turtle.detectDown() do
	  if not turtle.detect() then
	    turtle.place(slot)
		wallHitCount=0
	  end
	  if not turtle.back() and wallHitCount<4 then
	    rednet.broadcast("wall hit")
		turtle.turnRight()
	    turtle.back()
		wallHitCount=wallHitCount + 1
	  elseif wallHitCount==4 then
	    turtle.up()
	    turtle.placeDown(slot)
		rednet.broadcast("finished placing layer "..tostring(isFinished))
		isFinished=true
      end
    end
	rednet.broadcast("failed to detect block below")
    turtle.forward()
    turtle.turnRight()	
	turtle.back()
  end
  
  if isFinished then   
	rednet.broadcast("on my way back to the start")
	local currentLoc=vector.new(gps.locate(3,true))
    
	while currentLoc.x~=loc.x do
	  rednet.broadcast("aligning x axis")

	  local xdiff=math.abs(currentLoc.x-loc.x)
	  local isForward=true

	  if math.abs(currentLoc.x-loc.x)>0 then
		if isForward then
		  turtle.forward()
		else 
		  turtle.back()
		end
		
		if xdiff<math.abs(currentLoc.x-loc.x) then
		  isForward = not isForward
		elseif xdiff==math.abs(currentLoc.x-loc.x) then
		  turtle.turnRight()
		end	
	  end
	end
    while currentLoc.z~=loc.z do
	  rednet.broadcast("aligning z axis")
      local isForward=true
      local zdiff=math.abs(currentLoc.z-loc.z)
	  if math.abs(currentLoc.z-loc.z)>0 then
		if isForward then
		  turtle.forward()
		else 
		  turtle.back()
		end
		
		if zdiff<math.abs(currentLoc.z-loc.Z) then
		  isForward = not isForward
		elseif zdiff==math.abs(currentLoc.z-loc.z) then
		  turtle.turnRight()
		end	
	  end		  
	end 
    
	if currentLoc.z==loc.z and currentLoc.x==loc.x then
      rednet.broadcast("arrived at the start")
    end
  end
end
rednet.broadcast("finished executing task")]]

rednet.broadcast(placeAll)

--test application
rednet.open("top", 50)

tester = [[local isMoving=true
while isMoving do
  local id,command=rednet.receive(0.3)
  if not command==nil then
	rednet.broadcast("true")
    isMoving=false
    break
  elseif command==nil then
    rednet.broadcast(command)
  end
  turtle.forward()
  turtle.turnRight()
end]]

rednet.broadcast(tester)
local id,response=rednet.receive(3)
print("response: ", response)



--constantly display commands
--https://stackoverflow.com/questions/21075743/compare-string-if-theres-at-most-one-wrong-character-in-lua
--cDisplay
function compstr(w1, w2)
    if w1:len() ~= w2:len() then
        return false
    end
    for i = 1, w1:len() do
        if w1:sub(i, i) ~= w2:sub(i, i) then
            return w1:sub(i + 1) == w2:sub(i + 1)
        end
    end
    return true
end

local screen = peripheral.wrap("left")
screen.clear()
screen.setCursorPos(1,1)
screen.write("Turtle Update Log")
local x,y=1,2
screen.setCursorPos(x,y)

local prevMsg={}

rednet.open("top", 50)
while true do
  local id,msg=rednet.receive()
  if prevMsg[id]==nil then
    screen.write(msg)
	y=y+1
	screen.setCursorPos(x,y)
	table.insert(prevMsg, id, msg) 
  end
  if not prevMsg[id]==msg then
    screen.write(msg)
    y=y+1
    screen.setCursorPos(x,y)
	prevMsg[id]=msg
  end
end

--gps triangulation
--loc
edit startup
shell.run("gps", "host", x, y, z)
