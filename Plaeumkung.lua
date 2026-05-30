-- [[ PK-HUB | FULL REPAIR & TELEPORT AUTOMATION ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UIList = Instance.new("UIListLayout")

-- Setup UI
ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
Main.Position = UDim2.new(0, 15, 0.5, -100)
Main.Size = UDim2.new(0, 180, 0, 210)
Main.Active = true
Main.Draggable = true

Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "PK ULTIMATE GARAGE"
Title.TextColor3 = Color3.fromRGB(100, 200, 255)
Title.BackgroundColor3 = Color3.fromRGB(30, 40, 50)

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

-- ฟังก์ชันสร้างปุ่มใน UI
local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 35)
    b.Parent = Main
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(45, 55, 65)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    
    b.MouseButton1Click:Connect(callback)
    return b
end

-- 1. ปุ่มถอดชิ้นส่วนรถทั้งหมดออโต้ (One-Click Strip)
CreateBtn("❌ ถอดพาร์ททั้งหมด", function()
    pcall(function()
        local Car = GetMyCar()
        if not Car or not Car:FindFirstChild("PartsEvent") then return end
        
        local Body = Car:FindFirstChild("Body")
        local EngineBay = Body and Body:FindFirstChild("EngineBay")
        
        -- ถอดในห้องเครื่อง
        if EngineBay then
            for _, part in next, EngineBay:GetChildren() do
                Car.PartsEvent:FireServer("RemovePart", part.Name)
                task.wait(0.01)
            end
        end
        
        -- ถอดชิ้นส่วนรอบนอกบอดี้เพิ่มเติม (ถ้ามี)
        if Body then
            for _, part in next, Body:GetChildren() do
                if part.Name ~= "EngineBay" then
                    Car.PartsEvent:FireServer("RemovePart", part.Name)
                    task.wait(0.01)
                end
            end
        end
    end)
end)

-- 2. ปุ่มเปิดระบบเร่งเครื่องซ่อม (Toggle เหมือนรอบที่แล้ว)
local BenchToggle = CreateBtn("⚡ เร่งแท่นซ่อม: OFF", function() end)
BenchToggle.MouseButton1Click:Connect(function()
    getgenv().FastRepair = not getgenv().FastRepair
    if getgenv().FastRepair then
        BenchToggle.Text = "⚡ เร่งแท่นซ่อม: ON"
        BenchToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        task.spawn(function()
            while getgenv().FastRepair do
                pcall(function()
                    for _, v in next, workspace:GetDescendants() do
                        if v.Name == "SEALEA SUPER START 655" or v.Name:lower():find("bench") then
                            local event = v:FindFirstChild("RepairEvent") or v:FindFirstChild("Event") or v:FindFirstChildOfClass("RemoteEvent")
                            if event then
                                event:FireServer("Repair", true)
                                event:FireServer("StartRepair")
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    else
        BenchToggle.Text = "⚡ เร่งแท่นซ่อม: OFF"
        BenchToggle.BackgroundColor3 = Color3.fromRGB(45, 55, 65)
    end
end)

-- 3. ปุ่มวาร์ปไปหน้าโต๊ะซ่อมสีแดง (Teleport to Bench)
CreateBtn("🌀 วาร์ปไปโต๊ะซ่อม", function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- ค้นหาตำแหน่งของเครื่อง SEALEA
            for _, v in next, workspace:GetDescendants() do
                if v.Name == "SEALEA SUPER START 655" and v:IsA("BasePart") then
                    -- วาร์ปตัวละครไปเหนือนั่งร้านหรือหน้าเครื่องเล็กน้อย (บวกระยะไม่ให้จมดิน)
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame * CFrame.new(0, 3, 4)
                    break
                elseif v.Name == "SEALEA SUPER START 655" and v:IsA("Model") then
                    local primary = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                    if primary then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = primary.CFrame * CFrame.new(0, 3, 4)
                        break
                    end
                end
            end
        end
    end)
end)

-- 4. ปุ่มประกอบพาร์ทกลับเข้าที่รถ (One-Click Reapply)
CreateBtn("🔧 ประกอบชิ้นส่วนรถ", function()
    pcall(function()
        local Car = GetMyCar()
        if not Car or not Car:FindFirstChild("PartsEvent") then return end
        
        if workspace:FindFirstChild("MoveableParts") then
            for _, part in next, workspace.MoveableParts:GetChildren() do
                if part:GetAttribute("Owner") == LocalPlayer.Name or not part:GetAttribute("Owner") then
                    Car.PartsEvent:FireServer("ReapplyPart", part)
                    task.wait(0.01)
                end
            end
        end
    end)
end)
