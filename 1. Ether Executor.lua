-- ╔══════════════════════════════════════════════════════════════╗
-- ║  ETHER EXECUTOR — MERGED (File1 UI + File57 Features)        ║
-- ║  PART 1/3 : Foundation                                       ║
-- ╚══════════════════════════════════════════════════════════════╝

if getgenv().EtherExecutorLibrary then
	pcall(function() getgenv().EtherExecutorLibrary:Destroy() end)
end

local EtherLibrary = {
	Flags = {},
	ExecutorFlags = {},
	ThemeObjects = {},
	Connections = {},
	Themes = {
		Default = {
			WindowBackground = Color3.fromRGB(47, 54, 64),
			WindowBorder = Color3.fromRGB(47, 54, 64),
			ElementDivider = Color3.fromRGB(107, 114, 124),
			ElementDividerText = Color3.fromRGB(107, 114, 124),
			TabDivider = Color3.fromRGB(107, 114, 124),
			TabDividerText = Color3.fromRGB(107, 114, 124),
			TabBtnBackground = Color3.fromRGB(40, 148, 215),
			TabBtnBackgroundSelect = Color3.fromRGB(0, 168, 255),
			TabScriptBtnBackground = Color3.fromRGB(40, 148, 215),
			TabScriptBtnBackgroundSelect = Color3.fromRGB(0, 168, 255),
			Header = Color3.fromRGB(0, 168, 255),
			HeaderBorder = Color3.fromRGB(0, 168, 255),
			HeaderText = Color3.fromRGB(47, 54, 64),
			SubHeaderText = Color3.fromRGB(67, 74, 84),
			NormalText = Color3.fromRGB(245, 246, 250),
			NormalBackground = Color3.fromRGB(53, 59, 72),
			DropdownOptionBackground = Color3.fromRGB(53, 59, 72),
			DropdownOptionTextHolder = Color3.fromRGB(180, 180, 180),
			DropdownOptionSelect = Color3.fromRGB(73, 79, 92),
			BtnBorder = Color3.fromRGB(113, 128, 147),
			ToggleFiller = Color3.fromRGB(68, 189, 50),
			SliderFiller = Color3.fromRGB(76, 209, 55)
		}
	},
	GlobalAutoSave = true,
	MainFolder = "EtherExecutor",
	MainConfigFile = "ExeConfigs.json",
	MainFeatureFile = "Configs.json",
	IconCacheFolder = "IconCache",
	ImageCacheFolder = "ImageCache",
	SavedScriptFolder = "Saved Script",
	SavedTabEditorFolder = "Saved Tab Editor",
	SavedScriptHubFolder = "Saved Hub Script",
	SelectedTheme = "Default",
	
	CustomIcon = "lucide:eye",
	ToggleButtonConfig = {
		StrokeColor = Color3.fromRGB(0, 168, 255),
		StrokeColor2 = Color3.fromRGB(255, 105, 180),
		Gradient = false,
		GradientRotation = 45,
		Position = UDim2.new(0, 20, 0, 90),
		Size = 44,
		Visible = true,
		AutoRotate = false,
		AutoRotateSpeed = 45,
		RGBMode = false,
		RGBSpeed = 0.3,
		CornerRadius = 50,
	},
	MainUIHidden = false,
}

getgenv().EtherExecutorLibrary = EtherLibrary

local exeRunningTime = os.time()

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local player = players.LocalPlayer
local mouse = player:GetMouse()
local run = game:GetService("RunService")
local stepped = run.Stepped
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local GuiService = game:GetService("GuiService")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")

local activeInteraction = nil
local clientRbxVersion = version and version()
local clientLevel = (getidentity and getidentity()) or (getthreadidentity and getthreadidentity())
local name, version = "Unknown", "Unknown"
if identifyexecutor then
	local ok, n, v = pcall(identifyexecutor)
	if ok then
		name = n or "Unknown"
		version = v or "Unknown"
	end
end
local Version = "v0.0.1 beta"

local changeList = {
	["v0.0.1 beta"] = { "• Release!" }
}

local function createUIName()
	local length = math.random(1, 80)
	local array = {}
	for i = 1, length do array[i] = string.char(math.random(1, 255)) end
	return table.concat(array)
end

local function ensureIconCacheFolder()
	if makefolder and isfolder and not isfolder(EtherLibrary.IconCacheFolder) then
		pcall(makefolder, EtherLibrary.IconCacheFolder)
	end
end

local function ensureFolder(path)
	if isfolder and makefolder and not isfolder(path) then
		pcall(makefolder, path)
	end
end

local function getFolderPath(folderName, subFolder)
	ensureFolder(EtherLibrary.MainFolder)
	local userFolder = (folderName and folderName ~= "") and folderName or "DefaultScript"
	local userPath = EtherLibrary.MainFolder .. "/" .. userFolder
	ensureFolder(userPath)
	if subFolder then
		local subPath = userPath .. "/" .. subFolder
		ensureFolder(subPath)
		return subPath
	end
	return userPath
end

local SCRIPTBLOX_BASE = "https://scriptblox.com"
local RSCRIPTS_BASE = "https://rscripts.net"
local ROBLOXSCRIPTS_BASE = "https://robloxscripts.com"
local IMAGE_CACHE_DIR = EtherLibrary.MainFolder .. "/" .. EtherLibrary.ImageCacheFolder

ensureFolder(EtherLibrary.MainFolder)
ensureFolder(EtherLibrary.MainFolder .. "/" .. EtherLibrary.SavedScriptFolder)
ensureFolder(EtherLibrary.MainFolder .. "/" .. EtherLibrary.SavedScriptHubFolder)
ensureFolder(EtherLibrary.MainFolder .. "/" .. EtherLibrary.SavedTabEditorFolder)

local function table_find(tbl, val)
	if table.find then return table.find(tbl, val) end
	for i, v in ipairs(tbl) do if v == val then return i end end
	return nil
end

local function protect_gui(obj)
	local s = false
	obj.Name = tostring(createUIName())
	if gethui then local ok, hui = pcall(gethui) if ok and hui then pcall(function() obj.Parent = hui end) s = true end end
	if not s and get_hidden_gui then local ok, hui = pcall(get_hidden_gui) if ok and hui then pcall(function() obj.Parent = hui end) s = true end end
	if not s and syn and syn.protect_gui then pcall(function() syn.protect_gui(obj) end) pcall(function() obj.Parent = CoreGui end) s = true end
	if not s then
		if player and player:FindFirstChild("PlayerGui") then
			pcall(function() obj.Parent = player:FindFirstChild("PlayerGui") end) s = true
		else
			pcall(function() obj.Parent = CoreGui end)
		end
	end
	pcall(function()
		obj.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		obj.DisplayOrder = 999999
		obj.ResetOnSpawn = false
	end)
	return s
end

local function urlEncode(str)
	if HttpService and HttpService.UrlEncode then
		local ok, enc = pcall(HttpService.UrlEncode, HttpService, str)
		if ok then return enc end
	end
	return str:gsub("([^%w%-_%.~])", function(c) return string.format("%%%02X", string.byte(c)) end)
end

local function universalHttpGet(url)
	local requestFn = request or http_request or (syn and syn.request)
	if requestFn then
		local ok, res = pcall(function() return requestFn({ Url = url, Method = "GET" }) end)
		if ok and res then
			local body = res.Body or res.body
			if body and body ~= "" then return true, body, res.StatusCode or 200 end
		end
	end
	if game and game.HttpGet then
		local ok, body = pcall(function() return game:HttpGet(game, url) end)
		if ok and body and body ~= "" then return true, body, 200 end
	end
	if HttpService and HttpService.GetAsync then
		local ok, body = pcall(function() return HttpService:GetAsync(url) end)
		if ok and body and body ~= "" then return true, body, 200 end
	end
	return false, "", 0
end


-- ========== CACHE MANAGER (mirip file57 tapi lebih bagus) ==========
local function sanitizeFileName(str) return str:gsub("[^%w%._%-]", "_") end
local function hashString(str) local hash=0 for i=1,#str do hash=(hash*31+string.byte(str,i))%4294967296 end return string.format("%08x", hash) end
local function ensureImageFolder() if type(isfolder)~="function" or type(makefolder)~="function" then return false end local okExists,exists=pcall(isfolder, IMAGE_CACHE_DIR) if not okExists then return false end if not exists then local okMk=pcall(makefolder, IMAGE_CACHE_DIR) if not okMk then return false end end return true end
local function deriveImageFileName(url) local fileName=url:match("/([^/%?#]+)") or "image" fileName=fileName:match("([^?#]+)") or fileName local base=fileName:match("(.+)%.") or fileName base=sanitizeFileName(base) local ext="txt" local hashed=hashString(url) return string.format("%s_%s.%s", base~="" and base or "image", hashed, ext) end
local function normalizeImageUrl(url, base) if type(url)~="string" or url=="" then return nil end local trimmed=url:match("^%s*(.-)%s*$") or "" if trimmed=="" then return nil end if trimmed:match("^rbxassetid://") or trimmed:match("^rbxthumb://") then return nil end if trimmed:match("^https?://") then return trimmed end if trimmed:sub(1,2)=="//" then return "https:"..trimmed end if trimmed:sub(1,1)=="/" then if base then return base..trimmed end return trimmed end if base then return base.."/"..trimmed end return trimmed end
local function isMeaningfulImageUrl(url) if type(url)~="string" or url=="" then return false end local lower=url:lower() if lower:find("no%-script") then return false end return true end
local function robloxApiUrls(url) local subdomain,path=tostring(url):match("^https?://([%w%-]+)%.roblox%.com(/.*)$") if not subdomain then subdomain,path=tostring(url):match("^https?://([%w%-]+)%.roproxy%.com(/.*)$") end if not subdomain then subdomain,path=tostring(url):match("^https?://([%w%-]+)%.rotunnel%.com(/.*)$") end if not subdomain or not path then return {url} end return {"https://"..subdomain..".roproxy.com"..path, "https://"..subdomain..".rotunnel.com"..path, "https://"..subdomain..".roblox.com"..path} end
local function httpGetBinary(url, headers) if type(url)~="string" or url=="" then return nil end local function tryRequest(targetUrl, customHeaders) local rq=request or http_request or (syn and syn.request) if type(rq)~="function" then return nil end local hdr={} if type(customHeaders)=="table" then for k,v in pairs(customHeaders) do hdr[k]=v end end hdr["User-Agent"]=hdr["User-Agent"] or "Roblox/Http/1.1" hdr.Accept=hdr.Accept or "*/*" local okReq,res=pcall(rq, {Url=targetUrl, Method="GET", Headers=hdr}) if okReq and res then local status=res.StatusCode or res.Status or res.status_code or 0 local body=res.Body or res.body if status==0 or (status>=200 and status<300) then if type(body)=="string" and body~="" then return body end end end return nil end for _,targetUrl in ipairs(robloxApiUrls(url)) do local data=tryRequest(targetUrl, headers) if not (type(data)=="string" and data~="") then local okDirect,direct=pcall(function() return game:HttpGet(targetUrl) end) if okDirect and type(direct)=="string" and direct~="" then data=direct else data=tryRequest(targetUrl, nil) end end if type(data)=="string" and data~="" then return data end end return nil end

-- INI YANG KAMU TANYA: FILE57 CLEAR CACHE
local function clearImageCache()
	if type(isfolder)~="function" or type(listfiles)~="function" or type(isfile)~="function" or type(delfile)~="function" then return false end
	local okExists,exists=pcall(isfolder, IMAGE_CACHE_DIR)
	if not okExists or not exists then return false end
	local okList,files=pcall(listfiles, IMAGE_CACHE_DIR)
	if not okList or type(files)~="table" then return false end
	local deleted=0
	for _,path in ipairs(files) do
		if type(path)=="string" and path~="" then
			local ok=pcall(delfile, path)
			if ok then deleted+=1 end
		end
	end
	return true, deleted
end

