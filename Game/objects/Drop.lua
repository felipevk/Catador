local Drop = GameObject:extend()

function Drop:new(area, x, y, opts)
    Drop.super.new(self, area, x, y, opts)

    self.gameMode = opts.gameMode

    self.sprite = opts.sprite
    self.w,self.h = opts.w,opts.h

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
end

function Drop:update(dt)
    Drop.super.update(self, dt)

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
            self.score:add(1)
        end
    end
end 

function Drop:draw()
    local r = (self.gameMode == GameModes.ATTACK) and math.pi or 0
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