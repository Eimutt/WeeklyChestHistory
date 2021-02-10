local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("WEEKLY_REWARDS_SHOW")
frame:RegisterEvent("WEEKLY_REWARDS_UPDATE")


function GetDate()
    local d = C_DateAndTime.GetCurrentCalendarTime()
    local date = format("%d.%s.%d", d.monthDay, d.month, d.year)
    print(date)
    return date
end

local characterName = GetUnitName("player")
local globaldate = GetDate()

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "WeeklyChestHistory" then
        print("TESTADDONLOADEDEDEDED")
        -- Our saved variables, if they exist, have been loaded at this point.
        if WeeklyRewardsSave == nil then
            -- This is the first time this addon is loaded; set SVs to default values
            WeeklyRewardsSave = {}
            print("First ime loading addon")
        end

        if WeeklyRewardsSave[characterName] == nil and UnitLevel("player") == 60 then 
            WeeklyRewardsSave[characterName] = {}
            print("new character found :" + characterName)
        end
    end

    if event == "WEEKLY_REWARDS_SHOW" and UnitLevel("player") == 60 then
        if C_WeeklyRewards.HasAvailableRewards() then
            AddWeeklyEntry()
            C_Timer.After(1, function() GetItemsFromVault() end)
        end
    end
end)

function GetItemsFromVault()
    local activities = C_WeeklyRewards.GetActivities()
    for i, activityInfo in ipairs(activities) do
        for j, rewardInfo in ipairs(activityInfo.rewards) do --get two rewards from content, includes m+ key
            local itemName, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(rewardInfo.id);
            if itemName ~= "Mythic Keystone" and itemName ~= "Condensed Stygia" and itemName ~= "Ancient Insignia" then --ignore key
                local itemLink = C_WeeklyRewards.GetItemHyperlink(rewardInfo.itemDBID)
                print(itemName)
                if itemLink ~= "[]" then --ugly solution ( empty for some reason?? )
                    --print(itemLink)
                    WeeklyRewardsSave[characterName][globaldate][i] = itemLink
                end
            end
        end
    end
end

function AddWeeklyEntry()
    if WeeklyRewardsSave[characterName][globaldate] == nil then
        WeeklyRewardsSave[characterName][globaldate] = {}
        print("Added new week entry for " .. characterName)
    end
end



function PrintData()
    print("Printing save data")
    for index, data in pairs(WeeklyRewardsSave) do
        print("Character: " .. index)
        for week, weekdata in pairs(WeeklyRewardsSave[index]) do
            print("Week: " .. week)
            for reward, rewardData in pairs(WeeklyRewardsSave[index][week]) do
                -- local itemLink = C_WeeklyRewards.GetItemHyperlink(rewardData)
                -- print(itemLink)
                print("reward " .. reward .. ": " .. rewardData)
            end
        end
    end
end

function Main(msg)

    if(msg == "print") then
        PrintData();
    end



    if(msg == "reset") then
        WeeklyRewardsSave = nil
        print("data reset")
        ReloadUI()
    end

end


SLASH_TEST1 = "/test"
SlashCmdList["TEST"] = Main;