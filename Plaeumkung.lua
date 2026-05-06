task.wait(1)
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local PLACE_A = 13775256536
local PLACE_B = 93712201161812
local PLACE_C = 131703399727686

local function runPlaceA()
	while true do
		if game.PlaceId ~= PLACE_A then break end

		if game.PlaceId ~= PLACE_B then
			TeleportService:Teleport(PLACE_B, LocalPlayer)
		end

		task.wait(5)
	end
end

local function runPlaceB()
	local GuiService = game:GetService("GuiService")
	local VirtualInputManager = game:GetService("VirtualInputManager")

	local targets = {
		workspace.Lifts:GetChildren()[16],
		workspace.Lifts.ToiletHQ,
		workspace.Lifts:GetChildren()[12],
		workspace.Lifts:GetChildren()[15],
	}

	local function teleportToModelGround(model)
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local hrp = character:WaitForChild("HumanoidRootPart")

		local offsetHeight = 3

		if model:IsA("Model") then
			local cf, size = model:GetBoundingBox()
			local groundY = cf.Position.Y - (size.Y / 2)
			hrp.CFrame = CFrame.new(cf.Position.X, groundY + offsetHeight, cf.Position.Z)
		elseif model:IsA("BasePart") then
			local groundY = model.Position.Y - (model.Size.Y / 2)
			hrp.CFrame = CFrame.new(model.Position.X, groundY + offsetHeight, model.Position.Z)
		end
	end

	local function teleportToRandom()
		local target = targets[math.random(1, #targets)]
		if target then
			teleportToModelGround(target)
		end
	end

	local function focusAndPressEnter()
		local gui = LocalPlayer:WaitForChild("PlayerGui")
		local lobby = gui:WaitForChild("Lobby")
		local queueFrame = lobby:WaitForChild("QueueFrame")

		local t0 = tick()
		while not queueFrame.Visible do
			if tick() - t0 >= 10 then
				teleportToRandom()
				task.wait(0.5)
				focusAndPressEnter()
				return
			end
			task.wait()
		end

		local startBtn = queueFrame:FindFirstChild("Start")
		if startBtn then
			GuiService.SelectedObject = startBtn
			task.wait(0.2)

			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
			task.wait()
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
		end
	end

	teleportToRandom()
	focusAndPressEnter()
end

local function runPlaceC()
	local GuiService = game:GetService("GuiService")
	local VirtualInputManager = game:GetService("VirtualInputManager")

	local function pressEnter()
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
		task.wait()
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
	end

	local function autoFlow()
		local gui = LocalPlayer:WaitForChild("PlayerGui")
		local match = gui:WaitForChild("Match")
		local topFrame = match:WaitForChild("TopFrame")

		local skipWave = topFrame:WaitForChild("SkipWave")
		local autoSkipBtn = topFrame:WaitForChild("AutoSkip"):WaitForChild("OnAndOff")

		while true do
			if skipWave.Visible then
				GuiService.SelectedObject = skipWave
				task.wait(0.2)
				pressEnter()
				task.wait(0.2)
				GuiService.SelectedObject = nil
			end

			local currentColor = autoSkipBtn.BackgroundColor3

			if currentColor == Color3.fromRGB(255, 0, 0) then
				GuiService.SelectedObject = autoSkipBtn
				task.wait(0.2)
				pressEnter()
				task.wait(0.2)
				GuiService.SelectedObject = nil
			end

			task.wait(0.5)
		end
	end

	task.spawn(autoFlow)
end


if game.PlaceId == PLACE_A then
	runPlaceA()

elseif game.PlaceId == PLACE_B then
	task.wait(1)
	runPlaceB()

elseif game.PlaceId == PLACE_C then
	runPlaceC()
end
