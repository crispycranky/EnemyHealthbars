-- Look whos snooping where they dont belong
local mod = get_mod("ColorCodedHealthbars")

-- Check if required modules are available
local Breeds = require("scripts/settings/breed/breeds")
local HealthExtension = require("scripts/extension_systems/health/health_extension")
local HuskHealthExtension = require("scripts/extension_systems/health/husk_health_extension")
local HudHealthBarLogic = require("scripts/ui/hud/elements/hud_health_bar_logic")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

-- ===== GLOBAL VARIABLES =====

-- Color definitions for different breed types
mod.breed_colors = {
	horde = { 150, 150, 150 },
	roamer = { 180, 180, 180 },
	elite = { 255, 165, 0 },
	special = { 255, 0, 255 },
	monster = { 255, 0, 0 },
	captain = { 128, 0, 128 },
	default = { 255, 255, 255 }
}

-- Initialize settings with defaults
local show = {
	show_horde = false,
	show_roamer = false,
	show_elite = true,
	show_special = true,
	show_monster = true,
	show_captain = true,
	always_show_healthbars = false,
	show_enemy_names = false,
	show_damage_numbers = false,
	show_names_only = false,  -- NEW: Show only enemy names, hide health bars
	max_display_range = 50,
	healthbar_width = 120,
	healthbar_height = 6,
	text_size = 20,
	text_offset_y = 8,
	bar_offset_y = 0,
	-- Visual enhancement settings
	bar_border_enabled = true,
	bar_border_thickness = 1,
	background_opacity = 180,
	bar_corner_style = "standard",
	text_shadow_enabled = true,
	text_outline_enabled = false,
	health_gradient = true,
	gradient_intensity = 75,
	smooth_animations = true,
	-- Priority system settings (simplified)
	max_healthbars_shown = 8,
	hide_full_health = false,
	priority_system = true,
	show_tag_indicators = false,
	show_health_indicator = false,
	-- NEW: Visibility settings
	enable_visibility_check = true,
	visibility_fade_speed = 3.0,
	visibility_behind_walls = false
}

-- ===== HELPER FUNCTIONS =====

local function update_colors_from_settings()
	mod.breed_colors.horde = { 
		mod:get("horde_color_r") or 150, 
		mod:get("horde_color_g") or 150, 
		mod:get("horde_color_b") or 150 
	}
	mod.breed_colors.monster = { 
		mod:get("monster_color_r") or 255, 
		mod:get("monster_color_g") or 0, 
		mod:get("monster_color_b") or 0 
	}
	mod.breed_colors.roamer = { 
		math.min(255, (mod:get("horde_color_r") or 150) + 30), 
		math.min(255, (mod:get("horde_color_g") or 150) + 30), 
		math.min(255, (mod:get("horde_color_b") or 150) + 30) 
	}
	-- FIXED: Corrected captain color calculation to use all RGB components
	mod.breed_colors.captain = { 
		mod:get("captain_color_r") or math.floor((mod:get("monster_color_r") or 255) / 2), 
		mod:get("captain_color_g") or math.floor((mod:get("monster_color_g") or 0) / 2), 
		mod:get("captain_color_b") or math.floor((mod:get("monster_color_b") or 0) / 2) 
	}
	mod.breed_colors.elite_ranged = {
		mod:get("elite_ranged_color_r") or 255,
		mod:get("elite_ranged_color_g") or 100,
		mod:get("elite_ranged_color_b") or 0
	}
	mod.breed_colors.elite_melee = {
		mod:get("elite_melee_color_r") or 255,
		mod:get("elite_melee_color_g") or 165,
		mod:get("elite_melee_color_b") or 0
	}
	mod.breed_colors.special_sniper = {
		mod:get("special_sniper_color_r") or 255,
		mod:get("special_sniper_color_g") or 0,
		mod:get("special_sniper_color_b") or 200
	}
	mod.breed_colors.special_pox_hound = {
		mod:get("special_pox_hound_color_r") or 200,
		mod:get("special_pox_hound_color_g") or 0,
		mod:get("special_pox_hound_color_b") or 255
	}
	mod.breed_colors.special_trapper = {
		mod:get("special_trapper_color_r") or 180,
		mod:get("special_trapper_color_g") or 0,
		mod:get("special_trapper_color_b") or 255
	}
	mod.breed_colors.special_disabler = {
		mod:get("special_disabler_color_r") or 200,
		mod:get("special_disabler_color_g") or 0,
		mod:get("special_disabler_color_b") or 255
	}
	-- Add the missing generic special color
	mod.breed_colors.special = {
		mod:get("special_color_r") or 255,
		mod:get("special_color_g") or 0,
		mod:get("special_color_b") or 255
	}
end

function mod.get_breed_color(unit)
	if not unit then
		return mod.breed_colors.default
	end
	
	local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
	if not unit_data_extension then
		return mod.breed_colors.default
	end
	
	local breed = unit_data_extension:breed()
	if not breed or not breed.tags then
		return mod.breed_colors.default
	end
	
	local tags = breed.tags
	local breed_name = breed.name
	
	-- FIXED: Add captain detection for both captain and cultist_captain tags
	if tags.captain or tags.cultist_captain then
		return mod.breed_colors.captain
	elseif tags.elite then
		if breed_name == "renegade_gunner" or breed_name == "renegade_shocktrooper" or 
		   breed_name == "cultist_gunner" or breed_name == "chaos_ogryn_gunner" or
		   breed_name == "cultist_shocktrooper" then
			return mod.breed_colors.elite_ranged
		else
			return mod.breed_colors.elite_melee
		end
	elseif tags.special then
		if breed_name == "renegade_sniper" then
			return mod.breed_colors.special_sniper
		elseif breed_name == "chaos_hound" then
			return mod.breed_colors.special_pox_hound
		elseif breed_name == "renegade_netgunner" then
			return mod.breed_colors.special_trapper
		elseif breed_name == "cultist_flamer" or breed_name == "renegade_flamer" or 
		       breed_name == "cultist_mutant" or breed_name == "renegade_mutant" or
		       breed_name == "chaos_spawn" or breed_name == "cultist_berzerker" or
		       breed_name == "renegade_berzerker" or breed_name == "cultist_grenadier" or
		       breed_name == "renegade_grenadier" then
			-- These get the generic special color (flamers, mutants, berzerkers, grenadiers, etc.)
			return mod.breed_colors.special
		else
			return mod.breed_colors.special
		end
	elseif tags.monster then
		return mod.breed_colors.monster
	elseif tags.horde then
		return mod.breed_colors.horde
	elseif tags.roamer then
		return mod.breed_colors.roamer
	else
		return mod.breed_colors.default
	end
