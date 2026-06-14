local Config = {
    TargetPlayer = "",
    ItemFilter = {"ALL"},
    SendDelay = 5,
    NoteMessage = "Here is a gift!",
    AutoSend = true,
    AutoTrade = false,
    AutoClaimDelay = 0.45,
    AutoClaimScanDelay = 3,
    PickDelay = 0.1,
    SendPrepareDelay = 0.1,
    ResetDelay = 0.1,
    BetweenBatchDelay = 0.2,
}

local TARGET_PLAYER = Config.TargetPlayer
local ITEM_FILTER = Config.ItemFilter
local SEND_DELAY = Config.SendDelay
local NOTE_MESSAGE = Config.NoteMessage
local AUTO_SEND = Config.AutoSend
local AUTO_TRADE = Config.AutoTrade
local AUTO_CLAIM_DELAY = Config.AutoClaimDelay
local AUTO_CLAIM_SCAN_DELAY = Config.AutoClaimScanDelay
local PICK_DELAY = Config.PickDelay
local SEND_PREPARE_DELAY = Config.SendPrepareDelay
local RESET_DELAY = Config.ResetDelay
local BETWEEN_BATCH_DELAY = Config.BetweenBatchDelay

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Networking = require(ReplicatedStorage.SharedModules.Networking)
local MailboxController = require(LocalPlayer.PlayerScripts.Controllers.MailboxController)
local SeedImages = ReplicatedStorage.SharedModules.SeedData:FindFirstChild("SeedImages")

local attributeToCategoryMap = {
    SeedTool = "Seeds",
    Fruit = "Fruits",
    Sprinkler = "Sprinklers",
    WateringCan = "WateringCans",
    Mushroom = "Mushrooms",
    Gnome = "Gnomes",
    Raccoon = "Raccoons",
    Crate = "Crates",
    Teleporter = "Teleporters",
    SeedPack = "SeedPacks",
    Wheelbarrow = "Wheelbarrows",
    Trowel = "Trowels",
    Crowbar = "Crowbars",
    Ladder = "Ladders",
    FreezeRay = "FreezeRays",
    PowerHose = "PowerHoses",
    Rake = "Rakes",
    Lantern = "Lanterns",
    Sign = "Signs",
    EmptyPot = "EmptyPots",
    Flashbang = "Flashbangs",
    Bird = "Birds",
}

local UiState = {
    PlayerButtons = {},
    ItemButtons = {},
    SelectedItems = {},
    Sending = false,
    AutoThread = nil,
    AutoClaimThread = nil,
    AutoClaimQueue = {},
    HeadshotCache = {},
    HeadshotQueue = {},
    HeadshotLoading = false,
}

local function GetSelectedItemList()
    local selected = {}
    for itemName, enabled in pairs(UiState.SelectedItems) do
        if enabled then
            table.insert(selected, itemName)
        end
    end
    table.sort(selected)
    if #selected == 0 then
        return {"ALL"}
    end
    if table.find(selected, "ALL") then
        return {"ALL"}
    end
    return selected
end

local function SetSelectedItems(itemList)
    UiState.SelectedItems = {}
    for _, itemName in ipairs(itemList or {"ALL"}) do
        UiState.SelectedItems[itemName] = true
    end
    if UiState.SelectedItems["ALL"] then
        for itemName in pairs(UiState.SelectedItems) do
            if itemName ~= "ALL" then
                UiState.SelectedItems[itemName] = nil
            end
        end
    end
    ITEM_FILTER = GetSelectedItemList()
end

SetSelectedItems(ITEM_FILTER)

local function GetTargetPlayer()
    if not TARGET_PLAYER or TARGET_PLAYER == "" then
        return nil
    end
    local targetName = string.lower(TARGET_PLAYER)
    for _, player in ipairs(Players:GetPlayers()) do
        if string.lower(player.Name) == targetName or string.lower(player.DisplayName) == targetName then
            return player
        end
    end
    return nil
end

