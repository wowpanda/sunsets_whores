ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("sunsetswhores:buyService")
AddEventHandler("sunsetswhores:buyService", function(amount, action)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.get('money') >= amount then
		xPlayer.removeMoney(amount)
		TriggerClientEvent("sunsetswhores:isPaid", _source, action)
	else
		TriggerClientEvent("sunsetswhores:isPaid", _source, "error")
	end
end)