end

-- Function to check if unit is tagged by player or ally or has companion order
local function get_unit_tag_info(unit)
	if not unit then return nil, nil end
	
	-- Add safety checks to prevent crashes
	local success, result = pcall(function()
		if not Managers.state or not Managers.state.extension then
			return nil, nil
		end
		
		local smart_tag_system = Managers.state.extension:system("smart_tag_system")
		if not smart_tag_system then return nil, nil end
		
		local tag_id = smart_tag_system:unit_tag_id(unit)
		if not tag_id then return nil, nil end
		
		local tag = smart_tag_system:tag_by_id(tag_id)
		if not tag then return nil, nil end
		
		local template = tag:template()
		if not template then return nil, nil end
		
		-- Check if it's a companion order (arbites dog target)
		if template.companion_order then
			return "companion_order", tag
		end
		
		-- Check if it's a veteran tag
		if template.name == "enemy_over_here_veteran" then
			return "veteran_tag", tag
		end
		
		-- Check if it's a regular enemy tag
		if template.name == "enemy_over_here" then
			return "enemy_tag", tag
		end
		
		return nil, nil
	end)
	
	if success then
		return result
	else
		-- If any error occurs, just return nil safely
		return nil, nil
	end
end

-- Function to get tag border color based on tag type
local function get_tag_border_color(tag_type)
	if tag_type == "companion_order" then
		return { 255, 128, 0, 255 }  -- Purple
	elseif tag_type == "veteran_tag" then
		return { 255, 255, 255, 0 }  -- Yellow
	elseif tag_type == "enemy_tag" then
		return { 255, 255, 0, 0 }    -- Red
	end
	return { 255, 0, 0, 0 }  -- Black (default border)
end

local function get_health_gradient_color(health_percent, base_color, intensity)
	-- If health gradient is disabled, always return the pure base color
	if not show.health_gradient then
		return base_color
	end
	
	-- If intensity is 0, return pure base color
	if intensity <= 0 then
		return base_color
	end
	
	-- Clamp health percent
	health_percent = math.max(0, math.min(1, health_percent))
	
	-- Define health gradient colors (RGB)
	local full_health = { 0, 255, 0 }    -- Green
	local mid_health = { 255, 255, 0 }   -- Yellow  
	local low_health = { 255, 0, 0 }     -- Red
	
	local gradient_color
	
	if health_percent > 0.5 then
		-- Interpolate between green and yellow (100% to 50% health)
		local t = (health_percent - 0.5) * 2  -- Convert to 0-1 range
		gradient_color = {
			math.floor(mid_health[1] * (1 - t) + full_health[1] * t),
			math.floor(mid_health[2] * (1 - t) + full_health[2] * t),
			math.floor(mid_health[3] * (1 - t) + full_health[3] * t)
		}
	else
		-- Interpolate between red and yellow (50% to 0% health)
		local t = health_percent * 2  -- Convert to 0-1 range
		gradient_color = {
			math.floor(low_health[1] * (1 - t) + mid_health[1] * t),
			math.floor(low_health[2] * (1 - t) + mid_health[2] * t),
			math.floor(low_health[3] * (1 - t) + mid_health[3] * t)
		}
	end
	
	-- Blend gradient color with base breed color based on intensity
	local blend_factor = intensity / 100
	local final_color = {
		math.floor(base_color[1] * (1 - blend_factor) + gradient_color[1] * blend_factor),
		math.floor(base_color[2] * (1 - blend_factor) + gradient_color[2] * blend_factor),
		math.floor(base_color[3] * (1 - blend_factor) + gradient_color[3] * blend_factor)
	}
	
	return final_color
end

-- Function to get enemy display name
local function get_enemy_display_name(unit)
	if not unit then return "Unknown" end
	
	-- Add safety wrapper to prevent crashes
	local success, name = pcall(function()
		local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
		if not unit_data_extension then return "Unknown" end
		
		local breed = unit_data_extension:breed()
		if not breed then return "Unknown" end
		
		-- Check for boss display name first
		local boss_extension = ScriptUnit.has_extension(unit, "boss_system")
		if boss_extension then
			local boss_name = boss_extension:display_name()
			if boss_name then
				local success, localized_name = pcall(Localize, boss_name)
				if success then
					return localized_name
				end
			end
		end
		
		-- Check for smart tag display name
		local smart_tag_extension = ScriptUnit.has_extension(unit, "smart_tag_system")
		if smart_tag_extension then
			local smart_tag_name = smart_tag_extension:display_name()
			if smart_tag_name and smart_tag_name ~= "n/a" then
				local success, localized_name = pcall(Localize, smart_tag_name)
				if success then
					return localized_name
				end
			end
		end
		
		-- Fall back to breed display name
		if breed.display_name then
			local success, localized_name = pcall(Localize, breed.display_name)
			if success then
				return localized_name
			end
		end
		
		-- Last resort: use breed name and clean it up
		local clean_name = breed.name or "Unknown"
		clean_name = string.gsub(clean_name, "_", " ")
		clean_name = string.gsub(clean_name, "(%a)([%w_']*)", function(first, rest) 
			return string.upper(first) .. string.lower(rest) 
		end)
		
		return clean_name
	end)
	
	if success then
		return name
	else
		return "Enemy"  -- Safe fallback
	end
end

-- ===== SIMPLIFIED UNIT CHECKING =====

