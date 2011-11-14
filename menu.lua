local State = {}


function State:onBegin(lastState)
    love.graphics.setBackgroundColor(30, 30, 30)
    self.WASD_tex = love.graphics.newImage("data/wasd.png")
end


function State:onEnd()
end


function State:onUpdate(dt)

end


function State:onDraw()
    love.graphics.print("Shoot as many planes as you can!", 20, 20)
    love.graphics.print("Press any key", 20, 40)
    love.graphics.print("Control:", 20, 100)
    love.graphics.draw(self.WASD_tex, 20, 120)
    love.graphics.print("+ left mouse button", 25, 210)
end


function State:onMousePressed(x, y, button)
    setState("game")
end


function State:onMouseReleased(x, y, button)
end


function State:onKeyPressed(key)
	if key == "escape" then
		love.event.push("q")
    else 
        setState("game")
	end
end


function State:onKeyReleased(key)

end


return State
