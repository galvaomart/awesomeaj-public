--==============================================================--
--  AWESOME AJ — GITHUB JSON KEY SYSTEM
--  Supports Discord bot–generated 32-char keys (A-Z + 0-9)
--==============================================================--

local HttpService = game:GetService("HttpService")
local Analytics = game:GetService("RbxAnalyticsService")

local USER_KEY = rawget(getfenv(), "script_key") or ""
local HWID = Analytics:GetClientId()

-- GitHub URLs (CHANGE THESE TO YOUR REPO)
local KEYS_URL = "https://raw.githubusercontent.com/YOURNAME/YOURREPO/main/keys.json"
local AUTOJOINER_URL = "https://raw.githubusercontent.com/YOURNAME/YOURREPO/main/autojoiner.lua"

-- Local save file for one-time key entry
local SAVE_NAME = "AJ_KEY_" .. tostring(HWID)

--==============================================================--
--  One-Time Key Saving
--==============================================================--

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

-- Prefer saved key → fallback to user entry
local KEY = load_saved() or USER_KEY

if KEY == "" then
    warn("[AwesomeAJ] ❌ No key provided.")
    return
end

--==============================================================--
--  Load keys.json From GitHub
--==============================================================--

local raw = game:HttpGet(KEYS_URL)
local keys = HttpService:JSONDecode(raw)

local entry = keys[KEY]

if not entry then
    warn("[AwesomeAJ] ❌ Invalid key. (Not in keys.json)")
    return
end

--==============================================================--
--  HWID Binding Logic
--==============================================================--

if entry.hwid == "" then
    print("[AwesomeAJ] 🔒 First-time key use — Binding HWID...")
    entry.hwid = HWID
else
    if entry.hwid ~= HWID then
        warn("[AwesomeAJ] ❌ HWID mismatch — Access denied.")
        return
    end
end

-- Save key (one-time entry)
save_key(KEY)
print("[AwesomeAJ] ✅ Key Validated")

--==============================================================--
--  Load Auto Joiner Script
--==============================================================--

local src = game:HttpGet(AUTOJOINER_URL)
local fn = loadstring(src)

if fn then
    fn()
    print("[AwesomeAJ] 🚀 AutoJoiner Loaded")
else
    warn("[AwesomeAJ] ❌ Failed to load script.")
end

