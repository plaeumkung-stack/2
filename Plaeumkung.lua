-- [[ PK-HUB SUPER SIMPLE - รันติดชัวร์ 100% ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Layout = Instance.new("UIListLayout")

-- สร้างหน้าต่าง
ScreenGui.Parent = game:GetService("CoreGui")
Main.Name = "PK_Simple"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Main.Position = UDim2.new(0.5, -100, 0.5, -100)
Main.Size = UDim2.new(0, 200, 0, 220)
Main.Active = true
Main.Draggable = true

Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "PK HUB (SLIME RNG)"
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

Layout.Parent = Main
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ฟังก์ชันสร้างปุ่มแบบง่าย
local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton")
    local active = false
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Parent = Main
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = txt .. ": " .. (active and "ON" or "OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        callback(active)
    end)
end

-- 1. Auto Roll
CreateBtn("Auto Roll", function(v)
    getgenv().Roll = v
    task.spawn(function()
        while getgenv().Roll do
            pcall(function() game:GetService("ReplicatedStorage").Events.Roll:FireServer() end)
            task.wait(0.1)
        end
    end)
end)

-- 2. Magnet (ดูดของ)
CreateBtn("Magnet", function(v)
    getgenv().Mag = v
    task.spawn(function()
        while getgenv().Mag do
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                local items = {"Apple", "Carrot", "Potion", "Luck"}
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") then
                        for _, name in pairs(items) do
                            if obj.Parent.Name:find(name) then
                                obj.Parent.CFrame = hrp.CFrame
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end)

-- 3. Auto Best Slime
CreateBtn("Auto Best", function(v)
    getgenv().Best = v
    task.spawn(function()
        while getgenv().Best do
            pcall(function() game:GetService("ReplicatedStorage").Events.EquipBest:FireServer() end)
            task.wait(5)
        end
    end)
end)

-- 4. Speed
CreateBtn("Speed 100", function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16
end)

print("PK-HUB Simple Loaded!")
