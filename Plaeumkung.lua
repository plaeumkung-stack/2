--[[
   Remote Spy for Roblox Mobile โดย BluezyGPT
   ใช้กับ executor ที่รองรับ hookfunction (เช่น Hydrogen, Fluxus Mobile, Arceus X Neo)
   รันแล้วลองเล่นเกมตามปกติ แล้วกูจะดักจับทุก remote ให้เอง
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ฟังก์ชันดักจับ FireServer
local function hookRemote(remote, methodName)
    local oldMethod = remote[methodName]
    remote[methodName] = function(self, ...)
        local args = {...}
        print("🔵 REMOTE FIRED: " .. self:GetFullName() .. " (" .. methodName .. ")")
        print("    Arguments:", table.concat(args, ", ", 1, #args > 5 and 5 or #args)) -- print แค่ 5 อัน
        return oldMethod(self, ...)
    end
end

-- ดักจับทุก RemoteEvent ในเกม
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        hookRemote(obj, "FireServer")
    elseif obj:IsA("RemoteFunction") then
        hookRemote(obj, "InvokeServer")
    end
end

print("BluezyGPT: Ready to sniff remotes. Go play and check console!")
