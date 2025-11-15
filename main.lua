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
loadstring(game:HttpGet("https://raw.githubusercontent.com/fusion-lua/thread.lua/refs/heads/main/threadcleanseview.lua"))()
sendNotification("thread.lua", "Loading complete! Press F9 to view controls.", 3)
