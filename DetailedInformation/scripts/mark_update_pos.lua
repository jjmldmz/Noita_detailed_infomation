dofile_once("data/scripts/lib/utilities.lua")
local entity_id = GetUpdatedEntityID()
local marked_enemy = tonumber(GlobalsGetValue("MARKED_CREATURE", "0" ))
if marked_enemy <=0 then
    EntitySetComponentsWithTagEnabled( entity_id, "enabled_with_enemy", false )
    return
end
if EntityGetIsAlive( marked_enemy ) then
    local x,y = EntityGetTransform( marked_enemy)
    EntitySetTransform( entity_id, x,y)
    EntitySetComponentsWithTagEnabled( entity_id, "enabled_with_enemy", true )
else
    EntitySetComponentsWithTagEnabled( entity_id, "enabled_with_enemy", false )
end





