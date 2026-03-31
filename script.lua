task.wait(2)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- UI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local label = Instance.new("TextLabel", gui)
label.Size = UDim2.new(0,320,0,50)
label.Position = UDim2.new(0.5,-160,0,20)
label.BackgroundTransparency = 0.3
label.BackgroundColor3 = Color3.fromRGB(0,0,0)
label.TextColor3 = Color3.fromRGB(255,255,255)
label.TextScaled = true

-- Highlight
local highlight = Instance.new("Highlight")
highlight.FillColor = Color3.fromRGB(255, 220, 0)
highlight.OutlineColor = Color3.fromRGB(0,0,0)
highlight.FillTransparency = 0.3

local currentTarget = nil

-- Détection du meilleur
local function getBestBrainrot()
    local best = nil
    local bestValue = 0

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:find("Brainrot") then
            
            local value = 0
            if v.Name:find("Secret") then value = 4 end
            if v.Name:find("God") then value = 3 end
            if v.Name:find("Mythic") then value = 2 end

            if value > bestValue then
                bestValue = value
                best = v
            end
        end
    end

    return best
end

-- Scan loop
task.spawn(function()
    while task.wait(1) do
        local best = getBestBrainrot()
        currentTarget = best

        if best and best.PrimaryPart then
            highlight.Parent = best

            local char = player.Character
            if char and char.PrimaryPart then
                local dist = (char.PrimaryPart.Position - best.PrimaryPart.Position).Magnitude
                label.Text = "🔥 Best: "..best.Name.." | "..math.floor(dist).." studs | Press F"
            end
        else
            highlight.Parent = nil
            label.Text = "No brainrot found"
        end
    end
end)

-- TP MANUEL (touche F)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        if currentTarget and currentTarget.PrimaryPart then
            local char = player.Character
            if char and char.PrimaryPart then
                char:SetPrimaryPartCFrame(currentTarget.PrimaryPart.CFrame + Vector3.new(0,5,0))
            end
        end
    end
end)
