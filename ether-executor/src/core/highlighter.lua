-- core/highlighter.lua
local Ether = getgenv().Ether
if not Ether then return end

local highlighter = {}
Ether.highlighter = highlighter

highlighter.COLORS = {
	Numbers = Color3.fromRGB(255, 198, 0), Operators = Color3.fromRGB(204, 204, 204),
	Keywords = Color3.fromRGB(248, 109, 124), Globals = Color3.fromRGB(132, 214, 247),
	Executor = Color3.fromRGB(255, 119, 183), Types = Color3.fromRGB(97, 161, 241),
	Strings = Color3.fromRGB(173, 241, 149), Comments = Color3.fromRGB(102, 102, 102),
	Properties = Color3.fromRGB(129, 222, 255), Methods = Color3.fromRGB(227, 201, 141),
	Default = Color3.fromRGB(235, 235, 235),
}
local COLORS = highlighter.COLORS

local LUA_KEYWORDS = {["and"]=true,["break"]=true,["do"]=true,["else"]=true,["elseif"]=true,["end"]=true,["for"]=true,["function"]=true,["if"]=true,["in"]=true,["local"]=true,["not"]=true,["or"]=true,["repeat"]=true,["return"]=true,["then"]=true,["until"]=true,["while"]=true,["continue"]=true,["export"]=true,["type"]=true,["typeof"]=true}
local SPECIAL = {["nil"]=true,["true"]=true,["false"]=true,["self"]=true}
local GLOBALS = {["game"]=true,["workspace"]=true,["script"]=true,["math"]=true,["string"]=true,["table"]=true,["task"]=true,["coroutine"]=true,["bit32"]=true,["buffer"]=true,["utf8"]=true,["print"]=true,["warn"]=true,["error"]=true,["wait"]=true,["tick"]=true,["pairs"]=true,["ipairs"]=true,["next"]=true,["select"]=true,["unpack"]=true,["require"]=true,["Instance"]=true,["Vector2"]=true,["Vector3"]=true,["CFrame"]=true,["Color3"]=true,["UDim2"]=true,["Enum"]=true,["_G"]=true,["shared"]=true}
local EXECUTOR = {["getgenv"]=true,["getrenv"]=true,["getrawmetatable"]=true,["setrawmetatable"]=true,["hookmetamethod"]=true,["hookfunction"]=true,["newcclosure"]=true,["checkcaller"]=true,["getnamecallmethod"]=true,["getgc"]=true,["getinstances"]=true,["gethui"]=true,["cloneref"]=true,["fireclickdetector"]=true,["setclipboard"]=true,["identifyexecutor"]=true,["request"]=true,["http_request"]=true,["setfpscap"]=true}
local TYPES = {["Instance"]=true,["CFrame"]=true,["Vector3"]=true,["Vector2"]=true,["Color3"]=true,["UDim"]=true,["UDim2"]=true}

local function scanStringAndCommentsSorted(text)
	local intervals = {} local i, n = 1, #text
	while i <= n do
		local two = text:sub(i, i + 1)
		if two == "--" then
			local isLong = text:sub(i + 2, i + 3) == "[["
			if isLong then local e = text:find("%]%]", i + 4, true) e = e and e + 1 or n table.insert(intervals, { i, e, "comment" }) i = e + 1
			else local e = text:find("\n", i + 2, true) e = e and e - 1 or n table.insert(intervals, { i, e, "comment" }) i = e + 1 end
		else
			local c = text:sub(i, i)
			if c == '"' or c == "'" then local e = i + 1 while e <= n do if text:sub(e, e) == c and text:sub(e - 1, e - 1) ~= "\\" then break end e += 1 end table.insert(intervals, { i, e, "string" }) i = e + 1
			elseif two == "[[" then local e = text:find("%]%]", i + 2, true) e = e and e + 1 or n table.insert(intervals, { i, e, "string" }) i = e + 1
			else i += 1 end
		end
	end
	table.sort(intervals, function(a, b) return a[1] < b[1] end)
	return intervals
end

