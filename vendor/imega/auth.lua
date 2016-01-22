--
-- Copyright (C) 2015 iMega ltd Dmitry Gavriloff (email: info@imega.ru),
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

local redis = require "resty.redis"
local uuid = require "tieske.uuid"
local db = redis:new()
db:set_timeout(1000)

local ok, err = db:connect(ngx.var.redis_ip, ngx.var.redis_port)
if not ok then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(err)
    ngx.exit(ngx.status)
end

--
-- Generate token
--
-- @return string
--
local function generateToken()
    return uuid.new()
end

--
-- Auth user
--
-- @return bool
--
local function auth(login, pass)
    local result = false
    local res, err = db:get("auth:" .. login)

    if res == pass then
        result = true
        local token = generateToken()
        local res, err = db:set("login2token:" .. login, token)
        if not ok then
            result = false
        end
        local res, err = db:expire("login2token:" .. login, 600)
        if not ok then
            result = false
        end
        local res, err = db:set("token2login:" .. token, login)
        if not ok then
            result = false
        end
        local res, err = db:expire("token2login:" .. token, 600)
        if not ok then
            result = false
        end
    end

    return result
end

--
-- Get token by login
--
-- @return string
--
local function getToken(login)
    local result = ""
    local res, err = db:get("login2token:" .. login)
    if res then
        result = res
    end

    return result
end

--
-- Check token
--
-- @return bool
--
local function checkToken(token)
    local result = false
    local res, err = db:get("token2login:" .. token)
    if res then
        result = true
    end

    return result
end

return {
    authenticate = auth,
    getToken     = getToken,
    checkToken   = checkToken
}
