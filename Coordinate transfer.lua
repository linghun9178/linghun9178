--[[
    坐标传送 GUI · by linghun
    功能：保存坐标 · 传送 · 实时坐标显示 · 传送开关 · 最小化 · 关闭 · 拖拽
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ==================== 变量 ====================
local savedPosition = nil
local teleportEnabled = false
local isMinimized = false
local positionUpdateConnection = nil

-- ==================== 创建 GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.Parent = Player.PlayerGui
screenGui.ResetOnSpawn = false

-- 主框架（高度略微增加以容纳作者信息）
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 240)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- ==================== 标题栏 ====================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 33, 41)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "📍 坐标传送 · by linghun"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- 最小化按钮
local minBtn = Instance.new("ImageButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -64, 0, 2)
minBtn.BackgroundTransparency = 1
minBtn.Image = "rbxassetid://0"
minBtn.Parent = titleBar

local minIcon = Instance.new("TextLabel")
minIcon.Size = UDim2.new(1, 0, 1, 0)
minIcon.BackgroundTransparency = 1
minIcon.Text = "─"
minIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
minIcon.TextSize = 22
minIcon.Font = Enum.Font.GothamBold
minIcon.Parent = minBtn

-- 关闭按钮
local closeBtn = Instance.new("ImageButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0, 2)
closeBtn.BackgroundTransparency = 1
closeBtn.Image = "rbxassetid://0"
closeBtn.Parent = titleBar

local closeIcon = Instance.new("TextLabel")
closeIcon.Size = UDim2.new(1, 0, 1, 0)
closeIcon.BackgroundTransparency = 1
closeIcon.Text = "✕"
closeIcon.TextColor3 = Color3.fromRGB(255, 80, 80)
closeIcon.TextSize = 18
closeIcon.Font = Enum.Font.GothamBold
closeIcon.Parent = closeBtn

-- ==================== 内容容器 ====================
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, -32)
contentContainer.Position = UDim2.new(0, 0, 0, 32)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.Parent = mainFrame

-- 当前坐标显示标签
local coordLabel = Instance.new("TextLabel")
coordLabel.Size = UDim2.new(1, -30, 0, 24)
coordLabel.Position = UDim2.new(0, 15, 0, 12)
coordLabel.BackgroundTransparency = 1
coordLabel.Text = "📍 当前坐标：--"
coordLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
coordLabel.TextSize = 14
coordLabel.Font = Enum.Font.Gotham
coordLabel.TextXAlignment = Enum.TextXAlignment.Left
coordLabel.Parent = contentContainer

-- 保存的坐标显示
local savedLabel = Instance.new("TextLabel")
savedLabel.Size = UDim2.new(1, -30, 0, 24)
savedLabel.Position = UDim2.new(0, 15, 0, 40)
savedLabel.BackgroundTransparency = 1
savedLabel.Text = "💾 已保存：无"
savedLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
savedLabel.TextSize = 14
savedLabel.Font = Enum.Font.Gotham
savedLabel.TextXAlignment = Enum.TextXAlignment.Left
savedLabel.Parent = contentContainer

-- 按钮行
local btnRow = Instance.new("Frame")
btnRow.Size = UDim2.new(1, -30, 0, 34)
btnRow.Position = UDim2.new(0, 15, 0, 72)
btnRow.BackgroundTransparency = 1
btnRow.Parent = contentContainer

-- 保存坐标按钮
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0, 110, 0, 34)
saveBtn.Position = UDim2.new(0, 0, 0, 0)
saveBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 255)
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Text = "💾 保存坐标"
saveBtn.TextSize = 14
saveBtn.Font = Enum.Font.GothamBold
saveBtn.Parent = btnRow
local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 6)
saveCorner.Parent = saveBtn

-- 传送按钮
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(0, 110, 0, 34)
teleportBtn.Position = UDim2.new(0, 125, 0, 0)
teleportBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.Text = "🚀 传送"
teleportBtn.TextSize = 14
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.Parent = btnRow
local teleCorner = Instance.new("UICorner")
teleCorner.CornerRadius = UDim.new(0, 6)
teleCorner.Parent = teleportBtn

-- 传送开关
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 120, 0, 34)
toggleBtn.Position = UDim2.new(0.5, -60, 0, 122)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "🔴 传送关"
toggleBtn.TextSize = 15
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = contentContainer
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- 状态文字
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -30, 0, 18)
statusLabel.Position = UDim2.new(0, 15, 0, 168)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "就绪"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = contentContainer

-- ===== 作者信息（新增） =====
local authorLabel = Instance.new("TextLabel")
authorLabel.Size = UDim2.new(1, -30, 0, 16)
authorLabel.Position = UDim2.new(0, 15, 0, 192)
authorLabel.BackgroundTransparency = 1
authorLabel.Text = "由 linghun 制作 ❤️"
authorLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
authorLabel.TextSize = 11
authorLabel.Font = Enum.Font.Gotham
authorLabel.TextXAlignment = Enum.TextXAlignment.Center
authorLabel.Parent = contentContainer

-- ==================== 最小化 ====================
local fullSize = mainFrame.Size
local fullPos = mainFrame.Position
local minimizedSize = UDim2.new(0, 200, 0, 32)
local minimizedPos = UDim2.new(0.5, -100, 0, 20)

local function toggleMinimize()
    isMinimized = not isMinimized
    local targetSize, targetPos
    if isMinimized then
        targetSize = minimizedSize
        targetPos = minimizedPos
        contentContainer.Visible = false
        minIcon.Text = "□"
    else
        targetSize = fullSize
        targetPos = fullPos
        contentContainer.Visible = true
        minIcon.Text = "─"
    end
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local sizeTween = TweenService:Create(mainFrame, tweenInfo, { Size = targetSize })
    local posTween = TweenService:Create(mainFrame, tweenInfo, { Position = targetPos })
    sizeTween:Play()
    posTween:Play()
