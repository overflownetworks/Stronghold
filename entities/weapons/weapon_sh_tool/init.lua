resource.AddFile( "materials/tool_radialbg.vmt" )
resource.AddFile( "materials/tool_radialbg.vtf" )
resource.AddFile( "materials/tool_radialselect.vmt" )
resource.AddFile( "materials/tool_radialselect.vtf" )

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "tool.lua" )
AddCSLuaFile( "tool_object.lua" )
AddCSLuaFile( "cl_viewscreen.lua" )

include( "shared.lua" )
 
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
