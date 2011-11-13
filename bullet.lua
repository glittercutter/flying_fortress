require 'camera'
require 'utils'


local CLEANUP_DELAY = 0.5 -- In second


BulletPool = {}
function BulletPool:new()
    local t = {}
    setmetatable(t, self)
    self.__index = self
    
    t.Idle = {}
    t.Active = {}
    t.LastCleanupTime = 0
    t.DestroyedQueue = {}

    return t
end


function BulletPool:getBullet()
    local bullet = nil
    if not next(self.Idle) then
        bullet = Bullet:new(self)
    else
        bullet = next(self.Idle)
        self.Idle[bullet] = nil
    end
    self.Active[bullet] = true
    return bullet
end


function BulletPool:releaseBullet(bullet)
    self.Idle[bullet] = true
    self.Active[bullet] = nil
end


function BulletPool:onUpdate(dt, targets)
    local time = love.timer.getMicroTime()
    for bullet, _ in pairs(self.Active) do
        bullet:onUpdate(dt, targets)
    end
    if self.LastCleanupTime + CLEANUP_DELAY <= time then
        self:cleanup()
        self.LastCleanupTime = time
    end

    for bullet, _ in pairs(self.DestroyedQueue) do
        self:releaseBullet(bullet)
    end
    self.DestroyedQueue = {}
end


function BulletPool:onDraw()
    love.graphics.setColor(212, 197, 69, 255)
    for bullet, _ in pairs(self.Active) do bullet:onDraw() end
end


function BulletPool:cleanup()
    local buff = {}
    for bullet, _ in pairs(self.Active) do
        if not Camera.pointInArena(bullet.X, bullet.Y) then 
            table.insert(buff, bullet)
        end
    end
    for i, bullet in ipairs(buff) do self:releaseBullet(bullet) end
end


function BulletPool:notifyDestroyed(bullet)
    self.DestroyedQueue[bullet] = true
end


local BULLET_LENGTH = 3
local BULLET_DAMAGE = 30

Bullet = {}
function Bullet:new(parent)
    local t = {}
    setmetatable(t, self)
    self.__index = self 
    
    t.Parent = parent
    t.X, t.Y = 0, 0
    t.Vel = 0
    t.Radians = 0
    t.DirectionX = 0
    t.DirectionY = 0

    return t
end


function Bullet:fire(x, y, radian, vel)
    self.X, self.Y = x, y
    self.Radians = radian
    self.Vel = vel
    self.DirectionX = math.cos(self.Radians)
    self.DirectionY = math.sin(self.Radians)
end


function Bullet:onUpdate(dt, targets)
    self.X = self.X + self.DirectionX * (self.Vel * dt)
    self.Y = self.Y + self.DirectionY * (self.Vel * dt)
    
    for target, _ in pairs(targets) do
        if Utils.pointInBoundingBox({{x = target.X, y = target.Y}, {x = target.X + target.Width, y = target.Y + target.Height}}, self.X, self.Y) then
            target:hit(BULLET_DAMAGE, self.X, self.Y)
            love.audio.play("data/hit.ogg")
            self.Parent:notifyDestroyed(self)
        end
    end
end


function Bullet:onDraw()
    love.graphics.line(self.X, self.Y, self.X - self.DirectionX * BULLET_LENGTH, self.Y - self.DirectionY * BULLET_LENGTH)
end
