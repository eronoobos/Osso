MetalSpotHandler = class(Module)


function MetalSpotHandler:Name()
	return "MetalSpotHandler"
end

function MetalSpotHandler:internalName()
	return "metalspothandler"
end

function MetalSpotHandler:Init()
	self.spots = osso_include("metal")
end

local function distance(pos1,pos2)
	local xd = pos1.x-pos2.x
	local yd = pos1.z-pos2.z
	dist = math.sqrt(xd*xd + yd*yd)
	return dist
end

local function canBuildHere(unitDefID, position) -- returns boolean
	local newX, newY, newZ = Spring.Pos2BuildPos(unitDefID, position.x, position.y, position.z)
	local blocked = Spring.TestBuildOrder(unitDefID, newX, newY, newZ, 1) == 0
	-- Spring.Echo(unittype:Name(), newX, newY, newZ, blocked)
	return ( not blocked ), {x=newX, y=newY, z=newZ}
end

function MetalSpotHandler:ClosestFreeSpot(unitDefID, position)
	local pos = nil
	local bestDistance = 10000

	for i,v in ipairs(self.spots) do
		local p = v
		local dist = distance(position,p)
		if dist < bestDistance then
			local can, bp = canBuildHere(unitDefID, p)
			if can then
				bestDistance = dist
				pos = bp
			end
		end
	end
	return pos
end
