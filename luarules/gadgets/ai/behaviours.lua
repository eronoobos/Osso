
osso_include(  "taskqueues" )
osso_include(  "taskqueuebehaviour" )
osso_include(  "attackerbehaviour" )
osso_include(  "bootbehaviour" )

behaviours = { }

function defaultBehaviours(unit)
	local b = {}
	table.insert(b, BootBehaviour )
	if unit.def.isBuilder then
		table.insert(b,TaskQueueBehaviour)
	else
		if IsAttacker(unit) then
			table.insert(b,AttackerBehaviour)
		end
	end
	return b
end