local function should_enable_healthbar(unit)
	if not unit then return false end
	
	-- Check game mode - exclude shooting range unless creature spawner is present
	local game_mode_name = Managers.state.game_mode:game_mode_name()
	if game_mode_name == "shooting_range" and not get_mod("creature_spawner") then
		return false
	end

	local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
	if not unit_data_extension then return false end
	
	local breed = unit_data_extension:breed()
	if not breed or not breed.tags or not breed.tags.minion then return false end
	
	local tags = breed.tags
	
	-- Simple checks based on settings - FIXED: Add cultist_captain check
	if (tags.captain or tags.cultist_captain) and show.show_captain then return true end
	if tags.monster and show.show_monster then return true end
	if tags.elite and show.show_elite then return true end
	if tags.special and show.show_special then return true end
	if tags.horde and show.show_horde then return true end
	if tags.roamer and show.show_roamer then return true end
	
	return false
end

-- ===== TEMPLATE SETUP =====

local template = {}
-- Dynamic size based on settings
local function get_current_size()
	return { 
		mod:get("healthbar_width") or 120, 
		mod:get("healthbar_height") or 6 
	}
end

template.size = get_current_size()
template.name = "color_coded_healthbar"
template.unit_node = "j_head"
-- Dynamic position offset based on settings
template.position_offset = { 0, 0, 0.35 }
-- NEW: Enable line of sight checking like the default health bar template
template.check_line_of_sight = true  -- This is the key setting!
template.max_distance = 100
template.screen_clamp = false
template.disable_distance_scaling = true

template.bar_settings = {
	alpha_fade_delay = 2.6,
	alpha_fade_duration = 0.6,
	alpha_fade_min_value = 50,
	animate_on_health_increase = true,
	bar_spacing = 2,
	duration_health = 1,
	duration_health_ghost = 7,
	health_animation_threshold = 0.1,
}

template.fade_settings = {
	default_fade = 0,
	fade_from = 0,
	fade_to = 1,
	distance_max = 100,
	distance_min = 50,
	easing_function = function(t) return t end,  -- Simple linear easing
}

local function get_toggles()
	-- Use proper nil checking instead of 'or' defaults to handle false values correctly
	local function get_setting_bool(setting_name, default_value)
		local value = mod:get(setting_name)
		if value == nil then
			return default_value
		end
		return value
	end
	
	local function get_setting_num(setting_name, default_value)
		local value = mod:get(setting_name)
		if value == nil then
			return default_value
		end
		return value
	end
	
	local function get_setting_str(setting_name, default_value)
		local value = mod:get(setting_name)
		if value == nil then
			return default_value
		end
		return value
	end
	
	-- Breed type toggles - properly handle false values
	show.show_horde = get_setting_bool("show_horde", false)
	show.show_roamer = get_setting_bool("show_roamer", false)
	show.show_elite = get_setting_bool("show_elite", true)
	show.show_special = get_setting_bool("show_special", true)
	show.show_monster = get_setting_bool("show_monster", true)
	show.show_captain = get_setting_bool("show_captain", true)
	show.always_show_healthbars = get_setting_bool("always_show_healthbars", false)
	show.show_enemy_names = get_setting_bool("show_enemy_names", false)
	show.show_damage_numbers = get_setting_bool("show_damage_numbers", false)
	show.show_names_only = get_setting_bool("show_names_only", false)  -- NEW: Names only mode
	
	-- Priority system settings
	show.max_healthbars_shown = get_setting_num("max_healthbars_shown", 8)
	show.hide_full_health = get_setting_bool("hide_full_health", false)
	show.priority_system = get_setting_bool("priority_system", true)
	show.show_tag_indicators = get_setting_bool("show_tag_indicators", false)
	show.show_health_indicator = get_setting_bool("show_health_indicator", false)
	
	-- NEW: Visibility settings
	show.enable_visibility_check = get_setting_bool("enable_visibility_check", true)
	show.visibility_fade_speed = get_setting_num("visibility_fade_speed", 3.0)
	show.visibility_behind_walls = get_setting_bool("visibility_behind_walls", false)
	
	-- Numeric settings
	show.max_display_range = get_setting_num("max_display_range", 50)
	show.healthbar_width = get_setting_num("healthbar_width", 120)
	show.healthbar_height = get_setting_num("healthbar_height", 6)
	show.text_size = get_setting_num("text_size", 20)
	show.text_offset_y = get_setting_num("text_offset_y", 8)
	show.bar_offset_y = get_setting_num("bar_offset_y", 0)
	show.bar_border_thickness = get_setting_num("bar_border_thickness", 1)
	show.background_opacity = get_setting_num("background_opacity", 180)
	show.gradient_intensity = get_setting_num("gradient_intensity", 75)
	
	-- More boolean settings
	show.bar_border_enabled = get_setting_bool("bar_border_enabled", true)
	show.text_shadow_enabled = get_setting_bool("text_shadow_enabled", true)
	show.text_outline_enabled = get_setting_bool("text_outline_enabled", false)
	show.health_gradient = get_setting_bool("health_gradient", true)
	show.smooth_animations = get_setting_bool("smooth_animations", true)
	
	-- String settings
	show.bar_corner_style = get_setting_str("bar_corner_style", "standard")
	
	-- Update template size and position
	template.size = { show.healthbar_width, show.healthbar_height }
	template.position_offset = { 0, 0, 0.35 + (show.bar_offset_y / 100) }
	
	-- NEW: Update visibility settings on template
	template.check_line_of_sight = show.enable_visibility_check
	
	local max_distance = show.always_show_healthbars and math.max(show.max_display_range, 100) or show.max_display_range
	
	template.max_distance = max_distance
	template.fade_settings.distance_max = max_distance
	template.fade_settings.distance_min = max_distance * 0.5
	
	-- Update animation settings based on smooth_animations
	if show.smooth_animations then
		template.bar_settings.alpha_fade_delay = show.always_show_healthbars and 10.0 or 2.6
		template.bar_settings.alpha_fade_duration = 0.6
		template.bar_settings.alpha_fade_min_value = show.always_show_healthbars and 200 or 50
		template.fade_settings.default_fade = show.always_show_healthbars and 1 or 0
	else
		template.bar_settings.alpha_fade_delay = 0.1
		template.bar_settings.alpha_fade_duration = 0.1
		template.bar_settings.alpha_fade_min_value = show.always_show_healthbars and 255 or 100
		template.fade_settings.default_fade = show.always_show_healthbars and 1 or 0
	end
	
	update_colors_from_settings()
end

