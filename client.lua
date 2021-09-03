local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local hasAlreadyEnteredMarker = false
local allMyOutfits = {}
local StoreCost = 250;

QBCore = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if QBCore == nil then
            TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)
            Citizen.Wait(200)
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(2000, function()
        QBCore.Functions.TriggerCallback('fivem-appearance:getPlayerSkin', function(appearance)
		exports['fivem-appearance']:setPlayerAppearance(appearance)
        isLoggedIn = true
		end)
    end)
end)

RegisterCommand('reloadskin', function()
	QBCore.Functions.TriggerCallback('fivem-appearance:getPlayerSkin', function(appearance)
		exports['fivem-appearance']:setPlayerAppearance(appearance)
	end)
end)

RegisterNetEvent('fivem-appearance:client:CreateFirstCharacter')
AddEventHandler('fivem-appearance:client:CreateFirstCharacter', function()
	local config = {
		ped = true,
		headBlend = true,
		faceFeatures = true,
		headOverlays = true,
		components = true,
		props = true,
	}

	exports['fivem-appearance']:setPlayerAppearance(appearance)

	exports['fivem-appearance']:startPlayerCustomization(function (appearance)
		if (appearance) then
			TriggerServerEvent('fivem-appearance:save', appearance)
			print('Saved')
		else
			print('Canceled')
		end
	end, config)
end, false)

-- RegisterCommand('appearance', function()
-- 	local config = {
-- 		ped = true,
-- 		headBlend = true,
-- 		faceFeatures = true,
-- 		headOverlays = true,
-- 		components = true,
-- 		props = true,
-- 	}
-- 	exports['fivem-appearance']:startPlayerCustomization(function (appearance)
-- 		if (appearance) then
-- 			TriggerServerEvent('fivem-appearance:save', appearance)
-- 			print('Saved')
-- 		else
-- 			print('Canceled')
-- 		end
-- 	end, config)
-- end, false)

Citizen.CreateThread(function()
	while true do
		local playerCoords, isInClothingShop, isInPDPresets, isInBarberShop, currentZone, letSleep = GetEntityCoords(PlayerPedId()), false, false, nil, true
		local sleep = 2000
		for k,v in pairs(Config.ClothingShops) do
			local data = v
			local distance = #(playerCoords - data.coords)

			if distance < Config.DrawDistance then
				sleep = 0
				if distance < data.MarkerSize.x then
					isInClothingShop, currentZone = true, k
				end
			end
		end

		for k,v in pairs(Config.PDPresets) do
			local data = v
			local distance = #(playerCoords - data.coordss)

			if distance < Config.DrawDistance then
				sleep = 0
				if distance < data.MarkerSize.x then
					isInPDPresets, currentZone = true, k
				end
			end
		end

		for k,v in pairs(Config.BarberShops) do
			local distance = #(playerCoords - v)

			if distance < Config.DrawDistance then
				sleep = 0
				if distance < Config.MarkerSize.x then
					isInBarberShop, currentZone = true, k
				end
			end
		end
		
		if (isInClothingShop and not hasAlreadyEnteredMarker) or (isInClothingShop and LastZone ~= currentZone) then
			hasAlreadyEnteredMarker, LastZone = true, currentZone
			CurrentAction     = 'clothingMenu'
			TriggerEvent('cd_drawtextui:ShowUI', 'show', "Press [E] To Change Clothing")
		end

		if (isInPDPresets and not hasAlreadyEnteredMarker) or (isInPDPresets and LastZone ~= currentZone) then
			hasAlreadyEnteredMarker, LastZone = true, currentZone
			CurrentAction     = 'pdMenu'
			TriggerEvent('cd_drawtextui:ShowUI', 'show', "Press [E] To Change Outfits")
		end

		if (isInBarberShop and not hasAlreadyEnteredMarker) or (isInBarberShop and LastZone ~= currentZone) then
			hasAlreadyEnteredMarker, LastZone = true, currentZone
			CurrentAction     = 'barberMenu'
			TriggerEvent('cd_drawtextui:ShowUI', 'show', "Press [E] To Change Hair/Face")
		end

		if not isInClothingShop and not isInPDPresets and not isInBarberShop and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			sleep = 1000
			TriggerEvent('fivem-appearance:hasExitedMarker', LastZone)
			TriggerEvent('cd_drawtextui:HideUI')
		end

		Citizen.Wait(sleep)
	end
end)

