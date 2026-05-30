-- [[ PK-HUB | VEHICLE REPAIR TO SELL ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UIList = Instance.new("UIListLayout")
local RepairBtn = Instance.new("TextButton")

-- Setup UI ให้กระชับ ปุ่มเดียวกดง่ายๆ
ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30) -- ธีมอู่ซ่อมรถแต่งซิ่ง
Main.Position = UDim2.new(0, 15, 0.5, -45)
Main.Size = UDim2.new(0, 160, 0, 85)
Main.Active = true
Main.Draggable = true

Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "PK DEALER HUB"
Title.TextColor3 = Color3.fromRGB(255, 200, 50)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

UIList.Parent = Main
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ฟังก์ชันดึงรถตัวเอง
local LocalPlayer = game.Players.LocalPlayer
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

-- ปุ่มกดซ่อมทีเดียว (ไม่ลูป กดปุ๊บประกอบครบปั๊บ)
RepairBtn.Name = "RepairBtn"
RepairBtn.Parent = Main
RepairBtn.Size = UDim2.new(0.95, 0, 0, 45)
RepairBtn.Text = "🔧 ซ่อมประกอบรถ (90%+)"
RepairBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
RepairBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RepairBtn.Font = Enum.Font.SourceSansBold
RepairBtn.TextSize = 16
RepairBtn.BorderSizePixel = 0

RepairBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local Car = GetMyCar()
        if not Car or not Car:FindFirstChild("PartsEvent") then 
            -- ถ้ารถยังไม่เกิด หรือหาไม่เจอ
            RepairBtn.Text = "❌ ไม่พบรถของมึง!"
            RepairBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            task.wait(1.5)
            RepairBtn.Text = "🔧 ซ่อมประกอบรถ (90%+)"
            RepairBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            return 
        end
        
        RepairBtn.Text = "⏳ กำลังประกอบ..."
        RepairBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        
        -- สแกนหาชิ้นส่วนพาร์ททั้งหมดที่เป็นของมึงข้างนอก แล้วยัดกลับเข้าห้องเครื่องทีเดียว
        if workspace:FindFirstChild("MoveableParts") then
            local partCount = 0
            for _, part in next, workspace.MoveableParts:GetChildren() do
                if part:GetAttribute("Owner") == LocalPlayer.Name then
                    Car.PartsEvent:FireServer("ReapplyPart", part)
                    partCount = partCount + 1
                    -- หน่วงนิดๆ กันสแปมรีโมทค้าง (0.01 วิคือกำลังดี ไวมาก)
                    task.wait(0.01) 
                end
            end
            
            -- ซ่อมเสร็จสิ้น
            RepairBtn.Text = "✅ ซ่อมเสร็จแล้ว! เอาไปขายได้"
            RepairBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            task.wait(2)
            RepairBtn.Text = "🔧 ซ่อมประกอบรถ (90%+)"
            RepairBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end
    end)
end)
