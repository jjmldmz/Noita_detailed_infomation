dofile( "data/scripts/lib/utilities.lua" )
local created_gui = false

local res_number_format="%.2f"
res_decimal= math.floor(tonumber(ModSettingGet("DetailedInformation.decimal_places"))+0.5)
print("res number format: "..tostring(res_decimal))
if res_decimal then
  res_number_format="%."..tostring(res_decimal).."f"
end

local res_list = {"curse","drill","electricity","explosion","fire","healing","ice","melee","overeating","physics_hit","poison","projectile","radioactive","slice"}
local res_local_key = {["curse"] = "$inventory_mod_damage_curse",
                       ["drill"] = "$damage_drill",
                       ["electricity"] = "$damage_electricity",
                       ["explosion"] = "$damage_explosion",
                       ["fire"] = "$damage_fire",
                       ["healing"] = "$damage_healing",
                       ["ice"] = "$damage_ice",
                       ["melee"] ="$damage_melee",
                       ["overeating"] ="$damage_overeating",
                       ["physics_hit"] = "$damage_physicshit",
                       ["poison"] ="$damage_poison",
                       ["projectile"] = "$damage_projectile",
                       ["radioactive"] ="$damage_radioactive",
                       ["slice"] = "$damage_slice"}

local protect_icon = {
  ["PROTECTION_ALL"] = "mods/DetailedInformation/gui/protect_icon/protection_all.png",
  ["PROTECTION_ELECTRICITY"] = "mods/DetailedInformation/gui/protect_icon/protection_elec.png",
  ["PROTECTION_EXPLOSION"] = "mods/DetailedInformation/gui/protect_icon/protection_explo.png",
  ["PROTECTION_FIRE"] = "mods/DetailedInformation/gui/protect_icon/protection_fire.png",
  ["PROTECTION_FREEZE"] = "mods/DetailedInformation/gui/protect_icon/protection_freeze.png",
  ["PROTECTION_MELEE"] ="mods/DetailedInformation/gui/protect_icon/protection_melee.png",
  ["PROTECTION_POLYMORPH"] = "mods/DetailedInformation/gui/protect_icon/protection_poly.png",
  ["PROTECTION_RADIOACTIVITY"] = "mods/DetailedInformation/gui/protect_icon/protection_radio.png"
}
if not _info_gui then
  print("Creating equip GUI")
  _info_gui = GuiCreate()
  created_gui = true
else
  print("Reloading onto existing GUI")
end
local gui = _info_gui
function draw_text_box_info(x, y, width, height, id_start)
  GuiZSet( gui, 0.22 )
  if width ==0 or height == 0 then return end
  if id_start == nil then id_start = 37894 end
  GuiImage( gui, id_start, x,y, "mods/DetailedInformation/gui/text_background.png", 1,width/20, height/20)

  GuiZSet( gui, 0.2 )
  GuiImage( gui, id_start+1, x,y, "mods/DetailedInformation/gui/text_board.png", 1,width,1)
  GuiImage( gui, id_start+3, x,y, "mods/DetailedInformation/gui/text_board.png", 1,1,height)
  GuiImage( gui, id_start+2, x+1,y+height, "mods/DetailedInformation/gui/text_board.png", 1,width,1)
  GuiImage( gui, id_start+4, x+width,y+1, "mods/DetailedInformation/gui/text_board.png", 1,1,height)
  GuiImage( gui, id_start+5, x,y+height, "mods/DetailedInformation/gui/text_corner.png", 1,1)
  GuiImage( gui, id_start+6, x+width,y, "mods/DetailedInformation/gui/text_corner.png", 1,1)
  GuiZSet( gui, 0 )
end

function get_brief_info(creature_id)
  local info_list ={
    is_detailed_info = false,
    name = "",
    hp = 0,
    max_hp = 0,
  }
  if EntityGetIsAlive( creature_id ) == false then
    info_list.name = "Dead"
  else
    if EntityHasTag( creature_id,  "player_unit" ) then
      --player
      info_list.name = GameTextGet("$animal_player")
    else
      --try stats name first
      local stats_comp = EntityGetFirstComponentIncludingDisabled(creature_id, "GameStatsComponent" )
      if stats_comp ~= nil then
        info_list.name = GameTextGetTranslatedOrNot("$animal_"..ComponentGetValue2( stats_comp, "name"))
      end
      --try entityname
      if info_list.name == "" then
          info_list.name = GameTextGetTranslatedOrNot(EntityGetName(creature_id ))
      end
      if info_list.name == "" then
        --default name
        info_list.name = "An Enemy"
      end
    end
    local model_comp = EntityGetFirstComponentIncludingDisabled(creature_id, "DamageModelComponent" )
    info_list.hp = ComponentGetValue2( model_comp, "hp") *25
    info_list.max_hp = ComponentGetValue2( model_comp, "max_hp") *25
  end
  return info_list
end

function get_protect(entity_id)
  local protect = {
    ["PROTECTION_ALL"] = false,
    ["PROTECTION_ELECTRICITY"] = false,
    ["PROTECTION_EXPLOSION"] = false,
    ["PROTECTION_FIRE"] = false,
    ["PROTECTION_FREEZE"] = false,
    ["PROTECTION_MELEE"] = false,
    ["PROTECTION_POLYMORPH"] = false,
    ["PROTECTION_RADIOACTIVITY"] = false
  }
  local child_entity = EntityGetAllChildren( entity_id )
  if child_entity ~= nil then
    for _,child in pairs(child_entity) do
      local comps = EntityGetComponent( child , "GameEffectComponent")
      if comps ~= nil and #comps >0 then
        for _,comp in pairs(comps) do
          local effect_name = ComponentGetValue2( comp, "effect" )
          if protect[effect_name] ~= nil then
            protect[effect_name] = true
          end
        end
      end
    end
  end
  if EntityHasTag(entity_id,"polymorphable_NOT") then protect["PROTECTION_POLYMORPH"] = true end
  return protect