AddEventHandler('fivem-appearance:hasExitedMarker', function(zone)
	CurrentAction = nil
end)

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if CurrentAction ~= nil then

			if IsControlPressed(1, 38) then
				Citizen.Wait(500)

				if CurrentAction == 'clothingMenu' then
					TriggerEvent("fivem-appearance:clothingShop")
				end
				
				if CurrentAction == 'barberMenu' then
					TriggerEvent("fivem-appearance:barberMenu")
				end

				if QBCore.Functions.GetPlayerData().job.name =='police' then
				    if CurrentAction == 'pdMenu' then
					    TriggerEvent("fivem-appearance:pdMenu")
					end
				end
			end
		end
	end
end)

RegisterNetEvent('fivem-appearance:clothingShop', function()
    TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "Change clothing",
            txt = "",
			params = {
				event = "fivem-appearance:clothingMenu"
			}
        },
        {
            id = 2,
            header = "Change Outfit",
            txt = "",
            params = {
                event = "fivem-appearance:pickNewOutfit",
                args = {
                    number = 1,
                    id = 2
                }
            }
        },
		{
            id = 3,
            header = "Save New Outfit",
            txt = "",
			params = {
				event = "fivem-appearance:saveOutfit"
			}
        },
		{
			id = 4,
            header = "Delete Outfit",
            txt = "",
            params = {
                event = "fivem-appearance:deleteOutfitMenu",
                args = {
                    number = 1,
                    id = 2
                }
            }
        }
    })
end)

RegisterNetEvent('fivem-appearance:outfitsMenu', function()
    TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "Change Outfit",
            txt = "",
            params = {
                event = "fivem-appearance:pickNewOutfit2",
                args = {
                    number = 1,
                    id = 2
                }
            }
        },
		{
            id = 2,
            header = "Save New Outfit",
            txt = "",
			params = {
				event = "fivem-appearance:saveOutfit"
			}
        },
		{
			id = 3,
            header = "Delete Outfit",
            txt = "",
            params = {
                event = "fivem-appearance:deleteOutfitMenu2",
                args = {
                    number = 1,
                    id = 2
                }
            }
        }
    })
end)

RegisterNetEvent('fivem-appearance:pdMenu', function()
    TriggerEvent('nh-context:sendMenu', {
        
		{
			id = 1,
            header = "PD Outfits",
            txt = "",
            params = {
                event = "fivem-appearance:presetsOutfitMenu",
                args = {
                    number = 1,
                    id = 2
                }
            }
        },
		{
            id = 2,
            header = "Change Outfit",
            txt = "",
            params = {
                event = "fivem-appearance:pickNewOutfit3",
                args = {
                    number = 1,
                    id = 2
                }
            }
        },
    })
end)

RegisterNetEvent('fivem-appearance:clothingMenu', function()
	local config = {
		ped = true,
		headBlend = false,
		faceFeatures = false,
		headOverlays = false,
		components = true,
		props = true
	}
	
	exports['fivem-appearance']:startPlayerCustomization(function (appearance)
		if (appearance) then
			TriggerServerEvent('fivem-appearance:save', appearance)
			TriggerServerEvent("fivem-appearance:checkMoney", StoreCost)
			print('Saved')
		else
			print('Canceled')
		end
	end, config)
end)

RegisterNetEvent('fivem-appearance:barberMenu', function()
	local config = {
		ped = true,
		headBlend = true,
		faceFeatures = true,
		headOverlays = true,
		components = false,
		props = false
	}

	exports['fivem-appearance']:startPlayerCustomization(function (appearance)
		if (appearance) then
			TriggerServerEvent('fivem-appearance:save', appearance)
			print('Saved')
		else
			print('Canceled')
		end
	end, config)
end)

RegisterNetEvent('fivem-appearance:pickNewOutfit', function(data)
    local id = data.id
    local number = data.number
	TriggerEvent('fivem-appearance:getOutfits')
    TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "< Go Back",
            txt = "",
            params = {
                event = "fivem-appearance:clothingShop"
            }
        },
    })
	Citizen.Wait(300)
	for i=1, #allMyOutfits, 1 do
		TriggerEvent('nh-context:sendMenu', {
			{
				id = (1 + i),
				header = allMyOutfits[i].name,
				txt = "",
				params = {
					event = 'fivem-appearance:setOutfit',
					args = {
						ped = allMyOutfits[i].pedModel, 
						components = allMyOutfits[i].pedComponents, 
						props = allMyOutfits[i].pedProps
					}
				}
			},
		})
	end
