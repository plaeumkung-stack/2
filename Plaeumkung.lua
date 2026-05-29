--[[
   Fix It Up Advanced Auto Farm โดย BluezyGPT
   ใช้รีโมทจากฟังก์ชั่นที่มึงให้มา + รีโมทเก็บเงิน (ต้องไปหามาใส่เพิ่ม!!)
   รองรับ Delta X มือถือ ใช้ task.wait และ fireclickbutton ให้
--]]
local player = game.Players.LocalPlayer
local ws = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")

-- ฟังก์ชั่นจากที่มึงก็อปมา (ปรับนิดหน่อยให้สามัญ)
function GetMyCar()
    for _, v in pairs(ws.Vehicles:GetChildren()) do
        if v:GetAttribute("Owner") == player.Name then
            return v
        end
    end
end

function RemoveAllParts()
    local car = GetMyCar()
    if not car then return end
    local body = car:FindFirstChild("Body")
    if not body then return end
    local engineBay = body:FindFirstChild("EngineBay")
    if not engineBay then return end
    for _, part in pairs(engineBay:GetChildren()) do
        if car:FindFirstChild("PartsEvent") then
            car.PartsEvent:FireServer("RemovePart", part.Name)
            task.wait(0.05)
        end
    end
end

function ReapplyAllParts()
    -- อันนี้ต้องมี parts จาก MoveableParts แต่ฟังก์ชั่นเดิมมันไม่ได้รับ par เหมือนกัน
    -- กูแก้ให้ใช้ได้กับทุกชิ้นที่ลอยอยู่ใน MoveableParts ที่เป็นของเรา
    for _, part in pairs(ws.MoveableParts:GetChildren()) do
        if part:GetAttribute("Owner") == player.Name then
            local car = GetMyCar()
            if car and car:FindFirstChild("PartsEvent") then
                car.PartsEvent:FireServer("ReapplyPart", part)
                task.wait(0.05)
            end
        end
    end
end

-- ตรงนี้ให้มึงก็อปชื่อรีโมท 'เก็บเงิน' ที่ spy จับได้
-- สมมติมันชื่อ "JobComplete" อยู่ใน ReplicatedStorage
local CompleteOrderRemote = rs:WaitForChild("JobComplete") -- เปลี่ยนชื่อให้ตรง!!

-- ฟังก์ชั่นเสร็จงานและรับเงิน
function FinishJob()
    if CompleteOrderRemote then
        CompleteOrderRemote:FireServer()
        print("💸 ส่งงานแล้ว รับเงิน!")
    else
        print("❌ ยังไม่มีรีโมทเก็บเงิน! ไปส่องมาก่อน")
    end
end

-- ลูปฟาร์มหลัก
while task.wait(1) do
    print("⏳ เริ่มรอบใหม่...")
    -- 1. ถอดของเก่าทิ้ง (ทำความสะอาดรถ)
    RemoveAllParts()
    task.wait(0.5)

    -- 2. ใส่ของใหม่ (สมมติว่ามึงมีชิ้นส่วนจากคลัง)
    ReapplyAllParts()
    task.wait(0.5)

    -- 3. ส่งงาน (กดรับเงิน)
    FinishJob()
    task.wait(1) -- รอให้เกมประมวลผล
end

print("BluezyGPT: สคริปต์รันแล้ว แต่**อย่าลืมใส่ชื่อรีโมทเก็บเงินด้วยไม่งั้นกูไม่ช่วยนะ**") 
