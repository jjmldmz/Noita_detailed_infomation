dofile("data/scripts/lib/mod_settings.lua")
--dofile_once("mods/Magicka/scripts/magicka_orb_utils.lua")

local language = GameTextGetTranslatedOrNot("$current_language")
--current_language,English,русский,Português (Brasil),Español,Deutsch,Français,Italiano,Polska,简体中文,日本語,한국어
local translate = {
	["key"] = {
		english = "translated content",
		russian = "",
		chinese = "翻译后内容",
	},

	["select hotkey"] = {
		english = "select hotkey",
		russian = "",
		chinese = "选择快捷键",
	},
	["double right click"] = {
		english = "double right click",
		russian = "",
		chinese = "双击右键",
	},
	["right click"] = {
		english ="right click",
		russian = "",
		chinese = "单击右键",
	},
	["interact key('E' by default) "] = {
		english ="interact key('E' by default) ",
		russian = "",
		chinese = "互动键（默认是E键）",
	},

	["Change the hot key of selecting creatures."] = {
		english ="Change the hot key of selecting creatures.",
		russian = "",
		chinese = "改变选中敌人所用的快捷键。",
	},
	["brief panel enable"] = {
		english ="brief panel enable",
		russian = "",
		chinese = "是否开启简要信息。",
	},
	["Enable brief information panel."] = {
		english ="Enable this mod's brief information panel. Quick switch with a shortcut key(double right click by default)",
		russian = "",
		chinese = "开启未选中敌人时的简要信息栏。此设置可以通过快捷键快捷切换开关状态（默认双击右键）。",
	},
	["brief panel hotkey"] = {
		english ="brief panel hotkey",
		russian = "",
		chinese = "简要信息快捷键",
	},
	["Change brief panel hotkey"] = {
		english ="Change the hot key corresponding to the brief panel switch.",
		russian = "",
		chinese = "改变快捷切换简要信息打开状态所用的快捷。",
	},
	["double interact key('E' by default) "] = {
		english ="double interact key('E' by default) ",
		russian = "",
		chinese = "双击互动键（默认E键）",
	},
	["disable the hot key"] = {
		english ="disable the hot key",
		russian = "",
		chinese = "取消这个快捷键",
	},
	["percentage value"] = {
		english ="percentage value",
		russian = "",
		chinese = "百分号",
	},
	["Displays as percentage"] = {
		english ="Displays damage multiplier values as a percentage. If off, the damage multiplier value will be displayed as a decimal.",
		russian = "",
		chinese = "是否以百分比显示伤害有效系数。关闭时，会以小数显示。",
	},
	["multiplication symbol"] = {
		english ="multiplication symbol",
		russian = "",
		chinese = "显示乘号",
	},
	["Use multiplication symbol"] = {
		english ="Use multiplication symbol",
		russian = "",
		chinese = "是否在有效系数前加入乘号。",
	},
	["decimal places"] = {
		english ="decimal places",
		russian = "",
		chinese = "显示位数",
	},
	["Number of digits"] = {
		english ="Number of digits after decimal point",
		russian = "",
		chinese = "小数点后显示几位。",
	},
}

local function GetTranslation(key)

	local trans_data = translate[key]
	local translated_text = nil
	if trans_data == nil then
		print("Haven't get translate data for "..key.." in mod setting.")
		translated_text = nil
	else
		if language == "русский" then
			translated_text = trans_data.russian
		elseif language =="简体中文" then
			translated_text = trans_data.chinese
		else
			translated_text = trans_data.english
		end
	end
	--if no translated text get(no key in data or no translate in data), return key itself
	if translated_text == nil then
		translated_text = key
	end
	return translated_text
end


function mod_setting_bool_custom( mod_id, gui, in_main_menu, im_id, setting )
	local value = ModSettingGetNextValue( mod_setting_get_id(mod_id,setting) )
	local text = setting.ui_name .. " - " .. GameTextGet( value and "$option_on" or "$option_off" )

	if GuiButton( gui, im_id, mod_setting_group_x_offset, 0, text ) then
		ModSettingSetNextValue( mod_setting_get_id(mod_id,setting), not value, false )
	end

	mod_setting_tooltip( mod_id, gui, in_main_menu, setting )
end

function mod_setting_change_callback( mod_id, gui, in_main_menu, setting, old_value, new_value  )
	print( tostring(new_value) )
end

local mod_id = "DetailedInformation"
mod_settings_version = 1
mod_settings = 
{
	{
		id ="select_hotkey",
		ui_name ="select hotkey",
		ui_description ="Change the hot key of selecting creatures.",
		value_default = "right_click",
		values ={
			{"right_click2","double right click"},
			{"right_click","right click",},
			--{"leftright","left click + right click",},
			{"interact","interact key('E' by default) ",},
			--{"sub_fire","secondary fire key(no default key, need to bind) ",},
			--{"none","disable this hot key",},
		},
		scope =  MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id ="panel_enable",
		ui_name = "brief panel enable",
		ui_description = "Enable brief information panel.",
		value_default = true,
		scope =  MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id ="brief_panel_hotkey",
		ui_name = "brief panel hotkey",
		ui_description = "Change brief panel hotkey",
		value_default = "right_click2",
		values ={
			{"right_click2","double right click"},
			--{"right_click","right click",},
			--{"leftright","left click + right click",},
			{"interact2","double interact key('E' by default) ",},
			--{"sub_fire","secondary fire key(no default key, need to bind) ",},
			{"none","disable the hot key",},
		},
		scope =  MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id ="percentage",
		ui_name = "percentage value",
		ui_description = "Displays as percentage",
		value_default = true,
		scope =  MOD_SETTING_SCOPE_RUNTIME,
	},
	{
		id = "multiplication",
		ui_name = "multiplication symbol",
		ui_description = "Use multiplication symbol",
		value_default = true,
		scope = MOD_SETTING_SCOPE_RUNTIME,
	},
	--[[
                {
        id = "projectile_priority",
        ui_name = "priority of some resistance",
        ui_description = "whether to show resistance to projectiles and explosions first.",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
    },
    ]]--
	{
		id ="decimal_places",
		ui_name = "decimal places",
		ui_description =  "Number of digits",
		value_default = 2,
		value_min = 0,
		value_max = 4.49,
		value_display_multiplier = 1,
		value_display_formatting = " $0",
		scope =  MOD_SETTING_SCOPE_RUNTIME_RESTART,
	},
}

for i,setting_table in pairs(mod_settings) do
	if setting_table.ui_name ~= nil then
		mod_settings[i].ui_name = GetTranslation(setting_table.ui_name)
	end
	if setting_table.ui_name ~= nil then
		mod_settings[i].ui_description = GetTranslation(setting_table.ui_description)
	end
	if setting_table.values ~= nil then
		local values = setting_table.values
		for j,text in pairs(values) do
			if text[2] ~= nil then
				text[2] = GetTranslation(text[2])
				values[j] = text
			end
		end
		mod_settings[i].values = values
	end
end

function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id )
	mod_settings_update( mod_id, mod_settings, init_scope )
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end
