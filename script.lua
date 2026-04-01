task.wait(2)

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

-- =========================
-- 🔥 UI
-- =========================

local gui = Instance.new("ScreenGui", player.PlayerGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,150)
frame.Position = UDim2.new(0,20,0.5,-75)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local function makeButton(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,0,0,40)
    b.Position = UDim2.new(0,0,0,y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.new(1,1,1)
    return b
end

local bestBtn = makeButton("💰 Best Income", 0)
local rareBtn = makeButton("⭐ Rarest", 50)
local tpBtn = makeButton("📍 TP", 100)

-- =========================
-- 🔥 VARIABLES
-- =========================

local currentTarget = nil
local line = nil
local billboard = nil

-- =========================
-- 🔥 TROUVER BRAINROT
-- =========================

local function getMoney(model)
    for _,v in ipairs(model:GetDescendants()) do
        if v:IsA("TextLabel") and string.find(v.Text, "%$/s") then
            return v.Text
        end
    end
    return "?"
end

local function findBest()
    local best = nil
    local bestValue = 0

    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChildWhichIsA("BasePart") then
            
            local txt = getMoney(v)
            local num = tonumber(txt:match("%d+"))

            if num and num > bestValue then
                bestValue = num
                best = v
            end
        end
    end

    return best
end

local function findRarest()
    local last = nil

    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") then
            last = v
        end
    end

    return last
end

-- =========================
-- 🔥 VISUEL
-- =========================

local function clearVisual()
    if line then line:Destroy() end
    if billboard then billboard:Destroy() end
end

local function showTarget(model)
    clearVisual()

    if not model then return end
    currentTarget = model

    local part = model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    -- 🔥 Billboard (nom + argent)
    billboard = Instance.new("BillboardGui", part)
    billboard.Size = UDim2.new(0,200,0,50)
    billboard.StudsOffset = Vector3.new(0,3,0)

    local text = Instance.new("TextLabel", billboard)
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1,1,0)
    text.TextScaled = true
    text.Text = model.Name .. "\n" .. getMoney(model)

    -- 🔥 ligne
    line = Instance.new("Beam")

    local a0 = Instance.new("Attachment", player.Character.Head)
    local a1 = Instance.new("Attachment", part)

    line.Attachment0 = a0
    line.Attachment1 = a1
    line.Width0 = 0.2
    line.Width1 = 0.2
    line.Color = ColorSequence.new(Color3.new(1,1,0))
    line.Parent = player.Character.Head
end

-- =========================
-- 🔥 ACTIONS
-- =========================

bestBtn.MouseButton1Click:Connect(function()
    local target = findBest()
    showTarget(target)
end)

rareBtn.MouseButton1Click:Connect(function()
    local target = findRarest()
    showTarget(target)
end)

tpBtn.MouseButton1Click:Connect(function()
    if currentTarget and player.Character then
        local part = currentTarget:FindFirstChildWhichIsA("BasePart")
        if part then
            player.Character:MoveTo(part.Position + Vector3.new(0,3,0))
        end
    end
end)
