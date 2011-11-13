require 'enemyManager'


local Level = {}
function Level:new(targets)
    local t = {}
    setmetatable(t, self)
    self.__index = self

    t.Score = 0
    t.Enemies = EnemyManager:new(t)

    for _, v in pairs(targets) do t.Enemies:addTarget(v) end

    for i = 0, 220 do
        t.Enemies:addEnemy("zero", math.random(0, 5000), math.random(ArenaLimit.Y1, ArenaLimit.Y2))
    end
    
    love.graphics.setBackgroundColor(100, 5, 150)

    return t
end


function Level:onUpdate(dt, targets)
    self.Enemies.Targets = targets
    self.Enemies:onUpdate(dt)
    return self.Enemies:count()
end


function Level:onDraw()
    self.Enemies:onDraw()
end


function Level:getActiveEnemies()
    return self.Enemies:getActive()
end


function Level:score()
    self.Score = self.Score + 100
end


return Level
