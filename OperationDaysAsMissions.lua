_G.OperationDaysAsMissions = _G.OperationDaysAsMissions or {}
if not _G.OperationDaysAsMissions.setup then
    OperationDaysAsMissions.setup = true

    OperationDaysAsMissions.mod_path = ModPath
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
end