-- Auto cleanup kalau kebanyakan (misal >50 file atau >10MB)
local function autoCleanupIfNeeded()
	if type(isfolder)~="function" or type(listfiles)~="function" then return end
	local okExists,exists=pcall(isfolder, IMAGE_CACHE_DIR)
	if not okExists or not exists then return end
	local okList,files=pcall(listfiles, IMAGE_CACHE_DIR)
	if not okList or type(files)~="table" then return end
	if #files > 50 then
		-- hapus file tertua (berdasarkan nama, karena hash gak ada tanggal, kita hapus 50% tertua random)
		-- file57 langsung hapus semua, kita lebih gentle: hapus setengah
		print("[Ether Cache] Too many files ("..#files.."), cleaning half...")
		for i=1, math.floor(#files/2) do
			pcall(delfile, files[i])
		end
	end
end

-- Panggil clear pas awal kayak file57 (biar gak numpuk dari session sebelumnya)
-- File57 melakukan clearImageCache() di 2 tempat: pas load dan pas fetch
-- Kita tiru: clear pas load
task.spawn(function()
	task.wait(1)
	local ok,deleted=clearImageCache()
	if ok then print("[Ether Cache] Cleared on load, deleted "..tostring(deleted).." files") end
end)

local function downloadImageAsset(url)
	if type(url)~="string" or url=="" then return nil end
	if type(getcustomasset)~="function" or type(writefile)~="function" or type(isfile)~="function" then
		-- fallback kayak file57: kalau gak ada getcustomasset, return URL langsung biar Roblox coba load http
		return url
	end
	if not ensureImageFolder() then return url end
	local fileName=deriveImageFileName(url)
	local fullPath=IMAGE_CACHE_DIR.."/"..fileName
	local needDownload=true
	local okExists,exists=pcall(isfile, fullPath)
	if okExists and exists then needDownload=false end
	if needDownload then
		local host=url:match("^https?://([^/]+)") or ""
		local headers
		if host:find("scriptblox%.com") then headers=nil
		elseif host:find("rscripts%.net") then headers={Referer=RSCRIPTS_BASE}
		elseif host:find("robloxscripts%.com") then headers={Referer=ROBLOXSCRIPTS_BASE}
		elseif host:find("rbxcdn%.com") then headers={Referer="https://www.roblox.com/"} end
		local data=httpGetBinary(url, headers)
		if not (type(data)=="string" and data~="") then 
			-- fallback ke URL asli kayak file57
			return url 
		end
		local okWrite=pcall(writefile, fullPath, data)
		if not okWrite then return url end
	end
	local okAsset,assetId=pcall(getcustomasset, fullPath)
	if okAsset and assetId then return assetId end
	-- fallback ke URL asli
	return url
end

local function resolveScriptBloxImage(data) if not data then return nil end local function pick(values) for _,value in ipairs(values) do local normalized=normalizeImageUrl(value, SCRIPTBLOX_BASE) if normalized and isMeaningfulImageUrl(normalized) then return normalized end end end local fromScript=pick({data.image, data.imageUrl, data.thumbnail, data.coverImage, data.icon}) if fromScript then return fromScript end local game=data.game or {} local fromGame=pick({game.imageUrl, game.thumbnail, game.image, game.coverImage, game.icon}) if fromGame then return fromGame end return nil end
local function resolveRScriptsImage(data) if not data then return nil end local candidates={data.image, data.imageUrl, data.thumbnail, data.cover, data.banner, data.img} for _,value in ipairs(candidates) do local normalized=normalizeImageUrl(value, RSCRIPTS_BASE) if normalized then return normalized end end local game=data.game if game then local gameFields={game.imgurl, game.imageUrl, game.image, game.thumbnail, game.cover, game.banner, game.gameLogo} for _,value in ipairs(gameFields) do local normalized=normalizeImageUrl(value, RSCRIPTS_BASE) if normalized then return normalized end end end return nil end
local function resolveRobloxScriptsImage(data) if not data then return nil end local candidates={data.image, data.imageUrl, data.thumbnail, data.game and data.game.iconUrl, data.game and data.game.image} for _,value in ipairs(candidates) do local normalized=normalizeImageUrl(value, ROBLOXSCRIPTS_BASE) if normalized and isMeaningfulImageUrl(normalized) then return normalized end end return nil end
local function buildRobloxThumbnail(placeId) local id=tostring(placeId or "") if id=="" or id=="0" then return nil end return "https://www.roblox.com/Thumbs/PlaceThumbnail.ashx?width=420&height=270&format=png&placeId="..id end
local function tryFetchPlaceIcon(placeId, imageLabel) if not MarketplaceService or not placeId or not imageLabel then return end coroutine.wrap(function() local ok,info=pcall(function() return MarketplaceService:GetProductInfo(tonumber(placeId), Enum.InfoType.Asset) end) if not ok or not info then return end local iconId=info.IconImageAssetId if iconId and iconId~=0 then imageLabel.Image="rbxassetid://"..iconId imageLabel.ImageTransparency=0 end end)() end

local function isMobileDevice()
	return uis.TouchEnabled and not (uis.KeyboardEnabled or uis.MouseEnabled)
end

local function isSupportSaving()
	if not (makefolder or isfolder or writefile or readfile) then
		warn("Your executor not support saving")
		return false
	end
	return true
end

local function Create(Name, Properties)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do Object[i] = v end
	return Object
end

local EtherExecutor = Create("ScreenGui", {
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	ScreenInsets = Enum.ScreenInsets.None,
	ResetOnSpawn = false,
	ClipToDeviceSafeArea = false
})
protect_gui(EtherExecutor)

local function SafeConnect(signal, callback)
	if typeof(signal) ~= "RBXScriptSignal" then return nil end
	if type(callback) ~= "function" then return nil end
	local ok, connection = pcall(signal.Connect, signal, callback)
	if ok and connection then
		table.insert(EtherLibrary.Connections, connection)
		return connection
	end
	return nil
end

local function executeSource(source, chunkName)
	source = tostring(source or "")
	if type(loadstring) ~= "function" then
		print("Script execution is unavailable in this build.")
		return false
	end
	local compiled, compileError = loadstring(source, chunkName or "=Delta V2")
	if not compiled then
		print(tostring(compileError) or "Unknown compile error")
		return false
	end
	task.spawn(function()
		local ok, runtimeError = xpcall(compiled, function(message) return tostring(message) end)
		if not ok then print(tostring(runtimeError) or "Unknown runtime error") end
	end)
	return true
end

local IconPacks = {}

local function loadIconPackWithCache(packName, url)
	local fileName = string.lower(packName) .. "_icons (DO NOT EDIT THIS FILE).lua"
	local filePath = EtherLibrary.MainFolder .. "/" .. EtherLibrary.IconCacheFolder .. "/" .. fileName
	local rawData = nil
	if writefile and readfile and isfile and isfile(filePath) then
		local success, content = pcall(readfile, filePath)
		if success and content and content ~= "" then rawData = content end
	end
	if not rawData then
		local success, response = pcall(function() return game:HttpGet(url) end)
		if success and response and response ~= "" then
			rawData = response
			if writefile then
				pcall(function()
					ensureIconCacheFolder()
					writefile(filePath, rawData)
				end)
			end
		else
			warn(`[EtherExecutor] Failed to download Icon Packs '{packName}'.`)
			return
		end
	end
	if rawData then
		local loadSuccess, result = pcall(loadstring(rawData))
		if loadSuccess and type(result) == "table" then
			IconPacks[packName] = result
		else
			warn(`[EtherExecutor] Failed to parse Icon Packs data '{packName}'.`)
		end
	end
end

loadIconPackWithCache("lucide", "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua")
loadIconPackWithCache("solar", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/solar/dist/Icons.lua")
loadIconPackWithCache("craft", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua")
loadIconPackWithCache("geist", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua")
loadIconPackWithCache("sfsymbols", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua")
loadIconPackWithCache("gravity", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/gravity/dist/Icons.lua")

local function parseUniversalIcon(raw)
	if not raw then return nil end
	local result = { Image = "", RectSize = Vector2.zero, RectOffset = Vector2.zero }
	if type(raw) == "number" then
		result.Image = "rbxassetid://" .. raw
		return result
	end
	if type(raw) == "string" then
		if string.sub(raw, 1, 13) == "rbxassetid://" or string.find(raw, "://") then
			result.Image = raw
			return result
		elseif tonumber(raw) then
			result.Image = "rbxassetid://" .. raw
			return result
		end
	end
	if type(raw) == "table" then
		local img = raw.Image or raw.image or raw.id or raw.Id or raw.Asset or raw.asset or raw.url or raw[1]
		if type(img) == "number" then
			result.Image = "rbxassetid://" .. img
		elseif type(img) == "string" then
			result.Image = (string.sub(img, 1, 13) == "rbxassetid://" or string.find(img, "://")) and img or ("rbxassetid://" .. img)
		end
		local size = raw.ImageRectSize or raw.imageRectSize or raw.Size or raw.size or raw[2]
		if typeof(size) == "Vector2" then
			result.RectSize = size
		elseif type(size) == "table" then
			result.RectSize = Vector2.new(size[1] or size.X or size.x or 0, size[2] or size.Y or size.y or 0)
		end
		local offset = raw.ImageRectOffset or raw.imageRectOffset or raw.Offset or raw.offset or raw[3]
		if typeof(offset) == "Vector2" then
			result.RectOffset = offset
		elseif type(offset) == "table" then
			result.RectOffset = Vector2.new(offset[1] or offset.X or offset.x or 0, offset[2] or offset.Y or offset.y or 0)
		end
		return (result.Image ~= "") and result or nil
	end
	return nil
end

local function getIconData(input)
	if not input then return nil end
	local directParsed = parseUniversalIcon(input)
	if directParsed then return directParsed end
	if type(input) ~= "string" or input == "" then return nil end
	local packName, iconName = string.match(input, "^(%w+):(.+)$")
	if not packName then packName = "lucide" iconName = input end
	packName = string.lower(packName)
	iconName = string.match(string.lower(iconName), "^%s*(.*)%s*$")
	local selectedPack = IconPacks[packName]
	if not selectedPack then return nil end
	local sizedIcons = selectedPack['48px'] or selectedPack['24px'] or selectedPack
	local rawIcon = sizedIcons[iconName]
	if not rawIcon and type(selectedPack.Get) == "function" then rawIcon = selectedPack:Get(iconName) end
	return parseUniversalIcon(rawIcon)
end

local function applyIcon(imageInstance, iconInput)
	local data = getIconData(iconInput)
	if not data then imageInstance.Image = "" return end
	imageInstance.Image = data.Image
	imageInstance.ImageRectSize = data.RectSize
	imageInstance.ImageRectOffset = data.RectOffset
end

local function getDateAndTime()
os.date("%d/%m/%Y %X", os.time())
end

-- ============ HIGHLIGHTER ============
local highlighter = {}

local COLORS = {
	Numbers   = Color3.fromRGB(255, 198, 0),
	Operators = Color3.fromRGB(204, 204, 204),
	Keywords  = Color3.fromRGB(248, 109, 124),
	Globals   = Color3.fromRGB(132, 214, 247),
	Executor  = Color3.fromRGB(255, 119, 183),
	Types     = Color3.fromRGB(97, 161, 241),
	Strings   = Color3.fromRGB(173, 241, 149),
	Comments  = Color3.fromRGB(102, 102, 102),
	Properties= Color3.fromRGB(129, 222, 255),
	Methods   = Color3.fromRGB(227, 201, 141),
	Default   = Color3.fromRGB(235, 235, 235),
}

local LUA_KEYWORDS = {
	["and"]=true,["break"]=true,["do"]=true,["else"]=true,["elseif"]=true,["end"]=true,
	["for"]=true,["function"]=true,["if"]=true,["in"]=true,["local"]=true,["not"]=true,
	["or"]=true,["repeat"]=true,["return"]=true,["then"]=true,["until"]=true,["while"]=true,
	["continue"]=true,["export"]=true,["type"]=true,["typeof"]=true,
}
local SPECIAL = {["nil"]=true,["true"]=true,["false"]=true,["self"]=true}
local GLOBALS = {
	["game"]=true,["workspace"]=true,["script"]=true,["math"]=true,["string"]=true,["table"]=true,
	["task"]=true,["coroutine"]=true,["bit32"]=true,["buffer"]=true,["utf8"]=true,
	["print"]=true,["warn"]=true,["error"]=true,["wait"]=true,["tick"]=true,["pairs"]=true,
	["ipairs"]=true,["next"]=true,["select"]=true,["unpack"]=true,["require"]=true,
	["Instance"]=true,["Vector2"]=true,["Vector3"]=true,["CFrame"]=true,["Color3"]=true,
	["UDim2"]=true,["Enum"]=true,["_G"]=true,["shared"]=true,
}
local EXECUTOR = {
	["getgenv"]=true,["getrenv"]=true,["getrawmetatable"]=true,["setrawmetatable"]=true,
	["hookmetamethod"]=true,["hookfunction"]=true,["newcclosure"]=true,["checkcaller"]=true,
	["getnamecallmethod"]=true,["getgc"]=true,["getinstances"]=true,["gethui"]=true,
	["cloneref"]=true,["fireclickdetector"]=true,["setclipboard"]=true,["identifyexecutor"]=true,
	["request"]=true,["http_request"]=true,["setfpscap"]=true,
}
local TYPES = {["Instance"]=true,["CFrame"]=true,["Vector3"]=true,["Vector2"]=true,["Color3"]=true,["UDim"]=true,["UDim2"]=true}

local function scanStringAndCommentsSorted(text)
	local intervals = {}
	local i, n = 1, #text
	while i <= n do
		local two = text:sub(i, i + 1)
		if two == "--" then
			local isLong = text:sub(i + 2, i + 3) == "[["
			if isLong then
				local e = text:find("%]%]", i + 4, true)
				e = e and e + 1 or n
				table.insert(intervals, { i, e, "comment" })
				i = e + 1
			else
				local e = text:find("\n", i + 2, true)
				e = e and e - 1 or n
				table.insert(intervals, { i, e, "comment" })
				i = e + 1
			end
		else
			local c = text:sub(i, i)
			if c == '"' or c == "'" then
				local e = i + 1
				while e <= n do
					if text:sub(e, e) == c and text:sub(e - 1, e - 1) ~= "\\" then break end
					e += 1
				end
				table.insert(intervals, { i, e, "string" })
				i = e + 1
			elseif two == "[[" then
				local e = text:find("%]%]", i + 2, true)
				e = e and e + 1 or n
				table.insert(intervals, { i, e, "string" })
				i = e + 1
			else
				i += 1
			end
		end
	end
	table.sort(intervals, function(a, b) return a[1] < b[1] end)
	return intervals
end

function highlighter.buildLayers(source)
	source = source:gsub("\r", ""):gsub("\t", "    ")
	local len = #source
	local buffers = {
		Numbers={},Operators={},Keywords={},Globals={},Executor={},Types={},Strings={},Comments={},Properties={},Methods={},
	}
	for i = 1, len do
		local ch = source:sub(i, i)
		local space = ch == "\n" and "\n" or " "
		for _, buf in pairs(buffers) do buf[i] = space end
	end

	local intervals = scanStringAndCommentsSorted(source)
	for _, iv in ipairs(intervals) do
		local s, e, typ = iv[1], iv[2], iv[3]
		local target = typ == "string" and "Strings" or "Comments"
		for p = s, math.min(e, len) do buffers[target][p] = source:sub(p, p) end
	end

	local intervalIdx = 1
	local activeEnd = 0
	local i = 1
	while i <= len do
		while intervalIdx <= #intervals and intervals[intervalIdx][1] <= i do
			if i <= intervals[intervalIdx][2] then
				activeEnd = intervals[intervalIdx][2]
				break
			else
				intervalIdx += 1
			end
		end
		if i > activeEnd then
			while intervalIdx <= #intervals and intervals[intervalIdx][2] < i do intervalIdx += 1 end
		else
			i = activeEnd + 1
			continue
		end

		local c = source:sub(i, i)
		local two = source:sub(i, i + 1)
		local three = source:sub(i, i + 2)

		if three == "..." then
			buffers.Operators[i] = "." buffers.Operators[i+1] = "." buffers.Operators[i+2] = "."
			i += 3
		elseif two == ".." or two == "==" or two == "~=" or two == "<=" or two == ">=" or two == "::" then
			buffers.Operators[i] = two:sub(1, 1) buffers.Operators[i+1] = two:sub(2, 2)
			i += 2
		elseif c:match("%d") or (c == "." and source:sub(i + 1, i + 1):match("%d")) then
			local s, e = source:find("^%.?%d+%.?%d*[eE]?[+-]?%d*", i)
			if not s then s, e = source:find("^%d+%.?%d*", i) end
			e = e or i
			if source:sub(s, e):match("%d") then
				for p = s, e do buffers.Numbers[p] = source:sub(p, p) end
				i = e + 1
			else
				buffers.Operators[i] = c
				i += 1
			end
		elseif c == "." or c == ":" then
			local prevChar = i > 1 and source:sub(i - 1, i - 1) or ""
			local nextChar = source:sub(i + 1, i + 1)
			local isAccessor = prevChar:match("[%w_%)%]]") and nextChar:match("[%a_]")
			if isAccessor then
				buffers.Operators[i] = c
				local _, e, word = source:find("^([%a_][%w_]*)", i + 1)
				if word then
					local target = (c == ":" and "Methods" or "Properties")
					for p = i + 1, e do buffers[target][p] = source:sub(p, p) end
					i = e + 1
				else i += 1 end
			else
				buffers.Operators[i] = c
				i += 1
			end
		elseif c:match("[%a_]") then
			local _, e, word = source:find("^([%a_][%w_]*)", i)
			if word then
				local target = nil
				if LUA_KEYWORDS[word] or SPECIAL[word] then target = "Keywords"
				elseif EXECUTOR[word] then target = "Executor"
				elseif GLOBALS[word] then target = "Globals"
				elseif TYPES[word] then target = "Types" end
				if target then for p = i, e do buffers[target][p] = source:sub(p, p) end end
				i = e + 1
			else i += 1 end
		elseif c:match("[%p]") and c ~= "_" then
			buffers.Operators[i] = c
			i += 1
		else i += 1 end
	end

	local result = {}
	for k, v in pairs(buffers) do result[k] = table.concat(v) end
	return result
end

function highlighter.attach(textBox, options)
	assert(textBox and textBox:IsA("TextBox"))
	options = options or {}
	local hideOnFocus = options.hideOnFocus == nil and true or options.hideOnFocus
	local updateOnFocusLostOnly = options.updateOnFocusLostOnly == nil and true or options.updateOnFocusLostOnly
	local debounceTime = options.debounce or 0.15
	local useThread = options.useThread == nil and true or options.useThread

	local layers = {}
	local order = { "Numbers","Operators","Keywords","Globals","Executor","Types","Strings","Comments","Properties","Methods" }

	for _, name in ipairs(order) do
		local lbl = Instance.new("TextLabel")
		lbl.Name = name .. "_Layer"
		lbl.BackgroundTransparency = 1
		lbl.BorderSizePixel = 0
		lbl.TextXAlignment = textBox.TextXAlignment
		lbl.TextYAlignment = textBox.TextYAlignment
		lbl.Font = textBox.Font
		lbl.TextSize = textBox.TextSize
		lbl.LineHeight = textBox.LineHeight
		lbl.TextColor3 = COLORS[name] or COLORS.Default
		lbl.RichText = false
		lbl.TextWrapped = false
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.Position = UDim2.new(0, 0, 0, 0)
		lbl.ZIndex = textBox.ZIndex + 1
		lbl.Text = ""
		lbl.Visible = true
		lbl.Parent = textBox
		layers[name] = lbl
	end

	local function setVisible(v)
		for _, lbl in pairs(layers) do lbl.Visible = v end
		textBox.TextTransparency = v and 0.4 or 0
	end

	local function refreshImmediate()
		local src = textBox.Text or ""
		if src == "" then
			for _, l in pairs(layers) do l.Text = "" end
			return
		end
		local built = highlighter.buildLayers(src)
		for name, lbl in pairs(layers) do lbl.Text = built[name] or "" end
	end

	local debounceId = 0
	local isRefreshing = false

	local function refreshDebounced()
		if isRefreshing then return end
		debounceId += 1
		local myId = debounceId

		if useThread then
			task.spawn(function()
				isRefreshing = true
				task.wait(debounceTime)
				if myId ~= debounceId then isRefreshing = false return end
				local src = textBox.Text or ""
				if src == "" then
					for _, l in pairs(layers) do l.Text = "" end
					isRefreshing = false
					setVisible(true)
					return
				end
				local built
				if #src > 10000 then
					task.wait()
					built = highlighter.buildLayers(src)
				else
					built = highlighter.buildLayers(src)
				end
				if myId ~= debounceId then isRefreshing = false return end
				for name, lbl in pairs(layers) do lbl.Text = built[name] or "" end
				isRefreshing = false
				setVisible(true)
			end)
		else
			task.delay(debounceTime, function()
				if myId ~= debounceId then return end
				refreshImmediate()
				setVisible(true)
			end)
		end
	end

	refreshImmediate()

	if hideOnFocus then
		textBox.Focused:Connect(function()
			debounceId += 1
			setVisible(false)
		end)
		textBox.FocusLost:Connect(function()
			setVisible(false)
			refreshDebounced()
		end)
	end

	if not updateOnFocusLostOnly then
		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			if not textBox:IsFocused() then
				refreshDebounced()
			end
		end)
	end

	return {
		layers = layers,
		refresh = refreshImmediate,
		refreshDebounced = refreshDebounced,
		setVisible = setVisible,
		applyLayers = function(built)
			if not built then return end
			debounceId += 1
			for name, lbl in pairs(layers) do
				lbl.Text = built[name] or ""
			end
			setVisible(true)
		end,
		setColor = function(n, c) if layers[n] then layers[n].TextColor3 = c end end,
		destroy = function() for _, l in pairs(layers) do l:Destroy() end end,
	}
end

-- ►►► LANJUT KE PART 2 ◄◄◄

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  PART 2/3 : UI Framework                                     ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ============================================================
-- TabReuse (OPTIMIZED: cached layers per tab → switch INSTAN)
-- ============================================================
local TabReuse = {}
TabReuse.__index = TabReuse

function TabReuse.new(bar, box, hl, onSwitch)
	local self = setmetatable({}, TabReuse)
	self.tabBar = bar
	self.textBox = box
	self.tabs = {}
	self.activeId = nil
	self.nextId = 1
	self.onSwitch = onSwitch

	if not bar:FindFirstChildOfClass("UIListLayout") then
		local l = Instance.new("UIListLayout")
		l.FillDirection = Enum.FillDirection.Horizontal
		l.Padding = UDim.new(0, 4)
		l.SortOrder = Enum.SortOrder.LayoutOrder
		l.Parent = bar
	end

	self.hl = hl.attach(box, { debounce = 0.15 })
	self.savePath = EtherLibrary.MainFolder .. "/" .. EtherLibrary.SavedTabEditorFolder .. "/tabs.json"

	box.FocusLost:Connect(function()
		self:SaveCurrent()
		self:SaveAllToDisk()
	end)

	self:LoadFromDisk()
	if not next(self.tabs) then
		self:AddTab("Main", "-- Paste/Write your script here!")
	end
	return self
end

function TabReuse:_makeButton(id, title)
	local btn = Create("TextButton", {
		Name = "Tab_" .. id,
		Size = UDim2.new(0, 110, 1, 0),
		BackgroundColor3 = Color3.fromRGB(35, 35, 42),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Parent = self.tabBar,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.new(0, 6, 0, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = btn,
	})
	local close = Create("TextButton", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(1, -20, 0.5, -8),
		BackgroundTransparency = 1,
		Text = "×",
		TextColor3 = Color3.fromRGB(180, 180, 180),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Parent = btn,
	})
	btn.MouseButton1Click:Connect(function() self:SwitchTo(id) end)
	close.MouseButton1Click:Connect(function() self:CloseTab(id) end)
	return btn
end

function TabReuse:SaveCurrent()
	if self.activeId and self.tabs[self.activeId] then
		local tab = self.tabs[self.activeId]
		tab.code = self.textBox.Text
		if tab.code ~= "" then
			tab._cachedLayers = highlighter.buildLayers(tab.code)
		else
			tab._cachedLayers = nil
		end
	end
end

-- ============================================================
-- SAVE / LOAD — Format: .lua file per tab (bukan JSON)
-- Filename: <order>__<sanitized_title>.lua
-- Contoh: 001__Main.lua, 002__My_Script.lua
-- ============================================================
function TabReuse:SaveAllToDisk()
	if not (writefile and isfolder and makefolder and listfiles and delfile) then return end
	self:SaveCurrent()
	local folder = EtherLibrary.MainFolder .. "/" .. EtherLibrary.SavedTabEditorFolder
	if not isfolder(folder) then pcall(makefolder, folder) end

	-- Hapus semua .lua lama di folder
	local okList, files = pcall(listfiles, folder)
	if okList and type(files) == "table" then
		for _, f in ipairs(files) do
			if type(f) == "string" and f:lower():sub(-4) == ".lua" then
				pcall(delfile, f)
			end
		end
	end

	-- Urutkan tab by id, tulis sebagai file .lua
	local ordered = {}
	for id, tab in pairs(self.tabs) do
		table.insert(ordered, { id = id, title = tab.title, code = tab.code })
	end
	table.sort(ordered, function(a, b) return a.id < b.id end)

	for idx, t in ipairs(ordered) do
		local safeTitle = (t.title or "Tab"):gsub("[^%w%s%-_]", ""):gsub("%s+", "_"):sub(1, 40)
		if safeTitle == "" then safeTitle = "Tab_" .. idx end
		local fileName = string.format("%03d__%s.lua", idx, safeTitle)
		local filePath = folder .. "/" .. fileName
		pcall(writefile, filePath, t.code or "")
	end
end

function TabReuse:LoadFromDisk()
	if not (readfile and isfile and isfolder and listfiles) then return end
	local folder = EtherLibrary.MainFolder .. "/" .. EtherLibrary.SavedTabEditorFolder
	if not isfolder(folder) then return end

	local okList, files = pcall(listfiles, folder)
	if not okList or type(files) ~= "table" then return end

	-- Kumpulkan .lua files & legacy json
	local luaFiles = {}
	local legacyJson = nil
	for _, f in ipairs(files) do
		if type(f) == "string" then
			if f:lower():sub(-4) == ".lua" then
				table.insert(luaFiles, f)
			elseif f:lower():sub(-5) == ".json" then
				legacyJson = f
			end
		end
	end
	table.sort(luaFiles)

	-- Load .lua files
	for _, f in ipairs(luaFiles) do
		local okRead, content = pcall(readfile, f)
		if okRead and content then
			local baseName = f:match("([^/\\]+)%.lua$") or "Tab"
			local title = baseName:match("^%d+__(.*)$") or baseName
			title = title:gsub("_", " ")
			if title == "" then title = "Tab" end
			local id = self.nextId
			self.nextId += 1
			local btn = self:_makeButton(id, title)
			self.tabs[id] = {
				title = title,
				code = content,
				button = btn,
				_cachedLayers = nil,
			}
		end
	end

	-- Migrasi dari legacy tabs.json kalau ada & belum ada .lua
	if #luaFiles == 0 and legacyJson and isfile(legacyJson) then
		local okRead, content = pcall(readfile, legacyJson)
		if okRead and content ~= "" then
			local okDec, decoded = pcall(HttpService.JSONDecode, HttpService, content)
			if okDec and decoded and decoded.tabs then
				for _, tabData in ipairs(decoded.tabs) do
					local id = self.nextId
					self.nextId += 1
					local title = tabData.title or ("Tab " .. id)
					local btn = self:_makeButton(id, title)
					self.tabs[id] = {
						title = title,
						code = tabData.code or "",
						button = btn,
						_cachedLayers = nil,
					}
				end
				self:SaveAllToDisk()
				if delfile then pcall(delfile, legacyJson) end
				warn("[Ether] Migrated legacy tabs.json → .lua format")
			end
		end
	end

	-- Aktifkan tab pertama
	if not self.activeId then
		for id, _ in pairs(self.tabs) do self.activeId = id break end
	end
	if self.activeId and self.tabs[self.activeId] then
		local targetTab = self.tabs[self.activeId]
		self.textBox.Text = targetTab.code
		if targetTab.code ~= "" then
			targetTab._cachedLayers = highlighter.buildLayers(targetTab.code)
			self.hl.applyLayers(targetTab._cachedLayers)
		else
			self.hl.refresh()
		end
		for tid, d in pairs(self.tabs) do
			d.button.BackgroundColor3 = (tid == self.activeId) and Color3.fromRGB(55, 55, 65) or Color3.fromRGB(35, 35, 42)
		end
		if self.onSwitch then self.onSwitch(targetTab) end
	end
end

-- Rename + getter methods
function TabReuse:RenameTab(id, newTitle)
	if not self.tabs[id] then return false end
	if not newTitle or newTitle:gsub("%s", "") == "" then return false end
	newTitle = newTitle:sub(1, 40)
	self.tabs[id].title = newTitle
	local btn = self.tabs[id].button
	if btn then
		local lbl = btn:FindFirstChild("Label")
		if lbl then lbl.Text = newTitle end
	end
	self:SaveAllToDisk()
	return true
end

function TabReuse:GetActiveTitle()
	if self.activeId and self.tabs[self.activeId] then return self.tabs[self.activeId].title end
	return "Untitled"
end

function TabReuse:GetActiveId()
	return self.activeId
end

function TabReuse:AddTab(title, code)
	self:SaveCurrent()
	local id = self.nextId
	self.nextId += 1
	local btn = self:_makeButton(id, title or ("Tab " .. id))
	self.tabs[id] = {
		title = title or ("Tab " .. id),
		code = code or "",
		button = btn,
		_cachedLayers = nil,
	}
	self:SwitchTo(id)
	self:SaveAllToDisk()
	return id
end

function TabReuse:SwitchTo(id)
	if not self.tabs[id] then return end
	if self.activeId == id then return end

	self:SaveCurrent()
	for tid, d in pairs(self.tabs) do
		d.button.BackgroundColor3 = (tid == id) and Color3.fromRGB(55, 55, 65) or Color3.fromRGB(35, 35, 42)
	end

	self.activeId = id
	local targetTab = self.tabs[id]
	self.textBox.Text = targetTab.code

	if self.hl then
		if targetTab.code == "" then
			self.hl.refresh()
		elseif targetTab._cachedLayers then
			self.hl.applyLayers(targetTab._cachedLayers) -- ⚡ INSTAN
		else
			targetTab._cachedLayers = highlighter.buildLayers(targetTab.code)
			self.hl.applyLayers(targetTab._cachedLayers)
		end
	end

	if self.onSwitch then self.onSwitch(targetTab) end
	self:SaveAllToDisk()
end

function TabReuse:CloseTab(id)
	if not self.tabs[id] then return end
	local wasActive = self.activeId == id
	self.tabs[id].button:Destroy()
	self.tabs[id] = nil

	if wasActive then
		self.activeId = nil
		local nextId = nil
		for tid, _ in pairs(self.tabs) do nextId = tid break end
		if nextId then
			self:SwitchTo(nextId)
		else
			self.textBox.Text = ""
			if self.hl then self.hl.refresh() end
			if self.onSwitch then self.onSwitch(nil) end
		end
	end
	self:SaveAllToDisk()
end

function TabReuse:GetActiveCode() return self.textBox.Text end

-- ============================================================
-- AdvancedHub (Fetch from RScripts/RobloxScripts/ScriptBlox)
-- ============================================================
local AdvancedHub = {}
AdvancedHub.__index = AdvancedHub

function AdvancedHub.new()
	return setmetatable({
		engines = { "RScripts", "RobloxScripts", "ScriptBlox" },
		currentEngine = "RScripts",
		pagination = { current = 1, total = 1, query = "", hasResults = false },
		currentPageScripts = {},
		filterModes = { "Default", "Views", "Likes", "A-Z" },
		filterMode = "Default",
		searching = false
	}, AdvancedHub)
end

function AdvancedHub:Toast(msg, parent)
	local toast = Create("TextLabel", {
		Size = UDim2.new(0, 260, 0, 30),
		Position = UDim2.new(0.5, -130, 1, -40),
		BackgroundColor3 = Color3.fromRGB(30, 144, 255),
		Text = msg,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		ZIndex = 200,
		Parent = parent
	})
	if toast then
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = toast })
		TweenService:Create(toast, TweenInfo.new(0.3), { Position = UDim2.new(0.5, -130, 1, -70) }):Play()
		task.delay(2, function()
			TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
			task.wait(0.3)
			toast:Destroy()
		end)
	end
end

function AdvancedHub:Fetch(engine, query, page)
	page = page or 1
	query = query or ""
	local encoded = urlEncode(query)
	local url = ""
	if engine == "RScripts" then
		url = string.format("https://rscripts.net/api/v2/scripts?page=%d&orderBy=date&sort=desc", page)
		if query ~= "" then url = url .. "&q=" .. encoded end
	elseif engine == "RobloxScripts" then
		url = string.format("https://robloxscripts.com/api/v1/scripts?page=%d&limit=24&sort=newest", page)
		if query ~= "" then url = url .. "&q=" .. encoded end
	else
		if query == "" then
			url = string.format("https://scriptblox.com/api/script/fetch?page=%d", page)
		else
			url = string.format("https://scriptblox.com/api/script/search?q=%s&page=%d", encoded, page)
		end
	end
	local ok, body = universalHttpGet(url)
	if not ok then return {}, 1 end
	local ok2, dec = pcall(HttpService.JSONDecode, HttpService, body)
	if not ok2 or not dec then return {}, 1 end

	local data, totalPages = {}, 1
	if engine == "RScripts" then
		data = dec.scripts or {}
		totalPages = dec.info and dec.info.maxPages or dec.totalPages or 1
	elseif engine == "RobloxScripts" then
		data = dec.data or {}
		local pag = dec.pagination or {}
		totalPages = tonumber(pag.totalPages or pag.pages or pag.lastPage or 1) or 1
		if pag.total and pag.limit then totalPages = math.ceil(pag.total / math.max(pag.limit, 1)) end
		totalPages = math.min(totalPages, 200)
	else
		local result = dec.result or {}
		data = result.scripts or {}
		totalPages = result.totalPages or 1
	end

	local normalized = {}
	for _, item in ipairs(data) do
		local rawUrl=""
		local isUrl=false
		local directCode=""
		if engine=="RScripts" then
			rawUrl=item.rawScript or item.scriptLink or item.raw or item.rawScriptUrl or ""
			isUrl=true
			directCode=""
		else
			directCode=item.script or item.code or ""
			rawUrl=item.rawScriptUrl or item.scriptLink or item.raw or ""
			isUrl=rawUrl~="" and directCode==""
			if isUrl then
				
			else
				rawUrl=""
			end
		end
		table.insert(normalized,{
			title=item.title or "No Title",
			author=item.creator and item.creator.username or item.owner or "Anon",
			description=item.description or "",
			views=item.views or 0,
			likes=item.likes or item.likeCount or 0,
			source=engine,
			scriptCode=directCode, -- bisa kosong untuk RScripts
			rawUrl=rawUrl,
			isUrl=isUrl,
			_raw=item,
			gameId=item.gameId or (item.game and item.game.gameId) or item.placeId or (item.game and item.game.placeId)
		})
	end
	return normalized, totalPages
end

-- ============================================================
-- SAVE FILE — default .lua, tapi bisa format lain (txt/js/py/dll)
-- ============================================================
function AdvancedHub:SaveAsFile(data, extension)
	extension = tostring(extension or "lua"):gsub("[^%w]", ""):lower()
	if extension == "" then extension = "lua" end

	local safeName = (data.title or "script"):gsub("[^%w%s%-_]", ""):gsub("%s+", "_"):sub(1, 40)
	if safeName == "" then safeName = "script_" .. os.time() end

	local filePath = EtherLibrary.MainFolder .. "/" .. EtherLibrary.SavedScriptHubFolder .. "/" .. safeName .. "." .. extension
	local header = string.format(
		"--[[ Saved from Ether Executor\n   Title: %s\n   Source: %s\n   SavedAt: %s\n   Format: .%s\n]]\n\n",
		data.title or "Untitled",
		data.source or "Unknown",
		os.date("%Y-%m-%d %H:%M:%S"),
		extension
	)
	local fullCode = header .. (data.scriptCode or "")

	if writefile then
		local ok, err = pcall(writefile, filePath, fullCode)
		if ok then
			print("[Ether Save] Saved as ." .. extension .. ": " .. filePath)
			return true, filePath
		else
			warn("[Ether Save] Failed: " .. tostring(err))
			return false
		end
	end
	return false
end

-- Alias backward-compat (default .lua)
function AdvancedHub:SaveAsLua(data)
	return self:SaveAsFile(data, "lua")
end

-- ============================================================
-- LOAD SAVED — baca semua file non-json sebagai kode
-- Format apapun didukung (default .lua), .json legacy tetap dibaca
-- ============================================================
function AdvancedHub:LoadSavedScripts()
	local folder = EtherLibrary.MainFolder .. "/" .. EtherLibrary.SavedScriptHubFolder
	if not (isfolder and isfolder(folder) and listfiles) then return {} end
	local ok, files = pcall(listfiles, folder)
	if not ok or type(files) ~= "table" then return {} end

	local results = {}
	for _, f in ipairs(files) do
		if type(f) ~= "string" then continue end
		local lower = f:lower()

		if lower:sub(-5) == ".json" then
			-- Legacy JSON — baca untuk backward compat, tapi bisa dikonversi
			local okRead, content = pcall(readfile, f)
			if okRead then
				local okDec, data = pcall(HttpService.JSONDecode, HttpService, content)
				if okDec and data then
					table.insert(results, {
						filePath = f,
						fileName = f:match("([^/\\]+)%.json$") or "old",
						title = data.title or "Old JSON",
						code = data.code or "",
						isLua = false,
						isOldJson = true,
						ext = "json",
					})
				end
			end
		else
			-- Semua file non-json diperlakukan sebagai source code (default .lua)
			local okRead, content = pcall(readfile, f)
			if okRead and content then
				local fileName = f:match("([^/\\]+)%.%w+$") or (f:match("([^/\\]+)$") or "Untitled")
				local baseName = f:match("([^/\\]+)%.%w+$") or fileName
				local ext = f:match("%.(%w+)$") or "lua"
				local headerTitle = content:match("Title:%s*(.-)\n")
				local title = headerTitle or baseName:gsub("_", " ")
				table.insert(results, {
					filePath = f,
					fileName = fileName,
					title = title,
					code = content,
					isLua = (ext:lower() == "lua"),
					ext = ext,
				})
			end
		end
	end

	table.sort(results, function(a, b) return (a.title or ""):lower() < (b.title or ""):lower() end)
	self.savedScriptsCache = results
	return results
end

function AdvancedHub:Save(data)
	local title = data.title or ("script_" .. os.time())
	local path = EtherLibrary.MainFolder .. "/" .. EtherLibrary.SavedScriptHubFolder .. "/" .. (title:gsub("[^%w%s]", ""):sub(1, 30) .. ".json")
	local ok, json = pcall(HttpService.JSONEncode, HttpService, {
		title = data.title,
		code = data.scriptCode,
		source = data.source,
		savedAt = os.date()
	})
	if ok and writefile then pcall(writefile, path, json) end
end

-- Hub instance (dipindah ke sini supaya Part 2 bisa pakai)
local hub = AdvancedHub.new()

-- ============================================================
-- Theme utilities
-- ============================================================
local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then return "BackgroundColor3"
	elseif Object:IsA("ScrollingFrame") then return "ScrollBarImageColor3"
	elseif Object:IsA("UIStroke") then return "Color"
	elseif Object:IsA("TextLabel") or Object:IsA("TextBox") then return "TextColor3"
	elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then return "ImageColor3" end
	return "BackgroundColor3"
end

local function AddThemeObject(Object, ThemeKey, SpecificProperty)
	if not EtherLibrary.ThemeObjects[ThemeKey] then EtherLibrary.ThemeObjects[ThemeKey] = {} end
	local targetProperty = SpecificProperty or ReturnProperty(Object)
	table.insert(EtherLibrary.ThemeObjects[ThemeKey], { Object = Object, Property = targetProperty })
	local currentTheme = EtherLibrary.Themes[EtherLibrary.SelectedTheme]
	if currentTheme and currentTheme[ThemeKey] then
		Object[targetProperty] = currentTheme[ThemeKey]
	end
	return Object
end

function EtherLibrary:AddTheme(themeName, themeTable)
	if type(themeName) == "string" and type(themeTable) == "table" then
		EtherLibrary.Themes[themeName] = themeTable
	end
end

function EtherLibrary:SetTheme(themeInput)
	local targetTheme = nil
	if type(themeInput) == "string" then
		if EtherLibrary.Themes[themeInput] then
			EtherLibrary.SelectedTheme = themeInput
			targetTheme = EtherLibrary.Themes[themeInput]
		end
	elseif type(themeInput) == "table" then
		targetTheme = themeInput
		EtherLibrary.SelectedTheme = "Custom"
	end
	if not targetTheme then return end
	for themeKey, objectList in pairs(EtherLibrary.ThemeObjects) do
		local targetColor = targetTheme[themeKey]
		if targetColor then
			for i = #objectList, 1, -1 do
				local item = objectList[i]
				if item.Object and item.Object.Parent then
					item.Object[item.Property] = targetColor
				else
					table.remove(objectList, i)
				end
			end
		end
	end
end

-- ============================================================
-- MakeDraggable
-- ============================================================
local function MakeDraggable(DragPoint, Main)
	Main = Main or DragPoint
	if typeof(DragPoint) ~= "Instance" or typeof(Main) ~= "Instance" then return end
	local Dragging = false
	local DragInput = nil
	local MousePos = nil
	local FramePos = nil

	SafeConnect(DragPoint.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			if Dragging and activeInteraction ~= nil then return end
			Dragging = true
			MousePos = Input.Position
			FramePos = Main.Position
			DragInput = Input
			local changedConnection
			changedConnection = Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
					DragInput = nil
					if changedConnection then changedConnection:Disconnect() end
				end
			end)
		end
	end)

	SafeConnect(DragPoint.InputChanged, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			if not Dragging then DragInput = Input end
		end
	end)

	SafeConnect(uis.InputChanged, function(Input)
		if Dragging and activeInteraction == nil and Input == DragInput then
			local Delta = Input.Position - MousePos
			Main.Position = UDim2.new(
				FramePos.X.Scale,
				FramePos.X.Offset + Delta.X,
				FramePos.Y.Scale,
				FramePos.Y.Offset + Delta.Y
			)
		end
	end)

	SafeConnect(Main.AncestryChanged, function(_, parent)
		if not parent then Dragging = false end
	end)
end

local function registerFlag(config, controller)
	if not config.Flag then return end
	if EtherLibrary.Flags[config.Flag] ~= nil then
		warn("[EtherExecutor] Duplicate flag: '" .. tostring(config.Flag) .. "' on '" .. tostring(config.Title) .. "'")
		return
	end
	EtherLibrary.Flags[config.Flag] = config.Default
end

local function execCallback(callback, itemConfig, ...)
	if type(callback) ~= "function" then return true end
	local isSafe = true
	if itemConfig and (typeof(itemConfig.SafeCallback) == "boolean" and itemConfig.SafeCallback ~= nil) then
		isSafe = itemConfig.SafeCallback
	end
	if isSafe then
		local success, err = xpcall(callback, function(errMessage)
			return errMessage .. "\n" .. debug.traceback("", 2)
		end, ...)
		if not success then
			local elementName = "Unknown Element"
			if type(itemConfig) == "table" then
				elementName = itemConfig.Title or itemConfig.Name or itemConfig.Text or "Element"
			end
			warn("[EtherLibrary SafeCallback Error on " .. tostring(elementName) .. "]:\n" .. tostring(err))
			return false
		end
		return true
	else
		callback(...)
		return true
	end
end

local function randomNameString()
	local length = math.random(40, 60)
	local array = {}
	for i = 1, length do
		local charType = math.random(1, 3)
		if charType == 1 then array[i] = string.char(math.random(48, 57))
		elseif charType == 2 then array[i] = string.char(math.random(97, 122))
		else array[i] = string.char(math.random(65, 90)) end
	end
	return table.concat(array)
end

function EtherLibrary:Destroy()
	if EtherLibrary.GlobalAutoSave == true then task.wait(4) end
	if EtherLibrary.Connections then
		for _, conn in ipairs(EtherLibrary.Connections) do
			if typeof(conn) == "RBXScriptConnection" and conn.Connected then
				pcall(function() conn:Disconnect() end)
			end
		end
		table.clear(EtherLibrary.Connections)
	end
	if EtherExecutor then
		pcall(function() EtherExecutor:Destroy() end)
		EtherExecutor = nil
	end
	if EtherLibrary.ThemeObjects then table.clear(EtherLibrary.ThemeObjects) end
	if EtherLibrary.Flags then table.clear(EtherLibrary.Flags) end
	if EtherLibrary.Themes then table.clear(EtherLibrary.Themes) end
	if IconPacks then table.clear(IconPacks) end
	if getgenv().EtherExecutorLibrary == EtherLibrary then
		getgenv().EtherExecutorLibrary = nil
	end
end

-- ============================================================
-- Notification & Popup
-- ============================================================
local function getNotificationContainer()
	local container = EtherExecutor:FindFirstChild("NotificationHolder")
	if not container then
		container = Create("Frame", {
			Name = "NotificationHolder",
			Parent = EtherExecutor,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -25, 1, -25),
			Size = UDim2.new(0, 240, 1, -25),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			ZIndex = 99
		})
		Create("UIListLayout", {
			Parent = container,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 5)
		})
	end
	return container
end

local function Notification(NotificationConfig)
	task.spawn(function()
		NotificationConfig = NotificationConfig or {}
		NotificationConfig.Title = (NotificationConfig.Title or NotificationConfig.Name or NotificationConfig.Text) or "Notification"
		NotificationConfig.Content = (NotificationConfig.Content or NotificationConfig.Desc or NotificationConfig.Description) or "Hello World"
		NotificationConfig.Image = (NotificationConfig.Image or NotificationConfig.Icon) or 4384403532
		NotificationConfig.Type = NotificationConfig.Type or "Info"
		NotificationConfig.Time = ((NotificationConfig.Time or NotificationConfig.Duration) or (NotificationConfig.duration)) or 5
		local NotificationHolder = getNotificationContainer()
		local accentColors = {
			Info = Color3.fromRGB(52, 152, 219),
			Success = Color3.fromRGB(46, 204, 113),
			Warning = Color3.fromRGB(241, 196, 15),
			Error = Color3.fromRGB(231, 76, 60)
		}
		local accentColor = accentColors[NotificationConfig.Type] or accentColors.Info
		local isDismissed = false
		local NotificationParent = Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ClipsDescendants = false, Parent = NotificationHolder })
		local NotificationFrame = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(1, 50, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = EtherLibrary["Themes"]["Default"].WindowBackground, BackgroundTransparency = 1, Parent = NotificationParent })
		Create("UICorner", { CornerRadius = UDim.new(0.1, 0), Parent = NotificationFrame })
		local NotificationFrame_Stroke = Create("UIStroke", { Parent = NotificationFrame, Thickness = 1.2, Color = accentColor, Transparency = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Enabled = true })
		Create("UIPadding", { Parent = NotificationFrame, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
		local closeNotifButton = Create("ImageButton", { AnchorPoint = Vector2.new(1, 0), Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Image = "rbxassetid://7072725342", ImageColor3 = Color3.fromRGB(255, 255, 255), Parent = NotificationFrame })
		local contentHolder = Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = NotificationFrame })
		Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = contentHolder })
		local textHolder = Create("Frame", { Size = UDim2.new(1, -25, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Parent = contentHolder })
		Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = textHolder })
		local Icon = Create("ImageLabel", { Size = UDim2.new(0, 24, 0, 24), BackgroundTransparency = 1, ImageColor3 = Color3.fromRGB(240, 240, 240), Name = "Icon", LayoutOrder = 1, ImageTransparency = 1, Parent = textHolder })
		local Title = Create("TextLabel", { Parent = textHolder, Size = UDim2.new(1, -32, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Text = NotificationConfig.Title, TextTransparency = 1, LayoutOrder = 2 })
		if NotificationConfig.Image and (NotificationConfig.Image ~= nil and NotificationConfig.Image ~= "") then
			applyIcon(Icon, NotificationConfig.Image)
		else
			Icon:Destroy()
			Title.Size = UDim2.new(1, 0, 0, 0)
		end
		local Content = Create("TextLabel", { Parent = contentHolder, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.GothamSemibold, TextColor3 = Color3.fromRGB(220, 220, 220), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextTransparency = 1, LayoutOrder = 2, Text = NotificationConfig.Content })
		local ProgressBarParent = Create("Frame", { AnchorPoint = Vector2.new(0, 1), Parent = NotificationFrame, Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, 5), BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(60, 60, 60), BorderSizePixel = 0 })
		Create("UICorner", { Parent = ProgressBarParent, CornerRadius = UDim.new(0, 3) })
		local ProgressBar = Create("Frame", { AnchorPoint = Vector2.new(0, 0), Parent = ProgressBarParent, Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, BackgroundColor3 = accentColor, BorderSizePixel = 0 })
		Create("UICorner", { Parent = ProgressBar, CornerRadius = UDim.new(0, 3) })
		local SlideInTween = TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0 })
		local barTween = TweenService:Create(ProgressBar, TweenInfo.new(NotificationConfig.Time, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })
		SlideInTween:Play()

		local function DismissNotification()
			if isDismissed then return end
			isDismissed = true
			barTween:Cancel()
			NotificationParent.Size = UDim2.new(1, 0, 0, NotificationFrame.AbsoluteSize.Y)
			NotificationParent.AutomaticSize = Enum.AutomaticSize.None
			TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1 }):Play()
			TweenService:Create(NotificationFrame_Stroke, TweenInfo.new(0.2), { Transparency = 1 }):Play()
			TweenService:Create(Title, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
			TweenService:Create(Content, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
			TweenService:Create(ProgressBarParent, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(ProgressBar, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
			if Icon and Icon.Parent then TweenService:Create(Icon, TweenInfo.new(0.2), { ImageTransparency = 1 }):Play() end
			task.wait(0.25)
			local shrinkTween = TweenService:Create(NotificationParent, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Size = UDim2.new(1, 0, 0, 0) })
			shrinkTween:Play()
			shrinkTween.Completed:Connect(function() NotificationParent:Destroy() end)
		end

		SlideInTween.Completed:Connect(function()
			TweenService:Create(NotificationFrame_Stroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
			TweenService:Create(Title, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
			TweenService:Create(Content, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
			TweenService:Create(ProgressBarParent, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
			TweenService:Create(ProgressBar, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
			if Icon and Icon.Parent then TweenService:Create(Icon, TweenInfo.new(0.2), { ImageTransparency = 0 }):Play() end
			task.wait(0.25)
			if (typeof(NotificationConfig.Time) == "string" and NotificationConfig.Time == "inf") or NotificationConfig.Time == 0 then
				ProgressBarParent:Destroy()
			else
				barTween:Play()
				task.delay(NotificationConfig.Time, function()
					if not isDismissed then DismissNotification() end
				end)
			end
		end)

		closeNotifButton.MouseButton1Click:Connect(DismissNotification)
	end)
end

local function Popup(config)
	config = config or {}
	config.Title = config.Title or "Confirmation"
	config.Content = config.Content or "Are you sure you want to proceed?"
	config.Mode = config.Mode or "Alert"
	config.AcceptText = config.AcceptText or (config.Mode == "YesNo" and "Yes" or "OK")
	config.CancelText = config.CancelText or "No"
	config.OnAccept = config.OnAccept or function() end
	config.OnCancel = config.OnCancel or function() end

	local overlay = Instance.new("TextButton")
	overlay.Name = "PopupOverlay"
	overlay.Parent = EtherExecutor
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.ZIndex = 15

	local popupFrame = Instance.new("Frame")
	local popupCorner = Instance.new("UICorner")
	local popupStroke = Instance.new("UIStroke")
	local titleLabel = Instance.new("TextLabel")
	local contentLabel = Instance.new("TextLabel")
	local buttonHolder = Instance.new("Frame")
	local buttonLayout = Instance.new("UIListLayout")

	popupFrame.Parent = overlay
	popupFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	popupFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	popupFrame.Size = UDim2.new(0, 320, 0, 160)
	popupFrame.BackgroundColor3 = Color3.fromRGB(35, 39, 42)
	popupFrame.ClipsDescendants = true
	popupFrame.ZIndex = 15
	popupCorner.CornerRadius = UDim.new(0, 8)
	popupCorner.Parent = popupFrame
	popupStroke.Color = Color3.fromRGB(60, 64, 72)
	popupStroke.Thickness = 1
	popupStroke.Parent = popupFrame

	titleLabel.Parent = popupFrame
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0, 15, 0, 12)
	titleLabel.Size = UDim2.new(1, -30, 0, 20)
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.Text = config.Title
	titleLabel.TextColor3 = Color3.fromRGB(245, 246, 250)
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	contentLabel.Parent = popupFrame
	contentLabel.BackgroundTransparency = 1
	contentLabel.Position = UDim2.new(0, 15, 0, 38)
	contentLabel.Size = UDim2.new(1, -30, 0, 60)
	contentLabel.Font = Enum.Font.SourceSans
	contentLabel.Text = config.Content
	contentLabel.TextColor3 = Color3.fromRGB(189, 195, 199)
	contentLabel.TextSize = 14
	contentLabel.TextWrapped = true
	contentLabel.TextXAlignment = Enum.TextXAlignment.Left
	contentLabel.TextYAlignment = Enum.TextYAlignment.Top

	buttonHolder.Parent = popupFrame
	buttonHolder.BackgroundTransparency = 1
	buttonHolder.Position = UDim2.new(0, 15, 1, -42)
	buttonHolder.Size = UDim2.new(1, -30, 0, 30)
	buttonLayout.Parent = buttonHolder
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	buttonLayout.Padding = UDim.new(0, 8)

	local function createButton(text, bgCol, callback)
		local btn = Instance.new("TextButton")
		local btnCorner = Instance.new("UICorner")
		btn.Parent = buttonHolder
		btn.Size = UDim2.new(0, config.Mode == "YesNo" and 90 or 100, 1, 0)
		btn.BackgroundColor3 = bgCol
		btn.Font = Enum.Font.SourceSansBold
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(245, 246, 250)
		btn.TextSize = 14
		btn.ZIndex = 1002
		btnCorner.CornerRadius = UDim.new(0, 4)
		btnCorner.Parent = btn
		btn.MouseButton1Click:Connect(function()
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			TweenService:Create(overlay, tweenInfo, { BackgroundTransparency = 1 }):Play()
			local closeTween = TweenService:Create(popupFrame, tweenInfo, { Size = UDim2.new(0, 0, 0, 0) })
			closeTween:Play()
			closeTween.Completed:Connect(function()
				overlay:Destroy()
				if callback then execCallback(callback, config) end
			end)
		end)
	end

	if config.Mode == "YesNo" then
		createButton(config.CancelText, Color3.fromRGB(72, 84, 96), config.OnCancel)
		createButton(config.AcceptText, Color3.fromRGB(232, 65, 24), config.OnAccept)
	else
		createButton(config.AcceptText, Color3.fromRGB(9, 132, 227), config.OnAccept)
	end

	popupFrame.Size = UDim2.new(0, 320, 0, 0)
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.6 }):Play()
	TweenService:Create(popupFrame, tweenInfo, { Size = UDim2.new(0, 320, 0, 160) }):Play()
end

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local UIWindow = Create("Frame", {
	Name = tostring(createUIName()),
	Parent = EtherExecutor,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 340, 0, 300),
	Size = UDim2.new(0, 340, 0, 300),
	Active = false,
	ClipsDescendants = true
})

local MainFrameParent = Create("Frame", {
	Name = tostring(createUIName()),
	Parent = EtherExecutor,
	BackgroundTransparency = 1,
	BorderColor3 = Color3.fromRGB(0, 151, 230),
	Position = UDim2.new(0, 50, 0, 50),
	Size = UDim2.new(0, 530, 0, 300),
	Active = false,
	ClipsDescendants = true
})

Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = MainFrameParent
})

local HeaderFrame = Create("Frame", {
	Name = "HeaderFrame",
	Parent = MainFrameParent,
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 40),
	Active = true
})