local function GetItemInfo(tool)
    if not tool:IsA("Tool") then
        return nil
    end

    if tool:GetAttribute("HarvestedFruit") == true then
        local itemId = tool:GetAttribute("Id")
        if itemId then
            local fruitName = tool:GetAttribute("Fruit") or "Fruit"
            return {
                Category = "HarvestedFruits",
                ItemKey = itemId,
                DisplayName = fruitName .. " (Harvested)",
                FilterName = fruitName,
                Count = 1,
            }
        end
    end

    local petId = tool:GetAttribute("PetId")
    if type(petId) == "string" and petId ~= "" then
        local petName = tool:GetAttribute("Pet") or "Pet"
        return {
            Category = "Pets",
            ItemKey = petId,
            DisplayName = petName,
            FilterName = petName,
            Count = 1,
        }
    end

    for attrName, category in pairs(attributeToCategoryMap) do
        local value = tool:GetAttribute(attrName)
        if value then
            local itemKey = value
            local displayName = value
            local filterName = value

            if attrName == "Fruit" then
                local mutation = tool:GetAttribute("Mutation")
                local weight = tool:GetAttribute("Weight")
                filterName = value
                if mutation then
                    displayName = value .. " (" .. mutation .. ")"
                end
                if weight then
                    displayName = displayName .. " " .. tostring(math.floor(weight * 1000)) .. "g"
                end
            end

            local count = tool:GetAttribute("Count") or 1

            return {
                Category = category,
                ItemKey = itemKey,
                DisplayName = displayName,
                FilterName = filterName,
                Count = count,
            }
        end
    end

    return nil
end

local function GetAvailableItems()
    local itemMap = {
        ALL = true,
    }
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            local itemInfo = GetItemInfo(tool)
            if itemInfo then
                itemMap[itemInfo.DisplayName] = true
            end
        end
    end
    local items = {}
    for itemName in pairs(itemMap) do
        table.insert(items, itemName)
    end
    table.sort(items, function(a, b)
        if a == "ALL" then
            return true
        end
        if b == "ALL" then
            return false
        end
        return a < b
    end)
    return items
end

local function GetItemImage(itemName)
    if itemName == "ALL" or not SeedImages then
        return ""
    end
    local imageValue = SeedImages:FindFirstChild(itemName)
    if not imageValue then
        return ""
    end
    if imageValue:IsA("StringValue") then
        return imageValue.Value
    end
    if imageValue:IsA("ImageLabel") then
        return imageValue.Image
    end
    return ""
end

local function GetPlayerHeadshot(userId)
    if UiState.HeadshotCache[userId] then
        return UiState.HeadshotCache[userId]
    end
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    if ok and type(image) == "string" then
        UiState.HeadshotCache[userId] = image
        return image
    end
    return ""
end

local function QueuePlayerHeadshot(userId, imageLabel)
    if not userId or not imageLabel then
        return
    end

    local cached = UiState.HeadshotCache[userId]
    if cached then
        imageLabel.Image = cached
        return
    end

    table.insert(UiState.HeadshotQueue, {
        UserId = userId,
        ImageLabel = imageLabel
    })

    if UiState.HeadshotLoading then
        return
    end

    UiState.HeadshotLoading = true
    task.spawn(function()
        while #UiState.HeadshotQueue > 0 do
            local nextItem = table.remove(UiState.HeadshotQueue, 1)
            if nextItem and nextItem.ImageLabel and nextItem.ImageLabel.Parent then
                local image = GetPlayerHeadshot(nextItem.UserId)
                if image ~= "" and nextItem.ImageLabel.Parent then
                    nextItem.ImageLabel.Image = image
                end
            end
            task.wait()
        end
        UiState.HeadshotLoading = false
    end)
end

