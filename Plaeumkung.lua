local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TPService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local targetName = "PLAEUMKUNG_GG" --ชื่่อที่อยากจะเทรด
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear)

local function Rejoin()
    TPService:Teleport(game.PlaceId, player)
end

local function checkItemsLeft()
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name ~= "Treadmill" then return true end
        end
    end
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name ~= "Treadmill" then return true end
        end
    end
    return false
end

local function setupPrompt(v)
    if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
end
for _, v in ipairs(game:GetDescendants()) do setupPrompt(v) end
game.DescendantAdded:Connect(setupPrompt)

local function manageTools()
    local char = player.Character
    if not char then return end
    
    local isHoldingTool = false
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.Name ~= "Treadmill" then
            isHoldingTool = true
            break
        end
    end

    if not isHoldingTool then
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name ~= "Treadmill" then
                    tool.Parent = char
                    break
                end
            end
        end
    end
end

task.wait(0.5)
local rf = game:GetService("ReplicatedStorage"):WaitForChild("Functions", 5)
local setSettingFunc = rf and rf:FindFirstChild("SetSettingFunc")
if setSettingFunc then
    setSettingFunc:InvokeServer("BGM", "\255")
end
task.wait(0.5)
print("test dupe")

task.spawn(function()
    while true do
        local confirmGui = playerGui:FindFirstChild("Confirm")
        if confirmGui and confirmGui.Enabled then
            local btn = confirmGui:FindFirstChild("Main", true) 
                and confirmGui.Main:FindFirstChild("ConfirmFrame", true) 
                and confirmGui.Main.ConfirmFrame:FindFirstChild("Btn_Confirm")

            if btn then
                GuiService.SelectedObject = btn
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                task.wait()
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                GuiService.SelectedObject = nil
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if not checkItemsLeft() then
            Rejoin()
            break
        end

        local target = Players:FindFirstChild(targetName)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
            local targetHRP = target.Character.HumanoidRootPart
            local targetCFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
            
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
            
            manageTools()
            
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait()
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        else
            task.wait(0.5)
        end
        RunService.Heartbeat:Wait()
    end
end)
