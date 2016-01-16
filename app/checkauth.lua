local inspect = require("kikito.inspect")
local base64 = require("kloss.base64")
require "resty.validation.ngx"
local validation = require "resty.validation"
local auth = require "imega.auth"

-- Determine whether a variable is empty
--
-- @return bool
--
local function empty(value)
    return value == nil or value == ''
end

-- Split string
-- @todo https://github.com/openresty/lua-nginx-module/issues/217
--
-- @return table
--
function string:split(inSplitPattern, outResults)
    if not outResults then
        outResults = {}
    end
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
    while theSplitStart do
        table.insert(outResults, string.sub(self, theStart, theSplitStart-1))
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find(self, inSplitPattern, theStart)
    end
    table.insert(outResults, string.sub(self, theStart))

    return outResults
end

local headers = ngx.req.get_headers()

if empty(headers["Authorization"]) then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

local matchPiece = ngx.re.match(headers["Authorization"], "Basic\\s(.+)")

if empty(matchPiece[1]) then
    ngx.status = ngx.HTTP_BAD_REQUEST
    ngx.say("failure\n");
    ngx.exit(ngx.status)
end

local credentials = base64.decode(matchPiece[1])
credentials = string.split(credentials, ":")

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

if empty(validData["login"]) or empty(validData["pass"]) then
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
