EnemyManager = {}
function EnemyManager:new(parent, x, y)
    local t = {}
    setmetatable(t, self)
    self.__index = self
    
    t.Parent = parent
    t.Targets = {}
    t.SizeX, t.SizeY = x, y
    t.ActiveEnemies = {}
    t.ActiveEnemiesCount = 0
    t.IdleEnemies = {}
    t.IdleEnemiesCount = 0
    t.Targets = {}
    t.DestroyedQueue = {}
    t.BulletPool = BulletPool:new()

    return t
end


function EnemyManager:count()
    return self.ActiveEnemiesCount + self.IdleEnemiesCount
end


function EnemyManager:onUpdate(dt)
    self:cleanup()
    for k, _ in pairs(self.ActiveEnemies) do k:onUpdate(dt) end
    self.BulletPool:onUpdate(dt, self.Targets)
end


function EnemyManager:onDraw()
    for k, _ in pairs(self.ActiveEnemies) do k:onDraw() end
    self.BulletPool:onDraw()
end


function EnemyManager:addEnemy(name, x, y)
    local e = love.filesystem.load("enemy/" .. name .. ".lua")():new(self, x, y)
    e:setTarget(self:getRandomTarget())
    self.IdleEnemies[e] = true
    self.IdleEnemiesCount = self.IdleEnemiesCount + 1
end


function EnemyManager:cleanup()
    local wakeupList = {}
    for k, _ in pairs(self.IdleEnemies) do
        if Camera.bbInArena(k.X, k.Y, k.X + k.Width, k.Y + k.Height) then
            wakeupList[k] = true
        end
    end

    for k, _ in pairs(wakeupList) do
        self.ActiveEnemies[k] = true
        self.ActiveEnemiesCount = self.ActiveEnemiesCount + 1
        self.IdleEnemies[k] = nil
        self.IdleEnemiesCount = self.IdleEnemiesCount - 1
    end

    local destroyList = {}
    -- Out of screen
    for k, _ in pairs(self.ActiveEnemies) do
        if not Camera.bbInArena(k.X, k.Y, k.X + k.Width, k.Y + k.Height) then
            destroyList[k] = true
        end
    end
    -- Destroyed
    for k, _ in pairs(self.DestroyedQueue) do destroyList[k] = k end
    self.DestroyedQueue = {}

    for k, _ in pairs(destroyList) do
        self.ActiveEnemies[k] = nil
        self.ActiveEnemiesCount = self.ActiveEnemiesCount - 1
    end

end


function EnemyManager:notityDestroyed(e)
    if not self.DestroyedQueue[e] then
        self.Parent:score()
        self.DestroyedQueue[e] = true
    end
end


function EnemyManager:addTarget(target)
    table.insert(self.Targets, target)
end


function EnemyManager:getRandomTarget()
    return self.Targets[math.random(table.getn(self.Targets))]
end


function EnemyManager:getActive()
    return self.ActiveEnemies
end


function BasicEnemyUpdate(e, dt)
    

    e.X = e.X + e.VelX * dt
    e.Y = e.Y + e.VelY * dt
    for _, v in pairs(e.Cannons) do v:onUpdate(dt) end
end
