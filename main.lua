local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local function sendNotification(title, text, duration)
    duration = duration or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
        })
    end)
end

print([[

=============================================
              	 THREAD.LUA
=============================================
          EVERY EXECUTOR SUPPORTED

Open source uni/pd script
join the Discord for updates, devlog, detection and more:
https://discord.gg/P24XGuvQ4u

------------------------------------------
Version: 2.2.0  |  Status: Stable
------------------------------------------

F1 - Toggle Aimbot FOV
F2 - Toggle Aimbot
F3 - Toggle Player & NPC ESP
F4 - Toggle Player Visibility Through Walls
F5 - Unload Script
F6 - List all bosses and their status
F7 - Toggle inventory checker
F8 - Toggle viewmodel cleanse (transparent viewmodel)
`  - Hold to zoom
Scroll Wheel - Aimbot (Toggle)
	
---------------------------------------------
© 2025 Fusion | Paid distribution restricted.
=============================================

]])

loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadaim.lua"))()
sendNotification("thread.lua", "Aimbot loaded!", 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadsight.lua"))()
sendNotification("thread.lua", "Primary & ESP Loaded!", 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadskel.lua"))()
sendNotification("thread.lua", "Skeleton + Drawing loaded!", 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/invchecker.lua"))()
sendNotification("thread.lua", "Inventory checking loaded!", 3)
sendNotification("thread.lua", "Loading complete!", 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadkeybindlist.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadui.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadanim.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadunload.lua"))()
sendNotification("thread.lua", "Unload possible. Press F5 to unload script.", 2)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadcleanseview.lua"))()
