local world_path = minetest.get_worldpath()
local N = 1
local presentation = {}

local function ppt_formspec(clicker, course_select)
  local size = { "size[8,1]" }

  course_select_id = course_select ~= '' and course_select or 1
  table.insert(size, "label[0, 0.2;Course:]")
  table.insert(size, "dropdown[1.2,0.1;5,0.5;course_select;".. table.concat(courses, ",")..";"..course_select_id.."]")
  table.insert(size, "button_exit[6,0.25;2,0.5;exit;Exit]")
  return table.concat(size)
end

function presentation.on_use(itemstack, placer, pointed_thing)

  local placer_name = placer:get_player_name()
end

local function get_presentation(number)
  -- local file, err = io.open(world_path .. "/presentation/ppt_".. number.. ".png", "r")
    local file, err = io.open(minetest.get_modpath("university").."/textures/ppt_"..number..".png","r")
    if err then return end
    if file ~= nil then
      file:close()
      return true
    end
    return false
end

while get_presentation(N) == true do
    N = N + 1
end

N = N - 1

for n = 1, N, 1 do
  local groups = {oddly_breakable_by_hand = 3, not_in_creative_inventory=1}
  if n == 1 then
  	groups = {oddly_breakable_by_hand = 3}
  end

  -- width and height of the picture
  local pic_width, pic_height=1920, 1080
  local pictexture_pix = math.max(pic_width,pic_height)
  -- X and Y position Vertical Align
  local pic_pos_x = ((pictexture_pix - pic_width) / 2)
  local pic_pos_y = ((pictexture_pix - pic_height) / 2)

  function presentation.on_rightclick(pos, node, clicker, itemstack, pointed_thing)
    local length = string.len (node.name)
		local number = string.sub (node.name, 16, length)

		local keys=clicker:get_player_control()
		if keys["sneak"]==false then
			if number == tostring(N) then
				number = 1
			else
				number = number + 1
			end
		else
			if number == 1 then
				number = N - 1
			else
				number = number - 1
			end
		end
		node.name = "university:ppt_"..number..""
		minetest.env:set_node(pos, node)
  end


  minetest.register_node("university:ppt_"..n.."", {
  	description = "ppt #"..n.."",
  	drawtype = "signlike",
    tiles = {
            {name="([combine:"..pictexture_pix.."x"..pictexture_pix..":"..pic_pos_x..","..pic_pos_y.."=ppt_"..n..".png)"}
        },
  	visual_scale = 3,
  	inventory_image = "presentation_inv.png",
  	wield_image = "presentation_inv.png",
  	paramtype = "light",
  	paramtype2 = "wallmounted",
  	sunlight_propagates = true,
  	selection_box = {
  		type = "wallmounted",
  	},
  	groups = groups,

  	on_rightclick = presentation.on_rightclick,
    on_use = presentation.on_use
  })
end
