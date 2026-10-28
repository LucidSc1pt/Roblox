-- core/utils.lua
local Ether = getgenv().Ether
if not Ether then return end

local HttpService = Ether.HttpService
local MarketplaceService = Ether.MarketplaceService

-- ========== FOLDERS ==========
local IMAGE_CACHE_DIR = Ether.MainFolder .. "/" .. Ether.ImageCacheFolder
Ether.ensureFolder(Ether.MainFolder)
Ether.ensureFolder(Ether.MainFolder .. "/" .. Ether.SavedScriptFolder)
Ether.ensureFolder(Ether.MainFolder .. "/" .. Ether.SavedScriptHubFolder)
Ether.ensureFolder(Ether.MainFolder .. "/" .. Ether.SavedTabEditorFolder)

-- ========== HTTP & EXEC ==========
function Ether.executeSource(source, chunkName)
	source = tostring(source or "")
	if type(loadstring) ~= "function" then return false end
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

function Ether.urlEncode(str)
	if HttpService and HttpService.UrlEncode then
		local ok, enc = pcall(HttpService.UrlEncode, HttpService, str)
		if ok then return enc end
	end
	return str:gsub("([^%w%-_%.~])", function(c) return string.format("%%%02X", string.byte(c)) end)
end

function Ether.universalHttpGet(url)
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

-- ========== IMAGE CACHE ==========
local function sanitizeFileName(str) return str:gsub("[^%w%._%-]", "_") end
local function hashString(str) local hash=0 for i=1,#str do hash=(hash*31+string.byte(str,i))%4294967296 end return string.format("%08x", hash) end
local function normalizeImageUrl(url, base) if type(url)~="string" or url=="" then return nil end local trimmed=url:match("^%s*(.-)%s*$") or "" if trimmed=="" then return nil end if trimmed:match("^rbxassetid://") or trimmed:match("^rbxthumb://") then return nil end if trimmed:match("^https?://") then return trimmed end if trimmed:sub(1,2)=="//" then return "https:"..trimmed end if trimmed:sub(1,1)=="/" then if base then return base..trimmed end return trimmed end if base then return base.."/"..trimmed end return trimmed end
local function isMeaningfulImageUrl(url) if type(url)~="string" or url=="" then return false end local lower=url:lower() if lower:find("no%-script") then return false end return true end
local function deriveImageFileName(url) local fileName=url:match("/([^/%?#]+)") or "image" fileName=fileName:match("([^?#]+)") or fileName local base=fileName:match("(.+)%.") or fileName base=sanitizeFileName(base) local ext="txt" local hashed=hashString(url) return string.format("%s_%s.%s", base~="" and base or "image", hashed, ext) end

local function ensureImageFolder() if type(isfolder)~="function" or type(makefolder)~="function" then return false end local okExists,exists=pcall(isfolder, IMAGE_CACHE_DIR) if not okExists then return false end if not exists then local okMk=pcall(makefolder, IMAGE_CACHE_DIR) if not okMk then return false end end return true end
local function robloxApiUrls(url) local subdomain,path=tostring(url):match("^https?://([%w%-]+)%.roblox%.com(/.*)$") if not subdomain then subdomain,path=tostring(url):match("^https?://([%w%-]+)%.roproxy%.com(/.*)$") end if not subdomain then subdomain,path=tostring(url):match("^https?://([%w%-]+)%.rotunnel%.com(/.*)$") end if not subdomain or not path then return {url} end return {"https://"..subdomain..".roproxy.com"..path, "https://"..subdomain..".rotunnel.com"..path, "https://"..subdomain..".roblox.com"..path} end
local function httpGetBinary(url, headers) if type(url)~="string" or url=="" then return nil end local function tryRequest(targetUrl, customHeaders) local rq=request or http_request or (syn and syn.request) if type(rq)~="function" then return nil end local hdr={} if type(customHeaders)=="table" then for k,v in pairs(customHeaders) do hdr[k]=v end end hdr["User-Agent"]=hdr["User-Agent"] or "Roblox/Http/1.1" hdr.Accept=hdr.Accept or "*/*" local okReq,res=pcall(rq, {Url=targetUrl, Method="GET", Headers=hdr}) if okReq and res then local status=res.StatusCode or res.Status or res.status_code or 0 local body=res.Body or res.body if status==0 or (status>=200 and status<300) then if type(body)=="string" and body~="" then return body end end end return nil end for _,targetUrl in ipairs(robloxApiUrls(url)) do local data=tryRequest(targetUrl, headers) if not (type(data)=="string" and data~="") then local okDirect,direct=pcall(function() return game:HttpGet(targetUrl) end) if okDirect and type(direct)=="string" and direct~="" then data=direct else data=tryRequest(targetUrl, nil) end end if type(data)=="string" and data~="" then return data end end return nil end

