-- [[ PK-HUB | VEHICLE PARTS AUTOMATION ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UIList = Instance.new("UIListLayout")

-- Setup UI
ScreenGui.Parent = game:GetService("CoreGui")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 25, 20) -- ธีมเขียวๆ ดำๆ สายซ่อมรถ
Main.Position = UDim2.new(0, 15, 0.5, -60)
Main.Size = UDim2.new(0, 170, 0, 130)
Main.Active = true
Main.Draggable = true

Title.Parent = Main
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "PK MECHANIC HUB"
Title.TextColor3 = Color3.fromRGB(100, 255, 100)
Title.BackgroundColor3 = Color3.fromRGB(30, 40, 30)

UIList.Parent = Main
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ตัวแปรผู้เล่นหลัก
local LocalPlayer = game.Players.LocalPlayer

-- ฟังก์ชันดึงรถตัวเองจากรีโมทที่มึงให้มา
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
    b.Size = UDim2.new(0.95, 0, 0, 35)
    b.Parent = Main
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.BorderSizePixel = 0
    
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = txt .. ": " .. (active and "ON" or "OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 50, 40)
        callback(active)
    end)
end

-- 1. AUTO REMOVE PARTS (ถอดชิ้นส่วนในห้องเครื่องทั้งหมดออโต้)
CreateBtn("Auto Remove Parts", function(v)
    getgenv().AutoRemove = v
    task.spawn(function()
        while getgenv().AutoRemove do
            pcall(function()
                local Car = GetMyCar()
                if Car and Car:FindFirstChild("PartsEvent") then
                    local Body = Car:FindFirstChild("Body")
                    local EngineBay = Body and Body:FindFirstChild("EngineBay")
                    
                    if EngineBay then
                        for _, part in next, EngineBay:GetChildren() do
                            if not getgenv().AutoRemove then break end
                            Car.PartsEvent:FireServer("RemovePart", part.Name)
                            task.wait(0.05) -- หน่วงเวลานิดนึงกันสแปมหลุด
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)

-- 2. AUTO REAPPLY PARTS (ใส่ชิ้นส่วนที่ถอดออกมากลับเข้าที่รถออโต้)
CreateBtn("Auto Reapply Parts", function(v)
    getgenv().AutoReapply = v
    task.spawn(function()
        while getgenv().AutoReapply do
            pcall(function()
                if workspace:FindFirstChild("MoveableParts") then
                    for _, part in next, workspace.MoveableParts:GetChildren() do
                        if not getgenv().AutoReapply then break end
                        
                        if part:GetAttribute("Owner") == LocalPlayer.Name then 
                            local Car = GetMyCar() 
                            if Car and Car:FindFirstChild("PartsEvent") then 
                                Car.PartsEvent:FireServer("ReapplyPart", part) 
                                task.wait(0.05)
                            end 
                        end 
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)
