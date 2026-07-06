--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// SETTINGS
local flySpeed = 180
local orbOffset = 8

--// STATE
local flying = false
local orbFarm = false
local autoEgg = false
local emergencyClicks = {}

local flyConnection
local orbConnection

--// GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 230, 0, 190)
frame.Position = UDim2.new(0.4, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- верхняя панель
local topBar = Instance.new("Frame", frame)
topBar.Size = UDim2.new(1,0,0,30)
topBar.BackgroundColor3 = Color3.fromRGB(50,50,50)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1,0,1,0)
title.Text = "Orb Farm"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- перетаскивание
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

RunService.RenderStepped:Connect(function()
	if dragging then
		local delta = UIS:GetMouseLocation() - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- кнопки
local function createButton(text, posY, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1,0,0,30)
	btn.Position = UDim2.new(0,0,0,posY)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
	btn.TextColor3 = Color3.new(1,1,1)

	btn.MouseButton1Click:Connect(callback)
	return btn
end

--// FUNCTIONS

-- 🔹 ПОЛЕТ (CFrame)
local function startFly()
	if flyConnection then flyConnection:Disconnect() end
	flying = true

	flyConnection = RunService.RenderStepped:Connect(function(dt)
		if not flying then return end

		local char = player.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local target = hrp.Position + (hrp.CFrame.LookVector * orbOffset)

		hrp.CFrame = hrp.CFrame:Lerp(
			CFrame.new(target),
			math.clamp(flySpeed * dt / 60, 0, 1)
		)
	end)
end

local function stopFly()
	flying = false
	if flyConnection then flyConnection:Disconnect() end
end

-- 🔹 ОРБЫ
local function startOrbs()
	if orbConnection then orbConnection:Disconnect() end
	orbFarm = true

	orbConnection = task.spawn(function()
		while orbFarm do
			local char = player.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					for _, v in pairs(workspace:GetDescendants()) do
						if v:IsA("BasePart") and v.Name:lower():find("orb") then
							hrp.CFrame = CFrame.new(v.Position + Vector3.new(0,2,0))
							task.wait(0.07)
						end
					end
				end
			end
			task.wait(0.2)
		end
	end)
end

local function stopOrbs()
	orbFarm = false
end

-- 🔹 АВТО ЯЙЦА (FIXED)
local function startEgg()
	autoEgg = true

	task.spawn(function()
		local network = ReplicatedStorage:WaitForChild("Network")

		while autoEgg do
			-- важный запрос
			network:WaitForChild("Index: Request Hatch Count"):InvokeServer()
			task.wait(0.15)

			for i = 1, 11 do
				local args = {
					"4606f7235b444c568ad0a0da1d0adf9d",
					5
				}

				network:WaitForChild("CustomEggs_Hatch"):InvokeServer(unpack(args))
				task.wait(0.2)
			end

			task.wait(3)
		end
	end)
end

local function stopEgg()
	autoEgg = false
end

-- 🔹 ЭКСТРЕННОЕ ВЫКЛЮЧЕНИЕ
local function emergencyStop()
	local now = tick()
	table.insert(emergencyClicks, now)

	for i = #emergencyClicks, 1, -1 do
		if now - emergencyClicks[i] > 5 then
			table.remove(emergencyClicks, i)
		end
	end

	if #emergencyClicks >= 3 then
		stopFly()
		stopOrbs()
		stopEgg()
		print("ВСЕ ВЫКЛЮЧЕНО")
	end
end

--// BUTTONS
createButton("Fly ON/OFF", 40, function()
	if flying then stopFly() else startFly() end
end)

createButton("Orbs ON/OFF", 80, function()
	if orbFarm then stopOrbs() else startOrbs() end
end)

createButton("Egg x55 ON/OFF", 120, function()
	if autoEgg then stopEgg() else startEgg() end
end)

createButton("!!! STOP !!!", 150, function()
	emergencyStop()
end)
