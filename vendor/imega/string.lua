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
local function split(value, inSplitPattern, outResults)
    if not outResults then
        outResults = {}
    end
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find(value, inSplitPattern, theStart)
    while theSplitStart do
        table.insert(outResults, string.sub(value, theStart, theSplitStart-1))
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find(value, inSplitPattern, theStart)
    end
    table.insert(outResults, string.sub(value, theStart))

    return outResults
end

return {
    empty = empty,
    split = split
}
