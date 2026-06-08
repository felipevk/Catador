local Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    self.handCount = opts.modifiers.hands
    self.drop = opts.drop
    self.timeTracker = opts.timeTracker

    self.handData = {
        {sprite = { asset = sprites.hand1, position = {x = 0, y = 0} }, collider={x = 0, y = 0, w = 194, h = 74}},
        {sprite = { asset = sprites.hand1, position = {x = 300, y = 0} }, collider={x = 300, y = 0, w = 194, h = 74}},
        {sprite = { asset = sprites.hand1, position = {x = 80, y = -270} }, collider={x = 80, y = -270, w = 194, h = 74}},
        {sprite = { asset = sprites.hand1, position = {x = -250, y = 0} }, collider={x = -250, y = 0, w = 194, h = 74}},
        {sprite = { asset = sprites.hand1, position = {x = 100, y = 20} }, collider={x = 100, y = 20, w = 194, h = 74}},
        {sprite = { asset = sprites.hand1, position = {x = -200, y = -150} }, collider={x = -200, y = -150, w = 194, h = 74}}
    }

    self.colliders = {}
    self.sprites = {}
    self.joints = {}

    for i = 1, self.handCount do
        self.sprites[i] = self.handData[i].sprite.asset

        self.colliders[i] = self.area.world:newRectangleCollider(
            self.x + self.handData[i].collider.x , 
            self.y + self.handData[i].collider.y, 
            self.handData[i].collider.w, 
            self.handData[i].collider.h)

        self.colliders[i]:setCollisionClass('Player')
        self.colliders[i]:setFixedRotation(true)
        self.colliders[i]:setType('kinematic')
    end

    self.isClick = false
end

function Player:update(dt)
    Player.super.update(self, dt)

    local clicking = input:down('click') == true

    if clicking ~= self.isClick then
        self:ToggleClick(clicking)
    end

    self.x = love.mouse.getX() / sx
    self.y = love.mouse.getY() / sy

    for i = 1, self.handCount do
        local handCol = self.colliders[i]

        local x = self.x + self.handData[i].collider.x
        local y = self.y + self.handData[i].collider.y
        local w = self.handData[i].collider.w
        local h = self.handData[i].collider.h

        handCol:setX(x)
        handCol:setY(y)

        if not self.modifiers.sticky and not self.modifiers.split and not self.modifiers.increaseTimeWithCollision then break end

        local rect = {
            x = x - w / 2,
            y = y - h / 2,
            w = w,
            h = h
        }
        local hits = self.area.world:queryRectangleArea(
            rect.x, 
            rect.y, 
            rect.w,
            rect.h,
            {'Collectable'}
        )

        local handCenter = getCenter(rect)

        for _, collectableCol in ipairs(hits) do
            local collectable = collectableCol:getObject()

            if self.modifiers.increaseTimeWithCollision and not collectable.consumed then
                self.timeTracker:addTime(0.06)
            end

            if self.modifiers.split and not collectable.consumed and not collectable.split and not collectable.dead then
                self:splitCollectable(collectableCol)
                break
            end

            if self.modifiers.sticky and not collectable.consumed and not collectable.isAttached then
                self:stickToCollectable(collectableCol, handCol, handCenter)
            end
        end

    end

    for i = #self.joints, 1, -1 do
        if self.joints[i].attached.out then
            self.joints[i].j:destroy()
            table.remove(self.joints, i)
        end
    end
end 

function Player:stickToCollectable(collectableCol, handCol, handCenter)
    local collectable = collectableCol:getObject()
    print(collectable, collectableCol)
    local joint = love.physics.newRopeJoint(
        handCol.body,
        collectableCol.body,
        handCenter.x, handCenter.y,
        collectableCol:getX(), collectableCol:getY(),
        400,
        true
    )
    local newId = UUID()
    table.insert(self.joints, {idx = newId, j = joint, attached = collectable})

    --print('Created joint with id '.. newId)
    --print(self.joints, #self.joints)
    
    collectable.isAttached = true
end

function Player:splitCollectable(collectableCol)
    local collectable = collectableCol:getObject()
    local spawnPos = { x = collectableCol:getX(), y = collectableCol:getY()}
    collectable:die()

    local spawnForces = {
        {-20000, -5000},
        {0, -9000},
        {20000, -5000}
    }
    for i = 1, 3 do
        local col = self.area:addGameObject('Collectable', spawnPos.x, spawnPos.y, {
            sprite = sprites.tennisBall,
            colW = 76,
            colH = 72,
            modifiers = self.modifiers,
            drop = self.drop
        })
        col:applyForce(unpack(spawnForces[i]))
        col.split = true
    end
end

function Player:hasUsedJointID(id)
    for index, value in ipairs(self.usedIds) do
        if value == id then
            return true
        end
    end
    return false
end

function Player:ToggleClick(toggle)
    self.isClick = toggle

    for i = 1, self.handCount do
        self.colliders[i]:setSensor(self.isClick)
    end
end

function Player:clearJoint(id)
    --print('Trying to clear joint '..id)
    --print(self.joints, #self.joints)
    local cleared = false
    for i, jointEntry in ipairs(self.joints) do
        --print('Checking joint with id: '..jointEntry.idx)
        if jointEntry.idx == id then 
            table.remove(self.joints, i)
            jointEntry.j:destroy()
            cleared = true
            --print('Joint cleared')
            break 
        end
    end
    --if not cleared then error("Something went wrong with the game logic!") end
end

function Player:clearJoints()
    for i = 1, #self.joints do
        self.joints[i].j:destroy()
    end
    self.joints = {}
end

function Player:draw()
    love.graphics.setColor(1, 1, 1, self.isClick and 0.5 or 1)
    for i = 1, self.handCount do
        local spriteData = self.handData[i].sprite
        love.graphics.draw(
            spriteData.asset, 
            self.x + spriteData.position.x, 
            self.y + spriteData.position.y, 
            0, nil, nil, 
            spriteData.asset:getWidth() / 2, 
            spriteData.asset:getHeight() / 2)

        self.colliders[i]:setX(self.x + self.handData[i].collider.x)
        self.colliders[i]:setY(self.y + self.handData[i].collider.y)
    end
    
    for i, jointEntry in ipairs(self.joints) do
        if not jointEntry.j then break end

        if jointEntry.j and not jointEntry.j:isDestroyed() then
            local x1, y1, x2, y2 = jointEntry.j:getAnchors()
            love.graphics.setColor(unpack(colors.orange))
            love.graphics.setLineWidth(5)
            love.graphics.line(x1, y1, x2, y2)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function Player:die()
    self.dead = true
end

function Player:destroy()
   Player.super.destroy(self)

   for _, collider in ipairs(self.colliders) do
    collider:destroy()
   end
end

return Player
