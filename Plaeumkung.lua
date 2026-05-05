-- [[ PK-HUB FINAL VERSION | SLIME RNG (STOUTS STUDIO) ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local UIList = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Position = UDim2.new(0.5, 50, 0.5, -80) -- ขยับหลบกลางจอ
Main.Size = UDim2.new(0, 170, 0, 180)
Main.Active = true
Main.Draggable = true

UIList.Parent = Main
UIList.Padding = UDim.new(0, 2)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton")
    local active = false
    b.Size = UDim2.new(1, 0, 0, 35)
    b.Parent = Main
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.BorderSizePixel = 0
    
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = txt .. ": " .. (active and "ON" or "OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 40)
        callback(active)
    end)
end

-- 1. AUTO EQUIP BEST (กดปุ่มสีฟ้าใน Backpack มึงให้เลย)
CreateBtn("Auto Equip Best", function(v)
    getgenv().Equip = v
    task.spawn(function()
        while getgenv().Equip do
            pcall(function()
                local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
                -- สแกนหาปุ่ม Equip Best ในหน้าจอ
                for _, btn in pairs(playerGui:GetDescendants()) do
                    if btn:IsA("TextButton") and btn.Text:find("EQUIP BEST") then
                        for _, conn in pairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                    end
                end
            end)
            task.wait(5)
        end
    end)
end)

-- 2. TP TO ITEMS (สแกนหาของดรอปทุกชนิด)
CreateBtn("TP to Items", function(v)
    getgenv().Items = v
    task.spawn(function()
        while getgenv().Items do
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                -- ควานหาไอเทมในจุดที่แมพนี้ชอบดรอป
                for _, item in pairs(workspace:GetDescendants()) do
                    if item:IsA("TouchTransmitter") and item.Parent then
                        local name = item.Parent.Name:lower()
                        if name:find("apple") or name:find("carrot") or name:find("potion") or name:find("goop") or name:find("luck") then
                            hrp.CFrame = item.Parent.CFrame
                            task.wait(0.3)
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end)

-- 3. TP TO MONSTERS (รอให้ตายก่อน)
CreateBtn("TP to Monsters", function(v)
    getgenv().Mobs = v
    task.spawn(function()
        while getgenv().Mobs do
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                for _, mob in pairs(workspace:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                        -- ล็อกเป้าจนกว่าจะตาย
                        while getgenv().Mobs and mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 do
                            hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                            task.wait(0.1)
                        end
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
