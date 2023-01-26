--used with GPS to navigate to specified location
--drive
rednet.open("top", 50)
gps.locate(3,true)
drive=[[
local currentLoc=vector.new(gps.locate(3,true))

while not currentLoc.x==loc.x do
  rednet.broadcast("aligning x axis", 50)

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






rednet.open("right", 50)

mine=[[
local loc=vector.new(gps.locate(3,true))
local startLoc = loc
local size = 10
for y=0,size do
  for x=0,size do
    for z=0,size do
      turtle.dig()
      turtle.forward()
      rednet.broadcast("Mining "..(y * size * size) + (x * size) + z)
    end
  
    if x<size then   
      if x % 2 == 0 then
        turtle.turnRight()
        turtle.dig()
        turtle.forward()
        turtle.turnRight()
      else 
        turtle.turnLeft()
        turtle.dig()
        turtle.forward()
        turtle.turnLeft()
      end
    end
  end
  
  turtle.turnRight()
  turtle.turnRight()
  for i=0,size do
    turtle.forward()
  end
  turtle.turnRight()
  for i=0,size do
    turtle.forward()
  end
  turtle.turnRight()
  
  turtle.digDown()
  turtle.down()
end    
]]
rednet.broadcast(mine)





rednet.open("right", 50)
comm=[[
--offset by choice, negative y is up
local offsetX = 0
local offsetY = -15
local offsetZ = 0

local size = 10
local depth = 0
local unloaded = 0
local collected = 0

local xPos,zPos = 0,0
local xDir,zDir = 0,1

local goTo -- Filled in further down
 
local function unload( _bKeepOneFuelStack )
  print( "Unloading items..." )
  for n=1,9 do
    local nCount = turtle.getItemCount(n)
    if nCount > 0 then
      turtle.select(n)      
      local bDrop = true

      if bDrop then
        turtle.drop()
        unloaded = unloaded + nCount
      end
    end
  end
  collected = 0
  turtle.select(1)
end

local function returnSupplies()
  local x,y,z,xd,zd = xPos,depth,zPos,xDir,zDir
  print( "Returning to surface..." )
  goTo( 0,0,0,0,-1 )
  
  unload( true )  

  print( "Resuming mining..." )
  --goTo( x,y,z,xd,zd )
end

local function collect() 
  rednet.broadcast("Collect "..xPos.." "..depth.." "..zPos)
 
  local bFull = true
  local nTotalItems = 0
  for n=1,9 do
    local nCount = turtle.getItemCount(n)
    if nCount == 0 then
      bFull = false
    end
    nTotalItems = nTotalItems + nCount
  end
  
  if nTotalItems > collected then
    collected = nTotalItems
    if math.fmod(collected + unloaded, 50) == 0 then
      print( "Mined "..(collected + unloaded).." items." )
    end
  end
  
  if bFull then
    print( "No empty slots left." )
    return false
  end
  return true
end

local function tryForwards()
  while not turtle.forward() do
    if turtle.detect() then
      if turtle.dig() then
        if not collect() then
          returnSupplies()
        end
      else
        return false
      end
    elseif turtle.attack() then
      if not collect() then
        returnSupplies()
      end
    else
      sleep( 0.5 )
    end
  end
  
  xPos = xPos + xDir
  zPos = zPos + zDir
  return true
end

local function tryDown()
  while not turtle.down() do
    if turtle.detectDown() then
      if turtle.digDown() then
        if not collect() then
          returnSupplies()
        end
      else
        return false
      end
    elseif turtle.attackDown() then
      if not collect() then
        returnSupplies()
      end
    else
      sleep( 0.5 )
    end
  end

  depth = depth + 1
  if math.fmod( depth, 10 ) == 0 then
    print( "Descended "..depth.." metres." )
  end

  return true
end

local function turnLeft()
  turtle.turnLeft()
  xDir, zDir = -zDir, xDir
end

local function turnRight()
  turtle.turnRight()
  xDir, zDir = zDir, -xDir
end

function goTo( x, y, z, xd, zd )
  rednet.broadcast("GoTo "..x.." "..y.." "..z)
  while depth > y do
    if turtle.up() then
      depth = depth - 1
    elseif turtle.digUp() or turtle.attackUp() then
      collect()
    else
      sleep( 0.5 )
    end
  end

  if xPos > x then
    while not xDir == -1 do
      turnLeft()
    end
    while xPos > x do
      if turtle.forward() then
        xPos = xPos - 1
      elseif turtle.dig() or turtle.attack() then
        collect()
      else
        sleep( 0.5 )
      end
    end
  elseif xPos < x then
    while not xDir == 1 do
      turnLeft()
    end
    while xPos < x do
      if turtle.forward() then
        xPos = xPos + 1
      elseif turtle.dig() or turtle.attack() then
        collect()
      else
        sleep( 0.5 )
      end
    end
  end
  
  if zPos > z then
    while not zDir == -1 do
      turnLeft()
    end
    while zPos > z do
      if turtle.forward() then
        zPos = zPos - 1
      elseif turtle.dig() or turtle.attack() then
        collect()
      else
        sleep( 0.5 )
      end
    end
  elseif zPos < z then
    while not zDir == 1 do
      turnLeft()
    end
    while zPos < z do
      if turtle.forward() then
        zPos = zPos + 1
      elseif turtle.dig() or turtle.attack() then
        collect()
      else
        sleep( 0.5 )
      end
    end  
  end
  
  while depth < y do
    if turtle.down() then
      depth = depth + 1
    elseif turtle.digDown() or turtle.attackDown() then
      collect()
    else
      sleep( 0.5 )
    end
  end
  
  while not (zDir == zd or xDir == xd) do
    turnLeft()
  end
end

goTo( offsetX, offsetY, offsetZ, 0, -1)

print( "Excavating..." )

local reseal = false
turtle.select(1)
if turtle.digDown() then
  reseal = true
end

local alternate = 0
local done = false
while not done do
  for n=1,size do
    for m=1,size-1 do
      rednet.broadcast(n.." "..m)
	  if not tryForwards() then
        done = true
        break
      end
    end
    if done then
      break
    end
    if n<size then
      if math.fmod(n + alternate,2) == 0 then
        turnLeft()
        if not tryForwards() then
          done = true
          break
        end
        turnLeft()
      else
        turnRight()
        if not tryForwards() then
          done = true
          break
        end
        turnRight()
      end
    end
  end
  if done then
    break
  end
  
  if size > 1 then
    if math.fmod(size,2) == 0 then
      turnRight()
    else
      if alternate == 0 then
        turnLeft()
      else
        turnRight()
      end
      alternate = 1 - alternate
    end
  end
  
  if not tryDown() then
    done = true
    break
  end
end

print( "Returning to surface..." )

-- Return to where we started
goTo( 0,0,0,0,-1 ) --screws up go to
unload( false )
goTo( 0,0,0,0,1 )

print( "Arrived at surface..." )

-- Seal the hole
if reseal then
  turtle.placeDown()
end

print( "Mined "..(collected + unloaded).." items total." )
]]
rednet.broadcast(comm)





================================================
================================================


rednet.open("right", 50)
comm=[[1
--offset by choice, negative y is up

local size = 10
local depth = 0
local collected = 0

local xPos,zPos = 0,0
local xDir,zDir = 0,1

local function collect() 
  rednet.broadcast("Collect "..xPos.." "..depth.." "..zPos)
  
  if math.fmod(collected, 25) == 0 then
    print( "Mined "..(collected + unloaded).." items." )
    rednet.broadcast("Mined "..(collected + unloaded).." items.")
  else 
    rednet.broadcast("Collect "..xPos.." "..depth.." "..zPos)
  end
  
  for n=1,9 do
    if turtle.getItemCount(n) == 0 then 
      return true
    end	  
  end
  
  print( "No empty slots left." )
  return false
end

local function tryForwards()
  while not turtle.forward() do
    if turtle.dig() then
      if not collect() then
        return false
      end
    else
      sleep(0.8)
	  if turtle.dig() then
        if not collect() then
          return false
        end
      else
	    return false
	  end
    end
  end
  
  xPos = xPos + xDir
  zPos = zPos + zDir
  return true
end

local function tryDown()
  if not turtle.down() then
    if turtle.digDown() then
	  if not collect() then
	    return false
      end
    end
	if not turtle.down() then
	  return false
	end
  end
  depth = depth + 1
  if math.fmod(depth, 10) == 0 then
    print("Descended "..depth.." blocks")
  end
  return true
end

local function turnLeft()
  turtle.turnLeft()
  xDir, zDir = -zDir, xDir
end

local function turnRight()
  turtle.turnRight()
  xDir, zDir = zDir, -xDir
end

print( "Excavating..." )

local alternate = 0
local done = false
while not done do
  for n=1,size do
    for m=1,size-1 do
      rednet.broadcast(n.." "..m)
	  if not tryForwards() then
        done = true
        break
      end
    end
    if done then
      break
    end
    if n<size then
      if math.fmod(n + alternate,2) == 0 then
        turnLeft()
        if not tryForwards() then
          done = true
          break
        end
        turnLeft()
      else
        turnRight()
        if not tryForwards() then
          done = true
          break
        end
        turnRight()
      end
    end
  end
  if done then
    break
  end
  
  if size > 1 then
    if math.fmod(size,2) == 0 then
      turnRight()
    else
      if alternate == 0 then
        turnLeft()
      else
        turnRight()
      end
      alternate = 1 - alternate
    end
  end
  
  if not tryDown() then
    done = true
    break
  end
end

print( "Returning to surface..." )
rednet.broadcast("Returning to surface...")

-- Return to where we started
while depth > 0 do
  if turtle.up() then
    depth = depth - 1
  else if turtle.digUp() then
    collect()
  else
    sleep(0.5)
  end
end

print( "Arrived at surface..." )
rednet.broadcast("Arrived at surface...")

if xPos > 0 then
  while not xDir == -1 do
    turnLeft()
  end
  while xPos > 0 do
    if turtle.forward() then
	  xPos = xPos - 1
	elseif turtle.dig() then
	  collect()
	else
	  sleep(0.5)
	end
  end
end

if zPos > 0 then
  while not zDir == -1 do
    turnLeft()
  end
  while zPos > 0 do
    if turtle.forward() then
	  zPos = zPos - 1
	elseif turtle.dig() then
	  collect()
	else
	  sleep(0.5)
	end
  end
end

while not zDir == 1 do
  turnLeft()
end

print( "Arrived at origin..." )
rednet.broadcast("Arrived at origin...")

-- Seal the hole
if reseal then
  turtle.placeDown()
end

print( "Mined "..(collected + unloaded).." items total." )
rednet.broadcast("Mined "..(collected + unloaded).." items total.")
]]
rednet.broadcast(comm)
