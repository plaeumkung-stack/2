-- [[ PK-HUB | FLY MOD | BE FLASH FOR BRAINROTS ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local UIList = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Position = UDim2.new(0, 10, 0.5, -50)
Main.Size = UDim2.new(0, 150, 0, 120)
Main.Active = true
Main.Draggable = true

UIList.Parent = Main
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton")
    local active = false
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.Parent = Main
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = txt .. ": " .. (active and "ON" or "OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(50, 50, 50)
        callback(active)
    end)
end

-- ระบบบิน (Fly)
local flySpeed = 50
local c = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
local root = c:WaitForChild("HumanoidRootPart")
local bodyVel = Instance.new("BodyVelocity")
local bodyGyro = Instance.new("BodyGyro")

bodyVel.MaxForce = Vector3.new(0, 0, 0)
bodyVel.Velocity = Vector3.new(0, 0, 0)
bodyGyro.MaxTorque = Vector3.new(0, 0, 0)
bodyGyro.CFrame = root.CFrame

CreateBtn("Fly Mod", function(v)
    getgenv().Flying = v
    if v then
        bodyVel.Parent = root
        bodyGyro.Parent = root
        bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        
        task.spawn(function()
            while getgenv().Flying do
                local cam = workspace.CurrentCamera.CFrame
                local moveDir = Vector3.new(0, 0, 0)
                
                -- ใช้ทิศทางกล้องในการบินบนมือถือ
                body
                        
