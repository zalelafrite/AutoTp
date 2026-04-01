task.wait(2)

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- =========================
-- 🔥 UI PROPRE (DRAG + MINIMIZE)
-- =========================

local gui = Instance.new("ScreenGui", player.PlayerGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,150)
frame.Position = UDim2.new(1,-220,0.5,-75)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local miniBtn = Instance.new("TextButton", gui)
miniBtn.Size = UDim2.new(0,40,0,40)
miniBtn.Position = UDim2.new(1,-50,0.5,-20)
miniBtn.Text = "+"
miniBtn.Visible = false

-- drag
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputEnded:Connect(function()
    dragging = false
end)

UIS.InputChanged:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- minimize FIX
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-30,0,0)
closeBtn.Text = "-"

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    miniBtn.Visible = true
end)

miniBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    miniBtn.Visible = false
end)

-- boutons
local function makeButton(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,0,0,40)
    b.Position = UDim2.new(0,0,0,y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.new(1,1,1)
    return b
end

local bestBtn = makeButton("💰 Best Income",0)
local rareBtn = makeButton("⭐ Rarest",50)
local tpBtn = makeButton("📍 TP",100)

-- =========================
-- 🔥 FIND BRAINROTS (BASES ONLY)
-- =========================

local function getBrainrots()
    local list = {}

    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") then
            
            -- ignore tapis / spawn
            if v.Name:lower():find("spawn") then continue end
            if v.Name:lower():find("egg") then continue end

            -- prend ceux avec income UI
            for _,d in ipairs(v:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text:find("%$/s") then
                    table.insert(list, v)
                    break
                end
            end
        end
    end

    return list
end

local function parseMoney(txt)
    if not txt then return 0 end

    local num = tonumber(txt:match("%d+"))
    if not num then return 0 end

    if txt:find("K") then num *= 1e3 end
    if txt:find("M") then num *= 1e6 end
    if txt:find("B") then num *= 1e9 end

    return num
end

local function getIncome(model)
    for _,v in ipairs(model:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text:find("%$/s") then
            return parseMoney(v.Text), v.Text
        end
    end
    return 0, "?"
end

local function findBest()
    local best, bestVal = nil, 0

    for _,m in ipairs(getBrainrots()) do
        local val = getIncome(m)
        if val > bestVal then
            bestVal = val
            best = m
        end
    end

    return best
end

-- rarest = meilleur income fallback propre
local function findRarest()
    return findBest()
end

-- =========================
-- 🔥 VISUEL
-- =========================

local currentTarget
local beam, billboard

local function clear()
    if beam then beam:Destroy() end
    if billboard then billboard:Destroy() end
end

local function show(model)
    clear()
    currentTarget = model

    if not model then return end

    local part = model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local _, txt = getIncome(model)

    billboard = Instance.new("BillboardGui", part)
    billboard.Size = UDim2.new(0,200,0,50)
    billboard.StudsOffset = Vector3.new(0,4,0)

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.TextColor3 = Color3.new(1,1,0)
    label.Text = model.Name .. "\n" .. txt

    local a0 = Instance.new("Attachment", player.Character.Head)
    local a1 = Instance.new("Attachment", part)

    beam = Instance.new("Beam")
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.Width0 = 0.2
    beam.Width1 = 0.2
    beam.Color = ColorSequence.new(Color3.new(1,1,0))
    beam.Parent = player.Character.Head
end

-- =========================
-- 🔥 AUTO EQUIP FLYING CARPET
-- =========================

local function equipCarpet()
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character

    if not backpack or not char then return end

    local tool = backpack:FindFirstChild("Flying Carpet")
    if tool then
        tool.Parent = char
    end
end

local function teleportTo(model)
    if not model or not player.Character then return end

    local part = model:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    -- 🔥 auto equip
    equipCarpet()

    task.wait(0.2)

    player.Character:MoveTo(part.Position + Vector3.new(0,5,0))
end

-- =========================
-- 🔥 BUTTONS
-- =========================

bestBtn.MouseButton1Click:Connect(function()
    show(findBest())
end)

rareBtn.MouseButton1Click:Connect(function()
    show(findRarest())
end)

tpBtn.MouseButton1Click:Connect(function()
    teleportTo(currentTarget)
end)
