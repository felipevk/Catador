local Play = Object:extend()

function Play:new()
    self.area = Area(self)
    self.timer = Timer()
    self.area:addPhysicsWorld()
    self.area.world:addCollisionClass('Player')
    self.area.world:addCollisionClass('Collectable')
    self.area.world:addCollisionClass('DropWall')
    self.area.world:addCollisionClass('CharmDisplay')
    self.room_canvas = love.graphics.newCanvas(gw, gh)

    self.demoFont = love.graphics.newFont(40)

    GameModes = {
        ATTACK = 1,
        DEFENSE = 2
    }

    self.spawnerData = {
        bowler = {sprite = sprites.bowler, timeToSpawn = 2, spawnForces = { {1000, -500},{0, 1000} }, velocity = 100},
        basket = {sprite = sprites.basket, timeToSpawn = 1.5, spawnForces = { {1000, -500},{0, 1000} }, velocity = 200},
        tennis = {sprite = sprites.tennis, timeToSpawn = 0.8, spawnForces = { {1000, -500},{0, 1000} }, velocity = 150}
    }

    self.levelData = {
        -- ATTACK
        { 
            { goal = 2, time = 10, spawners = {'tennis'} }, 
            --{ goal = 2, time = 12, spawners = {'bowler', 'basket'} }, 
            --{ goal = 4, time = 10, spawners = {'bowler', 'tennis', 'basket'} }, 
            --{ goal = 6, time = 11, spawners = {'basket', 'tennis', 'bowler'} }, 
            --{ goal = 6, time = 9, spawners = {'basket', 'tennis', 'bowler', 'bowler'} }, 
            --{ goal = 8, time = 13, spawners = {'bowler', 'tennis', 'basket', 'tennis', 'bowler', 'bowler'} }
        },
       
        -- DEFENSE
        { 
            { goal = 4, time = 10, spawners = {'bowler', 'basket'} }, 
            --{ goal = 4, time = 10, spawners = {'bowler', 'bowler', 'bowler'} }, 
            --{ goal = 5, time = 8, spawners = {'tennis', 'basket', 'tennis'} }, 
           --{ goal = 6, time = 5, spawners = {'tennis', 'tennis', 'tennis'} }, 
            --{ goal = 6, time = 10, spawners = {'basket', 'tennis', 'basket'} } , 
            --{ goal = 5, time = 15, spawners = {'basket', 'tennis', 'basket', 'basket', 'bowler'} } 
        }
    }

    self.collectableData = {
        { sprite = sprites.car1, w = 280, h = 184 },
        { sprite = sprites.tennisBall, w = 76, h = 72 },
        { sprite = sprites.tennisRacket, w = 270, h = 100 },
        { sprite = sprites.ptero, w = 334, h = 74 },
        { sprite = sprites.lizard, w = 90, h = 302 }
    }

    self.modifiers = {
        hands = 1,
        goalScoreMult = 1, -- objective
        additionalTime = 0,
        scoreMult = 1, --value of each collectable
        bouncy = false,
        sticky = false,
        homing = false,
        increaseTimeWithScore = false, -- every X points increase time by 1 second
        split = false,
        increaseTimeWithCollision = false,
        modeSelectSpeed = 7000
    }

    self.effects = {
        nothing = function() end,
        increaseHands = function() self.modifiers.hands = self.modifiers.hands + 1 end,
        increaseTime = function() self.modifiers.additionalTime = self.modifiers.additionalTime + 3 end,
        setScoreMult2 = function() self.modifiers.scoreMult = 2 end,
        setBouncy = function() self.modifiers.bouncy = true end,
        setSticky= function() self.modifiers.sticky = true end,
        setHoming = function() self.modifiers.homing = true end,
        setIncreaseTimeWithScore = function() self.modifiers.increaseTimeWithScore = true end,
        setSplit = function() self.modifiers.split = true end,
        setIncreaseTimeWithCollision = function() self.modifiers.increaseTimeWithCollision = true end,
        setSlowSelectSpeed = function() self.modifiers.modeSelectSpeed = 600 end
    }

    self.fxDescriptions = {
        nothing = 'Nothing',
        increaseHands = '+1 hand',
        increaseTime = 'Additional time',
        setScoreMult2 = 'Score more points',
        setBouncy = 'Bouncy',
        setSticky = 'Sticky',
        setHoming = 'Homing',
        setIncreaseTimeWithScore = 'Time on score',
        setSplit = 'Break things',
        setIncreaseTimeWithCollision = 'Time on touch',
        setSlowSelectSpeed = 'Better Life Choices'
    }

    self.charmData = {
        {
            name = 'Journey', sprite = sprites.charm1, color = colors.purple, 
            descriptions = {self.fxDescriptions.increaseHands, self.fxDescriptions.increaseTime}, 
            effects = {self.effects.increaseHands, self.effects.increaseTime}
        },
        {
            name = 'Face', sprite = sprites.charm2, color = colors.red, 
            descriptions = {self.fxDescriptions.increaseHands}, 
            effects = {self.effects.increaseHands}
        },
        {
            name = 'Mill', sprite = sprites.charm3, color = colors.pink, 
            descriptions = {self.fxDescriptions.setIncreaseTimeWithCollision}, 
            effects = {self.effects.setIncreaseTimeWithCollision}
        },
        {
            name = 'Bless', sprite = sprites.charm4, color = colors.blue, 
            descriptions = {self.fxDescriptions.increaseHands, self.fxDescriptions.setSlowSelectSpeed}, 
            effects = {self.effects.increaseHands, self.effects.setSlowSelectSpeed}
        },
        {
            name = 'Elder', sprite = sprites.charm5, color = colors.cyan, 
            descriptions = {self.fxDescriptions.increaseTime}, 
            effects = {self.effects.increaseTime}
        },
        {
            name = 'Graveyard', sprite = sprites.charm6, color = colors.green, 
            descriptions = {self.fxDescriptions.setScoreMult2}, 
            effects = {self.effects.setScoreMult2}
        },
        {
            name = 'Yeller', sprite = sprites.charm7, color = colors.yellow, 
            descriptions = {self.fxDescriptions.setBouncy}, 
            effects = {self.effects.setBouncy}
        },
        {
            name = 'Tree', sprite = sprites.charm8, color = colors.orange, 
            descriptions = {self.fxDescriptions.setSticky}, 
            effects = {self.effects.setSticky}
        },
        {
            name = 'Gnome', sprite = sprites.charm9, color = colors.purple, 
            descriptions = {self.fxDescriptions.setHoming}, 
            effects = {self.effects.setHoming}
        },
        {
            name = 'Babuska', sprite = sprites.charm10, color = colors.red, 
            descriptions = {self.fxDescriptions.setIncreaseTimeWithScore}, 
            effects = {self.effects.setIncreaseTimeWithScore}
        },
        {
            name = 'Queen', sprite = sprites.charm11, color = colors.blue, 
            descriptions = {self.fxDescriptions.setSplit}, 
            effects = {self.effects.setSplit}
        }
    }

    self.availableCharms = {}
    for i = 1,#self.charmData do
        self.availableCharms[i] = i
    end

    self.activeCharms = {}

    self.gameMode = 0

    self.timeTracker = self.area:addGameObject('TimeTracker', gw * 0.95, gh, {play = self, modifiers = self.modifiers})

    self.score = self.area:addGameObject('Score', 112, gh * 0.93, {play = self, modifiers = self.modifiers, timeTracker = self.timeTracker})

    self.shop = self.area:addGameObject('ShopOverlay', 0, 0, {play = self})

    self.charmDisplay = self.area:addGameObject('CharmDisplay', gw * 0.9, 25, {})

    self.roundCompleteEffect = self.area:addGameObject('RoundCompleteEffect', 0, 0)

    self.gameModeOverlay = self.area:addGameObject('GameModeOverlay', 0, 0)

    self.drop = nil

    self.current_level = 0

    self.gameModeOverlay:show(self.modifiers.modeSelectSpeed,
        function(selectedMode)
            self.gameMode = selectedMode
            self:newLevel()
        end
    )
