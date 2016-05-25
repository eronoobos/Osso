Behaviour = class(AIBase)

function Behaviour:Init()
end

function Behaviour:Update()
end

function Behaviour:GameEnd()
end

function Behaviour:UnitCreated(unit)
end

function Behaviour:UnitFinished(unit)
end

function Behaviour:UnitDestroyed(unit)
end

function Behaviour:UnitDamaged(unit,attacker,damage)
end

function Behaviour:UnitIdle(unit)
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

function Behaviour:UnitMoveFailed(unit)
	self:UnitIdle(unit)
end

function Behaviour:OwnerDestroyed()
	return
end