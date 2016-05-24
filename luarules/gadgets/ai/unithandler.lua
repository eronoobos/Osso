UnitHandler = class(Module)

local spGetUnitTeam = Spring.GetUnitTeam

function UnitHandler:Name()
	return "UnitHandler"
end

function UnitHandler:internalName()
	return "unithandler"
end

function UnitHandler:Init()
	self.myUnits = {}
	self.behaviourFactory = BehaviourFactory()
	self.behaviourFactory:Init()
end

function UnitHandler:Update()
	for k,v in pairs(self.myUnits) do
		if v then
			v:Update()
		end
	end
end

function UnitHandler:GameEnd()
	for k,v in pairs(self.myUnits) do
		v:GameEnd()
	end
end

function UnitHandler:UnitCreated(unitID, unitDefID, teamID, builderID)
	self:AIRepresentation(unitID, unitDefID, teamID, builderID)
	for k,v in pairs(self.myUnits) do
		v:UnitCreated(unitID)
	end
end

function UnitHandler:UnitFinished(unitID)
	for k,v in pairs(self.myUnits) do
		v:UnitFinished(unitID)
	end
end

function UnitHandler:UnitDestroyed(unitID)
	for k,v in pairs(self.myUnits) do
		v:UnitDestroyed(unitID)
	end
	self.myUnits[unitID] = nil
end

function UnitHandler:UnitDamaged(unitID, unitDefID, unitTeamId, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeamID)
	for k,v in pairs(self.myUnits) do
		v:UnitDamaged(unitID, unitDefID, unitTeamId, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeamID)
	end
end

function UnitHandler:UnitIdle(unitID)
	for k,v in pairs(self.units) do
		v:UnitIdle(unitID)
	end
end

function UnitHandler:AIRepresentation(unitID, unitDefID, teamID, builderID)
	if unitID == nil or teamID ~= self.ai.id then
		return nil
	end
	local u = self.myUnits[unitID]
	if u == nil and  then
		u = Unit()
		u:SetUnitInfo(unitID, unitDefID, builderID)
		u:Init(self.ai)
		self.behaviourFactory:AddBehaviours(u)
		self.myUnits[unitID] = u
	end
	return u
end