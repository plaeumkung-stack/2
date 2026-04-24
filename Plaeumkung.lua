local Flux = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua"))() -- ใช้ Fluent แทน (ตัวนี้สวยและใหม่กว่า)
local Window = Flux:CreateWindow({
    Title = "PK-HUB | GIANT EDITION",
    SubTitle = "by Plaeumkung",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 320), -- ขนาดกะทัดรัดสำหรับมือถือ
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- [[ ปุ่มขยายร่าง ]] --
Tabs.Main:AddButton({
    Title = "ขยายร่างใหญ่ (Giant Mode)",
    Description = "ทำให้ตัวมึงใหญ่ยักษ์ (ใช้ได้ในแมพตัวเอง)",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            local s = 5 -- อยากใหญ่กว่านี้แก้เลขนี้
            
            hum:WaitForChild("HeadScale").Value = s
            hum:WaitForChild("BodyDepthScale").Value = s
            hum:WaitForChild("BodyWidthScale").Value = s
            hum:WaitForChild("BodyHeightScale").Value = s
            
            Window:Dialog({
                Title = "System",
                Content = "ขยายร่างสำเร็จแล้วโบร!",
                Buttons = { { Title = "OK", Variant = "Primary" } }
            })
        end
    end
})

-- [[ ปุ่มกลับร่างเดิม ]] --
Tabs.Main:AddButton({
    Title = "กลับร่างปกติ (Reset Size)",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            hum:WaitForChild("HeadScale").Value = 1
            hum:WaitForChild("BodyDepthScale").Value = 1
            hum:WaitForChild("BodyWidthScale").Value = 1
            hum:WaitForChild("BodyHeightScale").Value = 1
        end
    end
})

-- [[ ระบบปิด UI ]] --
Tabs.Settings:AddKeybind("ToggleBind", {
    Title = "ปุ่มเปิด/ปิดเมนู",
    Default = "RightControl",
    ChangedCallback = function(New)
        print("Bind changed to:", New)
    end
})

Window:SelectTab(1)
end

-- ============================================================
-- Trade Tab
-- ============================================================
local TradeTab = Window:CreateTab("Trade", 4483362458)

TradeTab:CreateButton({
	Name = "Set Rank",
	Callback = function()
        fireItems({
            {"Atomic Core", 2}, {"Blood Ring", 4}, {"Cursed Flesh", 2},
            {"HÅgyoku Fragment", 2}, {"Infinity Essence", 2}, {"Phantasm Core", 2},
            {"Slime Core", 3}, {"Soul Flame", 3}, {"Reiatsu Core", 4},
            {"Dark Ring", 5}, {"Dismantle Fang", 7}, {"Void Fragment", 5},
            {"Limitless Ring", 2}, {"Azure Heart", 2}, {"Evolution Fragment", 2},
            {"Path Fragment", 2}, {"Corrupt Crown", 3},
        })
        notify('✅ Rank — ใส่ครบ 17 อย่างแล้ว')
  	end    
})

TradeTab:CreateButton({
	Name = "Set Madara",
	Callback = function()
        fireItems({
            {"Path Fragment", 3}, {"Eternal Core", 8}, {"Battle Sigil", 18}, {"Power Remnant", 15},
        })
        notify('✅ Madara — ใส่ครบแล้ว')
  	end    
})

TradeTab:CreateButton({
	Name = "Set Moon Slayer+F",
	Callback = function()
        fireItems({
            {"Moon Crest", 3}, {"Crescent Shard", 14}, {"Lunar Essence", 9}, {"Demon Remnant", 16}, {"Upper Seal", 110},
        })
        notify('✅ Moon Slayer+F — ใส่ครบแล้ว')
  	end    
})

TradeTab:CreateButton({
	Name = "Set Garo",
	Callback = function()
        fireItems({
            {"Monster Pulse", 20}, {"Galaxy Shard", 50}, {"Star Mark", 80}, {"Cosmic Essence", 120},
        })
        notify('✅ Garo — ใส่ครบแล้ว')
  	end    
})


TradeTab:CreateButton({
	Name = "Set Dio",
	Callback = function()
        fireItems({
            {"Vampire Omen", 2}, {"World Core", 6}, {"Time Remnant", 12}, {"Domonion Brand", 80}, {"Powe Fragment", 20}, 
        })
        notify('✅ Dio — ใส่ครบแล้ว')
  	end    
})
-- ============================================================
-- Relic Set Tab
-- ============================================================
local RelicTab = Window:CreateTab("Relic Set", 4483362458)

RelicTab:CreateButton({
	Name = "Set Relic (Parts 1-8)",
	Callback = function()
        fireItems({
            {"Relic Part #1", 70}, {"Relic Part #2", 15},
            {"Relic Part #3", 75}, {"Relic Part #4", 20},
            {"Relic Part #5", 30}, {"Relic Part #6", 25},
            {"Relic Part #7", 40}, {"Relic Part #8", 30},
        })
        notify('✅ Relic Set — ใส่ครบแล้ว')
  	end    
})

-- Notify success loading
notify("โหลด UI เสร็จสมบูรณ์! พร้อมใช้งาน")
