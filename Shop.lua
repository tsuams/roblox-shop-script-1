-- Shop System for Roblox
local Shop = {}
Shop.Items = {
    {Name = "Sword", Price = 100, Id = "rbxassetid://12345678"},
    {Name = "Shield", Price = 150, Id = "rbxassetid://23456789"},
    {Name = "Speed Potion", Price = 50, Id = "rbxassetid://34567890"},
    {Name = "Magic Wand", Price = 200, Id = "rbxassetid://45678901"}
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote event for handling purchases
local PurchaseEvent = Instance.new("RemoteEvent")
PurchaseEvent.Name = "PurchaseEvent"
PurchaseEvent.Parent = ReplicatedStorage

-- Function to check if a player has enough money
local function CanAfford(player, cost)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local currency = leaderstats:FindFirstChild("Coins")
        if currency and currency.Value >= cost then
            return true
        end
    end
    return false
end

-- Function to deduct money from the player
local function DeductMoney(player, amount)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local currency = leaderstats:FindFirstChild("Coins")
        if currency then
            currency.Value = currency.Value - amount
        end
    end
end

-- Function to give item to the player
local function GiveItem(player, item)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local newItem = Instance.new("Tool")
        newItem.Name = item.Name
        newItem.TextureId = item.Id
        newItem.Parent = backpack
    end
end

-- Purchase event listener
PurchaseEvent.OnServerEvent:Connect(function(player, itemName)
    for _, item in pairs(Shop.Items) do
        if item.Name == itemName then
            if CanAfford(player, item.Price) then
                DeductMoney(player, item.Price)
                GiveItem(player, item)
                player:SendNotification("Purchase successful!", "You have bought " .. item.Name, 3)
            else
                player:SendNotification("Not enough money!", "You need more Coins to buy this item.", 3)
            end
            return
        end
    end
end)

-- Setup shop GUI
local function SetupShopGUI(player)
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end

    local shopFrame = Instance.new("Frame")
    shopFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
    shopFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
    shopFrame.Parent = playerGui

    for _, item in pairs(Shop.Items) do
        local button = Instance.new("TextButton")
        button.Text = item.Name .. " - " .. item.Price .. " Coins"
        button.Size = UDim2.new(1, 0, 0.2, 0)
        button.Parent = shopFrame

        button.MouseButton1Click:Connect(function()
            PurchaseEvent:FireServer(item.Name)
        end)
    end
end

-- When a player joins, setup the shop GUI
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        SetupShopGUI(player)
    end)
end)

return Shop
