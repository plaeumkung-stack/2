local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "PK-HUB | SLIME RNG PRO",
    SubTitle = "by Plaeumkung",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- [[ สร้าง Tab ให้ชัดเจน ]] --
local Tabs = {
    Main = Window:AddTab({ Title = "Auto Farm", Icon = "home" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" })
}

local Options = Fluent.Options

-- ── ฟังก์ชันหลัก: AUTO ROLL ──────────────────────────────────
Tabs.Main:AddToggle("AutoRoll", {Title = "Auto Roll (สุ่มรัวๆ)", Default = false})

task.spawn(function()
    while true do
        if Options.AutoRoll and Options.AutoRoll.Value then
            pcall(function()
                game:GetService("ReplicatedStorage").Events.Roll:FireServer()
            end)
        end
        task.wait(0.1)
    end
end)

-- ── ฟังก์ชันหลัก: ITEM MAGNET (ดูดของแอปเปิ้ล/แครอท) ───────────────
Tabs.Main:AddToggle("ItemMagnet", {Title = "Item Magnet (ดูดของรอบตัว)", Default = false})

task.spawn(function()
    while true do
        if Options.ItemMagnet and Options.ItemMagnet.Value then
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                local items = {"Apple", "Carrot", "Potion", "Luck", "Speed", "Banana"}
                
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("TouchTransmitter") and v.Parent then
                        for _, name in pairs(items) do
                            if v.Parent.Name:find(name) then
                                v.Parent.CFrame = hrp.CFrame
                            end
                        end
                    end
                end
            end)
        end
        task.wait(1.5)
    end
end)

-- ── ฟังก์ชันรอง: AUTO POTION ────────────────────────────────
Tabs.Main:AddToggle("AutoPotion", {Title = "Auto Use Potions (กดใช้ยาออโต้)", Default = false})

task.spawn(function()
    while true do
        if Options.AutoPotion and Options.AutoPotion.Value then
            pcall(function()
                local bp = game.Players.LocalPlayer.Backpack
                for _, item in pairs(bp:GetChildren()) do
                    if item.Name:find("Potion") or item.Name:find("Luck") then
                        item.Parent = game.Players.LocalPlayer.Character
                        task.wait(0.2)
                        item:Activate()
                        task.wait(0.2)
                        item.Parent = bp
                    end
                end
            end)
        end
        task.wait(3)
    end
end)

-- ── ฟังก์ชันจิปาถะ ──────────────────────────────────────────
Tabs.Misc:AddSlider("WalkSpeed", {
    Title = "Speed Hack",
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 1,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

Tabs.Misc:AddButton({
    Title = "Anti-AFK (กันหลุด)",
    Callback = function()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
    end
})

-- บังคับเลือก Tab แรกตอนเปิด
Window:SelectTab(1)

Fluent:Notify({
    Title = "PK-HUB Loaded",
    Content = "ฟังก์ชันมาครบแล้วโบร! ถ้าไม่เห็นให้ลองกด Tab 'Auto Farm' ดู",
    Duration = 5
})
