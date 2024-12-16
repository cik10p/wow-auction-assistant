-- AuctionAssistant: An addon to manage item prices and vendors with slash commands

-- Initialize SavedVariables if it doesn't exist
AuctionAssistantData = AuctionAssistantData or {}

ShowNoPriceMessage = false

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

-- ################   AH Commands   ################


SLASH_SCANPRICE1 = "/scanprice"

local function isAuctionHouseOpen()
    return AuctionFrame and AuctionFrame:IsShown()
end

function SlashCmdList.SCANPRICE(msg)
    -- Hardcode the item name
    local itemName = "Light Leather"

    -- Ensure the auction house is open
    if not isAuctionHouseOpen() then
        print("Auction house is not open. Please open the auction house and try again.")
        return
    end

    -- Search the auction house for the item
    local totalResults = 0
    local minBuyout = math.huge
    local minPriceString = ""

    -- Loop through the auction house listings
    for i = 1, GetNumAuctionItems("list") do
        local name, _, _, _, _, _, _, _, _, _, _, _, _, _, buyoutPrice = GetAuctionItemInfo("list", i)

        if name and name:lower() == itemName:lower() then
            totalResults = totalResults + 1
            if buyoutPrice and buyoutPrice > 0 then
                if buyoutPrice < minBuyout then
                    minBuyout = buyoutPrice
                    minPriceString = GetCoinTextureString(buyoutPrice)
                end
            end
        end
    end

    if totalResults == 0 then
        print("No auctions found for '" .. itemName .. "'.")
    else
        if minBuyout == math.huge then
            print("No buyout prices found for '" .. itemName .. "'.")
        else
            print("The lowest buyout price for '" .. itemName .. "' is: " .. minPriceString)
        end
    end
end

-- ## END OF AUCTION HOUSE COMMANDS ##





-- Function to add item link formatting (wrap the item name in [])
function AddItemLinkName(itemName)
    return "[" .. itemName .. "]"
end

-- Function to delete an item price from the AuctionAssistantData
function DeleteItemPrice(itemLinkOrName)
    local itemName = CleanItemName(itemLinkOrName)
    
    if AuctionAssistantData[itemName] then
        AuctionAssistantData[itemName] = nil
        print("Deleted item: " .. AddItemLinkName(itemName))  -- Use AddItemLinkName here
    else
        print("Item not found: " .. AddItemLinkName(itemName))  -- Use AddItemLinkName here
    end
end

-- Define the slash command to clear all data in AuctionAssistantData
SLASH_AACLEARALL1 = "/clearall"
SlashCmdList["AACLEARALL"] = function()
    -- Clear the AuctionAssistantData table
    AuctionAssistantData = {}

    -- Confirm to the user that the data has been cleared
    print("AuctionAssistant data has been cleared.")
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



-- Function to quickly update the price of an item
function QuickUpdatePrice(itemLinkOrName, price)
    -- Clean the item name (remove item link formatting)
    local itemName = CleanItemName(itemLinkOrName)
    
    -- Check if the item already exists
    if AuctionAssistantData[itemName] then
        -- Update the price while keeping the vendor price unchanged
        AuctionAssistantData[itemName].price = price
        print("Updated price for: " .. AddItemLinkName(itemName))
    else
        -- Create a new entry with vendor price set to 0
        AuctionAssistantData[itemName] = {price = price, vendor = 0}
        print("Added new item with price: " .. AddItemLinkName(itemName))
    end

    -- Print the updated data to the chat window
    print(string.format("Item: %s, Price: %d copper, Vendor: %d copper", AddItemLinkName(itemName), price, AuctionAssistantData[itemName].vendor))
end

-- Function to quickly update the vendor price of an item
function QuickUpdateVendorPrice(itemLinkOrName, vendor)
    -- Clean the item name (remove item link formatting)
    local itemName = CleanItemName(itemLinkOrName)
    
    -- Check if the item already exists
    if AuctionAssistantData[itemName] then
        -- Update the vendor price while keeping the item price unchanged
        AuctionAssistantData[itemName].vendor = vendor
        print("Updated vendor price for: " .. AddItemLinkName(itemName))
    else
        -- Create a new entry with item price set to 0
        AuctionAssistantData[itemName] = {price = 0, vendor = vendor}
        print("Added new item with vendor price: " .. AddItemLinkName(itemName))
    end

    -- Print the updated data to the chat window
    print(string.format("Item: %s, Price: %d copper, Vendor: %d copper", AddItemLinkName(itemName), AuctionAssistantData[itemName].price, vendor))
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

