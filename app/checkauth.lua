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

local base64 = require("kloss.base64")
require "resty.validation.ngx"
local validation = require "resty.validation"
local auth = require "imega.auth"
local strlib = require "imega.string"

local headers = ngx.req.get_headers()

if strlib.empty(headers["Authorization"]) then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

local matchPiece = ngx.re.match(headers["Authorization"], "Basic\\s(.+)")

if strlib.empty(matchPiece[1]) then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

local credentials = base64.decode(matchPiece[1])
credentials = strlib.split(credentials, ":")

local credentials = {
    login = credentials[1],
    pass  = credentials[2]
}

local validatorCredentials = validation.new{
    login = validation.string.trim:len(36,36),
    pass  = validation.string.trim:maxlen(36)
}

local isValid, values = validatorCredentials(credentials)
if not isValid then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

local validData = values("valid")

if not auth.authenticate(validData["login"], validData["pass"]) then
    ngx.status = ngx.HTTP_FORBIDDEN
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

local token = auth.getToken(validData["login"])

ngx.say("success\ntoken\n" .. token)
