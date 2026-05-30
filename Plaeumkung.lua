local Players             = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Gui                 = game:GetService("GuiService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local Workspace           = game:GetService("Workspace")

local Player        = Players.LocalPlayer
local VehFolder     = Workspace.Vehicles
local GarageFolder  = Player:WaitForChild("PlayerData"):WaitForChild("Garage")
local MoveableParts = Workspace:WaitForChild("MoveableParts")

local REPAIR_WAIT       = 18
local REMOVE_DELAY      = 0.15
local POST_REMOVE_WAIT  = 2
local WARP_SETTLE       = 1.5
local SAFE_OFFSET       = 15
local FIND_PART_TIMEOUT = 15

-- ── Shared ────────────────────────────────────────────────────────────────────

local function findPlayerVehicle()
    for _, v in pairs(VehFolder:GetChildren()) do
        if v:GetAttribute("Owner") == Player.Name then return v end
    end
    return nil
end

-- ── Junkyard ──────────────────────────────────────────────────────────────────

local Vehicles          = {}
local VehiclesInstances = {}
local ConfirmBtnPath    = Player:WaitForChild("PlayerGui").HUD.Frames.Confirmation.Confirm

local function scanVehicles()
    table.clear(Vehicles)
    table.clear(VehiclesInstances)
    for _, Veh in pairs(VehFolder:GetChildren()) do
        if Veh:GetAttribute("Junkyard") and not Veh:GetAttribute("ExclusivePrice") then
            local modelName = Veh:GetAttribute("Model")
            if modelName then
                table.insert(Vehicles, modelName)
                VehiclesInstances[modelName] = Veh
            end
        end
    end
end

local function pressEnter(btn)
    Gui.SelectedCoreObject = btn
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.5)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    task.wait(0.1)
    Gui.SelectedCoreObject = nil
end

-- ── Repair ────────────────────────────────────────────────────────────────────

local function waitForPartModel(partName, timeout)
    local elapsed, POLL = 0, 0.3
    while elapsed < timeout do
        for _, child in pairs(MoveableParts:GetChildren()) do
            if child.Name == partName and child:GetAttribute("Owner") == Player.Name then
                return child
            end
        end
        task.wait(POLL)
        elapsed = elapsed + POLL
    end
    warn(("[waitForPartModel] Timed out waiting for '%s' (%ds)"):format(partName, timeout))
    return nil
end