local MainExeWinFrame = Create("Frame", {
	Name = tostring(createUIName()),
	Parent = MainFrameParent,
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1),
	Size = UDim2.new(1, 0, 1, -40),
	Active = false
})
Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = MainExeWinFrame
})

local HeaderContentFrame = Create("Frame", {
	Name = "HeaderContentFrame",
	Parent = HeaderFrame,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -60, 1, 0),
	Active = false
})
Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = HeaderContentFrame
})

local HeaderTextFrame = Create("Frame", {
	Name = "HeaderTextFrame",
	Parent = HeaderContentFrame,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	Active = false
})
Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = HeaderTextFrame
})

MakeDraggable(HeaderFrame, MainFrameParent)

Create("TextLabel", {
	Name = "TitleText",
	Parent = HeaderTextFrame,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.new(1, -140, 0.5, 0),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Text = "Ether Internal Executor",
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
	Active = false
})

Create("TextLabel", {
	Name = "SubTitleText",
	Parent = HeaderTextFrame,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.new(1, -140, 0.5, 0),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(205, 205, 205),
	Text = Version,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left,
	Active = false
})

local HeaderToolBarFrame = Create("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	Name = "HeaderToolBarFrame",
	Parent = HeaderFrame,
	BackgroundTransparency = 1,
	Position = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.X,
	Size = UDim2.new(0, 0, 1, 0),
	Active = false
})
Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = HeaderToolBarFrame
})

