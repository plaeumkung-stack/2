-- [[ PK-HUB | SLIME RNG (Stouts Studio) | DELTA VERSION ]] --
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UIList = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0.5, -90, 0.5, -110)
Frame.Size = UDim2.new(0, 180, 0, 220)
Frame.Active = true
Frame.Draggable = true

UIList.Parent = Frame
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton")
    local active = false
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Parent = Frame
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = txt .. ": " .. (active and "ON" or "OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 50, 50)
        callback(active)
    end)
end

-- 1. AUTO ROLL (แมพนี้ใช้ Remote ในระบบ Network)
CreateBtn("Auto Roll", function(v)
    getgenv().Rolling = v
    task.spawn(function()
        while getgenv().Rolling do
            pcall(function()
                -- แมพของ Stouts Studio มักจะซ่อน Remote ไว้ในโฟลเดอร์ Remotes หรือใช้ชื่อ Network
                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Roll", true) or 
                               game:GetService("ReplicatedStorage"):FindFirstChild("Click", true)
                if remote and remote:IsA("RemoteEvent") then
                    remote:FireServer()
                end
            end)
            task.wait(0.1)
        end
    end)
end)

-- 2. ITEM MAGNET (แอปเปิ้ล, ยา, แครอท)
CreateBtn("Magnet", function(v)
    getgenv().Mag = v
    task.spawn(function()
        while getgenv().Mag do
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                -- กวาดไอเทมจากโฟลเดอร์ของแมพ Stouts Studio
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") and obj.Parent then
                        local n = obj.Parent.Name:lower()
                        if n:find("apple") or n:find("carrot") or n:find("potion") or n:find("luck") or n:find("slime") then
                            obj.Parent.CFrame = hrp.CFrame
                        end
                    end
                end
            end)
            task.wait(0.8)
        end
    end)
end)

-- 3. AUTO EQUIP BEST (ใส่สไลม์โหดสุด)
CreateBtn("Auto Best", function(v)
    getgenv().Best = v
    task.spawn(function()
        while getgenv().Best do
            pcall(function()
                local equip = game:GetService("ReplicatedStorage"):FindFirstChild("EquipBest", true)
                if equip then equip:FireServer() end
            end)
            task.wait(5)
        end
    end)
end)

-- 4. SPEED (Delta รองรับตัวนี้ดีที่สุด)
CreateBtn("Speed 100", function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16
end)

-- ANTI-AFK (กันหลุด)
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)
