-- BLIPS --

Citizen.CreateThread(function()
  Citizen.Wait(0)

  local cblip = Config["blip"]
  local blip = AddBlipForCoord(cblip.coords)

  SetBlipHighDetail(blip, true)
  SetBlipSprite (blip, cblip.sprite)
  SetBlipScale  (blip, cblip.scale)
  SetBlipColour (blip, cblip.color)
  SetBlipAsShortRange(blip, true)

  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(Lang["job_blip"])
  EndTextCommandSetBlipName(blip)
end)

RegisterNetEvent('aq_delivery:setupObjects')
AddEventHandler('aq_delivery:setupObjects', function(objects)
  for i = 1, #objects do
    SetPickupObject(objects[i]["id"], objects[i]["coords"], objects[i]["object"], objects[i]["items"], objects[i]["timeleft"], objects[i]["alerted"], objects[i]["serverSwitch"])

    Citizen.Wait(500)
  end
end)

SetPickupObject = function(id, coords, obj, items, timeleft, alerted, serverSwitch)
  local propCoords = vector3(coords.x, coords.y, coords.z - 1)

  ESX.Game.SpawnLocalObject(obj, propCoords, function(obj)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)

    pickup = {
      id = id,
      coords = coords,
      obj = obj,
      items = items,
      timeleft = timeleft,
      alerted = alerted,
      serverSwitch = serverSwitch
    }

    table.insert(spawnedPickup, pickup)

    Citizen.Wait(500)
  end)
end

-- MARKER --

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    if playerJob == 'delivery' then
      local ply = PlayerPedId()
      local coords = GetEntityCoords(ply)
  
      local dist = #(coords - Config["marker"].coords)
  
      if dist < Config["markersDistance"] then
        DrawMarker(
          Config["marker"]["marker"],
          Config["marker"]["coords"].x,
          Config["marker"]["coords"].y,
          Config["marker"]["coords"].z - 0.8,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          Config["marker"]["scale"],
          Config["marker"]["scale"],
          Config["marker"]["scale"],
          Config["marker"]["rgba"].r,
          Config["marker"]["rgba"].g,
          Config["marker"]["rgba"].b,
          Config["marker"]["rgba"].a,
          false, true, 2, true, false, false, false
        )
  
        if dist < Config["markersDistance"] / 6 then
          Draw3DText(Config["marker"]["coords"].x, Config["marker"]["coords"].y, Config["marker"]["coords"].z, Lang["returnVehiclePrompt"])
  
          if IsControlJustReleased(0, 51) and not IsEntityDead(ply) then
            TriggerEvent('aq_delivery:returnVehicle')
          end
        end
      end
    end
  end
end)