template.create_widget_defintion = function(template, scenegraph_id)
	-- Use cached settings instead of calling mod:get() during widget creation
	local bar_width = show.healthbar_width
	local bar_height = show.healthbar_height
	local font_size = show.text_size
	local text_offset = show.text_offset_y
	
	-- Get visual enhancement settings from cache
	local border_enabled = show.bar_border_enabled
	local border_thickness = show.bar_border_thickness
	local bg_opacity = show.background_opacity
	local text_shadow = show.text_shadow_enabled
	local text_outline = show.text_outline_enabled
	local bar_style = show.bar_corner_style
	
	local size = { bar_width, bar_height }
	local bar_size = { size[1], size[2] }
	local bar_offset = { -size[1] * 0.5, 0, 0 }
	
	-- Calculate border offsets (always calculate, control visibility later)
	local border_thickness_val = border_thickness or 1
	local border_size = { size[1] + border_thickness_val * 2, size[2] + border_thickness_val * 2 }
	local border_pos = { bar_offset[1] - border_thickness_val, bar_offset[2] - border_thickness_val, 0 }
	
	-- Use cached setting for name visibility
	local show_names = show.show_enemy_names
	
	-- Font settings for enemy names with enhancements
	local font_settings = UIFontSettings.nameplates or UIFontSettings.hud_body
	local name_text_style = {
		font_size = font_size,
		font_type = font_settings.font_type or "proxima_nova_bold",
		horizontal_alignment = "center",
		text_horizontal_alignment = "center",
		text_vertical_alignment = "bottom",
		vertical_alignment = "center",
		text_color = { show_names and 255 or 0, 255, 255, 255 },
		offset = { 0, size[2] + text_offset, 6 },
		size = { size[1] + 40, math.max(25, font_size + 5) },
		drop_shadow = text_shadow,
	}
	
	-- Add text outline if enabled
	if text_outline then
		name_text_style.drop_shadow = true
	end

	local widget_passes = {}
	
	-- ALWAYS add border (control visibility in update function)
	table.insert(widget_passes, {
		pass_type = "rect",
		style_id = "border",
		value = "content/ui/materials/backgrounds/default_square",
		style = {
			vertical_alignment = "center",
			offset = { border_pos[1], border_pos[2], 0 },
			size = border_size,
			color = { 0, 0, 0, 0 },  -- Initially invisible (will be set in update)
		},
	})
	
	-- Add tag border (always present, but initially invisible)
	table.insert(widget_passes, {
		pass_type = "rect",
		style_id = "tag_border",
		value = "content/ui/materials/backgrounds/default_square",
		style = {
			vertical_alignment = "center",
			offset = { border_pos[1] - 1, border_pos[2] - 1, -1 },  -- Slightly larger and behind
			size = { border_size[1] + 2, border_size[2] + 2 },
			color = { 0, 255, 0, 0 },  -- Initially invisible red
		},
	})
	
	-- Background
	table.insert(widget_passes, {
		pass_type = "rect",
		style_id = "background",
		value = "content/ui/materials/backgrounds/default_square",
		style = {
			vertical_alignment = "center",
			offset = { bar_offset[1], bar_offset[2], 1 },
			size = bar_size,
			color = { bg_opacity, 60, 60, 60 },
		},
	})
	
	-- Health bar - use different materials based on style
	local bar_material = "content/ui/materials/backgrounds/default_square"
	if bar_style == "capped" then
		-- Use a material with rounded end caps if available
		bar_material = "content/ui/materials/bars/simple/fill"
	end
	
	table.insert(widget_passes, {
		pass_type = "rect",
		style_id = "bar",
		value = bar_material,
		style = {
			vertical_alignment = "center",
			offset = { bar_offset[1], bar_offset[2], 3 },
			size = bar_size,
			color = { 255, 255, 255, 255 },
		},
	})
	
	-- Add end caps if using capped style
	if bar_style == "capped" then
		-- Left end cap
		table.insert(widget_passes, {
			pass_type = "texture",
			style_id = "bar_end_left",
			value = "content/ui/materials/bars/simple/end",
			style = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				offset = { bar_offset[1] - 6, bar_offset[2], 4 },
				size = { 12, bar_size[2] + 4 },
				color = { 255, 255, 255, 255 },
			},
		})
		
		-- Right end cap
		table.insert(widget_passes, {
			pass_type = "texture",
			style_id = "bar_end_right",
			value = "content/ui/materials/bars/simple/end",
			style = {
				horizontal_alignment = "right",
				vertical_alignment = "center",
				offset = { bar_offset[1] + bar_size[1] - 6, bar_offset[2], 4 },
				size = { 12, bar_size[2] + 4 },
				color = { 255, 255, 255, 255 },
			},
		})
	end
	
	-- Always include name text element
	table.insert(widget_passes, {
		pass_type = "text",
		style_id = "name_text",
		value = "Enemy",
		value_id = "name_text",
		style = name_text_style,
	})
	
	-- Add tag indicator text (for showing [TAGGED] or [DOG] indicators)
	table.insert(widget_passes, {
		pass_type = "text",
		style_id = "tag_indicator",
		value = "",
		value_id = "tag_indicator",
		style = {
			font_size = math.max(12, font_size - 4),
			font_type = font_settings.font_type or "proxima_nova_bold",
			horizontal_alignment = "center",
			text_horizontal_alignment = "center",
			text_vertical_alignment = "top",
			vertical_alignment = "center",
			text_color = { 0, 255, 255, 0 },  -- Cyan color for tags, initially invisible
			offset = { 0, -(size[2] + text_offset + 4), 7 },  -- Above the name text
			size = { size[1] + 40, math.max(20, font_size) },
			drop_shadow = text_shadow,
		},
	})
	
	-- Add health indicator (white line at current HP position)
	table.insert(widget_passes, {
		pass_type = "rect",
		style_id = "health_indicator",
		value = "content/ui/materials/backgrounds/default_square",
		style = {
			vertical_alignment = "center",
			offset = { bar_offset[1], bar_offset[2], 4 },  -- On top of health bar
			size = { 2, bar_size[2] + 2 },  -- Thin white line, slightly taller than bar
			color = { 0, 255, 255, 255 },  -- Initially invisible white
		},
	})

	return UIWidget.create_definition(widget_passes, scenegraph_id)
