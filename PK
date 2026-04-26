-- ============================================================
-- Trade Auto Items | UI: Rayfield (Mobile & PC Friendly)
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Auto trade PLAEUMKUNG",
   LoadingTitle = "กำลังโหลด Trade Auto...",
   LoadingSubtitle = "Mobile Version",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

-- ── Helper ──────────────────────────────────────────────────
local function notify(msg)
    Rayfield:Notify({
        Title = "System",
        Content = msg,
        Duration = 3,
        Image = 4483345998,
    })
end

local function getTradeRemote()
    return game:GetService("ReplicatedStorage")
        :WaitForChild("Remotes")
        :WaitForChild("TradeRemotes")
        :WaitForChild("AddItemToTrade")
end

local function fireItems(items)
    local remote = getTradeRemote()
    for _, item in ipairs(items) do
        remote:FireServer("Items", item[1], item[2])
        task.wait(0.5)
    end
end

-- ============================================================
-- Hot Set Tab
-- ============================================================
local HotSetTab = Window:CreateTab("Hot Set", 4483362458)

HotSetTab:CreateButton({
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

HotSetTab:CreateButton({
	Name = "Easter Egg×10000",
	Callback = function()
        fireItems({
            {"Easter Egg", 10000},  
        })
        notify('✅ Easter Egg×10000 — ใส่ครบแล้ว')
  	end    
})

HotSetTab:CreateButton({
	Name = "Aura×100",
	Callback = function()
        fireItems({
            {"Aura Crate", 1000},  
        })
        notify('✅ Aura×1000 — ใส่ครบแล้ว')
  	end    
})

HotSetTab:CreateButton({
	Name = "Spaw Dio×10000",
	Callback = function()
        fireItems({
            {"Dominion Brand", 10000},  
        })
        notify('✅ Spaw Dio×10000 — ใส่ครบแล้ว')
  	end    
})

HotSetTab:CreateButton({
	Name = "BloodLine×50000",
	Callback = function()
        fireItems({
            {"Bloodline Stone", 50000},  
        })
        notify('✅ BloodLine×50000 — ใส่ครบแล้ว')
  	end    
})

-- ============================================================
-- Trade Tab
-- ============================================================
local TradeTab = Window:CreateTab("Trade", 4483362458)

TradeTab:CreateButton({
	Name = "Set Rank",
	Callback = function()
        fireItems({
            {"Atomic Core", 2}, {"Blood Ring", 4}, {"Cursed Flesh", 2},
            {"Hōgyoku Fragment", 2}, {"Infinity Essence", 2}, {"Phantasm Core", 2},
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
	Name = "Set Esdeath",
	Callback = function()
        fireItems({
            {"Ice Core", 3}, {"Frozen Brand", 14}, {"Glacier Remnant", 9}, {"Battle Shard", 17}, {"Frost Relic", 110},
        })
        notify('✅ Esdeath — ใส่ครบแล้ว')
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

-- Notify success loading
notify("โหลด UI เสร็จสมบูรณ์! พร้อมใช้งาน")
