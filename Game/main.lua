Object = require 'libraries/classic/classic'
Input = require 'libraries/boipushy/Input'
Timer = require 'libraries/EnhancedTimer/EnhancedTimer'
M = require "libraries/Moses/moses"
Camera = require 'libraries/hump/camera'
Vector = require 'libraries/hump/vector'
Physics = require 'libraries/windfield/windfield'
Draft = require 'libraries/draft/draft'
Anim8 = require 'libraries/anim8/anim8'
sti = require 'libraries/Simple-Tiled-Implementation/sti'

require 'libraries/utf8/utf8'
require 'globals'
require "utils"

function love.load()
    input = Input()
    timer = Timer()
    camera = Camera()
    draft = Draft()

    resize(0.8)

    GameObject = require("objects/GameObject")

    local object_files = {}
    recursiveEnumerate('objects', object_files)
    requireFiles(object_files)

    local room_files = {}
    recursiveEnumerate('rooms', room_files)
    requireFiles(room_files)
    current_room = nil

    slow_amount = 1

    flash_frames = nil

    sprites = {
        hand1 = love.graphics.newImage("resources/sprites/hand1.png"),
        hand2 = love.graphics.newImage("resources/sprites/hand2.png"),
        hand3 = love.graphics.newImage("resources/sprites/hand3.png"),
        hand4 = love.graphics.newImage("resources/sprites/hand4.png"),
        hand5 = love.graphics.newImage("resources/sprites/hand5.png"),
        hand6 = love.graphics.newImage("resources/sprites/hand6.png"),
        drop = love.graphics.newImage("resources/sprites/drop.png"),
        car1 = love.graphics.newImage("resources/sprites/car1.png"),
        bowler = love.graphics.newImage("resources/sprites/bowler.png"),
        charm1 = love.graphics.newImage("resources/sprites/charm1.jpg"),
        charm2 = love.graphics.newImage("resources/sprites/charm2.jpg"),
        charm3 = love.graphics.newImage("resources/sprites/charm3.jpg"),
        charm4 = love.graphics.newImage("resources/sprites/charm4.jpg"),
        charm5 = love.graphics.newImage("resources/sprites/charm5.jpg"),
        charm6 = love.graphics.newImage("resources/sprites/charm6.jpg"),
        charm7 = love.graphics.newImage("resources/sprites/charm7.jpg"),
        charm8 = love.graphics.newImage("resources/sprites/charm8.jpg"),
        charm9 = love.graphics.newImage("resources/sprites/charm9.jpg"),
        charm10 = love.graphics.newImage("resources/sprites/charm10.jpg"),
        charm11 = love.graphics.newImage("resources/sprites/charm11.jpg"),
        tennisBall = love.graphics.newImage("resources/sprites/tennisBall.png"),
        fishPanel = love.graphics.newImage("resources/sprites/fishPanel.jpg"),
        shopPanel = love.graphics.newImage("resources/sprites/shopPanel.jpg"),
        mainBG = love.graphics.newImage("resources/sprites/mainBackground.jpg"),
        dropFill = love.graphics.newImage("resources/sprites/dropFill.png"),
        tennis = love.graphics.newImage("resources/sprites/tennis.png"),
        basket = love.graphics.newImage("resources/sprites/basket.png"),
        tennisRacket = love.graphics.newImage("resources/sprites/tennisRacket.png"),
        ptero = love.graphics.newImage("resources/sprites/ptero.png"),
        lizard = love.graphics.newImage("resources/sprites/lizard.png"),
        square = love.graphics.newImage("resources/sprites/square.jpg"),
        sun = love.graphics.newImage("resources/sprites/sun.png"),
        star = love.graphics.newImage("resources/sprites/star.png"),
        trophy = love.graphics.newImage("resources/sprites/trophy.png"),
        notch = love.graphics.newImage("resources/sprites/notch.png")
    }

    sounds = {
        main = love.audio.newSource("resources/audio/Guifrog - Suco de Abacaxi.mp3", "stream"),
        score = love.audio.newSource("resources/audio/ding.wav", "static"),
        metal = love.audio.newSource("resources/audio/metal.wav", "static"),
        cheer = love.audio.newSource("resources/audio/yaycheer.wav", "static"),
        breaking = love.audio.newSource("resources/audio/break.wav", "static"),
        stick = love.audio.newSource("resources/audio/sticky.mp3", "static"),
        phoneRing = love.audio.newSource("resources/audio/phoneRing1.mp3", "static")
    }

    fonts = {
        angelic = love.graphics.newFont("resources/fonts/Angelic-Regular.ttf", 40),
        jogrunge = love.graphics.newFont("resources/fonts/JOGRUNGE.otf", 40),
        friendlySans = love.graphics.newFont("resources/fonts/FriendlySans-Regular.ttf", 40),
        pixelatedElegance = love.graphics.newFont("resources/fonts/Pixelated Elegance.ttf", 40),
        latinaPopular = love.graphics.newFont("resources/fonts/LatinaPopular-Regular.ttf", 40),
        anotherTypewritter = love.graphics.newFont("resources/fonts/atwriter.ttf", 40),
        vinqueAntique = love.graphics.newFont("resources/fonts/vinque antique bd.otf", 40),

        angelicM = love.graphics.newFont("resources/fonts/Angelic-Regular.ttf", 80),
        jogrungeM = love.graphics.newFont("resources/fonts/JOGRUNGE.otf", 80),
        friendlySansM = love.graphics.newFont("resources/fonts/FriendlySans-Regular.ttf", 80),
        pixelatedEleganceM = love.graphics.newFont("resources/fonts/Pixelated Elegance.ttf", 80),
        latinaPopularM = love.graphics.newFont("resources/fonts/LatinaPopular-Regular.ttf", 80),
        anotherTypewritterM = love.graphics.newFont("resources/fonts/atwriter.ttf", 80),
        vinqueAntiqueM = love.graphics.newFont("resources/fonts/vinque antique bd.otf", 230),

        angelicL = love.graphics.newFont("resources/fonts/Angelic-Regular.ttf", 100),
        jogrungeL = love.graphics.newFont("resources/fonts/JOGRUNGE.otf", 100),
        friendlySansL = love.graphics.newFont("resources/fonts/FriendlySans-Regular.ttf", 100),
        pixelatedEleganceL = love.graphics.newFont("resources/fonts/Pixelated Elegance.ttf", 100),
        latinaPopularL = love.graphics.newFont("resources/fonts/LatinaPopular-Regular.ttf", 100),
        anotherTypewritterL = love.graphics.newFont("resources/fonts/atwriter.ttf", 100),
        vinqueAntiqueL = love.graphics.newFont("resources/fonts/vinque antique bd.otf", 250)
    }

    colors = {
        purple = {0.4784, 0.3333, 0.9255, 1.0}, -- 7a55ec
        red    = {0.9255, 0.3333, 0.3333, 1.0}, -- ec5555
        pink   = {0.9255, 0.3333, 0.8118, 1.0}, -- ec55cf
        blue   = {0.3333, 0.3961, 0.9255, 1.0}, -- 5565ec
        cyan   = {0.3333, 0.7059, 0.9255, 1.0}, -- 55b4ec
        green  = {0.3333, 0.9255, 0.6000, 1.0}, -- 55ec99
        yellow = {0.8588, 0.9255, 0.3333, 1.0}, -- dbec55
        orange = {0.9255, 0.5686, 0.3333, 1.0}, -- ec9155
    }

    shaders = {}

    shaders.crt = love.graphics.newShader([[
        extern vec2 screenSize;
        extern float aberration;

        vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc)
        {
            vec2 curved = uv * 2.0 - 1.0;
            curved *= 1.0 + dot(curved, curved) * 0.08;
            uv = curved * 0.5 + 0.5;

            if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
                return vec4(0.0, 0.0, 0.0, 1.0);

            vec2 center = vec2(0.5, 0.5);
            vec2 dir = uv - center;

            vec2 offset = dir * aberration;

            float r = Texel(tex, uv + offset).r;
            float g = Texel(tex, uv).g;
            float b = Texel(tex, uv - offset).b;
            float a = Texel(tex, uv).a;

            vec4 pixel = vec4(r, g, b, a);

            float scanline = sin(uv.y * screenSize.y * 3.14159);
            pixel.rgb *= 0.85 + 0.15 * scanline;

            return pixel * color;
        }
        ]])

    mainVolume = 0.5

    sounds.main:setLooping(true)
    sounds.main:setVolume(mainVolume)
    sounds.main:play()

    sounds.phoneRing:setVolume(0.3)

    input:bind('left', 'left')
    input:bind('right', 'right')
    input:bind('a', 'left')
    input:bind('d', 'right')
    input:bind('up', 'up')
    input:bind('down', 'down')
    input:bind('w', 'up')
    input:bind('s', 'down')

    input:bind('mouse1', 'click')
    input:bind('escape', 'exit')
    input:bind('e', 'autowin')

    gotoRoom("Start")

    if debug then debugTools = DebugTools() end
