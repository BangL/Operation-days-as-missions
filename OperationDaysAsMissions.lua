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

    function OperationDaysAsMissions:getFilesR(root, sub, files)
        local sub = sub or ''
        local files = files or {}
        local path = Application:nice_path(root .. sub, true)
        for _, file in ipairs(SystemFS:list(path)) do
            table.insert(files, '.' .. sub .. '/' .. file)
        end
        for _, sub_dir in ipairs(SystemFS:list(path, true)) do
            files = self:getFilesR(root, sub .. '/' .. sub_dir, files)
        end
        return files
    end

    function OperationDaysAsMissions:PreloadAssets()
        local new_textures = {}
        local assets = Application:nice_path(self.mod_path .. "/assets", false)
        for _, file in ipairs(self:getFilesR(assets)) do
            local f = string.sub(file, 3)
            local dot = string.find(string.reverse(f), '%.')
            local id = string.sub(f, 1, -1 - dot)
            local ext = string.sub(f, 1 - dot)
            local file_id = Idstring(id)
            DB:create_entry(Idstring(ext), file_id, assets .. '/' .. id .. '.' .. ext)
            if (ext == "texture") then
                table.insert(new_textures, file_id)
            end
        end

        Application:reload_textures(new_textures)
    end

    OperationDaysAsMissions:PreloadAssets()
    OperationDaysAsMissions:LoadDefaults()
    OperationDaysAsMissions:Load()
end