end

-- ==================== 功能函数 ====================

-- 获取当前坐标
local function getCurrentPosition()
    local char = Player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    return root.Position
end

-- 更新坐标显示
local function updateCoordDisplay()
    local pos = getCurrentPosition()
    if pos then
        coordLabel.Text = string.format("📍 当前坐标：X: %.1f  Y: %.1f  Z: %.1f", pos.X, pos.Y, pos.Z)
    else
        coordLabel.Text = "📍 当前坐标：--"
    end
end

-- 保存坐标
local function savePosition()
    local pos = getCurrentPosition()
    if pos then
        savedPosition = pos
        savedLabel.Text = string.format("💾 已保存：X: %.1f  Y: %.1f  Z: %.1f", pos.X, pos.Y, pos.Z)
        statusLabel.Text = "✅ 坐标已保存"
        task.wait(2)
        if not teleportEnabled then
            statusLabel.Text = "就绪"
        else
            statusLabel.Text = "🟢 传送已开启"
        end
    else
        statusLabel.Text = "❌ 无法获取坐标"
    end
end

-- 传送
local function teleportToSaved()
    if not teleportEnabled then
        statusLabel.Text = "⚠️ 请先开启传送开关"
        return
    end
    if not savedPosition then
        statusLabel.Text = "⚠️ 请先保存坐标"
        return
    end
    local char = Player.Character
    if not char then
        statusLabel.Text = "❌ 角色不存在"
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        statusLabel.Text = "❌ 无法传送"
        return
    end
    pcall(function()
        root.CFrame = CFrame.new(savedPosition)
        statusLabel.Text = "✅ 传送成功！"
        task.wait(2)
        if not teleportEnabled then
            statusLabel.Text = "就绪"
        else
            statusLabel.Text = "🟢 传送已开启"
        end
    end)
end

-- ==================== 更新循环 ====================
local function startPositionUpdate()
    if positionUpdateConnection then return end
    positionUpdateConnection = RunService.Heartbeat:Connect(function()
        updateCoordDisplay()
    end)
end

startPositionUpdate()

-- ==================== 开关 ====================
local function toggleTeleport()
    teleportEnabled = not teleportEnabled
    if teleportEnabled then
        toggleBtn.Text = "🟢 传送开"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        statusLabel.Text = "🟢 传送已开启"
    else
        toggleBtn.Text = "🔴 传送关"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        statusLabel.Text = "传送已关闭"
    end
end

-- ==================== 关闭 ====================
local function closeGUI()
    if positionUpdateConnection then
        positionUpdateConnection:Disconnect()
        positionUpdateConnection = nil
    end
    screenGui:Destroy()
end

-- ==================== 鼠标点击检测 ====================
local function isMouseOverButton(button, input)
    local absPos = button.AbsolutePosition
    local absSize = button.AbsoluteSize
    local mousePos = input.Position
    return mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
        and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
end

-- ==================== UserInputService 统一监听（最可靠） ====================
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isMouseOverButton(closeBtn, input) then
            closeGUI()
            return
        end
        if isMouseOverButton(minBtn, input) then
            toggleMinimize()
            return
        end
        if isMouseOverButton(saveBtn, input) then
            savePosition()
            return
        end
        if isMouseOverButton(teleportBtn, input) then
            teleportToSaved()
            return
        end
        if isMouseOverButton(toggleBtn, input) then
            toggleTeleport()
            return
        end
    end
end)

-- ==================== 备用：按钮自身事件（双保险） ====================
closeBtn.MouseButton1Click:Connect(closeGUI)
closeBtn.Activated:Connect(closeGUI)

minBtn.MouseButton1Click:Connect(toggleMinimize)
minBtn.Activated:Connect(toggleMinimize)

saveBtn.MouseButton1Click:Connect(savePosition)
saveBtn.Activated:Connect(savePosition)

teleportBtn.MouseButton1Click:Connect(teleportToSaved)
teleportBtn.Activated:Connect(teleportToSaved)

toggleBtn.MouseButton1Click:Connect(toggleTeleport)
toggleBtn.Activated:Connect(toggleTeleport)

-- ==================== 窗口拖拽 ====================
local dragData = nil

local function startDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isMouseOverButton(titleBar, input) then
            dragData = {
                startPos = input.Position,
                frameStart = mainFrame.Position,
                frameStartOffset = {
                    X = mainFrame.Position.X.Offset,
                    Y = mainFrame.Position.Y.Offset
                }
            }
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragData = nil
                end
            end)
        end
    end
end

local function updateDrag(input)
    if not dragData then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragData.startPos
        local newPos = UDim2.new(
            dragData.frameStart.X.Scale,
            dragData.frameStartOffset.X + delta.X,
            dragData.frameStart.Y.Scale,
            dragData.frameStartOffset.Y + delta.Y
        )
        mainFrame.Position = newPos
        if not isMinimized then
            fullPos = newPos
        else
            minimizedPos = newPos
        end
    end
end

titleBar.InputBegan:Connect(startDrag)
UserInputService.InputChanged:Connect(updateDrag)

-- ==================== 角色重生时更新 ====================
Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    updateCoordDisplay()
end)

-- ==================== 初始化 ====================
updateCoordDisplay()
statusLabel.Text = "就绪 · 保存坐标后可传送"

-- 关闭 GUI 时清理
screenGui.AncestryChanged:Connect(function()
    if not screenGui.Parent then
        if positionUpdateConnection then
            positionUpdateConnection:Disconnect()
            positionUpdateConnection = nil
        end
    end
end)
