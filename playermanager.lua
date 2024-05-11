local update_carry_to_peer_original = PlayerManager.update_carry_to_peer

function PlayerManager:update_carry_to_peer(peer, ...)
    update_carry_to_peer_original(self, peer, ...)
    -- send warning that this isnt a real operation for dropin
    if managers.chat and managers.raid_job and managers.raid_job:current_job() and managers.raid_job:current_job().is_fake_operation then
        DelayedCalls:Add("operation_days_as_missions_drop_in_notification", 1, function()
            managers.raid_job:notify_proxied_operation()
        end)
    end
end
