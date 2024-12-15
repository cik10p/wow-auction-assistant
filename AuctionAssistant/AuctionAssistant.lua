-- AuctionAssistant: Tooltip enhancer for auction and vendor info

-- Create a frame to handle events
local AuctionAssistantFrame = CreateFrame("Frame")

-- Hardcoded total currency in copper (e.g., 1 gold, 5 silver, 5 copper = 10505 copper)
local totalCopper = 10503

-- Function to calculate gold, silver, and copper
local function CalculateCurrency(copper)
    local gold = math.floor(copper / 10000) -- 1 gold = 10000 copper
    local remainder = copper % 10000
    local silver = math.floor(remainder / 100) -- 1 silver = 100 copper
    local copperLeft = remainder % 100
    return gold, silver, copperLeft
end

-- Function to add lines to tooltips
local function OnTooltipSetItem(tooltip)
    -- Check if the tooltip has an item
    local _, itemLink = tooltip:GetItem()
    if itemLink then
        -- Calculate gold, silver, and copper amounts
        local goldAmount, silverAmount, copperAmount = CalculateCurrency(totalCopper)

        -- Format the currency values with color codes
        local goldText = string.format("|cffffd700%d|r", goldAmount) -- Gold color
        local silverText = string.format("|cffc7c7cf%02d|r", silverAmount) -- Silver color
        local copperText = string.format("|cffeda55f%02d|r", copperAmount) -- Copper color

        -- Combine the currency values into one line
        local auctionLine = string.format("auction %s %s %s", goldText, silverText, copperText)

        -- Add the formatted line to the tooltip
        tooltip:AddLine(auctionLine, 1, 1, 0) -- Yellow text
        tooltip:AddLine("vendor", 0, 1, 0) -- Green text
        tooltip:Show() -- Refresh the tooltip to display the new lines
    end
end

-- Hook the function to the tooltip
GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
