local Players             = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Gui                 = game:GetService("GuiService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local Workspace           = game:GetService("Workspace")
local RunService          = game:GetService("RunService")
local VIM                 = game:GetService("VirtualInputManager")

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

local scriptLoopId = 0
local targetEndTime = 0
local countdownConnection = nil

local function findPlayerVehicle()
    for _, v in pairs(VehFolder:GetChildren()) do
        if v:GetAttribute("Owner") == Player.Name then return v end
    end
    return nil
end

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
                local spawnChance = Veh:GetAttribute("SpawnChance") or "?"
                local priceRaw    = Veh:GetAttribute("Price")
                local priceStr
                if typeof(priceRaw) == "Vector2" then
                    priceStr = ("%d-%d"):format(priceRaw.X, priceRaw.Y)
                else
                    priceStr = tostring(priceRaw or "?")
                end
                local label = ("[SC:%s] [$ %s]"):format(tostring(spawnChance), priceStr)
                table.insert(Vehicles, label)
                VehiclesInstances[label] = Veh
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

local function jumpCharacter()
    local char = Player.Character
    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
    if hum then
        hum:ChangeState("Jumping")
    end
end

local function findNearestPrompt(modelFolder)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, child in pairs(modelFolder:GetChildren()) do
        local promptPart = child:FindFirstChild("Prompt")
        if promptPart then
             local pp = promptPart:FindFirstChildWhichIsA("ProximityPrompt")
            if pp then
                local ok, pos = pcall(function() return child:GetPivot().Position end)
                if not ok then
                    local bp = child:FindFirstChildWhichIsA("BasePart")
                     if bp then ok = true; pos = bp.Position end
                end
                if ok then
                    local dist = (pos - root.Position).Magnitude
                    if dist < nearestDist then
                         nearestDist = dist
                        nearest = pp
                    end
                end
            end
        end
    end
     return nearest
end

-- [[ UI Setup ]]
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title  = "Garage Manager",
    Icon   = "wrench",
    Author = "Auto Script",
    Folder = "GarageManager",
    Size   = UDim2.fromOffset(580, 460),
    Theme  = "Dark",
})

-- [[ Junkyard Tab ]]
local JunkTab = Window:Tab({ Title = "Junkyard", Icon = "car" })

scanVehicles()

local SelectedVehicle = nil

local Dropdown = JunkTab:Dropdown({
    Title    = "Available Vehicles",
    Values   = Vehicles,
    Callback = function(selected)
         SelectedVehicle = selected
        print("[Junkyard] Selected: " .. selected)
    end
})

