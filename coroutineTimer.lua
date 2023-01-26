co = coroutine.create(function ()
  while not redstone.getInput("right") do 
    redstone.setOutput("left", true)
    sleep(1)
    redstone.setOutput("left", false)
    sleep(1)
  end
end)

coroutine.resume(co)  