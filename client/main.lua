ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj)
      ESX = obj
    end)

    Citizen.Wait(0)
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(3000)

    if #spawnedPickup == 0 then
      ESX.TriggerServerCallback('aq_delivery:getPickups', function(pickups)
        spawnedPickup = pickups
      end)
    else
      if DoesEntityExist(spawnedPickup[#spawnedPickup]["obj"]) then
        break
      else
        spawnedPickup = {}

        ESX.TriggerServerCallback('aq_delivery:getPickups', function(objects)
          TriggerEvent('aq_delivery:setupObjects', objects)
        end)
      end
    end
  end
end)

playerJob = nil
pickupBlip = nil
deliveryBlip = nil
deliveryCar = nil
arriveLocation = nil
pickup = nil
showTip = true
pay = false
isCarryingArrive = false
arrived = false
payInsurance = false
jobVehicleSpawned = false
isDelivering = false
isCarrying = false
signature = false
jobVehicle = {}
spawnedPickup = {}
visited = {}

RegisterNetEvent('aq_delivery:refreshObjValues')
AddEventHandler('aq_delivery:refreshObjValues', function()
  ESX.TriggerServerCallback('aq_delivery:getPickups', function(pickups)
    spawnedPickup = pickups
  end)
end)

RegisterNetEvent('aq_delivery:getCurrentJob')
AddEventHandler('aq_delivery:getCurrentJob', function()
  ESX.TriggerServerCallback('aq_delivery:updateJob', function(job)
    playerJob = job
  end)
end)

RegisterNetEvent('aq_delivery:returnVehicle')
AddEventHandler('aq_delivery:returnVehicle', function()
  local ply = PlayerPedId()

  if jobVehicle.vehicle ~= nil then
    if DoesEntityExist(jobVehicle.vehicle) then
      if IsPedInVehicle(ply, jobVehicle.vehicle, false) then
        if pay then
          TriggerServerEvent('aq_delivery:pay', visited)

          pay = false
        end

        SetEntityAsMissionEntity(jobVehicle.veh, false, false)
        TaskLeaveVehicle(ply, jobVehicle.vehicle, 0)
        Citizen.Wait(2000)
        DeleteVehicle(jobVehicle.vehicle)
        RemoveBlip(pickupBlip)
        RefreshVariables()
      else
        ESX.ShowNotification(Lang["mustBeSitting"])
      end
    else
      RemoveBlip(pickupBlip)
      ESX.ShowNotification(Lang["vehicleNotExist"])
      RefreshVariables()
      payInsurance = true
    end
  else
    ESX.ShowNotification(Lang["noVehicle"])
  end
end)

RegisterNetEvent('aq_delivery:deliveryStart')
AddEventHandler('aq_delivery:deliveryStart', function()
  if #visited == Config["itemsInVehicle"] then
    local returnRoute = vector3(Config["marker"].coords.x, Config["marker"].coords.y, Config["marker"].coords.z)

    SetDeliveryRoute(returnRoute, 38, 1.0, 11, 11)
    pay = true
  else
    local delivery = math.random(1, #Config["deliveryLocations"])
    local cDelivery = Config["deliveryLocations"][delivery]

    if cDelivery.visited == false then
      cDelivery.visited = true

      local deliveryInfo
      
      if Config["payFromBaseToDeliveryPoint"] then
        local dist = #(cDelivery.coords - Config["blip"].coords)
        
        if Config["payFromBaseToDeliveryPointDivider"] ~= 1 then
          deliveryInfo = {
            id = delivery,
            visited = cDelivery.visited,
            pay = dist / Config["payFromBaseToDeliveryPointDivider"]
          }
        elseif Config["payFromBaseToDeliveryPointMultiplier"] ~= 1 then
          deliveryInfo = {
            id = delivery,
            visited = cDelivery.visited,
            pay = dist * Config["payFromBaseToDeliveryPointMultiplier"]
          }
        else
          deliveryInfo = {
            id = delivery,
            visited = cDelivery.visited,
            pay = dist
          }
        end
      elseif Config["payFromDeliveryPrice"] then
        local pay = math.random(cDelivery["from"], cDelivery["to"])
  
        deliveryInfo = {
          id = delivery,
          visited = cDelivery.visited,
          pay = pay
        }
      else
        deliveryInfo = {
          id = delivery,
          visited = cDelivery.visited,
          pay = 0
        }
      end

      table.insert(visited, deliveryInfo)

      SetDeliveryRoute(cDelivery.coords, cDelivery.sprite, cDelivery.scale, cDelivery.color, cDelivery.routeColor)
      arriveLocation = vector3(cDelivery.coords.x, cDelivery.coords.y, cDelivery.coords.z)
    else
      TriggerEvent('aq_delivery:deliveryStart')
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    if arriveLocation ~= nil then
      local ply = PlayerPedId()
      local marker = Config["deliveryMarker"]
      local coords = GetEntityCoords(ply)
      local dist = #(arriveLocation - coords)

      if dist < 15 then
        arrived = true
      else
        arrived = false
      end

      if arrived then
        local dist = #(arriveLocation - coords)

        if dist < Config["deliveryMarkerDistance"] and not isCarryingArrive then
          DrawMarker(
            marker["marker"],
            arriveLocation.x,
            arriveLocation.y,
            arriveLocation.z + 0.5,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            marker["scale"],
            marker["scale"],
            marker["scale"],
            marker["rgba"].r,
            marker["rgba"].g,
            marker["rgba"].b,
            marker["rgba"].a,
            true, true, 2, false, false, false, false
          )
        end

        if isCarryingArrive then
          if dist < Config["deliveryMarkerDistance"] / Config["deliveryMarkerDistance"] then
            Draw3DText(arriveLocation.x, arriveLocation.y, arriveLocation.z, Lang["deliverPackage"])
  
            if IsControlJustPressed(0, 51) then
              ClearPedTasksImmediately(ply)
            
              ESX.Game.DeleteObject(prop)
            
              Citizen.Wait(2000)
              isCarryingArrive = false

              TriggerEvent('aq_delivery:deliveryStart')
            end
          end
        else
          local boneIndex = GetEntityBoneIndexByName(jobVehicle.vehicle, 'platelight')
          local vCoords = GetWorldPositionOfEntityBone(jobVehicle.vehicle, boneIndex)
          local newVCoords = vector3(vCoords.x, vCoords.y, vCoords.z + 0.25)
          local dist = #(vector3(vCoords.x, vCoords.y, vCoords.z + 0.25) - coords)

          if dist < 1 then
            Draw3DText(newVCoords.x, newVCoords.y, newVCoords.z, 'Press [~o~E~s~] to take out a package. Packages: ~b~' .. jobVehicle.items .. '~s~/~b~' .. Config["itemsInVehicle"])

            if IsControlJustPressed(0, 51) then
              TakeOutOfDeliveryCar(Config["pickupLocations"][pickup]["pickup"])
            end
          end
        end
      end
    else
      Citizen.Wait(3000)
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    
    local ply = PlayerPedId()
    local coords = GetEntityCoords(ply)

    if #spawnedPickup ~= 0 then
      local blip = Config["blip"]
      local dist = #(coords - blip.coords)
      
      if dist < 1 then
        if payInsurance then
          Draw3DText(blip.coords.x, blip.coords.y, blip.coords.z, Lang["insurancePrompt"])

          if IsControlJustReleased(0, 51) then
            TriggerServerEvent('aq_delivery:payInsurance', ply, Config["insurancePrice"])
            payInsurance = false
          end
        else
          if jobVehicleSpawned then
            Draw3DText(blip.coords.x, blip.coords.y, blip.coords.z, Lang["returnVehicle"])
          else
            Draw3DText(blip.coords.x, blip.coords.y, blip.coords.z, Lang["spawnVehicle"])

            if IsControlJustReleased(0, 51) and not IsEntityDead(ply) then
              TriggerEvent('aq_delivery:getCurrentJob')

              Citizen.Wait(100)

              if playerJob == 'delivery' then
                SpawnVehicle()
              else
                ESX.ShowNotification(Lang["notDeliveryJob"])
              end
            end
          end
        end
      end
    else
      local blip = Config["blip"]
      local dist = #(coords - blip.coords)

      if dist < 1 then
        Draw3DText(blip.coords.x, blip.coords.y, blip.coords.z, Lang["loading"])
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    if #spawnedPickup ~= 0 then
      for i = 1, #spawnedPickup do
        if spawnedPickup[i].alerted and spawnedPickup[i].timeleft == 0 then
          TriggerServerEvent('aq_delivery:refillBox', spawnedPickup[i].id)
        end

        if spawnedPickup[i].timeleft >= 0 then
          Citizen.Wait(1000)

          spawnedPickup[i].timeleft = spawnedPickup[i].timeleft - 1
          
          TriggerServerEvent('aq_delivery:updateTime', i, spawnedPickup[i].timeleft)
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    local ply = PlayerPedId()

    if isDelivering then
      local coords = GetEntityCoords(ply)

      if spawnedPickup[pickup].alerted and spawnedPickup[pickup].timeleft >= 0 then
        local dist = #(spawnedPickup[pickup].coords - coords)

        if dist < 2 then
          Draw3DText(spawnedPickup[pickup].coords.x, spawnedPickup[pickup].coords.y, spawnedPickup[pickup].coords.z, 'Palette is ~b~empty~s~. Wait another: ~b~' .. spawnedPickup[pickup].timeleft .. ' ~s~seconds.')
        end
      end

      if jobVehicle.items >= Config["itemsInVehicle"] then
        SetVehicleDoorShut(deliveryCar, 2, true)
        SetVehicleDoorShut(deliveryCar, 3, true)

        if not isCarrying then
          if not signature then
            Draw3DText(spawnedPickup[pickup].coords.x, spawnedPickup[pickup].coords.y, spawnedPickup[pickup].coords.z - 0.15, Lang["signToContinue"])
  
            if IsControlJustPressed(0, 74) then
              TriggerEvent('aq_delivery:deliveryStart')
              RemoveBlip(pickupBlip)
              signature = true
            end
          end
        end
      end

      if isCarrying then
        local boneIndex = GetEntityBoneIndexByName(jobVehicle.vehicle, 'platelight')
        local vCoords = GetWorldPositionOfEntityBone(jobVehicle.vehicle, boneIndex)
        local newVCoords = vector3(vCoords.x, vCoords.y, vCoords.z + 0.25)
        local dist = #(vector3(vCoords.x, vCoords.y, vCoords.z + 0.25) - coords)
        local pickupDist = #(vector3(spawnedPickup[pickup].coords.x, spawnedPickup[pickup].coords.y, spawnedPickup[pickup].coords.z) - coords)

        if pickupDist < 2 then
          if jobVehicle.items >= Config["itemsInVehicle"] then
            Draw3DText(spawnedPickup[pickup].coords.x, spawnedPickup[pickup].coords.y, spawnedPickup[pickup].coords.z - 0.15, Lang["returnPackage"])

            if IsControlJustPressed(0, 74) then 
              ClearPedTasksImmediately(ply)
            
              ESX.Game.DeleteObject(prop)
              ESX.Streaming.RequestAnimDict('anim@gangops@facility@servers@bodysearch@', function()
                TaskPlayAnim(ply, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 1.0, -1.0, 2000, 0, 1, true, true, true)
              end)
            
              TriggerServerEvent('aq_delivery:addItem', pickup, 1)
              TriggerServerEvent('aq_delivery:refreshValues')
            
              Citizen.Wait(2000)
              isCarrying = false
            end
          end
        end

        if dist < 2 then
          if jobVehicle.items >= Config["itemsInVehicle"] then
            Draw3DText(newVCoords.x, newVCoords.y, newVCoords.z, 'Vehicles trunk is ~o~full~s~. Pakuotes: ~b~' .. jobVehicle.items .. '~s~/~b~' .. Config["itemsInVehicle"])
          else
            Draw3DText(newVCoords.x, newVCoords.y, newVCoords.z, 'Press [~o~E~s~] to put in the package. Packages: ~b~' .. jobVehicle.items .. '~s~/~b~' .. Config["itemsInVehicle"])
  
            if IsControlJustReleased(0, 51) then
              PutInDeliveryCar(ply)
            end
          end
        end
      else
        local dist = #(spawnedPickup[pickup].coords - coords)

        if dist < 2 then
          if spawnedPickup[pickup].items > 0 then
            Draw3DText(spawnedPickup[pickup].coords.x, spawnedPickup[pickup].coords.y, spawnedPickup[pickup].coords.z, 'Press [~o~E~s~] to pick up a package. Packages: ~b~' .. spawnedPickup[pickup].items .. '~s~/~b~' .. Config["itemsInPalette"])

            if IsControlJustPressed(0, 51) then
              PickupBoxFromObject(pickup, Config["pickupLocations"][pickup]["pickup"])
            end
          end
        end
      end
    else
      local ply = PlayerPedId()

      if IsPedInVehicle(ply, jobVehicle.vehicle, false) then
        if IsControlJustPressed(0, 74) then
          pickup = math.random(1, #spawnedPickup)
          local pickupPoint = spawnedPickup[pickup]
          local cPickup = Config["pickupLocations"][pickup]
          deliveryCar = GetVehiclePedIsUsing(ply)

          SetPickupRoute(pickupPoint.coords, cPickup.sprite, cPickup.scale, cPickup.color, cPickup.routeColor)

          isDelivering = true
          showTip = false
        end
    
        if showTip then
          ESX.ShowHelpNotification(Lang["startDelivering"], false, false, 2000)
        end
      end
    end
  end
end)

--[[

  FUNCTIONS

]]--

SpawnVehicle = function()
  local vehicle = Config["carSpawnInfo"]

  ESX.Game.SpawnVehicle(vehicle.model, vehicle.coords, vehicle.heading, function(veh)
    SetEntityCoordsNoOffset(veh, vehicle.coords.x, vehicle.coords.y, vehicle.coords.z)
    SetEntityHeading(veh, vehicle.heading)
    FreezeEntityPosition(veh, true)
    SetVehicleOnGroundProperly(veh)
    FreezeEntityPosition(veh, false)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleDoorsLockedForAllPlayers(veh, false)
    SetVehicleNumberPlateText(veh, Config["numberPlate"])
    ESX.ShowNotification(Lang["carGiven"])

    jobVehicle = {
      owner = GetPlayerName(PlayerId()),
      vehicle = veh,
      items = 0
    }

    jobVehicleSpawned = true
  end)
end

SetPickupRoute = function(coords, sprite, scale, color, routeColor)
  if DoesBlipExist(pickupBlip) then
    RemoveBlip(pickupBlip)
  end

  pickupBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
  SetBlipDisplay(pickupBlip, 6)
  SetBlipSprite(pickupBlip, sprite)
  SetBlipScale(pickupBlip, scale)
  SetBlipColour(pickupBlip, color)
  SetBlipRoute(pickupBlip, true)
  SetBlipRouteColour(pickupBlip, routeColor)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(Lang["pickup_blip"])
  EndTextCommandSetBlipName(pickupBlip)
end

SetDeliveryRoute = function(coords, sprite, scale, color, routeColor)
  if DoesBlipExist(deliveryBlip) then
    RemoveBlip(deliveryBlip)
  end

  deliveryBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
  SetBlipDisplay(deliveryBlip, 6)
  SetBlipSprite(deliveryBlip, sprite)
  SetBlipScale(deliveryBlip, scale)
  SetBlipColour(deliveryBlip, color)
  SetBlipRoute(deliveryBlip, true)
  SetBlipRouteColour(deliveryBlip, routeColor)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(Lang["delivery_blip"])
  EndTextCommandSetBlipName(deliveryBlip)
end

PickupBoxFromObject = function(pickupId, obj)
  local ply = PlayerPedId()

  TriggerServerEvent('aq_delivery:subtractItem', pickupId, 1)
  TriggerServerEvent('aq_delivery:refreshValues')

  prop = CreateObject(GetHashKey(obj))
  AttachEntityToEntity(prop, ply, GetPedBoneIndex(ply, 28422), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)

  ESX.Streaming.RequestAnimDict('anim@heists@box_carry@', function()
    TaskPlayAnim(ply, "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
  end)

  isCarrying = true
  Citizen.Wait(1000)
end

PutInDeliveryCar = function()
  local ply = PlayerPedId()
  
  SetVehicleDoorOpen(deliveryCar, 2, false, true)
  SetVehicleDoorOpen(deliveryCar, 3, false, true)
  
  ClearPedTasksImmediately(ply)

  ESX.Game.DeleteObject(prop)
  ESX.Streaming.RequestAnimDict('anim@gangops@facility@servers@bodysearch@', function()
    TaskPlayAnim(ply, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 1.0, -1.0, 2000, 0, 1, true, true, true)
  end)

  jobVehicle.items = jobVehicle.items + 1
  isCarrying = false

  Citizen.Wait(2000)
end

TakeOutOfDeliveryCar = function(obj)
  local ply = PlayerPedId()

  SetVehicleDoorOpen(deliveryCar, 2, false, true)
  SetVehicleDoorOpen(deliveryCar, 3, false, true)

  jobVehicle.items = jobVehicle.items - 1

  prop = CreateObject(GetHashKey(obj))
  AttachEntityToEntity(prop, ply, GetPedBoneIndex(ply, 28422), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)

  ESX.Streaming.RequestAnimDict('anim@heists@box_carry@', function()
    TaskPlayAnim(ply, "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
  end)

  Citizen.Wait(200)
  isCarryingArrive = true

  Citizen.Wait(500)
  SetVehicleDoorShut(deliveryCar, 2, true)
  SetVehicleDoorShut(deliveryCar, 3, true)
end

Draw3DText = function(x, y, z, text)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  local px, py, pz = table.unpack(GetGameplayCamCoord())
  local dist = #(vector3(px, py, pz) - vector3(x, y, z))

  local scale = ((1 / dist) * 2) * (1 / GetGameplayCamFov()) * 100

  if onScreen then
      SetTextColour(255, 255, 255, 255)
      SetTextScale(0.0 * scale, 0.35 * scale)
      SetTextFont(4)
      SetTextProportional(1)
      SetTextCentre(true)

      SetTextDropshadow(1, 1, 1, 1, 255)

      BeginTextCommandWidth("STRING")
      AddTextComponentString(text)

      local height = GetTextScaleHeight(0.45 * scale, 4)
      local width = EndTextCommandGetWidth(5) + 0.01

      SetTextEntry("STRING")
      AddTextComponentString(text)
      EndTextCommandDisplayText(_x, _y)
      if Config["drawRect"] then
        DrawRect(_x, (_y + scale / 78), width, height, 10, 10, 10, 100)
      end
  end
end

RefreshVariables = function()
  RemoveBlip(deliveryBlip)

  playerJob = nil
  pickupBlip = nil
  deliveryBlip = nil
  deliveryCar = nil
  arriveLocation = nil
  pickup = nil
  showTip = true
  pay = false
  isCarryingArrive = false
  arrived = false
  payInsurance = false
  jobVehicleSpawned = false
  isDelivering = false
  isCarrying = false
  signature = false
  jobVehicle = {}
  visited = {}

  for i = 1, #Config["deliveryLocations"] do
    Config["deliveryLocations"][i].visited = false
  end
end

AddEventHandler('onResourceStop', function(resourceName)
  if GetCurrentResourceName() == resourceName then
    for i = 1, #spawnedPickup do
      ESX.Game.DeleteObject(spawnedPickup[i].obj)
    end

    spawnedPickup = {}
    jobVehicle = {}
  end
end)