end

function get_detailed_info(creature_id)
  local info = get_brief_info(creature_id)
  if info.name == "Dead" then
    return info
  end
  local detailed_info={
    is_detailed_info = true,
    name = info.name,
    hp = info.hp,
    max_hp = info.max_hp,
    protect = {},
    res = {},
    --material_damage = {}
  }
  local protect_list =  get_protect(creature_id)
  for effect_name,has_this_effect in pairs(protect_list) do
    if has_this_effect then
      table.insert(detailed_info.protect,effect_name)
    end
  end
  local damagemodel = EntityGetFirstComponent( creature_id, "DamageModelComponent" )
  if damagemodel~= nil then
    for _,damage_type in ipairs(res_list) do
      local res = ComponentObjectGetValue2(  damagemodel,"damage_multipliers", damage_type )
      if math.abs(res -1) >0.001 then
        table.insert(detailed_info.res,{type = damage_type,value = res})
      end
    end
  end
  --[[
  TODO
    local harm_mat = ComponentGetValue2( damagemodel, "materials_that_damage" )
  if harm_mat ~= nil then

  end
  ]]--
  return detailed_info
end

--line height: 5+4,box height = 9* lines
function draw_info(x,y,info,id)
  if info.name == "Dead" then
    draw_text_box_info(x+5,y+5,40, 15,id)
    GuiText( gui, x+10,y+10, GameTextGet("$creature_is_dead"))
    return
  end
  if info.is_detailed_info == false then
    local line1 = info.name .. "  ".. tostring(math.floor(info.hp) ).."/"..tostring(math.floor(info.max_hp))
    local line2 = ""
    local hotkey_setting = ModSettingGet("DetailedInformation.select_hotkey")
    if hotkey_setting =="right_click2" then
      line2 = GameTextGet("$interact_mark_enemy", GameTextGet("$input_mouseright"))
    elseif hotkey_setting =="right_click" then
      line2 = GameTextGet("$interact_mark_enemy", GameTextGet("$input_mouseright"))
    elseif hotkey_setting =="interact" then
      line2 = GameTextGet("$interact_mark_enemy","E")
    end
    local width = math.max(string.len(line1),string.len(line2))*5 + 10
    --TODO
    if GameTextGetTranslatedOrNot("$current_language") == "русский" then
      width =  math.max(string.len(line1),string.len(line2))*3 + 10
    end
    draw_text_box_info(x+5,y+5,width,27,id+1700)
    GuiText( gui, x+10,y+9,line1 )
    GuiText( gui, x+10,y+18,line2 )
  else
    GuiZSet( gui, 0 )
    local line1 = info.name --name
    local line2 = GameTextGet("$creature_hp")..":  "..string.format("%.2f",info.hp) .."/"..string.format("%.2f",info.max_hp) --detailed hp
    --box

    --name
    GuiText( gui, x+10,y+9,line1 )
    GuiText( gui, x+15,y+18,line2 )
    --protect
    local x_start = 15
    for _,protect_effect in pairs(info.protect) do
      GuiImage( gui, 45789+x_start,x + x_start, y+30,protect_icon[protect_effect],1,1)
      x_start = x_start+12
    end

    local current_y = 50
    if #(info.protect) == 0 then
      current_y = 31
    end
    GuiText( gui, x+10,y+ current_y,GameTextGet("$damage_multipliers")..":")
    current_y = current_y + 9

    local res_type_space = 55
    if GameTextGetTranslatedOrNot("$current_language") == "русский" then
      res_type_space = 75
      for i,resistance in pairs(info.res) do
        if resistance.type == "physics_hit" then
          res_type_space = 95
          break
        end
      end
    end

    for i,resistance in pairs(info.res) do
      local res_name =GameTextGet(res_local_key[resistance.type])
      GuiText( gui, x+15,y+ current_y,res_name)
      local text_res = string.format(res_number_format,resistance.value*100)
      if ModSettingGet("DetailedInformation.percentage")~=true then
        text_res = string.format(res_number_format,resistance.value)
      else
        text_res = text_res.."%"
      end
      if ModSettingGet("DetailedInformation.multiplication")==true then
        text_res = "x"..text_res
      end
      GuiText( gui, x+15 +  res_type_space,y+ current_y,text_res)
      current_y = current_y +9
    end
    GuiZSet( gui, 0 )
    draw_text_box_info(x+5,y+5,85 +  res_type_space, current_y +4,id+1900)
  end
end

function _info_gui_main(mouse_gui_x,mouse_gui_y,creature_id)
  if GameIsInventoryOpen() then
    return
  end

  local screen_width,screen_height = GuiGetScreenDimensions( gui )
  local marked_enemy = tonumber(GlobalsGetValue("MARKED_CREATURE", "0" ))
  if marked_enemy > 0 then
    --update mouse pos creature info
    local x,y=mouse_gui_x * screen_width/1280  , mouse_gui_y * screen_height/720
    local info = get_detailed_info(marked_enemy)
    draw_info(x,y,info,587945)
  elseif creature_id >0 then
    --update marked_enemy info
    if ModSettingGet("DetailedInformation.panel_enable") then
      local x,y=mouse_gui_x * screen_width/1280  , mouse_gui_y * screen_height/720
      local info = get_brief_info(creature_id)
      draw_info(x,y,info,878965)
    end
  end

  if gui ~= nil then
    GuiStartFrame( gui )
  end
end
