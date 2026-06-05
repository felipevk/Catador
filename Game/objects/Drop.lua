local Drop = GameObject:extend()

function Drop:new(area, x, y, opts)
    Drop.super.new(self, area, x, y, opts)

    self.sprite = opts.sprite
    self.w,self.h = opts.w,opts.h

    self.wallColData = {
        {x = 1384, y = 756, w = 66, h  = 236},
        {x = 1386, y = 938, w = 452, h = 48},
        {x = 1760, y = 754, w = 128, h = 234}
    }

    self.wallColliders = {}
    for i = 1,3 do
        self.wallColliders[i] = self.area.world:newRectangleCollider(
            self.wallColData[i].x, 
            self.wallColData[i].y, 
            self.wallColData[i].w,
            self.wallColData[i].h
        )

        self.wallColliders[i]:setCollisionClass('DropWall')
        self.wallColliders[i]:setObject(self)
        self.wallColliders[i]:setFixedRotation(false)
        self.wallColliders[i]:setType('static')
    end
end

function Drop:update(dt)
    Drop.super.update(self, dt)

    local hits = self.area.world:queryRectangleArea(
        1452, 
        840, 
        306,
        112,
        {'Collectable'})

    for _, collider in ipairs(hits) do
        local collectable = collider:getObject()
        if not collectable.consumed then
            collectable:consume()
        end
    end
end 

function Drop:draw()
    love.graphics.draw(self.sprite, self.x, self.y, 0, 1, 1, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
end

function Drop:destroy()
   Drop.super.destroy(self)
end

return Drop