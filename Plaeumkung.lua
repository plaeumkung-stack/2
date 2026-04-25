local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "PK-HUB | APOCALYPSE PRO",
    SubTitle = "by Plaeumkung",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- [[ ฟังก์ชัน Speed Hack ]] --
Tabs.Main:AddSlider("SpeedSlider", {
    Title = "Speed Hack",
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 1,
    Callback = function(Value)
        getgenv().Spd = Value
        task.spawn(function()
            while getgenv().Spd == Value do
                pcall(function() game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value end)
                task.wait()
            end
        end)
    end
})

-- [[ ฟังก์ชัน Kill Aura ]] --
Tabs.Main:AddToggle("KillAura", {Title = "Kill Aura", Default = false})
task.spawn(function()
    while true do
        if Options.KillAura.Value then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                local tool = char:FindFirstChildOfClass("Tool")
                for _, v in pairs(game.Workspace:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Name ~= game.Players.LocalPlayer.Name then
                        local mag = (char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                        if mag < 20 then
                            if tool then
                                tool:Activate()
                                firetouchinterest(v.HumanoidRootPart, tool.Handle, 0)
                                firetouchinterest(v.HumanoidRootPart, tool.Handle, 1)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- [[ ฟังก์ชัน God Mode ]] --
Tabs.Main:AddToggle("GodMode", {Title = "God Mode", Default = false})
task.spawn(function()
    while true do
        if Options.GodMode.Value then
            pcall(function()
                game.Players.LocalPlayer.Character.Humanoid.Health = game.Players.LocalPlayer.Character.Humanoid.MaxHealth
            end)
        end
        task.wait()
    end
end)

-- [[ ฟังก์ชัน Auto Eat/Drink ]] --
Tabs.Main:AddToggle("AutoEat", {Title = "Auto Eat/Drink", Default = false})
task.spawn(function()
    while true do
        if Options.AutoEat.Value then
            pcall(function()
                local bp = game.Players.LocalPlayer.Backpack
                local char = game.Players.LocalPlayer.Character
                for _, v in pairs(bp:GetChildren()) do
                    if v:IsA("Tool") then
                        v.Parent = char
                        task.wait(0.1)
                        v:Activate()
                        task.wait(0.1)
                        v.Parent = bp
                    end
                end
            end)
        end
        task.wait(2)
    end
end)

-- [[ ปุ่มปิด/พับ UI สำหรับมือถือ ]] --
Tabs.Settings:AddButton({
    Title = "ปิดหน้าต่างนี้ (Destroy UI)",
    Callback = function()
        Window:Destroy()
    end
})

Window:SelectTab(1)
