--// SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// CHARACTER
local char, hrp

local function loadChar()
    char = player.Character or player.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart")
end

loadChar()

player.CharacterAdded:Connect(function()
    task.wait(1)
    loadChar()
end)

--// SETTINGS
local speed = 4.5 -- x3 faster
local stepWait = 0.02

--// STATE
local orbFarm = false
local eggFarm = false
local stopped = false

--// MOVE SYSTEM (safe CFrame motion)
local function moveTo(target)
    while hrp and (hrp.Position - target).Magnitude > 2 and not stopped do
        local dir = (target - hrp.Position).Unit
        hrp.CFrame = hrp.CFrame + dir * speed
        task.wait(stepWait)
    end
end

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FarmGUI"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Parent = gui

-- TOP BAR (drag handle)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,25)
topBar.BackgroundColor3 = Color3.fromRGB(40,40,40)
topBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Farm Controller"
title.TextColor3 = Color3.new(1,1,1)
title.Parent = topBar

-- BUTTONS
local orbBtn = Instance.new("TextButton")
orbBtn.Size = UDim2.new(1,0,0,40)
orbBtn.Position = UDim2.new(0,0,0,30)
orbBtn.Text = "Orbs: OFF"
orbBtn.Parent = frame

local eggBtn = Instance.new("TextButton")
eggBtn.Size = UDim2.new(1,0,0,40)
eggBtn.Position = UDim2.new(0,0,0,75)
eggBtn.Text = "Eggs: OFF"
eggBtn.Parent = frame

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(1,0,0,40)
stopBtn.Position = UDim2.new(0,0,0,120)
stopBtn.Text = "EMERGENCY STOP"
stopBtn.BackgroundColor3 = Color3.fromRGB(170,40,40)
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Parent = frame

--// DRAG SYSTEM
local dragging = false
local dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--// STOP
stopBtn.MouseButton1Click:Connect(function()
    orbFarm = false
    eggFarm = false
    stopped = true
    print("🚫 SYSTEM STOPPED")
end)

--// TOGGLES
orbBtn.MouseButton1Click:Connect(function()
    if not stopped then
        orbFarm = not orbFarm
        orbBtn.Text = "Orbs: " .. tostring(orbFarm)
    end
end)

eggBtn.MouseButton1Click:Connect(function()
    if not stopped then
        eggFarm = not eggFarm
        eggBtn.Text = "Eggs: " .. tostring(eggFarm)
    end
end)

--// PLACEHOLDER LOOPS (you plug your game logic here)

task.spawn(function()
    while true do
        if orbFarm and not stopped then
            -- сюда вставляешь свою систему орбов
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while true do
        if eggFarm and not stopped then
            -- сюда вставляешь hatch logic (InvokeServer)
            task.wait(3)
        else
            task.wait(1)
        end
    end
end)
