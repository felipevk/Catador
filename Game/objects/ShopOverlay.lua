local ShopOverlay = GameObject:extend()
local unpack = _G.unpack or table.unpack

function ShopOverlay:new(area, x, y, opts)
    ShopOverlay.super.new(self, area, x, y, opts)

    self.play = opts.play

    self.backgroundColor = {1.0, 0.0, 0.0, 0.5}
    self.panelColor = {0.0, 0.0, 0.8, 0.9}
    
    self.optionColor = {0.0, 0.8, 1.0, 0.9} 
    self.optionOutlineColor = {1.0, 0.0, 0.0, 0.9}

    self.w, self.h = gw * 0.75 , gh * 0.75

    self.showing = false

    self.onTransitionOut = nil

    -- x,y as top left
    self.buttonData = {
        x = gw / 2 - 132,
        y = 884 - 29,
        w = 264,
        h = 58,
        text = "OK",
        color = {1.0, 1.0, 1.0, 0.9},
        hoveredColor = {0.7, 0.7, 0.7, 0.9},
        textColor = {0.0, 0.0, 0.0, 1.0}
    }

    self.optionRect = {
        {
            x = 380,
            y = 176,
            w = 546,
            h = 624,
        },
        {
            x = 994,
            y = 176,
            w = 546,
            h = 624,
        }
    }

    self.depth = 500

    self.isHovered = false

    self.shopCharms = {}

    self.selected = 0
end

function ShopOverlay:show(callback)
    self.showing = true
    self.onTransitionOut = callback

    self.shopIndexes = self.play:getShopOptions()

    self.shopCharms = {self.play.charmData[self.shopIndexes[1]], self.play.charmData[self.shopIndexes[2]]}

    self.selected = 0

    self.buttonFont = getGameFont()

    self.optionsFonts = {getGameFont(), getGameFont()}
end

function ShopOverlay:update(dt)
    ShopOverlay.super.update(self, dt)

    if not self.showing then return end

    local clicking = input:down('click') == true

    self.isHovered = self:isAreaHovered(self.buttonData)

    if self.isHovered and clicking then
        self:onOkPressed()
    end

    for i = 1, #self.optionRect do
        if self:isAreaHovered(self.optionRect[i]) and clicking then
            self:onOptionSelected(i)
        end
    end

end 

function ShopOverlay:onOkPressed()
    if self.selected == 0 then return end

    self.play:activateCharm(self.shopIndexes[self.selected])

    self:hide()

end

function ShopOverlay:onOptionSelected(index)
    self.selected = index
end

function ShopOverlay:hide()
    self.showing = false

    -- TODO move callback to end of transition
    self.onTransitionOut()
end

function ShopOverlay:isAreaHovered(rect)
    local mx, my = love.mouse.getPosition()

    mx = mx / sx
    my = my / sy

    return mx >= rect.x
       and mx <= rect.x + rect.w
       and my >= rect.y
       and my <= rect.y + rect.h
end

function ShopOverlay:draw()
    if not self.showing then return end

    local buttonRect = {x = self.buttonData.x, y = self.buttonData.y , w = self.buttonData.w, h = self.buttonData.h}

    local buttonCenter = getCenter(buttonRect)

    love.graphics.setColor(unpack(self.backgroundColor))
    draft:rectangle(gw / 2, gh / 2, gw, gh, 'fill')

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        sprites.shopPanel, 
        gw / 2, gh / 2,
        0, 
        1, 1, 
        sprites.shopPanel:getWidth() / 2, 
        sprites.shopPanel:getHeight() / 2
    )

    local buttonColor = (self.isHovered) and self.buttonData.hoveredColor or self.buttonData.color
    love.graphics.setColor(unpack(buttonColor))
    draft:rectangle(buttonCenter.x, buttonCenter.y , self.buttonData.w, self.buttonData.h, 'fill')

    love.graphics.setColor(unpack(self.buttonData.textColor))
    
    printInsideRect(self.buttonData.text, self.buttonFont, 'center', 0, buttonRect)
    
    love.graphics.setColor(1, 1, 1, 1)

    for i = 1, #self.optionRect do
        self:drawOption(self.optionRect[i], self.shopCharms[i], self.selected == i, self.optionsFonts[i])
    end
end

function ShopOverlay:drawOption(rect, charmData, isSelected, font)
    local rectCenter = getCenter(rect)
    local startPadding = 20

    love.graphics.setColor({1.0,1.0,1.0,0.75})
    draft:rectangle(rectCenter.x, rectCenter.y , rect.w, rect.h, 'fill')

    if isSelected then
        love.graphics.setColor(unpack(self.optionOutlineColor))
        love.graphics.setLineWidth(20)
        draft:rectangle(rectCenter.x, rectCenter.y , rect.w, rect.h, 'line')
        love.graphics.setLineWidth(1)
    end

    love.graphics.setColor({0.0,0.0,0.0,1.0})
    local lineHeight = font:getHeight()

    love.graphics.setFont(font)
    printInsideRect(charmData.name, font, 'top', startPadding, rect)
    
    love.graphics.setColor(unpack(charmData.color))
    local sprite = charmData.sprite
    local spriteScale = 0.75
    love.graphics.draw(
        charmData.sprite, 
        rectCenter.x, 
        rect.y + startPadding + lineHeight + 5, 
        0, 
        spriteScale, spriteScale, 
        sprite:getWidth() / 2, 
        0
    )

    love.graphics.setFont(font)
    love.graphics.setColor({0.0,0.0,0.0,1.0})

    local startTextY = rect.y + (sprite:getHeight() * spriteScale) + startPadding + 25
    for i = 1 , #charmData.descriptions do
        local text = charmData.descriptions[i]
        local textRect = {
            x = rectCenter.x - font:getWidth(text) / 2, 
            y = startTextY + i * (lineHeight + 5), 
            w = font:getWidth(text), 
            h = font:getHeight()
        }
        --text, font, side, offset, rect
        printInsideRect(text, font, 'center', 0, textRect)
    end
end

function ShopOverlay:die()
    self.dead = true
end

function ShopOverlay:destroy()
   ShopOverlay.super.destroy(self)
end

return ShopOverlay