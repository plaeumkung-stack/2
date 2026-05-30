-- [[ PK-MODIFIED | COMBINED AUTO-FARM HUB (FULL AUTO V3 - FIXED PURCHASE & NAMES) ]] --

local Players             = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Gui                 = game:GetService("GuiService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local Workspace           = game:GetService("Workspace")

local Player        = Players.LocalPlayer
local VehFolder     = Workspace.Vehicles
local GarageFolder  = Player:WaitForChild("PlayerData"):WaitForChild("Garage")
local MoveableParts = Workspace:WaitForChild("MoveableParts")

-- CONFIGURATION (เซ็ตค่าดีเลย์ให้ปลอดภัยและนิ่งที่สุด)
local REPAIR_WAIT       = 18.5
local REMOVE_DELAY      = 0.18
local POST_REMOVE_WAIT  = 2.5
local WARP_SETTLE       = 1.5
local SAFE_OFFSET       = 15
local FIND_PART_TIMEOUT = 20

-- ── Core Shared Functions ─────────────────────────────────────────────────────

local function findPlayerVehicle()
    local success, result = pcall(function()
        for _, v in pairs(VehFolder:GetChildren()) do
            if v:GetAttribute("Owner") == Player.Name or tostring(v:GetAttribute("Owner")):find(Player.Name) then 
                return v 
            end
        end
    end)
    return success and result or nil
end

local function pressEnter(btn)
    if not btn then return end
    pcall(function()
        Gui.SelectedCoreObject = btn
        task.wait(0.2) -- เพิ่มดีเลย์ให้ UI เซิร์ฟเวอร์รับรู้คำสั่งกด
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.2)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        task.wait(0.3)
        Gui.SelectedCoreObject = nil
    end)
end

local function firePrompt(prompt)
    if not prompt then return end
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        prompt:InputHoldBegin()
        task.wait(0.5)
        prompt:InputHoldEnd()
    end
end

local function tpVeh()
    local PlayerVehicle = findPlayerVehicle()
    if not PlayerVehicle then return end
    pcall(function()
        local vehicleData = GarageFolder:WaitForChild(PlayerVehicle.Name)
        local args = {
            vehicleData,
            Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 15)
        }
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("Vehicles"):WaitForChild("RemoteLoad"):InvokeServer(unpack(args))
    end)
end

local function removeAllPartsRaw(EngineBay)
    local vehicle = findPlayerVehicle()
    if not vehicle then return end
    pcall(function()
        for _, part in pairs(EngineBay:GetChildren()) do
            if vehicle:FindFirstChild("PartsEvent") then
                vehicle.PartsEvent:FireServer("RemovePart", part.Name)
                task.wait(REMOVE_DELAY)
            end
        end
    end)
    task.wait(POST_REMOVE_WAIT)
end

local function reinstallAllParts()
    local PlayerVehicle = findPlayerVehicle()
    if not PlayerVehicle then return end
    pcall(function()
        for _, v in pairs(MoveableParts:GetChildren()) do
            if v:GetAttribute("Owner") == Player.Name or not v:GetAttribute("Owner") then
                VehFolder:WaitForChild(PlayerVehicle.Name):WaitForChild("PartsEvent"):FireServer("ReapplyPart", v)
                task.wait(0.12)
            end
        end
    end)
end

local function waitForPartModel(partName, timeout)
    local elapsed, POLL = 0, 0.3
    while elapsed < timeout do
        local foundPart = nil
        pcall(function()
            for _, child in pairs(MoveableParts:GetChildren()) do
                if child.Name == partName and (child:GetAttribute("Owner") == Player.Name or not child:GetAttribute("Owner")) then
                    foundPart = child
                    break
                end
            end
        end)
        if foundPart then return foundPart end
        task.wait(POLL)
        elapsed = elapsed + POLL
    end
    return nil
end

local function buildMachineSlots(building)
    local slots = { GrindingMachine = {}, PartsWasher = {}, BatteryCharger = {} }
    pcall(function()
        for _, station in pairs(building:GetChildren()) do
            if station.Name:match("^Station%d+$") then
                for _, machine in pairs(station:GetChildren()) do
                    if slots[machine.Name] then
                        table.insert(slots[machine.Name], { station = station, model = machine })
                    end
                end
            end
        end
    end)
    return slots
