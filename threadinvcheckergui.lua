local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5,0,0.75,0)
frame.Size = UDim2.new(0,300,0,100)
frame.BackgroundColor3 = Color3.new(0,0,0)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Visible = false

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(40,40,40)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = frame
stroke.ZIndex = 1

local topLine = Instance.new("Frame")
topLine.BorderSizePixel = 0
topLine.BackgroundColor3 = Color3.new(1,1,1)
topLine.Size = UDim2.new(1,0,0,2)
topLine.Position = UDim2.new(0,0,0,0)
topLine.ZIndex = 2
topLine.Parent = frame

local header = Instance.new("TextLabel")
header.BackgroundTransparency = 1
header.Text = ""
header.Font = Enum.Font.Code
header.TextSize = 18
header.TextColor3 = Color3.new(1,1,1)
header.AnchorPoint = Vector2.new(0.5,0)
header.Position = UDim2.new(0.5,0,0,5)
header.ZIndex = 3
header.Parent = frame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.Position = UDim2.new(0,10,0,30)
scrollFrame.Size = UDim2.new(1,-20,1,-40)
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.ScrollBarThickness = 0
scrollFrame.Parent = frame
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local body = Instance.new("TextLabel")
body.BackgroundTransparency = 1
body.Text = ""
body.Font = Enum.Font.Code
body.TextWrapped = true
body.TextSize = 16
body.TextColor3 = Color3.new(1,1,1)
body.RichText = true
body.Size = UDim2.new(1,0,0,0)
body.Parent = scrollFrame

local function resize()
	header.Size = UDim2.new(1,-20,0,header.TextSize + 6)
	body.Size = UDim2.new(1,0,0,body.TextBounds.Y + 10)
	scrollFrame.CanvasSize = UDim2.new(0,0,0,body.TextBounds.Y + 10)
	local maxChars = 0
	for line in body.Text:gmatch("[^\n]+") do
		line = line:gsub("<[^>]->","")
		maxChars = math.max(maxChars,#line)
	end
	local charWidth = 8
	local widest = math.max(header.TextBounds.X + 40, maxChars*charWidth + 40, 300)
	if widest > workspace.CurrentCamera.ViewportSize.X - 50 then
		widest = workspace.CurrentCamera.ViewportSize.X - 50
	end
	local totalHeight = math.min(header.Size.Y.Offset + math.min(body.TextBounds.Y + 10, workspace.CurrentCamera.ViewportSize.Y-60) + 20, workspace.CurrentCamera.ViewportSize.Y-50)
	frame.Size = UDim2.new(0,widest,0,totalHeight)
end

header:GetPropertyChangedSignal("Text"):Connect(resize)
body:GetPropertyChangedSignal("Text"):Connect(resize)

frame.BackgroundTransparency = 1
header.TextTransparency = 1
body.TextTransparency = 1
topLine.BackgroundTransparency = 1
stroke.Transparency = 1

local function fade(inOrOut)
	TweenService:Create(frame,TweenInfo.new(0.3),{BackgroundTransparency = inOrOut and 0 or 1}):Play()
	TweenService:Create(header,TweenInfo.new(0.3),{TextTransparency = inOrOut and 0 or 1}):Play()
	TweenService:Create(body,TweenInfo.new(0.3),{TextTransparency = inOrOut and 0 or 1}):Play()
	TweenService:Create(topLine,TweenInfo.new(0.3),{BackgroundTransparency = inOrOut and 0 or 1}):Play()
	TweenService:Create(stroke,TweenInfo.new(0.3),{Transparency = inOrOut and 0 or 1}):Play()
	frame.Visible = inOrOut
end

local folderBlacklist = { Pathfinder=true, Lighter=true, EstonianBorderMap=true, DAGR=true, KeyChain=true, Balaclava=true, CombatGloves=true, HandWraps=true, KneePdas=true, Radio=true, DV2=true, AnarchyAxe=true, Scythe=true, Karambit=true, Longsword=true, PlasmaNinjato=true, GreatSword = true, IceAxe = true, }
local containerBlacklist = { Attachments=true }
local SpecialItems = { AsVal=true, TFZ98S=true, R700=true, SPSh44=true, FlareGun=true, HSPV=true, Altyn=true, M4=true, JPC=true, }

local function formatItemsList(items)
	if #items == 0 then return "Empty\n" end
	local counts = {}
	for _, name in ipairs(items) do
		counts[name] = (counts[name] or 0) + 1
	end

	local out = {}
	for name, count in pairs(counts) do
		local displayName = SpecialItems[name] and ("<font color='rgb(0,255,0)'>"..name.."</font>") or name
		if count > 1 then
			displayName = displayName.." x"..count
		end
		table.insert(out, displayName)
	end
	return table.concat(out, ", ").."\n"
end

local function getMouseTarget()
	local cam = workspace.CurrentCamera
	local mouse = Players.LocalPlayer:GetMouse()
	local closestPlayer = nil
	local shortestDist = math.huge
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local screenPos,onScreen = cam:WorldToScreenPoint(plr.Character.HumanoidRootPart.Position)
			if onScreen then
				local dist = (Vector2.new(mouse.X,mouse.Y)-Vector2.new(screenPos.X,screenPos.Y)).Magnitude
				if dist < shortestDist then
					shortestDist = dist
					closestPlayer = plr
				end
			end
		end
	end
	return closestPlayer
end

local function getInventoryText(plr)
	local playersFolder = RS:FindFirstChild("Players")
	if not playersFolder then return "Players folder missing\n" end
	local folder = playersFolder:FindFirstChild(plr.Name)
	if not folder then return "No folder for this player\n" end
	local inv = folder:FindFirstChild("Inventory")
	if not inv then return "No Inventory folder\n" end

	local out = plr.Name.."\n"
	for _,folderItem in ipairs(inv:GetChildren()) do
		if not folderBlacklist[folderItem.Name] then
			local containerItems = {}
			for _,container in ipairs(folderItem:GetChildren()) do
				if not containerBlacklist[container.Name] then
					if container.Name == "Inventory" then
						for _,nested in ipairs(container:GetChildren()) do
							table.insert(containerItems, nested.Name)
						end
					else
						table.insert(containerItems, container.Name)
					end
				end
			end
			local folderDisplay = SpecialItems[folderItem.Name] and ("<font color='rgb(0,255,0)'>"..folderItem.Name.."</font>") or folderItem.Name
			out = out..folderDisplay..":\n"..formatItemsList(containerItems).."\n"
		end
	end
	return out
end

local tracking = false
local updateTask

local function startTracking()
	tracking = true
	fade(true)
	if updateTask then updateTask:Disconnect() end
	updateTask = RunService.Heartbeat:Connect(function(dt)
		if not tracking then return end
		local target = getMouseTarget()
		if target then
			header.Text = "Inventory"
			body.Text = getInventoryText(target)
			resize()
		end
	end)
end

local function stopTracking()
	tracking = false
	fade(false)
	if updateTask then updateTask:Disconnect() end
end

UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Comma then
		if tracking then
			stopTracking()
		else
			startTracking()
		end
	end
	if input.KeyCode == Enum.KeyCode.F5 then
		stopTracking()
		gui:Destroy()
	end
end)
