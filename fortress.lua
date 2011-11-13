require 'cannon'
require 'bullet'
require 'utils'
require 'camera'


Fortress = {}
function Fortress:new(parent)
    local t = Fortress
    setmetatable(t, self)
    self.__index = self

    t.Parent = parent
    t.X, t.Y = (ArenaLimit.X2 - ArenaLimit.X1) / 2, (ArenaLimit.Y2 - ArenaLimit.Y1) / 2
    t.Width, t.Height = 50, 30
    t.VelX, t.VelY = 0, 0
    t.AccX, t.AccY = 30, 30
    t.MaxVelX, t.MaxVelY = 30, 30
    t.Health = 200
    
    t.MinFlyingVel = 100
    t.MaxFlyingVel = 300
    t.FlyingVel = 0

    t.Left, t.Right, t.Up, t.Down = false, false, false, false
    t.WasLeft, t.WasRight, t.WasUp, t.WasDown = false, false, false, false
    t.Drag = 0.15

    t.BulletPool = BulletPool:new()
    t.Tex = love.graphics.newImage("data/fortress.png")

    t.Cannons = {}
    table.insert(t.Cannons, Cannon:new(t, 48, 15, Utils.degToRad(-120), Utils.degToRad(120), 3)) -- Front
    table.insert(t.Cannons, Cannon:new(t, 0, 18, Utils.degToRad(120), Utils.degToRad(-120), 3)) -- Back
    table.insert(t.Cannons, Cannon:new(t, 28, 10, Utils.degToRad(-120), Utils.degToRad(120), 3)) -- Top
    table.insert(t.Cannons, Cannon:new(t, 23, 20, Utils.degToRad(-120), Utils.degToRad(120), 3)) -- Bottom

    return t
end


function Fortress:onKeyPressed(key)
    if key == Input.MoveUp then
        if self.Down then self.WasDown = true end
        self.Down, self.Up = false, true
    elseif key == Input.MoveDown then
        if self.Up then self.WasUp = true end
        self.up, self.Down = false, true
    elseif key == Input.MoveLeft then
        if self.Left then self.WasLeft = true end
        self.Right, self.Left = false, true
    elseif key == Input.MoveRight then
        if self.Right then self.WasRight = true end
        self.Left, self.Right = false, true
    end
end


function Fortress:onKeyReleased(key)
    if key == Input.MoveUp then
        self.Up, self.WasUp = false, false
        if self.WasDown then self.Down = true end
    elseif key == Input.MoveDown then
        self.Down, self.WasDown = false, false
        if self.WasUp then self.Up = true end
    elseif key == Input.MoveLeft then
        self.Left, self.WasLeft = false, false
        if self.WasLeft then self.Left = true end
    elseif key == Input.MoveRight then
        self.Right, self.WasRight = false, false
        if self.WasRight then self.Right = true end
    end
end


function Fortress:onMousePressed(x, y, button)
    if button == Input.Fire then
        self.Fire = true
        for _, cannon in ipairs(self.Cannons) do cannon:enableFire(true) end
    end
end


function Fortress:onMouseReleased(x, y, button)
    if button == Input.Fire then
        self.Fire = false
        for _, cannon in ipairs(self.Cannons) do cannon:enableFire(false) end
    end
end


function Fortress:hit(dmg, x, y)
    self.Health = self.Health - dmg
end


function Fortress:onUpdate(dt, targets)
    if self.Health <= 0 then
        love.audio.play("data/explode.ogg")
        self.Parent:notifyDestroyed(self)
    end

    if self.Left then self.VelX = self.VelX - (self.AccX - (dt / self.AccX))
    elseif self.Right then self.VelX = self.VelX + (self.AccX - (dt / self.AccX)) end
    Utils.clipRange(self.VelX, -self.MaxVelX, self.MaxVelX)

    if self.Up then self.VelY = self.VelY - (self.AccY - (dt / self.AccY))
    elseif self.Down then self.VelY = self.VelY + (self.AccY - (dt / self.AccY)) end
    Utils.clipRange(self.VelY, -self.MaxVelY, self.MaxVelY)
    
    self.X = self.X + self.VelX * dt
    self.Y = self.Y + self.VelY * dt

    -- Apply drag
    self.VelX = self.VelX - (self.VelX * (dt / self.Drag))
    self.VelY = self.VelY - (self.VelY * (dt / self.Drag))

    if self.X < ArenaLimit.X1 then
        self.X = ArenaLimit.X1
        self.VelX = 0;
    elseif self.X + self.Width > ArenaLimit.X2 then
        self.X = ArenaLimit.X2 - self.Width
        self.VelX = 0;
    end

    if self.Y < ArenaLimit.Y1 then
        self.Y = ArenaLimit.Y1
        self.VelY = 0;
    elseif self.Y + self.Height > ArenaLimit.Y2 then
        self.Y = ArenaLimit.Y2 - self.Height
        self.VelY = 0;
    end

    self.FlyingVel = (((self.X - ArenaLimit.X1) / ArenaLimit.X2) * (self.MinFlyingVel - self.MaxFlyingVel)) + self.MinFlyingVel
    self.X = self.X + self.FlyingVel * dt
    
    local mx, my = love.mouse.getPosition()
    mx, my = Camera.toCameraCoords(mx, my)
    for i, cannon in ipairs(self.Cannons) do
        cannon:onUpdate(dt, mx, my)
    end

    self.BulletPool:onUpdate(dt, targets)
end


function Fortress:onDraw()
    self.BulletPool:onDraw()

    for i, cannon in ipairs(self.Cannons) do
        cannon:onDraw()
    end

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode("alpha")
    love.graphics.draw(self.Tex, self.X, self.Y)
end

