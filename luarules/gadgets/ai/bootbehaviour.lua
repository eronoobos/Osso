-- An initial boot behaviour that takes over a unit initially,
-- makes it wait 3-4 seconds idle after it's been built, then
-- releases control
--
-- This helps prevent units in factories from immediatley building
-- things or doing stuff before they've left the factory and
-- blocking the factory from building the next unit

BootBehaviour = class(Behaviour)

local MOVESTATE_HOLDPOS = 0

function BootBehaviour:Init()
	self.waiting = true
	self.finished = false
	self.count = 150
	self.unit:ElectBehaviour()
end

function BootBehaviour:UnitFinished(unit)
	if unit.engineID == self.unit.engineID then
		self.finished = true
	end
end

function BootBehaviour:Update()
	if self.waiting == false then
		return
	end
	if self.finished then
		self.count = self.count - 1
		if self.count < 1 then
			self.waiting = false
			self.unit:ElectBehaviour()
		end
	end
end

function BootBehaviour:Activate()
	self.active = true
end

function BootBehaviour:Deactivate()
	self.active = false
end

function BootBehaviour:Priority()
	-- don't apply to starting units
	if self.ai.frame < 5 then
		return 0
	end

	-- don't apply to structures
	if not self.unit.def.canMove then
		return 0
	end
	if self.waiting then
		return 500
	else
		return 0
	end
end

-- set to hold position while being repaired after resurrect
function BootBehaviour:SetMoveState()
	spGiveOrderToUnit( self.unitID, CMD.MOVE_STATE, { MOVESTATE_HOLDPOS }, {} )
end
