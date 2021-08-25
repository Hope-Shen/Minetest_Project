print("++++++++ The minetest server started successfully +++++++++")

--Load File
dofile(minetest.get_modpath('university')..'/whitelist.lua')
dofile(minetest.get_modpath('university')..'/attendance_registration.lua')
dofile(minetest.get_modpath('university')..'/universityTool.lua')
dofile(minetest.get_modpath('university')..'/presentation.lua')
dofile(minetest.get_modpath('university')..'/welcome.lua')

-- Web API configuration can calling request_http_api() when load the environment
api_serverIP = "http://141.125.110.71:90/api/"
-- api_serverIP = "https://localhost:44357/api/"

http_api = minetest.request_http_api()
if not http_api then
	print("ERROR: in minetest.conf, this mod must be in secure.http_mods!")
end

--Set up default privileges
minetest.register_privilege("teacher", {
	description = "Teacher privilege for classroom mod",
	give_to_singleplayer = false
})

-- check privilege function
function check_teacher_priv(player)
	return minetest.check_player_privs(player:get_player_name(), { teacher = true })
end
