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
})
