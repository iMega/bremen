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

local strlib = require "imega.string"
local redis  = require "resty.redis"
local auth   = require "imega.auth"

local headers = ngx.req.get_headers()

if strlib.empty(headers["cookie"]) then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

local matchPiece = ngx.re.match(headers["cookie"], "token=([a-f0-9-]+)")

if strlib.empty(matchPiece[1]) then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

local token = matchPiece[1]

local db = redis:new()
db:set_timeout(1000)
local ok, err = db:connect(ngx.var.redis_ip, ngx.var.redis_port)
if not ok then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(err)
    ngx.exit(ngx.status)
end

if false == auth.checkToken(db, token) then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

ngx.say("zip=yes\nfile_limit=100000000")
