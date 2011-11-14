require 'sound'

States = {}
CurrentState = nil
Input = {}

Input.MoveUp = "w"
Input.MoveDown = "s"
Input.MoveLeft = "a"
Input.MoveRight = "d"
Input.Fire = "l"


function love.load()
    math.randomseed(os.time())

    font = love.graphics.newFont(love._vera_ttf, 10)

	love.graphics.setFont(font)
	love.graphics.setColor(200, 200, 200)

    setState("menu")
end


function love.update(dt)
    CurrentState:onUpdate(dt)
    love.audio.update()
end


function love.draw()
    CurrentState:onDraw()
end


function love.mousepressed(x, y, button)
    CurrentState:onMousePressed(x, y, button)
end


function love.mousereleased(x, y, button)
    CurrentState:onMouseReleased(x, y, button)
end

function love.keypressed(key)
    CurrentState:onKeyPressed(key)
end


function love.keyreleased(key)
    CurrentState:onKeyReleased(key)
end


function setState(stateName, ...)
    if CurrentState then CurrentState:onEnd() end
    local lastState = CurrentState
    
    CurrentState = love.filesystem.load(stateName .. ".lua")()
    CurrentState:onBegin(lastState, ...)
end
