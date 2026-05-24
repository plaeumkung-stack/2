-- [[ PK-MODIFIED LOADER | BYPASS VERSION ]] --
if not game:IsLoaded() then
    game.Loaded:Wait()
end

repeat
    task.wait()
until game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")

-- ลิสต์คลังสคริปต์ของ BenJaminX
local GameScripts = {
    [9091133975] = "https://auth.syscure.vip/obf/ba942cb1b4f3b9a9449b4796a71a85e1.lua",
    [9348272796] = "https://auth.syscure.vip/obf/b2745278dd655e65582488204ec283e1.lua",
    [10006104044] = "https://auth.syscure.vip/obf/64477b571bf497a5ec503bd226ff5b54.lua"
}

-- เช็กชื่อตัวรันปัจจุบัน
local currentExecutor = ((identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Unknown")
print("PK-LOG | Running on Executor: " .. currentExecutor)

-- [ BYPASS ] ระบบโหลดสคริปต์แบบบังคับรัน ไม่สนการบล็อกแมพ
local currentId = game.GameId
local targetSrc = GameScripts[currentId]

if targetSrc then
    print("✅ Found matching game! Loading script...")
    loadstring(game:HttpGet(targetSrc))()
else
    -- ถ้าแมพที่มึงเล่นอยู่ไม่ตรงกับ ID ด้านบน มันจะบังคับดึงตัวล่าสุด (ตัวที่ 3) มารันเผื่อฟลุ๊คติดทันที
    print("⚠️ Game not explicitly supported, bypassing to last known script...")
    local bypassSrc = GameScripts[10006104044] -- บังคับดึงลิงก์นี้มาลองรัน
    pcall(function()
        loadstring(game:HttpGet(bypassSrc))()
    end)
end
