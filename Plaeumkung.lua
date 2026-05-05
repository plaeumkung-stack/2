-- PK-HUB VERSION ประหยัดทรัพยากร (รันติดง่ายที่สุด)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AutoRollBtn = Instance.new("TextButton")
local MagnetBtn = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "PK_SimpleUI"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.Size = UDim2.new(0, 200, 0, 200)
MainFrame.Active = true
MainFrame.Draggable = true -- ลากหน้าจอได้

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "PK-HUB SIMPLE"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

-- ปุ่ม Auto Roll
AutoRollBtn.Name = "AutoRoll"
AutoRollBtn.Parent = MainFrame
AutoRollBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
AutoRollBtn.Size = UDim2.new(0.8, 0, 0, 30)
AutoRollBtn.Text = "Auto Roll: OFF"
AutoRollBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AutoRollBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local rolling = false
AutoRollBtn.MouseButton1Click:Connect(function()
    rolling = not rolling
    AutoRollBtn.Text = "Auto Roll: " .. (rolling and "ON" or "OFF")
    task.spawn(function()
        while rolling do
            pcall(function() game:GetService("ReplicatedStorage").Events.Roll:FireServer() end)
            task.wait(0.1)
        end
    end)
end)

-- ปุ่ม Magnet
MagnetBtn.Name = "Magnet"
MagnetBtn.Parent = MainFrame
MagnetBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
MagnetBtn.Size = UDim2.new(0.8, 0, 0, 30)
MagnetBtn.Text = "Magnet: OFF"
MagnetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MagnetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local mag = false
MagnetBtn.MouseButton1Click:Connect(function()
    mag = not mag
    MagnetBtn.Text = "Magnet: " .. (mag and "ON" or "OFF")
    task.spawn(function()
        while mag do
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("TouchTransmitter") and v.Parent then
                        local n = v.Parent.Name
                        if n:find("Apple") or n:find("Carrot") or n:find("Potion") then
                            v.Parent.CFrame = hrp.CFrame
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end)

print("PK-HUB Simple Loaded!")
