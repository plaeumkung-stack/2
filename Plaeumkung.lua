-- [[ PK-HUB | AUTO REPAIR CAR (LOOP) ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UIList = Instance.new("UIListLayout")

-- Setup UI
ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(30, 20, 35) -- ธีมม่วงเข้มๆ ดำๆ สายโมดิฟาย
Main.Position = UDim2.new(0, 15, 0.5, -45)
Main.Size = UDim2.new(0, 170, 0, 95)
Main.Active = true
Main.Draggable = true

Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "PK AUTO REPAIR"
Title.TextColor3 = Color3.fromRGB(200, 100, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 30, 60)

UIList.Parent = Main
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local LocalPlayer = game.Players.LocalPlayer

-- ฟังก์ชันดึงข้อมูลรถของตัวเอง
local function GetMyCar()
    if workspace:FindFirstChild("Vehicles") then
        for _, v in next, workspace.Vehicles:GetChildren() do 
            if v:GetAttribute("Owner") == LocalPlayer.Name then 
                return v 
            end 
        end
    end
    return nil
end

local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton")
    local active = false
    b.Size = UDim2.new(0.95, 0, 0, 45)
    b.Parent = Main
    b.Text = txt .. "\n[ STATUS: OFF ]"
    b.BackgroundColor3 = Color3.fromRGB(50, 40, 55)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.BorderSizePixel = 0
    
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = txt .. (active and "\n[ STATUS: ON ]" or "\n[ STATUS: OFF ]")
        b.BackgroundColor3 = active and Color3.fromRGB(150, 50, 250) or Color3.fromRGB(50, 40, 55)
        callback(active)
    end)
end

-- ระบบ AUTO REPAIR (ลูป ถอด-ใส่ ชิ้นส่วนออโต้)
CreateBtn("Auto Repair Loop", function(v)
    getgenv().AutoRepair = v
    task.spawn(function()
        while getgenv().AutoRepair do
            pcall(function()
                local Car = GetMyCar()
                if not Car or not Car:FindFirstChild("PartsEvent") then return end
                
                -- สเต็ปที่ 1: เช็กชิ้นส่วนในห้องเครื่องแล้วสั่ง "ถอดออก"
                local Body = Car:FindFirstChild("Body")
                local EngineBay = Body and Body:FindFirstChild("EngineBay")
                if EngineBay then
                    for _, part in next, EngineBay:GetChildren() do
                        if not getgenv().AutoRepair then break end
                        Car.PartsEvent:FireServer("RemovePart", part.Name)
                        task.wait(0.02) -- ความเร็วในการส่งรีโมทถอด (ปรับลดได้)
                    end
                end
                
                task.wait(0.1) -- หน่วงนิดนึงให้ระบบเซิร์ฟเวอร์อัปเดตพาร์ท
                
                -- สเต็ปที่ 2: สแกนหาชิ้นส่วนที่เป็นของเราข้างนอกแล้วสั่ง "ใส่กลับ"
                if workspace:FindFirstChild("MoveableParts") then
                    for _, part in next, workspace.MoveableParts:GetChildren() do
                        if not getgenv().AutoRepair then break end
                        if part:GetAttribute("Owner") == LocalPlayer.Name then
                            Car.PartsEvent:FireServer("ReapplyPart", part)
                            task.wait(0.02) -- ความเร็วในการส่งรีโมทใส่กลับ
                        end
                    end
                end
            end)
            task.wait(0.1) -- ระยะเวลาดีเลย์ของลูปซ่อมแต่ละรอบ
        end
    end)
end)
