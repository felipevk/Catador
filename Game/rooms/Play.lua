local Play = Object:extend()

function Play:new()
    self.area = Area(self)
    self.timer = Timer()
    self.area:addPhysicsWorld()
    self.area.world:addCollisionClass('Player')
    self.area.world:addCollisionClass('Collectable')
    self.area.world:addCollisionClass('DropWall')
    self.room_canvas = love.graphics.newCanvas(gw, gh)

    self.demoFont = love.graphics.newFont(40)

    self.score = self.area:addGameObject('Score', 0, 0, {play = self})

    self.timeTracker = self.area:addGameObject('TimeTracker', 0, 0, {play = self})

    self.drop = self.area:addGameObject('Drop', 1640, 870, {sprite = sprites.drop, w = 501, h = 235, score = self.score})

    self.spawnerData = {
        bowler = {sprite = sprites.bowler, timeToSpawn = 2}
    }

    self.levelData = {
        {goal = 2, time = 10, spawners = {'bowler'}},
        {goal = 3, time = 10, spawners = {'bowler', 'bowler'}},
        {goal = 3, time = 10, spawners = {'bowler', 'bowler', 'bowler'}}
    }

    self.current_level = 0


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

    self.current_level = self.current_level + 1

    local current_level_data = self.levelData[self.current_level]

    self.score:start(current_level_data.goal)
    self.timeTracker:start(current_level_data.time)

    M.each(current_level_data.spawners, 
        function(spawnerKey, _)
            local spawnerData = self.spawnerData[spawnerKey]
            local pos = {random(200, 1400), 100}
            self.area:addGameObject('Spawner', pos[1], pos[2], {
                sprite = spawnerData.sprite,
                timeToSpawn = spawnerData.timeToSpawn
            })
        end
    )

    self.player = self.area:addGameObject('Player', 0, 0, {hands = 1})

    --TODO load level data
end

function Play:finishLevel(isWin)
    local toLeave = self.area:getGameObjects(
        function(obj)
            return obj.class == 'Collectable' or obj.class == 'Spawner'
        end
    )

    if toLeave ~= nil then
        M.each(toLeave, 
            function(o, _)
                o:transitionOut()
            end
        )
    end

    self.player:destroy()

    self.timeTracker:stop()
    --TODO check win condition and open shop

    if isWin then
        -- TODO check if last level complete
        self.area:addGameObject('RoundCompleteEffect', 0, 0)
        self.timer:after(1, function() self:afterRoundComplete() end)
    else
        self.area:addGameObject('GameOverEffect', 0, 0)
        self.timer:after(2, function() gotoRoom("Credits") end)
    end
end

function Play:isLastLevel()
    return self.current_level == #self.levelData
end

function Play:afterRoundComplete()
    if self:isLastLevel() then
        self.area:addGameObject('GameFinishedEffect', 0, 0)
        self.timer:after(2, function() gotoRoom("Credits") end)
    else
        self:newLevel() 
    end
end

function Play:update(dt)
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)

    if self.timer then self.timer:update(dt) end
    
    self.area:update(dt)

    if input:pressed('exit') then
        gotoRoom("Credits")
    end

    if input:pressed('autowin') then
        self:finishLevel(true)
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