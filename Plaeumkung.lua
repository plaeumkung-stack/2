-- [[ PK-HUB | BE FLASH MOD (FLY & SPEED) ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UIList = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Position = UDim2.new(0, 15, 0.5, -75)
Main.Size = UDim2.new(0, 170, 0, 160)
Main.Active = true
Main.Draggable = true

Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "PK-HUB FLY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

UIList.Parent = Main
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local flySpeed = 50
local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton")
    local active = false
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Parent = Main
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.BorderSizePixel = 0
    
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = txt .. ": " .. (active and "ON" or "OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 55)
        callback(active)
    end)
end

-- ระบบ Fly (บินตามทิศทางกล้อง)
local lp = game.Players.LocalPlayer
local bVel, bGyro

CreateBtn("Fly (บิน)", function(v)
    getgenv().Flying = v
    local char = lp.Character or lp.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    if v then
        bVel = Instance.new("BodyVelocity", root)
        bGyro = Instance.new("BodyGyro", root)
        bVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        
        task.spawn(function()
            while getgenv().Flying do
                bVel.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
                bGyro.CFrame = workspace.CurrentCamera.CFrame
                task.wait()
            end
            if bVel then bVel:Destroy() end
            if bGyro then bGyro:Destroy() end
        end)
    else
        if bVel then bVel:Destroy() end
        if bGyro then bGyro:Destroy() end
    end
end)

-- ปุ่มปรับความเร็ว (กดวน 50 -> 150 -> 300)
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.9, 0, 0, 35)
speedBtn.Parent = Main
speedBtn.Text = "Fly Speed: 50"
speedBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.MouseButton1Click:Connect(function()
    if flySpeed == 50 then flySpeed = 150 
    elseif flySpeed == 150 then flySpeed = 300
    else flySpeed = 50 end
    speedBtn.Text = "Fly Speed: " .. tostring(flySpeed)
end)

-- ปุ่มปิด UI
local close = Instance.new("TextButton")
close.Size = UDim2.new(0.9, 0, 0, 30)
close.Parent = Main
close.Text = "Close Hub"
close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
