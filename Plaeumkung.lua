-- Method 2: ถอดรหัสจาก LocalScript
local function findRemotesInScripts()
    for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj:IsA("LocalScript") then
            local funcs = {}
            if getscriptfunctions then
                funcs = getscriptfunctions(obj) or {}
            elseif getsenv then
                local env = getsenv(obj)
                if env then
                    for _, v in pairs(env) do
                        if type(v) == "function" then
                            table.insert(funcs, v)
                        end
                    end
                end
            end
            for _, f in pairs(funcs) do
                local consts = debug.getconstants and debug.getconstants(f)
                if consts then
                    for _, c in pairs(consts) do
                        if typeof(c) == "Instance" and (c:IsA("RemoteEvent") or c:IsA("RemoteFunction")) then
                            print("[LocalScript]", obj:GetFullName(), "contains remote:", c:GetFullName())
                        end
                    end
                end
            end
        end
    end
end
findRemotesInScripts()
