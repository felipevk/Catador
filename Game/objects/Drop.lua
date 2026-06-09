local Drop = GameObject:extend()
local unpack = _G.unpack or table.unpack

function Drop:new(area, x, y, opts)
    Drop.super.new(self, area, x, y, opts)

    self.gameMode = opts.gameMode

    local dropPos = {
        {gw / 2, 150},
        {gw / 2, gh - 150}
    }

    self.x, self.y = dropPos[self.gameMode][1], dropPos[self.gameMode][2]

    self.modifiers = opts.modifiers

    self.sprite = opts.sprite
    self.w,self.h = opts.w,opts.h

    self.depth = -10

    self.fillColorR, self.fillColorG, self.fillColorB, self.fillColorA = unpack(colors.purple)
    self.timer = Timer()

    self.timer:every(2.0,
            function()
                -- wasn't able to lerp to color variable values
                -- hardcording to switch between green and purple
                self.timer:tween(
                    1.0, self, 
                    { fillColorR = 0.4784, fillColorG = 0.3333, fillColorB = 0.9255}, 
                    'in-out-cubic',
                    function()
                        self.timer:tween(1.0, self, { fillColorR = 0.3333, fillColorG = 0.9255, fillColorB = 0.6000 } , 'in-out-cubic')
                    end
                )
            end)

    self.wallColData = {
        {
            {x = 1142, y = 38, w = 66, h  = 236},
            {x = 770, y = 22, w = 452, h = 48},
            {x = 720, y = 26, w = 128, h = 234}
        },
        {
            {x = 690, y = 804, w = 80, h  = 248},
            {x = 716, y = 1000, w = 448, h = 50},
            {x = 1076, y = 816, w = 128, h = 230}
        },
    }

    self.dropArea = {
        {x = 840, y = 56, w = 306, h = 174},
        {x = 764, y = 854, w = 306, h = 174}
    }

    self.wallColliders = {}
    local selectedColData = self.wallColData[self.gameMode]
    for i = 1,3 do
        self.wallColliders[i] = self.area.world:newRectangleCollider(
            selectedColData[i].x, 
            selectedColData[i].y, 
            selectedColData[i].w,
            selectedColData[i].h
        )

        self.wallColliders[i]:setCollisionClass('DropWall')
        self.wallColliders[i]:setObject(self)
        self.wallColliders[i]:setFixedRotation(false)
        self.wallColliders[i]:setType('static')
    end

    self.score = opts.score

    self.active = false
end

function Drop:setActive(isActive)
    self.active = isActive
end

function Drop:update(dt)
    Drop.super.update(self, dt)

    if self.timer then self.timer:update(dt) end

    if not self.active then return end

    local dropArea = self.dropArea[self.gameMode]

    local hits = self.area.world:queryRectangleArea(
        dropArea.x, 
        dropArea.y, 
        dropArea.w,
        dropArea.h,
        {'Collectable'})

    for _, collider in ipairs(hits) do
        local collectable = collider:getObject()
        if not collectable.consumed then
            collectable:consume()
            self.score:add(self.modifiers.scoreMult)
        end
    end
end 

function Drop:draw()
    local r = (self.gameMode == GameModes.ATTACK) and math.pi or 0
    local offsetY = (self.gameMode == GameModes.ATTACK) and 24 or -24
    love.graphics.setColor(self.fillColorR, self.fillColorG, self.fillColorB, self.fillColorA)
    love.graphics.draw(sprites.dropFill, self.x, self.y + offsetY, r, 1, 1, sprites.dropFill:getWidth() / 2, sprites.dropFill:getHeight() / 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.sprite, self.x, self.y, r, 1, 1, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
end

function Drop:die()
    self.dead = true
end

function Drop:destroy()
    for i = 1,3 do
        self.wallColliders[i]:destroy()
    end
   Drop.super.destroy(self)
end

return Drop