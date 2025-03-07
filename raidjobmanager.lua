local set_selected_job_original = RaidJobManager.set_selected_job
local start_next_event_original = RaidJobManager.start_next_event
local save_game_original = RaidJobManager.save_game
local load_game_original = RaidJobManager.load_game

function RaidJobManager:set_selected_job(job_id, ...)
    if not Network:is_server() then
        return
    end

    local selected_job = tweak_data.operations:mission_data(job_id)

    if selected_job.proxy_operation ~= nil then
        self:start_proxied_operation(selected_job.proxy_operation, selected_job.proxy_event or 1)
    else
        set_selected_job_original(self, job_id, ...)
    end
end

function RaidJobManager:start_proxied_operation(operation, event)
    -- reset statistic sessions
    managers.statistics:stop_session({ success = false, quit = true })
    managers.network:session():send_to_peers_synched("stop_statistics_session", false, true, "")

    -- reset previous raid data
    self._loot_data = {}
    managers.global_state:reset_all_flags()

    -- build events_index, randomizes all days, even though we will use just one
    tweak_data.operations:randomize_operation(operation) -- writes into tweak_data

    -- get operation tweak data
    self._current_job = tweak_data.operations:mission_data(operation) -- clones from tweak_data, must therefore come after randomize_operation

    -- set event (day)
    self._current_job.current_event = event

    -- remember being fake, for skipping stuff later
    self._current_job.is_fake_operation = true

    local events_index = self._current_job.events_index
    if event == #events_index then                                -- if last day
        events_index = deep_clone(self._current_job.events_index) -- make copy of true index, for now. the original needs to stay untouched for set_job_info_by_current_job later

        -- add fake day so operation never counts as completed (prevent xp creep)
        -- this even works for clients without the mod, as we we sync this
        -- the only caveat is that it now shows 4/5 and 6/7, when it's actually 4/4 and 6/6
        table.insert(events_index, 1) -- the number doesnt event matter, we just wanna increase the size of events_index :)
    end

    -- send events_index to peers
    local list_delimited = table.concat(events_index, "|") -- not using OperationsTweakData:get_operation_indexes_delimited, as it uses original tweak_data
    managers.network:session():send_to_peers_synched("sync_randomize_operation", operation, list_delimited)

    -- sync set operation to peers
    managers.network:session():send_to_peers_synched("sync_current_job", operation)

    managers.network.matchmake:set_job_info_by_current_job() -- publish lobby information (uses self._current_job.events_index)

    -- also prevent own xp creep. (must be done after set_job_info_by_current_job!)
    self._current_job.events_index = events_index

    self._selected_job = self._current_job -- set fake job as selected_job
    self:start_event(event)                -- start day

    self:notify_proxied_operation()        -- send warning that this isnt a real operation
end

function RaidJobManager:start_next_event()
    -- if fake operation, skip all that next day / finish operation stuff an operation would normally do
    -- just trick the original function into handling this as 'mission' aka 'raid'
    -- that deletes our fake mission, cleans up lobby info, pops the 'select a mission' reminder, and shows the mission table waypoint
    if self._current_job and self._current_job.is_fake_operation then
        self._current_job.current_event = nil
        self._current_job.job_type = OperationsTweakData.JOB_TYPE_RAID
    end
    start_next_event_original(self)
end

function RaidJobManager:notify_proxied_operation()
    if managers.chat then
        managers.chat:send_message(ChatManager.GAME, "SYSTEM",
            "[" .. managers.localization:text("operation_days_as_missions") .. "] " ..
            managers.localization:text("operation_days_as_missions_warning"))
    end
end

function RaidJobManager:save_game(data, ...)
    -- drop failed/cancelled fake operation
    if self._need_to_save and self._current_job and self._current_job.is_fake_operation then
        self._need_to_save = nil
        log(string.format("[Operation days as missions] prevented saving fake-operation at slot: %s",
            tostring(self._current_save_slot)))
    end
    save_game_original(self, data, ...)
end

function RaidJobManager:load_game(data, ...)
    load_game_original(self, data, ...)
    local new_table = {}
    local fake_ops = 0
    local corrupt_ids = 0
    for slot_id, slot in pairs(self._save_slots or {}) do
        if slot.current_job.is_fake_operation then
            log(string.format("[Operation days as missions] deleting falsly saved fake-operation data at slot: %s.",
                tostring(slot_id)))
            fake_ops = fake_ops + 1
        else
            if type(slot_id) ~= "number" then
                log(string.format("[Operation days as missions] fixing corrupted operation data slot id: %s.",
                    tostring(slot_id)))
                corrupt_ids = corrupt_ids + 1
            end
            table.insert(new_table, slot)
        end
    end
    if fake_ops > 0 or corrupt_ids > 0 then
        self._save_slots = new_table
        if data.job_manager and data.job_manager.slots then
            data.job_manager.slots = self._save_slots
        end
    end
end
