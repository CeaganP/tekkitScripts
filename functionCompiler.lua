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
  local msgType = tonumber(string.sub(msg, 1, 1))
  if not msgType == 1 then
    continue
  end
  msg = string.sub(msg, 2) --trim msg type
  local f, err = loadstring(msg)
  if err==nil then  
    print("function assigned...")  
  else 
    print(err) 
  end
  local v, err = pcall(f)
  if not v then 
    print("code failed to compile...", err) 
  end
end