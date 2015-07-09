

local socket = require "socket"
local struct = require "struct"
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

function drawList()
    id = 0
    for k,v in pairs(tab) do
        love.graphics.draw( avatar[v.login], 0, id * 190)
        love.graphics.print(id, 175, id * 190 + 10)
        love.graphics.print(v.login, 188, id * 190 + 10)
        love.graphics.print(v.hostname, 250, id * 190 + 10)



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
        if data:sub(0,7) == "jso:lst" then
            tab = json.decode(data:sub(9))
            for k,v in pairs(tab) do
                print(v.login.." : "..v.hostname)
            end
            --updateList()
        end
        for k,v in pairs(tab) do
            if (not avatar[v.login]) then
                if loadImg(v.login) then
                    avatar[v.login] = love.graphics.newImage(v.login..".jpg")
                else
                    avatar[v.login] = love.graphics.newImage("default.png")
                end
            end
        end

        i = 0
    end

end

function love.draw()
drawList()
end
