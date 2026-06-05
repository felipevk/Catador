local Play = Object:extend()

function Play:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    self.area.world:addCollisionClass('Player')
    self.room_canvas = love.graphics.newCanvas(gw, gh)

    self.demoFont = love.graphics.newFont(40)

    self.player = self.area:addGameObject('Player', 0, 0, {})
end

function Play:update(dt)
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)
    
    self.area:update(dt)

    if input:pressed('exit') then
        gotoRoom("Credits")
    end
end

--[[
    Creates a canvas with the game resolution and resizes it to fit the scale
]]
function Play:draw()
    love.graphics.setCanvas(self.room_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
        self.area:draw()
        love.graphics.setFont(self.demoFont)
        printInsideRect("Play", self.demoFont, "center")
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

return Play