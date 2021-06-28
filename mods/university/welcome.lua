help_center = {}

--The welcome page.
help_center.welcome = [[
To get an easy way to manipulate this environment, take our guided tour. Please click the "Start Guided Tour" to start your university adventure.

Already know everything? Click the "Exit" button and enjoy your university life.

Note: If you need help, please type "/help_info" anytime.
]]

--The keyboard guide.
help_center.keyboard_guide = [[
Default controls:

- Left mouse button: Open / use
- W: Move forwards
- A: Move to the left
- D: Move to the right
- S: Move backwards
- space: Jump / move up
- Shift: Sneak / move down
- I: Show / hide inventory menu
- T: Open chat window
]]

--The university guide.
help_center.university_guide = [[
Some information you need to konw....
]]

local function fun_formspec(player, page)
	local size = { "size[10,7.5]" }
  if page == "welcome" then
    table.insert(size, "label[2.5,0.5;"..minetest.colorize("#EE0", "Welcome to Minetest University!").."]")
    table.insert(size, "textarea[0.5,1.5;9.5,6.5;;" ..help_center.welcome .. ";]")
  	table.insert(size, "button[6,7;4,0.5;welcome_start_tour;Start Guided Tour]")
  elseif page == "keyboard_guide" then
  	table.insert(size, "textarea[0.5,0.5;9.5,7.5;;" ..help_center.keyboard_guide .. ";]")
    table.insert(size, "button[1,7;3,0.5;keyboard_guide_pervious;<< Pervious]")
  	table.insert(size, "button[6,7;3,0.5;keyboard_guide_next;Next >>]")
  elseif page == "university_guide" then
    table.insert(size, "textarea[0.5,0.5;9.5,7.5;;" ..help_center.university_guide .. ";]")
    table.insert(size, "button[1,7;3,0.5;university_guide_pervious;<< Pervious]")
  end

	table.insert(size, "button_exit[4,7;2,0.5;exit;Exit]")
	return table.concat(size)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
  -- print("Formname: "..formname)
	local name = player:get_player_name()
	if fields.welcome_start_tour or fields.university_guide_pervious then
		minetest.after(1, function()
			minetest.show_formspec(name, "keyboard_guide_page", fun_formspec(player,"keyboard_guide"))
		end)
		return
  elseif fields.keyboard_guide_pervious then
		minetest.after(1, function()
			minetest.show_formspec(name, "welcome_page", fun_formspec(player, "welcome"))
		end)
		return
  elseif fields.keyboard_guide_next then
		minetest.after(1, function()
			minetest.show_formspec(name, "university_page", fun_formspec(player, "university_guide"))
		end)
		return
  -- else
  --   print("In else condition")
	-- return
	end
end)

minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    minetest.show_formspec(player_name, "welcome_page", fun_formspec(player, "welcome"))
end)

minetest.register_chatcommand('help_info', {
	description = "test2",
	params = '<welcome_page>',
	func = function(name, params)
		params = params:split(',')
		local directTo = params[1] or 'do nothing'
		if directTo == "welcome_page" or directTo == "keyboard_guide" or directTo == "university_guide" then
			if directTo == "welcome_page" then
				minetest.show_formspec(name, "welcome_page", fun_formspec(player, "welcome"))
			elseif directTo == "keyboard_guide" then
				minetest.show_formspec(name, "keyboard_guide_page", fun_formspec(player,"keyboard_guide"))
			elseif directTo == "university_guide" then
				minetest.show_formspec(name, "university_page", fun_formspec(player, "university_guide"))
			end
			minetest.chat_send_player(name, 'Direct to: '..directTo)
		else
			minetest.chat_send_player(name, 'Invalid command, please try "welcome_page", "keyboard_guide" or "university_guide".')
		end
	end,
})
