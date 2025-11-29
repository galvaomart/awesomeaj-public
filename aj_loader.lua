--==============================================================--
--  AWESOME AJ — GITHUB JSON KEY SYSTEM
--==============================================================--

local HttpService = game:GetService("HttpService")
local Analytics = game:GetService("RbxAnalyticsService")

local USER_KEY = rawget(getfenv(), "script_key") or ""
local HWID = Analytics:GetClientId()

-- GitHub file locations (YOUR repo)
local KEYS_URL = "https://raw.githubusercontent.com/galvaomart/awesomeaj-public/main/keys.json"
local AUTOJOINER_URL = "https://raw.githubusercontent.com/galvaomart/awesomeaj-public/main/autojoiner.lua"

-- local saved key
local SAVE_NAME = "AJ_KEY_" .. tostring(HWID)

local function load_saved()
    if isfile and isfile(SAVE_NAME) then
        return readfile(SAVE_NAME)
    end
end

local function save_key(k)
    if writefile then
        writefile(SAVE_NAME, k)
    end
end

-- prefer saved key → fallback to user
local KEY = load_saved() or USER_KEY

if KEY == "" then
    warn("[AwesomeAJ] ❌ No key entered.")
    return
end

--==============================================================--
--  Fetch keys.json from GitHub
--==============================================================--

local raw
local success, err = pcall(function()
    raw = game:HttpGet(KEYS_URL)
end)

if not success then
    warn("[AwesomeAJ] ❌ Failed to load keys.json:", err)
    return
end

local keys = HttpService:JSONDecode(raw)
local entry = keys[KEY]

if not entry then
    warn("[AwesomeAJ] ❌ Invalid key (not in keys.json).")
    return
end

--==============================================================--
--  HWID LOCK
--==============================================================--

if entry.hwid == "" then
    print("[AwesomeAJ] 🔒 First time use — binding HWID...")
    entry.hwid = HWID
else
    if entry.hwid ~= HWID then
        warn("[AwesomeAJ] ❌ HWID mismatch — Access denied.")
        return
    end
end

save_key(KEY)
print("[AwesomeAJ] ✅ Key Validated")

--==============================================================--
--  LOAD AUTO JOINER SCRIPT
--==============================================================--

local src = game:HttpGet(AUTOJOINER_URL)
local fn = loadstring(src)

if fn then
    print("[AwesomeAJ] 🚀 Loading AutoJoiner...")
    fn()
else
    warn("[AwesomeAJ] ❌ Failed to load AutoJoiner.")
end


