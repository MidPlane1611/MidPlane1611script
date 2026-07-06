--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// SETTINGS
local orbFarm = false
local eggFarm = false
local stopped = false

local ORB_STEP = 3
local SPEED = 2

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FarmGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 220, 0, 150)
frame.Position = UDim2.new(0.4, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true

-- верхняя панель
local topBar = Instance.new("Frame")
topBar.Parent = frame
topBar.Size = UDim2.new(1,0,0,30)
topBar.BackgroundColor3 = Color3.fromRGB(40,40,40)
topBar.Active = true

local title = Instance.new("TextLabel")
title.Parent = topBar
title.Size = UDim2.new(1,0,1,0)
title.Text = "FARM HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- кнопки
local orbBtn = Instance.new("TextButton", frame)
orbBtn.Position = UDim2.new(0,10,0,40)
orbBtn.Size = UDim2.new(0,200,0,30)
orbBtn.Text = "Orbs: OFF"

local eggBtn = Instance.new("TextButton", frame)
eggBtn.Position = UDim2.new(0,10,0,80)
eggBtn.Size = UDim2.new(0,200,0,30)
eggBtn.Text = "Eggs: OFF"

local panicBtn = Instance.new("TextButton", frame)
panicBtn.Position = UDim2.new(0,10,0,120)
panicBtn.Size = UDim2.new(0,200,0,25)
panicBtn.Text = "!!! STOP !!!"

--// 🔥 СУПЕР СТАБИЛЬНЫЙ DRAG
local dragging = false
local dragInput
local dragStart
local startPos

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		dragInput = input

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

topBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
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

--// КНОПКИ
orbBtn.MouseButton1Click:Connect(function()
	if stopped then return end
	orbFarm = not orbFarm
	orbBtn.Text = "Orbs: " .. (orbFarm and "ON" or "OFF")
end)

eggBtn.MouseButton1Click:Connect(function()
	if stopped then return end
	eggFarm = not eggFarm
	eggBtn.Text = "Eggs: " .. (eggFarm and "ON" or "OFF")
end)

--// PANIC (3 клика за 5 сек)
local clicks = 0
panicBtn.MouseButton1Click:Connect(function()
	clicks += 1
	
	task.delay(5, function()
		clicks = 0
	end)

	if clicks >= 3 then
		stopped = true
		orbFarm = false
		eggFarm = false
		
		orbBtn.Text = "Orbs: OFF"
		eggBtn.Text = "Eggs: OFF"
		panicBtn.Text = "STOPPED"
	end
end)

--// ОРБ ФАРМ
task.spawn(function()
	while true do
		task.wait(0.05 / SPEED)

		if orbFarm and not stopped then
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hrp = char.HumanoidRootPart
				
				local orbsFolder = workspace:FindFirstChild("Orbs")
				if orbsFolder then
					local orbs = orbsFolder:GetChildren()
					
					for i = 1, #orbs, ORB_STEP do
						local orb = orbs[i]
						if orb and orb:IsA("BasePart") then
							hrp.CFrame = orb.CFrame
							task.wait(0.01 / SPEED)
						end
					end
				end
			end
		end
	end
end)

--// ЯЙЦА (55)
task.spawn(function()
	while true do
		task.wait(4)

		if eggFarm and not stopped then
			local args = {
				"4606f7235b444c568ad0a0da1d0adf9d",
				55
			}

			RS:WaitForChild("Network"):WaitForChild("CustomEggs_Hatch"):InvokeServer(unpack(args))
		end
	end
end)
