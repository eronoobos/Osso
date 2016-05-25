TaskQueueBehaviour = class(Behaviour)

local function canBuildHere(unitDefID, position) -- returns boolean
	local newX, newY, newZ = Spring.Pos2BuildPos(unitDefID, position.x, position.y, position.z)
	local blocked = Spring.TestBuildOrder(unitDefID, newX, newY, newZ, 1) == 0
	-- Spring.Echo(unittype:Name(), newX, newY, newZ, blocked)
	return ( not blocked ), {x=newX, y=newY, z=newZ}
end

function TaskQueueBehaviour:Init()
	self.active = false
	self.countdown = 0
	if self:HasQueues() then
		self.queue = self:GetQueue()
	end
	self.waiting = {}
	
end

function TaskQueueBehaviour:HasQueues()
	return (taskqueues[self.name] ~= nil)
end

function TaskQueueBehaviour:OwnerFinished()
	if not self:IsActive() then
		return
	end
	self.progress = true
end

function TaskQueueBehaviour:OwnerIdle()
	if not self:IsActive() then
		return
	end
	self.progress = true
	self.countdown = 0
	--self.unit:ElectBehaviour()
end

function TaskQueueBehaviour:OwnerMoveFailed()
	if not self:IsActive() then
		return
	end
	self:OwnerIdle()
end

function TaskQueueBehaviour:OwnerDestroyed()
	if self.waiting ~= nil then
		for k,v in pairs(self.waiting) do
			ai.modules.sleep.Kill(self.waiting[k])
		end
	end
	self.waiting = nil
	self.unit = nil
end

function TaskQueueBehaviour:GetQueue()
	local q = taskqueues[self.name]
	if type(q) == "function" then
		--spEcho("function table found!")
		q = q(self)
	end
	return q
end

function TaskQueueBehaviour:Update(frame)
	if not self:IsActive() then
		return
	end
	local f = frame
	local s = self.countdown
	if self.progress == true then
	--if math.mod(f,3) == 0 then
		if (self.ai.tqblastframe ~= f) or (self.ai.tqblastframe == nil) or (self.countdown == 15) then
			self.countdown = 0
			self.ai.tqblastframe = f
			self:ProgressQueue()
		else
			if self.countdown == nil then
				self.countdown = 1
			else
				self.countdown = self.countdown + 1
			end
		end
	end
end

TaskQueueWakeup = class(function(a,tqb)
	a.tqb = tqb
end)
function TaskQueueWakeup:wakeup()
	spEcho("advancing queue from sleep1")
	self.tqb:ProgressQueue()
end

function TaskQueueBehaviour:ProgressQueue()
	self.progress = false
	if self.queue ~= nil then
		local idx, val = next(self.queue,self.idx)
		self.idx = idx
		if idx == nil then
			self.queue = self:GetQueue(name)
			self.progress = true
			return
		end
		
		local uDefID
		local value = val
		if type(val) == "table" then
			local action = value.action
			if action == "wait" then
				t = TaskQueueWakeup(self)
				tqb = self
				ai.sleep:Wait({ wakeup = function() tqb:ProgressQueue() end, },value.frames)
				return
			elseif action == "move" then
				local p = value.position
				spGiveOrderToUnit( self.unitID, CMD.MOVE, { p.x, p.y, p.z }, {} )
				self.progress = false
			elseif action == "moverelative" then
				local upos = spGetUnitPosition(self.unitID)
				local newpos = {}
				newpos.x = upos.x + value.position.x
				newpos.y = upos.y + value.position.y
				newpos.z = upos.z + value.position.z
				local p = newpos
				spGiveOrderToUnit( self.unitID, CMD.MOVE, { p.x, p.y, p.z }, {} )
				self.progress = false
			end
		else
			if type(val) == "function" then
				value = val(self)
			end
			if uDefID ~= "next" then
				uDefID = UnitDefNames[value].id
				if uDefID ~= nil then
					if self:CanBuild(uDefID) then
						if UnitDefs[uDefID].extractsMetal > 0 then
							-- find a free spot!
							local p = spGetUnitPosition(self.unitID)
							p = self.ai.metalspothandler:ClosestFreeSpot(uDefID,p)
							if p ~= nil then
								spGiveOrderToUnit( self.unitID, -uDefID, { p.x, p.y, p.z }, {} )
								success = true 
								self.progress = not success
							else
								self.progress = true
							end
						else
							local p = self:FindClosestBuildSite(uDefID, spGetUnitPosition(self.unitID))
							spGiveOrderToUnit( self.unitID, -uDefID, { p.x, p.y, p.z }, {} )
							success = true
							self.progress = not success
						end
					else
						self.progress = true
					end
				else
					spEcho("Cannot build:"..value..", couldnt grab the unit type from the engine")
					self.progress = true
				end
			else
				self.progress = true
			end
		end
	end
end

function TaskQueueBehaviour:Activate()
	self.progress = true
	self.active = true
end

function TaskQueueBehaviour:Deactivate()
	self.active = false
end

function TaskQueueBehaviour:Priority()
	return 50
end

function TaskQueueBehaviour:CanBuild(unitDefID)
	if not self.canBuildDefID then
		self.canBuildDefID = {}
		-- Spring.Echo(self.def.name, "build options", self.def.buildOptions)
		for _, defID in pairs(self.unit.def.buildOptions) do
			self.canBuildDefID[defID] = true
		end
	end
	return self.canBuildDefID[unitDefID]
end

function TaskQueueBehaviour:FindClosestBuildSite(unitDefID, builderpos, searchradius, minimumdistance, validFunction) -- returns Position
	-- validFunction takes a position and returns a position or nil if the position is not valid
	validFunction = validFunction or function (position) return position end
	searchradius = searchradius or 500
	minimumdistance = minimumdistance or 50
	local twicePi = math.pi * 2
	local angleIncMult = twicePi / minimumdistance
	local bx, bz = builderpos.x, builderpos.z
	local maxX, maxZ = Game.mapSizeX, Game.mapSizeZ
	for radius = 50, searchradius, minimumdistance do
		local angleInc = radius * twicePi * angleIncMult
		local initAngle = math.random() * twicePi
		for angle = initAngle, initAngle+twicePi, angleInc do
			local realAngle = angle+0
			if realAngle > twicePi then realAngle = realAngle - twicePi end
			local dx, dz = radius*math.cos(angle), radius*math.sin(angle)
			local x, z = bx+dx, bz+dz
			if x < 0 then x = 0 elseif x > maxX then x = maxX end
			if z < 0 then z = 0 elseif z > maxZ then z = maxZ end
			local y = spGetGroundHeight(x,z)
			local buildable, position = canBuildHere(unittype, {x=x, y=y, z=z})
			if buildable then
				position = validFunction(position)
				if position then return position end
			end
		end 
	end
	local lastDitch, lastDitchPos = canBuildHere(unittype, builderpos)
	if lastDitch then
		lastDitchPos = validFunction(lastDitchPos)
		if lastDitchPos then return lastDitchPos end
	end
end