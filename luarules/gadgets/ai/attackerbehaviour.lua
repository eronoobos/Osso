osso_include( "attackers" )

function IsAttacker(unit)
	for i,name in ipairs(attackerlist) do
		if name == unit:Name() then
			return true
		end
	end
	return false
end

AttackerBehaviour = class(Behaviour)

local spGetGroundHeight = Spring.GetGroundHeight
local spGiveOrderToUnit = Spring.GiveOrderToUnit

function AttackerBehaviour:Init()
	--game:SendToConsole("attacker!")
end

function AttackerBehaviour:OwnerFinished()
	self.attacking = false
	self.ai.attackhandler:AddRecruit(self)
end

function AttackerBehaviour:OwnerIdle()
	self.attacking = false
	self.ai.attackhandler:AddRecruit(self)
end

function AttackerBehaviour:AttackCell(cell)
	p = {}
	p.x = cell.posx
	p.z = cell.posz
	p.y = spGetGroundHeight(p.x, p.z)
	self.target = p
	self.attacking = true
	if self.active then
		spGiveOrderToUnit( self.unitID, CMD.FIGHT, { p.x, p.y, p.z }, {} )
	else
		self.unit:ElectBehaviour()
	end
end

function AttackerBehaviour:Priority()
	if not self.attacking then
		return 0
	else
		return 100
	end
end

function AttackerBehaviour:Activate()
	self.active = true
	if self.target then
		local p = self.target
		spGiveOrderToUnit( self.unitID, CMD.FIGHT, { p.x, p.y, p.z }, {} )
		self.target = nil
	else
		self.ai.attackhandler:AddRecruit(self)
	end
end


function AttackerBehaviour:OwnerDestroyed()
	self.ai.attackhandler:RemoveRecruit(self)
	self.attacking = nil
	self.active = nil
	self.unit = nil
end