function highlighter.buildLayers(source)
	source = source:gsub("\r", ""):gsub("\t", "    ")
	local len = #source
	local buffers = { Numbers={},Operators={},Keywords={},Globals={},Executor={},Types={},Strings={},Comments={},Properties={},Methods={} }
	for i = 1, len do local ch = source:sub(i, i) local space = ch == "\n" and "\n" or " " for _, buf in pairs(buffers) do buf[i] = space end end
	local intervals = scanStringAndCommentsSorted(source)
	for _, iv in ipairs(intervals) do local s, e, typ = iv[1], iv[2], iv[3] local target = typ == "string" and "Strings" or "Comments" for p = s, math.min(e, len) do buffers[target][p] = source:sub(p, p) end end
	local intervalIdx = 1 local activeEnd = 0 local i = 1
	while i <= len do
		while intervalIdx <= #intervals and intervals[intervalIdx][1] <= i do if i <= intervals[intervalIdx][2] then activeEnd = intervals[intervalIdx][2] break else intervalIdx += 1 end end
		if i > activeEnd then while intervalIdx <= #intervals and intervals[intervalIdx][2] < i do intervalIdx += 1 end
		else i = activeEnd + 1 continue end
		local c = source:sub(i, i) local two = source:sub(i, i + 1) local three = source:sub(i, i + 2)
		if three == "..." then buffers.Operators[i] = "." buffers.Operators[i+1] = "." buffers.Operators[i+2] = "." i += 3
		elseif two == ".." or two == "==" or two == "~=" or two == "<=" or two == ">=" or two == "::" then buffers.Operators[i] = two:sub(1, 1) buffers.Operators[i+1] = two:sub(2, 2) i += 2
		elseif c:match("%d") or (c == "." and source:sub(i + 1, i + 1):match("%d")) then local s, e = source:find("^%.?%d+%.?%d*[eE]?[+-]?%d*", i) if not s then s, e = source:find("^%d+%.?%d*", i) end e = e or i if source:sub(s, e):match("%d") then for p = s, e do buffers.Numbers[p] = source:sub(p, p) end i = e + 1 else buffers.Operators[i] = c i += 1 end
		elseif c == "." or c == ":" then local prevChar = i > 1 and source:sub(i - 1, i - 1) or "" local nextChar = source:sub(i + 1, i + 1) local isAccessor = prevChar:match("[%w_%)%]]") and nextChar:match("[%a_]") if isAccessor then buffers.Operators[i] = c local _, e, word = source:find("^([%a_][%w_]*)", i + 1) if word then local target = (c == ":" and "Methods" or "Properties") for p = i + 1, e do buffers[target][p] = source:sub(p, p) end i = e + 1 else i += 1 end else buffers.Operators[i] = c i += 1 end
		elseif c:match("[%a_]") then local _, e, word = source:find("^([%a_][%w_]*)", i) if word then local target = nil if LUA_KEYWORDS[word] or SPECIAL[word] then target = "Keywords" elseif EXECUTOR[word] then target = "Executor" elseif GLOBALS[word] then target = "Globals" elseif TYPES[word] then target = "Types" end if target then for p = i, e do buffers[target][p] = source:sub(p, p) end end i = e + 1 else i += 1 end
		elseif c:match("[%p]") and c ~= "_" then buffers.Operators[i] = c i += 1
		else i += 1 end
	end
	local result = {} for k, v in pairs(buffers) do result[k] = table.concat(v) end
	return result
end

function highlighter.attach(textBox, options)
	assert(textBox and textBox:IsA("TextBox")) options = options or {}
	local hideOnFocus = options.hideOnFocus == nil and true or options.hideOnFocus
	local updateOnFocusLostOnly = options.updateOnFocusLostOnly == nil and true or options.updateOnFocusLostOnly
	local debounceTime = options.debounce or 0.15 local useThread = options.useThread == nil and true or options.useThread
	local layers = {}
	for _, name in ipairs({ "Numbers","Operators","Keywords","Globals","Executor","Types","Strings","Comments","Properties","Methods" }) do
		local lbl = Instance.new("TextLabel")
		lbl.Name = name .. "_Layer" lbl.BackgroundTransparency = 1 lbl.BorderSizePixel = 0 lbl.TextXAlignment = textBox.TextXAlignment
		lbl.TextYAlignment = textBox.TextYAlignment lbl.Font = textBox.Font lbl.TextSize = textBox.TextSize lbl.LineHeight = textBox.LineHeight
		lbl.TextColor3 = COLORS[name] or COLORS.Default lbl.RichText = false lbl.TextWrapped = false lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.Position = UDim2.new(0, 0, 0, 0) lbl.ZIndex = textBox.ZIndex + 1 lbl.Text = "" lbl.Visible = true lbl.Parent = textBox
		layers[name] = lbl
	end
	local function setVisible(v) for _, lbl in pairs(layers) do lbl.Visible = v end textBox.TextTransparency = v and 0.4 or 0 end
	local function refreshImmediate() local src = textBox.Text or "" if src == "" then for _, l in pairs(layers) do l.Text = "" end return end local built = highlighter.buildLayers(src) for name, lbl in pairs(layers) do lbl.Text = built[name] or "" end end
	local debounceId = 0 local isRefreshing = false
	local function refreshDebounced()
		if isRefreshing then return end debounceId += 1 local myId = debounceId
		if useThread then
			task.spawn(function() isRefreshing = true task.wait(debounceTime) if myId ~= debounceId then isRefreshing = false return end local src = textBox.Text or "" if src == "" then for _, l in pairs(layers) do l.Text = "" end isRefreshing = false setVisible(true) return end local built if #src > 10000 then task.wait() built = highlighter.buildLayers(src) else built = highlighter.buildLayers(src) end if myId ~= debounceId then isRefreshing = false return end for name, lbl in pairs(layers) do lbl.Text = built[name] or "" end isRefreshing = false setVisible(true) end)
		else task.delay(debounceTime, function() if myId ~= debounceId then return end refreshImmediate() setVisible(true) end) end
	end
	refreshImmediate()
	if hideOnFocus then textBox.Focused:Connect(function() debounceId += 1 setVisible(false) end) textBox.FocusLost:Connect(function() setVisible(false) refreshDebounced() end) end
	if not updateOnFocusLostOnly then textBox:GetPropertyChangedSignal("Text"):Connect(function() if not textBox:IsFocused() then refreshDebounced() end end) end
	return { layers = layers, refresh = refreshImmediate, refreshDebounced = refreshDebounced, setVisible = setVisible,
		applyLayers = function(built) if not built then return end debounceId += 1 for name, lbl in pairs(layers) do lbl.Text = built[name] or "" end setVisible(true) end,
		setColor = function(n, c) if layers[n] then layers[n].TextColor3 = c end end, destroy = function() for _, l in pairs(layers) do l:Destroy() end end,
	}
end

return Ether
