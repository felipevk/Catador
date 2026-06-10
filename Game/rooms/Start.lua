local Start = Object:extend()
local unpack = _G.unpack or table.unpack

function Start:new()
    self.area = Area(self)
    self.timer = Timer()
    self.area:addPhysicsWorld()
    self.room_canvas = love.graphics.newCanvas(gw, gh)

    self.demoFont = love.graphics.newFont(40)

    --self.area:addGameObject('TestObj', gw / 2, gh /2 , {})

    self.a = 0

    self.timer:tween(1.0, self, {a = 1}, 'in-out-cubic')

    self.title = 'Catador'

    self.titleFontsBackground = {
        fonts.jogrungeM,
        fonts.friendlySansM,
        fonts.angelicM,
        fonts.pixelatedEleganceM,
        fonts.latinaPopularM,
        fonts.anotherTypewritterM,
        fonts.vinqueAntiqueM
    }

    self.titleFontsForeground = {
        fonts.jogrungeL,
        fonts.friendlySansL,
        fonts.angelicL,
        fonts.pixelatedEleganceL,
        fonts.latinaPopularL,
        fonts.anotherTypewritterL,
        fonts.vinqueAntiqueL
    }

    self.timer:every(2,
            function()
                self.area:addGameObject('CollisionEffect', gw / 2, gh / 2 - 300, {
                    duration = 0.5, speed = 300, height = 20, color = colors.red, min = 10, max = 20
                })
            end)
end

function Start:update(dt)
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)

    if self.timer then self.timer:update(dt) end
    
    self.area:update(dt)

    if input:pressed('click') then
        self:transitionOut()
    end
end

function Start:transitionOut()
    if self.out then return end

    self.out = true

    gotoRoom('Play')

end

-- 0 gives 1
-- 0.5 gives half size
-- 1 gives size

--[[
    Creates a canvas with the game resolution and resizes it to fit the scale
]]
function Start:draw()
    love.graphics.setCanvas(self.room_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
        self.area:draw()
        local fontIndex = math.floor(1 + (self.a * (#self.titleFontsBackground - 1)))

        local titleFontBackground = self.titleFontsBackground[fontIndex]
        love.graphics.setFont(titleFontBackground)
        love.graphics.setColor(1, 1, 1, 1)
        printInsideRect(self.title, titleFontBackground, "center")

        local titleFontForeground = self.titleFontsForeground[fontIndex]
        love.graphics.setFont(titleFontForeground)
        love.graphics.setColor(0, 0, 0, 1)
        printInsideRect(self.title, titleFontForeground, "center")
  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.setShader(getMainShader())
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setShader()
    love.graphics.setBlendMode('alpha')
end

return Start