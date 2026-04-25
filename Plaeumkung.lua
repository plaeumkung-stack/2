local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "PK-HUB | APOCALYPSE WIKI-EDITION",
    SubTitle = "by Plaeumkung",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = { Main = Window:AddTab({ Title = "Main", Icon = "home" }) }
local Options = Fluent.Options

-- [[ KILL AURA แบบระบุเป้าหมายตาม WIKI ]] --
Tabs.Main:AddToggle("KillAura", {Title = "Kill Aura (Target: Zombies)", Default = false})
task.spawn(function()
    while true do
        if Options.KillAura.Value then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                local tool = char:FindFirstChildOfClass("Tool")
                -- ค้นหาในโฟลเดอร์ที่พบบ่อยตาม Wiki
                local targets = workspace:FindFirstChild("Zombies") or workspace:FindFirstChild("Enemies") or workspace
                for _, v in pairs(targets:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Name ~= char.Name then
                        local mag = (char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                        if mag < 20 then
                            if tool then
                                tool:Activate()
                                -- ระบบ Damage Bypass (ถ้ามี Handle)
                                if tool:FindFirstChild("Handle") then
                                    firetouchinterest(v.HumanoidRootPart, tool.Handle, 0)
                                    firetouchinterest(v.HumanoidRootPart, tool.Handle, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- [[ AUTO LOOT (ดึงของเข้าตัว) ]] --
Tabs.Main:AddButton({
    Title = "Auto Loot (ดูดไอเทมรอบตัว)",
    Callback = function()
        pcall(function()
            -- ค้นหาของดรอปตามพิกัดที่ Wiki บอกว่ามักจะอยู่
            local folders = {workspace:FindFirstChild("DroppedItems"), workspace:FindFirstChild("Items"), workspace}
            for _, folder in pairs(folders) do
                if folder then
                    for _, item in pairs(folder:GetChildren()) do
                        if item:IsA("BackpackItem") or item:IsA("Tool") or item:FindFirstChild("Handle") then
                            item:MoveTo(game.Players.LocalPlayer.Character.HumanoidRootPart.Position)
                        end
                    end
                end
            end
        end)
    end
})

-- [[ สปีดแบบเนียนๆ กันวาร์ป ]] --
Tabs.Main:AddSlider("Speed", {
    Title = "Speed Hack",
    Default = 16, Min = 16, Max = 80, Rounding = 1,
    Callback = function(v)
        getgenv().S = v
        task.spawn(function()
            while getgenv().S == v do
                pcall(function() game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end)
                task.wait(0.1)
            end
        end)
    end
})

Window:SelectTab(1)