function Ether.clearImageCache()
	if type(isfolder)~="function" or type(listfiles)~="function" or type(isfile)~="function" or type(delfile)~="function" then return false end
	local okExists,exists=pcall(isfolder, IMAGE_CACHE_DIR) if not okExists or not exists then return false end
	local okList,files=pcall(listfiles, IMAGE_CACHE_DIR) if not okList or type(files)~="table" then return false end
	local deleted=0 for _,path in ipairs(files) do if type(path)=="string" and path~="" then local ok=pcall(delfile, path) if ok then deleted+=1 end end end
	return true, deleted
end

task.spawn(function() task.wait(1) Ether.clearImageCache() end)

function Ether.downloadImageAsset(url)
	if type(url)~="string" or url=="" then return nil end
	if type(getcustomasset)~="function" or type(writefile)~="function" or type(isfile)~="function" then return url end
	if not ensureImageFolder() then return url end
	local fileName=deriveImageFileName(url) local fullPath=IMAGE_CACHE_DIR.."/"..fileName
	local needDownload=true local okExists,exists=pcall(isfile, fullPath) if okExists and exists then needDownload=false end
	if needDownload then
		local host=url:match("^https?://([^/]+)") or "" local headers
		if host:find("scriptblox%.com") then headers=nil elseif host:find("rscripts%.net") then headers={Referer="https://rscripts.net"} elseif host:find("robloxscripts%.com") then headers={Referer="https://robloxscripts.com"} elseif host:find("rbxcdn%.com") then headers={Referer="https://www.roblox.com/"} end
		local data=httpGetBinary(url, headers) if not (type(data)=="string" and data~="") then return url end
		local okWrite=pcall(writefile, fullPath, data) if not okWrite then return url end
	end
	local okAsset,assetId=pcall(getcustomasset, fullPath) if okAsset and assetId then return assetId end return url
end

function Ether.resolveScriptBloxImage(data) if not data then return nil end local function pick(values) for _,value in ipairs(values) do local normalized=normalizeImageUrl(value, "https://scriptblox.com") if normalized and isMeaningfulImageUrl(normalized) then return normalized end end end local fromScript=pick({data.image, data.imageUrl, data.thumbnail, data.coverImage, data.icon}) if fromScript then return fromScript end local game=data.game or {} local fromGame=pick({game.imageUrl, game.thumbnail, game.image, game.coverImage, game.icon}) if fromGame then return fromGame end return nil end
function Ether.resolveRScriptsImage(data) if not data then return nil end local candidates={data.image, data.imageUrl, data.thumbnail, data.cover, data.banner, data.img} for _,value in ipairs(candidates) do local normalized=normalizeImageUrl(value, "https://rscripts.net") if normalized then return normalized end end local game=data.game if game then local gameFields={game.imgurl, game.imageUrl, game.image, game.thumbnail, game.cover, game.banner, game.gameLogo} for _,value in ipairs(gameFields) do local normalized=normalizeImageUrl(value, "https://rscripts.net") if normalized then return normalized end end end return nil end
function Ether.resolveRobloxScriptsImage(data) if not data then return nil end local candidates={data.image, data.imageUrl, data.thumbnail, data.game and data.game.iconUrl, data.game and data.game.image} for _,value in ipairs(candidates) do local normalized=normalizeImageUrl(value, "https://robloxscripts.com") if normalized and isMeaningfulImageUrl(normalized) then return normalized end end return nil end
function Ether.resolveHaxHellImage(data)
	if not data then return nil end
	local candidates = { data.media and data.media.thumbnailUrl, data.game and data.game.thumbnailUrl }
	for _, value in ipairs(candidates) do
		local normalized = normalizeImageUrl(value, "https://haxhell.com")
		if normalized and isMeaningfulImageUrl(normalized) then return normalized end
	end
	return nil