end)

RegisterNetEvent('fivem-appearance:pickNewOutfit2', function(data)
    local id = data.id
    local number = data.number
	TriggerEvent('fivem-appearance:getOutfits')
    TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "< Go Back",
            txt = "",
            params = {
                event = "fivem-appearance:outfitsMenu"
            }
        },
    })
	Citizen.Wait(300)
	for i=1, #allMyOutfits, 1 do
		TriggerEvent('nh-context:sendMenu', {
			{
				id = (1 + i),
				header = allMyOutfits[i].name,
				txt = "",
				params = {
					event = 'fivem-appearance:setOutfit',
					args = {
						ped = allMyOutfits[i].pedModel, 
						components = allMyOutfits[i].pedComponents, 
						props = allMyOutfits[i].pedProps
					}
				}
			},
		})
	end
end)

RegisterNetEvent('fivem-appearance:presetsOutfitMenu', function(data)
    local id = data.id
    local number = data.number
	TriggerEvent('fivem-appearance:getpdPresets')
    TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "< Go Back",
            txt = "",
            params = {
                event = "fivem-appearance:pdMenu"
            }
        },
    })
	Citizen.Wait(300)
	for i=1, #allPDPresets, 1 do
		TriggerEvent('nh-context:sendMenu', {
			{
				id = (1 + i),
				header = allPDPresets[i].name,
				txt = "",
				params = {
					event = 'fivem-appearance:setpdPreset',
					args = {
						ped = allPDPresets[i].pedModel, 
						components = allPDPresets[i].pedComponents, 
						props = allPDPresets[i].pedProps
					}
				}
			},
		})
	end
end)

RegisterNetEvent('fivem-appearance:pickNewOutfit3', function(data)
    local id = data.id
    local number = data.number
	TriggerEvent('fivem-appearance:getOutfits')
    TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "< Go Back",
            txt = "",
            params = {
                event = "fivem-appearance:pdMenu"
            }
        },
    })
	Citizen.Wait(300)
	for i=1, #allMyOutfits, 1 do
		TriggerEvent('nh-context:sendMenu', {
			{
				id = (1 + i),
				header = allMyOutfits[i].name,
				txt = "",
				params = {
					event = 'fivem-appearance:setOutfit',
					args = {
						ped = allMyOutfits[i].pedModel, 
						components = allMyOutfits[i].pedComponents, 
						props = allMyOutfits[i].pedProps
					}
				}
			},
		})
	end
end)

RegisterNetEvent('fivem-appearance:getOutfits')
AddEventHandler('fivem-appearance:getOutfits', function()
	TriggerServerEvent('fivem-appearance:getOutfits')
end)

RegisterNetEvent('fivem-appearance:getpdPresets')
AddEventHandler('fivem-appearance:getpdPresets', function()
	TriggerServerEvent('fivem-appearance:getpdPresets')
end)

RegisterNetEvent('fivem-appearance:sendOutfits')
AddEventHandler('fivem-appearance:sendOutfits', function(myOutfits)
	local Outfits = {}
	for i=1, #myOutfits, 1 do
		table.insert(Outfits, {id = myOutfits[i].id, name = myOutfits[i].name, pedModel = myOutfits[i].ped, pedComponents = myOutfits[i].components, pedProps = myOutfits[i].props})
	end
	allMyOutfits = Outfits
end)

RegisterNetEvent('fivem-appearance:sendpdPresets')
AddEventHandler('fivem-appearance:sendpdPresets', function(pdPresets)
	local Outfits = {}
	for i=1, #pdPresets, 1 do
		table.insert(Outfits, {id = pdPresets[i].id, name = pdPresets[i].name, pedModel = pdPresets[i].ped, pedComponents = pdPresets[i].components, pedProps = pdPresets[i].props})
	end
	allPDPresets = Outfits
end)

