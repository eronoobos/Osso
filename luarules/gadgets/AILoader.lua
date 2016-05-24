function gadget:GetInfo()
   return {
      name = "Osso",
      desc = "Osso Lua AI Framework, based on Shard by AF",
      author = "eronoobos, based on gadget by raaar, and Shard by AF",
      date = "May 2016",
      license = "whatever",
      layer = 999999,
      enabled = true,
   }
end

-- globals
VFS.Include("luarules/gadgets/ai/preload/globals.lua")

osso_include("behaviourfactory")
osso_include("unit")
osso_include("module")
osso_include("modules")
osso_include("ai")

local AIs = {}
Osso = {}
Osso.AIs = AIs

-- localization
local spEcho = Spring.Echo
local spGetTeamList = Spring.GetTeamList
local spGetTeamInfo = Spring.GetTeamInfo
local spGetTeamLuaAI = Spring.GetTeamLuaAI
local spAreTeamsAllied = Spring.AreTeamsAllied
local spGetTeamStartPosition = Spring.GetTeamStartPosition
local spGetTeamUnits = Spring.GetTeamUnits
local spGetAllUnits = Spring.GetAllUnits
local spGetUnitTeam = Spring.GetUnitTeam

local function prepareTheAI(thisAI)
	if not thisAI.modules then thisAI:Init() end
end

--SYNCED CODE
if (gadgetHandler:IsSyncedCode()) then

