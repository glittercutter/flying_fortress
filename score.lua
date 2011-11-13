local State = {}


function State:onBegin(lastState, ...)
    self.Score = arg[1]
    self.Msg = arg[2]
    love.graphics.setBackgroundColor(30, 30, 30)
end


function State:onEnd()
end


function State:onUpdate(dt)
end


function State:onDraw()
    local score = "SCORE = " .. self.Score
    love.graphics.print(score, 300, 300)
    if self.Msg then love.graphics.print(self.Msg, 300, 250) end
end


function State:onMousePressed(x, y, button)
    setState("menu")
end


function State:onMouseReleased(x, y, button)
end


function State:onKeyPressed(key)
    setState("menu")
end


function State:onKeyReleased(key)

end


return State
