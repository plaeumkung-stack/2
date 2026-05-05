-- [[ PK-HUB | SLIME RNG (PRO FARMER) | DELTA & MOBILE ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local UIList = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Position = UDim2.new(0.5, -95, 0.5, -100)
Main.Size = UDim2.new(0, 190, 0, 200)
Main.Active = true
Main.Draggable = true

UIList.Parent = Main
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton")
    local active = false
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Parent = Main
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = txt .. ": " .. (active and "ON" or "OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 45)
        callback(active)
    end)
end

-- 1. AUTO EQUIP BEST (ใส่สไลม์ที่โหดที่สุดให้อัตโนมัติ)
CreateBtn("Auto Equip Best", function(v)
    getgenv().AutoEquip = v
    task.spawn(function()
        while getgenv().AutoEquip do
            pcall(function()
                -- ส่งคำสั่งสวมใส่ตัวที่ดีที่สุดไปยังระบบของแมพ Stouts Studio
                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("EquipBest", true)
                if remote then
                    remote:FireServer()
                end
            end)
            task.wait(5) -- เช็กทุกๆ 5 วินาที
        end
    end)
end)

-- 2. ITEM TP & MAGNET (วาร์ปเก็บไอเทมดรอป: Apple, Carrot, Potion, Goop)
CreateBtn("TP to Items", function(v)
    getgenv().TPItem = v
    task.spawn(function()
        while getgenv().TPItem do
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                -- รายชื่อไอเทมตาม Wiki (Goop, Apple, Carrot, Potion, Luck)
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") and obj.Parent then
                        local n = obj.Parent.Name:lower()
                        if n:find("goop") or n:find("apple") or n:find("carrot") or n:find("potion") or n:find("luck") then
                            -- วาร์ปไปหาไอเทมโดยตรง
                            hrp.CFrame = obj.Parent.CFrame
                            task.wait(0.1)
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end)

-- 3. MOB TELEPORT (วาร์ปไปหามอนสเตอร์เพื่อฟาร์มเลเวล/เงิน)
CreateBtn("TP to Monsters", function(v)
    getgenv().TPMob = v
    task.spawn(function()
        while getgenv().TPMob do
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                -- สแกนหามอนสเตอร์ในแมพ (Enemy/Monster)
                for _, mob in pairs(workspace:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Name ~= game.Players.LocalPlayer.Name then
                        -- วาร์ปไปข้างหลังมอนสเตอร์
                        hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        task.wait(0.5)
                        if not getgenv().TPMob then break end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)

-- 4. SPEED HACK
CreateBtn("Speed 100", function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16
end)