local function buildMachineSlots(building)
    local slots = { GrindingMachine = {}, PartsWasher = {}, BatteryCharger = {} }
    for _, station in pairs(building:GetChildren()) do
        if station.Name:match("^Station%d+$") then
            for _, machine in pairs(station:GetChildren()) do
                if slots[machine.Name] then
                    table.insert(slots[machine.Name], { station = station, model = machine })
                end
            end
        end
    end
    for mtype, list in pairs(slots) do
        print(("[Slots] %s -> %d machine(s)"):format(mtype, #list))
    end
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
    if partModel:IsA("Model") then partModel:PivotTo(detector.CFrame)
    else partModel.CFrame = detector.CFrame end

    task.wait(WARP_SETTLE)

    local elapsed, POLL = 0, 0.2
    while elapsed < 10 do
        local pos = partModel:IsA("Model") and partModel:GetPivot().Position or partModel.Position
        if (pos - detector.CFrame.Position).Magnitude < 3 then break end
        task.wait(POLL)
        elapsed = elapsed + POLL
    end

    fireclickdetector(clickDetector)
    print(("  [Repair] %s -> %s / %s"):format(
        partModel.Name, detector.Parent.Parent.Name, detector.Parent.Name))

    task.wait(REPAIR_WAIT)

    local safePos = CFrame.new(safeBase + Vector3.new(index * SAFE_OFFSET, 0, 0))
    if partModel:IsA("Model") then partModel:PivotTo(safePos)
    else partModel.CFrame = safePos end
    task.wait(0.3)
end

local function runSlot(slotInfo, partSubList, safeBase, slotIndex)
    local detector, cd = resolveMachineIO(slotInfo.model)
    if not detector or not cd then
        warn(("[Slot] %s / %s : could not resolve IO"):format(
            slotInfo.station.Name, slotInfo.model.Name))
        return
    end
    for i, partData in ipairs(partSubList) do
        local model = waitForPartModel(partData.Name, FIND_PART_TIMEOUT)
        if model then
            repairSinglePart(model, detector, cd, safeBase, slotIndex * 100 + i)
            print(("  [%s / %s] %d / %d done: %s"):format(
                slotInfo.station.Name, slotInfo.model.Name, i, #partSubList, partData.Name))
        else
            warn(("  Skipping '%s' (timeout)"):format(partData.Name))
        end
    end
    print(("[Slot] %s / %s complete"):format(slotInfo.station.Name, slotInfo.model.Name))
end

local function distributeToSlots(slots, queues)
    local assignments = {}
    for machineType, partList in pairs(queues) do
        local machineSlots = slots[machineType]
        if not machineSlots or #machineSlots == 0 then
            warn(("No slots available for '%s'"):format(machineType))
        else
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

local function removeAllPartsRaw(EngineBay)
    local vehicle = findPlayerVehicle()
    if not vehicle then return end
    for _, part in pairs(EngineBay:GetChildren()) do
        if vehicle:FindFirstChild("PartsEvent") then
            vehicle.PartsEvent:FireServer("RemovePart", part.Name)
            print("  Removed: " .. part.Name)
            task.wait(REMOVE_DELAY)
        end
    end
    task.wait(POST_REMOVE_WAIT)
end

local function reinstallAllParts()
    print("[Reinstall] Installing parts back into vehicle...")
    local PlayerVehicle = findPlayerVehicle()
    if not PlayerVehicle then warn("[Reinstall] No vehicle found."); return end

    local partsFound = 0
    for _, v in pairs(MoveableParts:GetChildren()) do
        if v:GetAttribute("Owner") == Player.Name then
            VehFolder
                :WaitForChild(PlayerVehicle.Name)
                :WaitForChild("PartsEvent")
                :FireServer("ReapplyPart", v)
            print("  Installed: " .. v.Name)
            partsFound = partsFound + 1
            task.wait(0.1)
        end
    end
    if partsFound == 0 then
        print("[Reinstall] No parts found in MoveableParts.")
    else
        print(("[Reinstall] %d part(s) installed successfully."):format(partsFound))
    end
end

-- ── Vehicle ───────────────────────────────────────────────────────────────────

local function tpVeh()
    local PlayerVehicle = findPlayerVehicle()
    if not PlayerVehicle then
        warn("[SpawnVehicle] No active vehicle found.")
        return
    end
    local vehicleData = GarageFolder:WaitForChild(PlayerVehicle.Name)
    local args = {
        vehicleData,
        Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 15)
    }
    ReplicatedStorage
        :WaitForChild("Events")
        :WaitForChild("Vehicles")
        :WaitForChild("RemoteLoad")
        :InvokeServer(unpack(args))
    print("[SpawnVehicle] Request sent.")
end

-- ── Wind UI ───────────────────────────────────────────────────────────────────

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title  = "Combined Hub",
    Icon   = "wrench",
    Author = "Auto Script",
    Folder = "CombinedHub",
    Size   = UDim2.fromOffset(580, 460),
    Theme  = "Dark",
})

-- ── Tab: Junkyard ─────────────────────────────────────────────────────────────

local JunkTab = Window:Tab({ Title = "Junkyard", Icon = "car" })

scanVehicles()

local SelectedVehicle = nil

local Dropdown = JunkTab:Dropdown({
    Title    = "Select Vehicle",
    Values   = Vehicles,
    Callback = function(selected)
        SelectedVehicle = selected
        print("[Junkyard] Selected: " .. selected)
    end
})

JunkTab:Button({
    Title    = "Refresh List",
    Icon     = "refresh-ccw",
    Callback = function()
        scanVehicles()
        Dropdown:Refresh(Vehicles)
        SelectedVehicle = nil
        print("[Junkyard] List refreshed. Found " .. #Vehicles .. " vehicle(s).")
    end
})

JunkTab:Button({
    Title    = "Teleport to Vehicle",
    Icon     = "arrow-up-right",
    Callback = function()
        if not SelectedVehicle then print("[Junkyard] No vehicle selected."); return end
        local targetVeh = VehiclesInstances[SelectedVehicle]
        if targetVeh and targetVeh:FindFirstChild("Body") and targetVeh.Body:FindFirstChild("Plate") then
            local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = targetVeh.Body.Plate.CFrame
                print("[Junkyard] Teleported to: " .. SelectedVehicle)
            end
        else
            print("[Junkyard] Vehicle no longer available.")
        end
    end
})

JunkTab:Button({
    Title    = "Purchase Vehicle",
    Icon     = "shopping-cart",
    Callback = function()
        if not SelectedVehicle then print("[Junkyard] No vehicle selected."); return end
        local targetVeh = VehiclesInstances[SelectedVehicle]
        if not targetVeh or not targetVeh:IsDescendantOf(VehFolder) then
            print("[Junkyard] Vehicle is no longer in the junkyard."); return
        end

        local vehName = targetVeh.Name
        local root    = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if root and targetVeh:FindFirstChild("Body") and targetVeh.Body:FindFirstChild("Plate") then
            root.CFrame = targetVeh.Body.Plate.CFrame
        end
        task.wait(0.4)

        if targetVeh:FindFirstChild("ClickDetector") then
            fireclickdetector(targetVeh.ClickDetector)
        end
        task.wait(0.4)
        pressEnter(ConfirmBtnPath)

        local success, elapsed = false, 0
        repeat
            task.wait(0.1)
            elapsed = elapsed + 0.1
            if not VehFolder:FindFirstChild(vehName) and GarageFolder:FindFirstChild(vehName) then
                success = true; break
            end
        until elapsed > 4

        if success then
            print("[Junkyard] Purchase successful: " .. SelectedVehicle)
            scanVehicles(); Dropdown:Refresh(Vehicles); SelectedVehicle = nil
        else
            print("[Junkyard] Purchase failed or timed out.")
        end
    end
})

-- ── Tab: Repair ───────────────────────────────────────────────────────────────

local Automatically = Window:Tab({ Title = "Automatically", Icon = "bot" })

Automatically:Button({
    Title    = "Auto Repair",
    Icon     = "settings",
    Callback = function()
        task.spawn(function()
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(-1076, 5, -414)
            local vehicle = findPlayerVehicle()
            if not vehicle then warn("[Repair] No vehicle found."); return end

            local building  = Workspace.Map.FirstCity.Buildings["PitStop(Large)"]
            local EngineBay = vehicle.Body.EngineBay
            local charRoot  = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            local safeBase  = charRoot and charRoot.Position or Vector3.new(0, 100, 0)
            local slots     = buildMachineSlots(building)

            print("[Repair] Step 1: Removing all parts...")
            removeAllPartsRaw(EngineBay)

            local queues = { GrindingMachine = {}, PartsWasher = {}, BatteryCharger = {} }
            local total  = 0
            for _, child in pairs(MoveableParts:GetChildren()) do
                if child:GetAttribute("Owner") == Player.Name then
                    local rType = child:GetAttribute("RepairMachine")
                    if rType and queues[rType] then
                        table.insert(queues[rType], { Name = child.Name })
                        total = total + 1
                    end
                end
            end
            if total == 0 then warn("[Repair] No parts found."); return end

            print("[Repair] Step 2: Repairing " .. total .. " part(s) in parallel...")
            local assignments     = distributeToSlots(slots, queues)
            local doneCount       = 0
            local totalAssign     = #assignments
            for idx, assign in ipairs(assignments) do
                if #assign.parts > 0 then
                    task.spawn(function()
                        runSlot(assign.slot, assign.parts, safeBase, idx)
                        doneCount = doneCount + 1
                    end)
                else
                    doneCount = doneCount + 1
                end
            end
            while doneCount < totalAssign do task.wait(0.5) end

            print("[Repair] Step 3: Reinstalling parts...")
            reinstallAllParts()
            reinstallAllParts()
            print("[Repair] Complete.")
        end)
    end
})

Automatically:Button({
    Title    = "Auto Paint",
    Icon     = "paintbrush",
    Callback = function()
        task.spawn(function()
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(
                -990.619568, 4.53032351, -387.379364,
                 0.350393713, -8.45001722e-08, -0.936602473,
                -4.68328265e-09, 1, -9.19719554e-08,
                 0.936602473, 3.66127715e-08, 0.350393713
            )
            tpVeh()
            task.wait(2)

            local model    = Workspace.Map.FirstCity.Buildings["PitStop(Large)"].Model
            local children = model:GetChildren()
            fireproximityprompt(children[4].Prompt.ProximityPrompt)
            task.wait(0.5) 
            pressEnter(Player.PlayerGui.HUD.Frames.Paint.Confirm)
        end)
    end
})
Automatically:Button({
    Title    = "Sell Vehicle",
    Icon     = "dollar-sign",
    Callback = function()
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(-1915, 4, -785)
        tpVeh()
        task.wait(0.4)
        fireproximityprompt(workspace.Utils.SellCar.Prompt.ProximityPrompt)
        task.wait(0.4)
        pressEnter(ConfirmBtnPath)
        task.wait(0.5)
        Gui.SelectedCoreObject = nil
    end
})

-- ── Tab: Vehicle ──────────────────────────────────────────────────────────────

local VehTab = Window:Tab({ Title = "Vehicle", Icon = "box" })

VehTab:Button({
    Title    = "Spawn Vehicle",
    Icon     = "refresh-cw",
    Callback = function()
        task.spawn(tpVeh)
    end
})

VehTab:Button({
    Title    = "Teleport to Vehicle",
    Icon     = "map-pin",
    Callback = function()
        local v = findPlayerVehicle()
        if not v then print("[Vehicle] No active vehicle found."); return end
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if root and v:FindFirstChild("Body") and v.Body:FindFirstChild("Plate") then
            root.CFrame = v.Body.Plate.CFrame
            print("[Vehicle] Teleported to: " .. v.Name)
        end
    end
})

VehTab:Button({
    Title    = "Install Parts",
    Icon     = "arrow-down-to-line",
    Callback = function()
        task.spawn(reinstallAllParts)
        task.spawn(reinstallAllParts)
    end
})

print("[Combined Hub] Loaded successfully.")