local function SendAllItemsComplete()
    if UiState.Sending then
        warn("[Auto Send] Sending in progress")
        return
    end
    UiState.Sending = true

    if not TARGET_PLAYER or TARGET_PLAYER == "" then
        UiState.Sending = false
        warn("[Auto Send] กรุณาใส่ชื่อผู้เล่นที่จะส่ง")
        return
    end

    local targetPlayer = GetTargetPlayer()
    if not targetPlayer then
        UiState.Sending = false
        warn("[Auto Send] ไม่พบผู้เล่น: " .. TARGET_PLAYER)
        return
    end

    local backpack = LocalPlayer:WaitForChild("Backpack")
    local allItems = {}
    local isAllItems = table.find(ITEM_FILTER, "ALL") ~= nil
    for _, tool in ipairs(backpack:GetChildren()) do
        local itemInfo = GetItemInfo(tool)
        if itemInfo and (isAllItems or table.find(ITEM_FILTER, itemInfo.FilterName)) then
            local key = itemInfo.Category .. ":" .. itemInfo.ItemKey
            if not allItems[key] then
                allItems[key] = {
                    Category = itemInfo.Category,
                    ItemKey = itemInfo.ItemKey,
                    DisplayName = itemInfo.DisplayName,
                    Count = 0,
                }
            end
            allItems[key].Count = allItems[key].Count + itemInfo.Count
        end
    end

    local totalItems = 0
    for _, itemData in pairs(allItems) do
        totalItems = totalItems + itemData.Count
    end
    if totalItems == 0 then
        UiState.Sending = false
        warn("[Auto Send] ไม่มี Item ที่จะส่ง")
        return
    end

    print(string.format("[Auto Send] เริ่มส่ง %d Items ให้ %s", totalItems, targetPlayer.Name))
    pcall(function()
        MailboxController:_pickRecipient(targetPlayer.UserId, targetPlayer.DisplayName)
    end)
    task.wait(PICK_DELAY)

    local itemQueue = {}
    for _, itemData in pairs(allItems) do
        if itemData.Count > 0 then
            table.insert(itemQueue, itemData)
        end
    end

    local totalSent = 0
    local batchNumber = 1
    local queueIndex = 1
    while totalSent < totalItems and queueIndex <= #itemQueue do
        local batchCount = 0
        local itemsToSend = {}

        while batchCount < 20 and queueIndex <= #itemQueue do
            local itemData = itemQueue[queueIndex]
            local sendCount = math.min(itemData.Count, 20 - batchCount)

            for _ = 1, sendCount do
                local fullItemKey = itemData.Category .. ":" .. itemData.ItemKey
                pcall(function()
                    MailboxController:_addToSend(fullItemKey, itemData.Category, itemData.ItemKey, nil)
                end)
                table.insert(itemsToSend, {
                    Category = itemData.Category,
                    ItemKey = itemData.ItemKey,
                    Count = 1
                })
                batchCount = batchCount + 1
            end

            itemData.Count = itemData.Count - sendCount
            if itemData.Count <= 0 then
                queueIndex = queueIndex + 1
            end
        end

        if batchCount == 0 then
            break
        end

        task.wait(SEND_PREPARE_DELAY)
        local success, result, message = pcall(function()
            return Networking.Mailbox.SendBatch:Fire(
                targetPlayer.UserId,
                itemsToSend,
                NOTE_MESSAGE
            )
        end)

        if success and result then
            totalSent = totalSent + batchCount
            print(string.format("[Auto Send] Batch #%d: ส่ง %d Items สำเร็จ (รวม %d/%d)", batchNumber, batchCount, totalSent, totalItems))
        else
            warn(string.format("[Auto Send] Batch #%d ล้มเหลว: %s", batchNumber, tostring(message or "Unknown error")))
        end

        pcall(function()
            MailboxController:_resetToPlayerList()
        end)
        task.wait(RESET_DELAY)

        if totalSent < totalItems and queueIndex <= #itemQueue then
            pcall(function()
                MailboxController:_pickRecipient(targetPlayer.UserId, targetPlayer.DisplayName)
            end)
            task.wait(PICK_DELAY)
            task.wait(BETWEEN_BATCH_DELAY)
        end

        batchNumber = batchNumber + 1
    end

    pcall(function()
        MailboxController:_resetToPlayerList()
    end)
    print(string.format("[Auto Send] เสร็จสิ้น! ส่งทั้งหมด %d Items ให้ %s", totalSent, targetPlayer.Name))
    UiState.Sending = false
end

local function StartAutoSendLoop()
    if UiState.AutoThread then
        return
    end
    UiState.AutoThread = task.spawn(function()
        while AUTO_SEND do
            task.wait(math.max(0.1, tonumber(SEND_DELAY) or 5))
            if not AUTO_SEND then
                break
            end
            pcall(SendAllItemsComplete)
        end
        UiState.AutoThread = nil
    end)
end

local function StopAutoSendLoop()
    AUTO_SEND = false
end

local function RefreshMailboxClaimQueue()
    local ok, inbox = pcall(function()
        return Networking.Mailbox.OpenInbox:Fire()
    end)
    if not ok or type(inbox) ~= "table" then
        warn("[Auto Claim Mailbox] Failed to open inbox")
        return 0
    end

    table.clear(UiState.AutoClaimQueue)
    for mailId in pairs(inbox) do
        if type(mailId) == "string" then
            table.insert(UiState.AutoClaimQueue, mailId)
        end
    end
    table.sort(UiState.AutoClaimQueue)

    return #UiState.AutoClaimQueue
end

local function ClaimNextMailboxGift()
    local mailId = table.remove(UiState.AutoClaimQueue, 1)
    if not mailId then
        return false
    end

    local claimOk, success, message = pcall(function()
        return Networking.Mailbox.Claim:Fire(mailId)
    end)
    if claimOk and success then
        print("[Auto Claim Mailbox] Claimed " .. mailId)
    elseif claimOk then
        warn("[Auto Claim Mailbox] Claim failed: " .. tostring(message or mailId))
    else
        warn("[Auto Claim Mailbox] Claim error: " .. tostring(success))
    end

    return true
