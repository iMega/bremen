local inspect = require("kikito.inspect")
local upload = require("resty.upload")

local chunk_size = 8192

local form, err = upload:new(chunk_size)
if not form then
    ngx.log(ngx.ERR, "failed to new upload: ", err)
    ngx.exit(500)
end

form:set_timeout(1000)

while true do
    local typ, res, err = form:read()
    if not typ then
        ngx.say("failed to read: ", err)
        return
    end

    ngx.say("read: ", inspect({typ, res}))

    if typ == "eof" then
        break
    end
end

local typ, res, err = form:read()

ngx.say("read: ", inspect({typ, res}))