end

template.on_enter = function(widget, marker, template)
	local content = widget.content
	content.spawn_progress_timer = 0
	local bar_settings = template.bar_settings
	marker.bar_logic = HudHealthBarLogic:new(bar_settings)
	
	-- Apply initial breed-specific color with safety check
	if marker.unit then
		local success, color = pcall(mod.get_breed_color, marker.unit)
		if success and color and widget.style and widget.style.bar then
			widget.style.bar.color[1] = 255
			widget.style.bar.color[2] = color[1]
			widget.style.bar.color[3] = color[2]
			widget.style.bar.color[4] = color[3]
		end
	end
	
	-- Always set enemy name since text element is always present
	if widget.content and marker.unit then
		local enemy_name = get_enemy_display_name(marker.unit)
		widget.content.name_text = enemy_name
	end
	
	-- Set initial visibility based on cached setting
	if widget.style and widget.style.name_text and widget.style.name_text.color then
		widget.style.name_text.color[1] = show.show_enemy_names and 255 or 0
	end
	
	-- Set up tag indicator
	if widget.style and widget.style.tag_indicator and widget.style.tag_indicator.color then
		widget.style.tag_indicator.color[1] = 0  -- Initially invisible
		widget.content.tag_indicator = ""
	end
	
	-- Set up tag border (initially invisible)
	if widget.style and widget.style.tag_border then
		widget.style.tag_border.color[1] = 0  -- Initially invisible
	end
	
	-- Set up regular border (initially invisible, will be controlled in update)
	if widget.style and widget.style.border then
		widget.style.border.color[1] = 0  -- Initially invisible
	end
	
	-- Set up health indicator (initially invisible)
	if widget.style and widget.style.health_indicator then
		widget.style.health_indicator.color[1] = 0  -- Initially invisible
	end
end

