--[[
 ========================================
  By: luisgamercooI231fan, 
  Time: Fri Feb 18 21:11:26 2022,
  Description: sprint,
  ======================================== 
  ]]--
local module = {}
local data = {}
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CAS = game:GetService("ContextActionService")
local function scale_button(CurrentCamera, name:string)
	local MinAxis = math.min(CurrentCamera.ViewportSize.X, CurrentCamera.ViewportSize.Y)
	local IsSmallScreen = MinAxis <= 500
	local ActionButtonSize = IsSmallScreen and 70 or 120

	local function RescaleActionButton(Name)
		local ActionButton = CAS:GetButton(Name)

		if ActionButton then
			local ActionTitle = ActionButton:WaitForChild("ActionTitle")

			if not IsSmallScreen then
				ActionTitle.TextSize = 36
			else
				ActionTitle.TextSize = 18
			end
			ActionButton.Size = UDim2.fromOffset(ActionButtonSize, ActionButtonSize)
		end
	end
	RescaleActionButton(name)
end
function module.new()
	if game:GetService("RunService"):IsClient() then
		local plr = game:GetService("Players").LocalPlayer
		local self = setmetatable({}, {})
		local start_time = nil
		self.phone_button_offset = 45 -- the offset of the default mobile button on phones
		self.tablet_button_offset = 2.45 -- the offset of the default mobile button on tablets
		self.mobile_button_icon = "rbxassetid://1921587812" -- the icon for the default mobile button
		local sprinted = Instance.new("BindableEvent")
		local unsprinted = Instance.new("BindableEvent")
		self.camera = workspace.CurrentCamera
		self.mobile_button_title = nil -- the mobile button title 
		self.run_animation = nil
		self.default_FOV = 70
		self.FOV_tween_speed = 0.4 -- how long it takes for the fov to tween
		self.FOV_tween_style = Enum.EasingStyle.Quad -- the easing style of which the tween is tweened at
		self.FOV_tween_direction = Enum.EasingDirection.Out -- the easing direction of which the tween is tweened at.
		self.FOV_tween_info = TweenInfo.new(self.FOV_tween_speed, self.FOV_tween_style, self.FOV_tween_direction, 0, false, 0)
		self.default_speed = game:GetService("StarterPlayer").CharacterWalkSpeed -- the default speed for when you stop sprinting
		self.run_speed = self.default_speed * 2 -- the speed of which the player sprints at
		self.uses_default_ui = true -- if the mobile ui uses the default mobile ui
		self.sprint_ui = nil -- if the mobile ui is set to false, you can set this to add a custom ui(image button or text button).
		self.Sprinted = sprinted.Event
		self.Unsprinted = unsprinted.Event
		self.use_run_FOV = true -- if the player's fov changes when sprinting
		self.running_FOV = 85 -- the FOV for the player when they run
		local goals = {
			FieldOfView = self.running_FOV
		}
		local stop_goals = {
			FieldOfView = self.default_FOV
		}
		local FOV_tween = TS:Create(self.camera, self.FOV_tween_info, goals)
		local FOV_stop_tween = TS:Create(self.camera,self.FOV_tween_info, stop_goals)
		self.valid_keys = { -- the keys that can be used to start sprinting
			--[PC]--
			Enum.KeyCode.LeftShift, 
			Enum.KeyCode.RightShift,
			--[Xbox]--
			Enum.KeyCode.ButtonX -- the X button on controller
		}
		local function sprint(name, state)
			if state == Enum.UserInputState.Begin then
				start_time = tick()
				sprinted:Fire(start_time)
			else
				if start_time then
					unsprinted:Fire(tick(),tick() - start_time)
				else
					unsprinted:Fire(tick(),0)
				end

				start_time = nil
			end
		end
		self.Sprint = function(state:Enum.UserInputState)
			sprint(nil, state)
		end
		self.Sprinted:Connect(function(start_time)
			local char = plr.Character
			if char then
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if hum then
					hum.WalkSpeed = self.run_speed
					if self.use_run_FOV then
						FOV_tween:Play()
					end
					
				end
			end
		end)
		self.Unsprinted:Connect(function(end_time, activation_time)
			local char = plr.Character
			if char then
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if hum then
					hum.WalkSpeed = self.default_speed
					FOV_stop_tween:Play()
				end
			end
		end)

		function self:Init(id:string)
			table.insert(data, self)
			local CurrentCamera = self.camera
			if self.uses_default_ui == true and self.sprint_ui == nil then
				local MinAxis = math.min(CurrentCamera.ViewportSize.X, CurrentCamera.ViewportSize.Y)
				local IsSmallScreen = MinAxis <= 500
				local ActionButtonSize = IsSmallScreen and 70 or 120
				CAS:BindActionAtPriority(id, sprint, true, 10000, unpack(self.valid_keys))
				CAS:SetPosition(id, IsSmallScreen and UDim2.new(1, -(ActionButtonSize * 2.52), 1, -ActionButtonSize - self.phone_button_offset) or
					UDim2.new(1, -(ActionButtonSize * 2.52 - 10), 1, -ActionButtonSize  * self.tablet_button_offset))
				scale_button(CurrentCamera, id)
				if self.mobile_button_title then
					CAS:SetTitle(id, self.mobile_button_title)
				else
					CAS:SetImage(id, self.mobile_button_icon)
				end	
			elseif self.uses_default_ui == false and self.sprint_ui ~= nil then
				local ui:TextButton | ImageButton = self.sprint_ui
				if ui:IsA("TextButton") or ui:IsA("ImageButton") then
					CAS:BindActionAtPriority("sprint-action", sprint, false, 10000, unpack(self.valid_keys))
					if not UIS.KeyboardEnabled then
						ui.Visible = true
						ui.InputBegan:Connect(function(input)
							sprint(nil, input.UserInputState)
						end)
						ui.Activated:Connect(function(input)
							sprint(nil, input.UserInputState)				
						end)
					else --user has keyboard
						ui.Visible = false
					end
				end
				end
			end
		return self
	else
		error('please run sprinting module on client; exit code 1')
	end


end
function module:Get(id:string)
		for _, sprint_data in ipairs(data) do
			if sprint_data.id == id then
				return sprint_data
			end
		end
	
	
end
return module
