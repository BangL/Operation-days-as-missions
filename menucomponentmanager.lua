OperationDaysAsMissionsMenu = OperationDaysAsMissionsMenu or class(BLTMenu)

function OperationDaysAsMissionsMenu:Init(root)
    self:Title({
        text = "operation_days_as_missions",
    })
    self:Label({
        text = nil,
        localize = false,
        h = 8,
    })
    self:Toggle({
        name = "operation_days_as_missions_use_custom_icons",
        text = "operation_days_as_missions_use_custom_icons",
        default_value = OperationDaysAsMissions.Options:GetOption("use_custom_icons").default_value,
        value = OperationDaysAsMissions.Options:GetValue("use_custom_icons"),
        callback = callback(self, self, "ValueChanged", "use_custom_icons"),
    })

    self:LongRoundedButton2({
        name = "operation_days_as_missions_reset",
        text = "operation_days_as_missions_reset",
        localize = true,
        callback = callback(self, self, "Reset"),
        ignore_align = true,
        y = 832,
        x = 1472,
    })
end

function OperationDaysAsMissionsMenu:ValueChanged(key, value)
    if OperationDaysAsMissions.Options:GetValue(key) ~= value then
        self["_" .. key .. "_changed"] = true
        OperationDaysAsMissions.Options:SetValue(key, value)
    end
end

function OperationDaysAsMissionsMenu:Reset(value, item)
    QuickMenu:new(
        managers.localization:text("operation_days_as_missions_reset"),
        managers.localization:text("operation_days_as_missions_reset_confirm"),
        {
            [1] = {
                text = managers.localization:text("dialog_no"),
                is_cancel_button = true,
            },
            [2] = {
                text = managers.localization:text("dialog_yes"),
                callback = function()
                    OperationDaysAsMissions.Options:LoadDefaultValues()
                    self:ReloadMenu()
                    OperationDaysAsMissions.Options:Save()
                end,
            },
        },
        true
    )
end

function OperationDaysAsMissionsMenu:Close()
    OperationDaysAsMissions.Options:Save()
    if self._use_custom_icons_changed then
        tweak_data.operations:reload_fake_mission_icons()
    end
end

Hooks:Add("MenuComponentManagerInitialize", "OperationDaysAsMissions.MenuComponentManagerInitialize", function(self)
    RaidMenuHelper:CreateMenu({
        name = "OperationDaysAsMissions_options",
        name_id = "operation_days_as_missions",
        inject_menu = "blt_options",
        class = OperationDaysAsMissionsMenu
    })
end)
