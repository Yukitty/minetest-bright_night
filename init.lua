-- engine const
local SUNLIGHT = 15

-- mod config
local night_light = 4
local dawn = 0.2049
local dusk = 0.7882

-- mod active values
local night_mode = false

-- If you change night_light above, use this command
-- to calculate new seamless dawn and dusk times.
--[[
minetest.register_chatcommand("calc_nightlight", {
description = "Calculate appropriate time settings for bright_night mod.",
func=function(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		return false, "Must be run by an in-game player."
	end

	local pos = player:get_pos()
	pos.x = math.floor(pos.x)
	pos.y = math.floor(pos.y + 1)
	pos.z = math.floor(pos.z)

	local time = 0.5
	local light = minetest.get_node_light(pos, time)
	if light ~= SUNLIGHT then
		return false, "Please stand in open sunlight."
	end

	time = 0.26
	while light >= night_light and time > 0 do
		time = time - 0.0001
		light = minetest.get_node_light(pos, time)
	end
	dawn = time

	time = 0.74
	light = 15
	while light > night_light and time < 1 do
		time = time + 0.0001
		light = minetest.get_node_light(pos, time)
	end
	dusk = time

	return true, string.format('Found dawn and dusk for %d as %.4f and %.4f', night_light, dawn, dusk)
end})
]]

local function set_night(player)
	player:override_day_night_ratio(night_light / SUNLIGHT)
end

local function unset_night(player)
	player:override_day_night_ratio(nil)
end

minetest.register_on_joinplayer(function(player)
	if night_mode then
		set_night(player)
	end
end)

minetest.register_globalstep(function()
	local time = minetest.get_timeofday()
	if time < dawn or time > dusk then
		if not night_mode then
			night_mode = true
			for _, player in ipairs(minetest.get_connected_players()) do
				set_night(player)
			end
		end
	elseif night_mode then
		night_mode = false
		for _, player in ipairs(minetest.get_connected_players()) do
			unset_night(player)
		end
	end
end)

