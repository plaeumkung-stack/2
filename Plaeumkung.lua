-- [[ PK-HUB | SLIME RNG (STOUTS STUDIO) | MEGA FIX ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local UIList = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Position = UDim2.new(0.5, 50, 0.5, -80)
Main.Size = UDim2.new(0, 180, 0, 200)
Main.Active = true
Main.Draggable = true

UIList.Parent = Main
UIList.Padding = UDim.new(0, 3)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton")
    local active = false
    b.Size = UDim2.new(0.95, 0, 0, 38)
    b.Parent = Main
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.BorderSizePixel = 0
    
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = txt .. ": " .. (active and "ON" or "OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(45, 45, 45)
        callback(active)
    end)
end

-- 1. AUTO EQUIP BEST (เรียก Remote ตรงๆ ไม่ผ่านปุ่มหน้าจอ)
CreateBtn("Auto Equip Best", function(v)
    getgenv().AutoEquip = v
    task.spawn(function()
        while getgenv().AutoEquip do
            pcall(function()
                -- แมพนี้ใช้ Remote ใน Network หรือ Remotes
                local net = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") or game:GetService("ReplicatedStorage")
                local eq = net:FindFirstChild("EquipBest") or net:FindFirstChild("Equip")
                if eq:IsA("RemoteEvent") then
                    eq:FireServer()
                elseif eq:IsA("RemoteFunction") then
                    eq:InvokeServer()
                end
            end)
            task.wait(5)
        end
    end)
end)

-- 2. ITEM TP (สแกนหาของดรอปในโลก)
CreateBtn("TP to Items", function(v)
    getgenv().TPItems = v
    task.spawn(function()
        while getgenv().TPItems do
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                -- ควานหาใน Workspace จุดที่แมพเสกของ
                for _, drop in pairs(workspace:GetDescendants()) do
                    if drop:IsA("TouchTransmitter") and drop.Parent then
                        local n = drop.Parent.Name:lower()
                        if n:find("apple") or n:find("carrot") or n:find("potion") or n:find("goop") or n:find("luck") or n:find("token") then
                            hrp.CFrame = drop.Parent.CFrame
                            task.wait(0.2)
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)

-- 3. MOB TP (เจาะจงเฉพาะตัวที่อยู่ใกล้ในโซนเดียวกัน)
CreateBtn("TP Monsters (Zone)", function(v)
    getgenv().TPMobs = v
    task.spawn(function()
        while getgenv().TPMobs do
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                local targetMob = nil
                local dist = 500 -- ระยะสแกนหาในโซน (ไม่ให้วาร์ปข้ามแมพจนเอ๋อ)

                for _, mob in pairs(workspace:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                        local mDist = (hrp.Position - mob.HumanoidRootPart.Position).Magnitude
                        if mDist < dist then
                            targetMob = mob
                            break -- เจอตัวแรกที่ใกล้สุดในโซนให้ล็อกเป้าทันที
                        end
                    end
                end

                if targetMob then
                    while getgenv().TPMobs and targetMob and targetMob:FindFirstChild("Humanoid") and targetMob.Humanoid.Health > 0 do
                        hrp.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5) -- จี้ตูดระยะ 5
                        task.wait(0.1)
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)

-- 4. SPEED 100
CreateBtn("Speed 100", function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16
end)
