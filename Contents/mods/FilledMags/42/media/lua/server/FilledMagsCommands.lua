-- Server side of the FilledMags admin tool: sets the ammo of a magazine the
-- requesting admin is carrying, then syncs the item to clients.

local function canEdit(player)
    if not isServer() then return isDebugEnabled() end
    return player:getRole():hasCapability(Capability.EditItem)
end

local function onClientCommand(module, command, player, args)
    if module ~= "FilledMags" or command ~= "setAmmo" then return end
    if not canEdit(player) then return end

    local item = player:getInventory():getItemById(args.id)
    if not item or instanceof(item, "HandWeapon") or item:getMaxAmmo() <= 0 then return end

    local fraction = math.max(0, math.min(1, args.fraction))
    item:setCurrentAmmoCount(math.floor(item:getMaxAmmo() * fraction + 0.5))
    if isServer() then
        sendReplaceItemInContainer(item:getContainer(), item, item)
    end
end

Events.OnClientCommand.Add(onClientCommand)
