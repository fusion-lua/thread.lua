local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local textSize = 10
local keybindTextSize = 15
local padding = 5
local extraWidth = 50
local spacing = 4
local menuVisible = true
local listening = true
local keybinds = {}
local activeNotifications = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local function getTextSize(message, size)
	local temp = Instance.new("TextLabel")
	temp.Text = message
	temp.Font = Enum.Font.Code
	temp.TextSize = size or textSize
	temp.TextTransparency = 1
	temp.Size = UDim2.new(0,0,0,0)
	temp.Parent = screenGui
	local width = temp.TextBounds.X + padding*2 + extraWidth
	local height = temp.TextBounds.Y + padding*2
	temp:Destroy()
	return width, height
end

local function createLayeredFrame(w, h, startX, startY)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, w+8, 0, h+8)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Position = UDim2.new(0, startX, 0, startY)
	container.Parent = screenGui

	local blackOutline = Instance.new("Frame")
	blackOutline.Size = UDim2.new(1,0,1,0)
	blackOutline.Position = UDim2.new(0,0,0,0)
	blackOutline.BackgroundColor3 = Color3.new(0,0,0)
	blackOutline.BorderSizePixel = 0
	blackOutline.Parent = container

	local whiteOutline = Instance.new("Frame")
	whiteOutline.Size = UDim2.new(0, w+4, 0, h+4)
	whiteOutline.Position = UDim2.new(0,2,0,2)
	whiteOutline.BackgroundColor3 = Color3.new(1,1,1)
	whiteOutline.BorderSizePixel = 0
	whiteOutline.Parent = container

	local blackBox = Instance.new("Frame")
	blackBox.Size = UDim2.new(0, w, 0, h)
	blackBox.Position = UDim2.new(0,4,0,4)
	blackBox.BackgroundColor3 = Color3.new(0,0,0)
	blackBox.BorderSizePixel = 0
	blackBox.Parent = container

	return container, blackBox
end

local function createNotification(message)
	if not listening then return end
	local w,h = getTextSize(message)
	local container, inner = createLayeredFrame(w,h, -w-50, 50)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0,w,0,h)
	lbl.Position = UDim2.new(0,4,0,4)
	lbl.BackgroundTransparency = 1
	lbl.Text = message
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.Font = Enum.Font.Code
	lbl.TextSize = textSize
	lbl.Parent = inner

	table.insert(activeNotifications, {frame = container, height = h+8})

	TweenService:Create(container, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
		Position = UDim2.new(0,10,0,50)
	}):Play()

	task.delay(3, function()
		if container then
			TweenService:Create(container, TweenInfo.new(0.5), {
				Position = UDim2.new(0,10,0,-50)
			}):Play()
			task.delay(0.5, function()
				if container then container:Destroy() end
			end)
		end
	end)
end

function sendNotification(key,text)
	UserInputService.InputBegan:Connect(function(input,processed)
		if processed or not listening then return end
		if input.KeyCode == key then
			createNotification(text)
		end
	end)
end

local function refreshMenu()
	if not menuVisible or not listening then return end

	for _, c in ipairs(screenGui:GetChildren()) do
		if c.Name == "KeybindMenu" then c:Destroy() end
	end

	local texts = {"Keybinds"}
	for i,v in ipairs(keybinds) do
		table.insert(texts, v.key.." - "..v.text)
	end

	local maxWidth = 0
	local totalHeight = 0
	local itemData = {}

	for _, msg in ipairs(texts) do
		local w,h = getTextSize(msg, keybindTextSize)
		if w > maxWidth then maxWidth = w end
		totalHeight = totalHeight + h + spacing
		table.insert(itemData,{msg=msg,height=h})
	end
	totalHeight = totalHeight + 10

	local container, inner = createLayeredFrame(maxWidth, totalHeight, -maxWidth-50, 100)
	container.Name = "KeybindMenu"

	local y = 4
	for i, data in ipairs(itemData) do
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0,maxWidth,0,data.height)
		lbl.Position = UDim2.new(0,4,0,y)
		lbl.BackgroundTransparency = 1
		lbl.Text = data.msg
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.Font = Enum.Font.Code
		lbl.TextSize = keybindTextSize
		lbl.TextXAlignment = Enum.TextXAlignment.Center
		lbl.Parent = inner
		y = y + data.height + spacing

		if i == 1 then
			local line = Instance.new("Frame")
			line.Size = UDim2.new(1,-8,0,2)
			line.Position = UDim2.new(0,4,0,y-2)
			line.BackgroundColor3 = Color3.new(1,1,1)
			line.BorderSizePixel = 0
			line.Parent = inner
			y = y + spacing
		end
	end

	TweenService:Create(container,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
		Position = UDim2.new(0,10,0,100)
	}):Play()
end

function AddKeybind(key,text)
	table.insert(keybinds,{key=key,text=text})
	refreshMenu()
end

UserInputService.InputBegan:Connect(function(i,p)
	if p or not listening then return end
	if i.KeyCode == Enum.KeyCode.F10 then
		menuVisible = not menuVisible
		if menuVisible then
			refreshMenu()
		else
			for _, c in ipairs(screenGui:GetChildren()) do
				if c.Name == "KeybindMenu" then
					TweenService:Create(c,TweenInfo.new(0.4),{
						Position = UDim2.new(0,-c.Size.X.Offset-50,0,100)
					}):Play()
					task.delay(0.45, function() if c then c:Destroy() end end)
				end
			end
		end
	end
end)

UserInputService.InputBegan:Connect(function(i,p)
	if p then return end
	if i.KeyCode == Enum.KeyCode.F5 then
		listening = false
		menuVisible = false
		for _, c in ipairs(screenGui:GetChildren()) do
			local tween = TweenService:Create(c,TweenInfo.new(0.5), {
				Position = UDim2.new(0,-c.Size.X.Offset-50,0,100)
			})
			tween:Play()
			tween.Completed:Connect(function()
				if c then c:Destroy() end
			end)
		end
		activeNotifications = {}
		keybinds = {}
	end
end)

AddKeybind("F1","Aimbot FOV (Toggle)")
AddKeybind("F2","Aimbot (Toggle)")
AddKeybind("F3","ESP (Toggle)")
AddKeybind("F4","Chams style (Toggle)")
AddKeybind("F5","Unload script (Press)")
AddKeybind("F6","List boss status (Press)")
AddKeybind("F7","Inventory checker (Toggle)")
AddKeybind("F8","Viewmodel changer (Toggle)")
AddKeybind("F10","UI Menu (Toggle)")
AddKeybind("`","Zoom in (Hold)")
AddKeybind("Scroll Wheel","Aimbot lock on (Toggle)")
