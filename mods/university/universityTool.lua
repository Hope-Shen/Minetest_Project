minetest.register_node("university:wood_table", {
	description = "This is wood_table",
	tiles = {
		"Table_wood.png"
	},
	groups = {crumbly =3, stone=1},
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
})
