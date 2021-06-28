sfinv.register_page("university:classroom", {
    title = "Classroom",
    get = function(self, player, context)
        return sfinv.make_formspec(player, context,
                "label[0.1,0.1;Hello world!]", true)
    end
})
