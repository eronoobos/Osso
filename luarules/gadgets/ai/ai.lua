AI = class(AIBase)

function AI:SetTeamID(teamID)
	self.id = teamID
end

function AI:SetAllyID(allyID)
	self.allyID = allyID
end

function AI:Init()
	Spring.Echo("Osso - playing:".. Game.gameShortName .. " on: " .. Game.mapName)
	self.modules = {}
	if next(modules) ~= nil then
		for i,m in ipairs(modules) do
			newmodule = m()
			self:AddModule(newmodule)
		end
	end
end

function AI:Update()
	if self.gameend == true then
		return
	end
	for i,m in ipairs(self.modules) do
		if m == nil then
			Spring.Echo("nil module!")
		else
			m:Update()
		end
	end
end

function AI:GameMessage(text)
	if self.gameend == true then
		return
	end
	for i,m in ipairs(self.modules) do
		if m == nil then
			Spring.Echo("nil module!")
		else
			m:GameMessage(text)
		end
	end
end

function AI:UnitCreated(unitID, unitDefID, teamID, builderID)
	if self.gameend == true then
		return
	end
	for i,m in ipairs(self.modules) do
		m:UnitCreated(unitID, unitDefID, teamID, builderID)
	end
end

function AI:UnitFinished(unitID, unitDefID, teamID)
	if self.gameend == true then
		return
	end
	for i,m in ipairs(self.modules) do
		m:UnitFinished(unitID, unitDefID, teamID)
	end
end

function AI:UnitDestroyed(unitID, unitDefID, teamID, attackerId, attackerDefId, attackerTeamId)
	if self.gameend == true then
		return
	end
	for i,m in ipairs(self.modules) do
		m:UnitDestroyed(unitID, unitDefID, teamID, attackerId, attackerDefId, attackerTeamId)
	end
end

function AI:UnitIdle(unitID, unitDefID, teamID)
	if self.gameend == true then
		return
	end
	for i,m in ipairs(self.modules) do
		m:UnitIdle(unitID, unitDefID, teamID)
	end
end

function AI:UnitDamaged(unitID, unitDefID, unitTeamId, damage, paralyzer, weaponDefId, projectileId, attackerId, attackerDefId, attackerTeamId)
	if self.gameend == true then
		return
	end
	for i,m in ipairs(self.modules) do
		m:UnitDamaged(unitID, unitDefID, unitTeamId, damage, paralyzer, weaponDefId, projectileId, attackerId, attackerDefId, attackerTeamId)
	end
end

function AI:UnitMoveFailed(unitID)
	if self.gameend == true then
		return
	end
	for i,m in ipairs(self.modules) do
		m:UnitMoveFailed(unitID)
	end
end

function AI:GameEnd()
	self.gameend = true
	for i,m in ipairs(self.modules) do
		m:GameEnd()
	end
end

function AI:AddModule( newmodule )
	Spring.Echo("adding "..newmodule:Name().." module")
	local internalname = newmodule:internalName()
	self[internalname] = newmodule
	table.insert(self.modules,newmodule)
	newmodule:SetAI(self)
	newmodule:Init()
end