end

local function resolveMachineIO(machine)
    local detector = machine:FindFirstChild("Detector")
    local cd       = machine:FindFirstChildWhichIsA("ClickDetector", true)
    if not cd then
        local btn = machine:FindFirstChild("Button")
        if btn then cd = btn:FindFirstChildWhichIsA("ClickDetector") end
    end
    if not cd then
        local faucet = machine:FindFirstChild("Faucet")
        if faucet then cd = faucet:FindFirstChildWhichIsA("ClickDetector") end
    end
    if not detector then detector = machine:FindFirstChildWhichIsA("BasePart") end
    return detector, cd
end

local function repairSinglePart(partModel, detector, clickDetector, safeBase, index)
    pcall(function()
        if partModel:IsA("Model") then partModel:PivotTo(detector.CFrame)
        else partModel.CFrame = detector.CFrame end
        task.wait(WARP_SETTLE)

        local elapsed, POLL = 0, 0.2
        while elapsed < 5 do
            local pos = partModel:IsA("Model") and partModel:GetPivot().Position or partModel.Position
            if (pos - detector.CFrame.Position).Magnitude < 4 then break end
            task.wait(POLL)
            elapsed = elapsed + POLL
        end

        if fireclickdetector then fireclickdetector(clickDetector) else clickDetector:FireClickDetector() end
        task.wait(REPAIR_WAIT)

        local safePos = CFrame.new(safeBase + Vector3.new(index * SAFE_OFFSET, 10, 0))
        if partModel:IsA("Model") then partModel:PivotTo(safePos)
        else partModel.CFrame = safePos end
        task.wait(0.3)
    end)
end

local function runSlot(slotInfo, partSubList, safeBase, slotIndex)
    local detector, cd = resolveMachineIO(slotInfo.model)
    if not detector or not cd then return end
    for i, partData in ipairs(partSubList) do
        local model = waitForPartModel(partData.Name, FIND_PART_TIMEOUT)
        if model then
            repairSinglePart(model, detector, cd, safeBase, slotIndex * 100 + i)
        end
    end
end

