local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local f5Connection
f5Connection = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadanim.lua"))()
        if f5Connection then
            f5Connection:Disconnect()
            f5Connection = nil
        end
    end
end)