end

function getGameFont()
    if love.math.random() > 0.9 then
        return fonts.angelic
    end

    local regularFonts = {
        fonts.jogrunge,
        fonts.friendlySans,
        fonts.vinqueAntique,
        fonts.pixelatedElegance,
        fonts.latinaPopular,
        fonts.anotherTypewritter
    }
    local selected = regularFonts[love.math.random(#regularFonts)]

    return selected
end

function love.update(dt)
    timer:update(dt*slow_amount)
    camera:update(dt*slow_amount)
    if current_room then current_room:update(dt*slow_amount) end
    if debug then debugTools:update(dt) end
end

function love.draw()
    shaders.crt:send("screenSize", {gw * sx, gh * sy})
    shaders.crt:send("aberration", 0.005)

    love.graphics.setShader(getMainShader())
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(sprites.mainBG, 0, 0, 0, sx, sy)
    love.graphics.setShader()
    if current_room then current_room:draw() end

    if flash_frames then 
        flash_frames = flash_frames - 1
        if flash_frames == -1 then flash_frames = nil end
    end
    if flash_frames then
        love.graphics.setColor(flashColor) --change to background color
        love.graphics.rectangle('fill', 0, 0, sx*gw, sy*gh)
        love.graphics.setColor(1, 1, 1, 1)
    end

    if debug then debugTools:draw() end
end

function getMainShader()
    return (useShader) and shaders.crt or nil
end

function love.keypressed(key)
end

function gotoRoom(room_type, ...)
    if current_room and current_room.destroy then current_room:destroy() end
    current_room = _G[room_type](...)
end

--[[
    Stores all possible object files into a table
]]
function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        if love.filesystem.getInfo(file) then
            table.insert(file_list, file)
        elseif love.filesystem.isDirectory(file) then
            recursiveEnumerate(file, file_list)
        end
    end
end

--[[
    Imports files from a table
]]
function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        local className = file:match("([^/]+)$")
        if not _G[className] then
            _G[className] = require(file)
        end
    end
end

function resize(s)
    love.window.setMode(s*gw, s*gh) 
    sx, sy = s, s
end

function slow(amount, duration)
    slow_amount = amount
    timer:tween('slow', duration, _G, {slow_amount = 1}, 'in-out-cubic')
end

function flash(frames, color)
    flash_frames = frames
    flashColor = color or {1,1,1,0.5}
end

function checkGC()
    -- Counts how many of each object type exist in memory after garbage collection
    print("Before collection: " .. collectgarbage("count")/1024)
    collectgarbage()
    print("After collection: " .. collectgarbage("count")/1024)
    print("Object count: ")
    local counts = type_count()
    for k, v in pairs(counts) do print(k, v) end
    print("-------------------------------------")
end

function count_all(f)
    local seen = {}
    local count_table
    count_table = function(t)
        if seen[t] then return end
            f(t)
	    seen[t] = true
	    for k,v in pairs(t) do
	        if type(v) == "table" then
		    count_table(v)
	        elseif type(v) == "userdata" then
		    f(v)
	        end
	end
    end
    count_table(_G)
end

function type_count()
    local counts = {}
    local enumerate = function (o)
        local t = type_name(o)
        counts[t] = (counts[t] or 0) + 1
    end
    count_all(enumerate)
    return counts
end

global_type_table = nil
function type_name(o)
    if global_type_table == nil then
        global_type_table = {}
            for k,v in pairs(_G) do
	        global_type_table[v] = k
	    end
	global_type_table[0] = "table"
    end
    return global_type_table[getmetatable(o) or 0] or "Unknown"
end

function AddTestShortcuts()
    input:bind('f1', checkGC )
    input:bind('f3', function() debug = not debug end )
end