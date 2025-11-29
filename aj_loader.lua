--==============================================================--
--  AWESOME AJ — ONE-TIME KEY LOADER (GITHUB VERSION)
--==============================================================--

local HttpService = game:GetService("HttpService")
local Analytics = game:GetService("RbxAnalyticsService")

local USER_KEY = rawget(getfenv(), "script_key") or ""
local HWID = Analytics:GetClientId()

-- YOUR PYTHON API (still must be online)
local SERVER = "http://YOUR_PUBLIC_IP:5000/validate"

-- Your publicly hosted AutoJoiner file:
local AUTOJOINER_URL = "https://raw.githubusercontent.com/YOURNAME/YOURREPO/main/autojoiner.lua"

--==============================================================--
--  LOCAL KEY SAVE (ONE-TIME ENTRY)
--==============================================================--

local SAVE_NAME = "AJ_KEY_" .. tostring(HWID)

local function loadSavedKey()
    if isfile and isfile(SAVE_NAME) then
        return readfile(SAVE_NAME)
    end
end

local function saveKey(k)
    if writefile then
        writefile(SAVE_NAME, k)
    end
end

-- Pick key: saved > user input
local KEY = loadSavedKey() or USER_KEY

if KEY == "" then
    warn("[AwesomeAJ] ❌ No key found (saved or entered).")
    return
end

--==============================================================--
--  VALIDATE KEY
--==============================================================--

local payload = HttpService:JSONEncode({
    key = KEY,
    hwid = HWID,
    client = "lua"
})

local function validate()
    local res

    local ok, err = pcall(function()
        res = game:HttpPost(SERVER, payload)
    end)

    if not ok then
        warn("[AwesomeAJ] ❌ Server error:", err)
        return false
    end

    local data = HttpService:JSONDecode(res)
    return data.valid == true
end

if not validate() then
    warn("[AwesomeAJ] ❌ Invalid key or HWID mismatch.")
    return
end

print("[AwesomeAJ] ✅ Key Valid — Loading Script...")
saveKey(KEY)

--==============================================================--
--  LOAD AUTOJOINER FROM GITHUB
--==============================================================--

local src = game:HttpGet(AUTOJOINER_URL)
local fn = loadstring(src)

if fn then
    fn()
else
    warn("[AwesomeAJ] ❌ AutoJoiner failed to load.")
end
