-- [[ PK-HUB | WIZARD ALCHEMY | REMOTE ATTACK ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UIList = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
Main.Position = UDim2.new(0, 10, 0.5, -60)
Main.Size = UDim2.new(0, 160, 0, 130)
Main.Active = true
Main.Draggable = true

Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "PK WIZARD HUB"
Title.TextColor3 = Color3.fromRGB(200, 150, 255)
Title.BackgroundColor3 = Color3.fromRGB(40, 30, 60)

UIList.Parent = Main
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton")
    local active = false
    b.Size = UDim2.new(0.95, 0, 0, 35)
    b.Parent = Main
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(50, 40, 70)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.BorderSizePixel = 0
    
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = txt .. ": " .. (active and "ON" or "OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(150, 50, 250) or Color3.fromRGB(50, 40, 70)
        callback(active)
    end)
end

-- 1. AUTO ATTACK (ยิงคำสั่งโจมตีจากตัวคทาโดยตรง)
CreateBtn("Auto Attack", function(v)
    getgenv().AutoWizard = v
    task.spawn(function()
        while getgenv().AutoWizard do
            pcall(function()
                local player = game.Players.LocalPlayer
                local char = player.Character
                
                -- ตรวจสอบคทาในมือหรือในกระเป๋า
                local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
                
                if tool then
                    if tool.Parent ~= char then
                        tool.Parent = char -- สั่งควักคทาออกมาถือ
                    end
                    
                    -- ค้นหาระบบส่งคำสั่งยิงเวท (Remote) ที่ซ่อนอยู่ในคทา
                    local remote = tool:FindFirstChildOfClass("RemoteEvent") or tool:FindFirstChildOfClass("RemoteFunction") or tool:FindFirstChild("Remote")
                    
                    if remote then
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer() -- ยิงเวทมนตร์ออกไปหลังบ้านเลย!
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer()
                        end
                    else
                        -- ถ้าหาในคทาไม่เจอ ให้ยิงคำสั่งเซิร์ฟเวอร์หลักของเกม
                        local sharedRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Cast", true) or game:GetService("ReplicatedStorage"):FindFirstChild("Attack", true)
                        if sharedRemote and sharedRemote:IsA("RemoteEvent") then
                            sharedRemote:FireServer()
                        end
                    end
                end
            end)
            task.wait(0.1) -- สับเวทรัวๆ 0.1 วิ
        end
    end)
end)

-- 2. SPEED 100
CreateBtn("Speed 100", function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16
end)

-- Anti AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