local function distributeToSlots(slots, queues)
    local assignments = {}
    for machineType, partList in pairs(queues) do
        local machineSlots = slots[machineType]
        if machineSlots and #machineSlots > 0 then
            local slotAssign = {}
            for _, slot in ipairs(machineSlots) do
                local entry = { slot = slot, parts = {} }
                table.insert(slotAssign, entry)
                table.insert(assignments, entry)
            end
            for i, partData in ipairs(partList) do
                local idx = ((i - 1) % #slotAssign) + 1
                table.insert(slotAssign[idx].parts, partData)
            end
        end
    end
    return assignments
end

-- ── ระบบรันหลักแบบปุ่มเดียวจบ ───────────────────────────────────────────────────

local function runFullAutoProcess(targetDisplayName, VehiclesInstances, ConfirmBtnPath)
    if not targetDisplayName then print("[PK-AUTO] กรุณาเลือกรถที่จะซื้อก่อนโบร!"); return end
    
    local targetVeh = VehiclesInstances[targetDisplayName]
    if not targetVeh or not targetVeh:IsDescendantOf(VehFolder) then
        print("[PK-AUTO] ไม่พบรถคันนี้ในสุสานรถแล้ว"); return
    end

    local vehName = targetVeh.Name

    -- [STEP 1]: วาร์ปไปซื้อรถจาก Junkyard (แก้บั๊กเพิ่มดีเลย์รอโหลดวัตถุ)
    print("[PK-AUTO] วาร์ปไปหารถ...")
    pcall(function()
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if root and targetVeh:FindFirstChild("Body") and targetVeh.Body:FindFirstChild("Plate") then
            root.CFrame = targetVeh.Body.Plate.CFrame
        else
            -- ถ้าไม่มีป้ายทะเบียน ให้วาร์ปไปจุดศูนย์กลางของโมเดลรถแทน
            local targetPart = targetVeh:FindFirstChildWhichIsA("BasePart", true)
            if root and targetPart then root.CFrame = targetPart.CFrame end
        end
    end)
    
    -- 🚨 จุดแก้ไขสำคัญ: หน่วงเวลารอให้ ClickDetector โหลดเข้าเครื่อง 100% กันกดวืด
    task.wait(1.2) 

    print("[PK-AUTO] กำลังคลิกซื้อรถและกดตกลง...")
    pcall(function()
        local cd = targetVeh:FindFirstChild("ClickDetector") or targetVeh:FindFirstChildWhichIsA("ClickDetector", true)
        if cd then
            if fireclickdetector then 
                fireclickdetector(cd) 
            else 
                cd:FireClickDetector() 
            end
        end
    end)
    
    task.wait(0.8) -- รอ UI ยืนยันเด้งขึ้นมา
    pressEnter(ConfirmBtnPath)

    -- รอนุมัติการซื้อรถเข้า Garage
    local bought = false
    for i = 1, 25 do
        task.wait(0.2)
        if not VehFolder:FindFirstChild(vehName) and GarageFolder:FindFirstChild(vehName) then
            bought = true; break
        end
    end
    if not bought then print("[PK-AUTO] การซื้อรถล้มเหลวหรือช้าเกินไป (ลองกดใหม่อีกรอบโบร)"); return end
    print("[PK-AUTO] ซื้อรถสำเร็จ! สตาร์ทระบบซ่อมต่อทันที...")

    -- [STEP 2]: วาร์ปไปอู่ใหญ่ ยกรถมาถอดพาร์ท
    pcall(function()
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(-1076, 5, -414)
    end)
    task.wait(0.5)
    
    local vehicle = findPlayerVehicle()
    if not vehicle then 
        print("[PK-AUTO] กำลังเสกรถออกมาซ่อม...")
        tpVeh()
        task.wait(2)
        vehicle = findPlayerVehicle()
    end
    
    if not vehicle then print("[PK-AUTO] เกิดข้อผิดพลาด หาตัวรถไม่เจอ"); return end

    local building  = Workspace.Map.FirstCity.Buildings["PitStop(Large)"]
    local EngineBay = vehicle.BodCOMBINEDrChild("EngineBay", 5)
    local charRoot  = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local safeBase  = charRoot and charRoot.Position or Vector3.new(0, 100, 0)
    local slots     = buildMachineSlots(building)

    print("[PK-AUTO] กำลังถอดชิ้นส่วนรถ...")
    removeAllPartsRaw(EngineBay)

    -- จัดคิวพาร์ทเข้าเครื่องซ่อม
    local queues = { GrindingMachine = {}, PartsWasher = {}, BatteryCharger = {} }
    local total  = 0
    for _, child in pairs(MoveableParts:GetChildren()) do
        if child:GetAttribute("Owner") == Player.Name or not child:GetAttribute("Owner") then
            local rType = child:GetAttribute("RepairMachine")
            if rType and queues[rType] then
                table.insert(queues[rType], { Name = child.Name })
                total = total + 1
            end
        end
    end
    
    -- [STEP 3]: เริ่มซ่อมพาร์ททั้งหมดแบบคู่ขนาน (Parallel)
    if total > 0 then
        print("[PK-AUTO] กำลังซ่อมชิ้นส่วนจำนวน " .. total .. " ชิ้นพร้อมกัน...")
        local assignments     = distributeToSlots(slots, queues)
        local doneCount       = 0
        local totalAssign     = #assignments
        
        for idx, assign in ipairs(assignments) do
            if #assign.parts > 0 then
                task.spawn(function()
                    pcall(function() runSlot(assign.slot, assign.parts, safeBase, idx) end)
                    doneCount = doneCount + 1
                end)
            else
                doneCount = doneCount + 1
            end
        end
        while doneCount < totalAssign do task.wait(0.5) end
    end

    -- [STEP 4]: ประกอบชิ้นส่วนคืนร่างรถ
    print("[PK-AUTO] กำลังประกอบพาร์ทคืนร่างรถ...")
    task.wait(1)
    reinstallAllParts()
    task.wait(1)
    reinstallAllParts()

    -- [STEP 5]: วาร์ปพ่นสีรถ
    print("[PK-AUTO] กำลังนำรถไปพ่นสีเพิ่มมูลค่า...")
    pcall(function()
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(-990.619568, 4.53032351, -387.379364, 0.35, 0, -0.93, 0, 1, 0, 0.93, 0, 0.35)
        tpVeh()
    end)
    task.wait(2)
    pcall(function()
        local model = Workspace.Map.FirstCity.Buildings["PitStop(Large)"].Model
        local children = model:GetChildren()
        firePrompt(children[4].Prompt.ProximityPrompt)
        task.wait(0.5)
        pressEnter(Player.PlayerGui.HUD.Frames.Paint.Confirm)
    end)
    task.wait(1)

    -- [STEP 6]: วาร์ปไปเต็นท์รถเพื่อกดขายกินตังค์ชิลๆ
    print("[PK-AUTO] วาร์ปไปจุดขาย... กำลังรับเงินโบร!")
    pcall(function()
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(-1915, 4, -785)
        tpVeh()
    end)
    task.wait(1)
    pcall(function()
        firePrompt(workspace.Utils.SellCar.Prompt.ProximityPrompt)
        task.wait(0.5)
        pressEnter(ConfirmBtnPath)
    end)
    print("[PK-AUTO] 💸 เสร็จสิ้นกระบวนการฟาร์มปุ่มเดียว! บอทรับเงินเรียบร้อย")
end

-- ── Wind UI Setup ─────────────────────────────────────────────────────────────

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title  = "PK GOD-MODE V3",
    Icon   = "bot",
    Author = "PK Modified",
    Folder = "PK_OneClick_Hub_V3",
    Size   = UDim2.fromOffset(580, 460),
    Theme  = "Dark",
})

