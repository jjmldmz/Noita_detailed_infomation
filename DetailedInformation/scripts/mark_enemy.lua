dofile_once("data/scripts/lib/utilities.lua")
print("interacting")
function interacting( entity_who_interacted, entity_interacted, interactable_name )
    if interactable_name ~= "enemy_interact" then return end

    local player_id= EntityGetWithTag("player_unit")[1]
    local px,py = EntityGetTransform(player_id)
    local ctrl_components = EntityGetComponentIncludingDisabled(player_id, "ControlsComponent")
    local mouse_x,mouse_y
    if(ctrl_components ~= nil) then
        edit_component2(player_id,"ControlsComponent",function (comp,vars)
            mouse_x,mouse_y = ComponentGetValue2(comp, "mMousePosition")
        end )
    end

    local entity_to_mark
    if ((math.abs(mouse_x - px) + math.abs(mouse_y - py)) < 20) then
        entity_to_mark = player_id
    else
        entity_to_mark = EntityGetClosestWithTag(  mouse_x,mouse_y, "enemy" )
    end

    if EntityHasTag(entity_to_mark,"mod_enemy_info_marked") then
        return
    else
        local last_mark = EntityGetWithName( "mod_mark_on_enemy" )
        if last_mark ~= 0 and last_mark ~= nil then
            EntityKill( last_mark )
        end

        local mark = EntityLoad( "mods/mark_enemy/entities/mark.xml")
        EntityAddChild( entity_to_mark , mark )
    end
end





