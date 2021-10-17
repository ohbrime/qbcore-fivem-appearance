local QBCore = exports['qb-core']:GetCoreObject()

-- Callbacks

QBCore.Functions.CreateCallback('fivem-appearance:getPlayerSkin', function(source, cb)
	local Player = QBCore.Functions.GetPlayer(source)
	local players = exports.oxmysql:fetch('SELECT skin FROM players WHERE citizenid = ?', {Player.PlayerData.citizenid})
	local player, appearance = players[1]
	if player.skin then
		appearance = json.decode(player.skin)
	end
	cb(appearance)
end)

-- Events

RegisterNetEvent('fivem-appearance:save', function(appearance)
	local Player = QBCore.Functions.GetPlayer(source)
	exports.oxmysql:execute('UPDATE players SET skin = ? WHERE citizenid = ?', {json.encode(appearance), Player.PlayerData.citizenid})
end)

RegisterNetEvent('fivem-appearance:saveOutfit', function(name, pedModel, pedComponents, pedProps)
	local Player = QBCore.Functions.GetPlayer(source)
	exports.oxmysql:insert('INSERT INTO `player_outfits` (citizenid, name, ped, components, props) VALUES (?, ?, ?, ?, ?)', {Player.PlayerData.citizenid, name, json.encode(pedModel), json.encode(pedComponents), json.encode(pedProps)})
end)

RegisterNetEvent('fivem-appearance:getOutfit', function(name)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local outfit = exports.oxmysql:fetchSync('SELECT outfit FROM player_outfits WHERE citizenid = @citizenid AND name = @name', {['@citizenid'] = Player.PlayerData.citizenid, ['@name'] = name})
	local newOutfit = outfit
	if newOutfit then
		newOutfit = json.decode(newOutfit)
		TriggerClientEvent('fivem-appearance:setOutfit', src, newOutfit)
	end
end)

RegisterNetEvent('fivem-appearance:getOutfits', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local myOutfits = {}
	local result = exports.oxmysql:fetchSync('SELECT id, name, ped, components, props FROM player_outfits WHERE citizenid = ?', {Player.PlayerData.citizenid})
	for i=1, #result, 1 do
		table.insert(myOutfits, {id = result[i].id, name = result[i].name, ped = json.decode(result[i].ped), components = json.decode(result[i].components), props = json.decode(result[i].props)})
	end
	TriggerClientEvent('fivem-appearance:sendOutfits', src, myOutfits)
end)

-- PD Presets

RegisterServerEvent('fivem-appearance:getpdPreset', function(name)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local presets = exports.oxmysql:fetchSync('SELECT presets FROM player_pdpresets WHERE name = ?', {name})
	local newPreset = presets
	if newPresets then
		newPresets = json.decode(newPresets)
		TriggerClientEvent('fivem-appearance:setpdPresets', src, newPresets)
	end
end)

RegisterNetEvent('fivem-appearance:deleteOutfit', function(id)
	local Player = QBCore.Functions.GetPlayer(source)
	exports.oxmysql:execute('DELETE FROM player_outfits WHERE id = ?', {id})
end)