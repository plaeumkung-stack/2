-- ============================================================
-- Trade Auto Items | UI: Rayfield (Mobile & PC Friendly)
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "💱 Trade Auto Items",
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
-- Trade Tab
-- ============================================================
local TradeTab = Window:CreateTab("Trade", 4483362458)

TradeTab:CreateButton({
	Name = "Set Carte",
	Callback = function()
        fireItems({
            {"Celestial Mark", 1}, {"Aero Core", 3}, {"Gale Essence", 8},
            {"Tide Remnant", 14}, {"Tempest Relic", 25},
        })
        notify('✅ Carte — ใส่ครบแล้ว')
  	end    
})

TradeTab:CreateButton({
	Name = "Atomic Core",
	Callback = function()
        fireItems({
            {"Atomic Core", 1},
        })
        notify('✅ Aromic Core — ใส่ครบแล้ว')
  	end    
})

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
	Name = "Set Rimuru",
	Callback = function()
        fireItems({
            {"Slime Core", 1}, {"Slime Remnant", 3}, {"Tempest Seal", 6}, {"Sage Pulse", 9},
        })
        notify('✅ Rimuru — ใส่ครบแล้ว')
  	end    
})

TradeTab:CreateButton({
	Name = "Set Gilgamesh",
	Callback = function()
        fireItems({
            {"Throne Remnant", 12}, {"Ancient Shard", 6}, {"Golden Essence", 3}, {"Phantasm Core", 1},
        })
        notify('✅ Gilgamesh — ใส่ครบแล้ว')
  	end    
})

TradeTab:CreateButton({
	Name = "Set Alucard",
	Callback = function()
        fireItems({
            {"Soul Amulet", 5}, {"Blood Ring", 1}, {"Casull", 1},
        })
        notify('✅ Alucard — ใส่ครบแล้ว')
  	end    
})

TradeTab:CreateButton({
	Name = "Set Shadow V1",
	Callback = function()
        fireItems({
            {"Atomic Core", 1}, {"Shadow Essence", 4}, {"Void Seed", 8}, {"Umbral Capsule", 20},
        })
        notify('✅ Shadow V1 — ใส่ครบแล้ว')
  	end    
})

TradeTab:CreateButton({
	Name = "Set Shadow V2",
	Callback = function()
        fireItems({
            {"Atomic Omen", 1}, {"Eminence Essence", 3}, {"Shadow Remnant", 9}, {"Magic Shard", 16}, {"Abyss Sigil", 80},
        })
        notify('✅ Shadow V2 — ใส่ครบแล้ว')
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

-- ============================================================
-- Dio Set Tab
-- ============================================================
local DioTab = Window:CreateTab("Dio Set", 4483362458)

local DIO_BASE = {
    {"Vampire Omen",   2},
    {"World Core",     6},
    {"Time Remnant",   12},
    {"Power Fragment", 20},
    {"Dominion Brand", 140},
}

local function SetDio(mult)
    local scaled = {}
    for _, item in ipairs(DIO_BASE) do
        table.insert(scaled, {item[1], item[2] * mult})
    end
    fireItems(scaled)
    notify(string.format('✅ Dio x%d — ใส่ครบแล้ว', mult))
end

DioTab:CreateButton({
	Name = "Set Dio  ×1",
	Callback = function() SetDio(1) end    
})

DioTab:CreateButton({
	Name = "Set Dio  ×5",
	Callback = function() SetDio(5) end    
})

DioTab:CreateButton({
	Name = "Set Dio  ×10",
	Callback = function() SetDio(10) end    
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