local DestroyBut = Create("TextButton", {
	Name = "DestroyBut",
	Parent = HeaderToolBarFrame,
	BackgroundColor3 = Color3.fromRGB(255, 0, 0),
	BorderSizePixel = 0,
	Size = UDim2.new(0, 50, 1, 0),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(242, 243, 243),
	Text = "×",
	TextSize = 18,
	Active = true
})
SafeConnect(DestroyBut.MouseButton1Click, function() EtherLibrary:Destroy() end)

local MinimizeBut = Create("TextButton", {
	Name = "MinimizeBut",
	Parent = HeaderToolBarFrame,
	BackgroundColor3 = Color3.fromRGB(0, 0, 255),
	BorderSizePixel = 0,
	Size = UDim2.new(0, 50, 1, 0),
	Font = Enum.Font.FredokaOne,
	TextColor3 = Color3.fromRGB(242, 243, 243),
	Text = "-",
	TextSize = 18,
	Active = true
})

local TabHolder = Create("ScrollingFrame", {
	Name = "TabFrame",
	Parent = MainExeWinFrame,
	BackgroundColor3 = Color3.fromRGB(45, 45, 45),
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	ScrollBarThickness = 0,
	Size = UDim2.new(0, 50, 1, 0),
	Active = true
})
Create("UIListLayout", {
	Name = "TabHolderListLayout",
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = TabHolder
})
Create("UIPadding", {
	PaddingRight = UDim.new(0, 5),
	PaddingLeft = UDim.new(0, 5),
	Parent = TabHolder
})

local contentArea = Instance.new("Frame")
contentArea.Name = "contentArea"
contentArea.BackgroundTransparency = 1
contentArea.Position = UDim2.new(0, 0, 0, 0)
contentArea.Size = UDim2.new(1, -50, 1, 0)
contentArea.Parent = MainExeWinFrame

local minimize = false
local tweening = false
SafeConnect(MinimizeBut.MouseButton1Click, function()
	if tweening then return end
	tweening = true
	minimize = not minimize
	local easing = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local SizeAnimUIOut = TweenService:Create(MainExeWinFrame, easing, { Size = UDim2.new(1, 0, 0, 0) })
	local SizeAnimUIIn = TweenService:Create(MainExeWinFrame, easing, { Size = UDim2.new(1, 0, 1, -40) })
	if minimize then
		MinimizeBut.Text = "+"
		SizeAnimUIOut:Play()
		SizeAnimUIOut.Completed:Connect(function()
			tweening = false
			MainExeWinFrame.Visible = false
		end)
	else
		MainExeWinFrame.Visible = true
		MinimizeBut.Text = "–"
		SizeAnimUIIn:Play()
		SizeAnimUIIn.Completed:Connect(function() tweening = false end)
	end
end)

local window = {
	_autoSaveConnected = false,
	winContentArea = contentArea,
	tabs = {},
	activeTab = nil
}

local function AddTab(TabConfig)
	TabConfig = TabConfig or {}
	TabConfig.Title = TabConfig.Title or "Main"
	TabConfig.Icon = TabConfig.Icon or "sword"
	TabConfig.IsAutoLayout = TabConfig.IsAutoLayout or false
	TabConfig.AutoSizeScroll = TabConfig.AutoSizeScroll or false

	local tab = {
		type = "tab",
		title = TabConfig.Title,
		buttonInstance = nil,
		buttonTitle = nil,
		containerInstance = nil
	}

	local tabButtonFrame = Create("Frame", {
		Name = TabConfig.Title,
		Parent = TabHolder,
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 45),
		Active = true
	})

	local tabButton = Create("TextButton", {
		Name = "_Button",
		Parent = tabButtonFrame,
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		TextTransparency = 1,
		Active = false
	})
	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabButton
	})
	Create("UIPadding", {
		PaddingBottom = UDim.new(0, 5),
		PaddingTop = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		Parent = tabButton
	})

	local Iccon = Create("ImageLabel", {
		Size = UDim2.new(0, 24, 0, 24),
		BackgroundTransparency = 1,
		ImageColor3 = Color3.fromRGB(240, 240, 240),
		Name = "Icon",
		LayoutOrder = 1,
		Parent = tabButton
	})
	if TabConfig.Icon and (TabConfig.Icon ~= nil and TabConfig.Icon ~= "") then
		applyIcon(Iccon, TabConfig.Icon)
	else
		Iccon:Destroy()
	end

	local tabButtonTitle = Create("TextLabel", {
		LayoutOrder = 2,
		Parent = tabButton,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Font = Enum.Font.GothamSemibold,
		Text = TabConfig.Title,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Active = false
	})
	AddThemeObject(tabButtonTitle, "NormalText", "TextColor3")

	local tabContainer = Create("ScrollingFrame", {
		Name = "Content_" .. TabConfig.Title,
		Parent = window.winContentArea,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = TabConfig.AutoSizeScroll and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		ScrollBarThickness = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		Active = true
	})
	Create("UIPadding", {
		PaddingBottom = UDim.new(0, 5),
		PaddingTop = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
		PaddingLeft = UDim.new(0, 5),
		Parent = tabContainer
	})
	if TabConfig.IsAutoLayout then
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = tabContainer
		})
	end

	tab.buttonTitle = tabButtonTitle
	tab.buttonInstance = tabButtonFrame
	tab.containerInstance = tabContainer

	function tab:Select()
		for _, otherTab in ipairs(window.tabs) do
			if otherTab.containerInstance then otherTab.containerInstance.Visible = false end
			if otherTab.buttonInstance then otherTab.buttonInstance.BackgroundTransparency = 1 end
			if otherTab.buttonTitle then otherTab.buttonTitle.TextTransparency = 0.2 end
		end
		tab.containerInstance.Visible = true
		tab.buttonInstance.BackgroundTransparency = 0
		tab.buttonTitle.TextTransparency = 0
		window.activeTab = tab
	end

	tabButton.MouseButton1Click:Connect(function() tab:Select() end)
	table.insert(window.tabs, tab)
	if #window.tabs == 1 and window.activeTab == nil then tab:Select() end
	return tab