JunkTab:Button({
    Title    = "Refresh Listings",
    Icon     = "refresh-ccw",
    Callback = function()
        scanVehicles()
        Dropdown:Refresh(Vehicles)
        SelectedVehicle = nil
        print("[Junkyard] List refreshed. Found " .. #Vehicles .. " vehicle(s).")
    end
})

JunkTab:Button({
    Title    = "Inspect Vehicle",
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
            print("[Junkyard] Vehicle is no longer available."); return
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

-- [[ Automation Tab ]]
local Automatically = Window:Tab({ Title = "Automation", Icon = "bot" })

_G.autoLoopRunning = false
_G.WaitAfterPaint  = 150
_G.minSpawnChance  = 50
_G.autoDriveRunning = false

Automatically:Slider({
    Title = "Max Spawn Chance Filter",
    Step  = 1,
    Value = { Min = 1, Max = 100, Default = 50 },
    Callback = function(val)
         _G.minSpawnChance = val
        print("[AutoLoop] Spawn chance filter set to: " .. val)
    end
})

local lastSliderVal = 150

local HoldSlider = Automatically:Slider({
    Title = "Hold Duration Before Sale (s)",
    Desc  = "Duration: 150s",
    Step  = 1,
    Value = { Min = 1, Max = 200, Default = 150 },
    Callback = function(val)
        local diff = val - lastSliderVal
         _G.WaitAfterPaint = val
        lastSliderVal = val
        
        if _G.autoLoopRunning and targetEndTime > 0 then
            targetEndTime = targetEndTime + diff
        else
            HoldSlider:SetDesc(("Duration: %ds"):format(val))
        end
    end
})

Automatically:Toggle({
    Title    = "Auto Farm  —  Acquire · Restore · Paint · Sell",
    Icon     = "repeat",
    Default  = false,
    Callback = function(state)
        _G.autoLoopRunning = state
        if not state then
            if countdownConnection then countdownConnection:Disconnect(); countdownConnection = nil end
            targetEndTime = 0
            HoldSlider:SetDesc(("Duration: %ds"):format(_G.WaitAfterPaint or 150))
            print("[AutoLoop] Stopped instantly by user.")
            return
        end

        scriptLoopId = scriptLoopId + 1
        local currentId = scriptLoopId

        print("[AutoLoop] Started.")
        task.spawn(function()
            while _G.autoLoopRunning and scriptLoopId == currentId do
                
                local sessionVehicles = {} 
                
                local startupVeh = findPlayerVehicle()
                 if startupVeh then
                    pcall(function()
                        ReplicatedStorage.Events.Vehicles.RemoteStore:InvokeServer(GarageFolder:WaitForChild(startupVeh.Name))
                    end)
                    task.wait(1)
                 end

                while _G.autoLoopRunning and scriptLoopId == currentId do
                    local totalActiveOwned = #GarageFolder:GetChildren()
                    if totalActiveOwned >=  3 then break end
                     
                    scanVehicles()
                    local targetLabel, targetVeh = nil, nil
                    for label, veh in pairs(VehiclesInstances) do
                         local sc = veh:GetAttribute("SpawnChance") or 0
                        if sc <= _G.minSpawnChance then
                            targetLabel = label
                             targetVeh   = veh
                            break
                        end
                    end

                     if not targetVeh then
                        task.wait(4)
                        continue 
                     end

                    local vehName = targetVeh.Name
                    local root    = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                    if root and targetVeh:FindFirstChild("Body") and targetVeh.Body:FindFirstChild("Plate") then
                         root.CFrame = targetVeh.Body.Plate.CFrame
                    end
                    task.wait(0.6)

                    if targetVeh:FindFirstChild("ClickDetector") then
                        fireclickdetector(targetVeh.ClickDetector)
                     end
                    task.wait(0.6)

                    local playerGui = Player:FindFirstChild("PlayerGui")
                    local confirmBtn = playerGui and playerGui:FindFirstChild("HUD") 
                         and playerGui.HUD:FindFirstChild("Frames") 
                        and playerGui.HUD.Frames:FindFirstChild("Confirmation") 
                        and playerGui.HUD.Frames.Confirmation:FindFirstChild("Confirm")

                    if confirmBtn and confirmBtn:IsDescendantOf(playerGui) then
                        pressEnter(confirmBtn)
                    else
                        task.wait(1)
                         continue
                    end

                    local bought, elapsed = false, 0
                    repeat
                        task.wait(0.2)
                         elapsed = elapsed + 0.2
                        if GarageFolder:FindFirstChild(vehName) then
                            bought = true
                             break
                        end
                    until elapsed > 4 or not _G.autoLoopRunning

                    if bought then
                        task.wait(1.5)
                        pcall(function()
                             local charRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                            if charRoot then
                                charRoot.CFrame = CFrame.new(-1076, 5, -414)
                            end
                        end)
                        task.wait(1)
                     end
                end

                table.clear(sessionVehicles)
                for _, child in pairs(GarageFolder:GetChildren()) do
                    if #sessionVehicles < 3 then
                         table.insert(sessionVehicles, child.Name)
                    end
                end

                if _G.autoLoopRunning and scriptLoopId == currentId and #sessionVehicles > 0 then
                     for carIndex, vehName in ipairs(sessionVehicles) do
                        if not _G.autoLoopRunning or scriptLoopId ~= currentId then break end

                        local oldVehicle =  findPlayerVehicle()
                        if oldVehicle then
                            pcall(function()
                                 ReplicatedStorage.Events.Vehicles.RemoteStore:InvokeServer(GarageFolder:WaitForChild(oldVehicle.Name))
                            end)
                            task.wait(1.5)
                         end

                        Player.Character.HumanoidRootPart.CFrame = CFrame.new(-1076, 5, -414)
                        task.wait(0.5)
                        
                         local spawnArgs = { GarageFolder:WaitForChild(vehName), Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 15) }
                        ReplicatedStorage.Events.Vehicles.RemoteLoad:InvokeServer(unpack(spawnArgs))
                        task.wait(2)

                        local vehicle = findPlayerVehicle()
                         if vehicle then
                            local building  = Workspace.Map.FirstCity.Buildings["PitStop(Large)"]
                            local EngineBay = vehicle.Body.EngineBay
                             local charRoot  = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                            local safeBase  = charRoot and charRoot.Position or Vector3.new(0, 100, 0)
                            local slots     = buildMachineSlots(building)

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

                            if total > 0 and _G.autoLoopRunning and scriptLoopId == currentId then
                                local assignments             = distributeToSlots(slots, queues)
                                local doneCount, totalAssign = 0, #assignments
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
                                while doneCount < totalAssign and _G.autoLoopRunning and scriptLoopId == currentId do task.wait(0.5) end
                             end

                            if not _G.autoLoopRunning or scriptLoopId ~= currentId then break end
                            reinstallAllParts()
                             task.wait(0.5)
                            reinstallAllParts()
                        end

                        task.wait(1)

                        Player.Character.HumanoidRootPart.CFrame = CFrame.new(
                            -990.619568, 4.53032351, -387.379364,
                             0.350393713, -8.45001722e-08, -0.936602473,
                             -4.68328265e-09, 1, -9.19719554e-08,
                             0.936602473, 3.66127715e-08, 0.350393713
                        )
                        task.wait(0.5)
                         
                        local paintSpawnArgs = { GarageFolder:WaitForChild(vehName), Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 15) }
                        ReplicatedStorage.Events.Vehicles.RemoteLoad:InvokeServer(unpack(paintSpawnArgs))
                         task.wait(2)

                        local model       = Workspace.Map.FirstCity.Buildings["PitStop(Large)"].Model
                        local paintPrompt = findNearestPrompt(model)
                        if paintPrompt then
                             fireproximityprompt(paintPrompt)
                        end
                        task.wait(0.5)
                        
                         local paintConfirm = Player.PlayerGui:FindFirstChild("HUD") and Player.PlayerGui.HUD.Frames.Paint.Confirm
                        if paintConfirm then pressEnter(paintConfirm) end
                         task.wait(2)
                    end
                end

                 if _G.autoLoopRunning and scriptLoopId == currentId and #sessionVehicles > 0 then
                    targetEndTime = os.clock() + _G.WaitAfterPaint
                    local isWaiting = true
                    local lastSecText = -1
                    
                     if countdownConnection then countdownConnection:Disconnect() end
                    
                    countdownConnection = RunService.RenderStepped:Connect(function()
                        if not _G.autoLoopRunning or scriptLoopId ~= currentId then
                             isWaiting = false
                            if countdownConnection then countdownConnection:Disconnect(); countdownConnection = nil end
                            return
                         end
                        
                        local now = os.clock()
                        local remainingFloat = targetEndTime - now
                         local remainingInt = math.ceil(remainingFloat)
                        
                        if remainingFloat <= 0 then
                            isWaiting = false
                             if countdownConnection then countdownConnection:Disconnect(); countdownConnection = nil end
                            return
                        end
                        
                       if remainingInt ~= lastSecText then
                            HoldSlider:SetDesc(("⏳ Remaining: %ds / %ds"):format(remainingInt, _G.WaitAfterPaint))
                            lastSecText = remainingInt
                        end
                     end)
                    
                    while isWaiting do task.wait() end
                    targetEndTime = 0
                    HoldSlider:SetDesc(("Duration: %ds"):format(_G.WaitAfterPaint))

                    for i = #sessionVehicles, 1, -1 do
                        if not _G.autoLoopRunning or scriptLoopId ~= currentId then break end
                        local targetVehName = sessionVehicles[i]
                        local activeVeh = findPlayerVehicle()
                         if activeVeh then
                            pcall(function()
                                ReplicatedStorage.Events.Vehicles.RemoteStore:InvokeServer(GarageFolder:WaitForChild(activeVeh.Name))
                            end)
                             task.wait(1)
                        end

                        Player.Character.HumanoidRootPart.CFrame = CFrame.new(-1915, 4, -785)
                         task.wait(0.5)

                        local sellSpawnArgs = { GarageFolder:WaitForChild(targetVehName), Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 15) }
                        local spawnSuccess = pcall(function()
                            ReplicatedStorage.Events.Vehicles.RemoteLoad:InvokeServer(unpack(sellSpawnArgs))
                         end)
                        
                        if spawnSuccess then
                            task.wait(1.5)
                             fireproximityprompt(workspace.Utils.SellCar.Prompt.ProximityPrompt)
                            task.wait(0.8)
                            
                             local sellConfirm = Player.PlayerGui:FindFirstChild("HUD") and Player.PlayerGui.HUD.Frames.Confirmation.Confirm
                            if sellConfirm then pressEnter(sellConfirm) end
                            task.wait(0.5)
                            Gui.SelectedCoreObject =  nil

                            local sellCheck, sellElapsed = false, 0
                            repeat
                                task.wait(0.2)
                                 sellElapsed = sellElapsed + 0.2
                                if not findPlayerVehicle() then
                                     sellCheck = true
                                    break
                                end
                            until sellElapsed  > 5 or not _G.autoLoopRunning or scriptLoopId ~= currentId
                            task.wait(1.5)
                         end
                    end
                end
                task.wait(2)
            end

            if countdownConnection then countdownConnection:Disconnect(); countdownConnection = nil end
            HoldSlider:SetDesc(("Duration: %ds"):format(_G.WaitAfterPaint or 150))
         end)
    end
})