-- Define the slash command to quickly update item prices
SLASH_AAQUICKUPDATE1 = "/ap"
SlashCmdList["AAQUICKUPDATE"] = function(msg)
    -- Split the message into item name or item link and price
    local itemLinkOrName, price = strsplit(",", msg)
    price = tonumber(price)  -- Convert price to a number

    -- Check if the input is valid (item name or item link and price must be provided)
    if itemLinkOrName and price then
        -- Call the QuickUpdatePrice function with the provided arguments
        QuickUpdatePrice(itemLinkOrName, price)
    else
        -- Provide usage instructions if the input is invalid
        print("Usage: /ap <Item Name or Item Link>, <Price>")
    end
end

-- Define the slash command to quickly update vendor prices
SLASH_AAQUICKUPDATEVENDOR1 = "/vp"
SlashCmdList["AAQUICKUPDATEVENDOR"] = function(msg)
    -- Split the message into item name or item link and vendor price
    local itemLinkOrName, vendor = strsplit(",", msg)
    vendor = tonumber(vendor)  -- Convert vendor price to a number

    -- Check if the input is valid (item name or item link and vendor price must be provided)
    if itemLinkOrName and vendor then
        -- Call the QuickUpdateVendorPrice function with the provided arguments
        QuickUpdateVendorPrice(itemLinkOrName, vendor)
    else
        -- Provide usage instructions if the input is invalid
        print("Usage: /vp <Item Name or Item Link>, <Vendor Price>")
    end
end

-- Define the slash command to delete item prices
SLASH_AADELETEPRICE1 = "/dp"
SlashCmdList["AADELETEPRICE"] = function(msg)
    -- Get the item name or item link from the message
    local itemLinkOrName = msg:match("^%s*(.-)%s*$")  -- Trim whitespace

    -- Check if the input is valid (item name or item link must be provided)
    if itemLinkOrName and itemLinkOrName ~= "" then
        -- Call the DeleteItemPrice function with the provided argument
        DeleteItemPrice(itemLinkOrName)
    else
        -- Provide usage instructions if the input is invalid
        print("Usage: /dp <Item Name or Item Link>")
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
        print(string.format("Item: %s, Price: %d copper, Vendor: %d copper", AddItemLinkName(itemName), itemData.price, itemData.vendor))  -- Use AddItemLinkName here
    end
end

-- Define the slash command to print all data in AuctionAssistantData
SLASH_AAPRINTDATA1 = "/pp"
SlashCmdList["AAPRINTDATA"] = function()
    -- Call the PrintLoadedData function to print the data
    PrintLoadedData()
end

local function CalculateCurrency(copper)
    local gold = math.floor(copper / 10000) -- 1 gold = 10000 copper
    local remainder = copper % 10000
    local silver = math.floor(remainder / 100) -- 1 silver = 100 copper
    local copperLeft = remainder % 100
    return gold, silver, copperLeft
end

-- Tooltip hook to display prices and vendors for items in the tooltip
local function OnTooltipSetItem(tooltip)
    local _, itemLink = tooltip:GetItem()
    if itemLink then
        local itemName = CleanItemName(itemLink)
        if itemName then
            -- Search for the item in AuctionAssistantData
            local priceInCopper, vendorPriceInCopper = SearchInItemPrices(itemName)

            -- If a price is found, format and add it to the tooltip
            if priceInCopper then
                -- Convert auction price to gold, silver, and copper
                local goldAuction, silverAuction, copperAuction = CalculateCurrency(priceInCopper)
                local goldTextAuction = string.format("|cffffd700%d|r", goldAuction) -- Gold color
                local silverTextAuction = string.format("|cffc7c7cf%02d|r", silverAuction) -- Silver color
                local copperTextAuction = string.format("|cffeda55f%02d|r", copperAuction) -- Copper color
                local auctionLine = string.format("Auction: %s %s %s", goldTextAuction, silverTextAuction, copperTextAuction)
                tooltip:AddLine(auctionLine, 1, 1, 0)

                -- Convert vendor price to gold, silver, and copper
                if vendorPriceInCopper then
                    local goldVendor, silverVendor, copperVendor = CalculateCurrency(vendorPriceInCopper)
                    local goldTextVendor = string.format("|cffffd700%d|r", goldVendor)
                    local silverTextVendor = string.format("|cffc7c7cf%02d|r", silverVendor)
                    local copperTextVendor = string.format("|cffeda55f%02d|r", copperVendor)
                    local vendorLine = string.format("Vendor: %s %s %s", goldTextVendor, silverTextVendor, copperTextVendor)
                    tooltip:AddLine(vendorLine, 0, 1, 0)
                else
                    tooltip:AddLine("No vendor price found.", 1, 0, 0)
                end
            else
                if ShowNoPriceMessage then
                    tooltip:AddLine("No stored price found.", 1, 0, 0)
                end
            end

            tooltip:Show() -- Refresh the tooltip to display the new lines
        end
    end
end

-- Hook the tooltip function to display item prices when hovering over items
GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)

-- Example usage of PrintLoadedData function (to be called in chat)
-- /run PrintLoadedData() to print out hardcoded data
