local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimbotAvailable = false
local Locking = false
local FOVSize = 160
local smoothingSpeed = 30

local FOVFill = Drawing.new("Circle")
local FOVStroke = Drawing.new("Circle")
FOVFill.Visible = true
FOVFill.Filled = true
FOVFill.Transparency = 0.15
FOVFill.Color = Color3.new(1,1,1)
FOVFill.Radius = FOVSize
FOVStroke.Visible = true
FOVStroke.Filled = false
FOVStroke.Transparency = 1
FOVStroke.Color = Color3.new(1,1,1)
FOVStroke.Radius = FOVSize
FOVStroke.Thickness = 1

local connections = {}
local function add(conn) table.insert(connections, conn) end
local function disconnectAll()
	for _,c in ipairs(connections) do
		pcall(function() c:Disconnect() end)
	end
	connections = {}
end

local function mousePos()
	return UserInputService:GetMouseLocation()
end

local function getClosestHeadInFOV()
	local mp = mousePos()
	local bestHead = nil
	local bestDist = FOVFill.Radius
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl ~= LocalPlayer then
			local ch = pl.Character
			if ch then
				local hum = ch:FindFirstChildOfClass("Humanoid")
				local head = ch:FindFirstChild("Head")
				if hum and head and hum.Health > 0 then
					local v3, onScreen = Camera:WorldToViewportPoint(head.Position)
					if onScreen then
						local screenVec = Vector2.new(v3.X, v3.Y)
						local d = (screenVec - mp).Magnitude
						if d < bestDist then
							bestDist = d
							bestHead = head
						end
					end
				end
			end
		end
	end
	return bestHead
end

local running = true
spawn(function()
	while running do
		local m = mousePos()
		FOVFill.Position = m
		FOVStroke.Position = m
		wait(0.025)
	end
end)

add(UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.F2 then
		AimbotAvailable = not AimbotAvailable
		if not AimbotAvailable then Locking = false end
	elseif input.KeyCode == Enum.KeyCode.F5 then
		running = false
		FOVFill:Remove()
		FOVStroke:Remove()
		disconnectAll()
		pcall(function() script:Destroy() end)
	elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
		if AimbotAvailable then
			Locking = not Locking
		end
	end
end))

add(RunService.RenderStepped:Connect(function(dt)
	if not (AimbotAvailable and Locking) then return end
	local head = getClosestHeadInFOV()
	if not head then return end
	local camPos = Camera.CFrame.Position
	local desired = CFrame.new(camPos, head.Position)
	local alpha = math.clamp(smoothingSpeed * dt, 0, 1)
	Camera.CFrame = Camera.CFrame:Lerp(desired, alpha)
end))
