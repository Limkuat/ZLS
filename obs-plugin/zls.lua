print("Start Plugin ZLS Input :|")

obs = obslua

local dir = obs.os_opendir("/home/amaury/Programmes/MyOpenBackpack/zls/conciliator/segs")
print(dir)
local entry
repeat
    entry = obs.os_readdir(dir)
    if entry then
        print(entry.d_name)
    end
until not entry
obs.os_closedir(dir)

local source_def = {}
source_def.id = "zls_input_source"
source_def.type = obslua.OBS_SOURCE_TYPE_INPUT
source_def.output_flags = bit.bor(obslua.OBS_SOURCE_VIDEO, obslua.OBS_SOURCE_AUDIO)

source_def.get_name = function()
    return "ZLS Input Filesystem"
end

source_def.create = function(settings, source)
    -- typically source data would be stored as a table
    local my_source_data = {}
    -- TODO use video size instead
    my_source_data.width = 400
    my_source_data.height = 400
    return my_source_data
end

source_def.video_render = function(my_source_data, effect)
end

source_def.get_width = function(my_source_data)
    -- assuming the source data contains a 'width' key
    return my_source_data.width
end

source_def.get_height = function(my_source_data)
    -- assuming the source data contains a 'height' key
    return my_source_data.height
end

-- register the source
obslua.obs_register_source(source_def)
