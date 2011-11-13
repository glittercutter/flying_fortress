require 'utils'
require 'fortress'
require 'camera'

State = {}


function State:loadNextLevel()
    Camera.reset()
    self.X = 0
    self.Y = 0
    self.Fortress = Fortress:new(self)
    self.LevelNo = self.LevelNo + 1

    local filename = "level/level" .. self.LevelNo .. ".lua"
    if not love.filesystem.exists(filename) then
        setState("score", self.Level.Score) 
        return
    end

    self.Level = love.filesystem.load(filename)():new({self.Fortress})
end


function State:onBegin(lastState)
    self.LevelNo = 0
    self:loadNextLevel()
    self.BMG = love.audio.play("data/bmg.ogg", "stream", true)
end


function State:onEnd()
    love.audio.stop(self.BMG)
end


function State:notifyDestroyed(unit)
    if unit == self.Fortress then
        setState("score", self.Level.Score, "GAME OVER")
    end
end


function State:onUpdate(dt)
    local t = {}
    t[self.Fortress] = true
    if self.Level:onUpdate(dt, t) == 0 then self:loadNextLevel() end

    self.Fortress:onUpdate(dt, self.Level:getActiveEnemies())
    self.X = self.X + self.Fortress.FlyingVel * dt
end


function State:onDraw()
    Camera.draw(self.X, self.Y,
        function()
            self.Level:onDraw()
            self.Fortress:onDraw()
        end)
    local score = "Score = " .. self.Level.Score
    love.graphics.print(score, 20, 20)
    local health = "Health = " .. self.Fortress.Health
    love.graphics.print(health, 690, 20)
end


function State:onMousePressed(x, y, button)
    self.Fortress:onMousePressed(x, y, button)
end


function State:onMouseReleased(x, y, button)
    self.Fortress:onMouseReleased(x, y, button)
end


function State:onKeyPressed(key)
    if key == "escape" then setState("menu") end
    self.Fortress:onKeyPressed(key)
end


function State:onKeyReleased(key)
    self.Fortress:onKeyReleased(key)
end


return State
