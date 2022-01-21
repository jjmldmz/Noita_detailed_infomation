
--this script file contains the functions of two scripts
dofile_once("data/scripts/lib/utilities.lua")
print("interacting")

--This part of the code is executed every 20 frames
local entity_id = GetUpdatedEntityID()
--Here, the interaction of the end mark is enalbed. delayed for a while to prevent the end of the tag.
EntitySetComponentsWithTagEnabled( entity_id, "mark_delete", true )
--[[
The interaction of "delete mark" is disabled at the beginning.
It must be enabled on manually later after generation, rather than enabled by default.
Otherwise, as soon as the mark is generated(by you press [E] to mark a enemy), you will directly trigger the code to delete it because you still press the [E].
]]--

--Check if the player is still nearby
local x,y = EntityGetTransform( entity_id)
local players = EntityGetInRadiusWithTag( x,y, 300,"player_unit")
if #players == 0 then EntityKill( entity_id ) end


function interacting( entity_who_interacted, entity_interacted, interactable_name )
    --the interact part, simply delete itself.
    if interactable_name ~= "mark_interact" then return end
    EntityKill( entity_interacted )
end