end

local function StartAutoClaimLoop()
    if UiState.AutoClaimThread then
        return
    end
    UiState.AutoClaimThread = task.spawn(function()
        while AUTO_TRADE do
            if #UiState.AutoClaimQueue == 0 then
                local count = RefreshMailboxClaimQueue()
                if count == 0 then
                    task.wait(AUTO_CLAIM_SCAN_DELAY)
                end
            end

            if #UiState.AutoClaimQueue > 0 then
                ClaimNextMailboxGift()
                task.wait(AUTO_CLAIM_DELAY)
            end
        end
        table.clear(UiState.AutoClaimQueue)
        UiState.AutoClaimThread = nil
    end)
end

local function StopAutoClaimLoop()
    AUTO_TRADE = false
end

local function GetPlayerPlot()
    local plotId = LocalPlayer:GetAttribute("PlotId")
    if not plotId then
        return nil
    end
    local gardens = workspace:FindFirstChild("Gardens")
    if not gardens then
        return nil
    end
    return gardens:FindFirstChild("Plot" .. tostring(plotId))
end

local function GetPlayerPlants()
    local plot = GetPlayerPlot()
    local plants = plot and plot:FindFirstChild("Plants")
    if not plants then
        return {}
    end
    local list = {}
    for _, child in ipairs(plants:GetChildren()) do
        if child:IsA("Model") then
            table.insert(list, child)
        end
    end
    return list
end

local function HasSeedTool()
    local function scan(container)
        if not container then
            return false
        end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute("SeedTool") then
                return true
            end
        end
        return false
    end
    return scan(LocalPlayer.Character) or scan(LocalPlayer:FindFirstChildOfClass("Backpack"))
end

local function HasHarvestedFruitTool()
    local function scan(container)
        if not container then
            return false
        end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Tool") and (child:GetAttribute("Fruit") or child:GetAttribute("FruitName") or child:GetAttribute("HarvestedFruit")) then
                return true
            end
        end
        return false
    end
    return scan(LocalPlayer.Character) or scan(LocalPlayer:FindFirstChildOfClass("Backpack"))
end

local existingGui = PlayerGui:FindFirstChild("AutoSendSeedUI")
if existingGui then
    existingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoSendSeedUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 700, 0, 430)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -215)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 20, 45)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(15, 8, 25)
mainStroke.Thickness = 3
mainStroke.Parent = mainFrame

local outerShadow = Instance.new("Frame")
outerShadow.Size = UDim2.new(1, -6, 1, -6)
outerShadow.Position = UDim2.new(0, 3, 0, 3)
outerShadow.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
outerShadow.BackgroundTransparency = 0.65
outerShadow.BorderSizePixel = 0
outerShadow.ZIndex = 0
outerShadow.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Name = "Header"
topBar.Size = UDim2.new(1, 0, 0, 58)
topBar.BackgroundColor3 = Color3.fromRGB(88, 44, 180)
topBar.BorderSizePixel = 0
topBar.ClipsDescendants = true
topBar.ZIndex = 2
topBar.Parent = mainFrame

local topStroke = Instance.new("UIStroke")
topStroke.Color = Color3.fromRGB(55, 25, 110)
topStroke.Thickness = 2
topStroke.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 300, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Your Mailbox"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.FredokaOne
title.TextSize = 26
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = topBar

local function CreateHeaderButton(text, bgColor, posScaleX, widthScale, isClose)
    local button = Instance.new("TextButton")
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Size = isClose and UDim2.new(0, 32, 0, 32) or UDim2.new(widthScale, 0, 0, 32)
    button.Position = UDim2.new(posScaleX, 0, 0.5, 0)
    button.BackgroundColor3 = bgColor
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.FredokaOne
    button.TextSize = isClose and 20 or 17
    button.ClipsDescendants = true
    button.ZIndex = 3
    button.Parent = topBar

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 80, 150)
    stroke.Thickness = 2
    stroke.Parent = button

    return button
end

local sendTabButton = CreateHeaderButton("Mail", Color3.fromRGB(60, 45, 95), 0.69, 0.17, false)
local receiveTabButton = CreateHeaderButton("Receive", Color3.fromRGB(60, 45, 95), 0.87, 0.17, false)
local closeButton = CreateHeaderButton("X", Color3.fromRGB(255, 100, 120), 0.95, 0, true)
sendTabButton.Visible = false
receiveTabButton.Visible = false
closeButton.Visible = false

