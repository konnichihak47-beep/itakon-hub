--// 必要なサービス
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer

--// パレット吸着用の変数
local sticking = false
local connectionMagnet = nil
local currentTargetMagnet = nil
local offsetCFrameMagnet = CFrame.new()

--// パレットかどうかを判定する関数
local function isPallet(instance)
    if not instance then return false end
    return instance.Name:match("Pallet") or (instance.Parent and instance.Parent.Name:match("Pallet"))
end

--// 【最強の検知ロジック】敵を掴んだか、または敵に掴まれたかを判定
local function checkGrabCondition(myChar)
    if not myChar then return false end
    
    -- 1. 自分の中に「敵と繋がるもの」が生成されたかチェック（被掴み対策）
    -- 敵に掴まれると、自分の体の中にWeld、Rope、Beamなどが強制的に作られます
    for _, desc in ipairs(myChar:GetDescendants()) do
        if desc:IsA("Weld") or desc:IsA("WeldConstraint") or desc:IsA("Constraint") or desc:IsA("Beam") then
            local connectedPart = nil
            
            -- 各オブジェクトの種類に合わせて接続先のパーツを特定
            pcall(function()
                if desc:IsA("Weld") or desc:IsA("WeldConstraint") then
                    connectedPart = (desc.Part0 == myChar or desc.Part0:IsDescendantOf(myChar)) and desc.Part1 or desc.Part0
                elseif desc:IsA("Beam") or desc:IsA("Constraint") then
                    if desc.Attachment0 and desc.Attachment1 then
                        local p0 = desc.Attachment0.Parent
                        local p1 = desc.Attachment1.Parent
                        connectedPart = (p0 and p0:IsDescendantOf(myChar)) and p1 or p0
                    end
                end
            end)
            
            -- 接続先が「自分以外のプレイヤーや敵NPC」なら、掴まれたと判断して解除
            if connectedPart and connectedPart:IsDescendantOf(Workspace) then
                local enemyModel = connectedPart:IsA("Model") and connectedPart or connectedPart:FindFirstAncestorOfClass("Model")
                if enemyModel and enemyModel:FindFirstChildOfClass("Humanoid") and enemyModel ~= myChar then
                    return true
                end
            end
        end
    end
    
    -- 2.

