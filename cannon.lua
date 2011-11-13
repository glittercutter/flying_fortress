require "utils"

local BULLET_VELOCITY = 900

Cannon = {}
function Cannon:new(parent, x, y, min, max, size)
    local t = {}
    setmetatable(t, self)
    self.__index = self

    t.Parent = parent
    t.X, t.Y = x, y
    t.Size = size
    t.CannonLength = size * 2

    t.MinRad, t.MaxRad = min, max
    t.Radians = (max - min) / 2
    t.MaxRotSpeed = math.pi/2 -- rad/sec
    
    t.RepeatRate = 0.2
    t.LastFired = 0
    t.Fire = false
    return t
end


function Cannon:enableFire(enable)
    if enable then
        self.Fire = true
    else
        self.HasFired = false
        self.Fire = false
    end
end


function Cannon:fire(headStart)
    local bullet = self.Parent.BulletPool:getBullet()
    local x, y = self:getPosition()
    bullet:fire(x, y, self.Radians, BULLET_VELOCITY)
    if headStart then bullet:onUpdate(headStart) end
end


function Cannon:onUpdate(dt, mx, my)
    if mx and my then self:rotate(dt, mx, my) end
    local time = love.timer.getMicroTime()

    if self.Fire and self.LastFired + self.RepeatRate <= time then
        if not self.HasFired then
            self:fire()
            self.LastFired = time
        else
            local n, i = (time - self.LastFired) / self.RepeatRate, 1
            while i <= n do
                self:fire((self.LastFired + self.RepeatRate) - time)
                i = i + 1
            end
            self.LastFired = self.LastFired + (n * self.RepeatRate)
        end 
    end
end


function Cannon:rotate(dt, mx, my)
    local cx, cy = self:getPosition()
    local a = math.atan2(my - cy, mx - cx) - self.Radians
    Utils.clipRange(a, -self.MaxRotSpeed * dt, self.MaxRotSpeed * dt)
    self.Radians = self.Radians + a
    Utils.clipRange(self.Radians, self.MinRad, self.MaxRad)
    return a
end


function Cannon:onDraw()
    love.graphics.setColor(30, 30, 30, 255)
    local x, y = self:getPosition()
    love.graphics.line(x, y, x + (math.cos(self.Radians) * self.CannonLength), y + (math.sin(self.Radians) * self.CannonLength))
end


function Cannon:getPosition()
    return self.X + self.Parent.X, self.Y + self.Parent.Y
end
