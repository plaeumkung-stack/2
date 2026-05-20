-- [[ PK-HUB | WIZARD ALCHEMY | FIXED AUTO CAST ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UIList = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
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

-- 1. AUTO CAST (สั่งเปิดปุ่ม Auto Cast สีดำในเกมให้เอง และกดใช้ไม้คทาออโต้)
CreateBtn("Auto Attack", function(v)
    getgenv().AutoWizard = v
    task.spawn(function()
        while getgenv().AutoWizard do
            pcall(function()
                local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
                
                -- ส่วนที่ 1: ควานหาปุ่ม Auto Cast ในหน้าจอเกมแล้วสั่งเปิดใช้งาน
                for _, btn in pairs(playerGui:GetDescendants()) do
                    if btn:IsA("TextButton") and (btn.Name:lower():find("cast") or btn.Text:lower():find("cast")) then
                        firesignal(btn.MouseButton1Click)
                        firesignal(btn.Activated)
                    end
                end
                
                -- ส่วนที่ 2: สั่งให้ตัวละครถืออาวุธและกดยิงสกิลจากคทาในช่องสล็อต
                local char = game.Players.LocalPlayer.Character
                local tool = char:FindFirstChildOfClass("Tool") or game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                
                if tool then
                    if tool.Parent ~= char then
                        tool.Parent = char -- เอาคทามาถือไว้ในมือ
                    end
                    tool:Activate() -- สั่งยิงเวทมนตร์ออกไป
                end
            end)
            task.wait(0.2) -- ความเร็วในการสับสกิลและยิงเวท
        end
    end)
end)

-- 2. SPEED 100 (แถมปุ่มวิ่งไวให้ไปทำเควสท์ Lombard ง่ายขึ้น)
CreateBtn("Speed 100", function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16
end)

-- Anti AFK กันเด้งออกจากเซิร์ฟเวอร์
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
