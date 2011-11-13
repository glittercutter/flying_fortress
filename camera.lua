local HUD_HEIGHT = 50

ArenaLimit = {X1 = 0, Y1 = HUD_HEIGHT, X2 = love.graphics.getWidth(), Y2 = love.graphics.getHeight()}
Camera = {}
local X = 0
local Y = 0

function Camera.draw(x, y, func)
    X, Y = x, y
    love.graphics.push()
    love.graphics.translate(-x, -y)
    ArenaLimit = {X1 = 0 + x, Y1 = HUD_HEIGHT + y, X2 = love.graphics.getWidth() + x, Y2 = love.graphics.getHeight() + y}
    func()
    love.graphics.pop()
end

function Camera.pointInArena(x, y)
    if x < ArenaLimit.X1 or x > ArenaLimit.X2 or y < ArenaLimit.Y1 or y > ArenaLimit.Y2 then return false end
    return true
end

function Camera.bbInArena(x1, y1, x2, y2)
    return x1 < ArenaLimit.X2 and x2 > ArenaLimit.X1 and y1 < ArenaLimit.Y2 and y2 > ArenaLimit.Y1
end

function Camera.toCameraCoords(x, y)
    return x + X, y + Y
end

function Camera.reset()
    X, Y = 0, 0
    ArenaLimit = {X1 = 0, Y1 = HUD_HEIGHT, X2 = love.graphics.getWidth(), Y2 = love.graphics.getHeight()}
end