end

function Play:getShopOptions()
    local first = love.math.random(#self.availableCharms)
    --local first = 3
    local second = first
    --local second = 8
    while second == first do second = love.math.random(#self.availableCharms) end

    -- will return indexes
    return {self.availableCharms[first], self.availableCharms[second]}
end

function Play:activateCharm(charmIndex)
    for i, v in ipairs(self.availableCharms) do
        if v == charmIndex then
            table.remove(self.availableCharms, i)
            break
        end
    end

    table.insert(self.activeCharms, charmIndex)

    local selectedCharmData = self.charmData[charmIndex]

    for i = 1, #selectedCharmData.effects do
        selectedCharmData.effects[i]()
    end

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

    if self.drop ~= nil then self.drop:die() end

    self.current_level = self.current_level + 1

    local current_level_data = self.levelData[self.gameMode][self.current_level]

    self.drop = self.area:addGameObject('Drop', 0, 0, {
        gameMode = self.gameMode, 
        sprite = sprites.drop, 
        w = 501, h = 235, 
        score = self.score,
        modifiers = self.modifiers
        })
    self.drop:setActive(true)

    self.score:show(current_level_data.goal * self.modifiers.goalScoreMult)
    self.timeTracker:start(current_level_data.time + self.modifiers.additionalTime)

    self.player = self.area:addGameObject('Player', 0, 0, {modifiers = self.modifiers, drop = self.drop, timeTracker = self.timeTracker})
    
    local spawnerDepth = 10
    
    M.each(current_level_data.spawners, 
        function(spawnerKey, _)
            local spawnerData = self.spawnerData[spawnerKey]
            local pos = {}
            if self.gameMode == GameModes.ATTACK then
                pos = {50, love.math.random(100, 600)}
            else
                pos = {love.math.random(200, 1400), 100}
            end
            
            self.area:addGameObject('Spawner', pos[1], pos[2], {
                gameMode = self.gameMode,
                drop = self.drop,
                collectableData = self.collectableData,
                modifiers = self.modifiers,
                sprite = spawnerData.sprite,
                timeToSpawn = spawnerData.timeToSpawn,
                spawnForces = spawnerData.spawnForces,
                velocity = spawnerData.velocity,
                depth = spawnerDepth
            })

            spawnerDepth = spawnerDepth + 1
        end
    )

    local activeCharmsData = {}
    for _, i in ipairs(self.activeCharms) do
        table.insert(activeCharmsData, self.charmData[i])
    end
    self.charmDisplay:setCharms(activeCharmsData)

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

    self.player:clearJoints()
    self.player:die()

    self.timeTracker:stop()
    self.drop:setActive(false)

    self.score:hide()

    self.roundCompleteEffect:show(2.5, isWin)

    sounds.phoneRing:play()

    if isWin then
        self.timer:after(1.5, function() self:afterRoundComplete() end)
    else
        self.timer:after(3.5, function() gotoRoom("Credits") end)
    end
end

function Play:isLastLevel()
    return self.current_level == #self.levelData[self.gameMode]
end

function Play:afterRoundComplete()
    if self:isLastLevel() then
        self.area:addGameObject('GameFinishedEffect', 0, 0)
        self.timer:after(2, function() gotoRoom("Credits") end)
    else
        sounds.main:setVolume(0.2)
        sounds.main:setPitch(0.95)
        self.shop:show(function() 
            self:afterShop()
        end) 
    end
end

function Play:afterShop()
    self.gameModeOverlay:show(self.modifiers.modeSelectSpeed,
        function(selectedMode)
            sounds.main:setVolume(mainVolume)
            sounds.main:setPitch(1)
            self.roundCompleteEffect:hide(2.5)
            self.gameMode = selectedMode
            self:newLevel()
        end
    )
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
    love.graphics.setShader(getMainShader())
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setShader()
    love.graphics.setBlendMode('alpha')
end

return Play