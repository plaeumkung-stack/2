local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "PK-HUB | APOCALYPSE PRO",
   LoadingTitle = "PK-HUB LOADING...",
   LoadingSubtitle = "by Plaeumkung",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:AddSlider({
   Name = "Speed Hack",
   Min = 16,
   Max = 150,
   Default = 16,
   Color = Color3.fromRGB(255, 255, 255),
   Increment = 1,
   Suffix = "Speed",
   Callback = function(Value)
      getgenv().Spd = Value
      task.spawn(function()
          while getgenv().Spd == Value do
              pcall(function()
                  game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
              end)
              task.wait()
          end
      end)
   end,
})

MainTab:AddToggle({
   Name = "Kill Aura",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().Aura = Value
      task.spawn(function()
         while getgenv().Aura do
            pcall(function()
               local char = game.Players.LocalPlayer.Character
               local tool = char:FindFirstChildOfClass("Tool")
               for _, v in pairs(game.Workspace:GetChildren()) do
                  if v:FindFirstChild("Humanoid") and v.Name ~= game.Players.LocalPlayer.Name then
                     local mag = (char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                     if mag < 20 then
                        if tool then
                            tool:Activate()
                            firetouchinterest(v.HumanoidRootPart, tool.Handle, 0)
                            firetouchinterest(v.HumanoidRootPart, tool.Handle, 1)
                        end
                     end
                  end
               end
            end)
            task.wait(0.1)
         end
      end)
   end,
})

MainTab:AddToggle({
   Name = "God Mode",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().God = Value
      task.spawn(function()
          while getgenv().God do
              pcall(function()
                  game.Players.LocalPlayer.Character.Humanoid.Health = game.Players.LocalPlayer.Character.Humanoid.MaxHealth
              end)
              task.wait()
          end
      end)
   end,
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:AddToggle({
   Name = "Auto Eat/Drink",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().Eat = Value
      task.spawn(function()
         while getgenv().Eat do
            pcall(function()
               local bp = game.Players.LocalPlayer.Backpack
               local char = game.Players.LocalPlayer.Character
               for _, v in pairs(bp:GetChildren()) do
                  if v:IsA("Tool") then
                     v.Parent = char
                     task.wait(0.1)
                     v:Activate()
                     task.wait(0.1)
                     v.Parent = bp
                  end
               end
            end)
            task.wait(2)
         end
      end)
   end,
})

