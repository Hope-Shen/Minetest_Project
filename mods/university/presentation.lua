local presentation = {}
local existing_ppt_course = {}
local mod_path = minetest.get_modpath("university")

-- Get all file in directory for the file name with "PPT_" and store in "existing_ppt_course" table
local files = minetest.get_dir_list(mod_path.."/textures")
table.sort(files)
local temp = ""
for i, file in pairs(files) do
  if string.match(file, "PPT_") then
    if #existing_ppt_course + 1 == 1 then
      temp = file:sub(5, 12)
      existing_ppt_course[#existing_ppt_course + 1] = file:sub(5, 12)
    else
      if temp ~= file:sub(5, 12) then
        existing_ppt_course[#existing_ppt_course + 1] = file:sub(5, 12)
        temp = file:sub(5, 12)
      end
    end
  end
end

-- Get presentation png
local function get_presentation(number, ppt_course)
  local file, err = io.open(mod_path.."/textures/PPT_"..ppt_course ..'_'..number..".png","r")

    if err then return end
    if file ~= nil then
      file:close()
      return true
    end
    return false
end

-- Loop the presentation because the slide show cycle
for i, ppt_course in pairs(existing_ppt_course) do
  local N = 1
  while get_presentation(N, ppt_course) == true do
      N = N + 1
  end

  N = N - 1

  for n = 1, N, 1 do
    -- Only show the first slide in inventory
    local groups = {oddly_breakable_by_hand = 3, not_in_creative_inventory=1}
    if n == 1 then
    	groups = {oddly_breakable_by_hand = 3}
    end

    -- Set width and height of the picture
    local pic_width, pic_height=1920, 1080
    local pictexture_pix = math.max(pic_width,pic_height)
    -- X and Y position Vertical Align
    local pic_pos_x = ((pictexture_pix - pic_width) / 2)
    local pic_pos_y = ((pictexture_pix - pic_height) / 2)

    -- Place presentation object event
    -- *This function only allows the teacher to operate.Or it will show the deny meeeage.
    function presentation.on_place(itemstack, clicker, pointed_thing)
      if not check_teacher_priv(clicker) then
        minetest.chat_send_player(clicker:get_player_name(), "You don't have permission. This function is only for the teacher.")
        return
      end
      return minetest.item_place(itemstack, clicker, pointed_thing)
    end

    -- presentation object right click to switch the slide
    function presentation.on_rightclick(pos, node, clicker, itemstack, pointed_thing)
      local length = string.len (node.name)
  		local number = string.sub (node.name, 25, length)
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
  		node.name = "university:PPT_"..ppt_course.."_"..number..""
  		minetest.env:set_node(pos, node)
    end

    -- presentation node register
    minetest.register_node("university:PPT_"..ppt_course.."_"..n, {
    	description = "PPT #"..ppt_course.."_"..n.."",
    	drawtype = "signlike",
      tiles = {
              {name="([combine:"..pictexture_pix.."x"..pictexture_pix..":"..pic_pos_x..","
              ..pic_pos_y.."=PPT_"..ppt_course.."_"..n..".png)"}
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
      on_place = presentation.on_place,
    	on_rightclick = presentation.on_rightclick,
    })
  end
end