Automatically:Divider()

_G.autoBuyRunning  = false
_G.targetPercentage = 5

local Input = Automatically:Input({
    Title       = "Input Percentage",
    Desc        = "",
    Value       = "5",
    InputIcon   = "car",
    Type        = "Input",
    Placeholder = "Enter percentage...",
    Callback    = function(input)
        local num = tonumber(input)
         _G.targetPercentage = (num and num > 0) and num or 5
    end
})

Automatically:Toggle({
    Title    = "Auto Purchase 5%+ Spawn Chance Vehicles",
    Icon     = "repeat",
    Default  = false,
    Callback = function(state)
        _G.autoBuyRunning = state
        if not state then return end

        task.spawn(function()
            while _G.autoBuyRunning do
                scanVehicles()
                local candidates = {}
               
                for label, veh in pairs(VehiclesInstances) do
                 local sc = veh:GetAttribute("SpawnChance") or math.huge
                    if sc <= (_G.targetPercentage or 5) then
                        table.insert(candidates, { label = label, veh = veh })
                    end
              end

                if #candidates == 0 then
                    task.wait(0.15)
                    continue
                end

                 local targetLabel, targetVeh = nil, nil
                for _, c in ipairs(candidates) do
                    local ok, alive = pcall(function()
                        return c.veh:IsDescendantOf(VehFolder)
                    end)
                     if ok and alive then
                        targetLabel = c.label
                        targetVeh   = c.veh
                         break
                    end
                end

                if not targetVeh then
                    task.wait(0.15)
                    continue
              end

                local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                local plateOk = pcall(function()
                    if root and targetVeh:FindFirstChild("Body") and targetVeh.Body:FindFirstChild("Plate") then
                         root.CFrame = targetVeh.Body.Plate.CFrame
                    end
                end)
                if not plateOk then
                    task.wait(0.5)
                    continue
                end
                task.wait(0.2)

                local cdOk = pcall(function()
                     if targetVeh:FindFirstChild("ClickDetector") then
                        fireclickdetector(targetVeh.ClickDetector)
                    end
                end)
                if not cdOk then
                    task.wait(0.5)
                    continue
                end
                task.wait(0.25)

                 local playerGui = Player:FindFirstChild("PlayerGui")
                local confirmBtn

                local uiWait, uiElapsed = false, 0
                repeat
                    task.wait(0.1)
                     uiElapsed = uiElapsed + 0.1
                    local ok, result = pcall(function()
                        local btn = playerGui
                            and playerGui:FindFirstChild("HUD")
                             and playerGui.HUD:FindFirstChild("Frames")
                            and playerGui.HUD.Frames:FindFirstChild("Confirmation")
                            and playerGui.HUD.Frames.Confirmation:FindFirstChild("Confirm")
                         return btn and btn:IsDescendantOf(playerGui) and btn
                    end)
                    if ok and result then
                        confirmBtn = result
                         uiWait     = true
                    end
                until uiWait or uiElapsed > 2

                if not confirmBtn then
                    task.wait(0.5)
                    continue
                end

                pressEnter(confirmBtn)

                local vehName         = targetVeh.Name
                 local bought, elapsed = false, 0
                repeat
                    task.wait(0.1)
                    elapsed = elapsed + 0.1
                     local owned = pcall(function()
                        return GarageFolder:FindFirstChild(vehName) ~= nil or findPlayerVehicle() ~= nil
                    end)
                    if owned then
                         if GarageFolder:FindFirstChild(vehName) or findPlayerVehicle() then
                            bought = true
                            break
                        end
                     end
                until elapsed > 4 or not _G.autoBuyRunning

                if bought then
                    break
                  else
                    task.wait(1)
                end
            end
            _G.autoBuyRunning = false
        end)
    end
})

