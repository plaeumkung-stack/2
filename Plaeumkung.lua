if not getrawmetatable then
    print("แม่งไม่รองรับ getrawmetatable! ไปใช้ Arceus X Neo หรือ Hydrogen ซะ")
    return
end

local mt = getrawmetatable(game)
local old = mt.__namecall

setreadonly(mt, false)

local function namecallHook(...)
    local method = getnamecallmethod()
    local args = {...}
    
    if method == "FireServer" and type(args[1]) == "userdata" and args[1]:IsA("RemoteEvent") then
        local remote = args[1]
        local realArgs = {select(2, ...)}
        print("[🔥FireServer]", remote:GetFullName(), "Args:", unpack(realArgs))
        
    elseif method == "InvokeServer" and type(args[1]) == "userdata" and args[1]:IsA("RemoteFunction") then
        local remote = args[1]
        local realArgs = {select(2, ...)}
        print("[🔥InvokeServer]", remote:GetFullName(), "Args:", unpack(realArgs))
    end
    
    return old(...)
end

if newcclosure then
    mt.__namecall = newcclosure(namecallHook)
else
    mt.__namecall = namecallHook
end

print("✅ Remote Spy Active! ไปเล่นเกมเลย แล้วคอยดูคอนโซล")
