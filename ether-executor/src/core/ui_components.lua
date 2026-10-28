-- core/ui_components.lua
local Ether = getgenv().Ether
if not Ether then return end

local TweenService = Ether.TweenService
local HttpService = Ether.HttpService

-- ========== ADVANCED HUB API ==========
local AdvancedHub = {}
AdvancedHub.__index = AdvancedHub

function AdvancedHub.new()
	return setmetatable({
		engines = { "RScripts", "RobloxScripts", "ScriptBlox", "HaxHell" },
		currentEngine = "RScripts",
		pagination = { current = 1, total = 1, query = "", hasResults = false },
		currentPageScripts = {},
		filterModes = { "Default", "Views", "Likes", "A-Z" },
		filterMode = "Default",
		searching = false,
		savedScriptsCache = {}
	}, AdvancedHub)
end

function AdvancedHub:Fetch(engine, query, page)
	page = page or 1 query = query or "" local encoded = Ether.urlEncode(query) local url = ""
	if engine == "RScripts" then
		url = string.format("https://rscripts.net/api/v2/scripts?page=%d&orderBy=date&sort=desc", page)
		if query ~= "" then url = url .. "&q=" .. encoded end
	elseif engine == "RobloxScripts" then
		url = string.format("https://robloxscripts.com/api/v1/scripts?page=%d&limit=24&sort=newest", page)
		if query ~= "" then url = url .. "&q=" .. encoded end
	elseif engine == "HaxHell" then
		if query == "" then
			url = string.format("https://haxhell.com/api/v1/scripts?page=%d&limit=20", page)
		else
			url = string.format("https://haxhell.com/api/v1/search/scripts?q=%s&page=%d&limit=20", encoded, page)
		end
	else
		if query == "" then
			url = string.format("https://scriptblox.com/api/script/fetch?page=%d", page)
		else
			url = string.format("https://scriptblox.com/api/script/search?q=%s&page=%d", encoded, page)
		end
	end
	
	local ok, body = Ether.universalHttpGet(url)
	if not ok then return {}, 1 end
	local ok2, dec = pcall(HttpService.JSONDecode, HttpService, body)
	if not ok2 or not dec then return {}, 1 end
	
	local data, totalPages = {}, 1
	if engine == "RScripts" then
		data = dec.scripts or {} totalPages = dec.info and dec.info.maxPages or dec.totalPages or 1
	elseif engine == "RobloxScripts" then
		data = dec.data or {} local pag = dec.pagination or {} totalPages = tonumber(pag.totalPages or pag.pages or pag.lastPage or 1) or 1
		if pag.total and pag.limit then totalPages = math.ceil(pag.total / math.max(pag.limit, 1)) end
		totalPages = math.min(totalPages, 200)
	elseif engine == "HaxHell" then
		data = dec.data or {} local pag = dec.pagination or {} totalPages = tonumber(pag.totalPages or 1) or 1
	else
		local result = dec.result or {} data = result.scripts or {} totalPages = result.totalPages or 1
	end
	
	local normalized = {}
	for _, item in ipairs(data) do
		if engine == "RScripts" then
			table.insert(normalized, {
				title = item.title or "No Title", author = item.creator and item.creator.username or item.owner or "Anon",
				description = item.description or "", views = item.views or 0, likes = item.likes or item.likeCount or 0,
				source = engine, scriptCode = "", rawUrl = item.rawScript or item.scriptLink or item.raw or item.rawScriptUrl or "",
				isUrl = true, _raw = item, gameId = item.gameId or (item.game and item.game.gameId) or item.placeId or (item.game and item.game.placeId)
			})
		elseif engine == "HaxHell" then
			table.insert(normalized, {
				title = item.title or "No Title", author = item.author and item.author.username or "Anon",
				description = item.description or "", views = item.stats and item.stats.views or 0, likes = item.stats and item.stats.likes or 0,
				source = engine, scriptCode = "", rawUrl = item.links and item.links.raw or "",
				isUrl = true, _raw = item, gameId = item.game and item.game.placeId
			})
		else
			local directCode = item.script or item.code or "" local rawUrl = item.rawScriptUrl or item.scriptLink or item.raw or ""
			local isUrl = rawUrl ~= "" and directCode == "" if not isUrl then rawUrl = "" end
			table.insert(normalized, {
				title = item.title or "No Title", author = item.creator and item.creator.username or item.owner or "Anon",
				description = item.description or "", views = item.views or 0, likes = item.likes or item.likeCount or 0,
				source = engine, scriptCode = directCode, rawUrl = rawUrl, isUrl = isUrl,
				_raw = item, gameId = item.gameId or (item.game and item.game.gameId) or item.placeId or (item.game and item.game.placeId)
			})
		end
	end
	return normalized, totalPages
end

function AdvancedHub:SaveAsFile(data, extension)
	extension = tostring(extension or "lua"):gsub("[^%w]", ""):lower() if extension == "" then extension = "lua" end
	local safeName = (data.title or "script"):gsub("[^%w%s%-_]", ""):gsub("%s+", "_"):sub(1, 40) if safeName == "" then safeName = "script_" .. os.time() end
	local filePath = Ether.MainFolder .. "/" .. Ether.SavedScriptHubFolder .. "/" .. safeName .. "." .. extension
	local header = string.format("--[[ Saved from Ether Executor\n   Title: %s\n   Source: %s\n   SavedAt: %s\n   Format: .%s\n]]\n\n", data.title or "Untitled", data.source or "Unknown", os.date("%Y-%m-%d %H:%M:%S"), extension)
	local fullCode = header .. (data.scriptCode or "")
	if writefile then local ok, err = pcall(writefile, filePath, fullCode) if ok then return true, filePath else warn(err) return false end end return false
end

function AdvancedHub:LoadSavedScripts()
	local folder = Ether.MainFolder .. "/" .. Ether.SavedScriptHubFolder
	if not (isfolder and isfolder(folder) and listfiles) then return {} end
	local ok, files = pcall(listfiles, folder) if not ok or type(files) ~= "table" then return {} end
	local results = {}
	for _, f in ipairs(files) do
		local lower = f:lower()
		if lower:sub(-5) == ".json" then
			local ok2, content = pcall(readfile, f) if ok2 then local ok3, data = pcall(HttpService.JSONDecode, HttpService, content) if ok3 and data then table.insert(results, { filePath = f, fileName = f:match("([^/\\]+)%.json$") or "old", title = data.title or "Old JSON", code = data.code or "", isLua = false, isOldJson = true, ext = "json" }) end end
		else
			local ok2, content = pcall(readfile, f) if ok2 and content then local fileName = f:match("([^/\\]+)%.%w+$") or (f:match("([^/\\]+)$") or "Untitled") local baseName = f:match("([^/\\]+)%.%w+$") or fileName local ext = f:match("%.(%w+)$") or "lua" local headerTitle = content:match("Title:%s*(.-)\n") local title = headerTitle or baseName:gsub("_", " ") table.insert(results, { filePath = f, fileName = fileName, title = title, code = content, isLua = (ext:lower() == "lua"), ext = ext }) end
		end
	end
	table.sort(results, function(a, b) return a.title:lower() < b.title:lower() end) self.savedScriptsCache = results
	return results
end

Ether.AdvancedHub = AdvancedHub
Ether.hub = AdvancedHub.new()
return Ether