Automatically:Divider()

Automatically:Toggle({
    Title    = "Auto Drive Loop (30s)",
    Icon     = "gauge",
    Default  = false,
    Callback = function(state)
        _G.autoDriveRunning = state
        if not state then
            print("[AutoDrive] Loop stopped by user.")
            return
        end

        print("[AutoDrive] Loop started.")
        task.spawn(function()
            while _G.autoDriveRunning do
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum  = char and char:FindFirstChildWhichIsA("Humanoid")
                
                if not root or not hum then 
                    warn("[AutoDrive] Player character not ready. Waiting 2s...")
                    task.wait(2)
                    continue 
                end

                print("[AutoDrive] Step 1: Teleporting player to start location...")
                root.CFrame = CFrame.new(
                    -628.818726, 4.01882744, 646.687927, 
                    -0.975349545, -4.53806486e-08, 0.220665619, 
                    -2.15982521e-08, 1, 1.10188459e-07, 
                    -0.220665619, 1.02706267e-07, -0.975349545
                )
                task.wait(0.5)

                print("[AutoDrive] Step 2: Spawning vehicle via tpVeh()...")
                tpVeh()
                task.wait(0.7)

                local myCar = findPlayerVehicle()
                if not myCar then
                    warn("[AutoDrive] Active vehicle not found in workspace! Retrying...")
                    task.wait(1)
                    continue
                end

                local driveSeat = myCar:FindFirstChild("DriveSeat", true) or myCar:FindFirstChildWhichIsA("VehicleSeat", true)
                
                if driveSeat then
                    print("[AutoDrive] Step 3: Teleporting to DriveSeat and pressing F...")
                    
                    hum.WalkToPoint = driveSeat.Position
                    task.wait(1)
                    
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    
                    task.wait(0.5)
                else
                    warn("[AutoDrive] Could not find any DriveSeat inside this car!")
                    task.wait(1)
                    continue
                end

                local weightPart = myCar:FindFirstChild("#Weight", true) or myCar:FindFirstChild("Weight", true) or myCar:FindFirstChildWhichIsA("BasePart", true)
                
                if not weightPart then
                    warn("[AutoDrive] Driving part (#Weight) not found! Skipping lap...")
                    task.wait(1)
                    continue
                end

                local bg = Instance.new("BodyGyro")
                bg.Name = "AutoDriveGyro"
                bg.MaxTorque = Vector3.new(0, 1000000, 0)
                bg.P = 30000
                bg.CFrame = weightPart.CFrame
                bg.Parent = weightPart

                print("[AutoDrive] Step 4: Driving forward for 30 seconds...")
                local driveEndTime = os.clock() + 30

                while os.clock() < driveEndTime and _G.autoDriveRunning do
                    if hum.SeatPart == nil and not driveSeat:FindFirstChild("SeatWeld") then
                        if not myCar:FindFirstChild("Occupant", true) then
                            warn("[AutoDrive] Player is no longer inside the vehicle. Aborting lap.")
                            break
                        end
                    end
                    
                    local rightSkewDirection = bg.CFrame * CFrame.Angles(0, math.rad(-2), 0)
                    weightPart.Velocity = rightSkewDirection.LookVector * 150
                    
                    task.wait(0.1)
                end

                if bg then bg:Destroy() end

                if _G.autoDriveRunning then
                    print("[AutoDrive] Step 5: Lap duration met! Forcing jump output.")
                    jumpCharacter()
                    task.wait(1.5)
                end
            end
            print("[AutoDrive] Loop cleanly terminated.")
        end)
    end
})

