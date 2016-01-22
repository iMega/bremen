local inspect = require("kikito.inspect")
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

ngx.say("zip=yes\nfile_limit=100000000")