end
function Ether.buildRobloxThumbnail(placeId) local id=tostring(placeId or "") if id=="" or id=="0" then return nil end return "https://www.roblox.com/Thumbs/PlaceThumbnail.ashx?width=420&height=270&format=png&placeId="..id end
function Ether.tryFetchPlaceIcon(placeId, imageLabel) if not MarketplaceService or not placeId or not imageLabel then return end coroutine.wrap(function() local ok,info=pcall(function() return MarketplaceService:GetProductInfo(tonumber(placeId), Enum.InfoType.Asset) end) if not ok or not info then return end local iconId=info.ImageIconAssetId if iconId and iconId~=0 then imageLabel.Image="rbxassetid://"..iconId imageLabel.ImageTransparency=0 end end)() end

-- ========== ICON PACKS ==========
local IconPacks = {}
local function parseUniversalIcon(raw)
	if not raw then return nil end
	local result = { Image = "", RectSize = Vector2.zero, RectOffset = Vector2.zero }
	if type(raw) == "number" then result.Image = "rbxassetid://" .. raw return result end
	if type(raw) == "string" then if string.sub(raw, 1, 13) == "rbxassetid://" or string.find(raw, "://") then result.Image = raw return result elseif tonumber(raw) then result.Image = "rbxassetid://" .. raw return result end end
	if type(raw) == "table" then
		local img = raw.Image or raw.image or raw.id or raw.Id or raw.Asset or raw.asset or raw.url or raw[1]
		if type(img) == "number" then result.Image = "rbxassetid://" .. img elseif type(img) == "string" then result.Image = (string.sub(img, 1, 13) == "rbxassetid://" or string.find(img, "://")) and img or ("rbxassetid://" .. img) end
		local size = raw.ImageRectSize or raw.imageRectSize or raw.Size or raw.size or raw[2]
		if typeof(size) == "Vector2" then result.RectSize = size elseif type(size) == "table" then result.RectSize = Vector2.new(size[1] or size.X or size.x or 0, size[2] or size.Y or size.y or 0) end
		local offset = raw.ImageRectOffset or raw.imageRectOffset or raw.Offset or raw.offset or raw[3]
		if typeof(offset) == "Vector2" then result.RectOffset = offset elseif type(offset) == "table" then result.RectOffset = Vector2.new(offset[1] or offset.X or offset.x or 0, offset[2] or offset.Y or offset.y or 0) end
		return (result.Image ~= "") and result or nil
	end
	return nil
end

function Ether.getIconData(input)
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

function Ether.applyIcon(imageInstance, iconInput)
	local data = Ether.getIconData(iconInput)
	if not data then imageInstance.Image = "" return end
	imageInstance.Image = data.Image
	imageInstance.ImageRectSize = data.RectSize
	imageInstance.ImageRectOffset = data.RectOffset
end

local function loadIconPackWithCache(packName, url)
	local fileName = string.lower(packName) .. "_icons (DO NOT EDIT THIS FILE).lua"
	local filePath = Ether.MainFolder .. "/" .. Ether.IconCacheFolder .. "/" .. fileName
	local rawData = nil
	if writefile and readfile and isfile and isfile(filePath) then
		local success, content = pcall(readfile, filePath)
		if success and content and content ~= "" then rawData = content end
	end
	if not rawData then
		local success, response = pcall(function() return game:HttpGet(url) end)
		if success and response and response ~= "" then rawData = response
			if writefile then pcall(function() Ether.ensureFolder(Ether.MainFolder .. "/" .. Ether.IconCacheFolder) writefile(filePath, rawData) end) end
		else warn(`[EtherExecutor] Failed to download Icon Packs '{packName}'.`) return end
	end
	if rawData then
		local loadSuccess, result = pcall(loadstring(rawData))
		if loadSuccess and type(result) == "table" then IconPacks[packName] = result
		else warn(`[EtherExecutor] Failed to parse Icon Packs data '{packName}'.`) end
	end
end

task.spawn(function()
    loadIconPackWithCache("lucide", "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua")
    loadIconPackWithCache("solar", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/solar/dist/Icons.lua")
    loadIconPackWithCache("craft", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua")
    loadIconPackWithCache("geist", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua")
    loadIconPackWithCache("sfsymbols", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua")
    loadIconPackWithCache("gravity", "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/gravity/dist/Icons.lua")
end)

return Ether
