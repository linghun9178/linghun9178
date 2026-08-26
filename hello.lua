loadstring([[
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WelcomeMessage"
screenGui.Parent = Player.PlayerGui
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 160)
frame.Position = UDim2.new(0.5, -160, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = screenGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 55)
titleLabel.Position = UDim2.new(0, 0, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "你好"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 40
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true
titleLabel.Parent = frame
local subLabel = Instance.new("TextLabel")
subLabel.Size = UDim2.new(1, 0, 0, 40)
subLabel.Position = UDim2.new(0, 0, 0, 65)
subLabel.BackgroundTransparency = 1
subLabel.Text = "我是灵魂，一个新开发者"
subLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
subLabel.TextSize = 24
subLabel.Font = Enum.Font.Gotham
subLabel.TextScaled = true
subLabel.Parent = frame
local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, 0, 0, 22)
hint.Position = UDim2.new(0, 0, 0, 125)
hint.BackgroundTransparency = 1
hint.Text = "欢迎来到我的世界 ✨"
hint.TextColor3 = Color3.fromRGB(150, 150, 150)
hint.TextSize = 14
hint.Font = Enum.Font.Gotham
hint.Parent = frame
task.wait(4)
screenGui:Destroy()
]])()
