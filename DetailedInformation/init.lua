dofile( "data/scripts/perks/perk.lua" )

local function check_double_click(frame_right_click)
	local time = frame_right_click- frame_last_right_click
	if time>0 and time<20 then
		frame_last_right_click = 0
		return true
	else
		frame_last_right_click = frame_right_click
		return false
	end
end

local function get_creature_at(x,y)
	local players = EntityGetInRadiusWithTag( x,y, 22,"player_unit")
	if #players >0 then
		return players[1]
	end
	local enemies = EntityGetInRadiusWithTag( x,y, 22,"enemy")
	if #enemies>0 then
		return enemies[1]
	end
	return 0
end
function OnWorldPostUpdate()
	if player_id == nil then return end
	if EntityGetIsAlive( player_id ) == false then return end
	if not _info_gui_main then return end
	local mouse_x,mouse_y,mouse_gui_x,mouse_gui_y, right_click,frame_right_click
	edit_component2(player_id,"ControlsComponent",function (comp,vars)
		mouse_x,mouse_y = ComponentGetValue2( comp, "mMousePosition")
		mouse_gui_x,mouse_gui_y = ComponentGetValue2( comp, "mMousePositionRaw")
		right_click = ComponentGetValue2( comp, "mButtonDownRightClick")
		frame_right_click = ComponentGetValue2( comp, "mButtonFrameRightClick")
	end )

	if check_double_click(frame_right_click) then
		info_enabled = not info_enabled
	end

	local mouse_creature = get_creature_at(mouse_x,mouse_y)

	--update marked enemy
	if right_click then
		GlobalsSetValue("MARKED_CREATURE", tostring( mouse_creature) )
	end
	_info_gui_main(mouse_gui_x,mouse_gui_y,mouse_creature)
end

function OnPlayerSpawned( player_entity ) -- this runs when player entity has been created
	dofile("mods/DetailedInformation/gui/info_gui.lua")
	info_enabled = true
	player_id = player_entity
	frame_last_right_click = 0
	entity_to_mark = -1

	local mark = EntityGetWithName( "mod_mark_on_enemy")
	if mark == nil or mark ==0 then
		EntityLoad( "mods/DetailedInformation/entities/mark.xml")
	end
end
