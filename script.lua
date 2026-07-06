
--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// CHARACTER HANDLER
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
local speed = 1.5
local stepWait = 0.03

local x1, z1 = 1979, -31963
local x2, z2 = 1828, -32050
local y = 16
local step = 8

local EGG_ID = "4606f7235b444c568ad0a0da1d0adf9d"
local EGG_AMOUNT = 55

--// STATES
local orbFarm = false
local eggFarm = false
local stopped = false

--// PANIC SYSTEM (3 clicks in 5 sec)
local clickCount = 0
local lastClick = 0

local function panicStop()
    orbFarm = false
    eggFarm = false
    stopped = true
    print("🚫 ALL SYSTEMS STOPPED")
end

local function registerClick()
    local now = tick()

    if now - lastClick > 5 then
        clickCount = 0
    end

    lastClick = now
    clickCount += 1

    if clickCount >= 3 then
        panicStop()
        clickCount = 0
    end
end

--// MOVE SYSTEM (CFrame slow fly)
local function moveTo(target)
    while hrp and (hrp.Position - target).Magnitude > 2 and not stopped do
        local dir = (target - hrp.Position).Unit
        hrp.CFrame = hrp.CFrame + dir * speed
        task.wait(stepWait)
    end
end

--// ORB FARM LOOP
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

            task.wait(5)
        else
            task.wait(1)
        end
    end
end)

--// EGG OPEN SYSTEM (55 eggs)
local function openEggs()
    local remote = ReplicatedStorage
        :WaitForChild("Network")
        :WaitForChild("CustomEggs_Hatch")

    local args = {
        EGG_ID,
        EGG_AMOUNT
    }

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

--// SIMPLE GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FarmGUI"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Parent = gui

local orbBtn = Instance.new("TextButton")
orbBtn.Size = UDim2.new(1,0,0,50)
orbBtn.Text = "Orbs"
orbBtn.Parent = frame

local eggBtn = Instance.new("TextButton")
eggBtn.Size = UDim2.new(1,0,0,50)
eggBtn.Position = UDim2.new(0,0,0,50)
eggBtn.Text = "Eggs"
eggBtn.Parent = frame

--// BUTTON LOGIC
orbBtn.MouseButton1Click:Connect(function()
    registerClick()
    if not stopped then
        orbFarm = not orbFarm
        orbBtn.Text = "Orbs: " .. tostring(orbFarm)
    end
end)

eggBtn.MouseButton1Click:Connect(function()
    registerClick()
    if not stopped then
        eggFarm = not eggFarm
        eggBtn.Text = "Eggs: " .. tostring(eggFarm)
    end
end)
