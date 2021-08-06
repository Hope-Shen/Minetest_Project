local whitlist = {}
local admin = minetest.settings:get("name")

minetest.after(1, function()
  http_api.fetch({
    url = api_serverIP .. "Student",
    method="GET"
  }, function (res)
    -- print('whitelist: '..dump(res))
    if res.succeeded then
      local api_content = minetest.parse_json(minetest.parse_json(dump(res.data)))
      for i, j_str in pairs(api_content) do
        whitlist[#whitlist + 1 ] = j_str.studentId .. '-' .. j_str.studentName
      end
      print("Whitelist has been loaded successfully.")
    end
  end)
end)

minetest.register_on_prejoinplayer(function(name)
  if name == "singleplayer" or name == admin then
    return
  end

  for i, user in pairs(whitlist) do
    if name == user  then
  		return
  	end
  end
  return "You are not allow to join, please connect your professor."
end)
