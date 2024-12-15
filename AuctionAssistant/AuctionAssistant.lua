-- AuctionAssistant: Simple addon with hardcoded prices for Linen Cloth and Light Leather

-- Hardcoded prices for some items (prices in copper)
local itemPrices = {
    ["Linen Cloth"] = {price = 500, vendor = "General Goods Vendor"},
    ["Light Leather"] = {price = 300, vendor = "Leatherworking Supply Vendor"}
}

-- Function to search for an item in the hardcoded prices table
function SearchInItemPrices(itemName)
    if itemPrices[itemName] then
        local data = itemPrices[itemName]
        return data.price, data.vendor -- Return price in copper and vendor name
    end
    return nil, nil -- Item not found
end

-- Function to print the current loaded data to the chat window
function PrintLoadedData()
    -- Print each item and its price/vendor from the itemPrices table
    for itemName, itemData in pairs(itemPrices) do
        print(string.format("Item: %s, Price: %d copper, Vendor: %s", itemName, itemData.price, itemData.vendor))
    end
end

-- Hook for when the tooltip is set on an item
local function OnTooltipSetItem(tooltip)
    local _, itemLink = tooltip:GetItem()
    if itemLink then
        -- Extract item name
        local itemName = GetItemInfo(itemLink)
        if itemName then
            -- Search for the item in the hardcoded prices table
            local priceInCopper, vendorName = SearchInItemPrices(itemName)

            -- Add lines to the tooltip
            if priceInCopper then
                -- Display stored price and vendor
                tooltip:AddLine(string.format("Stored price: %d copper", priceInCopper), 1, 1, 0)
                tooltip:AddLine(string.format("Vendor: %s", vendorName), 0, 1, 0)
            else
                tooltip:AddLine("No stored price found.", 1, 0, 0)
            end

            tooltip:Show() -- Refresh the tooltip to display the new lines
        end
    end
end

-- Hook the function to the tooltip
GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)

-- Example usage of PrintLoadedData function (to be called in chat)
-- /run PrintLoadedData() to print out hardcoded data
