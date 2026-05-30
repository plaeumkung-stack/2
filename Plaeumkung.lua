-- [[ PK-HUB | SPEED & ENGINE AUTOMATION ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UIList = Instance.new("UIListLayout")

-- Setup UI
ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
Main.Position = UDim2.new(0, 15, 0.5, -110)
Main.Size = UDim2.new(0, 180, 0, 210)
Main.Active = true
Main.Draggable = true

Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "PK NITRO GARAGE"
Title.TextColor3 = Color3.fromRGB(255, 100, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 30, 60)

UIList.Parent = Main
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local LocalPlayer = game.Players.LocalPlayer

-- ฟังก์ชันดึงรถตัวเอง
local function GetMyCar()
    if workspace:FindFirstChild("Vehicles") then
        for _, v in next, workspace.Vehicles:GetChildren() do 
            if v:GetAttribute("Owner") == LocalPlayer.Name or tostring(v:GetAttribute("Owner")):find(LocalPlayer.Name) then 
                return v 
            end 
        end
    end
    return nil
end

-- ฟังก์ชันสร้างปุ่ม
local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 35)
    b.Parent = Main
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(55, 45, 65)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    
    b.MouseButton1Click:Connect(callback)
    return b
end

-- 1. ปุ่มเปิด-ปิด วิ่งไว (Speed Hack Toggle)
local SpeedToggle = CreateBtn("🏃 วิ่งไว (Speed): OFF", function() end)
SpeedToggle.MouseButton1Click:Connect(function()
    getgenv().SpeedHack = not getgenv().SpeedHack
    if getgenv().SpeedHack then
        SpeedToggle.Text = "🏃 วิ่งไว (Speed): ON"
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        
        -- ลูปบังคับค่า WalkSpeed ของตัวละคร
        task.spawn(function()
            while getgenv().SpeedHack do
                pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        -- สามารถปรับเลข 100 เป็นความเร็วที่มึงต้องการได้ (ปกติเกมน่าจะอยู่ที่ 16)
                        LocalPlayer.Character.Humanoid.WalkSpeed = 100 
                    end
                end)
                task.wait(0.1)
            end
        end)
    else
        SpeedToggle.Text = "🏃 วิ่งไว (Speed): OFF"
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(55, 45, 65)
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- คืนค่าความเร็วปกติ
            end
        end)
    end
end)

-- 2. ปุ่มถอดเครื่องยนต์ทั้งหมดออโต้ (Strip Engine)
CreateBtn("❌ ถอดเครื่องยนต์ทั้งหมด", function()
    pcall(function()
        local Car = GetMyCar()
        if not Car or not Car:FindFirstChild("PartsEvent") then return end
        
        local Body = Car:FindFirstChild("Body")
        local EngineBay = Body and Body:FindFirstChild("EngineBay")
        
        -- ไล่ถอดทุกชิ้นในห้องเครื่อง
        if EngineBay then
            for _, part in next, EngineBay:GetChildren() do
                Car.PartsEvent:FireServer("RemovePart", part.Name)
                task.wait(0.01) -- หน่วงนิดนึงกันรีโมทหลุด
            end
            print("PK-LOG | ถอดชิ้นส่วนห้องเครื่องเสร็จแล้วโบร!")
        end
    end)
end)

-- 3. ปุ่มประกอบเครื่องยนต์กลับเข้าที่รถออโต้ (Reapply Parts)
CreateBtn("🔧 ประกอบเครื่องยนต์กลับ", function()
    pcall(function()
        local Car = GetMyCar()
        if not Car or not Car:FindFirstChild("PartsEvent") then return end
        
        -- ดึงชิ้นส่วนรอบๆ ที่เป็นของเรายัดกลับเข้าที่เดิม
        if workspace:FindFirstChild("MoveableParts") then
            for _, part in next, workspace.MoveableParts:GetChildren() do
                if part:GetAttribute("Owner") == LocalPlayer.Name or not part:GetAttribute("Owner") then
                    Car.PartsEvent:FireServer("ReapplyPart", part)
                    task.wait(0.01)
                end
            end
            print("PK-LOG | ประกอบคืนร่างสำเร็จ!")
        end
    end)
end)