-- Enhanced template update function with VISIBILITY CHECK IMPLEMENTATION
template.update_function = function(parent, ui_renderer, widget, marker, template, dt, t)
	local content = widget.content
	local style = widget.style
	local unit = marker.unit
	local health_extension = ScriptUnit.has_extension(unit, "health_system")
	local health_percent = health_extension and health_extension:current_health_percent() or 0
	local bar_logic = marker.bar_logic
	
	-- Hide healthbar if enemy is at full health and setting is enabled
	if show.hide_full_health and health_percent >= 1 then
		widget.alpha_multiplier = 0
		return
	end
	
	-- NEW: Names only mode - hide health bar elements but keep names visible
	local names_only_mode = show.show_names_only
	if names_only_mode then
		-- Force enemy names to be visible in names-only mode
		if style.name_text and style.name_text.color then
			style.name_text.color[1] = 255  -- Make name visible
			if content and not content.name_text then
				content.name_text = get_enemy_display_name(unit)
			end
		end
		
		-- Hide all health bar related elements
		if style.bar then style.bar.color[1] = 0 end
		if style.background then style.background.color[1] = 0 end
		if style.border then style.border.color[1] = 0 end
		if style.health_indicator then style.health_indicator.color[1] = 0 end
		if style.bar_end_left then style.bar_end_left.color[1] = 0 end
		if style.bar_end_right then style.bar_end_right.color[1] = 0 end
		
		-- Still process tag indicators in names-only mode
		local tag_type, tag_obj = get_unit_tag_info(unit)
		if style.tag_border then
			if show.show_tag_indicators and tag_type then
				local border_color = get_tag_border_color(tag_type)
				style.tag_border.color[1] = 255
				style.tag_border.color[2] = border_color[2]
				style.tag_border.color[3] = border_color[3]
				style.tag_border.color[4] = border_color[4]
			else
				style.tag_border.color[1] = 0
			end
		end
		
		if style.tag_indicator and style.tag_indicator.color and content then
			if show.show_tag_indicators and tag_type then
				if tag_type == "companion_order" then
					content.tag_indicator = "[DOG]"
					style.tag_indicator.color[1] = 255
					style.tag_indicator.color[2] = 255
					style.tag_indicator.color[3] = 255
					style.tag_indicator.color[4] = 0
				elseif tag_type == "veteran_tag" then
					content.tag_indicator = "[VET]"
					style.tag_indicator.color[1] = 255
					style.tag_indicator.color[2] = 255
					style.tag_indicator.color[3] = 255
					style.tag_indicator.color[4] = 0
				elseif tag_type == "enemy_tag" then
					content.tag_indicator = "[TAGGED]"
					style.tag_indicator.color[1] = 255
					style.tag_indicator.color[2] = 0
					style.tag_indicator.color[3] = 255
					style.tag_indicator.color[4] = 255
				end
			else
				content.tag_indicator = ""
				style.tag_indicator.color[1] = 0
			end
		end
		
		return  -- Skip normal health bar processing
	end
	
	-- Remove marker if unit is dead
	if not health_extension or not health_extension:is_alive() then
		marker.remove = true
		return
	end

	-- Update health bar logic
	bar_logic:update(dt, t, health_percent)
	local health_fraction, health_ghost_fraction, health_max_fraction = bar_logic:animated_health_fractions()

	if health_fraction and style.bar then
		-- Use cached settings instead of calling mod:get() every frame
		local base_size = show.healthbar_width
		local default_width_offset = -base_size * 0.5
		
		-- Clamp health fraction
		health_fraction = math.max(0, math.min(1, health_fraction or 0))
		
		-- Calculate health bar width
		local health_width = health_fraction * base_size
		health_width = math.max(0, math.min(base_size, health_width))

		-- Update size and position
		style.bar.size[1] = health_width
		style.bar.offset[1] = default_width_offset

		if style.background then
			style.background.size[1] = base_size
			style.background.offset[1] = default_width_offset
			style.background.color[1] = 180  -- Background always visible
		end

		-- Apply current colors with health-based gradient
		if marker.unit then
			local success, base_color = pcall(mod.get_breed_color, marker.unit)
			if success and base_color then
				local gradient_intensity = show.gradient_intensity
				local final_color = get_health_gradient_color(health_percent, base_color, gradient_intensity)
				
				style.bar.color[1] = 255           -- Full alpha
				style.bar.color[2] = final_color[1]  -- R
				style.bar.color[3] = final_color[2]  -- G
				style.bar.color[4] = final_color[3]  -- B
				
				-- Update end caps if they exist
				if style.bar_end_left then
					style.bar_end_left.color[1] = 255
					style.bar_end_left.color[2] = final_color[1]
					style.bar_end_left.color[3] = final_color[2]
					style.bar_end_left.color[4] = final_color[3]
				end
				
				if style.bar_end_right then
					style.bar_end_right.color[1] = 255
					style.bar_end_right.color[2] = final_color[1]
					style.bar_end_right.color[3] = final_color[2]
					style.bar_end_right.color[4] = final_color[3]
				end
			end
		end
	end
	
	-- ===== NEW: VISIBILITY CHECK IMPLEMENTATION =====
	-- This mimics the line of sight system from the default health bar template
	local line_of_sight_progress = content.line_of_sight_progress or 0
	
	if show.enable_visibility_check then
		-- Check if the marker has raycast data (provided by the world marker system)
		if marker.raycast_initialized then
			local raycast_result = marker.raycast_result
			local visibility_speed = show.visibility_fade_speed
			
			if raycast_result then
				-- Enemy is behind a wall/obstacle - fade out
				line_of_sight_progress = math.max(line_of_sight_progress - dt * visibility_speed, 0)
			else
				-- Enemy is visible - fade in
				line_of_sight_progress = math.min(line_of_sight_progress + dt * visibility_speed, 1)
			end
		end
		
		-- Store the progress for next frame
		content.line_of_sight_progress = line_of_sight_progress
		
		-- Apply visibility to the entire widget
		if not show.visibility_behind_walls then
			-- Completely hide when behind walls
			widget.alpha_multiplier = line_of_sight_progress
		else
			-- Reduce opacity but don't completely hide
			widget.alpha_multiplier = math.max(line_of_sight_progress, 0.1)
		end
	else
		-- Visibility check disabled - always show at full opacity
		widget.alpha_multiplier = 1.0
		content.line_of_sight_progress = 1.0
	end
	
	-- Update border visibility based on cached setting
	if style.border then
		if show.bar_border_enabled then
			style.border.color[1] = 255  -- Make border visible
			style.border.color[2] = 0    -- Black color
			style.border.color[3] = 0
			style.border.color[4] = 0
		else
			style.border.color[1] = 0    -- Make border invisible
		end
	end
	
	-- Update enemy name visibility based on cached settings
	if style.name_text and style.name_text.color then
		if show.show_enemy_names or show.show_names_only then  -- UPDATED: Show names in both modes
			style.name_text.color[1] = 255  -- Make visible
			-- Update name if it has changed
			if content and not content.name_text then
				content.name_text = get_enemy_display_name(unit)
			end
		else
			style.name_text.color[1] = 0  -- Make invisible
		end
	end
	
	-- Update tag indicator visibility and content with safety checks
	local tag_type, tag_obj = get_unit_tag_info(unit)
	
	-- Update tag border based on tag status AND show_tag_indicators setting
	if style.tag_border then
		if show.show_tag_indicators and tag_type then
			local border_color = get_tag_border_color(tag_type)
			style.tag_border.color[1] = 255  -- Make visible
			style.tag_border.color[2] = border_color[2]
			style.tag_border.color[3] = border_color[3]
			style.tag_border.color[4] = border_color[4]
		else
			style.tag_border.color[1] = 0  -- Make invisible
		end
	end
	
	if style.tag_indicator and style.tag_indicator.color and content then
		if show.show_tag_indicators then
			if tag_type then
				if tag_type == "companion_order" then
					content.tag_indicator = "[DOG]"
					style.tag_indicator.color[1] = 255  -- Full visibility
					style.tag_indicator.color[2] = 255  -- Bright yellow
					style.tag_indicator.color[3] = 255
					style.tag_indicator.color[4] = 0
				elseif tag_type == "veteran_tag" then
					content.tag_indicator = "[VET]"
					style.tag_indicator.color[1] = 255  -- Full visibility
					style.tag_indicator.color[2] = 255  -- Yellow
					style.tag_indicator.color[3] = 255
					style.tag_indicator.color[4] = 0
				elseif tag_type == "enemy_tag" then
					content.tag_indicator = "[TAGGED]"
					style.tag_indicator.color[1] = 255  -- Full visibility
					style.tag_indicator.color[2] = 0    -- Cyan
					style.tag_indicator.color[3] = 255
					style.tag_indicator.color[4] = 255
				end
			else
				content.tag_indicator = ""
				style.tag_indicator.color[1] = 0  -- Make invisible
			end
		else
			content.tag_indicator = ""
			style.tag_indicator.color[1] = 0  -- Make invisible
		end
	end
	
	-- Update health indicator visibility and position
	if style.health_indicator and health_fraction then
		if show.show_health_indicator then
			-- Position the indicator at the end of current health
			local base_size = show.healthbar_width
			local default_width_offset = -base_size * 0.5
			local health_width = health_fraction * base_size
			local indicator_x_pos = default_width_offset + health_width - 1  -- Subtract 1 to center the 2px line
			
			style.health_indicator.color[1] = 255  -- Make visible
			style.health_indicator.color[2] = 255  -- White color
			style.health_indicator.color[3] = 255
			style.health_indicator.color[4] = 255
			style.health_indicator.offset[1] = indicator_x_pos
		else
			style.health_indicator.color[1] = 0  -- Make invisible
		end
	end
end

-- ===== INITIALIZE =====
get_toggles()

-- ===== SETTINGS HANDLER =====