local MainTab = Window:Tab({ Title = "One-Click Farm", Icon = "zap" })
local VehiclesInstances = {}
local Vehicles = {}

local function scanVehiclesLocal()
    table.clear(Vehicles)
    table.clear(VehiclesInstances)
    pcall(function()
        for _, Veh in pairs(VehFolder:GetChildren()) do
            if Veh:GetAttribute("Junkyard") and not Veh:GetAttribute("ExclusivePrice") then
                local brand = Veh:GetAttribute("Brand") or "Unknown"
                local modelName = Veh:GetAttribute("Model") or "Car"
                
                -- รวมชื่อยี่ห้อและรุ่นเข้าด้วยกันเพื่อให้มนุษย์อ่านรู้เรื่อง (เช่น "Honda CivicEF")
                local displayName = "[" .. brand .. "] " .. modelName
                
                if modelName then
                    table.insert(Vehicles, displayName)
                    VehiclesInstances[displayName] = Veh
                end
            end
        end
    end)
end

scanVehiclesLocal()
local SelectedVehicle = nil

local Dropdown = MainTab:Dropdown({
    Title    = "1. เลือกรถที่จะซื้อ (แสดงยี่ห้อ+รุ่นแล้วโบร)",
    Values   = Vehicles,
    Callback = function(selected)
        SelectedVehicle = selected
    end
})

MainTab:Button({
    Title    = "🔄 รีเฟรชรายชื่อรถในสุสาน",
    Icon     = "refresh-ccw",
    Callback = function()
        scanVehiclesLocal()
        Dropdown:Refresh(Vehicles)
        SelectedVehicle = nil
    end
})

-- ปุ่มเริ่มระบบแบบออโต้สมบูรณ์แบบ
MainTab:Button({
    Title    = "🚀 START ALL PROCESS (FULL AUTO)",
    Icon     = "play",
    Callback = function()
        task.spawn(function()
            runFullAutoProcess(SelectedVehicle, VehiclesInstances, ConfirmBtnPath)
        end)
    end
})

print("[PK One-Click Hub V3] ปรับปรุงชื่อรถและระบบซื้อเรียบร้อยไอ่สัส!")
