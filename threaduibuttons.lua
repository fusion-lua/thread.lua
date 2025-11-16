local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenEffects = PlayerGui:WaitForChild("NoInsetGui"):WaitForChild("MainFrame"):WaitForChild("ScreenEffects")

local textSize = 10.5
local padding = 12
local buttonSpacing = 5
local buttons = {}
local menuVisible = true
local stopped = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomButtonGui"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local function getTextSize(message)
	local temp = Instance.new("TextLabel")
	temp.Text = message
	temp.Font = Enum.Font.Code
	temp.TextSize = textSize
	temp.TextTransparency = 1
	temp.Size = UDim2.new(0,0,0,0)
	temp.Parent = screenGui
	local width = temp.TextBounds.X + padding*2
	local height = temp.TextBounds.Y + padding*2
	temp:Destroy()
	return width, height
end

local function flashOnClick(gui)
	if gui:FindFirstChild("BlackBox") then
		local blackBox = gui.BlackBox
		local tweenUp = TweenService:Create(blackBox, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.new(1,1,1)})
		local tweenDown = TweenService:Create(blackBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.new(0,0,0)})
		tweenUp:Play()
		tweenUp.Completed:Connect(function() tweenDown:Play() end)
	end
end

local function slideTween(gui, show)
	local targetX = show and 10 or -gui.Size.X.Offset - 10
	TweenService:Create(gui, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, targetX, 0, gui.Position.Y.Offset)
	}):Play()
end

local function repositionButtons()
	local totalHeight = 0
	for _, btn in ipairs(buttons) do
		totalHeight = totalHeight + btn.Size.Y.Offset + buttonSpacing
	end
	totalHeight = totalHeight - buttonSpacing
	local screenHeight = workspace.CurrentCamera.ViewportSize.Y
	local startY = screenHeight/2 - totalHeight/2
	for i, btn in ipairs(buttons) do
		local posY = startY
		for j=1,i-1 do
			posY = posY + buttons[j].Size.Y.Offset + buttonSpacing
		end
		btn.Position = UDim2.new(btn.Position.X.Scale, btn.Position.X.Offset, 0, posY)
	end
end

local function createButton(text, callback)
	local w,h = getTextSize(text)
	h = h * 0.8
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(0, w+8, 0, h+8)
	container.Position = UDim2.new(0,-w-50,0, workspace.CurrentCamera.ViewportSize.Y/2 - (h+8)/2)
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
	blackBox.Name = "BlackBox"
	blackBox.Size = UDim2.new(0, w, 0, h)
	blackBox.Position = UDim2.new(0,4,0,4)
	blackBox.BackgroundColor3 = Color3.new(0,0,0)
	blackBox.BorderSizePixel = 0
	blackBox.Parent = container

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.Position = UDim2.new(0,0,0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.Font = Enum.Font.Code
	lbl.TextSize = textSize
	lbl.TextXAlignment = Enum.TextXAlignment.Center
	lbl.TextYAlignment = Enum.TextYAlignment.Center
	lbl.Active = true
	lbl.Parent = blackBox

	lbl.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			callback()
			flashOnClick(container)
		end
	end)

	table.insert(buttons, container)
	local newW = lbl.TextBounds.X + padding*2
	blackBox.Size = UDim2.new(0, newW, 0, h)
	container.Size = UDim2.new(0, newW+8, 0, h+8)
	whiteOutline.Size = UDim2.new(0, newW+4, 0, h+4)

	repositionButtons()
	slideTween(container, true)
	return container
end

local visorEnabled = true
local function deleteSpecificVisors(parent)
	for _, child in ipairs(parent:GetChildren()) do
		if not child or not child.Parent then continue end
		if child:IsA("Sound") then
			child:Destroy()
		else
			local nameLower = string.lower(child.Name)
			if ((nameLower:find("maska") and nameLower:find("visor")) or
				(nameLower:find("altyn") and nameLower:find("visor"))) and child:IsA("GuiObject") and child.Visible then
				child:Destroy()
			elseif child.Name ~= "DamageModule" then
				deleteSpecificVisors(child)
			end
		end
	end
end

local function deleteScreenEffects()
	local fb = screenEffects:FindFirstChild("Flashbang")
	if fb then if fb:FindFirstChild("ImageLabel") and fb.ImageLabel.Visible then fb.ImageLabel:Destroy() end if fb.Visible then fb:Destroy() end end
	local mask = screenEffects:FindFirstChild("Mask")
	if mask and mask:FindFirstChild("GP5") then
		local gp5 = mask.GP5
		if gp5:FindFirstChild("ImageLabel") and gp5.ImageLabel.Visible then gp5.ImageLabel:Destroy() end
		if gp5:FindFirstChild("GasMask") and gp5.GasMask.Visible then gp5.GasMask:Destroy() end
		if gp5.Visible then gp5:Destroy() end
	end
	local nvt = screenEffects:FindFirstChild("NightVisionTube")
	if nvt and nvt.Visible then nvt:Destroy() end
end

RunService.Heartbeat:Connect(function()
	if stopped or not visorEnabled then return end
	deleteScreenEffects()
end)

local tracersEnabled = false
local tracerLines = {}
local function initializeTracers()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local line = Drawing.new("Line")
			line.Color = Color3.new(1,1,1)
			line.Thickness = 2
			line.Visible = false
			tracerLines[plr] = line
		end
	end
end

