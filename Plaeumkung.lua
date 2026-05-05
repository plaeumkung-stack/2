local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "PK-HUB | SLIME RNG PRO",
   LoadingTitle = "Slime RNG Wiki-Edition",
   LoadingSubtitle = "by Plaeumkung",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local MainTab = Window:CreateTab("Auto Farm", 4483362458)

-- [[ 1. AUTO ROLL & AUTO POTION ]] --
MainTab:AddToggle({
   Name = "Infinite Roll (สุ่มไม่หยุด)",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().Rolling = Value
      task.spawn(function()
         while getgenv().Rolling do
            pcall(function()
                game:GetService("ReplicatedStorage").Events.Roll:FireServer()
            end)
            task.wait(0.05)
         end
      end)
   end,
})

-- [[ 2. WIKI ITEM MAGNET (ดูดของดรอป) ]] --
MainTab:AddToggle({
   Name = "Item Magnet (ดูดแอปเปิ้ล/แครอท/โพชั่น)",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().Magnet = Value
      task.spawn(function()
         while getgenv().Magnet do
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                -- เช็กโฟลเดอร์ไอเทมตามข้อมูล Wiki
                local itemFolders = {workspace:FindFirstChild("Items"), workspace:FindFirstChild("SpawnedItems"), workspace}
                for _, folder in pairs(itemFolders) do
                    if folder then
                        for _, v in pairs(folder:GetChildren()) do
                            -- กรองเอาเฉพาะไอเทมที่ใช้ได้ (Apple, Carrot, Potion)
                            if v:IsA("Tool") or v:FindFirstChild("Handle") or v:IsA("BasePart") then
                                if v.Name:find("Apple") or v.Name:find("Carrot") or v.Name:find("Potion") or v.Name:find("Luck") then
                                    v.CFrame = char.HumanoidRootPart.CFrame
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(1)
         end
      end)
   end,
})

-- [[ 3. AUTO USE POTIONS (กดใช้ยาอัตโนมัติ) ]] --
MainTab:AddToggle({
   Name = "Auto Use Potions (กดใช้ยาทันที)",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().AutoUse = Value
      task.spawn(function()
         while getgenv().AutoUse do
            pcall(function()
               local bp = game.Players.LocalPlayer.Backpack
               for _, p in pairs(bp:GetChildren()) do
                  if p.Name:find("Potion") or p.Name:find("Luck") then
                     p.Parent = game.Players.LocalPlayer.Character
                     task.wait(0.1)
                     p:Activate()
                     task.wait(0.1)
                     p.Parent = bp
                  end
               end
            end)
            task.wait(2)
         end
      end)
   end,
})

-- [[ MISC & UTILS ]] --
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:AddButton({
   Name = "Anti-AFK",
   Callback = function()
      local vu = game:GetService("VirtualUser")
      game:GetService("Players").LocalPlayer.Idled:Connect(function()
         vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
         task.wait(1)
         vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
      end)
   end,
})

MiscTab:AddSlider({
   Name = "WalkSpeed",
   Min = 16, Max = 200, Default = 16, Increment = 1,
   Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end
})
