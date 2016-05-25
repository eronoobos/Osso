AttackHandler = class(Module)

local spGetUnitPosition = Spring.GetUnitPosition

function AttackHandler:Name()
	return "AttackHandler"
end

function AttackHandler:internalName()
	return "attackhandler"
end

function AttackHandler:Init()
	self.recruits = {}
	self.counter = 8
end

function AttackHandler:Update(frame)
-- stagger targetting if multiple ossos
	local f = frame + self.ai.id
	if f % 15 == 0 then
		self:DoTargetting()
	end
end

function AttackHandler:UnitDestroyed(unitID, unitDefID, teamID, attackerId, attackerDefId, attackerTeamId)
	if teamID == self.ai.id then
		self.counter = self.counter - 0.2
		self.counter = math.max(self.counter,8)
	end
end

function AttackHandler:DoTargetting()
	if #self.recruits > self.counter then
		-- find somewhere to attack
		local cells = {}
		local celllist = {}
		local enemies = self.ai.enemyUnits

		if enemies and #enemies > 0 then
			-- figure out where all the enemies are!
			for i=1,#enemies do
				local e = enemies[i]

				if e ~= nil then
					local ex, ey, ez = spGetUnitPosition(e)
					local px = (ex - (ex % 400)) / 400
					local pz = (ez - (ez % 400)) / 400
					if cells[px] == nil then
						cells[px] = {}
					end
					if cells[px][pz] == nil then
						local newcell = { count = 0, posx = 0,posz=0,}
						cells[px][pz] = newcell
						table.insert(celllist,newcell)
					end
					cell = cells[px][pz]
					cell.count = cell.count + self:ScoreUnit(e)
					
					-- we dont want to target the center of the cell encase its a ledge with nothing
					-- on it etc so target this units position instead
					cell.posx = ex
					cell.posz = ez

					-- @TODO: The unit chosen may not be the best unit to target, ideally pick the
					-- one closest to the average location of all units in that grid
				end

			end
			
			local bestCell = nil
			-- now find the smallest nonvacant cell to attack
			for i=1,#celllist do
				local cell = celllist[i]
				if bestCell == nil then
					bestCell = cell
				else
					if cell.count < bestCell.count then
						bestCell = cell
					end
				end
			end
			
			-- if we have a cell then lets go attack it!
			if bestCell ~= nil then
				for i,recruit in ipairs(self.recruits) do
					recruit:AttackCell(bestCell)
				end
				
				self.counter = self.counter + 0.2
				self.counter = math.min(self.counter,20)
				
				-- remove all our recruits!
				self.recruits = {}
			end
		end
		
		-- cleanup
		cellist = nil
		cells = nil
		mapdimensions = nil
		
	end
end

function AttackHandler:IsRecruit(attkbehaviour)
	for i,v in ipairs(self.recruits) do
		if v.unitID == attkbehaviour.unitID then
			return true
		end
	end
	return false
end

function AttackHandler:AddRecruit(attkbehaviour)
	if attkbehaviour.unit == nil then
		spEcho( "null unit in attack beh found ")
		return
	end
	if not self:IsRecruit(attkbehaviour) then
		table.insert(self.recruits,attkbehaviour)
	end
end

function AttackHandler:RemoveRecruit(attkbehaviour)
	for i,v in ipairs(self.recruits) do
		if v.unitID == attkbehaviour.unitID then
			table.remove(self.recruits,i)
			return true
		end
	end
	return false
end

-- How much is this unit worth?
-- 
-- Idea: add a table with hardcoded values,
-- and use said values if a units found in
-- that table to highlight strategic value
function AttackHandler:ScoreUnit(unit)
	local value = 1

	if unit.def.canMove then
		if unit.def.isBuilder then
			value = value + 1
		end
	else
		value = value + 1
		if unit.def.isBuilder then
			value = value + 1
		end
	end
	return value
end
