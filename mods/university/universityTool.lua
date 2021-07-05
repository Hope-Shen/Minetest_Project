minetest.register_node("university:wood_table", {
	description = "This is wood_table",
tiles = {"table_wood.png"},
	groups = {oddly_breakable_by_hand=3},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.375, -0.5, 0.5, 0.5, 0.5}, -- wood_table_Top
			{-0.5, -0.5, 0.5, -0.4375, 0.5, 0.4375}, -- wood_table_Lift_Top
			{-0.5, -0.5, -0.4375, -0.4375, 0.5, -0.5}, -- wood_table_Lift_Bottom
			{0.4375, -0.5, -0.4375, 0.5, 0.5, -0.5}, -- wood_table_Right_Bottom
			{0.4375, -0.5, 0.5, 0.5, 0.5, 0.4375}, -- wood_table_Right_Top
		}
	},
	walkable = false,
})

minetest.register_node('university:lobby_table', {
  description = 'This is lobby_table',
  drawtype = 'mesh',
  mesh = 'lobby_table.obj',
  tiles = {'lobby_table_texture.jpg'},
  paramtype = 'light',
  paramtype2 = 'facedir',
	inventory_image = "lobby_table_inv.png",
	wield_image = "lobby_table_inv.png",
	walkable = false,
	groups = {oddly_breakable_by_hand = 3},
})

minetest.register_node("university:blackboard_top", {
	description = "This is top of blackboard",
	tiles = {"blackboard_top.png"},
	groups = {oddly_breakable_by_hand=3},
	drawtype = "nodebox",
	paramtype = "light",
	walkable = false,
})

minetest.register_node("university:blackboard_bottom_chalk", {
	description = "This is bottom of blackboard with chalk",
	tiles = {"blackboard_bottom_chalk.png"},
	groups = {oddly_breakable_by_hand=3},
	drawtype = "nodebox",
	paramtype = "light",
	walkable = false,
})

minetest.register_node("university:blackboard_bottom", {
	description = "This is bottom of blackboard",
	tiles = {"blackboard_bottom.png"},
	groups = {oddly_breakable_by_hand=3},
	drawtype = "nodebox",
	paramtype = "light",
	walkable = false,
})

local floor, pi = math.floor, math.pi
local vadd = vector.add
local whiteboard = {}
whiteboard_setting = {
	letter_width = 16,
	row_width = 20
}
local wall_sign_positions = {
	[0] = {{x =  0.43, y = -0.005, z =  0},    pi * 0.5},
	[1] = {{x = -0.43, y = -0.005, z =  0},    pi * 1.5},
	[2] = {{x =  0,    y = -0.005, z =  0.43}, pi},
	[3] = {{x =  0,    y = -0.005, z = -0.43}, 0}
}

local wrap_chars = {
	"\n", "\r", "\t", " ", "-", "/", ";", ":", ",", ".", "?", "!"
}

local disposable_chars = {
	["\n"] = true, ["\r"] = true, ["\t"] = true, [" "] = true
}

local function find_any(str, start)
	local ret = 0 -- 0 if not found (indices start at 1)
	for i, char in pairs(wrap_chars) do
		local first = str:find(char, start)
		if first then
			if ret == 0 or first < ret then
				ret = first
			end
		end
	end

	return ret
end

