local StarterGui = game:GetService("StarterGui")

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

loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadaim.lua"))()
sendNotification("thread.lua", "Aimbot loaded!", 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadsight.lua"))()
sendNotification("thread.lua", "Primary & ESP Loaded!", 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadskel.lua"))()
sendNotification("thread.lua", "Skeleton + Drawing loaded!", 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/invchecker.lua"))()
sendNotification("thread.lua", "Inventory checking loaded!", 3)
sendNotification("thread.lua", "Loading complete! Press F9 to view controls.", 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadcleanseview.lua"))()

print([[

=============================================
              	 THREAD.LUA
=============================================
          EVERY EXECUTOR SUPPORTED

Open source uni/pd script
join the Discord for updates, devlog, detection and more:
https://discord.gg/P24XGuvQ4u

------------------------------------------
Version: 1.4.1  |  Status: Stable
------------------------------------------

F1 - Toggle Aimbot FOV
F2 - Toggle Aimbot
F3 - Toggle Player & NPC ESP
F4 - Toggle Player Visibility Through Walls
F5 - Stop / Remove All ESP
F6 - List all bosses and their status
F7 - Toggle inventory checker
F8 - Toggle viewmodel cleanse (transparent viewmodel)
`  - Hold to zoom
Scroll Wheel - Aimbot (Toggle)
	
---------------------------------------------
© 2025 Fusion | Paid distribution restricted.
=============================================

]])

loadtsring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadanim.lua"))()
