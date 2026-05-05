-- [[ PK-HUB FINAL FIX | SLIME RNG ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local UIList = Instance.new("UIListLayout")

-- Setup UI (เน้นรันง่าย ไม่โหลดของนอก)
ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Main.Position = UDim2.new(0.5, -90, 0.5, -100)
Main.Size = UDim2.new(0, 180, 0, 200)
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
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = txt .. ": " .. (active and "ON" or "OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
        callback(active)
    end)
end

-- 1. Auto Roll (แก้ให้หา Event เจอชัวร์)
CreateBtn("Auto Roll", function(v)
    getgenv().Rolling = v
    task.spawn(function()
        local rollEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Roll", true) or 
                          game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("Roll")
        
        while getgenv().Rolling do
            if rollEvent then
                pcall(function() rollEvent:FireServer() end)
            end
            task.wait(0.1)
        end
    end)
end)

-- 2. Magnet (ดูดของแอปเปิ้ล/ยา/แครอท)
CreateBtn("Magnet", function(v)
    getgenv().Mag = v
    task.spawn(function()
        while getgenv().Mag do
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                -- รายชื่อไอเทมตาม Wiki
                local items = {"Apple", "Carrot", "Potion", "Luck", "Speed", "Banana"}
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") and obj.Parent then
                        for _, name in pairs(items) do
                            if obj.Parent.Name:find(name) then
                                obj.Parent.CFrame = hrp.CFrame
                                break
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end)

-- 3. Auto Best Slime (ใส่ตัวโหดสุด)
CreateBtn("Auto Best", function(v)
    getgenv().Best = v
    task.spawn(function()
        local equipEvent = game:GetService("ReplicatedStorage"):FindFirstChild("EquipBest", true)
        while getgenv().Best do
            if equipEvent then
                pcall(function() equipEvent:FireServer() end)
            end
            task.wait(5)
        end
    end)
end)

-- 4. Speed Hack (ตัวที่มึงบอกว่าใช้ได้แค่อันเดียว)
CreateBtn("Speed 100", function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16
end)

print("PK-HUB Updated: Slime RNG Fix")
