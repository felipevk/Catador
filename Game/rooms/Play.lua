local Play = Object:extend()

function Play:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    self.area.world:addCollisionClass('Player')
    self.area.world:addCollisionClass('Collectable')
    self.area.world:addCollisionClass('DropWall')
    self.room_canvas = love.graphics.newCanvas(gw, gh)

    self.demoFont = love.graphics.newFont(40)

    self.player = self.area:addGameObject('Player', 0, 0, {hands = 1})

    self.score = self.area:addGameObject('Score', 0, 0, {play = self})

    self.drop = self.area:addGameObject('Drop', 1640, 870, {sprite = sprites.drop, w = 501, h = 235, score = self.score})

    self:newLevel()
end

function Play:newLevel()
    local collectables = self.area:getGameObjects(
        function(obj)
            return obj.class == 'Collectable' or obj.class == 'Spawner'
        end
    )

    if collectables ~= nil then
        M.each(collectables, 
            function(o, _)
                o:die()
            end
        )
    end

    self.score:start(2)

    self.spawner = self.area:addGameObject('Spawner', gw / 2, 100, {
        sprite = sprites.bowler,
        timeToSpawn = 2
    })

    --TODO load level data
end

function Play:finishLevel(isWin)
    local toLeave = self.area:getGameObjects(
        function(obj)
            return obj.class == 'Collectable' or obj.class == 'Spawner'
        end
    )

    if toLeave ~= nil then
        print(toLeave[1])
        M.each(toLeave, 
            function(o, _)
                o:transitionOut()
            end
        )
    end

    --TODO check win condition and open shop
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
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

return Play