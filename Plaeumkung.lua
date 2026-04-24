local Flux = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua"))() -- ใช้ Fluent แทน (ตัวนี้สวยและใหม่กว่า)
local Window = Flux:CreateWindow({
    Title = "PK-HUB | GIANT EDITION",
    SubTitle = "by Plaeumkung",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 320), -- ขนาดกะทัดรัดสำหรับมือถือ
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- [[ ปุ่มขยายร่าง ]] --
Tabs.Main:AddButton({
    Title = "ขยายร่างใหญ่ (Giant Mode)",
    Description = "ทำให้ตัวมึงใหญ่ยักษ์ (ใช้ได้ในแมพตัวเอง)",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            local s = 5 -- อยากใหญ่กว่านี้แก้เลขนี้
            
            hum:WaitForChild("HeadScale").Value = s
            hum:WaitForChild("BodyDepthScale").Value = s
            hum:WaitForChild("BodyWidthScale").Value = s
            hum:WaitForChild("BodyHeightScale").Value = s
            
            Window:Dialog({
                Title = "System",
                Content = "ขยายร่างสำเร็จแล้วโบร!",
                Buttons = { { Title = "OK", Variant = "Primary" } }
            })
        end
    end
})

-- [[ ปุ่มกลับร่างเดิม ]] --
Tabs.Main:AddButton({
    Title = "กลับร่างปกติ (Reset Size)",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            hum:WaitForChild("HeadScale").Value = 1
            hum:WaitForChild("BodyDepthScale").Value = 1
            hum:WaitForChild("BodyWidthScale").Value = 1
            hum:WaitForChild("BodyHeightScale").Value = 1
        end
    end
})

-- [[ ระบบปิด UI ]] --
Tabs.Settings:AddKeybind("ToggleBind", {
    Title = "ปุ่มเปิด/ปิดเมนู",
    Default = "RightControl",
    ChangedCallback = function(New)
        print("Bind changed to:", New)
    end
})

Window:SelectTab(1)
