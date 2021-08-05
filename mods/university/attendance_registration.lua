local computer = {}
local column_name = {
	{
		title = "Enroll?",
	},
}
local courses = {}
local enrolled = {}
local attendance = {}
local attendance_by_course_student = {}

local whitelist = {}
local world_path = minetest.get_worldpath()

local online_students = {}
local course_select_id = ""
local online_student_select_id = ""
local attendance_student_select_id = ""
local getAPI_status = false

-- Read API
local function load_API()
	courses = {}
	enrolled = {}
	attendance = {}
	http_api.fetch({
		url = api_serverIP .. "course",
		method="GET"
	}, function (res)
		local api_content = minetest.parse_json(minetest.parse_json(dump(res.data)))
		for i, j_str in pairs(api_content) do
			courses[#courses + 1 ] = j_str.courseId .. ' ' .. j_str.courseName
		end
	end)
	http_api.fetch({
		url = api_serverIP .. "enrollment",
		method="GET"
	}, function (res)
		local api_content = minetest.parse_json(minetest.parse_json(dump(res.data)))
		for i, j_str in pairs(api_content) do
			enrolled[#enrolled + 1 ] = j_str.studentName
		end
	end)
	http_api.fetch({
		url = api_serverIP .. "attendance",
		method="GET"
	}, function (res)
		local api_content = minetest.parse_json(minetest.parse_json(dump(res.data)))
		for i, j_str in pairs(api_content) do
			attendance[#attendance + 1 ] = j_str.studentName
		end
	end)
	getAPI_status = true
end

-- Write student attendance
local function save_attendance(course_select_id, online_student_select_id)
	local post_data= "{\"courseId\":\"".. courses[course_select_id]:sub(1, 8) .."\",\"studentId\":\"".. string.split(online_student_select_id, "-")[1] .."\"}"
	http_api.fetch({
		url = api_serverIP .. "attendance",
		method="POST",
		extra_headers = { "Content-Type: application/json" },
		data = post_data
	}, function (res)
		-- print('save_attendance: '..dump(res))
		if res.succeeded then
			print('[Success] Take attendance: '.. online_student_select_id ..', course: '.. courses[course_select_id])
		end
	end)
end

-- Remove student attendance
local function remove_attendance(course_select_id, attendance_student_select_id)
	local post_data= "{\"courseId\":\"".. courses[course_select_id]:sub(1, 8) .."\",\"studentId\":\"".. string.split(attendance_student_select_id, "-")[1] .."\",\"Date\":\""..os.date('%Y-%m-%d').."\"}"
	http_api.fetch({
		url = api_serverIP .. "attendance",
		method="DELETE",
		extra_headers = { "Content-Type: application/json" },
		data = post_data
	}, function (res)
		-- print('remove_attendance: '..dump(res))
		if res.succeeded then
			print('[Success] Remove attendance: '.. attendance_student_select_id ..', course: '.. courses[course_select_id])
		end
	end)
end

local function check_enorlled(course_select_id, student)
	if enrolled[course_select_id] then
		local all_enrolled = string.split(enrolled[course_select_id], ",")
	  for i, col in pairs(all_enrolled) do
	    if student == col then
	      return true
	    end
	  end
	end
  return false
end

local function check_attendant(course_select_id, student)
	if attendance[course_select_id] then
	  local all_attendance = string.split(attendance[course_select_id], ",")
		for i, col in pairs(all_attendance) do
	    if student == col then
	      return true
	    end
	  end
	end
  return false
end

local function computer_formspec(clicker, course_select, student_select)
	local size = { "size[11.5,8]" }

	-- Check the privilege
	if not check_teacher_priv(clicker) then
		return "size[7,1.5] label[0.5,0;Access denied. This function only for teacher.] button_exit[2.5,1;2,0.5;exit;Exit]"
	end

	-- Check user has right clicked to download the data from API
	if not getAPI_status then
		return "size[10,1.5] label[0.5,0;Please left click to download the data or there is no course had been found.] button_exit[4,1;2,0.5;exit;Exit]"
	end

  course_select_id = course_select ~= '' and course_select or 1
  table.insert(size, "label[0, 0.5;Course:]")
  table.insert(size, "dropdown[1.2,0.35;5,0.5;course_select;".. table.concat(courses, ",")..";"..course_select_id.."]")
  table.insert(size, "button[6.5,0.5;2,0.5;save;Save]")
  table.insert(size, "button_exit[9,0.5;2,0.5;exit;Exit]")

  -- Online student zone
  table.insert(size, "label[0, 1.5;Online Students:]")

  local fs_col = {}
  for i, col in pairs(column_name) do
		fs_col[#fs_col + 1] = ";color;text,align=center"
		if i == 1 then
			fs_col[#fs_col + 1] = ",padding=2"
		end
	end
	fs_col[#fs_col + 1] = "]"

  table.insert(size, "tablecolumns[color;text,width=10".. table.concat(fs_col, "")..",width=5]")

  local fs = {}
  for i, col in pairs(column_name) do
		fs[#fs + 1] = ",," .. col.title
	end

	attendance_by_course_student = {}
	if attendance[course_select_id] ~= nil then
		attendance_by_course_student = string.split(attendance[course_select_id], ",")
	end

  -- Get online students who is not register attendance
	online_students = {}
  for i,player in pairs(minetest.get_connected_players()) do
		if not check_attendant(course_select_id, player:get_player_name()) and
				not check_teacher_priv(clicker) then
			  online_students[#online_students + 1] = player:get_player_name()
		end
  end

  table.sort(online_students)

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
	fs[#fs + 1] = online_student_select_id

	table.insert(size, "table[0, 2; 4.5, 6;online_list;,Name".. table.concat(fs, "").."]")

  -- Move button zone
  table.insert(size, "button[5,3.5;1.3,0.5;move_right;>>]")
  table.insert(size, "button[5,5;1.3,0.5;move_left;<<]")

  -- Attendance Register zone
	fs = {}
  table.insert(size, "label[6.5, 1.5;Attendance Register:]")
	table.insert(size, "tablecolumns[color;text,width=10".. table.concat(fs_col, "")..",width=5]")
	local fs = {}
  for i, col in pairs(column_name) do
		fs[#fs + 1] = ",," .. col.title
	end

	for i, student in pairs(attendance_by_course_student) do
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
	fs[#fs + 1] = attendance_student_select_id

  table.insert(size, "table[6.5, 2; 4.5, 6;attendance_list;,Name".. table.concat(fs, "").."]")
	return table.concat(size)
end

function computer.on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local clicker_name = clicker:get_player_name()
	minetest.show_formspec(clicker_name, "attendance_register", computer_formspec(clicker, 1, ''))
end

function computer.on_use(itemstack, clicker, pointed_thing)
	if not check_teacher_priv(clicker) then
		minetest.chat_send_player(clicker:get_player_name(), "You don't have permission. This function only for teacher.")
		return
	end
  load_API()
end

local function on_player_receive_fields(player, fields, update_callback)
	local online_list_evt = minetest.explode_table_event(fields.online_list)
	local attendance_list_evt = minetest.explode_table_event(fields.attendance_list)

	--select online list (left column) action
	if fields.online_list then
		online_student_select_id = ""
		local i = (online_list_evt.row or 0) - 1
			if online_list_evt.type == "CHG" and i >= 1  and i <= #online_students then
				online_student_select_id = online_students[i]
			end
			update_callback(player)
			return
	end

	--select attendance list (right column) action
	if fields.attendance_list then
		attendance_student_select_id = ""
		local i = (attendance_list_evt.row or 0) - 1
			if attendance_list_evt.type == "CHG" and i >= 1  and i <= #attendance_by_course_student then
				attendance_student_select_id = attendance_by_course_student[i]
			end
			update_callback(player)
			return
	end

	if fields.move_right then
		if online_student_select_id ~= "" then
			save_attendance(course_select_id, online_student_select_id)
			if string.find(attendance[course_select_id], ",") then
				attendance[course_select_id] = attendance[course_select_id] .. ','..online_student_select_id
			else
				attendance[course_select_id] = online_student_select_id
			end

			online_student_select_id = ""
		end

		update_callback(player)
		return
	end

	if fields.move_left then
		if attendance_student_select_id ~= "" then
			remove_attendance(course_select_id, attendance_student_select_id)

			local trim = ""
			if string.find(attendance[course_select_id], ",") then
				trim = "%,"..string.split(attendance_student_select_id, "-")[1]..'%-'..string.split(attendance_student_select_id, "-")[2]
				attendance[course_select_id] = attendance[course_select_id]:gsub(trim,"")
			else
				trim = string.split(attendance_student_select_id, "-")[1]..'%-'..string.split(attendance_student_select_id, "-")[2]
				-- attendance[course_select_id] = ""
			end
			attendance[course_select_id] = attendance[course_select_id]:gsub(trim,"")

			attendance_student_select_id = ""
		end
		update_callback(player)
		return
	end

	if fields.course_select then
		course_select_id = ""
		online_student_select_id = ""
		for i, courses in pairs(courses) do
			if courses == fields.course_select then
				course_select_id = i
			end
		end

		update_callback(player)
		return
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
  local player_name = player:get_player_name()
	if formname ~= "attendance_register" then
		return
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
	on_use = computer.on_use,
  on_rightclick = computer.on_rightclick,
})