local body = Instance.new("Frame")
body.Size = UDim2.new(1, -20, 1, -70)
body.Position = UDim2.new(0, 10, 0, 60)
body.BackgroundTransparency = 1
body.ClipsDescendants = true
body.ZIndex = 1
body.Parent = mainFrame

local selectPlayerFrame = Instance.new("Frame")
selectPlayerFrame.Name = "SelectPlayerFrame"
selectPlayerFrame.Size = UDim2.new(0, 286, 1, 0)
selectPlayerFrame.BackgroundTransparency = 1
selectPlayerFrame.ClipsDescendants = true
selectPlayerFrame.Parent = body

local itemSendFrame = Instance.new("Frame")
itemSendFrame.Name = "ItemSendFrame"
itemSendFrame.Size = UDim2.new(1, -298, 1, 0)
itemSendFrame.Position = UDim2.new(0, 298, 0, 0)
itemSendFrame.BackgroundTransparency = 1
itemSendFrame.ClipsDescendants = true
itemSendFrame.Visible = true
itemSendFrame.Parent = body

local receiveFrame = Instance.new("ScrollingFrame")
receiveFrame.Name = "ReceiveFrame"
receiveFrame.Size = UDim2.new(1, 0, 1, 0)
receiveFrame.BackgroundTransparency = 1
receiveFrame.BorderSizePixel = 0
receiveFrame.ScrollBarThickness = 6
receiveFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
receiveFrame.Visible = false
receiveFrame.Parent = body

local receiveLayout = Instance.new("UIListLayout")
receiveLayout.Padding = UDim.new(0, 10)
receiveLayout.Parent = receiveFrame

local receivePadding = Instance.new("UIPadding")
receivePadding.PaddingTop = UDim.new(0, 4)
receivePadding.PaddingLeft = UDim.new(0, 4)
receivePadding.PaddingRight = UDim.new(0, 4)
receivePadding.PaddingBottom = UDim.new(0, 4)
receivePadding.Parent = receiveFrame

local function CreateLabel(parent, text, y)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(235, 240, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 2
    label.Parent = parent
    return label
end

local function CreateBox(parent, placeholder, text, y)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 34)
    box.Position = UDim2.new(0, 10, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(45, 32, 75)
    box.BorderSizePixel = 0
    box.PlaceholderText = placeholder
    box.Text = text
    box.TextColor3 = Color3.fromRGB(240, 245, 255)
    box.PlaceholderColor3 = Color3.fromRGB(160, 150, 190)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.ZIndex = 2
    box.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 80, 150)
    stroke.Thickness = 2
    stroke.Parent = box

    return box
end

local function CreateActionButton(parent, text, color, y, sizeX, posX)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(sizeX or 1, sizeX and -5 or -20, 0, 34)
    button.Position = UDim2.new(posX or 0, posX and 10 or 10, 0, y)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.AutoButtonColor = true
    button.ClipsDescendants = true
    button.ZIndex = 2
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 80, 150)
    stroke.Thickness = 2
    stroke.Parent = button

    local shine = Instance.new("Frame")
    shine.Name = "Shine"
    shine.Size = UDim2.new(1, -6, 0, 9)
    shine.Position = UDim2.new(0, 3, 0, 3)
    shine.BackgroundColor3 = Color3.fromRGB(200, 180, 255)
    shine.BackgroundTransparency = 0.82
    shine.BorderSizePixel = 0
    shine.ZIndex = 3
    shine.Parent = button

    local shineCorner = Instance.new("UICorner")
    shineCorner.CornerRadius = UDim.new(0, 8)
    shineCorner.Parent = shine

    return button
end

local function CreateScroll(parent, y, height)
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, -20, 0, height)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(50, 35, 85)
    frame.BorderSizePixel = 0
    frame.CanvasSize = UDim2.new()
    frame.ScrollBarThickness = 5
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.ClipsDescendants = true
    frame.ZIndex = 2
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(88, 70, 140)
    stroke.Thickness = 2
    stroke.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = frame

    return frame
end

local topSearchBar = Instance.new("Frame")
topSearchBar.Size = UDim2.new(1, -20, 0, 46)
topSearchBar.Position = UDim2.new(0, 10, 0, 2)
topSearchBar.BackgroundColor3 = Color3.fromRGB(35, 25, 60)
topSearchBar.BorderSizePixel = 0
topSearchBar.ClipsDescendants = true
topSearchBar.ZIndex = 2
topSearchBar.Parent = selectPlayerFrame

