function osso_include( file )
	if type(file) ~= 'string' then
		return nil
	end
	local baseFile = "luarules/gadgets/ai/" .. file .. ".lua"
	local preloadFile = "luarules/gadgets/ai/preload/" .. file .. ".lua"
	if VFS.FileExists(baseFile) then
		-- Spring.Echo("got baseFile", baseFile)
		return VFS.Include(baseFile)
	elseif VFS.FileExists(preloadFile) then
		-- Spring.Echo("got preloadFile", preloadFile)
		return VFS.Include(preloadFile)
	end
end

osso_include "hooks"
osso_include "class"
osso_include "aibase"