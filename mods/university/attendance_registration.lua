--Set up default privileges
minetest.register_privilege("teacher", {
	give_to_singleplayer = false
})

-- local http_api = minetest.request_http_api()
-- if not http_api then
-- 	print("ERROR: in minetest.conf, this mod must be in secure.http_mods!")
-- end
--


local computer = {}
local column_name = {
	{
		title = "Enroll?",
	},
}
local courses = {}
local enrolled = {}
local attendance = {}

local whitelist = {}
local world_path = minetest.get_worldpath()

local online_students = {}
local course_select_id = ""
local student_select_id = ""


-- Read courses
local function load_JsonFile()
	courses = {}
	enrolled = {}
	attendance = {}
	local file, err = io.open(world_path .. "/course.json", "r")
	if err then return end
  local json_content = minetest.parse_json(file:read("*a"))
	file:close()

	for i, j_str in pairs(json_content) do
    courses[#courses + 1 ] = j_str.courses
    enrolled[#enrolled + 1 ] = j_str.enroll_students
    attendance[#attendance + 1 ] = j_str.attendance_student
    enrolled[j_str.courses] = j_str.enroll_students
	end
end

-- Write student attendance
local function save_attendance()
	local str_save = {}

	for i = 1,#courses,1
	do
		table.insert(str_save, minetest.write_json({courses = courses[i], enroll_students = enrolled[i], attendance_student = attendance[i]}))
	end

	local file, err = io.open(world_path .. "/course.json", "w")
	if err then return end
	file:write("[".. table.concat(str_save,",").."]")
	file:close()
end


local function check_enorlled(course_select, student)
	-- minetest.chat_send_player('singleplayer', 'bbb: '..enrolled[course_select]..', '.. student)
  local all_enrolled = string.split(enrolled[course_select], ",")
  for i, col in pairs(all_enrolled) do
    if student == col then
      return true
    end
  end
  return false
end

local function check_attendant(course_select, student)
  local all_attendance = string.split(attendance[course_select], ",")
	for i, col in pairs(all_attendance) do
    if student == col then
      return true
    end
  end
  return false
end


local function computer_formspec(clicker, course_select, student_select)
	local size = { "size[11.5,8]" }

  course_select_id = course_select ~= '' and course_select or 1
  table.insert(size, "label[0, 0.5;Course:]")
  table.insert(size, "dropdown[1.2,0.35;5,0.5;course_select;".. table.concat(courses, ",")..";"..course_select_id.."]")
  table.insert(size, "button[6.5,0.5;2,0.5;save;Save]")
  table.insert(size, "button_exit[9,0.5;2,0.5;exit;Exit]")

  -- Online student zone
  table.insert(size, "label[0, 1.5;Online Students:]")

  local fs = {}
  for i, col in pairs(column_name) do
		fs[#fs + 1] = ";color;text,align=center"
		if i == 1 then
			fs[#fs + 1] = ",padding=2"
		end
	end
	fs[#fs + 1] = "]"

  table.insert(size, "tablecolumns[color;text,width=10".. table.concat(fs, "")..",width=5]")

  fs = {}
  for i, col in pairs(column_name) do
		fs[#fs + 1] = ",," .. col.title
	end
	local all_attendance_by_course = {}
	if attendance[course_select_id] ~= nil then
		all_attendance_by_course = string.split(attendance[course_select_id], ",")
	end

  -- Get online students who is not register attendance
	online_students = {}
  for i,player in pairs(minetest.get_connected_players()) do
		if not check_attendant(course_select_id, player:get_player_name()) then
			  online_students[#online_students + 1] = player:get_player_name()
		end
  end
  table.sort(online_students)

	-- minetest.chat_send_player('singleplayer', 'qq: '..courses[course_select])

	for i, student in pairs(online_students) do
    local color, value
    local has_enrolled = check_enorlled(course_select_id, student)
    color = has_enrolled and "green" or "red"
		value = has_enrolled and "Yes" or "No"

    fs[#fs + 1] = ",,"
    fs[#fs + 1] = minetest.formspec_escape(student)

    fs[#fs + 1] = ","
    fs[#fs + 1] = color
    fs[#fs + 1] = ","
    fs[#fs + 1] = minetest.formspec_escape(value)
	end

	fs[#fs + 1] = ";"
	fs[#fs + 1] = student_select_id

	-- minetest.chat_send_player('singleplayer', 'fs: '.. table.concat(fs, ""))
  table.insert(size, "table[0, 2; 4.5, 6;online_list;,Name".. table.concat(fs, "").."]")

  -- Move button zone
  table.insert(size, "button[5,3.5;1.3,0.5;move_right;>>]")
  table.insert(size, "button[5,5;1.3,0.5;move_left;<<]")

  -- Attendance Register zone
	fs = {}
  table.insert(size, "label[6.5, 1.5;Attendance Register:]")

	local selection_id = ""

	if attendance[course_select_id] ~= nil then
		for i, student in pairs(all_attendance_by_course) do
	    local color, value
	    local has_enrolled = check_enorlled(course_select_id, student)
	    color = has_enrolled and "green" or "red"
			value = has_enrolled and "Yes" or "No"

	    fs[#fs + 1] = ",,,"
	    fs[#fs + 1] = color
	    fs[#fs + 1] = ","
	    fs[#fs + 1] = minetest.formspec_escape(student)
		end
	else

	end

	fs[#fs + 1] = ";"
	fs[#fs + 1] = selection_id

  table.insert(size, "table[6.5, 2; 4.5, 6;attendance_list;,Name".. table.concat(fs, "").."]")
	-- minetest.chat_send_player('singleplayer', 'size: '.. table.concat(size,""))
	-- print('size: '.. table.concat(size,""))
	return table.concat(size)
end

function computer.on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local clicker_name = clicker:get_player_name()
  load_JsonFile()
	minetest.show_formspec(clicker_name, "attendance_register", computer_formspec(clicker, 1, ''))
end

local function on_player_receive_fields(player, fields, update_callback)
	update_callback(player)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
  local player_name = player:get_player_name()
	if formname ~= "attendance_register" then
		return
	end
	local evt = minetest.explode_table_event(fields.course_select)

	if fields.course_select then
		for i, courses in pairs(courses) do
			if courses == fields.course_select then
				course_select_id = i
			end
		end
	end

	-- local course_select_id
	if fields.online_list then
		student_select_id = ""
		local evt = minetest.explode_table_event(fields.online_list)
		local i = (evt.row or 0) - 1
			if evt.type == "CHG" and i >= 1  and i <= #online_students then
				student_select_id = online_students[i]
				-- minetest.chat_send_player('singleplayer',"student_select_id: "..student_select_id )
			end
	end

	if fields.move_right then
		-- minetest.chat_send_player('singleplayer',"move right: "..course_select_id ..', '..student_select_id )
		if student_select_id ~= "" then
			attendance[course_select_id] = attendance[course_select_id] .. ','..student_select_id
			student_select_id = ""
			save_attendance()
		end
	end

	on_player_receive_fields(player, fields, function(player)
		minetest.show_formspec(player:get_player_name(), "attendance_register", computer_formspec(player,course_select_id,''))
	end)
end)

minetest.register_node('university:computer', {
  description = 'This is computer',
  drawtype = 'mesh',
  mesh = 'computer.obj',
  tiles = {'computer_texture.png'},
	groups = {oddly_breakable_by_hand = 3},
  paramtype = 'light',
  paramtype2 = 'facedir',
	inventory_image = "computer_inv.png",
	wield_image = "computer_inv.png",
	buildable_to = false,

  on_rightclick = computer.on_rightclick,
})