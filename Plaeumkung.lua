local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "PK-HUB | APOCALYPSE SURVIVAL",
    SubTitle = "Auto-Farm & Seller Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Survival", Icon = "shield" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "box" })
}

local Options = Fluent.Options

-- ── SURVIVAL SECTION ────────────────────────────────────────

Tabs.Main:AddToggle("GodMode", {Title = "God Mode (อมตะ)", Default = false})
Tabs.Main:AddToggle("AutoEat", {Title = "Auto Eat/Drink (กิน/ดื่ม ออโต้)", Default = false})
Tabs.Main:AddToggle("NoDarkness", {Title = "Full Bright (ปิดความมืด)", Default = false})

-- ระบบ Full Bright (มองเห็นตอนกลางคืน)
task.spawn(function()
    while task.wait(1) do
        if Options.NoDarkness.Value then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").FogEnd = 100000
        end
    end
end)

-- ── COMBAT SECTION (ล่าซอมบี้ปั๊มเวล) ───────────────────────────

Tabs.Combat:AddToggle("KillAura", {Title = "Kill Aura (ตีกระจายรอบตัว)", Default = false})
Tabs.Combat:AddSlider("AuraRange", {Title = "ระยะ Kill Aura", Default = 15, Min = 5, Max = 50, Rounding = 1})

task.spawn(function()
    while task.wait(0.1) do
        if Options.KillAura.Value then
            pcall(function()
                local character = game.Players.LocalPlayer.Character
                for _, enemy in pairs(game:GetService("Workspace").Enemies:GetChildren()) do -- ปรับชื่อโฟลเดอร์ตามแมพ
                    local distance = (enemy.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                    if distance <= Options.AuraRange.Value then
                        -- ส่ง Remote ตี (ต้องแก้ชื่อ Remote ตามของแมพ)
                        -- game:GetService("ReplicatedStorage").Remotes.Attack:FireServer(enemy)
                    end
                end
            end)
        end
    end
end)

-- ── MISC SECTION (หาของปั้นรหัส) ─────────────────────────────

Tabs.Misc:AddButton({
    Title = "Auto Loot Items (เก็บของรอบตัว)",
    Description = "ดูดไอเทมที่ตกอยู่รอบๆ เข้าตัวทันที",
    Callback = function()
        for _, item in pairs(game:GetService("Workspace").Items:GetChildren()) do -- ปรับชื่อตามแมพ
            if item:IsA("BasePart") or item:FindFirstChild("Handle") then
                item.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
})

Tabs.Misc:AddSlider("WS", {
    Title = "Speed Hack",
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 0,
    Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end
})

Window:SelectTab(1)

Fluent:Notify({
    Title = "PK-HUB",
    Content = "พร้อมปั้นรหัสไปขายแล้วโบร!",
    Duration = 5
})
