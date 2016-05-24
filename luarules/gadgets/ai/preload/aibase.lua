
AIBase = class(function(a)
   --
end)


function AIBase:Init()
end

function AIBase:Update()
end

function AIBase:GameEnd()
end

function AIBase:GameMessage(text)
end

function AIBase:UnitCreated(engineunit)
end

function AIBase:UnitFinished(engineunit)
end

function AIBase:UnitGiven(engineunit)
	self:UnitCreated(engineunit)
	self:UnitFinished(engineunit)
end


function AIBase:UnitDestroyed(engineunit)
end

function AIBase:UnitIdle(engineunit)
end

function AIBase:UnitDamaged(engineunit,enginedamage)
end
function AIBase:UnitMoveFailed(engineunit)
end