mod.on_setting_changed = function()
	get_toggles()
	
	-- Simple approach: just update the template settings immediately
	-- The existing markers will pick up the changes in their next update cycle
	template.size = { show.healthbar_width, show.healthbar_height }
	template.position_offset = { 0, 0, 0.35 + (show.bar_offset_y / 100) }
	
	-- Update visibility setting
	template.check_line_of_sight = show.enable_visibility_check
	
	local max_distance = show.always_show_healthbars and math.max(show.max_display_range, 100) or show.max_display_range
	template.max_distance = max_distance
	template.fade_settings.distance_max = max_distance
	template.fade_settings.distance_min = max_distance * 0.5
	
	-- Update animation settings based on smooth_animations
	if show.smooth_animations then
		template.bar_settings.alpha_fade_delay = show.always_show_healthbars and 10.0 or 2.6
		template.bar_settings.alpha_fade_duration = 0.6
		template.bar_settings.alpha_fade_min_value = show.always_show_healthbars and 200 or 50
		template.fade_settings.default_fade = show.always_show_healthbars and 1 or 0
	else
		template.bar_settings.alpha_fade_delay = 0.1
		template.bar_settings.alpha_fade_duration = 0.1
		template.bar_settings.alpha_fade_min_value = show.always_show_healthbars and 255 or 100
		template.fade_settings.default_fade = show.always_show_healthbars and 1 or 0
	end
end

-- Register template with world markers system
mod:hook_safe("HudElementWorldMarkers", "init", function(self)
	self._marker_templates[template.name] = template
end)

-- Simple initialization hooks like the working mod
mod:hook_safe("HealthExtension", "init", function(_self, _extension_init_context, unit, _extension_init_data, _game_object_data)
	-- Add custom healthbar marker
	if should_enable_healthbar(unit) then
		Managers.event:trigger("add_world_marker_unit", template.name, unit)
	end
end)

mod:hook_safe("HuskHealthExtension", "init", function(self, _extension_init_context, unit, _extension_init_data, _game_session, _game_object_id, _owner_id)
	-- Make sure husks have the methods needed
	self.set_last_damaging_unit = HealthExtension.set_last_damaging_unit
	self.last_damaging_unit = HealthExtension.last_damaging_unit
	self.last_hit_zone_name = HealthExtension.last_hit_zone_name
	self.last_hit_was_critical = HealthExtension.last_hit_was_critical
	self.was_hit_by_critical_hit_this_render_frame = HealthExtension.was_hit_by_critical_hit_this_render_frame

	-- Set has a healthbar
	if should_enable_healthbar(unit) then
		Managers.event:trigger("add_world_marker_unit", template.name, unit)
	end
end)

-- ===== SCAN FOR EXISTING UNITS ON JOIN =====

-- Timer to scan for existing units when joining a game in progress
local scan_timer = 0
local scan_interval = 1.0  -- Scan every second
local initial_scan_done = false
local max_initial_scans = 10  -- Stop scanning after 10 attempts

-- Function to scan existing units and add healthbars
local function scan_existing_units()
	local added_count = 0
	
	-- Check if minion spawn manager is available
	if not Managers.state or not Managers.state.minion_spawn then
		return 0
	end
	
	local spawned_minions = Managers.state.minion_spawn:spawned_minions()
	if not spawned_minions then
		return 0
	end
	
	-- Check all spawned minions
	for i = 1, #spawned_minions do
		local unit = spawned_minions[i]
		if unit and HEALTH_ALIVE[unit] then
			if should_enable_healthbar(unit) then
				-- Check if this unit already has a healthbar marker
				local has_marker = false
				
				-- Simple check: try to add marker, if it already exists it won't duplicate
				local success = pcall(function()
					Managers.event:trigger("add_world_marker_unit", template.name, unit)
				end)
				
				if success then
					added_count = added_count + 1
				end
			end
		end
	end
	
	return added_count
end

-- ===== COMMANDS =====

mod:command("cc_test", "Test color coded healthbars", function()
	mod:echo("Color Coded Healthbars (Standalone with Visibility) loaded!")
	mod:echo("Show enemy names: " .. tostring(show.show_enemy_names))
	mod:echo("Show tag indicators: " .. tostring(show.show_tag_indicators))
	mod:echo("Show health indicator: " .. tostring(show.show_health_indicator))
	
	-- NEW: Show visibility settings
	mod:echo("Visibility Settings:")
	mod:echo("  Enable visibility check: " .. tostring(show.enable_visibility_check))
	mod:echo("  Visibility fade speed: " .. show.visibility_fade_speed)
	mod:echo("  Show behind walls: " .. tostring(show.visibility_behind_walls))
	
	mod:echo("Visual Settings:")
	mod:echo("  Bar size: " .. show.healthbar_width .. "x" .. show.healthbar_height .. " pixels")
	mod:echo("  Text size: " .. show.text_size .. " pixels")
	mod:echo("  Text offset: " .. show.text_offset_y .. " pixels")
	mod:echo("  Bar Y offset: " .. show.bar_offset_y .. " pixels")
	
	mod:echo("Visual Enhancements:")
	mod:echo("  Borders: " .. tostring(show.bar_border_enabled) .. " (thickness: " .. show.bar_border_thickness .. ")")
	mod:echo("  Background opacity: " .. show.background_opacity)
	mod:echo("  Bar style: " .. show.bar_corner_style)
	mod:echo("  Text shadow: " .. tostring(show.text_shadow_enabled))
	mod:echo("  Text outline: " .. tostring(show.text_outline_enabled))
	mod:echo("  Health gradient: " .. tostring(show.health_gradient) .. " (intensity: " .. show.gradient_intensity .. "%%)")
	mod:echo("  Smooth animations: " .. tostring(show.smooth_animations))
	
	mod:echo("Current breed type toggles:")
	for setting, value in pairs(show) do
		if string.find(setting, "show_") and setting ~= "show_enemy_names" and setting ~= "show_damage_numbers" then
			mod:echo("  " .. setting .. ": " .. tostring(value))
		end
	end
	
	mod:echo("FIXED: Captain color formula now uses all RGB components!")
	mod:echo("FIXED: Cultist captains now properly detected!")
end)

mod:command("cc_scan", "Scan for existing units and add healthbars", function()
	mod:echo("=== Manual Scan Starting ===")
	local added = scan_existing_units()
	mod:echo("=== Manual Scan Complete ===")
	if added > 0 then
		mod:echo("Added healthbars to " .. added .. " existing enemies")
	else
		mod:echo("No new enemies found or all enemies already have healthbars")
	end
end)

mod:command("cc_reset_scan", "Reset the scanning system", function()
	initial_scan_done = false
	max_initial_scans = 10
	scan_timer = 0
	mod:echo("Scanning system reset - will resume automatic scanning")
end)

