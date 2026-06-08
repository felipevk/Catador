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

    GameModes = {
        ATTACK = 1,
        DEFENSE = 2
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
        increaseTimeWithCollision = false
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
        setIncreaseTimeWithCollision = function() self.modifiers.increaseTimeWithCollision = true end
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
        setIncreaseTimeWithCollision = 'Time on collision',
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
            descriptions = {self.fxDescriptions.increaseHands}, 
            effects = {self.effects.increaseHands}
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

    self.timeTracker = self.area:addGameObject('TimeTracker', 0, 0, {play = self, modifiers = self.modifiers})

    self.score = self.area:addGameObject('Score', 0, 0, {play = self, modifiers = self.modifiers, timeTracker = self.timeTracker})

    self.shop = self.area:addGameObject('ShopOverlay', 0, 0, {play = self})

    self.drop = nil

    self.spawnerData = {
        bowler = {sprite = sprites.bowler, timeToSpawn = 2}
    }

    self.levelData = {
        {mode = GameModes.ATTACK, goal = 2, time = 10, spawners = {'bowler'}},
        {mode = GameModes.DEFENSE, goal = 2, time = 10, spawners = {'bowler', 'bowler'}},
        {mode = GameModes.ATTACK, goal = 2, time = 10, spawners = {'bowler', 'bowler', 'bowler'}},
        {mode = GameModes.DEFENSE, goal = 2, time = 10, spawners = {'bowler', 'bowler', 'bowler'}}
    }

    self.current_level = 0


    self:newLevel()
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

    self.current_level = self.current_level + 1

    local current_level_data = self.levelData[self.current_level]

    self.gameMode = current_level_data.mode

    self.score:start(current_level_data.goal * self.modifiers.goalScoreMult)
    self.timeTracker:start(current_level_data.time + self.modifiers.additionalTime)

    self.player = self.area:addGameObject('Player', 0, 0, {modifiers = self.modifiers, drop = self.drop, timeTracker = self.timeTracker})

    local dropPos = {
        {gw / 2, 150},
        {gw / 2, gh - 150}
    }

    local selectedPos = dropPos[self.gameMode]

    if self.drop ~= nil then self.drop:die() end

    self.drop = self.area:addGameObject('Drop', selectedPos[1], selectedPos[2], {
        gameMode = self.gameMode, 
        sprite = sprites.drop, 
        w = 501, h = 235, 
        score = self.score,
        modifiers = self.modifiers
        })
    local spawnerDepth = 1
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
                modifiers = self.modifiers,
                sprite = spawnerData.sprite,
                timeToSpawn = spawnerData.timeToSpawn,
                depth = spawnerDepth
            })

            spawnerDepth = spawnerDepth + 1
        end
    )

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

    self.player:clearJoints()
    self.player:die()

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
        self.shop:show(function() self:newLevel() end) 
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
        love.graphics.setFont(self.demoFont)
        local modeText = "Attack"
        if self.gameMode == GameModes.DEFENSE then modeText = "Defense" end
        printInsideRect(modeText, self.demoFont, "bottom")
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

return Play