end

local exeTabs = {
	CodeTab = AddTab({ Title = "Code", Icon = "code" }),
	ScriptSearchTab = AddTab({ Title = "Search", Icon = "search" }),
	SavedTab = AddTab({ Title = "Saved", Icon = "folder" }),
	InfoTab = AddTab({ Title = "Info", Icon = "info", IsAutoLayout = true, AutoSizeScroll = true }),
	SettingsTab = AddTab({ Title = "Settings", Icon = "lucide:settings" })
}

-- ============================================================
-- CODE TAB (multi-file editor via TabReuse)
-- ============================================================
local EditorTabBar = Create("ScrollingFrame", {
	Name = "EditorTabBar",
	Parent = exeTabs.CodeTab.containerInstance,
	BackgroundColor3 = Color3.fromRGB(20, 20, 20),
	BorderSizePixel = 0,
	Position = UDim2.new(0, 5, 0, 5),
	Size = UDim2.new(1, -125, 0, 32), -- lebih kecil: kasih ruang Rename btn
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.X,
	ScrollingDirection = Enum.ScrollingDirection.X,
	ScrollBarThickness = 0,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	Active = true
})
Create("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = EditorTabBar })

local AddTabBtn = Create("TextButton", {
	Name = "AddTabBtn",
	Parent = exeTabs.CodeTab.containerInstance,
	Position = UDim2.new(1, -125, 0, 5),
	Size = UDim2.new(0, 55, 0, 32),
	BackgroundColor3 = Color3.fromRGB(40, 148, 215),
	BorderSizePixel = 0,
	Text = "+",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	AutoButtonColor = false,
	ZIndex = 5
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = AddTabBtn })

local RenameTabBtn = Create("TextButton", {
	Name = "RenameTabBtn",
	Parent = exeTabs.CodeTab.containerInstance,
	Position = UDim2.new(1, -65, 0, 5),
	Size = UDim2.new(0, 60, 0, 32),
	BackgroundColor3 = Color3.fromRGB(80, 80, 90),
	BorderSizePixel = 0,
	Text = "Rename",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	AutoButtonColor = false,
	ZIndex = 5
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = RenameTabBtn })

-- ============================================================
-- RENAME POPUP HELPER
-- ============================================================
local function createRenamePopup(currentTitle, onConfirm)
	local overlay = Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		ZIndex = 150,
		Parent = EtherExecutor
	})
	local popup = Create("Frame", {
		Size = UDim2.new(0, 320, 0, 140),
		Position = UDim2.new(0.5, -160, 0.5, -70),
		BackgroundColor3 = Color3.fromRGB(35, 35, 42),
		ZIndex = 151,
		Parent = overlay
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = popup })
	Create("TextLabel", {
		Size = UDim2.new(1, -20, 0, 25),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundTransparency = 1,
		Text = "Rename Tab",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 152,
		Parent = popup
	})
	local input = Create("TextBox", {
		Size = UDim2.new(1, -20, 0, 35),
		Position = UDim2.new(0, 10, 0, 40),
		BackgroundColor3 = Color3.fromRGB(25, 25, 30),
		Text = currentTitle or "",
		PlaceholderText = "New tab name...",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 152,
		Parent = popup
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = input })
	local saveBtn = Create("TextButton", {
		Size = UDim2.new(0, 80, 0, 30),
		Position = UDim2.new(1, -170, 1, -40),
		BackgroundColor3 = Color3.fromRGB(40, 148, 215),
		Text = "Save",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		AutoButtonColor = false,
		ZIndex = 152,
		Parent = popup
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = saveBtn })
	local cancelBtn = Create("TextButton", {
		Size = UDim2.new(0, 80, 0, 30),
		Position = UDim2.new(1, -85, 1, -40),
		BackgroundColor3 = Color3.fromRGB(60, 60, 70),
		Text = "Cancel",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		AutoButtonColor = false,
		ZIndex = 152,
		Parent = popup
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = cancelBtn })

	local function close() overlay:Destroy() end
	cancelBtn.MouseButton1Click:Connect(close)
	saveBtn.MouseButton1Click:Connect(function()
		local newName = input.Text
		if newName and newName:gsub("%s", "") ~= "" then onConfirm(newName) end
		close()
	end)
	input.FocusLost:Connect(function(enter)
	if enter then
		local newName = input.Text
		if newName and newName:gsub("%s", "") ~= "" then onConfirm(newName) end
			close()
		end
	end)
	task.defer(function() pcall(function() input:CaptureFocus() end) end)
end

local EditorFrameParent = Create("Frame", {
	Name = "EditorFrameParent",
	Parent = exeTabs.CodeTab.containerInstance,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 5, 0, 42),
	Size = UDim2.new(1, -10, 1, -130),
	ClipsDescendants = true
})
Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = EditorFrameParent
})

local lineTextFrameParent = Create("Frame", {
	Name = "lineTextFrameParent",
	Parent = EditorFrameParent,
	BackgroundTransparency = 1,
	AutomaticSize = Enum.AutomaticSize.X,
	Size = UDim2.new(0, 0, 1, 0)
})

local lineText = Instance.new("TextLabel", lineTextFrameParent)
lineText.Size = UDim2.new(0, 20, 1, 0)
lineText.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
lineText.BackgroundTransparency = 0
lineText.Font = Enum.Font.Code
lineText.AutomaticSize = Enum.AutomaticSize.X
lineText.TextSize = 12
lineText.TextXAlignment = Enum.TextXAlignment.Right
lineText.TextYAlignment = Enum.TextYAlignment.Top
lineText.TextColor3 = Color3.fromRGB(100, 100, 100)
lineText.Text = "1"

local EditorHolder = Instance.new("ScrollingFrame")
EditorHolder.Name = "EditorHolder"
EditorHolder.Parent = EditorFrameParent
EditorHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
EditorHolder.BorderSizePixel = 0
EditorHolder.Position = UDim2.new(0, 5, 0, 5)
EditorHolder.Size = UDim2.new(1, lineText.AbsoluteSize.X, 1, 0)
EditorHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
EditorHolder.ScrollBarThickness = 1
EditorHolder.ElasticBehavior = Enum.ElasticBehavior.Never
EditorHolder.AutomaticCanvasSize = Enum.AutomaticSize.XY
EditorHolder.ScrollingDirection = Enum.ScrollingDirection.XY
EditorHolder.Active = false

local TextBox1 = Instance.new("TextBox")
TextBox1.Name = "Editor_Script"
TextBox1.Parent = EditorHolder
TextBox1.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TextBox1.BackgroundTransparency = 1
TextBox1.BorderSizePixel = 0
TextBox1.Size = UDim2.new(1, -lineText.AbsoluteSize.X, 1, 0)
TextBox1.Font = Enum.Font.Code
TextBox1.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox1.Text = ""
TextBox1.PlaceholderText = "Paste/Write your script here!"
TextBox1.TextWrapped = false
TextBox1.TextSize = 12
TextBox1.MultiLine = true
TextBox1.ClearTextOnFocus = false
TextBox1.TextXAlignment = Enum.TextXAlignment.Left
TextBox1.TextYAlignment = Enum.TextYAlignment.Top
TextBox1.RichText = true

local function autoSizeEditor(target, line, scroll)
	local textBounds = target.TextBounds
	local frameSize = scroll.AbsoluteSize
	local text = target.Text
	local lines = select(2, text:gsub("\n", "")) + 1
	local list = {}
	for i = 1, lines do list[#list+1] = tostring(i) end
	line.Text = table.concat(list, "\n")
	local newWidth = math.max(textBounds.X, frameSize.X)
	local newHeight = math.max(textBounds.Y, frameSize.Y)
	target.Size = UDim2.new(0, newWidth - line.AbsoluteSize.X, 0, newHeight)
	line.Size = UDim2.new(0, line.AbsoluteSize.X, 0, newHeight)
end

local tabEditor
tabEditor = TabReuse.new(EditorTabBar, TextBox1, highlighter, function(tabData)
	autoSizeEditor(TextBox1, lineText, EditorHolder)
end)

TextBox1.Focused:Connect(function()
	TextBox1.Size = UDim2.new(1, 0, 1, 0)
	TextBox1.TextTransparency = 0
	tabEditor.hl.setVisible(false)
	lineText.Size = UDim2.new(0, lineText.AbsoluteSize.X, 1, 0)
	EditorHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

TextBox1.FocusLost:Connect(function()
	autoSizeEditor(TextBox1, lineText, EditorHolder)
	local activeTab = tabEditor.activeId and tabEditor.tabs[tabEditor.activeId]
	if activeTab and activeTab._cachedLayers then
		tabEditor.hl.applyLayers(activeTab._cachedLayers) -- ⚡ pakai cache, gak rebuild
	else
		tabEditor.hl.refresh()
	end
	tabEditor.hl.setVisible(true)
end)

EditorHolder:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	lineText.Position = UDim2.new(0, 0, 0, -EditorHolder.CanvasPosition.Y)
end)

AddTabBtn.MouseButton1Click:Connect(function()
	tabEditor:AddTab("Tab " .. tabEditor.nextId, "")
end)

RenameTabBtn.MouseButton1Click:Connect(function()
	local activeId = tabEditor:GetActiveId()
	if not activeId then hub:Toast("No active tab", EtherExecutor) return end
	local current = tabEditor:GetActiveTitle()
	createRenamePopup(current, function(newName)
		local ok = tabEditor:RenameTab(activeId, newName)
		if ok then hub:Toast("Renamed to " .. newName, EtherExecutor) else hub:Toast("Failed rename", EtherExecutor) end
	end)
end)

local Execute_Editor_Scripts = Create("TextButton", {
	Name = "Execute_Editor_Scripts",
	Parent = exeTabs.CodeTab.containerInstance,
	BackgroundColor3 = Color3.fromRGB(40, 148, 215),
	BorderSizePixel = 0,
	Position = UDim2.new(0, 5, 0.8, 10),
	Size = UDim2.new(0.15, 0, 0, 30),
	Font = Enum.Font.GothamBold,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Text = "Execute",
	TextSize = 13,
	AutoButtonColor = false
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Execute_Editor_Scripts })
Execute_Editor_Scripts.MouseButton1Click:Connect(function()
	executeSource(TextBox1.Text, "=Editor1")
end)

local Clear_Editor_Scripts = Create("TextButton", {
	Name = "Clear_Editor_Scripts",
	Parent = exeTabs.CodeTab.containerInstance,
	BackgroundColor3 = Color3.fromRGB(200, 60, 60),
	BorderSizePixel = 0,
	Position = UDim2.new(0.2, -13, 0.8, 10),
	Size = UDim2.new(0.15, 0, 0, 30),
	Font = Enum.Font.GothamBold,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Text = "Clear",
	TextSize = 13,
	AutoButtonColor = false
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Clear_Editor_Scripts })
Clear_Editor_Scripts.MouseButton1Click:Connect(function()
	TextBox1.Text = ""
	tabEditor:SaveCurrent()
	tabEditor.hl.refresh()
	autoSizeEditor(TextBox1, lineText, EditorHolder)
end)

local Copy_Editor_Scripts = Create("TextButton", {
	Name = "Copy_Editor_Scripts",
	Parent = exeTabs.CodeTab.containerInstance,
	BackgroundColor3 = Color3.fromRGB(45, 49, 58),
	BorderSizePixel = 0,
	Position = UDim2.new(0.35, 5, 0.8, 10),
	Size = UDim2.new(0.15, 0, 0, 30),
	Font = Enum.Font.GothamBold,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Text = "Copy",
	TextSize = 13,
	AutoButtonColor = false
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Copy_Editor_Scripts })
Copy_Editor_Scripts.MouseButton1Click:Connect(function()
	if setclipboard then pcall(setclipboard, TextBox1.Text) end
end)

-- Save to Hub
local SaveToHubBtn = Create("TextButton", {
	Name = "SaveToHubBtn",
	Parent = exeTabs.CodeTab.containerInstance,
	BackgroundColor3 = Color3.fromRGB(255, 165, 0),
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 5, 0.8, 10),
	Size = UDim2.new(0.2, 0, 0, 30),
	Font = Enum.Font.GothamBold,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Text = "Save to Hub",
	TextSize = 13,
	AutoButtonColor = false
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SaveToHubBtn })
SaveToHubBtn.MouseButton1Click:Connect(function()
	local code = tabEditor:GetActiveCode()
	if code == "" or code:gsub("%s", "") == "" then
		hub:Toast("Code empty!", EtherExecutor)
		return
	end
	local title = tabEditor:GetActiveTitle()
	createRenamePopup(title, function(newName)
		local ok, path = hub:SaveAsFile({ title = newName, scriptCode = code, source = "Code Tab" }, "lua")
		if ok then
			hub:Toast("Saved to Hub: " .. newName .. ".lua", EtherExecutor)
			local aid = tabEditor:GetActiveId()
			if aid then tabEditor:RenameTab(aid, newName) end
			if _G.refreshSavedFn then _G.refreshSavedFn() end
		else
			hub:Toast("Failed save", EtherExecutor)
		end
	end)
end)

-- ►►► LANJUT KE PART 3 ◄◄◄

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  PART 3/3 : Feature Tabs + Init                              ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ============================================================
-- SEARCH TAB
-- ============================================================
local SearchContent = Create("Frame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Parent = exeTabs.ScriptSearchTab.containerInstance
})

local SearchTop = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 35),
	BackgroundTransparency = 1,
	Parent = SearchContent
})

local SearchBox = Create("TextBox", {
	Size = UDim2.new(0, 200, 0, 30),
	BackgroundColor3 = Color3.fromRGB(35, 35, 42),
	PlaceholderText = "Search rscripts.net...",
	PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
	Text = "",
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Parent = SearchTop
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SearchBox })

local EngineBtn = Create("TextButton", {
	Size = UDim2.new(0, 120, 0, 30),
	Position = UDim2.new(0, 210, 0, 0),
	BackgroundColor3 = Color3.fromRGB(45, 49, 58),
	Text = "Engine: RScripts",
	TextSize = 11,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamSemibold,
	AutoButtonColor = false,
	Parent = SearchTop
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = EngineBtn })

local GoBtn = Create("TextButton", {
	Size = UDim2.new(0, 60, 0, 30),
	Position = UDim2.new(0, 335, 0, 0),
	BackgroundColor3 = Color3.fromRGB(0, 168, 255),
	Text = "Go",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	AutoButtonColor = false,
	Parent = SearchTop
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = GoBtn })

local FilterBtn = Create("TextButton", {
	Size = UDim2.new(0, 110, 0, 30),
	Position = UDim2.new(0, 400, 0, 0),
	BackgroundColor3 = Color3.fromRGB(35, 35, 42),
	Text = "Filter: Default",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 11,
	Font = Enum.Font.GothamSemibold,
	AutoButtonColor = false,
	Parent = SearchTop
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = FilterBtn })

local PaginationBar = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 30),
	Position = UDim2.new(0, 0, 1, -30),
	BackgroundTransparency = 1,
	Parent = SearchContent
})

local function makePagBtn(text, xPos)
	local b = Create("TextButton", { Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(0, xPos, 0, 0), BackgroundColor3 = Color3.fromRGB(35, 35, 42), Text = text, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11, Font = Enum.Font.GothamSemibold, AutoButtonColor = false, Parent = PaginationBar })
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = b })
	return b
end

local FirstBtn = makePagBtn("First", 0)
local PrevBtn = makePagBtn("Prev", 55)
local PageLbl = Create("TextLabel", { Size = UDim2.new(0, 80, 1, 0), Position = UDim2.new(0, 110, 0, 0), BackgroundTransparency = 1, Text = "1 / 1", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11, Font = Enum.Font.GothamSemibold, Parent = PaginationBar })
local NextBtn = makePagBtn("Next", 195)
local LastBtn = makePagBtn("Last", 250)

local ResultHolder = Create("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, -70),
	Position = UDim2.new(0, 0, 0, 35),
	BackgroundTransparency = 1,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 2,
	Parent = SearchContent
})
Create("UIGridLayout", {
	CellSize = UDim2.new(0, 170, 0, 160),
	CellPadding = UDim2.new(0, 8,0,8),
	Parent = ResultHolder
})

local function setNavEnabled()
	local has = hub.pagination.hasResults
	FirstBtn.Visible = has
	NextBtn.Visible = has
	PrevBtn.Visible = has
	LastBtn.Visible = has
	PageLbl.Visible = has
	PageLbl.Text = hub.pagination.current .. " / " .. hub.pagination.total
end

-- ============================================================
-- SAVED TAB (search + refresh + exec + edit + del)
-- ============================================================
local SavedTopBar = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 35),
	BackgroundTransparency = 1,
	Parent = exeTabs.SavedTab.containerInstance
})

local SavedSearchBox = Create("TextBox", {
	Size = UDim2.new(1, -70, 1, 0),
	BackgroundColor3 = Color3.fromRGB(35, 35, 42),
	PlaceholderText = "Search saved scripts...",
	PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
	Text = "",
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Parent = SavedTopBar
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SavedSearchBox })

local SavedRefreshBtn = Create("TextButton", {
	Size = UDim2.new(0, 60, 1, 0),
	Position = UDim2.new(1, -60, 0, 0),
	BackgroundColor3 = Color3.fromRGB(50, 50, 60),
	Text = "Refresh",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 11,
	Font = Enum.Font.GothamSemibold,
	AutoButtonColor = false,
	Parent = SavedTopBar
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SavedRefreshBtn })

local SavedList = Create("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, -35),
	Position = UDim2.new(0, 0, 0, 35),
	BackgroundTransparency = 1,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 2,
	Parent = exeTabs.SavedTab.containerInstance
})
Create("UIListLayout", { Padding = UDim.new(0, 4), Parent = SavedList })

local savedFilterQuery = ""

