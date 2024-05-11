Hooks:PostHook(GuiTweakData, "init", "operation_days_as_missions_gui_tweak_data_init", function(self)
    local x = 0
    for _, meta in pairs(OperationDaysAsMissions.icons_index) do
        for i = 1, meta.days do
            self.icons[meta.name .. "_" .. tostring(i)] = {
                texture = "ui/atlas/raid_atlas_opdays",
                texture_rect = { 56 * x, 0, 56, 56 }
            }
            x = x + 1
        end
    end
end)