function gadget:Initialize()

	local numberOfOssoAITeams = 0
	local teamList = spGetTeamList()

	for i=1,#teamList do
		local id = teamList[i]
		local _,_,_,isAI,side,allyID = spGetTeamInfo(id)
        
		--spEcho("Player " .. teamList[i] .. " is " .. side .. " AI=" .. tostring(isAI))

		---- adding AI
		if (isAI) then
			local aiInfo = spGetTeamLuaAI(id)
			if (string.sub(aiInfo,1,8) == "Osso") then
				numberOfOssoAITeams = numberOfOssoAITeams + 1
				spEcho("Player " .. teamList[i] .. " is " .. aiInfo)
				-- add AI object
				thisAI = AI()
				thisAI:SetTeamID(id)
				thisAI:SetallyID(allyID)
				-- thisAI:Init()
				AIs[#AIs+1] = thisAI
			else
				spEcho("Player " .. teamList[i] .. " is another type of lua AI!")
			end
		end
	end

	-- add allied teams for each AI
	for i = 1, #AIs do
    		local thisAI = AIs[i]
		alliedTeamIds = {}
		enemyTeamIds = {}
		for i=1,#teamList do
			if (spAreTeamsAllied(thisAI.id,teamList[i])) then
				alliedTeamIds[teamList[i]] = true
			else
				enemyTeamIds[teamList[i]] = true
			end
		end
		-- spEcho("AI "..thisAI.id.." : allies="..#alliedTeamIds.." enemies="..#enemyTeamIds)
		thisAI.alliedTeamIds = alliedTeamIds
		thisAI.enemyTeamIds = enemyTeamIds
	end

	-- catch up to started game
	if Spring.GetGameFrame() > 1 then
		self:GameStart()
		-- catch up to current units
		for _,uId in ipairs(spGetAllUnits()) do
			self:UnitCreated(uId, Spring.GetUnitDefID(uId), Spring.GetUnitTeam(uId))
		end
	end
end

function gadget:GameStart() 
    -- Initialise AIs
    for i = 1, #AIs do
    		local thisAI = AIs[i]
        local _,_,_,isAI,side = spGetTeamInfo(thisAI.id)
		thisAI.side = side
		local x,y,z = spGetTeamStartPosition(thisAI.id)
		thisAI.startPos = {x,y,z}
		if not thisAI.modules then thisAI:Init() end
    end
end


function gadget:GameFrame(n) 

	-- for each AI...
    for i = 1, #AIs do
    		local thisAI = AIs[i]
        
        -- update sets of unit ids : own, friendlies, enemies
		thisAI.ownUnitIds = {}
        thisAI.friendlyUnitIds = {}
        thisAI.alliedUnitIds = {}
        thisAI.enemyUnitIds = {}

        for _,uId in ipairs(spGetAllUnits()) do
        	if (spGetUnitTeam(uId) == thisAI.id) then
        		thisAI.ownUnitIds[uId] = true
        		thisAI.friendlyUnitIds[uId] = true
        	elseif (thisAI.alliedTeamIds[spGetUnitTeam(uId)] or spGetUnitTeam(uId) == thisAI.id) then
        		thisAI.alliedUnitIds[uId] = true
        		thisAI.friendlyUnitIds[uId] = true
        	else
        		thisAI.enemyUnitIds[uId] = true
        	end
        end 
	
		-- run AI game frame update handlers
		prepareTheAI(thisAI)
		thisAI:Update()
    end
end


function gadget:UnitCreated(unitID, unitDefID, teamID, builderID) 
    for i = 1, #AIs do
    	local thisAI = AIs[i]
    	if Spring.GetUnitTeam(unitID) == thisAI.id then
	    	prepareTheAI(thisAI)
    		thisAI:UnitCreated(unitID, unitDefID, teamID, builderID)
	    end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerId, attackerDefId, attackerTeamId) 
	for i = 1, #AIs do
		local thisAI = AIs[i]
		prepareTheAI(thisAI)
		thisAI:UnitDestroyed(unitID, unitDefID, teamID, attackerId, attackerDefId, attackerTeamId)
	end
end


function gadget:UnitDamaged(unitID, unitDefID, unitTeamId, damage, paralyzer, weaponDefId, projectileId, attackerId, attackerDefId, attackerTeamId)
    for i = 1, #AIs do
		local thisAI = AIs[i]
    	prepareTheAI(thisAI)
		thisAI:UnitDamaged(unitID, unitDefID, unitTeamId, damage, paralyzer, weaponDefId, projectileId, attackerId, attackerDefId, attackerTeamId)
	end	
end

function gadget:UnitIdle(unitID, unitDefID, teamID) 
    for i = 1, #AIs do
		local thisAI = AIs[i]
    	prepareTheAI(thisAI)
		thisAI:UnitIdle(unitID, unitDefID, teamID)
	end
end


function gadget:UnitFinished(unitID, unitDefID, teamID) 
    for i = 1, #AIs do
		local thisAI = AIs[i]
		prepareTheAI(thisAI)
		thisAI:UnitFinished(unitID, unitDefID, teamID)
	end
end

function gadget:UnitTaken(unitID, unitDefID, teamID, newTeamID) 
    for i = 1, #AIs do
		local thisAI = AIs[i]
		if teamID == thisAI.id or newTeamID == thisAI.id then
	    	prepareTheAI(thisAI)
			-- thisAI:UnitTaken(unitID, unitDefID, teamID, newTeamID)
		end
	end
end

function gadget:UnitGiven(unitID, unitDefID, teamID, oldTeamID)
    for i = 1, #AIs do
		local thisAI = AIs[i]
		if teamID == thisAI.id or oldTeamID == thisAI.id then
	    	prepareTheAI(thisAI)
			-- thisAI:UnitGiven(unitID, unitDefID, teamID, oldTeamID)
		end
	end
end

function gadget:GameID(gameID)
	if Osso then
		Osso.gameID = gameID
		local rseed = 0
		local unpacked = VFS.UnpackU8(gameID, 1, string.len(gameID))
		for i, part in ipairs(unpacked) do
			-- local mult = 256 ^ (#unpacked-i)
			-- rseed = rseed + (part*mult)
			rseed = rseed + part
		end
		-- Spring.Echo("randomseed", rseed)
		Osso.randomseed = rseed
	end
end

--UNSYNCED CODE
else





end