local function refreshSavedList()
	for _, c in ipairs(SavedList:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	local scripts = hub:LoadSavedScripts()
	local filtered = {}
	local q = savedFilterQuery:lower():gsub("%s", "")
	if q == "" then
		filtered = scripts
	else
		for _, s in ipairs(scripts) do
			if (s.title or ""):lower():find(q, 1, true) or (s.fileName or ""):lower():find(q, 1, true) then
				table.insert(filtered, s)
			end
		end
	end

	-- Header info
	local header = Create("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Parent = SavedList })
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = header })
	Create("TextLabel", {
		Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 8, 0, 2),
		BackgroundTransparency = 1,
		Text = "Folder: " .. EtherLibrary.MainFolder .. "/" .. EtherLibrary.SavedScriptHubFolder .. " (" .. #filtered .. "/" .. #scripts .. ")",
		TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 8, Font = Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = header
	})
	Create("TextLabel", {
		Size = UDim2.new(1, -10, 0, 15), Position = UDim2.new(0, 8, 0, 22),
		BackgroundTransparency = 1,
		Text = "Format: .lua default (any text format supported) | Direct Exec available",
		TextColor3 = Color3.fromRGB(100, 200, 100), TextSize = 9, Font = Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = header
	})

	for _, data in ipairs(filtered) do
		local row = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundColor3 = data.isOldJson and Color3.fromRGB(60, 40, 40) or Color3.fromRGB(35, 35, 42),
			Parent = SavedList
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = row })

		Create("TextLabel", {
			Size = UDim2.new(1, -210, 0, 20), Position = UDim2.new(0, 8, 0, 2),
			BackgroundTransparency = 1,
			Text = data.title or "Untitled",
			TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 11, Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row
		})
		Create("TextLabel", {
			Size = UDim2.new(1, -210, 0, 15), Position = UDim2.new(0, 8, 0, 22),
			BackgroundTransparency = 1,
			Text = (data.fileName or "?") .. (data.isOldJson and " (legacy json)" or (" (." .. (data.ext or "lua") .. ")")),
			TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 8, Font = Enum.Font.Code,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = row
		})
		Create("TextLabel", {
			Size = UDim2.new(1, -210, 0, 12), Position = UDim2.new(0, 8, 0, 37),
			BackgroundTransparency = 1,
			Text = data.filePath or "",
			TextColor3 = Color3.fromRGB(100, 100, 100), TextSize = 7, Font = Enum.Font.Code,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row
		})

		local loadBtn = Create("TextButton", { Size = UDim2.new(0, 40, 0, 30), Position = UDim2.new(1, -160, 0, 10), BackgroundColor3 = Color3.fromRGB(30, 144, 255), Text = "Load", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 10, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = row })
		local execBtn = Create("TextButton", { Size = UDim2.new(0, 40, 0, 30), Position = UDim2.new(1, -115, 0, 10), BackgroundColor3 = Color3.fromRGB(40, 180, 80), Text = "Exec", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 10, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = row })
		local editBtn = Create("TextButton", { Size = UDim2.new(0, 25, 0, 30), Position = UDim2.new(1, -70, 0, 10), BackgroundColor3 = Color3.fromRGB(80, 80, 90), Text = "Edit", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 9, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = row })
		local delBtn  = Create("TextButton", { Size = UDim2.new(0, 40, 0, 30), Position = UDim2.new(1, -45, 0, 10), BackgroundColor3 = Color3.fromRGB(200, 50, 50), Text = "Del", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 10, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = row })
		for _, b in ipairs({ loadBtn, execBtn, editBtn, delBtn }) do
			Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = b })
		end

		loadBtn.MouseButton1Click:Connect(function()
			tabEditor:AddTab(data.title, data.code)
			hub:Toast("Loaded " .. data.fileName, EtherExecutor)
		end)

		execBtn.MouseButton1Click:Connect(function()
			-- Strip header block-comment sebelum exec
			local execCode = (data.code or ""):gsub("^%-%-%[%[.-%]%]%s*", "")
			local fn, err = loadstring(execCode)
			if not fn then
				hub:Toast("Compile error: " .. tostring(err):sub(1, 40), EtherExecutor)
				return
			end
			local ok, err2 = pcall(fn)
			if ok then
				hub:Toast("Executed " .. data.title, EtherExecutor)
			else
				hub:Toast("Runtime error", EtherExecutor)
				warn(err2)
			end
		end)

		editBtn.MouseButton1Click:Connect(function()
			tabEditor:AddTab((data.title or "Script") .. " [Edit]", data.code)
			exeTabs.CodeTab:Select()
			hub:Toast("Opened for edit", EtherExecutor)
		end)

		delBtn.MouseButton1Click:Connect(function()
			if delfile then pcall(delfile, data.filePath) end
			refreshSavedList()
			hub:Toast("Deleted " .. data.fileName, EtherExecutor)
		end)
	end

	if #filtered == 0 then
		local msg = savedFilterQuery ~= "" and ("No results for '" .. savedFilterQuery .. "'") or "No saved scripts yet. Save from Search popup or Code tab!"
		Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1,
			Text = msg, TextColor3 = Color3.fromRGB(150, 150, 150),
			TextSize = 12, Font = Enum.Font.Gotham, Parent = SavedList
		})
	end
end

SavedSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	savedFilterQuery = SavedSearchBox.Text
	refreshSavedList()
end)
SavedRefreshBtn.MouseButton1Click:Connect(refreshSavedList)
_G.refreshSavedFn = refreshSavedList

-- ============================================================
-- POPUP VIEW/EXECUTE
-- ============================================================
local function createReadOnlyPopup(data)
	local overlay = Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.4,
		ZIndex = 100,
		Parent = EtherExecutor
	})
	local popup = Create("Frame", {
		Size = UDim2.new(0, 600, 0, 400),
		Position = UDim2.new(0.5, -300, 0.5, -200),
		BackgroundColor3 = Color3.fromRGB(20, 20, 25),
		ZIndex = 101,
		Parent = overlay
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = popup })
	Create("TextLabel", {
		Size = UDim2.new(1, -40, 0, 30),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Text = data.title or "Script",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 102,
		Parent = popup
	})
	local scroll = Create("ScrollingFrame", {
		Size = UDim2.new(1, -20, 1, -80),
		Position = UDim2.new(0, 10, 0, 40),
		BackgroundColor3 = Color3.fromRGB(10, 10, 12),
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		ScrollBarThickness = 2,
		ZIndex = 102,
		Parent = popup
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = scroll })
	
	local cont = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = scroll })
	
	local function renderCode(codeStr)
		codeStr=codeStr or "-- Failed to fetch"
		local layers=highlighter.buildLayers(codeStr)
		for _,c in ipairs(cont:GetChildren())do if c:IsA("TextLabel")then c:Destroy() end end
		for _, name in ipairs({"Numbers","Operators","Keywords","Globals","Executor","Types","Strings","Comments","Properties","Methods"}) do
			Create("TextLabel",{Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, Font=Enum.Font.Code, TextSize=12, TextColor3=COLORS[name], Text=layers[name] or "", ZIndex=103, Parent=cont}) 
		end
		task.spawn(function() 
			local b=game:GetService("TextService"):GetTextSize(codeStr,12,Enum.Font.Code,Vector2.new(10000,10000)) 
			scroll.CanvasSize=UDim2.new(0,b.X,0,b.Y) 
			cont.Size=UDim2.new(0,b.X,0,b.Y) 
		end)
		data.fetchedCode=codeStr
		local status=popup:FindFirstChild("StatusLbl", true) or overlay:FindFirstChild("StatusLbl", true)
		if status then status.Text="Loaded "..#codeStr.." chars" end
	end

	if data.isUrl and data.rawUrl~="" then
		renderCode("-- Loading from RScripts...\n-- URL: "..data.rawUrl)
		task.spawn(function()
			local ok,body=universalHttpGet(data.rawUrl)
			if ok and body~="" then
				renderCode(body)
			else
				renderCode("-- Failed to fetch from RScripts\n-- URL: "..data.rawUrl.."\n-- Try game:HttpGet manually:\n-- game:HttpGet('"..data.rawUrl.."')")
			end
		end)
	else
		renderCode(data.scriptCode)
	end

	local execBtn = Create("TextButton", { Size = UDim2.new(0, 90, 0, 30), Position = UDim2.new(1, -280, 1, -35), BackgroundColor3 = Color3.fromRGB(40, 180, 80), Text = "Execute", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, ZIndex = 105, Parent = popup })
	local saveBtn = Create("TextButton", { Size = UDim2.new(0, 80, 0, 30), Position = UDim2.new(1, -180, 1, -35), BackgroundColor3 = Color3.fromRGB(255, 165, 0), Text = "Save", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, ZIndex = 105, Parent = popup })
	local loadBtn = Create("TextButton", { Size = UDim2.new(0, 80, 0, 30), Position = UDim2.new(1, -90, 1, -35), BackgroundColor3 = Color3.fromRGB(30, 144, 255), Text = "To Editor", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, ZIndex = 105, Parent = popup })
	for _, b in ipairs({ execBtn, saveBtn, loadBtn }) do
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = b })
	end
	local closeBtn = Create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 5), BackgroundTransparency = 1, Text = "×", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 18, ZIndex = 106, Parent = popup })

	closeBtn.MouseButton1Click:Connect(function() overlay:Destroy() end)
	execBtn.MouseButton1Click:Connect(function()
		local codeToRun=data.fetchedCode or data.scriptCode
		if data.isUrl and (not codeToRun or codeToRun:sub(1,2)=="--") then
			-- kalau belum ke-fetch, fetch dulu baru run
			local ok,body=universalHttpGet(data.rawUrl)
			if ok then codeToRun=body end
		end
		executeSource(codeToRun, "=HubScript")
		overlay:Destroy()
	end)
	saveBtn.MouseButton1Click:Connect(function()
		local codeToSave = data.fetchedCode or data.scriptCode
		if data.isUrl and (not codeToSave or codeToSave:sub(1, 2) == "--") then
			local ok, body = universalHttpGet(data.rawUrl)
			if ok then codeToSave = body end
		end
		local ok, path = hub:SaveAsFile({ title = data.title, scriptCode = codeToSave, source = data.source }, "lua")
		if ok then
			hub:Toast("Saved: " .. (path:match("([^/\\]+)$") or "?"), EtherExecutor)
			refreshSavedList()
		else
			hub:Toast("Failed save", EtherExecutor)
		end
		overlay:Destroy()
	end)
	loadBtn.MouseButton1Click:Connect(function()
		local codeToAdd=data.fetchedCode or data.scriptCode
		if data.isUrl and (not codeToAdd or codeToAdd:sub(1,2)=="--") then
			local ok,body=universalHttpGet(data.rawUrl)
			if ok then codeToAdd=body end
		end
		tabEditor:AddTab(data.title, codeToAdd)
		--tabEditor:SaveCurrent()
		--tabEditor.hl.refresh()
		autoSizeEditor(TextBox1, lineText, EditorHolder)
		exeTabs.CodeTab:Select()
		overlay:Destroy()
	end)
end

-- ============================================================
-- RENDER + SEARCH
-- ============================================================
local function renderCurrentPage()
	local list = hub.currentPageScripts
	if hub.filterMode == "Views" then
		table.sort(list, function(a, b) return (a.views or 0) > (b.views or 0) end)
	elseif hub.filterMode == "Likes" then
		table.sort(list, function(a, b) return (a.likes or 0) > (b.likes or 0) end)
	elseif hub.filterMode == "A-Z" then
		table.sort(list, function(a, b) return (a.title or ""):lower() < (b.title or ""):lower() end)
	end

	for _, c in ipairs(ResultHolder:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	for _, data in ipairs(list) do
		local card = Create("Frame", { Size = UDim2.new(0, 170, 0, 160), BackgroundColor3 = Color3.fromRGB(35, 35, 42), Parent = ResultHolder })
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = card })

		local thumb = Create("ImageLabel", {
			Size = UDim2.new(1, 0, 0, 70),
			BackgroundColor3 = Color3.fromRGB(25, 25, 25),
			Image = "",
			ImageTransparency = 1,
			Parent = card
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = thumb })

		local raw = data._raw or {}
		local remoteImageUrl
		if data.source == "ScriptBlox" then
			remoteImageUrl = resolveScriptBloxImage(raw)
		elseif data.source == "RScripts" then
			remoteImageUrl = resolveRScriptsImage(raw)
		else
			remoteImageUrl = resolveRobloxScriptsImage(raw)
		end
		local sourceUrl = remoteImageUrl
		if not sourceUrl and data.gameId then sourceUrl = buildRobloxThumbnail(data.gameId) end

		if sourceUrl then
			task.spawn(function()
				local custom = downloadImageAsset(sourceUrl)
				if custom then
					thumb.Image = custom
					thumb.ImageTransparency = 0
				elseif data.gameId then
					tryFetchPlaceIcon(data.gameId, thumb)
				end
			end)
		elseif data.gameId then
			tryFetchPlaceIcon(data.gameId, thumb)
		end

		Create("TextLabel", { Size = UDim2.new(1, -10, 0, 25), Position = UDim2.new(0, 5, 0, 75), BackgroundTransparency = 1, Text = (data.title or ""):sub(1, 30), TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 10, Font = Enum.Font.GothamBold, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
		Create("TextLabel", { Size = UDim2.new(1, -10, 0, 15), Position = UDim2.new(0, 5, 0, 100), BackgroundTransparency = 1, Text = (data.source or "") .. " | " .. tostring(data.views or 0), TextColor3 = Color3.fromRGB(150, 200, 255), TextSize = 8, Parent = card })
		Create("TextLabel", { Size = UDim2.new(1, -10, 0, 40), Position = UDim2.new(0, 5, 0, 115), BackgroundTransparency = 1, Text = (data.description or ""):sub(1, 60), TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 8, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = card })

		local btn = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = card })
		btn.MouseButton1Click:Connect(function() createReadOnlyPopup(data) end)
	end
	setNavEnabled()
end

local function runSearch(query, page)
	if hub.searching then return end
	hub.searching = true
	GoBtn.Text = "..."
	GoBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	task.spawn(function()
		local data, total = hub:Fetch(hub.currentEngine, query, page or 1)
		hub.currentPageScripts = data or {}
		hub.pagination.current = page or 1
		hub.pagination.total = total or 1
		hub.pagination.query = query or ""
		hub.pagination.hasResults = #hub.currentPageScripts > 0
		renderCurrentPage()
		hub.searching = false
		GoBtn.Text = "Go"
		GoBtn.BackgroundColor3 = Color3.fromRGB(0, 168, 255)
		if #hub.currentPageScripts == 0 then hub:Toast("No scripts found", EtherExecutor) end
	end)
end

EngineBtn.MouseButton1Click:Connect(function()
	local idx = table_find(hub.engines, hub.currentEngine) or 1
	hub.currentEngine = hub.engines[idx % #hub.engines + 1]
	EngineBtn.Text = "Engine: " .. hub.currentEngine
	if hub.currentEngine == "RScripts" then
		SearchBox.PlaceholderText = "Search rscripts.net..."
		EngineBtn.BackgroundColor3 = Color3.fromRGB(45, 49, 58)
	elseif hub.currentEngine == "RobloxScripts" then
		SearchBox.PlaceholderText = "Search robloxscripts.com..."
		EngineBtn.BackgroundColor3 = Color3.fromRGB(38, 52, 68)
	else
		SearchBox.PlaceholderText = "Search scriptblox.com..."
		EngineBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
	end
end)

FilterBtn.MouseButton1Click:Connect(function()
	local idx = table_find(hub.filterModes, hub.filterMode) or 1
	hub.filterMode = hub.filterModes[idx % #hub.filterModes + 1]
	FilterBtn.Text = "Filter: " .. hub.filterMode
	renderCurrentPage()
end)

GoBtn.MouseButton1Click:Connect(function() runSearch(SearchBox.Text, 1) end)
SearchBox.FocusLost:Connect(function(enter) if enter then runSearch(SearchBox.Text, 1) end end)
FirstBtn.MouseButton1Click:Connect(function() runSearch(hub.pagination.query, 1) end)
PrevBtn.MouseButton1Click:Connect(function() if hub.pagination.current > 1 then runSearch(hub.pagination.query, hub.pagination.current - 1) end end)
NextBtn.MouseButton1Click:Connect(function() if hub.pagination.current < hub.pagination.total then runSearch(hub.pagination.query, hub.pagination.current + 1) end end)
LastBtn.MouseButton1Click:Connect(function() runSearch(hub.pagination.query, hub.pagination.total) end)

setNavEnabled()
refreshSavedList()
task.delay(1, function() pcall(function() runSearch("", 1) end) end)

-- ============================================================
-- INFO TAB
-- ============================================================
local ServerInfo_Holder = Create("ScrollingFrame", {
	Name = "ServerInfo_Holder",
	Parent = exeTabs.InfoTab.containerInstance,
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0.6, 0),
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 1,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	AutomaticCanvasSize = Enum.AutomaticSize.XY,
	ScrollingDirection = Enum.ScrollingDirection.XY
})
Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = ServerInfo_Holder
})

local function makeInfoLabel(name)
	local lbl = Instance.new("TextLabel")
	lbl.Name = name
	lbl.Size = UDim2.new(1, -10, 0, 20)
	lbl.BackgroundTransparency = 1
	lbl.AutomaticSize = Enum.AutomaticSize.XY
	lbl.Text = name .. ": ..."
	lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
	lbl.Font = Enum.Font.SourceSans
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = ServerInfo_Holder
	return lbl
end

local GameNameLabel = makeInfoLabel("Game")
local PlaceIdLabel = makeInfoLabel("PlaceId")
local JobIdLabel = makeInfoLabel("JobId")
local PlayerCountLbl = makeInfoLabel("Players")
local PingLabel = makeInfoLabel("Ping")
local FPSLabel = makeInfoLabel("FPS")
local PlaceVersionLbl = makeInfoLabel("PlaceVersion")
local ServerTypeLbl = makeInfoLabel("ServerType")
local LocalPlayerLbl = makeInfoLabel("LocalPlayer")
local AccountAgeLbl = makeInfoLabel("AccountAge")
local UptimeLabel = makeInfoLabel("Uptime")
local MemoryLabel = makeInfoLabel("Memory")

local currentFPS = 0
task.spawn(function()
	local placeId = game.PlaceId
	local jobId = game.JobId
	local gameName = "Unknown"
	pcall(function() gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name end)
	local placeVersion = tonumber(game.PlaceVersion) or 0

	SafeConnect(run.RenderStepped, function()
		local playersList = players:GetPlayers()
		local playerCount = #playersList
		local maxPlayers = players.MaxPlayers
		local pingStr = "N/A"
		local pingItem = Stats.Network.ServerStatsItem["Data Ping"]
		if pingItem then pingStr = pingItem:GetValueString() end
		local memoryStr = "N/A"
		pcall(function()
			local mem = Stats:GetTotalMemoryUsageMb()
			memoryStr = string.format("%.1f MB", mem)
		end)
		local serverType = "Public"
		pcall(function()
			if playerCount == 1 and maxPlayers > 1 then serverType = "Private" else serverType = "Public" end
		end)
		local accountAgeDays = player.AccountAge or 0
		local uptimeSec = os.time() - exeRunningTime
		local h = math.floor(uptimeSec / 3600)
		local m = math.floor((uptimeSec % 3600) / 60)
		local s = uptimeSec % 60
		local uptimeStr = string.format("%02d:%02d:%02d", h, m, s)
		local names = {}
		local realTime = os.date("%d/%m/%Y %X", os.time())
		for _, plr in ipairs(playersList) do table.insert(names, plr.Name) end
		GameNameLabel.Text = "Game: " .. tostring(gameName)
		PlaceIdLabel.Text = "PlaceId: " .. tostring(placeId)
		JobIdLabel.Text = "JobId: " .. tostring(jobId)
		PlayerCountLbl.Text = "Players: " .. tostring(playerCount) .. " [" .. table.concat(names, ", ") .. "]"
		PingLabel.Text = "Ping: " .. tostring(pingStr)
		FPSLabel.Text = "FPS: " .. tostring(currentFPS)
		PlaceVersionLbl.Text = "PlaceVersion: " .. tostring(placeVersion)
		ServerTypeLbl.Text = "ServerType: " .. serverType
		LocalPlayerLbl.Text = "LocalPlayer: " .. player.Name .. " (ID: " .. tostring(player.UserId) .. ")"
		AccountAgeLbl.Text = "AccountAge: " .. tostring(accountAgeDays) .. " days"
		UptimeLabel.Text = "Uptime: " .. uptimeStr
		MemoryLabel.Text = "Memory: " .. memoryStr
	end)
end)

