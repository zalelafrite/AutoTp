task.wait(2)

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- =========================
-- 🔥 UI (simple + clean)
-- =========================

local gui = Instance.new("ScreenGui", player.PlayerGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,130)
frame.Position = UDim2.new(1,-220,0.5,-65)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

-- drag simple
frame.Active = true
frame.Draggable = true

-- boutons
local function makeButton(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,0,0,40)
    b.Position = UDim2.new(0,0,0,y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.new(1,1,1)
    return b
end

local bestBtn = makeButton("💰 Best Income",0)
local tpBtn = makeButton("📍 TP",45)

-- =========================
-- 🔥 DETECTION SIMPLE (PAS DE LAG)
-- =========================

local function parse(txt)
    local n = tonumber(txt:match("%d+"))
    if not n then return 0 end

    if txt:find("K") then n *= 1e3 end
    if txt:find("M") then n *= 1e6 end
    if txt:find("B") then n *= 1e9 end

    return n
end

local function findBest()
    local best, bestVal = nil, 0

    -- 🔥 seulement les BillboardGui (rapide)
    for _,g in ipairs(workspace:GetDescendants()) do
        if g:IsA("BillboardGui") then
            
            local label = g:FindFirstChildWhichIsA("TextLabel")
            if label and label.Text:find("%$/s") then
                
                local val = parse(label.Text)

                if val > bestVal then
                    bestVal = val
                    best = g.Parent
                end
            end
        end
    end

    return best
end

-- =========================
-- 🔥 VISUEL
-- =========================

local current
local beam

local function show(target)
    if beam then beam:Destroy() end
    current = target

    if not target or not player.Character then return end

    local part = target:FindFirstChildWhichIsA("BasePart")
    if not part then return end

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
-- 🔥 TP + CARPET
-- =========================

local function equipCarpet()
    local tool = player.Backpack:FindFirstChild("Flying Carpet")
    if tool then
        tool.Parent = player.Character
    end
end

local function tp(target)
    if not target or not player.Character then return end

    local part = target:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    equipCarpet()
    task.wait(0.2)

    player.Character:MoveTo(part.Position + Vector3.new(0,5,0))
end

-- =========================
-- 🔥 BUTTONS
-- =========================

bestBtn.MouseButton1Click:Connect(function()
    local t = findBest()
    show(t)
end)

tpBtn.MouseButton1Click:Connect(function()
    tp(current)
end)
