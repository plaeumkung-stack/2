local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "PK-HUB | APOCALYPSE PRO",
   LoadingTitle = "กำลังเจาะระบบเอาชีวิตรอด...",
   LoadingSubtitle = "by Plaeumkung",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

-- ── Fix Speed Hack (แบบไม่วาร์ปกลับ) ──────────────────────
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:AddSlider({
   Name = "Speed Hack (เดินเนียน)",
   Min = 16,
   Max = 100,
   Default = 16,
   Color = Color3.fromRGB(255, 255, 255),
   Increment = 1,
   Suffix = "Speed",
   Callback = function(Value)
      -- ใช้คำสั่งแบบนี้จะลดการโดนดึงกลับ
      getgenv().WalkSpeedValue = Value
      task.spawn(function()
          while getgenv().WalkSpeedValue == Value do
              game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = Value
              task.wait(0.1)
          end
      end)
   end,
})

-- ── Fix Kill Aura (แบบเนียนๆ) ─────────────────────────────
MainTab:AddToggle({
   Name = "Kill Aura (ตีกระจายรอบตัว)",
   CurrentValue = false,
   Flag = "KillAura",
   Callback = function(Value)
      getgenv().KillAura = Value
      task.spawn(function()
         while getgenv().KillAura do
            pcall(function()
               for _, v in pairs(game.Workspace:GetChildren()) do
                  if v:FindFirstChild("Humanoid") and v.Name ~= game.Players.LocalPlayer.Name then
                     local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                     if dist < 15 then
                        -- จำลองการคลิกตี (ใช้ได้กับเกือบทุกแมพ)
                        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool then 
                            tool:Activate() 
                            firetouchinterest(v.HumanoidRootPart, tool.Handle, 0)
                            firetouchinterest(v.HumanoidRootPart, tool.Handle, 1)
                        end
                     end
                  end
               end
            end)
            task.wait(0.2)
         end
      end)
   end,
})

-- ── Fix God Mode (แบบล่องหนเลือด) ──────────────────────────
MainTab:AddToggle({
   Name = "Semi-God Mode",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().GodMode = Value
      if Value then
          -- วิธีแก้เผื่อ God Mode ตรงๆ โดนดัก คือการลบส่วนเจ็บออก (ใช้ได้บางแมพ)
          local char = game.Players.LocalPlayer.Character
          if char:FindFirstChild("Animate") then char.Animate:Destroy() end
      end
   end,
})

-- ── Fix Auto Eat (แก้ปัญหาใช้ไม่ได้) ──────────────────────────
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:AddToggle({
   Name = "Auto Eat/Drink (กินออโต้)",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().AutoEat = Value
      task.spawn(function()
         while getgenv().AutoEat do
            pcall(function()
               for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                  if v.Name:find("Food") or v.Name:find("Water") or v.Name:find("Drink") then
                     v.Parent = game.Players.LocalPlayer.Character
                     v:Activate()
                     task.wait(0.5)
                     v.Parent = game.Players.LocalPlayer.Backpack
                  end
               end
            end)
            task.wait(5)
         end
      end)
   end,
})

-- ── ปุ่มพับ UI ─────────────────────────────────────────────
Rayfield:Notify({
   Title = "PK-HUB Ready!",
   Content = "กดปุ่ม 'RightControl' หรือปุ่มที่ตั้งไว้เพื่อพับหน้าจอ",
   Duration = 5,
})
