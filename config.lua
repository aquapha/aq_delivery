---------------------------------------------------------------------------------
-- WHERE TO LOOK FOR SOMETHING IF YOU WANT TO CHANGE SOMETHING.
--
-- sprite: Choose from here: https://docs.fivem.net/docs/game-references/blips/
-- color, routeColor: Choose from here: https://docs.fivem.net/natives/?_0x03D7FB09E75D6B7E
-- marker:  Choose from here: https://docs.fivem.net/docs/game-references/markers/
-- rgba: You can choose colors from here: https://www.google.com/search?q=color+picker&oq=color+picker&aqs=chrome.0.69i59j0l6j69i60.971j0j7&sourceid=chrome&ie=UTF-8
-- object, pickup: Choose from here: http://www.test.raccoon72.ru/

-- FOR ["deliveryLocations"], visited MUST ALWAYS BE FALSE.
---------------------------------------------------------------------------------

Config = {
  ["markersDistance"] = 16, -- Distance at which to display return marker.
  ["deliveryMarkerDistance"] = 15, -- Distance at which to display pickup marker.
  ["insurancePrice"] = 2000, -- Price to pay for insurance.
  ["waitTimeBeforeOtherPalette"] = 40, -- Time to wait after palette refreshes.
  ["drawRect"] = false, -- Draw's a rectangle on prompts.

-----------------------------------------------------
-----------------------------------------------------
-- ONLY ONE MUST BE SET TO TRUE.  
  ["payFromBaseToDeliveryPoint"] = true,
  ["payFromDeliveryPrice"] = false, -- If this is active, add `from` and `to` into delivery locations.

-- ONLY USE THESE WHEN ["payFromBaseToDeliveryPoint"] is set to true.
  ["payFromBaseToDeliveryPointDivider"] = 1,
  ["payFromBaseToDeliveryPointMultiplier"] = 1,
-----------------------------------------------------
-----------------------------------------------------

-----------------------------------------------------
-----------------------------------------------------
  ["itemsInVehicle"] = 5, -- MUST BE LESS OR EQUAL TO THE AMOUNT OF DELIVERY LOCATIONS.
-----------------------------------------------------
-----------------------------------------------------

  ["itemsInPalette"] = 15, -- How many items fit inside of the vehicle.
  ["numberPlate"] = 'courier', -- Job vehicles number plate.

  ["blip"] = {
    coords = vector3(823.22, -2997.12, 6.02),
    sprite = 67, 
    scale = 0.8,
    color = 8, 
  },
  
  ["carSpawnInfo"] = {
    model = 'burrito', -- You can change this to whatever car you want, but the prompt to put in items might be buggy.
    coords = vector3(826.41, -2983.66, 5.72),
    heading = 0.22,
  },

  ["marker"] = {
    marker = 27,
    coords = vector3(826.41, -2983.75, 5.72),
    scale = 2.5,
    rgba = {r = 255, g = 133, b = 85, a = 255}
  },

  ["pickupLocations"] = {
    [1] = {
      coords = vector3(918.43, -2116.99, 30.50),
      sprite = 478, 
      scale = 1.0,
      color = 3, 
      routeColor = 5, 
      object = 'prop_cratepile_07a',
      pickup = 'prop_cs_cardbox_01',
    },
    [2] = {
      coords = vector3(995.13, -1857.88, 30.89),
      sprite = 478, 
      scale = 1.0,
      color = 3, 
      routeColor = 5,
      object = 'prop_cratepile_07a',
      pickup = 'prop_champ_box_01',
    }
  },

  ["deliveryMarker"] = {
    marker = 20,
    scale = 0.8,
    rgba = {r = 255, g = 133, b = 85, a = 255}
  },

  ["deliveryLocations"] = {
    [1] = {
      coords = vector3(-295.32, -827.84, 32.42),
      sprite = 40,
      scale = 1.0,
      color = 5,
      routeColor = 5,
      visited = false,
      from = 500,
      to = 700,
    },
    [2] = {
      coords = vector3(-521.09, -855.69, 30.25),
      sprite = 40,
      scale = 1.0,
      color = 5,
      routeColor = 5,
      visited = false,
      from = 500,
      to = 700,
    },
    [3] = {
      coords = vector3(-664.28, -1218.30, 11.81),
      sprite = 40,
      scale = 1.0,
      color = 5,
      routeColor = 5,
      visited = false,
      from = 500,
      to = 700,
    },
    [4] = {
      coords = vector3(-298.14, -1333.04, 31.30),
      sprite = 40,
      scale = 1.0,
      color = 5,
      routeColor = 5,
      visited = false,
      from = 500,
      to = 700,
    },
    [5] = {
      coords = vector3(-342.52, -1483.07, 30.72),
      sprite = 40,
      scale = 1.0,
      color = 5,
      routeColor = 5,
      visited = false,
      from = 500,
      to = 700,
    },
    [6] = {
      coords = vector3(-621.03, -1639.94, 26.35),
      sprite = 40,
      scale = 1.0,
      color = 5,
      routeColor = 5,
      visited = false,
      from = 500,
      to = 700,
    },
    [7] = {
      coords = vector3(-127.96, -1394.56, 29.53),
      sprite = 40,
      scale = 1.0,
      color = 5,
      routeColor = 5,
      visited = false,
      from = 500,
      to = 700,
    },
    [8] = {
      coords = vector3(99.05, -1419.39, 29.42),
      sprite = 40,
      scale = 1.0,
      color = 5,
      routeColor = 5,
      visited = false,
      from = 500,
      to = 700,
    },
    [9] = {
      coords = vector3(60.68, -1579.97, 29.60),
      sprite = 40,
      scale = 1.0,
      color = 5,
      routeColor = 5,
      visited = false,
      from = 500,
      to = 700,
    },
    [10] = {
      coords = vector3(-239.07, -1397.76, 31.28),
      sprite = 40,
      scale = 1.0,
      color = 5,
      routeColor = 5,
      visited = false,
      from = 500,
      to = 700,
    },
  }
}
