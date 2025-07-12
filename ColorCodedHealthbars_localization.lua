local Breeds = require("scripts/settings/breed/breeds")

local localization = {
	mod_name = {
		en = "Color Coded Healthbars (Standalone)",
		["zh-cn"] = "彩色编码血条（独立版带可见性检查）",
		ru = "Цветные полоски здоровья (Автономные с проверкой видимости)",
	},
	mod_description = {
		en = "Show color-coded healthbars based on enemy breed type with subcategory support, enemy names, tag indicators, and line-of-sight visibility checking - No external dependencies required. Elite Ranged (Dark Orange), Elite Melee (Orange), Special Snipers (Pink), Special Disablers (Purple), Generic Specials (Magenta), etc.",
		["zh-cn"] = "根据敌人类型显示彩色编码血条，支持子类别、敌人名称、标签指示器和视线可见性检查 - 无需外部依赖。精英远程（深橙色），精英近战（橙色），专家狙击手（粉色），专家控制（紫色），通用专家（洋红色）等",
		ru = "Показывает цветные полоски здоровья на основе типа врага с поддержкой подкategorий, имен врагов, индикаторов тегов и проверки видимости - Не требует внешних зависимостей. Элитные дальние (Тёмно-оранжевый), Элитные ближние (Оранжевый), Снайперы (Розовый), Контроллеры (Фиолетовый), Обычные специалисты (Пурпурный) и т.д.",
	},
	general_settings = {
		en = "General Settings",
		["zh-cn"] = "常规设置",
		ru = "Общие настройки",
	},
	show_startup_messages = {
		en = "Show Startup Messages",
		["zh-cn"] = "显示启动消息",
		ru = "Показать сообщения запуска",
	},
	always_show_healthbars = {
		en = "Always Show Healthbars",
		["zh-cn"] = "始终显示血条",
		ru = "Всегда показывать полоски здоровья",
	},
	show_enemy_names = {
		en = "Show Enemy Names",
		["zh-cn"] = "显示敌人名称",
		ru = "Показать имена врагов",
	},
	show_tag_indicators = {
		en = "Show Tag Indicators",
		["zh-cn"] = "显示标签指示器",
		ru = "Показать индикаторы тегов",
	},
	max_healthbars_shown = {
		en = "Max Healthbars Shown",
		["zh-cn"] = "显示的最大血条数",
		ru = "Максимум полосок здоровья",
	},
	hide_full_health = {
		en = "Hide Full Health Enemies",
		["zh-cn"] = "隐藏满血敌人",
		ru = "Скрыть врагов с полным здоровьем",
	},
	priority_system = {
		en = "Smart Priority System",
		["zh-cn"] = "智能优先级系统",
		ru = "Умная система приоритетов",
	},
	max_display_range = {
		en = "Maximum Display Range",
		["zh-cn"] = "最大显示范围",
		ru = "Максимальная дальность отображения",
	},
	-- NEW: Visibility settings
	visibility_settings = {
		en = "Visibility Settings",
		["zh-cn"] = "可见性设置",
		ru = "Настройки видимости",
	},
	enable_visibility_check = {
		en = "Enable Line of Sight Check",
		["zh-cn"] = "启用视线检查",
		ru = "Включить проверку линии зрения",
	},
	visibility_fade_speed = {
		en = "Visibility Fade Speed",
		["zh-cn"] = "可见性渐变速度",
		ru = "Скорость исчезновения видимости",
	},
	visibility_behind_walls = {
		en = "Show Behind Walls",
		["zh-cn"] = "墙后显示",
		ru = "Показать за стенами",
	},
	visual_settings = {
		en = "Visual Settings",
		["zh-cn"] = "视觉设置",
		ru = "Визуальные настройки",
	},
	healthbar_width = {
		en = "Health Bar Width",
		["zh-cn"] = "血条宽度",
		ru = "Ширина полоски здоровья",
	},
	healthbar_height = {
		en = "Health Bar Height",
		["zh-cn"] = "血条高度",
		ru = "Высота полоски здоровья",
	},
	text_size = {
		en = "Enemy Name Text Size",
		["zh-cn"] = "敌人名称文字大小",
		ru = "Размер текста имен врагов",
	},
	text_offset_y = {
		en = "Text Vertical Offset",
		["zh-cn"] = "文字垂直偏移",
		ru = "Вертикальное смещение текста",
	},
	bar_offset_y = {
		en = "Health Bar Vertical Offset",
		["zh-cn"] = "血条垂直偏移",
		ru = "Вертикальное смещение полоски здоровья",
	},
	visual_enhancement_settings = {
		en = "Visual Enhancement Settings",
		["zh-cn"] = "视觉增强设置",
		ru = "Настройки визуального улучшения",
	},
	bar_border_enabled = {
		en = "Health Bar Borders",
		["zh-cn"] = "血条边框",
		ru = "Границы полосок здоровья",
	},
	bar_border_thickness = {
		en = "Border Thickness",
		["zh-cn"] = "边框厚度",
		ru = "Толщина границы",
	},
	background_opacity = {
		en = "Background Opacity",
		["zh-cn"] = "背景不透明度",
		ru = "Прозрачность фона",
	},
	bar_corner_style = {
		en = "Bar Style",
		["zh-cn"] = "血条样式",
		ru = "Стиль полоски",
	},
	text_shadow_enabled = {
		en = "Text Shadow",
		["zh-cn"] = "文字阴影",
		ru = "Тень текста",
	},
	text_outline_enabled = {
		en = "Text Outline",
		["zh-cn"] = "文字轮廓",
		ru = "Контур текста",
	},
	health_gradient = {
		en = "Health-Based Color Gradient",
		["zh-cn"] = "基于血量的颜色渐变",
		ru = "Цветовой градиент на основе здоровья",
	},
	gradient_intensity = {
		en = "Gradient Intensity",
		["zh-cn"] = "渐变强度",
		ru = "Интенсивность градиента",
	},
	smooth_animations = {
		en = "Smooth Animations",
		["zh-cn"] = "平滑动画",
		ru = "Плавные анимации",
	},
	breed_type_toggles = {
		en = "Breed Type Toggles",
		["zh-cn"] = "敌人类型开关",
		ru = "Переключатели типов врагов",
	},
	show_horde = {
		en = "Show Horde Enemies",
		["zh-cn"] = "显示群怪敌人",
		ru = "Показать врагов орды",
	},
	show_roamer = {
		en = "Show Roamer Enemies",
		["zh-cn"] = "显示游荡敌人",
		ru = "Показать бродячих врагов",
	},
	show_elite = {
		en = "Show Elite Enemies",
		["zh-cn"] = "显示精英敌人",
		ru = "Показать элитных врагов",
	},
	show_special = {
		en = "Show Special Enemies",
		["zh-cn"] = "显示专家敌人",
		ru = "Показать специальных врагов",
	},
	show_monster = {
		en = "Show Monster Enemies",
		["zh-cn"] = "显示怪物敌人",
		ru = "Показать врагов-монстров",
	},
	show_captain = {
		en = "Show Captain Enemies",
		["zh-cn"] = "显示队长敌人",
		ru = "Показать врагов-капитанов",
	},
	basic_color_settings = {
		en = "Basic Color Settings",
		["zh-cn"] = "基础颜色设置",
		ru = "Основные настройки цвета",
	},
	elite_subcategory_colors = {
		en = "Elite Subcategory Colors",
		["zh-cn"] = "精英子类别颜色",
		ru = "Цвета подкategorий элиты",
	},
	special_subcategory_colors = {
		en = "Special Subcategory Colors",
		["zh-cn"] = "专家子类别颜色",
		ru = "Цвета подкategorий специалистов",
	},
	horde_color_r = {
		en = "Horde Red Component",
		["zh-cn"] = "群怪红色分量",
		ru = "Красная составляющая орды",
	},
	horde_color_g = {
		en = "Horde Green Component",
		["zh-cn"] = "群怪绿色分量",
		ru = "Зелёная составляющая орды",
	},
	horde_color_b = {
		en = "Horde Blue Component",
		["zh-cn"] = "群怪蓝色分量",
		ru = "Синяя составляющая орды",
	},
	elite_melee_color_r = {
		en = "Elite Melee Red",
		["zh-cn"] = "精英近战红色",
		ru = "Красный элитных ближних",
	},
	elite_melee_color_g = {
		en = "Elite Melee Green",
		["zh-cn"] = "精英近战绿色",
		ru = "Зелёный элитных ближних",
	},
	elite_melee_color_b = {
		en = "Elite Melee Blue",
		["zh-cn"] = "精英近战蓝色",
		ru = "Синий элитных ближних",
	},
	elite_ranged_color_r = {
		en = "Elite Ranged Red",
		["zh-cn"] = "精英远程红色",
		ru = "Красный элитных дальних",
	},
	elite_ranged_color_g = {
		en = "Elite Ranged Green",
		["zh-cn"] = "精英远程绿色",
		ru = "Зелёный элитных дальних",
	},
	elite_ranged_color_b = {
		en = "Elite Ranged Blue",
		["zh-cn"] = "精英远程蓝色",
		ru = "Синий элитных дальних",
	},
	-- NEW: Generic special color settings
	special_color_r = {
		en = "Generic Special Red",
		["zh-cn"] = "通用专家红色",
		ru = "Красный обычных специалистов",
	},
	special_color_g = {
		en = "Generic Special Green",
		["zh-cn"] = "通用专家绿色",
		ru = "Зелёный обычных специалистов",
	},
	special_color_b = {
		en = "Generic Special Blue",
		["zh-cn"] = "通用专家蓝色",
		ru = "Синий обычных специалистов",
	},
	special_sniper_color_r = {
		en = "Special Sniper Red",
		["zh-cn"] = "专家狙击手红色",
		ru = "Красный специальных снайперов",
	},
	special_sniper_color_g = {
		en = "Special Sniper Green",
		["zh-cn"] = "专家狙击手绿色",
		ru = "Зелёный специальных снайперов",
	},
	special_sniper_color_b = {
		en = "Special Sniper Blue",
		["zh-cn"] = "专家狙击手蓝色",
		ru = "Синий специальных снайперов",
	},
	special_disabler_color_r = {
		en = "Special Disabler Red",
		["zh-cn"] = "专家控制红色",
		ru = "Красный специальных контроллеров",
	},
	special_disabler_color_g = {
		en = "Special Disabler Green",
		["zh-cn"] = "专家控制绿色",
		ru = "Зелёный специальных контроллеров",
	},
	special_disabler_color_b = {
		en = "Special Disabler Blue",
		["zh-cn"] = "专家控制蓝色",
		ru = "Синий специальных контроллеров",
	},
	monster_color_r = {
		en = "Monster Red Component",
		["zh-cn"] = "怪物红色分量",
		ru = "Красная составляющая монстра",
	},
	monster_color_g = {
		en = "Monster Green Component",
		["zh-cn"] = "怪物绿色分量",
		ru = "Зелёная составляющая монстра",
	},
	monster_color_b = {
		en = "Monster Blue Component",
		["zh-cn"] = "怪物蓝色分量",
		ru = "Синяя составляющая монстра",
	},
	captain_color_r = {
		en = "Captain Red Component",
		["zh-cn"] = "队长红色分量",
		ru = "Красная составляющая капитана",
	},
	captain_color_g = {
		en = "Captain Green Component",
		["zh-cn"] = "队长绿色分量",
		ru = "Зелёная составляющая капитана",
	},
	captain_color_b = {
		en = "Captain Blue Component",
		["zh-cn"] = "队长蓝色分量",
		ru = "Синяя составляющая капитана",
	},
}

-- Add localization entries for individual breeds
for breed_name, breed in pairs(Breeds) do
	if breed.tags and breed.tags.minion then
		local display_name = breed.display_name and Localize(breed.display_name) or breed_name
		localization[breed_name] = {
			en = "Show " .. display_name .. " health",
			["zh-cn"] = "显示" .. display_name .. "的血量",
			ru = "Показать здоровье: " .. display_name,
		}
	end
end

return localization