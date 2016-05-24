Unit = class(AIBase)

function Unit:SetUnitInfo(unitID, unitDefID, builderID)
	self.unitID = unitID
	self.defID = unitDefID
	self.builderID = builderID
	self.def = UnitDefs[unitDefID]
	self.name = self.def.name
end

function Unit:ID()
	return self.unitID
end

function Unit:Name()
	return self.name
end

function Unit:Def()
	return self.def
end

function Unit:Init(ai)
	self.behaviours = {}
	self.behaviourvalues = {}
	self.ai = ai
end

function Unit:Update()
	if self.behaviours == nil then
		self.behaviours = {}
	end
	for k,v in pairs(self.behaviours) do
		v:Update()
	end
end

function Unit:GameEnd()
	for k,v in pairs(self.behaviours) do
		v:GameEnd()
	end
end

function Unit:UnitCreated(unitID)
	for k,v in pairs(self.behaviours) do
		v:UnitCreated(unitID)
	end
end

function Unit:UnitFinished(unitID)
	self:ElectBehaviour()
	for k,v in pairs(self.behaviours) do
		v:UnitFinished(unitID)
	end
end

function Unit:UnitDestroyed(unitID)
	for k,v in pairs(self.behaviours) do
		v:UnitDestroyed(unitID)
	end
	if unitID == self.unitID then
		if self.behaviours then
			for k,v in pairs(self.behaviours) do
				self.behaviours[k]:OwnerDied()
				self.behaviours[k] = nil
			end
			self.behaviours = nil
		end
	end
end


function Unit:UnitDamaged(unitID, unitDefID, unitTeamId, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeamID)
	for k,v in pairs(self.behaviours) do
		v:UnitDamaged(unitID, unitDefID, unitTeamId, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeamID)
	end
end

function Unit:UnitIdle(unitID)
	for k,v in pairs(self.behaviours) do
		v:UnitIdle(unitID)
	end
end

function Unit:UnitMoveFailed(unitID)
	for k,v in pairs(self.behaviours) do
		v:UnitMoveFailed(unitID)
	end
end

function Unit:AddBehaviour(behaviour)
	table.insert(self.behaviours,behaviour)
end

function Unit:ActiveBehaviour()
	return self.activebeh
end

function Unit:ElectBehaviour()
	if self.behaviours == nil then --probably we are dead.
		return
	end
	local bestbeh = nil
	local bestscore = -1
	if #self.behaviours > 0 then
		for k,v in pairs(self.behaviours) do
			if bestbeh == nil then
				bestbeh = v
				bestscore = v:Priority()
			else
				local score = v:Priority()
				if score > bestscore then
					bestscore = score
					bestbeh = v
				end
			end
		end
		
		if self.activebeh ~= bestbeh then
			if self.activebeh ~= nil then
				self.activebeh:Deactivate()
			end
			self.activebeh = bestbeh
			self.activebeh:Activate()
		end
	end
end
