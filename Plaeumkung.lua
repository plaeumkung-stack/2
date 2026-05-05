local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "PK-HUB | SLIME RNG V2",
   LoadingTitle = "PK-HUB IS STARTING...",
   LoadingSubtitle = "by Plaeumkung",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local MainTab = Window:CreateTab("Main Farm", 4483362458)

-- ── ฟังก์ชันใหม่: AUTO EQUIP BEST SLIME ──────────────────────
MainTab:AddSection(" Slime Management ")

MainTab:AddToggle({
   Name = "Auto Best Slime (ใส่สไลม์ที่โหดที่สุด)",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().AutoBest = Value
      task.spawn(function()
         while getgenv().AutoBest do
            pcall(function()
                -- สั่งให้ระบบเลือกสวมใส่สไลม์ที่ดีที่สุดอัตโนมัติ
                -- ส่วนใหญ่แมพ RNG จะมี Remote สำหรับสวมใส่ตัวที่ดีที่สุด
                game:GetService("ReplicatedStorage").Events.EquipBest:FireServer()
            end)
            task.wait(5) -- เช็กทุกๆ 5 วินาที
         end
      end)
   end,
})

-- ── ฟังก์ชันเดิมที่ปรับปรุงให้เสถียรขึ้น ──────────────────────────
MainTab:AddSection(" Auto Farm ")

MainTab:AddToggle({
   Name = "Auto Roll (สุ่มรัวๆ)",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().AutoRoll = Value
      task.spawn(function()
         while getgenv().AutoRoll do
            pcall(function() game:GetService("ReplicatedStorage").Events.Roll:FireServer() end)
            task.wait(0.1)
         end
      end)
   end,
})

MainTab:AddToggle({
   Name = "Item Magnet (ดูดของแอปเปิ้ล/แครอท/ยา)",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().Magnet = Value
      task.spawn(function()
         while getgenv().Magnet do
            pcall(function()
                local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                -- กวาดไอเทมตามชื่อใน Wiki
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("TouchTransmitter")
                                        
