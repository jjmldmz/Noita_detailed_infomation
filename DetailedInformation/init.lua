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

local function check_double_interact(frame_interact)
	local time = frame_interact- frame_last_interact
	if time>0 and time<20 then
		frame_last_interact = 0
		return true
	else
		frame_last_interact = frame_interact
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
	return -1
end
function OnWorldPostUpdate()
	if player_id == nil then
		player_id = EntityGetWithTag("player_unit")[1]
		if player_id==nil then
			return
		end
	end

	if EntityGetIsAlive( player_id ) == false then return end
	if not _info_gui_main then return end
	local mouse_x,mouse_y,mouse_gui_x,mouse_gui_y, select_key_pressed,frame_right_click, close_key_pressed,frame_interact
	close_key_pressed = false
	edit_component2(player_id,"ControlsComponent",function (comp,vars)
		mouse_x,mouse_y = ComponentGetValue2( comp, "mMousePosition")
		mouse_gui_x,mouse_gui_y = ComponentGetValue2( comp, "mMousePositionRaw")

		frame_right_click = ComponentGetValue2( comp, "mButtonFrameRightClick")
		frame_interact=ComponentGetValue2( comp, "mButtonFrameInteract")

		local hotkey_setting = ModSettingGet("DetailedInformation.select_hotkey")
		if hotkey_setting =="right_click2" then
			select_key_pressed = check_double_click(frame_right_click)
		elseif hotkey_setting =="right_click" then
			select_key_pressed = ComponentGetValue2( comp, "mButtonDownRightClick")
		elseif hotkey_setting =="leftright" then
			select_key_pressed = ComponentGetValue2( comp, "mButtonDownRightClick") and ComponentGetValue2( comp, "mButtonDownLeftClick")
		elseif hotkey_setting =="interact" then
			select_key_pressed = ComponentGetValue2( comp, "mButtonDownInteract")
		elseif hotkey_setting == "sub_fire" then
			select_key_pressed =ComponentGetValue2( comp, "mButtonDownFire") and (ComponentGetValue2( comp, "mButtonDownFire2") == false)
		end

		local close_hotkey_setting = ModSettingGet("DetailedInformation.brief_panel_hotkey")
		if close_hotkey_setting =="right_click2" then
			close_key_pressed = check_double_click(frame_right_click)
		elseif close_hotkey_setting =="right_click" then
			close_key_pressed = ComponentGetValue2( comp, "mButtonDownRightClick")
		elseif close_hotkey_setting =="leftright" then
			close_key_pressed = ComponentGetValue2( comp, "mButtonDownRightClick") and ComponentGetValue2( comp, "mButtonDownLeftClick")
		elseif close_hotkey_setting =="interact2" then
			close_key_pressed = check_double_interact(frame_interact)
			--close_key_pressed = ComponentGetValue2( comp, "mButtonDownInteract")
		elseif close_hotkey_setting == "sub_fire" then
			close_key_pressed =ComponentGetValue2( comp, "mButtonDownFire") and (ComponentGetValue2( comp, "mButtonDownFire2") == false)
		else
			close_key_pressed = false
		end
	end )



	if close_key_pressed then
		--info_enabled = not info_enabled
		--print("close key pressed")
		ModSettingSetNextValue( "DetailedInformation.panel_enable", not ModSettingGet( "DetailedInformation.panel_enable"), false )
		GlobalsSetValue("MARKED_CREATURE","-1" )
	end

	local mouse_creature = get_creature_at(mouse_x,mouse_y)

	--update marked enemy
	if select_key_pressed then
		GlobalsSetValue("MARKED_CREATURE", tostring( mouse_creature) )
	end
	_info_gui_main(mouse_gui_x,mouse_gui_y,mouse_creature)
end

function OnPlayerSpawned( player_entity ) -- this runs when player entity has been created
	dofile("mods/DetailedInformation/gui/info_gui.lua")
	player_id = player_entity
	frame_last_right_click = 0
	frame_last_interact=0
	entity_to_mark = -1
	GlobalsSetValue("MARKED_CREATURE","-1" )


	local mark = EntityGetWithName( "mod_mark_on_enemy")
	if mark == nil or mark ==0 then
		EntityLoad( "mods/DetailedInformation/entities/mark.xml")
	end

	--for test
	--[[
		--local res_list = {"curse","drill","electricity","explosion","fire","healing","ice","melee","overeating","physics_hit","poison","projectile","radioactive","slice"}
	local res_list = {"curse","drill","electricity","explosion","fire","healing","ice","melee","overeating","poison","projectile","radioactive","slice"}
	local damagemodel = EntityGetFirstComponentIncludingDisabled(  player_entity, "DamageModelComponent" )
	if damagemodel~= nil then
		for _,damage_type in ipairs(res_list) do
			ComponentObjectSetValue2(  damagemodel,"damage_multipliers", damage_type,0.8 )
		end
	end
	]]--
end
local translation = ModTextFileGetContent("data/translations/common.csv") .. ModTextFileGetContent("mods/DetailedInformation/translation/common.csv")
ModTextFileSetContent("data/translations/common.csv", translation)