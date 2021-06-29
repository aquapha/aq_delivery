ESX = nil

spawnedPickups = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('aq_delivery:updateJob', function(source, cb)
  local xPlayer = ESX.GetPlayerFromId(source)

  cb(xPlayer.job.name)
end)

ESX.RegisterServerCallback('aq_delivery:getPickups', function(source, cb)
  cb(spawnedPickups)
end)

RegisterServerEvent('aq_delivery:updateTime')
AddEventHandler('aq_delivery:updateTime', function(id, timeleft)
  spawnedPickups[id].timeleft = timeleft
end)

RegisterServerEvent('aq_delivery:refillBox')
AddEventHandler('aq_delivery:refillBox', function(id)
  spawnedPickups[id].alerted = false
  spawnedPickups[id].timeleft = 0
  spawnedPickups[id].serverSwitch = false
  spawnedPickups[id].items = Config["itemsInPalette"]

  TriggerClientEvent('aq_delivery:refreshObjValues', -1, spawnedPickups)
end)

RegisterServerEvent('aq_delivery:addItem')
AddEventHandler('aq_delivery:addItem', function(id, amount)
  for i = 1, #spawnedPickups do
    if spawnedPickups[i].id == id then
      spawnedPickups[i].items = spawnedPickups[i].items + amount
    end
  end
end)

RegisterServerEvent('aq_delivery:subtractItem')
AddEventHandler('aq_delivery:subtractItem', function(id, amount)
  for i = 1, #spawnedPickups do
    if spawnedPickups[i].id == id then
      spawnedPickups[i].items = spawnedPickups[i].items - amount
      
      if not spawnedPickups[i].serverSwitch then
        if spawnedPickups[i].items <= 0 then
  
          spawnedPickups[i].serverSwitch = true    
          spawnedPickups[i].alerted = true
          spawnedPickups[i].timeleft = Config["waitTimeBeforeOtherPalette"]
        end
      end
    end
  end
end)

RegisterServerEvent('aq_delivery:payInsurance')
AddEventHandler('aq_delivery:payInsurance', function(amount)
  local xPlayer = ESX.GetPlayerFromId(source)
  local amounts = xPlayer.getAccounts()
  local cash = xPlayer.getMoney()
  local bank = xPlayer.getAccount('bank')

  if cash < Config["insurancePrice"] then
    xPlayer.removeAccountMoney('bank', Config["insurancePrice"])
  else
    xPlayer.removeMoney(Config["insurancePrice"])
  end

  xPlayer.showNotification('You paid: ~p~' .. Config["insurancePrice"] .. '$ ~s~for insurance.')
end)

RegisterServerEvent('aq_delivery:refreshValues')
AddEventHandler('aq_delivery:refreshValues', function()
  TriggerClientEvent('aq_delivery:refreshObjValues', -1, spawnedPickups)
end)

RegisterServerEvent('aq_delivery:pay')
AddEventHandler('aq_delivery:pay', function(deliveries)
  local xPlayer = ESX.GetPlayerFromId(source)
  local toPay = 0

  for k, v in pairs(deliveries) do
    toPay = toPay + v.pay
  end

  xPlayer.addMoney(toPay)
  xPlayer.showNotification('You\'ve been paid a total of: ~b~' .. math.floor(toPay) .. '$ ~s~for all the deliveries combined.')
end)

Citizen.CreateThread(function()
  Citizen.Wait(500)

  for i = 1, #Config["pickupLocations"] do
    pickup = Config["pickupLocations"][i]

    objData = {
      id = i,
      coords = pickup["coords"],
      object = pickup["object"],
      items = Config["itemsInPalette"],
      timeleft = 0,
      alerted = false,
      serverSwitch = false,
    }

    table.insert(spawnedPickups, objData)
  end

  Citizen.Wait(500)

  TriggerClientEvent('aq_delivery:setupObjects', -1, spawnedPickups)
end)

AddEventHandler('onResourceStop', function(resourceName)
  if GetCurrentResourceName() == resourceName then
    spawnedPickups = {}
  end
end)
