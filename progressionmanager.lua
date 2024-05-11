local mission_unlocked_original = ProgressionManager.mission_unlocked
local get_mission_progression_original = ProgressionManager.get_mission_progression

function ProgressionManager:mission_unlocked(job_type, mission_id)
    job_type, mission_id = self:fake_operation_interceptor(job_type, mission_id)
    return mission_unlocked_original(self, job_type, mission_id)
end

function ProgressionManager:get_mission_progression(mission_type, mission_id)
    mission_type, mission_id = self:fake_operation_interceptor(mission_type, mission_id)
    return get_mission_progression_original(self, mission_type, mission_id)
end

-- reroute unlocked/progression checks to the proxied operation
-- fixes errors with those checks when opening the mission selection
function ProgressionManager:fake_operation_interceptor(mission_type, mission_id)
    if mission_type == OperationsTweakData.JOB_TYPE_RAID then
        local mission = tweak_data.operations.missions[mission_id]
        if type(mission) == "table" then
            local proxy_operation = mission.proxy_operation
            if type(proxy_operation) == "string" then
                return OperationsTweakData.JOB_TYPE_OPERATION, proxy_operation
            end
        end
    end
    return mission_type, mission_id
end