local Credits = Create("TextLabel", {
	Name = "Credits",
	Parent = exeTabs.InfoTab.containerInstance,
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	BackgroundTransparency = 0,
	Size = UDim2.new(0.2, 0, 0, 30),
	Font = Enum.Font.GothamBlack,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Text = "Credits:",
	TextSize = 20
})

local Credits_Text = Credits:Clone()
Credits_Text.Name = "Credits_Text"
Credits_Text.Parent = exeTabs.InfoTab.containerInstance
Credits_Text.Size = UDim2.new(1, -10, 0.3, 0)
Credits_Text.Font = Enum.Font.GothamSemibold
Credits_Text.Text = "This script was made by LucidSc1pt"
Credits_Text.TextSize = 18
Credits_Text.TextWrapped = false

local versions = {}
for version in pairs(changeList) do table.insert(versions, version) end
table.sort(versions)

local combinedText = "📜 All Versions:\n\n"
for i = #versions, 1, -1 do
	local version = versions[i]
	local logs = changeList[version]
	combinedText = combinedText .. "[" .. version .. "]\n"
	combinedText = combinedText .. table.concat(logs, "\n") .. "\n\n"
end

local Changelog = Credits:Clone()
Changelog.Name = "Changelog"
Changelog.Parent = exeTabs.InfoTab.containerInstance
Changelog.Size = UDim2.new(0.25, 0, 0, 30)
Changelog.Text = "📜 Changelog:"

local Changelog_Text_Holder = Create("ScrollingFrame", {
	Name = "Changelog_Text_Holder",
	Parent = exeTabs.InfoTab.containerInstance,
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0.6, 0),
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 1,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y
})

Create("TextLabel", {
	Name = "Changelog_Text",
	Parent = Changelog_Text_Holder,
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 0, 0, 0),
	Font = Enum.Font.GothamSemibold,
	Text = combinedText,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextSize = 18,
	AutomaticSize = Enum.AutomaticSize.Y,
	TextWrapped = false
})

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  FEATURE: Hide/Unhide UI + Settings Tab + Toggle Button       ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ─────────────── 1) Config persistence ───────────────
local TOGGLE_CONFIG_PATH = EtherLibrary.MainFolder .. "/toggle_config.txt"

local function saveToggleConfig()
	if type(writefile) ~= "function" then return end
	local cfg = EtherLibrary.ToggleButtonConfig
	local c1, c2 = cfg.StrokeColor, cfg.StrokeColor2
	local data = table.concat({
		"CustomIcon=" .. tostring(EtherLibrary.CustomIcon or "lucide:eye"),
		"StrokeColorR=" .. math.floor(c1.R * 255),
		"StrokeColorG=" .. math.floor(c1.G * 255),
		"StrokeColorB=" .. math.floor(c1.B * 255),
		"StrokeColor2R=" .. math.floor(c2.R * 255),
		"StrokeColor2G=" .. math.floor(c2.G * 255),
		"StrokeColor2B=" .. math.floor(c2.B * 255),
		"Gradient=" .. tostring(cfg.Gradient),
		"GradientRotation=" .. tostring(cfg.GradientRotation),
		"TogglePosX=" .. tostring(cfg.Position.X.Offset),
		"TogglePosY=" .. tostring(cfg.Position.Y.Offset),
		-- NEW
		"AutoRotate=" .. tostring(cfg.AutoRotate),
		"AutoRotateSpeed=" .. tostring(cfg.AutoRotateSpeed),
		"RGBMode=" .. tostring(cfg.RGBMode),
		"RGBSpeed=" .. tostring(cfg.RGBSpeed),
		"CornerRadius=" .. tostring(cfg.CornerRadius or 50),
	}, "\n")
	pcall(writefile, TOGGLE_CONFIG_PATH, data)
end

local function loadToggleConfig()
	if type(isfile) ~= "function" or type(readfile) ~= "function" then return end
	local okExist, exists = pcall(isfile, TOGGLE_CONFIG_PATH)
	if not okExist or not exists then return end
	local okRead, content = pcall(readfile, TOGGLE_CONFIG_PATH)
	if not okRead or not content then return end
	local cfg = EtherLibrary.ToggleButtonConfig
	local function num(k) return tonumber(content:match(k .. "=(%-?%d+)")) end
	local function fnum(k) return tonumber(content:match(k .. "=([%-%d%.]+)")) end
	local icon = content:match("CustomIcon=([^\n]+)")
	if icon and icon ~= "" then EtherLibrary.CustomIcon = icon end
	local r, g, b = num("StrokeColorR"), num("StrokeColorG"), num("StrokeColorB")
	if r and g and b then cfg.StrokeColor = Color3.fromRGB(r, g, b) end
	local r2, g2, b2 = num("StrokeColor2R"), num("StrokeColor2G"), num("StrokeColor2B")
	if r2 and g2 and b2 then cfg.StrokeColor2 = Color3.fromRGB(r2, g2, b2) end
	local gradStr = content:match("Gradient=([^\n]+)")
	if gradStr then cfg.Gradient = (gradStr == "true") end
	local rot = num("GradientRotation")
	if rot then cfg.GradientRotation = rot end
	local px, py = num("TogglePosX"), num("TogglePosY")
	if px and py then cfg.Position = UDim2.new(0, px, 0, py) end
	-- NEW
	local ar = content:match("AutoRotate=([^\n]+)")
	if ar then cfg.AutoRotate = (ar == "true") end
	local ars = fnum("AutoRotateSpeed")
	if ars then cfg.AutoRotateSpeed = ars end
	local rgb = content:match("RGBMode=([^\n]+)")
	if rgb then cfg.RGBMode = (rgb == "true") end
	local rgbs = fnum("RGBSpeed")
	if rgbs then cfg.RGBSpeed = rgbs end
	local cr = num("CornerRadius")
	if cr then cfg.CornerRadius = math.clamp(cr, 0, 50) end
end

loadToggleConfig()

-- ─────────────── 1.5) Header Clock (in-place, tidak floating) ───────────────
local HeaderClockFrame = Create("Frame", {
	Name = "HeaderClock",
	Parent = HeaderFrame,
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -108, 0.5, 0),
	Size = UDim2.new(0, 130, 0, 36),
	BackgroundTransparency = 1,
	ZIndex = 5,
})
Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Parent = HeaderClockFrame,
})
local HeaderClockTimeLbl = Create("TextLabel", {
	Name = "TimeLbl",
	Size = UDim2.new(1, 0, 0, 18),
	BackgroundTransparency = 1,
	Text = "00:00:00",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = Color3.fromRGB(0, 210, 255),
	TextXAlignment = Enum.TextXAlignment.Right,
	Parent = HeaderClockFrame,
})
local HeaderClockDateLbl = Create("TextLabel", {
	Name = "DateLbl",
	Size = UDim2.new(1, 0, 0, 12),
	BackgroundTransparency = 1,
	Text = "---",
	Font = Enum.Font.Gotham,
	TextSize = 9,
	TextColor3 = Color3.fromRGB(190, 200, 220),
	TextXAlignment = Enum.TextXAlignment.Right,
	Parent = HeaderClockFrame,
})

local DAY_NAMES = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"}
local MONTH_NAMES = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}

local function updateHeaderClock()
	local ok, now = pcall(os.date, "*t")
	if not ok or not now then return end
	HeaderClockTimeLbl.Text = string.format("%02d:%02d:%02d", now.hour or 0, now.min or 0, now.sec or 0)
	HeaderClockDateLbl.Text = string.format("%s, %02d %s %d",
		DAY_NAMES[now.wday] or "?",
		now.day or 0,
		MONTH_NAMES[now.month] or "?",
		now.year or 0)
end
updateHeaderClock()
task.spawn(function()
	while HeaderClockFrame and HeaderClockFrame.Parent do
		task.wait(1)
		updateHeaderClock()
	end
end)

-- ─────────────── 2) Floating toggle button ───────────────
local ToggleButton = Create("TextButton", {
	Name = "EtherToggleButton",
	Parent = EtherExecutor,
	Size = UDim2.new(0, EtherLibrary.ToggleButtonConfig.Size, 0, EtherLibrary.ToggleButtonConfig.Size),
	Position = EtherLibrary.ToggleButtonConfig.Position,
	BackgroundColor3 = Color3.fromRGB(18, 18, 24),
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false,
	ZIndex = 1001,
	Active = true,
})
local ToggleButtonCorner = Create("UICorner", {
	CornerRadius = UDim.new((EtherLibrary.ToggleButtonConfig.CornerRadius or 50) / 100, 0),
	Parent = ToggleButton,
})
local ToggleButtonStroke = Create("UIStroke", {
	Parent = ToggleButton,
	Thickness = 2,
	Color = EtherLibrary.ToggleButtonConfig.StrokeColor,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
})

local ToggleButtonGradient = Create("UIGradient", {
	Parent = ToggleButtonStroke,
	Rotation = EtherLibrary.ToggleButtonConfig.GradientRotation,
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, EtherLibrary.ToggleButtonConfig.StrokeColor),
		ColorSequenceKeypoint.new(1, EtherLibrary.ToggleButtonConfig.StrokeColor2),
	}),
	Enabled = EtherLibrary.ToggleButtonConfig.Gradient,
})

local ToggleButtonIcon = Create("ImageLabel", {
	Name = "Icon",
	Size = UDim2.new(0.55, 0, 0.55, 0),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	ImageColor3 = Color3.fromRGB(240, 240, 240),
	Image = "",
	Parent = ToggleButton,
})
applyIcon(ToggleButtonIcon, EtherLibrary.CustomIcon or "lucide:eye")

local function applyToggleVisuals()
	local cfg = EtherLibrary.ToggleButtonConfig
	-- Skip color reset kalau RGB Mode ON (animation yang handle)
	if not cfg.RGBMode then
		ToggleButtonStroke.Color = cfg.StrokeColor
		ToggleButtonGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, cfg.StrokeColor),
			ColorSequenceKeypoint.new(1, cfg.StrokeColor2),
		})
	end
	-- Skip rotation reset kalau Auto Rotate ON
	if not cfg.AutoRotate then
		ToggleButtonGradient.Rotation = cfg.GradientRotation
	end
	ToggleButtonGradient.Enabled = cfg.Gradient
	ToggleButtonCorner.CornerRadius = UDim.new((cfg.CornerRadius or 50) / 100, 0)
	applyIcon(ToggleButtonIcon, EtherLibrary.CustomIcon or "lucide:eye")
end
EtherLibrary.applyToggleVisuals = applyToggleVisuals

-- ─── Animation Loop (RGB + Auto Rotate) ───
local RunService = game:GetService("RunService")
local animStartTime = time()
SafeConnect(RunService.RenderStepped, function()
	local cfg = EtherLibrary.ToggleButtonConfig
	if not ToggleButton or not ToggleButton.Parent then return end
	if not (cfg.AutoRotate or cfg.RGBMode) then return end

	local t = time() - animStartTime

	if cfg.AutoRotate then
		ToggleButtonGradient.Rotation = (t * (cfg.AutoRotateSpeed or 45)) % 360
	end

	if cfg.RGBMode then
		local hue = (t * (cfg.RGBSpeed or 0.3)) % 1
		local c1 = Color3.fromHSV(hue, 0.85, 1)
		if cfg.Gradient then
			local c2 = Color3.fromHSV((hue + 0.5) % 1, 0.85, 1)
			ToggleButtonGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, c1),
				ColorSequenceKeypoint.new(1, c2),
			})
		else
			ToggleButtonStroke.Color = c1
		end
	end
end)

local function setMainUIHidden(hidden)
	EtherLibrary.MainUIHidden = hidden
	MainFrameParent.Visible = not hidden
end
EtherLibrary.setMainUIHidden = setMainUIHidden

ToggleButton.MouseButton1Click:Connect(function()
	setMainUIHidden(not EtherLibrary.MainUIHidden)
end)

-- Drag toggle button
local toggleDragging, toggleDragStart, toggleStartPos = false, nil, nil

ToggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		toggleDragging = true
		toggleDragStart = input.Position
		toggleStartPos = ToggleButton.Position
	end
end)

ToggleButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if toggleDragging then
			toggleDragging = false
			EtherLibrary.ToggleButtonConfig.Position = ToggleButton.Position
			saveToggleConfig()
		end
	end
end)

uis.InputChanged:Connect(function(input)
	if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - toggleDragStart
		local nx = toggleStartPos.X.Offset + delta.X
		local ny = toggleStartPos.Y.Offset + delta.Y
		local cam = workspace.CurrentCamera
		if cam then
			local vp = cam.ViewportSize
			nx = math.clamp(nx, 0, math.max(0, vp.X - ToggleButton.AbsoluteSize.X))
			ny = math.clamp(ny, 0, math.max(0, vp.Y - ToggleButton.AbsoluteSize.Y))
		end
		ToggleButton.Position = UDim2.new(0, nx, 0, ny)
	end
end)

-- ─────────────── 3) Settings tab content ───────────────
local SettingsContent = Create("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 2,
	Parent = exeTabs.SettingsTab.containerInstance,
})
Create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 12),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = SettingsContent,
})
Create("UIPadding", {
	PaddingTop = UDim.new(0, 8),
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8),
	Parent = SettingsContent,
})

local VisibilitySection = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 90),
	BackgroundColor3 = Color3.fromRGB(35, 35, 42),
	BorderSizePixel = 0,
	LayoutOrder = 1,
	Parent = SettingsContent,
})
Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = VisibilitySection })
Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = VisibilitySection })
Create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 20),
	BackgroundTransparency = 1,
	Text = "UI Visibility",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = Color3.fromRGB(0, 210, 255),
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = VisibilitySection,
})
local HideUIButton = Create("TextButton", {
	Size = UDim2.new(0, 140, 0, 32),
	Position = UDim2.new(0, 0, 0, 28),
	BackgroundColor3 = Color3.fromRGB(200, 60, 60),
	Text = "Hide Main UI",
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	AutoButtonColor = false,
	Parent = VisibilitySection,
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = HideUIButton })
Create("TextLabel", {
	Size = UDim2.new(1, -150, 0, 32),
	Position = UDim2.new(0, 150, 0, 28),
	BackgroundTransparency = 1,
	Text = "Klik icon floating untuk buka lagi",
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = Color3.fromRGB(160, 160, 170),
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
	Parent = VisibilitySection,
})
HideUIButton.MouseButton1Click:Connect(function()
	setMainUIHidden(true)
end)

local ToggleSection = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 260),
	BackgroundColor3 = Color3.fromRGB(35, 35, 42),
	BorderSizePixel = 0,
	LayoutOrder = 2,
	Parent = SettingsContent,
})
Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ToggleSection })
Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = ToggleSection })

Create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 20),
	BackgroundTransparency = 1,
	Text = "Toggle Button Customization",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = Color3.fromRGB(0, 210, 255),
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = ToggleSection,
})

-- Icon input
Create("TextLabel", {
	Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 0, 0, 30),
	BackgroundTransparency = 1, Text = "Icon:",
	Font = Enum.Font.GothamSemibold, TextSize = 11,
	TextColor3 = Color3.fromRGB(220, 220, 230),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleSection,
})
local IconInput = Create("TextBox", {
	Size = UDim2.new(1, -140, 0, 26),
	Position = UDim2.new(0, 60, 0, 30),
	BackgroundColor3 = Color3.fromRGB(22, 22, 28),
	Text = EtherLibrary.CustomIcon or "lucide:eye",
	PlaceholderText = "lucide:eye, solar:settings, ...",
	Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255),
	TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
	Parent = ToggleSection,
})
Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = IconInput })
Create("UIPadding", { PaddingLeft = UDim.new(0, 6), Parent = IconInput })
local IconApplyBtn = Create("TextButton", {
	Size = UDim2.new(0, 70, 0, 26), Position = UDim2.new(1, -70, 0, 30),
	BackgroundColor3 = Color3.fromRGB(40, 148, 215),
	Text = "Apply", Font = Enum.Font.GothamBold, TextSize = 11,
	TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false,
	Parent = ToggleSection,
})
Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = IconApplyBtn })
IconApplyBtn.MouseButton1Click:Connect(function()
	local val = IconInput.Text
	if val and val:gsub("%s", "") ~= "" then
		EtherLibrary.CustomIcon = val
		applyToggleVisuals()
		saveToggleConfig()
		hub:Toast("Icon updated", EtherExecutor)
	end
end)

Create("TextLabel", {
	Size = UDim2.new(0, 90, 0, 26), Position = UDim2.new(0, 0, 0, 66),
	BackgroundTransparency = 1, Text = "Stroke:",
	Font = Enum.Font.GothamSemibold, TextSize = 11,
	TextColor3 = Color3.fromRGB(220, 220, 230),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleSection,
})
local SolidBtn = Create("TextButton", {
	Size = UDim2.new(0, 70, 0, 26), Position = UDim2.new(0, 90, 0, 66),
	BackgroundColor3 = EtherLibrary.ToggleButtonConfig.Gradient and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(0, 168, 255),
	Text = "Solid", Font = Enum.Font.GothamBold, TextSize = 11,
	TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false,
	Parent = ToggleSection,
})
Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = SolidBtn })
local GradientBtn = Create("TextButton", {
	Size = UDim2.new(0, 80, 0, 26), Position = UDim2.new(0, 165, 0, 66),
	BackgroundColor3 = EtherLibrary.ToggleButtonConfig.Gradient and Color3.fromRGB(0, 168, 255) or Color3.fromRGB(50, 50, 60),
	Text = "Gradient", Font = Enum.Font.GothamBold, TextSize = 11,
	TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false,
	Parent = ToggleSection,
})
Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = GradientBtn })