RegisterNetEvent('fivem-appearance:setOutfit')
AddEventHandler('fivem-appearance:setOutfit', function(data)
	local pedModel = data.ped
	local pedComponents = data.components
	local pedProps = data.props
	local playerPed = PlayerPedId()
	local currentPedModel = exports['fivem-appearance']:getPedModel(playerPed)
	if currentPedModel ~= pedModel then
    	exports['fivem-appearance']:setPlayerModel(pedModel)
		Citizen.Wait(500)
		playerPed = PlayerPedId()
		exports['fivem-appearance']:setPedComponents(playerPed, pedComponents)
		exports['fivem-appearance']:setPedProps(playerPed, pedProps)
		local appearance = exports['fivem-appearance']:getPedAppearance(playerPed)
		TriggerServerEvent('fivem-appearance:save', appearance)
	else
		exports['fivem-appearance']:setPedComponents(playerPed, pedComponents)
		exports['fivem-appearance']:setPedProps(playerPed, pedProps)
		local appearance = exports['fivem-appearance']:getPedAppearance(playerPed)
		TriggerServerEvent('fivem-appearance:save', appearance)
	end
end)

RegisterNetEvent('fivem-appearance:setpdPreset')
AddEventHandler('fivem-appearance:setpdPreset', function(data)
	local pedModel = data.ped
	local pedComponents = data.components
	local pedProps = data.props
	local playerPed = PlayerPedId()
	local currentPedModel = exports['fivem-appearance']:getPedModel(playerPed)
	if currentPedModel ~= pedModel then
    	exports['fivem-appearance']:setPlayerModel(pedModel)
		Citizen.Wait(500)
		playerPed = PlayerPedId()
		exports['fivem-appearance']:setPedComponents(playerPed, pedComponents)
		exports['fivem-appearance']:setPedProps(playerPed, pedProps)
		local appearance = exports['fivem-appearance']:getPedAppearance(playerPed)
		TriggerServerEvent('fivem-appearance:save', appearance)
	else
		exports['fivem-appearance']:setPedComponents(playerPed, pedComponents)
		exports['fivem-appearance']:setPedProps(playerPed, pedProps)
		local appearance = exports['fivem-appearance']:getPedAppearance(playerPed)
		TriggerServerEvent('fivem-appearance:save', appearance)
	end
end)

RegisterNetEvent('fivem-appearance:saveOutfit', function()
	local keyboard = exports["brime-keyboard"]:KeyboardInput({
		header = "Name Outfit", 
		rows = {
			{
				id = 0, 
				txt = ""
			}
		}
	})
	if keyboard ~= nil then
		local playerPed = PlayerPedId()
		local pedModel = exports['fivem-appearance']:getPedModel(playerPed)
		local pedComponents = exports['fivem-appearance']:getPedComponents(playerPed)
		local pedProps = exports['fivem-appearance']:getPedProps(playerPed)
		Citizen.Wait(500)
		TriggerServerEvent('fivem-appearance:saveOutfit', keyboard[1].input, pedModel, pedComponents, pedProps)
	end
end)

RegisterNetEvent('fivem-appearance:deleteOutfitMenu2', function(data)
    local id = data.id
    local number = data.number
	TriggerEvent('fivem-appearance:getOutfits')
	Citizen.Wait(150)
    TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "< Go Back",
            txt = "",
            params = {
                event = "fivem-appearance:outfitsMenu"
            }
        },
    })
	for i=1, #allMyOutfits, 1 do
		TriggerEvent('nh-context:sendMenu', {
			{
				id = (1 + i),
				header = allMyOutfits[i].name,
				txt = "",
				params = {
					event = 'fivem-appearance:deleteOutfit',
					args = allMyOutfits[i].id
				}
			},
		})
	end
end)

RegisterNetEvent('fivem-appearance:deleteOutfitMenu', function(data)
    local id = data.id
    local number = data.number
	TriggerEvent('fivem-appearance:getOutfits')
	Citizen.Wait(150)
    TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "< Go Back",
            txt = "",
            params = {
                event = "fivem-appearance:clothingShop"
            }
        },
    })
	for i=1, #allMyOutfits, 1 do
		TriggerEvent('nh-context:sendMenu', {
			{
				id = (1 + i),
				header = allMyOutfits[i].name,
				txt = "",
				params = {
					event = 'fivem-appearance:deleteOutfit',
					args = allMyOutfits[i].id
				}
			},
		})
	end
end)

RegisterNetEvent('fivem-appearance:deleteOutfit')
AddEventHandler('fivem-appearance:deleteOutfit', function(id)
	TriggerServerEvent('fivem-appearance:deleteOutfit', id)
end)

RegisterCommand('propfix', function()
    for k, v in pairs(GetGamePool('CObject')) do
        if IsEntityAttachedToEntity(PlayerPedId(), v) then
            SetEntityAsMissionEntity(v, true, true)
            DeleteObject(v)
            DeleteEntity(v)
        end
    end
end)
