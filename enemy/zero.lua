require 'cannon'
require 'enemyManager'


local Zero = {}
function Zero:new(parent, x, y)
    local t = {}
    setmetatable(t, self)
    self.__index = self

    t.Parent = parent
    t.X, t.Y = x, y
    t.Width, t.Height = 22, 9
    t.VelX, t.VelY = -275, 0
    t.Health = 100
    t.BulletPool = parent.BulletPool
    t.Cannons = {}
    local c = Cannon:new(t, 0, 5, Utils.degToRad(-120), Utils.degToRad(120), 3)
    c:enableFire(true)
    c.Radians = math.pi
    table.insert(t.Cannons, c)

    t.Tex = love.graphics.newImage("data/zero.png")

    return t
end


function Zero:setTarget(t)
    self.Target = t
end


function Zero:onUpdate(dt)
    BasicEnemyUpdate(self, dt)
end


function Zero:onDraw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(self.Tex, self.X, self.Y)
end


function Zero:hit(dmg, x, y)
    self.Health = self.Health - dmg
    if self.Health <= 0 then
        self.Parent:notityDestroyed(self)
        love.audio.play("data/explode.ogg")
    end
end

return Zero