local function makeColorInput(parent, label, initialColor, yPos, onApply)
	Create("TextLabel", {
		Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 0, 0, yPos),
		BackgroundTransparency = 1, Text = label,
		Font = Enum.Font.GothamSemibold, TextSize = 11,
		TextColor3 = Color3.fromRGB(220, 220, 230),
		TextXAlignment = Enum.TextXAlignment.Left, Parent = parent,
	})
	local rIn = Create("TextBox", {
		Size = UDim2.new(0, 45, 0, 26), Position = UDim2.new(0, 60, 0, yPos),
		BackgroundColor3 = Color3.fromRGB(22, 22, 28),
		Text = tostring(math.floor(initialColor.R * 255)),
		Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(255, 100, 100),
		ClearTextOnFocus = false, Parent = parent,
	})
	local gIn = Create("TextBox", {
		Size = UDim2.new(0, 45, 0, 26), Position = UDim2.new(0, 110, 0, yPos),
		BackgroundColor3 = Color3.fromRGB(22, 22, 28),
		Text = tostring(math.floor(initialColor.G * 255)),
		Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(100, 255, 100),
		ClearTextOnFocus = false, Parent = parent,
	})
	local bIn = Create("TextBox", {
		Size = UDim2.new(0, 45, 0, 26), Position = UDim2.new(0, 160, 0, yPos),
		BackgroundColor3 = Color3.fromRGB(22, 22, 28),
		Text = tostring(math.floor(initialColor.B * 255)),
		Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(100, 150, 255),
		ClearTextOnFocus = false, Parent = parent,
	})
	local applyB = Create("TextButton", {
		Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 210, 0, yPos),
		BackgroundColor3 = Color3.fromRGB(40, 148, 215),
		Text = "Apply", Font = Enum.Font.GothamBold, TextSize = 11,
		TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false,
		Parent = parent,
	})
	for _, inst in ipairs({ rIn, gIn, bIn, applyB }) do
		Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = inst })
	end
	applyB.MouseButton1Click:Connect(function()
		local r = math.clamp(tonumber(rIn.Text) or 0, 0, 255)
		local g = math.clamp(tonumber(gIn.Text) or 0, 0, 255)
		local b = math.clamp(tonumber(bIn.Text) or 0, 0, 255)
		onApply(Color3.fromRGB(r, g, b))
		saveToggleConfig()
	end)
end

makeColorInput(ToggleSection, "Color 1:", EtherLibrary.ToggleButtonConfig.StrokeColor, 100, function(c)
	EtherLibrary.ToggleButtonConfig.StrokeColor = c
	applyToggleVisuals()
end)

local Color2RowFrame = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 26),
	Position = UDim2.new(0, 0, 0, 134),
	BackgroundTransparency = 1,
	Visible = EtherLibrary.ToggleButtonConfig.Gradient,
	Parent = ToggleSection,
})
makeColorInput(Color2RowFrame, "Color 2:", EtherLibrary.ToggleButtonConfig.StrokeColor2, 0, function(c)
	EtherLibrary.ToggleButtonConfig.StrokeColor2 = c
	applyToggleVisuals()
end)

local function refreshStrokeModeButtons()
	local isGrad = EtherLibrary.ToggleButtonConfig.Gradient
	SolidBtn.BackgroundColor3 = isGrad and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(0, 168, 255)
	GradientBtn.BackgroundColor3 = isGrad and Color3.fromRGB(0, 168, 255) or Color3.fromRGB(50, 50, 60)
	Color2RowFrame.Visible = isGrad
end

SolidBtn.MouseButton1Click:Connect(function()
	EtherLibrary.ToggleButtonConfig.Gradient = false
	applyToggleVisuals()
	saveToggleConfig()
	refreshStrokeModeButtons()
end)
GradientBtn.MouseButton1Click:Connect(function()
	EtherLibrary.ToggleButtonConfig.Gradient = true
	applyToggleVisuals()
	saveToggleConfig()
	refreshStrokeModeButtons()
end)

Create("TextLabel", {
	Size = UDim2.new(0, 90, 0, 26), Position = UDim2.new(0, 0, 0, 168),
	BackgroundTransparency = 1, Text = "Rotation:",
	Font = Enum.Font.GothamSemibold, TextSize = 11,
	TextColor3 = Color3.fromRGB(220, 220, 230),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleSection,
})
local RotationInput = Create("TextBox", {
	Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 90, 0, 168),
	BackgroundColor3 = Color3.fromRGB(22, 22, 28),
	Text = tostring(EtherLibrary.ToggleButtonConfig.GradientRotation),
	Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255),
	ClearTextOnFocus = false, Parent = ToggleSection,
})
Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = RotationInput })
local RotationApply = Create("TextButton", {
	Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 155, 0, 168),
	BackgroundColor3 = Color3.fromRGB(40, 148, 215),
	Text = "Apply", Font = Enum.Font.GothamBold, TextSize = 11,
	TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false,
	Parent = ToggleSection,
})
Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = RotationApply })
RotationApply.MouseButton1Click:Connect(function()
	local v = tonumber(RotationInput.Text)
	if v then
		EtherLibrary.ToggleButtonConfig.GradientRotation = math.clamp(v, 0, 360)
		applyToggleVisuals()
		saveToggleConfig()
	end
end)

-- Corner radius slider
Create("TextLabel", {
	Size = UDim2.new(0, 90, 0, 26), Position = UDim2.new(0, 0, 0, 200),
	BackgroundTransparency = 1, Text = "Corner:",
	Font = Enum.Font.GothamSemibold, TextSize = 11,
	TextColor3 = Color3.fromRGB(220, 220, 230),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleSection,
})
local CornerSliderBG = Create("Frame", {
	Size = UDim2.new(0, 175, 0, 8), Position = UDim2.new(0, 90, 0, 209),
	BackgroundColor3 = Color3.fromRGB(22, 22, 28),
	BorderSizePixel = 0, Parent = ToggleSection,
})
Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = CornerSliderBG })
local CornerSliderFill = Create("Frame", {
	Size = UDim2.new((EtherLibrary.ToggleButtonConfig.CornerRadius or 50) / 50, 0, 1, 0),
	BackgroundColor3 = Color3.fromRGB(0, 168, 255),
	BorderSizePixel = 0, Parent = CornerSliderBG,
})
Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = CornerSliderFill })
local CornerSliderKnob = Create("Frame", {
	Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new((EtherLibrary.ToggleButtonConfig.CornerRadius or 50) / 50, -7, 0.5, -7),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BorderSizePixel = 0, Parent = CornerSliderBG,
})
Create("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = CornerSliderKnob })
local CornerSliderInput = Create("TextButton", {
	Size = UDim2.new(0, 175, 0, 20), Position = UDim2.new(0, 90, 0, 203),
	BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
	Parent = ToggleSection,
})
local CornerValueLbl = Create("TextLabel", {
	Size = UDim2.new(0, 50, 0, 26), Position = UDim2.new(0, 270, 0, 200),
	BackgroundTransparency = 1,
	Text = tostring(EtherLibrary.ToggleButtonConfig.CornerRadius or 50),
	Font = Enum.Font.Code, TextSize = 11,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = ToggleSection,
})

local cornerDragging = false
local function setCornerFromX(mouseX)
	local absPos = CornerSliderBG.AbsolutePosition
	local absSize = CornerSliderBG.AbsoluteSize
	local rel = math.clamp((mouseX - absPos.X) / absSize.X, 0, 1)
	local val = math.floor(rel * 50 + 0.5)
	EtherLibrary.ToggleButtonConfig.CornerRadius = val
	CornerSliderFill.Size = UDim2.new(val / 50, 0, 1, 0)
	CornerSliderKnob.Position = UDim2.new(val / 50, -7, 0.5, -7)
	CornerValueLbl.Text = tostring(val)
	ToggleButtonCorner.CornerRadius = UDim.new(val / 100, 0)
end
CornerSliderInput.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		cornerDragging = true
		setCornerFromX(input.Position.X)
	end
end)
CornerSliderInput.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		cornerDragging = false
		saveToggleConfig()
	end
end)
uis.InputChanged:Connect(function(input)
	if cornerDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		setCornerFromX(input.Position.X)
	end
end)

-- Reset
local ResetBtn = Create("TextButton", {
	Size = UDim2.new(1, 0, 0, 32), Position = UDim2.new(0, 0, 0, 240),
	BackgroundColor3 = Color3.fromRGB(80, 80, 90),
	Text = "Reset to Defaults",
	Font = Enum.Font.GothamBold, TextSize = 12,
	TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false,
	Parent = ToggleSection,
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ResetBtn })

-- === Presets Section ===
local PresetsSection = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 130),
	BackgroundColor3 = Color3.fromRGB(35, 35, 42),
	BorderSizePixel = 0,
	LayoutOrder = 3,
	Parent = SettingsContent,
})
Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = PresetsSection })
Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = PresetsSection })
Create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 20),
	BackgroundTransparency = 1, Text = "Presets",
	Font = Enum.Font.GothamBold, TextSize = 13,
	TextColor3 = Color3.fromRGB(0, 210, 255),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = PresetsSection,
})

local PRESETS = {
	{ name = "Ocean",   c1 = Color3.fromRGB(0, 168, 255),   c2 = Color3.fromRGB(0, 255, 200),   gradient = true,  rgb = false, rot = 45 },
	{ name = "Sunset",  c1 = Color3.fromRGB(255, 100, 50),  c2 = Color3.fromRGB(255, 100, 180), gradient = true,  rgb = false, rot = 45 },
	{ name = "Neon",    c1 = Color3.fromRGB(0, 255, 100),   c2 = Color3.fromRGB(0, 255, 100),   gradient = false, rgb = false, rot = 0 },
	{ name = "Fire",    c1 = Color3.fromRGB(255, 50, 0),    c2 = Color3.fromRGB(255, 200, 0),   gradient = true,  rgb = false, rot = 90 },
	{ name = "Magic",   c1 = Color3.fromRGB(160, 50, 255),  c2 = Color3.fromRGB(255, 100, 200), gradient = true,  rgb = false, rot = 45 },
	{ name = "Midnight",c1 = Color3.fromRGB(30, 50, 120),   c2 = Color3.fromRGB(30, 50, 120),   gradient = false, rgb = false, rot = 0 },
	{ name = "Cyber",   c1 = Color3.fromRGB(255, 0, 200),   c2 = Color3.fromRGB(0, 255, 200),   gradient = true,  rgb = false, rot = 135 },
	{ name = "Rainbow", c1 = Color3.fromRGB(255, 0, 0),     c2 = Color3.fromRGB(0, 0, 255),     gradient = true,  rgb = true,  rot = 0 },
}

local PresetGrid = Create("Frame", {
	Size = UDim2.new(1, 0, 1, -30), Position = UDim2.new(0, 0, 0, 28),
	BackgroundTransparency = 1, Parent = PresetsSection,
})
Create("UIGridLayout", {
	CellSize = UDim2.new(0, 95, 0, 32),
	CellPadding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = PresetGrid,
})

local function buildPresetButtons()
	for _, preset in ipairs(PRESETS) do
		local pBtn = Create("TextButton", {
			BackgroundColor3 = Color3.fromRGB(22, 22, 28),
			Text = preset.name, Font = Enum.Font.GothamBold, TextSize = 10,
			TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false,
			Parent = PresetGrid,
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = pBtn })
		local pStroke = Create("UIStroke", {
			Parent = pBtn, Thickness = 2, Color = preset.c1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		})
		if preset.gradient then
			Create("UIGradient", {
				Parent = pStroke, Rotation = preset.rot,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, preset.c1),
					ColorSequenceKeypoint.new(1, preset.c2),
				}),
			})
		end
		pBtn.MouseButton1Click:Connect(function()
			local cfg = EtherLibrary.ToggleButtonConfig
			cfg.StrokeColor = preset.c1
			cfg.StrokeColor2 = preset.c2
			cfg.Gradient = preset.gradient
			cfg.GradientRotation = preset.rot
			cfg.RGBMode = preset.rgb
			cfg.AutoRotate = false
			RGBModeBtn.Text = preset.rgb and "ON" or "OFF"
			RGBModeBtn.BackgroundColor3 = preset.rgb and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(50, 50, 60)
			AutoRotateBtn.Text = "OFF"
			AutoRotateBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
			RotationInput.Text = tostring(preset.rot)
			applyToggleVisuals()
			refreshStrokeModeButtons()
			saveToggleConfig()
			hub:Toast("Preset: " .. preset.name, EtherExecutor)
		end)
	end
end
buildPresetButtons()

-- === Animation Section ===
local AnimationSection = Create("Frame", {
	Size = UDim2.new(1, 0, 0, 130),
	BackgroundColor3 = Color3.fromRGB(35, 35, 42),
	BorderSizePixel = 0,
	LayoutOrder = 4,
	Parent = SettingsContent,
})
Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = AnimationSection })
Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = AnimationSection })
Create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 20),
	BackgroundTransparency = 1, Text = "Animation",
	Font = Enum.Font.GothamBold, TextSize = 13,
	TextColor3 = Color3.fromRGB(0, 210, 255),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = AnimationSection,
})

-- Auto Rotate
Create("TextLabel", {
	Size = UDim2.new(0, 100, 0, 26), Position = UDim2.new(0, 0, 0, 30),
	BackgroundTransparency = 1, Text = "Auto Rotate:",
	Font = Enum.Font.GothamSemibold, TextSize = 11,
	TextColor3 = Color3.fromRGB(220, 220, 230),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = AnimationSection,
})
local AutoRotateBtn = Create("TextButton", {
	Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 100, 0, 30),
	BackgroundColor3 = EtherLibrary.ToggleButtonConfig.AutoRotate and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(50, 50, 60),
	Text = EtherLibrary.ToggleButtonConfig.AutoRotate and "ON" or "OFF",
	Font = Enum.Font.GothamBold, TextSize = 11,
	TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false,
	Parent = AnimationSection,
})
Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = AutoRotateBtn })
Create("TextLabel", {
	Size = UDim2.new(0, 70, 0, 26), Position = UDim2.new(0, 168, 0, 30),
	BackgroundTransparency = 1, Text = "Speed °/s:",
	Font = Enum.Font.GothamSemibold, TextSize = 10,
	TextColor3 = Color3.fromRGB(220, 220, 230),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = AnimationSection,
})
local AutoRotSpeedInput = Create("TextBox", {
	Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 238, 0, 30),
	BackgroundColor3 = Color3.fromRGB(22, 22, 28),
	Text = tostring(EtherLibrary.ToggleButtonConfig.AutoRotateSpeed or 45),
	Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255),
	ClearTextOnFocus = false, Parent = AnimationSection,
})
Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = AutoRotSpeedInput })
AutoRotSpeedInput.FocusLost:Connect(function()
	local v = tonumber(AutoRotSpeedInput.Text)
	if v then
		EtherLibrary.ToggleButtonConfig.AutoRotateSpeed = math.clamp(v, 5, 360)
		AutoRotSpeedInput.Text = tostring(EtherLibrary.ToggleButtonConfig.AutoRotateSpeed)
		saveToggleConfig()
	end
end)
AutoRotateBtn.MouseButton1Click:Connect(function()
	local cfg = EtherLibrary.ToggleButtonConfig
	cfg.AutoRotate = not cfg.AutoRotate
	AutoRotateBtn.Text = cfg.AutoRotate and "ON" or "OFF"
	AutoRotateBtn.BackgroundColor3 = cfg.AutoRotate and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(50, 50, 60)
	if not cfg.AutoRotate then ToggleButtonGradient.Rotation = cfg.GradientRotation end
	saveToggleConfig()
end)

-- RGB Mode
Create("TextLabel", {
	Size = UDim2.new(0, 100, 0, 26), Position = UDim2.new(0, 0, 0, 66),
	BackgroundTransparency = 1, Text = "RGB Mode:",
	Font = Enum.Font.GothamSemibold, TextSize = 11,
	TextColor3 = Color3.fromRGB(220, 220, 230),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = AnimationSection,
})
local RGBModeBtn = Create("TextButton", {
	Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 100, 0, 66),
	BackgroundColor3 = EtherLibrary.ToggleButtonConfig.RGBMode and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(50, 50, 60),
	Text = EtherLibrary.ToggleButtonConfig.RGBMode and "ON" or "OFF",
	Font = Enum.Font.GothamBold, TextSize = 11,
	TextColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false,
	Parent = AnimationSection,
})
Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = RGBModeBtn })
Create("TextLabel", {
	Size = UDim2.new(0, 70, 0, 26), Position = UDim2.new(0, 168, 0, 66),
	BackgroundTransparency = 1, Text = "Speed Hz:",
	Font = Enum.Font.GothamSemibold, TextSize = 10,
	TextColor3 = Color3.fromRGB(220, 220, 230),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = AnimationSection,
})
local RGBSpeedInput = Create("TextBox", {
	Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(0, 238, 0, 66),
	BackgroundColor3 = Color3.fromRGB(22, 22, 28),
	Text = tostring(EtherLibrary.ToggleButtonConfig.RGBSpeed or 0.3),
	Font = Enum.Font.Code, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255),
	ClearTextOnFocus = false, Parent = AnimationSection,
})
Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = RGBSpeedInput })
RGBSpeedInput.FocusLost:Connect(function()
	local v = tonumber(RGBSpeedInput.Text)
	if v then
		EtherLibrary.ToggleButtonConfig.RGBSpeed = math.clamp(v, 0.05, 3)
		RGBSpeedInput.Text = tostring(EtherLibrary.ToggleButtonConfig.RGBSpeed)
		saveToggleConfig()
	end
end)
RGBModeBtn.MouseButton1Click:Connect(function()
	local cfg = EtherLibrary.ToggleButtonConfig
	cfg.RGBMode = not cfg.RGBMode
	RGBModeBtn.Text = cfg.RGBMode and "ON" or "OFF"
	RGBModeBtn.BackgroundColor3 = cfg.RGBMode and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(50, 50, 60)
	if not cfg.RGBMode then applyToggleVisuals() end
	saveToggleConfig()
end)

ResetBtn.MouseButton1Click:Connect(function()
	EtherLibrary.CustomIcon = "lucide:eye"
	EtherLibrary.ToggleButtonConfig = {
		StrokeColor = Color3.fromRGB(0, 168, 255),
		StrokeColor2 = Color3.fromRGB(255, 105, 180),
		Gradient = false,
		GradientRotation = 45,
		Position = UDim2.new(0, 20, 0, 90),
		Size = 44,
		Visible = true,
		AutoRotate = false,
		AutoRotateSpeed = 45,
		RGBMode = false,
		RGBSpeed = 0.3,
		CornerRadius = 50,
	}
	ToggleButton.Position = EtherLibrary.ToggleButtonConfig.Position
	IconInput.Text = EtherLibrary.CustomIcon
	RotationInput.Text = "45"
	AutoRotSpeedInput.Text = "45"
	RGBSpeedInput.Text = "0.3"
	AutoRotateBtn.Text = "OFF"
	AutoRotateBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	RGBModeBtn.Text = "OFF"
	RGBModeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	CornerSliderFill.Size = UDim2.new(1, 0, 1, 0)
	CornerSliderKnob.Position = UDim2.new(1, -7, 0.5, -7)
	CornerValueLbl.Text = "50"
	ToggleButtonCorner.CornerRadius = UDim.new(0.5, 0)
	applyToggleVisuals()
	saveToggleConfig()
	refreshStrokeModeButtons()
	hub:Toast("Reset to defaults", EtherExecutor)
end)

print("[Ether] Settings tab + Toggle button loaded.")

-- ============================================================
-- INIT NOTIFICATION
-- ============================================================
Notification({
	Title = "Loaded!",
	Content = "Ether Internal Executor",
	Time = 5
})

print("[Ether] Loaded successfully (merged File1 + File57)")