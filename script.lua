--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

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
local speed = 4.5 -- ускоренный полёт
local stepWait = 0.02

-- координаты (можешь менять)
local x1, z1 = 1979, -31963
local x2, z2 = 1828, -32050
local y = 16
local step = 8

-- яйцо
local EGG_ID = "4606f7235b444c568ad0a0da1d0adf9d"
local EGG_AMOUNT = 55

--// STATE
local orbFarm = false
local eggFarm = false
local stopped = false

--// MOVE
local function moveTo(target)
    while hrp and (hrp.Position - target).Magnitude > 2 and not stopped do
        local dir = (target - hrp.Position).Unit
        hrp.CFrame = hrp.CFrame + dir * speed
        task.wait(stepWait)
    end
end

--// ORB FARM
task.spawn(function()
    while true do
        if orbFarm and not stopped then
            local currentZ = z1
            local direction = true

            while orbFarm and currentZ >= z2 and not stopped do
                if direction then
                    moveTo(Vector3.new(x2, y, currentZ))
                else
                    moveTo(Vector3.new(x1, y, currentZ))
                end

                direction = not direction
                currentZ -= step

                moveTo(Vector3.new(hrp.Position.X, y, currentZ))
                task.wait(0.1)
            end
        else
            task.wait(1)
        end
    end
end)

--// EGG OPEN
local function openEggs()
    local remote = ReplicatedStorage
        :WaitForChild("Network")
        :WaitForChild("CustomEggs_Hatch")

    local args = {EGG_ID, EGG_AMOUNT}

    pcall(function()
        remote:InvokeServer(unpack(args))
    end)
end

task.spawn(function()
    while true do
        if eggFarm and not stopped then
            openEggs()
            task.wait(5)
        else
            task.wait(1)
        end
    end
end)

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FarmGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Parent = gui

-- TOP BAR
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

--// DRAG SYSTEM (РАБОЧИЙ)
local dragging = false
local dragStart
local startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
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

--// BUTTON LOGIC
orbBtn.MouseButton1Click:Connect(function()
    if stopped then return end
    orbFarm = not orbFarm
    orbBtn.Text = "Orbs: " .. tostring(orbFarm)
end)

eggBtn.MouseButton1Click:Connect(function()
    if stopped then return end
    eggFarm = not eggFarm
    eggBtn.Text = "Eggs: " .. tostring(eggFarm)
end)

stopBtn.MouseButton1Click:Connect(function()
    orbFarm = false
    eggFarm = false
    stopped = true
    print("🚫 SYSTEM STOPPED")
end)
