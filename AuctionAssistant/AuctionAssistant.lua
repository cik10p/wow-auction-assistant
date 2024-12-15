-- AuctionAssistant: An addon to manage item prices and vendors with slash commands

-- Initialize SavedVariables if it doesn't exist
AuctionAssistantData = AuctionAssistantData or {}

-- Function to clean the item name by removing the item link formatting
function CleanItemName(itemLinkOrName)
    if itemLinkOrName then
        -- If the input is an item link, extract the item name
        local itemName = GetItemInfo(itemLinkOrName)
        if itemName then
            return itemName
        end
    end
    -- If not an item link, assume it's a regular item name
    return itemLinkOrName
end

-- Function to add item link formatting (wrap the item name in [])
function AddItemLinkName(itemName)
    return "[" .. itemName .. "]"
end

-- Function to add or update an item price in the AuctionAssistantData
function AddItemPrice(itemLinkOrName, price, vendor)
    -- Clean the item name (remove item link formatting)
    local itemName = CleanItemName(itemLinkOrName)
    
    -- Check if the item already exists, if so, update it
    if not AuctionAssistantData[itemName] then
        print("Adding new item: " .. AddItemLinkName(itemName))  -- Use AddItemLinkName here
    else
        print("Updating price for: " .. AddItemLinkName(itemName))  -- Use AddItemLinkName here
    end

    -- Update the item data in the SavedVariables table
    AuctionAssistantData[itemName] = {price = price, vendor = vendor}

    -- Print the updated data to the chat window
    print(string.format("Item: %s, Price: %d copper, Vendor: %s", AddItemLinkName(itemName), price, vendor))  -- Use AddItemLinkName here
end

-- Define the slash command to add or update item prices
SLASH_AAADDPRICE1 = "/addprice"
SlashCmdList["AAADDPRICE"] = function(msg)
    -- Split the message into item name or item link, price, and vendor
    local itemLinkOrName, price, vendor = strsplit(",", msg)
    price = tonumber(price)  -- Convert price to a number

    -- Check if the input is valid (all fields must be provided)
    if itemLinkOrName and price and vendor then
        -- Call the AddItemPrice function with the provided arguments
        AddItemPrice(itemLinkOrName, price, vendor)
    else
        -- Provide usage instructions if the input is invalid
        print("Usage: /addprice <Item Name or Item Link>, <Price>, <Vendor>")
    end
end

-- Function to search for an item in AuctionAssistantData
function SearchInItemPrices(itemName)
    if AuctionAssistantData[itemName] then
        local data = AuctionAssistantData[itemName]
        return data.price, data.vendor -- Return price in copper and vendor name
    end
    return nil, nil -- Item not found
end

-- Function to print all stored data (item prices and vendors)
function PrintLoadedData()
    -- Check if there is any data to print
    if next(AuctionAssistantData) == nil then
        print("No item data available.")
        return
    end

    print("############################")
    print("AuctionAssistant Data:")
    print("############################")
    
    -- Print each item and its price/vendor from AuctionAssistantData
    for itemName, itemData in pairs(AuctionAssistantData) do
        print(string.format("Item: %s, Price: %d copper, Vendor: %s", AddItemLinkName(itemName), itemData.price, itemData.vendor))  -- Use AddItemLinkName here
    end
end

-- Define the slash command to print all data in AuctionAssistantData
SLASH_AAPRINTDATA1 = "/printdata"
SlashCmdList["AAPRINTDATA"] = function()
    -- Call the PrintLoadedData function to print the data
    PrintLoadedData()
end

-- Tooltip hook to display prices and vendors for items in the tooltip
local function OnTooltipSetItem(tooltip)
    local _, itemLink = tooltip:GetItem()
    if itemLink then
        local itemName = CleanItemName(itemLink)
        if itemName then
            -- Search for the item in AuctionAssistantData
            local priceInCopper, vendorName = SearchInItemPrices(itemName)

            -- If a price is found, add it to the tooltip
            if priceInCopper then
                tooltip:AddLine(string.format("Stored price: %d copper", priceInCopper), 1, 1, 0)
                tooltip:AddLine(string.format("Vendor: %s", vendorName), 0, 1, 0)
            else
                tooltip:AddLine("No stored price found.", 1, 0, 0)
            end

            tooltip:Show() -- Refresh the tooltip to display the new lines
        end
    end
end

-- Hook the tooltip function to display item prices when hovering over items
GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)

-- Example usage of PrintLoadedData function (to be called in chat)
-- /run PrintLoadedData() to print out hardcoded data
