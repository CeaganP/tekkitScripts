--left flicker the redstone output
function leftFlicker()
  while not redstone.getInput("right") do
    redstone.setOutput("left", true)
	sleep(1)
    redstone.setOutput("left", false)
	sleep(1)
  end
end

parallel.waitForAll(leftFlicker)
