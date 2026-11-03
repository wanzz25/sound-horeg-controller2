-- ============================================
-- Sound Horeg Controller v2.0
-- Paste HANYA file ini ke Delta Executor
-- GitHub: https://github.com/YOUR_USERNAME/sound-horeg-controller
-- ============================================

-- ⚠️ Ganti YOUR_USERNAME dan nama repo kamu
local BASE = "https://raw.githubusercontent.com/YOUR_USERNAME/sound-horeg-controller/main/"

-- Loadstring helper
local function ls(file)
    return loadstring(game:HttpGet(BASE .. file, true))()
end

-- Services
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local me      = Players.LocalPlayer

-- Snapshot model sebelum script jalan (untuk deteksi owner)
local snapshot = {}
for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("Model") then snapshot[v] = true end
end

-- ── Load semua modul via loadstring ──
local cfg  = ls("config.lua")
local gui  = ls("gui.lua")(me.PlayerGui, me.Name)
ls("drag.lua")(gui.Win, gui.TBar)
local scan = ls("scanner.lua")(cfg, me, snapshot)
local act  = ls("actions.lua")(cfg, me)

-- State
local myModels = {}

local function rWait(a, b)
    task.wait(a + math.random() * ((b or a) - a))
end

-- Scan alat milik sendiri
local function doScan()
    myModels = {}
    gui.Log("── Scan ──", Color3.fromRGB(50, 50, 70))

    local all = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and scan.isAudio(v) then
            table.insert(all, v)
        end
    end

    for _, v in ipairs(all) do
        if scan.isMine(v) then
            table.insert(myModels, v)
            gui.Log("✓ " .. v.Name, Color3.fromRGB(100, 220, 120))
        end
    end

    -- Fallback jika tidak ada yang cocok
    if #myModels == 0 and #all > 0 then
        gui.Log("! Fallback: ambil semua audio", Color3.fromRGB(255, 200, 50))
        myModels = all
        for _, v in ipairs(myModels) do
            gui.Log("~ " .. v.Name, Color3.fromRGB(200, 200, 100))
        end
    end

    gui.Counter.Text = "Alat: " .. #myModels .. "  |  " .. me.Name
    gui.Log("Total: " .. #myModels, Color3.fromRGB(120, 180, 120))
end

-- ── Events tombol ──
gui.BScan.MouseButton1Click:Connect(function()
    gui.BScan.Text = "Scanning..."
    doScan()
    gui.BScan.Text = "🔍  Scan Alat Saya"
end)

gui.BPow.MouseButton1Click:Connect(function()
    if #myModels == 0 then doScan() end
    gui.Log("── Power ON ──", Color3.fromRGB(50, 50, 70))
    gui.BPow.Text = "Loading..."
    for _, m in ipairs(myModels) do
        gui.Log("⚡ " .. m.Name, Color3.fromRGB(220, 180, 80))
        act.power(m)
        rWait(0.3, 0.6)
    end
    gui.BPow.Text = "⚡  Power ON"
    gui.Log("✓ Done", Color3.fromRGB(100, 220, 100))
end)

gui.BKnob.MouseButton1Click:Connect(function()
    if #myModels == 0 then doScan() end
    gui.Log("── Knob Full ──", Color3.fromRGB(50, 50, 70))
    gui.BKnob.Text = "Loading..."
    for _, m in ipairs(myModels) do
        gui.Log("🔊 " .. m.Name, Color3.fromRGB(80, 200, 180))
        act.knob(m)
        rWait(0.25, 0.5)
    end
    gui.BKnob.Text = "🔊  Knob Full"
    gui.Log("✓ Done", Color3.fromRGB(100, 220, 100))
end)

gui.BAll.MouseButton1Click:Connect(function()
    if #myModels == 0 then doScan() end
    gui.Log("── All ──", Color3.fromRGB(50, 50, 70))
    gui.BAll.Text = "Running..."
    for _, m in ipairs(myModels) do
        gui.Log("▶ " .. m.Name, Color3.fromRGB(220, 150, 80))
        act.power(m)
        rWait(0.3, 0.5)
        act.knob(m)
        rWait(0.2, 0.4)
    end
    gui.BAll.Text = "▶  Jalankan Semua"
    gui.Log("✓ Done!", Color3.fromRGB(100, 220, 100))
end)

-- Auto-detect alat baru yang di-spawn
workspace.DescendantAdded:Connect(function(v)
    rWait(0.8, 1.2)
    if v:IsA("Model") and scan.isAudio(v) and scan.isMine(v) then
        for _, m in ipairs(myModels) do
            if m == v then return end
        end
        table.insert(myModels, v)
        gui.Counter.Text = "Alat: " .. #myModels .. "  |  " .. me.Name
        gui.Log("+ " .. v.Name, Color3.fromRGB(180, 220, 100))
    end
end)

-- RightAlt = hide/show GUI
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        gui.Win.Visible = not gui.Win.Visible
    end
end)

-- Start
task.wait(2)
gui.Log("v" .. cfg.version .. " | RightAlt=hide", Color3.fromRGB(100, 100, 140))
doScan()
