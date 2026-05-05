-- [[ PK-HUB CUSTOM ENGINE - NO LIBRARY VERSION ]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local Container = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- Setup UI หลัก (ป้องกันการโหลดไม่ขึ้น)
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "PK_HUB_V3"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true -- ลากหน้าจอได้บนมือถือ

UICorner.Parent = MainFrame

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "PK-HUB | SLIME RNG"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold

Container.Parent = MainFrame
Container.Position = UDim2.new(0, 5, 0, 45)
Container.Size = UDim2.new(1, -10, 1, -50)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 4

UIListLayout.Parent = Container
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [[ ฟังก์ชันสร้างปุ่มแบบรวดเร็ว ]] --
local function CreateToggleButton(name, callback)
    local Button = Instance.new("TextButton")
    local state = false
    
    Button.Size = UDim2.new(0.9, 0, 0, 35)
    Button.Parent = Container
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = name .. " : OFF"
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.Text = name .. " : " .. (state and "ON" or "OFF")
        Button.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

-- [[ 1. AUTO ROLL ]] --
CreateToggleButton("Auto Roll", function(v)
    getgenv().Rolling = v
    task.spawn(function()
        while getgenv().Rolling do
            pcall(function() game:GetService("ReplicatedStorage").Events.Roll:FireServer() end)
            task.wait(0.1)
        end
    end)
end)

-- [[ 2. ITEM MAGNET (WIKI ITEMS) ]] --
CreateToggleButton("Item Magnet", function(v)
    getgenv().Magnet = v
    task.spawn(function()
        while getgenv().Magnet do
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                local items = {"Apple", "Carrot", "Potion", "Luck", "Speed"}
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") and obj.Parent then
                        for _, name in pairs(items) do
                            if obj.Parent.Name:find(name) then
                                obj.Parent.CFrame = hrp.CFrame
                            end
                        end
                    end
                end
            end)
            task.wait(1.5)
        end
    end)
end)

-- [[ 3. AUTO EQUIP BEST ]] --
CreateToggleButton("Auto Best Slime", function(v)
    getgenv().AutoBest = v
    task.spawn(function()
        while getgenv().AutoBest do
            pcall(function() game:GetService("ReplicatedStorage").Events.EquipBest:FireServer() end)
            task.wait(5)
        end
    end)
end)

-- [[ 4. SPEED HACK ]] --
CreateToggleButton("Speed Hack (100)", function(v)
    if v then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
    else
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

-- [[ 5. ANTI-AFK ]] --
local function AntiAFK()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end
AntiAFK()

print("PK-HUB V3 LOADED SUCCESSFULLY")
