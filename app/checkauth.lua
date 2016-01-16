local inspect = require("kikito.inspect")
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
    ngx.exit(ngx.status)
end

local validData = values("valid")

if strlib.empty(validData["login"]) or strlib.empty(validData["pass"]) then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

if not auth.authenticate(validData["login"], validData["pass"]) then
    ngx.status = ngx.HTTP_FORBIDDEN
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

local token = auth.getToken(validData["login"])

ngx.say("success\nbla\n" .. token)
