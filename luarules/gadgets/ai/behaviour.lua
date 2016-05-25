Behaviour = class(AIBase)

function Behaviour:Init()
end

function Behaviour:Update()
end

function Behaviour:GameEnd()
end

function Behaviour:UnitCreated(unitID)
end

function Behaviour:UnitFinished(unitID)
end

function Behaviour:OwnerFinished()
end

function Behaviour:UnitDestroyed(unitID)
end

function Behaviour:OwnerDestroyed()
end

function Behaviour:UnitDamaged(unitID, attackerID, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeamID)
end

function Behaviour:OwnerDamaged(damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeamID)
end

function Behaviour:UnitIdle(unitID)
end

function Behaviour:OwnerIdle()
end

function Behaviour:SetUnit(unit)
	self.unit = unit
	self.ai = unit.ai
	self.unitID = unit.unitID
	self.name = unit:Name()
end

function Behaviour:IsActive()
	return self.active
end

function Behaviour:Activate()
	--
end

function Behaviour:Deactivate()
	--
end

function Behaviour:Priority()
	return 0
end

function Behaviour:Passive()
	return false
end

function Behaviour:UnitMoveFailed(unitID)
	self:UnitIdle(unitID)
end

function Behaviour:OwnerMoveFailed()
end