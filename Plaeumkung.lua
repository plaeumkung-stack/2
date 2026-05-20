-- [[ PK-HUB | WIZARD ALCHEMY | AUTO ATTACK ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UIList = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 15, 30) -- ธีมพ่อมดม่วงๆ ดำๆ
Main.Position = UDim2.new(0, 15, 0.5, -60)
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

local attackSpeed = 0.1 -- ความเร็วเริ่มต้น (0.1 วินาทีต่อครั้ง)

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

-- 1. AUTO ATTACK (จำลองการกดคลิกตีธรรมดารัวๆ)
local vu = game:GetService("VirtualUser")
CreateBtn("Auto Attack", function(v)
    getgenv().AutoClick = v
    task.spawn(function()
        while getgenv().AutoClick do
            pcall(function()
                -- ยิงคำสั่ง Click ซ้ายจำลองการใช้อาวุธ/เวทมนตร์ในมือ
                vu:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(attackSpeed)
                vu:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
            task.wait(attackSpeed)
        end
    end)
end)

-- 2. ADJUST SPEED (ปุ่มปรับความเร็วในการตี วนลูป)
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.95, 0, 0, 35)
speedBtn.Parent = Main
speedBtn.Text = "Speed: รัวปกติ"
speedBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 70)
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.BorderSizePixel = 0

speedBtn.MouseButton1Click:Connect(function()
    if attackSpeed == 0.1 then
        attackSpeed = 0.01 -- รัวนรกแตก
        speedBtn.Text = "Speed: รัวนรกแตก"
        speedBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    elseif attackSpeed == 0.01 then
        attackSpeed = 0.3 -- ช้าๆ เน้นเสถียร
        speedBtn.Text = "Speed: หน่วงเน้นเซฟ"
        speedBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        attackSpeed = 0.1
        speedBtn.Text = "Speed: รัวปกติ"
        speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- Anti AFK ในตัว กันเด้งออกจากห้อง
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