mod:command("cc_tags", "Test tag indicator system", function()
	mod:echo("=== Tag Indicator System Test ===")
	mod:echo("Tag indicators enabled: " .. tostring(show.show_tag_indicators))
	
	local smart_tag_system = Managers.state.extension:system("smart_tag_system")
	if not smart_tag_system then
		mod:echo("Smart tag system not available")
		return
	end
	
	mod:echo("Tag system is available. Try tagging an enemy (T key) or commanding your arbites dog!")
end)

-- NEW: Command to test visibility system
mod:command("cc_visibility", "Test visibility system", function()
	mod:echo("=== Visibility System Test ===")
	mod:echo("Visibility check enabled: " .. tostring(show.enable_visibility_check))
	mod:echo("Fade speed: " .. show.visibility_fade_speed)
	mod:echo("Show behind walls: " .. tostring(show.visibility_behind_walls))
	mod:echo("Template line of sight: " .. tostring(template.check_line_of_sight))
	
	if show.enable_visibility_check then
		mod:echo("Healthbars should fade out when enemies are behind walls!")
	else
		mod:echo("Visibility checking is disabled - healthbars always visible")
	end
end)

-- NEW: Command to test pox hound and trapper separation
mod:command("cc_disablers", "Test Pox Hound and Trapper color separation", function()
	mod:echo("=== Pox Hound vs Trapper Color Test ===")
	mod:echo("Pox Hound (chaos_hound) color (R,G,B): " .. mod.breed_colors.special_pox_hound[1] .. "," .. mod.breed_colors.special_pox_hound[2] .. "," .. mod.breed_colors.special_pox_hound[3])
	mod:echo("Trapper (renegade_netgunner) color (R,G,B): " .. mod.breed_colors.special_trapper[1] .. "," .. mod.breed_colors.special_trapper[2] .. "," .. mod.breed_colors.special_trapper[3])
	mod:echo("Generic disabler color (R,G,B): " .. mod.breed_colors.special_disabler[1] .. "," .. mod.breed_colors.special_disabler[2] .. "," .. mod.breed_colors.special_disabler[3])
	mod:echo("SEPARATED: Pox Hounds and Trappers now have individual color controls!")
	mod:echo("Check 'Special Subcategory Colors' in mod settings to customize each one independently.")
end)
mod:command("cc_names", "Test names-only mode", function()
	mod:echo("=== Names Only Mode Test ===")
	mod:echo("Names only mode: " .. tostring(show.show_names_only))
	mod:echo("Show enemy names: " .. tostring(show.show_enemy_names))
	mod:echo("Show tag indicators: " .. tostring(show.show_tag_indicators))
	
	if show.show_names_only then
		mod:echo("Names-only mode is ACTIVE - health bars are hidden!")
		mod:echo("Enemy names will be visible with tag indicators if enabled")
	else
		mod:echo("Names-only mode is DISABLED - normal health bars shown")
	end
end)
mod:command("cc_captain", "Test captain color system", function()
	mod:echo("=== Captain Color System Test ===")
	mod:echo("Monster color (R,G,B): " .. (mod:get("monster_color_r") or 255) .. "," .. (mod:get("monster_color_g") or 0) .. "," .. (mod:get("monster_color_b") or 0))
	mod:echo("Captain color (R,G,B): " .. mod.breed_colors.captain[1] .. "," .. mod.breed_colors.captain[2] .. "," .. mod.breed_colors.captain[3])
	mod:echo("Captain detection tags: captain=" .. tostring(show.show_captain) .. ", cultist_captain support=ENABLED")
	mod:echo("FIXED: Now properly detects both 'captain' and 'cultist_captain' tags!")
	mod:echo("FIXED: Captain color formula now divides ALL RGB components, not just red!")
end)

-- ===== KEYBIND FUNCTIONALITY =====

-- Function to perform manual refresh
local function manual_refresh_healthbars()
	mod:echo("=== Manual Refresh (Keybind) ===")
	local added = scan_existing_units()
	if added > 0 then
		mod:echo("Refreshed " .. added .. " healthbars")
	else
		mod:echo("All healthbars up to date")
	end
end

-- Hook into update to check for keybind input and handle scanning
local keybind_pressed_last_frame = false

mod:hook_safe("HudElementWorldMarkers", "update", function(self, dt, t, ui_renderer, render_settings, input_service)
	-- Only scan if we haven't completed initial scans yet
	if not initial_scan_done then
		scan_timer = scan_timer + dt
		
		if scan_timer >= scan_interval then
			scan_timer = 0
			
			local added = scan_existing_units()
			
			-- Reduce max scans each time
			max_initial_scans = max_initial_scans - 1
			
			-- Stop scanning if we added units or if we've tried enough times
			if added > 0 then
				initial_scan_done = true
				if added > 0 then
					mod:echo("Found " .. added .. " existing enemies and added healthbars")
				end
			elseif max_initial_scans <= 0 then
				initial_scan_done = true
				-- No message needed if no enemies found
			end
		end
	end
	
	-- Handle keybind input
	if input_service then
		local keybind_setting = mod:get("refresh_keybind")
		if keybind_setting and keybind_setting.key then
			local key_pressed = input_service:get(keybind_setting.key)
			
			-- Only trigger on key press (not while held)
			if key_pressed and not keybind_pressed_last_frame then
				local success = pcall(manual_refresh_healthbars)
				if not success then
					mod:echo("Error during manual refresh")
				end
			end
			
			keybind_pressed_last_frame = key_pressed
		end
	end
end)

-- Startup message
if mod:get("show_startup_messages") then
	mod:echo("Color Coded Healthbars (Standalone with Visibility) loaded!")
	mod:echo("FIXED: Captain color formula and cultist_captain detection!")
	mod:echo("NEW: Pox Hounds and Trappers now have separate color controls!")
	mod:echo("Simplified and reliable - works in both Meat Grinder and missions!")
	mod:echo("NEW: Line of sight visibility checking - healthbars fade when enemies are behind walls!")
	mod:echo("Enemy name display available - check mod settings")
	mod:echo("Tag indicators available - shows [TAGGED] and [DOG] markers")
	mod:echo("Type /cc_test to check mod status")
	mod:echo("Type /cc_captain to test captain color fixes")
end