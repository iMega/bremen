local inspect = require("kikito.inspect")
local auth   = require "imega.auth"
local strlib = require "imega.string"

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

if false == strlib.empty(auth.checkToken()) then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

ngx.req.read_body()

local file = ngx.req.get_body_file()

if strlib.empty(file) then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

os.execute("cp " .. file .. " /data/" .. login .. ".zip")

ngx.say("success\n")
