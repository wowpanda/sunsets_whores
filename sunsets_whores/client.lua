local ModelSpawned		= false
local PlayingAnim 		= false
local CurrentLocation 	= nil
local canTakeHooker		= true
local playerPed 		= GetPlayerPed(-1)
local selectedWhore		= nil
local context 			= GetHashKey("MINI_PROSTITUTE_LOW_PASSENGER")
local previousPos		= nil
ESX      				= nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	while true do
			Citizen.Wait(0)
			coords = GetEntityCoords(playerPed)
			for k,v in pairs(Config.Locations) do
					if GetDistanceBetweenCoords(coords, v.pos.x, v.pos.y, v.pos.z, true) < v.size then
							CurrentLocation = v
							break
					else
							CurrentLocation = nil
					end
			end
	end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
	
	if (not ModelSpawned) then
	  
	  for i=1, #Config.Hookers do
		RequestModel(GetHashKey(Config.Hookers[i].modelHash))
        while not HasModelLoaded(GetHashKey(Config.Hookers[i].modelHash)) do
          Citizen.Wait(0)
        end
		SpawnedPed = CreatePed(2, Config.Hookers[i].modelHash, Config.Hookers[i].x, Config.Hookers[i].y, Config.Hookers[i].z, Config.Hookers[i].heading, true, true)
		ModelSpawned = true
		TaskSetBlockingOfNonTemporaryEvents(SpawnedPed, true)
		Citizen.Wait(1)
		TaskStartScenarioInPlace(SpawnedPed, "WORLD_HUMAN_SMOKING", 0, false)
		
	end
    end
	end
end)

Citizen.CreateThread(function()
	while true do
			Citizen.Wait(0)
			-- Si le joueur est a la bonne position, dans un vehicule qui n'est pas une moto, et qu'il peut prendre une prostitué, alors ...
			if CurrentLocation ~= nil and IsPedInAnyVehicle(PlayerPedId(), false) and IsPedOnAnyBike(PlayerPedId()) == false and canTakeHooker then
					SetTextComponentFormat('STRING')
					AddTextComponentString('Appuie sur ~b~~h~E~h~~w~ pour appeler la prostitué')
					DisplayHelpTextFromStringLabel(0, 0, 1, -1)
					if IsControlJustPressed(0,51) then
						selectedWhore = GetClosestPed()
						previousPos = GetEntityCoords(selectedWhore)
						print(previousPos)
						TaskEnterVehicle(selectedWhore, GetVehiclePedIsIn(playerPed, false), -1, 0, 1.0, 1, 0)
						Citizen.Wait(5000)
						canTakeHooker = false
						show_menu()
					end
			end
	end
end)

function GetClosestPed()
    local closestPed = 0
  
    for ped in EnumeratePeds() do
        local distanceCheck = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(ped), true)
        if distanceCheck <= 3.0 then
            closestPed = ped
            break
        end
    end

    return closestPed
end

function show_menu()
    local elems = {
        {label = '50$: Fellation', 		value = 'blowjob'},
        {label = '100$: Sexe', 			value = 'sex'},
        {label = 'Ne rien demander', 	value = 'quit'},
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'hookerMenu',{
        title    = 'Demander un service',
        align = 'top-left',
        elements = elems
    },
    function(data, menu)
        if data.current.value == 'blowjob' then -- Test la valeur après appuis sur "Entrée" pour diriger au "bon endroit"
			TriggerServerEvent("sunsetswhores:buyService", Config.Tarif.blowjob, "blowjob")
			menu.close()
        elseif data.current.value == 'sex' then
			TriggerServerEvent("sunsetswhores:buyService", Config.Tarif.sex, "sex")
			menu.close()
        elseif data.current.value == 'quit' then
            TriggerEvent("sunsetswhores:quit") 
			canTakeHooker = true
			menu.close()
        end
    end,
    function(data, menu)
        TriggerEvent("sunsetswhores:quit") 
		canTakeHooker = true
		menu.close()
    end)
end

RegisterNetEvent("sunsetswhores:isPaid")
AddEventHandler("sunsetswhores:isPaid", function(action)
	if action == "error" then
		ESX.ShowNotification("Vous n'avez pas assez d'argent !")
	else
		TriggerEvent("sunsetswhores:" .. action)
	end
end)

RegisterNetEvent("sunsetswhores:blowjob")
AddEventHandler("sunsetswhores:blowjob", function(inputText)
	RequestAnimDict("oddjobs@towing")
	while (not HasAnimDictLoaded("oddjobs@towing")) do 
	Citizen.Wait(0)
	end
	TaskPlayAnim(selectedWhore,"oddjobs@towing","f_blow_job_loop", 1.0, -1.0, 30000, 0, 1, true, true, true)
	TaskPlayAnim(playerPed,"oddjobs@towing","m_blow_job_loop", 1.0, -1.0, 30000, 0, 1, true, true, true) 
	Citizen.Wait(13000)
	show_menu()
end)

RegisterNetEvent("sunsetswhores:sex")
AddEventHandler("sunsetswhores:sex", function(inputText)
	RequestAnimDict("mini@prostitutes@sexlow_veh")
	while (not HasAnimDictLoaded("mini@prostitutes@sexlow_veh")) do 
	Citizen.Wait(0)
	end
	TaskPlayAnim(selectedWhore,"mini@prostitutes@sexlow_veh","low_car_sex_loop_female", 1.0, -1.0, 50000, 0, 1, true, true, true)
	TaskPlayAnim(playerPed,"mini@prostitutes@sexlow_veh","low_car_sex_loop_player", 1.0, -1.0, 50000, 0, 1, true, true, true)
	Citizen.Wait(16000)
	show_menu()
end)

RegisterNetEvent("sunsetswhores:quit")
AddEventHandler("sunsetswhores:quit", function(inputText)
	TaskLeaveVehicle(selectedWhore, vehicle, 0)
	TaskGoToCoordAnyMeans(selectedWhore, previousPos.x, previousPos.y, previousPos.z, 3.0, 0, 0, 786603, 0xbf800000)
	
end)

Citizen.CreateThread(function()
	while true do
	  Citizen.Wait(1000)
			if selectedWhore ~= nil and IsEntityDead(selectedWhore) then
			  SpawnedPed = CreatePed(2, "s_f_y_hooker_01", previousPos.x, previousPos.y, previousPos.z, 43, true, true)
			  TaskSetBlockingOfNonTemporaryEvents(SpawnedPed, true)
			  Citizen.Wait(1)
			  TaskStartScenarioInPlace(SpawnedPed, "WORLD_HUMAN_SMOKING", 0, false)
			end
	end
end)

local entityEnumerator = {
  __gc = function(enum)
    if enum.destructor and enum.handle then
      enum.destructor(enum.handle)
    end
    enum.destructor = nil
    enum.handle = nil
  end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
  return coroutine.wrap(function()
    local iter, id = initFunc()
    if not id or id == 0 then
      disposeFunc(iter)
      return
    end
    
    local enum = {handle = iter, destructor = disposeFunc}
    setmetatable(enum, entityEnumerator)
    
    local next = true
    repeat
      coroutine.yield(id)
      next, id = moveFunc(iter)
    until not next
    
    enum.destructor, enum.handle = nil, nil
    disposeFunc(iter)
  end)
end

function EnumerateObjects()
  return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
  return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
  return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
  return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end
