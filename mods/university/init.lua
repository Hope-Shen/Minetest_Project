print("++++++++ The minetest server started successfully +++++++++")


--Load File
-- dofile(minetest.get_modpath('university')..'/chatcommand.lua')
dofile(minetest.get_modpath('university')..'/whitelist.lua')
dofile(minetest.get_modpath('university')..'/attendance_registration.lua')
dofile(minetest.get_modpath('university')..'/universityTool.lua')
dofile(minetest.get_modpath('university')..'/presentation.lua')
dofile(minetest.get_modpath('university')..'/welcome.lua')