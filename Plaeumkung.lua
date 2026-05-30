function GetMyCar()
    for _, v in next, workspace.Vehicles:GetChildren() do if v:GetAttribute("Owner") == LocalPlayer.Name then return v end end
end

function ReapplyAllParts()
    for _, v in next, workspace.MoveableParts:GetChildren() do if v:GetAttribute("Owner") == LocalPlayer.Name then local Car = GetMyCar() if Car and Car:FindFirstChild("PartsEvent") then Car.PartsEvent:FireServer("ReapplyPart", v) end end end
end

function RemoveAllParts()
    local Car = GetMyCar()
    if not Car then return end
    local Body = Car:FindFirstChild("Body")
    if not Body then return end
    local EngineBay = Body:FindFirstChild("EngineBay")
    if not EngineBay then return end
    for _, v in next, EngineBay:GetChildren() do if Car:FindFirstChild("PartsEvent") then Car.PartsEvent:FireServer("RemovePart", v.Name) end
    end
end