Players.PlayerAdded:Connect(function(plr)
	if plr ~= LocalPlayer then
		local line = Drawing.new("Line")
		line.Color = Color3.new(1,1,1)
		line.Thickness = 2
		line.Visible = false
		tracerLines[plr] = line
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	if tracerLines[plr] then
		tracerLines[plr]:Remove()
		tracerLines[plr] = nil
	end
end)

initializeTracers()

task.spawn(function()
	while not stopped do
		if tracersEnabled then
			local camera = workspace.CurrentCamera
			local screenBottom = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
			for plr, line in pairs(tracerLines) do
				local char = plr.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					local rootPos = camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
					if rootPos.Z > 0 then
						line.From = screenBottom
						line.To = Vector2.new(rootPos.X, rootPos.Y)
						line.Visible = true
					else
						line.Visible = false
					end
				else
					line.Visible = false
				end
			end
		else
			for _, line in pairs(tracerLines) do line.Visible = false end
		end
		task.wait(0.05)
	end
end)

local fullbrightEnabled = false
local savedLighting = {}
local function toggleFullbright()
	local lighting = game:GetService("Lighting")
	if not fullbrightEnabled then
		savedLighting.Brightness = lighting.Brightness
		savedLighting.ClockTime = lighting.ClockTime
		savedLighting.GlobalShadows = lighting.GlobalShadows
		savedLighting.OutdoorAmbient = lighting.OutdoorAmbient
		lighting.Brightness = 4
		if lighting.ClockTime >= 6 and lighting.ClockTime <= 18 then
			lighting.ClockTime = 12
		end
		lighting.GlobalShadows = false
		lighting.OutdoorAmbient = Color3.new(1,1,1)
	else
		lighting.Brightness = savedLighting.Brightness
		lighting.ClockTime = savedLighting.ClockTime
		lighting.GlobalShadows = savedLighting.GlobalShadows
		lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
	end
	fullbrightEnabled = not fullbrightEnabled
end

createButton("Delete Visors", function()
	visorEnabled = true
	deleteSpecificVisors(PlayerGui)
end)
createButton("Tracers", function()
	tracersEnabled = not tracersEnabled
end)
createButton("No Shadows", toggleFullbright)

-- LOOK HIGHLIGHT FEATURE WITH SIZE CHECK
local highlightEnabled = false
local currentHighlight
local mouse = LocalPlayer:GetMouse()

task.spawn(function()
	while not stopped do
		if highlightEnabled then
			local target = mouse.Target
			if target and target:IsA("BasePart") then
				local size = target.Size
				local maxDimension = math.max(size.X, size.Y, size.Z)
				if maxDimension <= 50 then
					if not currentHighlight then
						currentHighlight = Instance.new("Highlight")
						currentHighlight.FillColor = Color3.new(1,1,1)
						currentHighlight.FillTransparency = 0.5
						currentHighlight.OutlineTransparency = 1
						currentHighlight.Parent = CoreGui
					end
					currentHighlight.Adornee = target
				else
					if currentHighlight then
						currentHighlight.Adornee = nil
					end
				end
			else
				if currentHighlight then
					currentHighlight.Adornee = nil
				end
			end
		else
			if currentHighlight then
				currentHighlight:Destroy()
				currentHighlight = nil
			end
		end
		task.wait(0.05)
	end
end)

createButton("Look Highlight", function()
	highlightEnabled = not highlightEnabled
	if not highlightEnabled and currentHighlight then
		currentHighlight:Destroy()
		currentHighlight = nil
	end
end)

-- INSTANT LOCK FEATURE
local instantLockEnabled = false
local holdingLock = false
local savedCamCFrame = nil
local cam = workspace.CurrentCamera

local function getNearestLockTarget()
    local closest
    local closestDist = math.huge

    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("Head")
    if not myHRP then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("Head")
            if hrp then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = hrp
                end
            end
        end
    end

    return closest
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or stopped or not instantLockEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        holdingLock = true
        savedCamCFrame = cam.CFrame
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe or stopped or not instantLockEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        holdingLock = false
        if savedCamCFrame then
            cam.CFrame = savedCamCFrame
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if stopped or not instantLockEnabled or not holdingLock then return end
    local target = getNearestLockTarget()
    if target then
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position)
    end
end)

createButton("Instant Lock", function()
    instantLockEnabled = not instantLockEnabled
end)


repositionButtons()
for _, btn in ipairs(buttons) do
	slideTween(btn, true)
end

-- UPDATED F5 UNLOAD TO RESTORE FULLBRIGHT
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F10 and not stopped then
		for _, btn in ipairs(buttons) do
			slideTween(btn, not menuVisible)
		end
		menuVisible = not menuVisible
	elseif input.KeyCode == Enum.KeyCode.F5 then
		stopped = true
		instantLockEnabled = false
		holdingLock = false
		savedCamCFrame = nil
		visorEnabled = false
		tracersEnabled = false
		highlightEnabled = false
		-- Restore fullbright lighting if active
		if fullbrightEnabled then
			local lighting = game:GetService("Lighting")
			lighting.Brightness = savedLighting.Brightness
			lighting.ClockTime = savedLighting.ClockTime
			lighting.GlobalShadows = savedLighting.GlobalShadows
			lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
			fullbrightEnabled = false
		end
		for _, btn in ipairs(buttons) do
			slideTween(btn, false)
		end
		task.delay(0.5, function()
			for _, btn in ipairs(buttons) do btn:Destroy() end
			for _, line in pairs(tracerLines) do line:Remove() end
			if currentHighlight then
				currentHighlight:Destroy()
				currentHighlight = nil
			end
		end)
	end
end)
