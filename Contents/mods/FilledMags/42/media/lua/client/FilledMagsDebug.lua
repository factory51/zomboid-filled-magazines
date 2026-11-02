-- FilledMags admin tool: right-click a magazine to set its ammo.
-- Available in debug mode, or to server admins with item-edit rights. The change is
-- made on the server so it works on dedicated servers.

local function canUse()
    if isDebugEnabled() then return true end
    return isClient() and getPlayer():getRole():hasCapability(Capability.EditItem)
end

local function setAmmo(player, list, pct)
    for _, m in ipairs(list) do
        sendClientCommand(player, "FilledMags", "setAmmo", { id = m:getID(), fraction = pct / 100 })
    end
end

local function onFillMenu(playerNum, context, items)
    if not canUse() then return end

    local mags = {}
    for _, item in ipairs(ISInventoryPane.getActualItems(items)) do
        if not instanceof(item, "HandWeapon") and item:getMaxAmmo() > 0 then
            table.insert(mags, item)
        end
    end
    if #mags == 0 then return end

    local player = getSpecificPlayer(playerNum)
    local parent = context:addOption("[Admin] Fill magazine")
    local sub = ISContextMenu:getNew(context)
    context:addSubMenu(parent, sub)
    for _, pct in ipairs({ 100, 50, 25, 0 }) do
        sub:addOption("Set ammo to " .. pct .. "%", player, setAmmo, mags, pct)
    end
    sub:addOption("Set ammo to random 25-100%", player, function(p)
        for _, m in ipairs(mags) do
            sendClientCommand(p, "FilledMags", "setAmmo", { id = m:getID(), fraction = (25 + ZombRand(76)) / 100 })
        end
    end)
end

Events.OnFillInventoryObjectContextMenu.Add(onFillMenu)
