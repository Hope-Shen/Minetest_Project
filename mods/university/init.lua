print("++++++++ The minetest server started successfully +++++++++")


--Load File
-- dofile(minetest.get_modpath('university')..'/chatcommand.lua')
dofile(minetest.get_modpath('university')..'/whitelist.lua')
dofile(minetest.get_modpath('university')..'/attendance_registration.lua')
dofile(minetest.get_modpath('university')..'/universityTool.lua')
dofile(minetest.get_modpath('university')..'/presentation.lua')
dofile(minetest.get_modpath('university')..'/welcome.lua')
http_api = minetest.request_http_api()
if not http_api then
	print("ERROR: in minetest.conf, this mod must be in secure.http_mods!")
end
api_serverIP = "https://localhost:44357/api/"