if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = game.Players.LocalPlayer or game.Players:GetPlayerFromCharacter(game.Players.LocalPlayer.Character)
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local pGui = player:WaitForChild("PlayerGui")
local WORLD_1_ID = 77747658251236 
local PORTAL_CF_WORLD2 = CFrame.new(-276.131165, 322.956329, -3057.51636) 
local FARM_TARGET_CF = CFrame.new(-690.935486, 5.0, -348.099884) 
local MAIN_ACCOUNTS = {"main1", "main2"}
local CHICKEN_LIST = {"CHICKEN1", "CHICKEN2"}
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local ArrivedAtFarm = false
local function CheckNameInList(name, list)
    for _, v in pairs(list) do if v == name then return true end end
    return false
end

local function UpdateMonitorStatus()
    pcall(function()
        local stats = player:FindFirstChild("leaderstats")
        local bounty = (stats and stats:FindFirstChild("Bounty")) and stats.Bounty.Value or 0
        local isMain = CheckNameInList(player.Name, MAIN_ACCOUNTS)
        local isChicken = CheckNameInList(player.Name, CHICKEN_LIST)
        
        local data = {
            Bounty = bounty,
            Role = isMain and "Main" or (isChicken and "Chicken" or "Unknown"),
            Status = "Online"
        }

        if isMain and bounty >= 50000000 then
            ArrivedAtFarm = false
            data.Status = "DONE"
            _G.Horst_SetDescription("✅ DONE 50M - Switching", HttpService:JSONEncode(data))
            task.wait(1)
            _G.Horst_AccountChangeDone()
        elseif isChicken and bounty <= 1500000 then
            ArrivedAtFarm = false
            data.Status = "EMPTY"
            _G.Horst_SetDescription("🪶 CHICKEN EMPTY - Switching", HttpService:JSONEncode(data))
            task.wait(1)
            _G.Horst_AccountChangeDone()
        else
            if tick() % 30 < 5 then
                local shortBounty = tostring(math.floor(bounty/1000000)) .. "M"
                local displayMsg = string.format("💰 %s | %s | Farming", shortBounty, data.Role)
                _G.Horst_SetDescription(displayMsg, HttpService:JSONEncode(data))
            end
        end
    end)
end

local function CheckAndReturnToSea1()
    if game.PlaceId ~= WORLD_1_ID then
        while game.PlaceId ~= WORLD_1_ID do
            pcall(function()
                local charObj = player.Character or player.CharacterAdded:Wait()
                local root = charObj:WaitForChild("HumanoidRootPart", 5)
                if root then
                    local dist = (PORTAL_CF_WORLD2.Position - root.Position).Magnitude
                    if dist > 15 then
                        local tween = TweenService:Create(root, TweenInfo.new(dist/150, Enum.EasingStyle.Linear), {CFrame = PORTAL_CF_WORLD2})
                        tween:Play()
                        tween.Completed:Wait()
                    end
                    root.CFrame = PORTAL_CF_WORLD2
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and (v.ObjectText == "World Island Door" or v.ActionText:find("Sea 1")) then
                            fireproximityprompt(v)
                            break
                        end
                    end
                end
            end)
            task.wait(5)
        end
    end
end

local function GoToFarm()
    if game.PlaceId ~= WORLD_1_ID then return end
    local charObj = player.Character or player.CharacterAdded:Wait()
    local root = charObj:WaitForChild("HumanoidRootPart")
    local dist = (FARM_TARGET_CF.Position - root.Position).Magnitude
    if dist > 5 then
        local tween = TweenService:Create(root, TweenInfo.new(dist/150, Enum.EasingStyle.Linear), {CFrame = FARM_TARGET_CF})
        tween:Play()
        tween.Completed:Wait()
    end
    ArrivedAtFarm = true
    pcall(function()
        local pvpRemote = ReplicatedStorage:WaitForChild("RemoteEvents", 2):WaitForChild("SettingsToggle", 2)
        if pvpRemote then pvpRemote:FireServer("DisablePvP", false) end
    end)
end

local function AttackLogic()
    if not ArrivedAtFarm or not CheckNameInList(player.Name, MAIN_ACCOUNTS) then return end
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Bounty") and stats.Bounty.Value >= 50000000 then return end
    pcall(function()
        local hitRemote = ReplicatedStorage.CombatSystem.Remotes.RequestHit
        if not player.Character:FindFirstChildOfClass("Tool") then
            local tool = player.Backpack:FindFirstChildOfClass("Tool")
            if tool then player.Character.Humanoid:EquipTool(tool) end
        end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and CheckNameInList(p.Name, CHICKEN_LIST) then
                if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    hitRemote:FireServer(p.Character)
                end
            end
        end
    end)
end

--// 5. รันลูปทั้งหมด
task.spawn(function()
    CheckAndReturnToSea1()
    if not CheckNameInList(player.Name, MAIN_ACCOUNTS) then
        pcall(function() ReplicatedStorage.RemoteEvents.ResetStats:FireServer() end)
    end
    GoToFarm()
end)

task.spawn(function()
    local lastMonitorUpdate = 0
    while true do
        AttackLogic()
        if tick() - lastMonitorUpdate > 5 then
            UpdateMonitorStatus()
            lastMonitorUpdate = tick()
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if ArrivedAtFarm then
            pcall(function()
                local root = player.Character.HumanoidRootPart
                if (FARM_TARGET_CF.Position - root.Position).Magnitude > 5 then
                    root.CFrame = FARM_TARGET_CF
                end
            end)
        end
        task.wait(0.5)
    end
end)
