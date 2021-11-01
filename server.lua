QBCore = exports['qb-core']:GetCoreObject()

-- Callbacks

QBCore.Functions.CreateCallback('fivem-appearance:getPlayerSkin', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local players_appearance = exports.oxmysql:executeSync('SELECT appearance FROM players_appearance WHERE citizenid = ?', {Player.PlayerData.citizenid})
    if players_appearance[1] then
	    pedAppearance = json.decode(players_appearance[1].appearance)
    end
    cb(pedAppearance)
end)

-- Events

RegisterServerEvent("fivem-appearance:saveSkin") 
AddEventHandler('fivem-appearance:saveSkin', function(pedModel, pedAppearance)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if pedModel ~= nil and pedAppearance ~= nil then 
        exports.oxmysql:execute('DELETE FROM players_appearance WHERE citizenid = ?', {Player.PlayerData.citizenid}, function()
            exports.oxmysql:execute('INSERT INTO players_appearance (citizenid, model, appearance) VALUES (?, ?, ?)', {Player.PlayerData.citizenid, json.encode(pedModel), json.encode(pedAppearance)})
        end)
		print('saved')
    end
end)

-- Player Outfits 

RegisterNetEvent('fivem-appearance:saveOutfit', function(name, pedModel, pedComponents, pedProps)
	local Player = QBCore.Functions.GetPlayer(source)
	exports.oxmysql:insert('INSERT INTO `players_outfits` (citizenid, name, ped, components, props) VALUES (?, ?, ?, ?, ?)', {Player.PlayerData.citizenid, name, json.encode(pedModel), json.encode(pedComponents), json.encode(pedProps)})
end)

RegisterNetEvent('fivem-appearance:getOutfit', function(name)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local outfit = exports.oxmysql:executeSync('SELECT outfit FROM players_outfits WHERE citizenid = ? AND name = ?', {Player.PlayerData.citizenid, name})
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
	local result = exports.oxmysql:executeSync('SELECT id, name, ped, components, props FROM players_outfits WHERE citizenid = ?', {Player.PlayerData.citizenid})
	for i=1, #result, 1 do
		table.execute(myOutfits, {id = result[i].id, name = result[i].name, ped = json.decode(result[i].ped), components = json.decode(result[i].components), props = json.decode(result[i].props)})
	end
	TriggerClientEvent('fivem-appearance:sendOutfits', src, myOutfits)
end)

-- PD Presets

RegisterServerEvent('fivem-appearance:getpdPreset', function(name)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local presets = exports.oxmysql:executeSync('SELECT presets FROM players_pd_presets WHERE name = ?', {name})
	local newPreset = presets
	if newPresets then
		newPresets = json.decode(newPresets)
		TriggerClientEvent('fivem-appearance:setpdPresets', src, newPresets)
	end
end)

RegisterNetEvent('fivem-appearance:deleteOutfit', function(id)
	local Player = QBCore.Functions.GetPlayer(source)
	exports.oxmysql:execute('DELETE FROM players_outfits WHERE id = ?', {id})
end)