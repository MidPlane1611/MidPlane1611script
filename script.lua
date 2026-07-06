--// SETTINGS
local x1, z1 = 1979, -31963
local x2, z2 = 1828, -32050
local y = 16
local step = 8
local speed = 240

--// SERVICES
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

--// GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FarmGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,150)
frame.Position = UDim2.new(0,20,0,200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

-- 🔝 Верхняя панель
local top = Instance.new("Frame", frame)
top.Size = UDim2.new(1,0,0,30)
top.BackgroundColor3 = Color3.fromRGB(40,40,40)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,0,1,0)
title.Text = "Orb Farm"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- Кнопки
local orbBtn = Instance.new("TextButton", frame)
orbBtn.Size = UDim2.new(1,0,0,50)
orbBtn.Position = UDim2.new(0,0,0,35)
orbBtn.Text = "Orbs: OFF"

local eggBtn = Instance.new("TextButton", frame)
eggBtn.Size = UDim2.new(1,0,0,50)
eggBtn.Position = UDim2.new(0,0,0,90)
eggBtn.Text = "Egg: OFF"

-- 🖱️ ПЕРЕТАСКИВАНИЕ
local dragging = false
local dragInput
local dragStart
local startPos

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--// STATE
local orbFarm = false
local eggFarm = false

--// VELOCITY
local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(1e5,1e5,1e5)
bv.Parent = hrp

local function flyTo(target)
    repeat
        local dir = (target - hrp.Position).Unit
        bv.Velocity = dir * speed
        task.wait()
    until (hrp.Position - target).Magnitude < 5
end

--// ORB FARM
task.spawn(function()
    while true do
        if orbFarm then
            local currentZ = z1
            local direction = true

            while currentZ >= z2 and orbFarm do
                if direction then
                    flyTo(Vector3.new(x2,y,currentZ))
                else
                    flyTo(Vector3.new(x1,y,currentZ))
                end

                direction = not direction
                currentZ -= step

                flyTo(Vector3.new(hrp.Position.X,y,currentZ))
                task.wait(0.1)
            end

            task.wait(8) -- пауза спавна
        else
            task.wait(1)
        end
    end
end)

--// EGG FARM (ВАЖНО: возможно нужно поменять Remote)
task.spawn(function()
    while true do
        if eggFarm then
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("OpenEgg"):FireServer()
            end)
            task.wait(4)
        else
            task.wait(1)
        end
    end
end)

--// BUTTONS
orbBtn.MouseButton1Click:Connect(function()
    orbFarm = not orbFarm
    orbBtn.Text = "Orbs: " .. (orbFarm and "ON" or "OFF")
end)

eggBtn.MouseButton1Click:Connect(function()
    eggFarm = not eggFarm
    eggBtn.Text = "Egg: " .. (eggFarm and "ON" or "OFF")
end)
