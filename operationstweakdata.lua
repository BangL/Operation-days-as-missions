Hooks:PostHook(OperationsTweakData, "init", "operation_days_as_missions_operations_tweak_data_init", function(self)
    -- go through all existing operations and semi-clone their events as fake missions..
    for _, operation_name in pairs(self._operations_index) do
        for i, events in ipairs(self.missions[operation_name].events_index_template) do -- we only use registered 'events' by reading events_index_template. the full events list would have more, non-existing ones.
            -- for event_id, just take first one here, doesnt matter. starting it will randomize it anyways, according to the full template used above. the values we copy should be equal across all of them anyways
            local event_id = events[1]
            local event = self.missions[operation_name].events[event_id]
            local fake_mission = {
                name_id = event.name_id,
                briefing_id = event.progress_text_id,
                icon_menu = event.icon_menu,
                icon_hud = event.icon_hud,
                start_in_stealth = event.start_in_stealth,
                stealth_bonus = event.stealth_bonus,
                xp = event.xp,
                proxy_operation = operation_name,
                proxy_event = i,
                job_type = OperationsTweakData.JOB_TYPE_RAID,
                progression_groups = { OperationsTweakData.PROGRESSION_GROUP_INITIAL, OperationsTweakData.PROGRESSION_GROUP_STANDARD },
            }

            -- register fake mission
            local mission_name = self:get_fake_mission_id(operation_name, event_id) -- and here, it just serves uniqueness
            self.missions[mission_name] = fake_mission
            table.insert(self._raids_index, mission_name)

            -- when one of these fake missions is started, we route everything to the operation/day instead,
            -- so clients without the mod also can handle the situation
            -- just adding missions to OperationsTweakData.missions would break clients without the mod, as they dont have them!
            -- which would be logical, if this would be new content.
            -- but as these missions are technically existing content, that would be inacceptable :)
            -- so instead, we never send these fake missions to clients, instead we trick them into a faked saved operation,
            -- which we then.. never 'complete'
            -- (see RaidJobManager:set_selected_job and :start_next_event)
        end
    end
    self._custom_icons_loaded = false
    self:reload_fake_mission_icons()
end)

function OperationsTweakData:get_fake_mission_id(operation_name, event_id)
    return "fake_mission_" .. operation_name .. "_" .. event_id
end

function OperationsTweakData:reload_fake_mission_icons()
    local load_custom_icons = OperationDaysAsMissions:GetOption("use_custom_icons")
    if self._custom_icons_loaded == load_custom_icons then
        return
    end
    self._custom_icons_loaded = load_custom_icons

    for _, operation_name in pairs(self._operations_index) do
        for i, events in ipairs(self.missions[operation_name].events_index_template) do
            local event_id = events[1]
            local mission_name = self:get_fake_mission_id(operation_name, event_id)
            local icon_meta = load_custom_icons and
                OperationDaysAsMissions:get_icon_meta_by_operation_name(operation_name) or nil
            if self.missions[mission_name] then
                self.missions[mission_name].icon_menu = (icon_meta and icon_meta.days >= i) and
                    (operation_name .. "_" .. tostring(i)) or self.missions[operation_name].events[event_id].icon_menu
            end
        end
    end
end