local function generate_img_texture(str, row)
	local left_space = floor((whiteboard_setting.row_width - #str) * whiteboard_setting.letter_width / 2)

	local texture = ""
	for i = 1, whiteboard_setting.row_width do
		local char = str:byte(i) --letter/character (char) covert to Decimal Value (ASCII Code)
		if char and (char >= 32 and char <= 126) then
			texture = texture .. ":" .. (i - 1) * whiteboard_setting.letter_width + left_space .. ","
					.. row * whiteboard_setting.row_width .. "=letter_" .. char .. ".png"
		end
	end

-- minetest.chat_send_player('singleplayer', 'texture_img: '..texture)
	return texture
end

local function generate_texture(str)
	local row = 0
	local texture = "[combine:" .. whiteboard_setting.row_width * whiteboard_setting.letter_width .. "x100"
	local result = {}

	while #str > 0 do
		if row > 4 then
			break
		end
		local wrap_i = 0
		local keep_i = 0 -- The last character that was kept
		while wrap_i < #str do
			wrap_i = find_any(str, wrap_i + 1)
			if wrap_i > 20 then
				if keep_i > 1 then
					wrap_i = keep_i
				else
					wrap_i = 20
				end
				break
			elseif wrap_i == 0 then
				if #str <= 20 then
					wrap_i = #str
				elseif keep_i > 0 then
					wrap_i = keep_i
				else
					wrap_i = #str
				end
				break
			elseif str:sub(wrap_i, wrap_i) == "\n" then
				break
			end
			if not disposable_chars[str:sub(wrap_i, wrap_i)] then
				keep_i = wrap_i
			elseif wrap_i > 1 and
					not disposable_chars[str:sub(wrap_i - 1, wrap_i - 1)] then
				keep_i = wrap_i - 1
			end
		end
		if wrap_i > 20 then
			wrap_i = 20
		end
		local start_remove = 0
		if disposable_chars[str:sub(1, 1)] then
			start_remove = 1
		end
		local end_remove = 0
		if disposable_chars[str:sub(wrap_i, wrap_i)] then
			end_remove = 1
		end
		local line_string = str:sub(1 + start_remove, wrap_i - end_remove)
		str = str:sub(wrap_i + 1)
		if line_string ~= "" then
			result[row] = line_string
		end
		row = row + 1
	end

	local empty_row = row < 4 and 1 or 0 -- if row < 4 ? 1 : 0
	for i, str in pairs(result) do
		texture = texture .. generate_img_texture(str, i + empty_row)
	end

	-- minetest.chat_send_player('singleplayer', 'texture: '..texture)
	return texture
end

local function objects_inside_radius(p)
	return minetest.get_objects_inside_radius(p, 0.5)
end

minetest.register_entity("university:whiteboard_text_entity", {
	visual = "upright_sprite",
	visual_size = {x = 0.7, y = 0.6},
	collisionbox = {0},
	physical = false,
	on_activate = function(self)
		local ent = self.object
		local pos = ent:get_pos()

		local meta = minetest.get_meta(pos)
		local meta_texture = meta:get_string("whiteboard_input_texture")

		local texture = ""
		if meta_texture and meta_texture ~= "" then
			texture = meta_texture
		else
			local meta_text = meta:get_string("whiteboard_input_text")
			if meta_text and meta_text ~= "" then
				texture = generate_texture(meta_text)
			end
			meta:set_string("whiteboard_input_texture", texture)
		end

		ent:set_properties({
			textures = {texture, ""}
		})
	end
})

local function whiteboard_formspec(pos, clicker, can_edit)
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("whiteboard_input_text")
	local size = { "size[5,3]" }
	if can_edit then
		table.insert(size, "textarea[1,0.5;3.5,2;whiteboard_content;Enter your text:;"..text.."]")
	  table.insert(size, "button_exit[1,2.5;3,0.5;save;Save]")
		table.insert(size, "field[0,0;0,0;whiteboadr_pos;;" .. minetest.pos_to_string(pos) .. "]")
	else
		table.insert(size, "textarea[1,0.5;3.5,2;;Present content:;"..text.."]")
	  table.insert(size, "button_exit[1,2.5;3,0.5;close;Close]")
	end
	return table.concat(size)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "whiteboard_content" then
		return
	end

	local pos = fields.whiteboadr_pos and minetest.string_to_pos(fields.whiteboadr_pos)
	if not pos then
		return
	end

	local meta = minetest.get_meta(pos)
	local text = fields.whiteboard_content

	if not text then
		text = meta:get_string("whiteboard_input_text")
	end

	local node = minetest.get_node(pos)
	local p2 = node.param2 - 2
	local	sign_pos = wall_sign_positions

	local sign
	for _, obj in pairs(objects_inside_radius(pos)) do
		local ent = obj:get_luaentity()
		if ent and ent.name == "university:whiteboard_text_entity" then
			sign = obj
			break
		end
	end
	if not sign then
		sign = minetest.add_entity(
			vadd(pos, sign_pos[p2][1]), "university:whiteboard_text_entity")
	else
		sign:set_pos(vadd(pos, sign_pos[p2][1]))
	end

	local texture = generate_texture(text)
	sign:set_properties({
		textures = {texture, ""}
	})

	sign:set_yaw(sign_pos[p2][2])
	meta:set_string("whiteboard_input_texture", texture)
	meta:set_string("whiteboard_input_text", text)
	meta:set_string("infotext", string.format("Presented by: %s \n\n%s", player:get_player_name(), text))
end)

function whiteboard.on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local clicker_name = clicker:get_player_name()
	local can_edit = clicker_name == meta:get_string("owner") and true or false -- if xxx == yyy ? true : false
	minetest.show_formspec(clicker_name, "whiteboard_content", whiteboard_formspec(pos, clicker, can_edit))
end

function whiteboard.on_destruct(pos)
	for _, obj in pairs(objects_inside_radius(pos)) do
		local ent = obj:get_luaentity()
		if ent and ent.name == "university:whiteboard_text_entity" then
			obj:remove()
		end
	end
end

function whiteboard.after_place(pos, placer, itemstack)
	local meta = minetest.get_meta(pos)
	local name = placer:get_player_name()
	local text = minetest.get_meta(pos):get_string("whiteboard_content")
	meta:set_string("owner", name)
	meta:set_string("infotext", string.format("Placeed by: %s \n\n%s", name, text))
end

local function is_owner(pos, name)
	local owner = minetest.get_meta(pos):get_string("owner")
	if owner == "" or owner == name or minetest.check_player_privs(name, "protection_bypass") then
		return true
	end
	return false
end

function whiteboard.on_dig(pos, node, player)
		local player_name = player:get_player_name()
		-- Check the placer is the digger
		if is_owner(pos, player) then
			minetest.remove_node(pos)
		else
			minetest.chat_send_player(player_name, 'You don\'t have privileges to remove this item.')
		end
end

minetest.register_node("university:whiteboard", {
	description = "This is whiteboard",
	tiles = {"whiteboard.png"},
	inventory_image = "whiteboard.png",
	wield_image = "whiteboard.png",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "wallmounted",
	node_box = {
		type = "wallmounted",
		wall_top = {-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5}, -- Ceiling
		wall_bottom    = {-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}, -- Floor
		wall_side   = {-0.5, -0.3125, -0.4375, -0.4375, 0.3125, 0.4375}, -- Wall
	},
	groups = {oddly_breakable_by_hand=3},
	on_rotate = false,
	walkable = false,
	after_place_node = whiteboard.after_place,
	on_rightclick = whiteboard.on_rightclick,
	on_destruct = whiteboard.on_destruct,
	on_dig = whiteboard.on_dig
})

minetest.register_node('university:computer', {
  description = 'This is computer',
  drawtype = 'mesh',
  mesh = 'computer.obj',
  tiles = {'computer_texture.png'},
  paramtype = 'light',
  paramtype2 = 'facedir',
	inventory_image = "computer_inv.png",
	wield_image = "computer_inv.png",
	walkable = false,
	groups = {oddly_breakable_by_hand = 3},
})
