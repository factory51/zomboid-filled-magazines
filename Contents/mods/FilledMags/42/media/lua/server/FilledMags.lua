-- FilledMags: magazines that spawn as world loot arrive partly or fully loaded.

local function isLooseMagazine(item)
    if instanceof(item, "HandWeapon") then return false end
    return item:getMaxAmmo() > 0
end

local function fillMagazines(roomName, containerType, itemContainer)
    local opts = SandboxVars.FilledMags
    if not opts then return end

    -- Procedural rolls can fire this event with the distribution definition
    -- (ItemPickerContainer) instead of a real container; there is nothing to fill then.
    if not instanceof(itemContainer, "ItemContainer") then return end

    local minPct = math.min(opts.MinFillPercent, opts.MaxFillPercent)
    local maxPct = math.max(opts.MinFillPercent, opts.MaxFillPercent)

    local items = itemContainer:getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if isLooseMagazine(item) and ZombRand(100) < opts.Chance then
            local maxAmmo = item:getMaxAmmo()
            local pct = minPct + ZombRand(maxPct - minPct + 1)
            item:setCurrentAmmoCount(math.floor(maxAmmo * pct / 100 + 0.5))
        end
    end
end

Events.OnFillContainer.Add(fillMagazines)
