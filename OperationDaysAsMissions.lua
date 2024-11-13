_G.OperationDaysAsMissions = _G.OperationDaysAsMissions or {}
if not _G.OperationDaysAsMissions.setup then
    OperationDaysAsMissions.setup = true

    OperationDaysAsMissions.mod_path = ModPath
    OperationDaysAsMissions._defaults_path = ModPath .. "defaults.json"
    OperationDaysAsMissions._options_path = SavePath .. "OperationDaysAsMissions.json"
    OperationDaysAsMissions._defaults = {}
    OperationDaysAsMissions._options = {}

    OperationDaysAsMissions.icons_index = {
        {
            name = "oper_flamable",
            days = 4
        },
        {
            name = "clear_skies",
            days = 6
        }
    }

    function OperationDaysAsMissions:LoadDefaults()
        local default_file = io.open(self._defaults_path, "r")
        if default_file then
            self._defaults = json.decode(default_file:read("*all"))
            default_file:close()
        end
    end

    function OperationDaysAsMissions:Load()
        self._options = deep_clone(self._defaults)
        local file = io.open(self._options_path, "r")
        if file then
            local config = json.decode(file:read("*all"))
            file:close()
            if config and type(config) == "table" then
                for k, v in pairs(config) do
                    self._options[k] = v
                end
            end
        end
    end

    function OperationDaysAsMissions:Save()
        local file = io.open(self._options_path, "w+")
        if file then
            file:write(json.encode(self._options))
            file:close()
        end
    end

    function OperationDaysAsMissions:GetDefault(id)
        return self._defaults[id]
    end

    function OperationDaysAsMissions:GetOption(id)
        return self._options[id]
    end

    function OperationDaysAsMissions:SetOption(id, value, save)
        self._options[id] = value
        if save then
            self:Save()
        end
    end

    function OperationDaysAsMissions:get_icon_meta_by_operation_name(operation)
        for _, v in ipairs(self.icons_index) do
            if v.name == operation then
                return v
            end
        end
        return nil
    end

    OperationDaysAsMissions:LoadDefaults()
    OperationDaysAsMissions:Load()
end
