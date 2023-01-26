C:\Users\Ceagan\AppData\Roaming\.technic\modpacks\tekkit\mods\ComputerCraft\lua\rom\programs



--http://www.computercraft.info/forums2/index.php?/topic/23184-sensorlog-logging-nearby-players-printing-as-a-table/
--SENSORS
--computercraft.info/forums2/index.php?/topic/9490-how-to-use-ccsensors/
--sensor controller reference
sensor = peripheral.wrap("right")
for value in pairs(sensor) do
  print(value)
end



--used with GPS to navigate to specified location
--drive
rednet.open("top", 50)
gps.locate(3,true)
drive=[[
local currentLoc=vector.new(gps.locate(3,true))

while not currentLoc.x==loc.x do
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
  local id,command=rednet.receive(3)
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



--test monitor logging 
rednet.open("right", 50)

tester = [[local log=false
local isMoving=true
if isMoving then
  rednet.broadcast("systems are a go")
end
rednet.broadcast("finished communications")
]]
rednet.broadcast(tester)
local id,response=rednet.receive()
print("response: ", response)






--xox	xox
--xxo	oxo
--oxx	
--to host x y z
gps host -4020 89 -3499
gps host -4019 88 -3497
gps host -4021 88 -3497
shell.run("gps", "host", x, y, z)
shell.run("gps", "host", -4020, 88, 3499)
shell.run("gps", "host", -4019, 88, -3497)
shell.run("gps", "host", -4021, 88, -3497)

local x = -9395
local y = 95
local z = -9640 
shell.run("gps", "host", x, y, z)


-9396, 96, -9642 
-9397, 95, -9640 
-9395, 95, -9640

local loc=vector.new(gps.locate(3,true))












--used with GPS to navigate to specified location
--drive

--direction of 0 is forward 
--direction of 1 is right 
--direction of 2 is back 
--direction of 3 is left 

rednet.open("top", 50)

drive=[[
local loc=vector.new(gps.locate(3,true))
local startLoc = loc
local dir = 0 

function align()
  turtle.forward()
  local liveLoc = vector.new(gps.locate(3,true))
  
  local posDiffX = loc.x - liveLoc.x
  local posDiffZ = loc.z - liveLoc.z    
	
  if posDiffX < 0 then
    dir = 3  
  elseif posDiffX > 0 then
    dir = 1
  end
  
  if posDiffZ < 0 then
    dir = 0
  elseif posDiffZ > 0 then
    dir = 2
  end  
  turtle.back()
end

function right()
  turtle.turnRight()
  
  local ndir = dir + 1  
  if ndir == 4 then
    return 0
  end
  return ndir
end

function left()
  turtle.turnLeft()
  return dir - 1;
end

function turn(newDir)
  if not newDir == dir then
    turn(right()) 
  end
end

function goToStart(location) 
    if location.x < startLoc.x then 
	  turn(1)
	elseif location.x > startLoc.x then
	  turn(3)
	end
	while not location.x == startLoc.x do 
	  turtle.forward()
	end
	
	if location.z < startLoc.z then
	  turn(0)
	elseif location.z > startLoc.z then
	  turn(2) 
	end
	while not location.z == startLoc.z do 
	  turtle.forward()
	end
end

turtle.forward()
turtle.forward()
turtle.turnRight()
turtle.forward()
goToStart()
]]

rednet.broadcast(drive)



local x = 180
local y = 72
local z = 258 
shell.run("gps", "host", x, y, z)