local topSearchStroke = Instance.new("UIStroke")
topSearchStroke.Color = Color3.fromRGB(100, 80, 150)
topSearchStroke.Thickness = 2
topSearchStroke.Parent = topSearchBar

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, 34, 1, 0)
searchIcon.Position = UDim2.new(0, 4, 0, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "Q"
searchIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
searchIcon.Font = Enum.Font.FredokaOne
searchIcon.TextSize = 20
searchIcon.ZIndex = 3
searchIcon.Parent = topSearchBar

local targetBox = CreateBox(topSearchBar, "Player name or display name", TARGET_PLAYER, 10)
targetBox.Size = UDim2.new(1, -44, 0, 30)
targetBox.Position = UDim2.new(0, 36, 0, 8)

local playerScroll = CreateScroll(selectPlayerFrame, 56, 248)
local refreshPlayersButton = CreateActionButton(selectPlayerFrame, "Refresh Players", Color3.fromRGB(55, 40, 90), 314)

CreateLabel(itemSendFrame, "Your Inventory", 0)
local autoTradeButton = CreateActionButton(itemSendFrame, AUTO_TRADE and "Auto Accept Trade ON" or "Auto Accept Trade OFF", AUTO_TRADE and Color3.fromRGB(120, 80, 200) or Color3.fromRGB(55, 40, 90), 22)
local itemScroll = CreateScroll(itemSendFrame, 64, 112)
CreateLabel(itemSendFrame, "Sending Settings", 186)
CreateLabel(itemSendFrame, "Mail Note", 208)
local noteBox = CreateBox(itemSendFrame, "Mail note", NOTE_MESSAGE, 230)
CreateLabel(itemSendFrame, "Auto Delay (seconds)", 272)
local delayBox = CreateBox(itemSendFrame, "5", tostring(SEND_DELAY), 294)
local refreshItemsButton = CreateActionButton(itemSendFrame, "Refresh Items", Color3.fromRGB(55, 40, 90), 326, 0.48, 0)
local autoToggleButton = CreateActionButton(itemSendFrame, AUTO_SEND and "Auto Send ON" or "Auto Send OFF", AUTO_SEND and Color3.fromRGB(120, 80, 200) or Color3.fromRGB(55, 40, 90), 326, 0.48, 0.52)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 16)
statusLabel.Position = UDim2.new(0, 10, 1, -26)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(220, 225, 245)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 2
statusLabel.Parent = selectPlayerFrame

local function SetStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color or Color3.fromRGB(220, 225, 245)
end

local function CreateListButton(parent, text, image)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, image and image ~= "" and 48 or 28)
    button.BackgroundColor3 = Color3.fromRGB(40, 28, 70)
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = true
    button.ClipsDescendants = true
    button.ZIndex = 2
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 80, 150)
    stroke.Thickness = 2
    stroke.Parent = button

    if image and image ~= "" then
        local itemImage = Instance.new("ImageLabel")
        itemImage.Name = "ItemImage"
        itemImage.Size = UDim2.new(0, 36, 0, 36)
        itemImage.Position = UDim2.new(0, 6, 0.5, -18)
        itemImage.BackgroundTransparency = 1
        itemImage.Image = image
        itemImage.ScaleType = Enum.ScaleType.Fit
        itemImage.ZIndex = 3
        itemImage.Parent = button

        local itemText = Instance.new("TextLabel")
        itemText.Name = "ItemText"
        itemText.Size = UDim2.new(1, -48, 1, 0)
        itemText.Position = UDim2.new(0, 44, 0, 0)
        itemText.BackgroundTransparency = 1
        itemText.Text = text
        itemText.TextColor3 = Color3.fromRGB(240, 245, 255)
        itemText.Font = Enum.Font.GothamBold
        itemText.TextSize = 12
        itemText.TextXAlignment = Enum.TextXAlignment.Left
        itemText.ZIndex = 3
        itemText.Parent = button
    else
        button.Text = text
        button.TextColor3 = Color3.fromRGB(240, 245, 255)
        button.Font = Enum.Font.Gotham
        button.TextSize = 12
    end

    return button
end

