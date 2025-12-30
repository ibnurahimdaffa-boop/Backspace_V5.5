-- BACKSPACE DROP v5.5 - SERVER-SIDE ATTEMPT
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- ================= CONFIG =================
local CONFIG = {
    ButtonText = "BACKSPACE/DROP",
    ButtonSize = UDim2.new(0, 165, 0, 42),
    ButtonPosition = UDim2.new(1, -170, 0, 12),
    
    -- WARNA FINAL (NO TRANSPARENCY)
    TextColor = Color3.fromRGB(255, 40, 40),      -- MERAH TERANG
    BgColor = Color3.fromRGB(40, 40, 40),         -- ABU-HITAM
    ClickColor = Color3.fromRGB(255, 255, 255),   -- PUTIH SAAT DIKLIK
}

-- ================= GUI =================
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("CoreGui")
screenGui.Name = "BackspaceV55_GUI"

local dropButton = Instance.new("TextButton")
dropButton.Name = "BackspaceBtn_V55"
dropButton.Text = CONFIG.ButtonText
dropButton.Font = Enum.Font.GothamBold
dropButton.TextSize = 15
dropButton.TextColor3 = CONFIG.TextColor
dropButton.TextTransparency = 0
dropButton.BackgroundColor3 = CONFIG.BgColor
dropButton.BackgroundTransparency = 0
dropButton.BorderSizePixel = 0
dropButton.AutoButtonColor = false
dropButton.Size = CONFIG.ButtonSize
dropButton.Position = CONFIG.ButtonPosition
dropButton.Draggable = false
dropButton.ZIndex = 999

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = dropButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 80)
stroke.Thickness = 2
stroke.Parent = dropButton

-- ================= SERVER DROP ATTEMPT =================
local function ATTEMPT_SERVER_DROP()
    if not player.Character then return end
    
    local tool = player.Character:FindFirstChildWhichIsA("Tool")
    if not tool then
        dropButton.Text = "NO TOOL!"
        task.wait(0.8)
        dropButton.Text = CONFIG.ButtonText
        return
    end
    
    -- VISUAL: PUTIH SAAT DIKLIK
    local originalText = dropButton.Text
    local originalBg = dropButton.BackgroundColor3
    local originalTextColor = dropButton.TextColor3
    
    dropButton.Text = "SEARCHING..."
    dropButton.BackgroundColor3 = CONFIG.ClickColor
    dropButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    
    -- VARIABEL TRACKING
    local dropMethod = "UNKNOWN"
    local success = false
    
    -- 🎯 METHOD 1: CARI SEMUA REMOTEEVENT YANG MUNGKIN
    task.spawn(function()
        local remoteEvents = {}
        
        -- Kumpulkan semua RemoteEvent yang berhubungan
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local nameLower = obj.Name:lower()
                if nameLower:find("drop") or nameLower:find("tool") or 
                   nameLower:find("unequip") or nameLower:find("remove") or
                   nameLower:find("inventory") then
                    table.insert(remoteEvents, obj)
                end
            end
        end
        
        print("[Backspace] 🔍 Found " .. #remoteEvents .. " possible RemoteEvents")
        
        -- Coba satu-satu dengan berbagai parameter
        for _, remote in pairs(remoteEvents) do
            if success then break end
            
            -- Coba berbagai parameter
            local paramsToTry = {
                {},  -- Kosong
                {tool},  -- Tool saja
                {player, tool},  -- Player + Tool
                {tool.Name},  -- Nama tool
                {player.UserId, tool.Name}  -- UserID + Nama
            }
            
            for _, params in ipairs(paramsToTry) do
                if success then break end
                
                local s, err = pcall(function()
                    remote:FireServer(unpack(params))
                end)
                
                if s then
                    dropMethod = "RemoteEvent: " .. remote.Name
                    success = true
                    print("[Backspace] ✅ " .. dropMethod)
                    break
                end
            end
        end
    end)
    
    -- METHOD 2: HUMANOID (fallback)
    if not success then
        task.wait(0.3)  -- Kasih waktu method 1
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            pcall(function()
                humanoid:UnequipTools()
                tool.Parent = workspace
                
                -- Try to make it visible to others
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dropCF = root.CFrame + (root.CFrame.LookVector * 6) + Vector3.new(0, 3, 0)
                    tool:PivotTo(dropCF)
                end
                
                dropMethod = "Humanoid Unequip"
                success = true
                print("[Backspace] ⚙️ " .. dropMethod)
            end)
        end
    end
    
    -- FEEDBACK
    task.wait(0.5)
    
    if success then
        dropButton.Text = "SERVER DROP ✓"
        dropButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        dropButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        print("[Backspace] 🎉 Item SHOULD be visible to others")
        print("[Backspace] 📡 Method: " .. dropMethod)
    else
        dropButton.Text = "CLIENT ONLY ✗"
        dropButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        dropButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        print("[Backspace] ⚠️ Item is CLIENT-SIDE only (others can't see)")
    end
    
    task.wait(1)
    
    -- RESET
    dropButton.Text = originalText
    dropButton.BackgroundColor3 = originalBg
    dropButton.TextColor3 = originalTextColor
end

-- ================= EVENTS =================
dropButton.MouseButton1Click:Connect(ATTEMPT_SERVER_DROP)
dropButton.TouchTap:Connect(ATTEMPT_SERVER_DROP)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Backspace then
        ATTEMPT_SERVER_DROP()
    end
end)

-- ================= FINAL =================
dropButton.Parent = screenGui

-- Cleanup
for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if gui.Name == "BackspaceV55_GUI" and gui ~= screenGui then
        gui:Destroy()
    end
end

print("╔══════════════════════════════════════╗")
print("║     BACKSPACE DROP v5.5              ║")
print("║     SERVER-SIDE ATTEMPT              ║")
print("║     Item SHOULD be visible to others ║")
print("║     Black-Red | White Click          ║")
print("╚══════════════════════════════════════╝")
