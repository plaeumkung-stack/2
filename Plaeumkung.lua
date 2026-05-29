--[[
   Fix It Up Auto Farm for Delta X (by BluezyGPT)
   ใช้กับ Delta X exploit เท่านั้น (ตรวจเวอร์ชั่นแล้ว)
   มันจะรัน loop รับงาน-ซ่อม-เก็บเงิน แบบไม่ต้องแตะเมาส์
--]]

local plr = game:GetService("Players").LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local ts = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")

-- ฟังก์ชันเทเลพอร์ตแบบ Instant (ไม่กระตุก)
local function tp(pos)
    if hrp then hrp.CFrame = CFrame.new(pos) end
end

-- ฟังก์ชันกดปุ่ม UI แบบ Delta X (ใช้ firetouchinterest ได้ด้วย)
local function click(part)
    if part and part:IsA("BasePart") and part.CanTouch then
        firetouchinterest(hrp, part, 0) -- จำลองการแตะ
    end
end

-- ฟังก์ชันหาปุ่ม/ออบเจคตามชื่อ (ปรับตามแมพจริง)
local function findObj(name)
    return workspace:FindFirstChild(name, true) -- หาลูกหลาน
end

-- เริ่มฟาร์มแบบไม่มีสิ้นสุด
local waittime = 0.2
while task.wait(waittime) do
    -- 1. ไปจุดรับออร์เดอร์
    local orderNPC = findObj("OrderCounter") or findObj("NPC_Work")
    if orderNPC then
        tp(orderNPC.Position + Vector3.new(0,5,0))
        wait(0.2)
        -- 2. จำลองกดรับงาน (Delta X ยิง remote ได้ตรง)
        local getJob = game:GetService("ReplicatedStorage"):FindFirstChild("RequestJob") or
                       game:GetService("ReplicatedStorage"):FindFirstChild("GetNewOrder")
        if getJob then
            getJob:FireServer()
        else
            -- fallback: แตะปุ่มที่ NPC
            click(orderNPC)
        end
    end

    wait(0.5)

    -- 3. ไปจุดซ่อม (สมมติมี lift 1)
    local lift = findObj("Lift1") or findObj("CarFixStation")
    if lift then
        tp(lift.Position)
        wait(0.2)
        -- 4. กดซ่อมทุกส่วน (ส่ง remote ซ่อมเลย)
        local fixPart = game:GetService("ReplicatedStorage"):FindFirstChild("FixPart")
        if fixPart then
            for i = 1, 5 do -- ส่งหลายครั้งกันพลาด
                fixPart:FireServer("engine", "repair")
                fixPart:FireServer("tire", "repair")
                wait(0.05)
            end
        end
    end

    wait(1)

    -- 5. กลับไปรับเงิน
    if orderNPC then
        tp(orderNPC.Position + Vector3.new(0,5,0))
        local collectCash = game:GetService("ReplicatedStorage"):FindFirstChild("FinishJob")
        if collectCash then
            collectCash:FireServer()
        else
            click(orderNPC)
        end
    end
end