local function CreatePlayerButton(parent, player)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 70)
    button.BackgroundColor3 = Color3.fromRGB(40, 28, 70)
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = true
    button.ClipsDescendants = true
    button.ZIndex = 2
    button.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 80, 150)
    stroke.Thickness = 2
    stroke.Parent = button

    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(0, 54, 0, 54)
    avatarFrame.Position = UDim2.new(0, 8, 0.5, -27)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(50, 35, 75)
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ZIndex = 3
    avatarFrame.Parent = button

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Color = Color3.fromRGB(88, 70, 140)
    avatarStroke.Thickness = 2
    avatarStroke.Parent = avatarFrame

    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Name = "PlayerImage"
    avatarImage.Size = UDim2.new(1, -6, 1, -6)
    avatarImage.Position = UDim2.new(0, 3, 0, 3)
    avatarImage.BackgroundTransparency = 1
    avatarImage.Image = ""
    avatarImage.ScaleType = Enum.ScaleType.Crop
    avatarImage.ZIndex = 4
    avatarImage.Parent = avatarFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "PlayerName"
    nameLabel.Size = UDim2.new(1, -76, 0, 26)
    nameLabel.Position = UDim2.new(0, 70, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(245, 248, 255)
    nameLabel.Font = Enum.Font.FredokaOne
    nameLabel.TextSize = 17
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 4
    nameLabel.Parent = button

    local handleLabel = Instance.new("TextLabel")
    handleLabel.Name = "PlayerHandle"
    handleLabel.Size = UDim2.new(1, -76, 0, 18)
    handleLabel.Position = UDim2.new(0, 70, 0, 34)
    handleLabel.BackgroundTransparency = 1
    handleLabel.Text = "@" .. player.DisplayName
    handleLabel.TextColor3 = Color3.fromRGB(190, 185, 215)
    handleLabel.Font = Enum.Font.GothamBold
    handleLabel.TextSize = 11
    handleLabel.TextXAlignment = Enum.TextXAlignment.Left
    handleLabel.ZIndex = 4
    handleLabel.Parent = button

    QueuePlayerHeadshot(player.UserId, avatarImage)

    return button
end

local function UpdateAutoToggle()
    autoToggleButton.Text = AUTO_SEND and "Auto Send ON" or "Auto Send OFF"
    autoToggleButton.BackgroundColor3 = AUTO_SEND and Color3.fromRGB(120, 80, 200) or Color3.fromRGB(55, 40, 90)
end

local function UpdateAutoTradeToggle()
    autoTradeButton.Text = AUTO_TRADE and "Auto Accept Trade ON" or "Auto Accept Trade OFF"
    autoTradeButton.BackgroundColor3 = AUTO_TRADE and Color3.fromRGB(120, 80, 200) or Color3.fromRGB(55, 40, 90)
end

local function SetPage(isSendPage)
    itemSendFrame.Visible = isSendPage
    selectPlayerFrame.Visible = isSendPage
    receiveFrame.Visible = not isSendPage
    sendTabButton.BackgroundColor3 = isSendPage and Color3.fromRGB(120, 80, 200) or Color3.fromRGB(60, 45, 95)
    receiveTabButton.BackgroundColor3 = not isSendPage and Color3.fromRGB(120, 80, 200) or Color3.fromRGB(60, 45, 95)
end

local function UpdateItemButtons()
    for itemName, button in pairs(UiState.ItemButtons) do
        local selected = UiState.SelectedItems[itemName] == true
        button.BackgroundColor3 = selected and Color3.fromRGB(120, 80, 200) or Color3.fromRGB(40, 28, 70)
        local itemText = button:FindFirstChild("ItemText")
        if itemText then
            itemText.Text = selected and ("[x] " .. itemName) or ("[ ] " .. itemName)
        else
            button.Text = selected and ("[x] " .. itemName) or ("[ ] " .. itemName)
        end
    end
end

local function RefreshItemList()
    for _, button in pairs(UiState.ItemButtons) do
        button:Destroy()
    end
    UiState.ItemButtons = {}

    for _, itemName in ipairs(GetAvailableItems()) do
        local button = CreateListButton(itemScroll, itemName, GetItemImage(itemName))
        UiState.ItemButtons[itemName] = button
        button.MouseButton1Click:Connect(function()
            if itemName == "ALL" then
                SetSelectedItems({"ALL"})
            else
                UiState.SelectedItems["ALL"] = nil
                UiState.SelectedItems[itemName] = not UiState.SelectedItems[itemName]
                if next(UiState.SelectedItems) == nil then
                    UiState.SelectedItems["ALL"] = true
                end
                ITEM_FILTER = GetSelectedItemList()
            end
            UpdateItemButtons()
            SetStatus("Selected items: " .. table.concat(ITEM_FILTER, ", "))
        end)
    end

    if #GetSelectedItemList() == 0 then
        SetSelectedItems({"ALL"})
    end
    UpdateItemButtons()
end

local function HighlightPlayerButtons()
    for playerName, button in pairs(UiState.PlayerButtons) do
        local selected = string.lower(playerName) == string.lower(TARGET_PLAYER)
        button.BackgroundColor3 = selected and Color3.fromRGB(120, 80, 200) or Color3.fromRGB(40, 28, 70)
        local nameLabel = button:FindFirstChild("PlayerName")
        local handleLabel = button:FindFirstChild("PlayerHandle")
        if nameLabel then
            nameLabel.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(245, 248, 255)
        end
        if handleLabel then
            handleLabel.TextColor3 = selected and Color3.fromRGB(220, 215, 255) or Color3.fromRGB(190, 185, 215)
        end
    end
end

local function RefreshPlayerList()
    for _, button in pairs(UiState.PlayerButtons) do
        button:Destroy()
    end
    UiState.PlayerButtons = {}

    local playerList = Players:GetPlayers()
    table.sort(playerList, function(a, b)
        return a.Name < b.Name
    end)

    for _, player in ipairs(playerList) do
        if player ~= LocalPlayer then
            local button = CreatePlayerButton(playerScroll, player)
            UiState.PlayerButtons[player.Name] = button
            button.MouseButton1Click:Connect(function()
                TARGET_PLAYER = player.Name
                targetBox.Text = TARGET_PLAYER
                HighlightPlayerButtons()
                SetStatus("Target set to " .. TARGET_PLAYER, Color3.fromRGB(194, 255, 163))
            end)
        end
    end

    HighlightPlayerButtons()
end

targetBox.FocusLost:Connect(function()
    TARGET_PLAYER = targetBox.Text
    HighlightPlayerButtons()
end)

noteBox.FocusLost:Connect(function()
    NOTE_MESSAGE = noteBox.Text
end)

delayBox.FocusLost:Connect(function()
    local value = tonumber(delayBox.Text)
    if value and value > 0 then
        SEND_DELAY = value
        delayBox.Text = tostring(value)
    else
        delayBox.Text = tostring(SEND_DELAY)
    end
end)

refreshPlayersButton.MouseButton1Click:Connect(function()
    RefreshPlayerList()
    SetStatus("Player list refreshed", Color3.fromRGB(194, 255, 163))
end)

refreshItemsButton.MouseButton1Click:Connect(function()
    RefreshItemList()
    SetStatus("Item list refreshed", Color3.fromRGB(194, 255, 163))
end)

autoTradeButton.MouseButton1Click:Connect(function()
    AUTO_TRADE = not AUTO_TRADE
    UpdateAutoTradeToggle()
    if AUTO_TRADE then
        StartAutoClaimLoop()
        SetStatus("Auto claim mailbox enabled", Color3.fromRGB(126, 221, 154))
    else
        StopAutoClaimLoop()
        SetStatus("Auto claim mailbox disabled", Color3.fromRGB(255, 140, 140))
    end
end)

autoToggleButton.MouseButton1Click:Connect(function()
    AUTO_SEND = not AUTO_SEND
    UpdateAutoToggle()
    if AUTO_SEND then
        StartAutoSendLoop()
        SetStatus("Auto send enabled", Color3.fromRGB(126, 221, 154))
    else
        StopAutoSendLoop()
        SetStatus("Auto send disabled", Color3.fromRGB(255, 140, 140))
    end
end)

sendTabButton.MouseButton1Click:Connect(function()
    SetPage(true)
end)

receiveTabButton.MouseButton1Click:Connect(function()
    SetPage(false)
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

local dragging = false
local dragInput
local dragStart
local startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

screenGui.Enabled = true
RefreshPlayerList()
RefreshItemList()
UpdateAutoToggle()
UpdateAutoTradeToggle()
SetPage(true)
SetStatus("UI ready", Color3.fromRGB(126, 221, 154))

Players.PlayerAdded:Connect(function()
    if screenGui.Parent then
        RefreshPlayerList()
    end
end)

Players.PlayerRemoving:Connect(function()
    if screenGui.Parent then
        RefreshPlayerList()
    end
end)

local Backpack = LocalPlayer:FindFirstChild("Backpack")
if Backpack then
    Backpack.ChildAdded:Connect(function()
        if screenGui.Parent then
            RefreshItemList()
        end
    end)
    Backpack.ChildRemoved:Connect(function()
        if screenGui.Parent then
            RefreshItemList()
        end
    end)
end

local fade = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0
})
mainFrame.BackgroundTransparency = 1
fade:Play()

print("[Auto Send] UI loaded")
if AUTO_SEND then
    StartAutoSendLoop()
end
if AUTO_TRADE then
    StartAutoClaimLoop()
end