Automatically:Divider()

Automatically:Button({
    Title    = "Repair Vehicle",
    Icon     = "settings",
    Callback = function()
        task.spawn(function()
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(-1076, 5, -414)
            local vehicle = findPlayerVehicle()
            if not vehicle then warn("[Repair] No active vehicle found."); return end

            local building  = Workspace.Map.FirstCity.Buildings["PitStop(Large)"]
            local EngineBay = vehicle.Body.EngineBay
            local charRoot  = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            local safeBase  = charRoot and charRoot.Position or Vector3.new(0, 100, 0)
            local slots     = buildMachineSlots(building)

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
            if total == 0 then return end

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

            reinstallAllParts()
            reinstallAllParts()
        end)
    end
})

Automatically:Button({
    Title    = "Apply Paint",
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

            local model       = Workspace.Map.FirstCity.Buildings["PitStop(Large)"].Model
            local paintPrompt = findNearestPrompt(model)
            if paintPrompt then
                fireproximityprompt(paintPrompt)
            end
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

-- [[ Vehicle Tab ]]
local VehTab = Window:Tab({ Title = "Vehicle", Icon = "box" })

VehTab:Button({
    Title    = "Deploy Vehicle",
    Icon     = "refresh-cw",
     Callback = function()
        task.spawn(tpVeh)
    end
})

VehTab:Button({
    Title    = "Locate Vehicle",
    Icon     = "map-pin",
    Callback = function()
        local v = findPlayerVehicle()
        if not v then return end
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if root and v:FindFirstChild("Body") and v.Body:FindFirstChild("Plate") then
            root.CFrame = v.Body.Plate.CFrame
        end
    end
})

VehTab:Button({
    Title    = "Install Components",
    Icon     = "arrow-down-to-line",
    Callback = function()
         task.spawn(reinstallAllParts)
        task.spawn(reinstallAllParts)
    end
})

print("[Garage Manager] Version 2.0 Loaded successfully.")
