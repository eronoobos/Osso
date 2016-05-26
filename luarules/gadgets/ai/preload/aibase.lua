
AIBase = class(function(a)
   --
end)


function AIBase:Init()
end

function AIBase:Update(frame)
end

function AIBase:GameEnd()
end

function AIBase:GameMessage(text)
end

function AIBase:UnitCreated(unitID, unitDefID, teamID, builderID)
end

function AIBase:UnitFinished(unitID, unitDefID, teamID)
end

function AIBase:UnitGiven(unitID, unitDefID, teamID, oldTeamID)
end


function AIBase:UnitDestroyed(unitID, unitDefID, teamID, attackerId, attackerDefId, attackerTeamId)
end

function AIBase:UnitIdle(unitID, unitDefID, teamID)
end

function AIBase:UnitDamaged(unitID, unitDefID, unitTeamId, damage, paralyzer, weaponDefId, projectileId, attackerId, attackerDefId, attackerTeamId)
end
function AIBase:UnitMoveFailed(unitID)
end
