--
-- Auth user
--
-- @return bool
--
local function auth(login, pass)
    return true
end

--
-- Get token by login
--
-- @return string
--
local function getToken(login)
    return "token"
end

--
-- Check token
--
-- @return bool
--
local function checkToken(token)
    return false
end

return {
    authenticate = auth,
    getToken     = getToken,
    checkToken   = checkToken
}
