task.wait(2)

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- =========================
-- 🎨 UI MODERNE
-- =========================

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "BrainrotFinder"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,220,0,140)
frame.Position = UDim2.new(1,-240,0.5,-70)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

-- titre
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "Brainrot Finder"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14

-- bouton minimize
local minimize = Instance.new("TextButton", frame)
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-35,0,0)
minimize.Text = "-"
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.new(1,1,1)

local mini = Instance.new("TextButton", gui)
mini.Size = UDim2.new(0,40,0,40)
mini.Position = UDim2.new(1,-50,0.5,-20)
mini.Text = "☰"
mini.Visible = false

minimize.MouseButton1Click:Connect(function()
    frame.Visible = false
    mini.Visible = true
end)

mini.MouseButton1Click:Connect(function()
    frame.Visible = true
    mini.Visible = false
end)

-- drag clean
frame.Active = true
frame.Draggable = true

-- =========================
-- 🔘 BOUTONS
-- =========================

local function makeBtn(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.9,0,0,35)
    b.Position = UDim2.new(0.05,0,0,y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 13

    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

    return b
end

local bestBtn = makeBtn("💰 Best Income",40)
local tpBtn = makeBtn("📍 Teleport",80)

-- =========================
-- 🔍 DETECTION (SAFE)
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

    for _, v in ipairs(player.PlayerGui:GetDescendants()) do
        
        if v:IsA("TextLabel") and v.Text:find("%$/s") then
            
            local val = parse(v.Text)

            if val > bestVal then
                bestVal = val
                
                -- remonte jusqu’au modèle lié
                local parent = v.Parent
                for i = 1,5 do
                    if parent and parent:IsA("Model") then
                        best = parent
                        break
                    end
                    parent = parent.Parent
                end
            end
        end
    end

    return best
end

-- =========================
-- 🎯 VISUEL
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
    beam.Width0 = 0.15
    beam.Width1 = 0.15
    beam.Color = ColorSequence.new(Color3.fromRGB(255,200,0))
    beam.Parent = player.Character.Head
end

-- =========================
-- 🪄 TP + CARPET
-- =========================

local function equipCarpet()
    local tool = player.Backpack:FindFirstChild("Flying Carpet")
    if tool then
        tool.Parent = player.Character
    end
end

local function teleport(target)
    if not target or not player.Character then return end

    local part = target:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    equipCarpet()
    task.wait(0.2)

    player.Character:MoveTo(part.Position + Vector3.new(0,5,0))
end

-- =========================
-- 🔘 ACTIONS
-- =========================

bestBtn.MouseButton1Click:Connect(function()
    local t = findBest()
    show(t)
end)

tpBtn.MouseButton1Click:Connect(function()
    teleport(current)
end)
