obs = obslua

local source_def = {}
source_def.id = "zls_input_source"
source_def.type = obslua.OBS_SOURCE_TYPE_INPUT
source_def.output_flags = bit.bor(obslua.OBS_SOURCE_ASYNC_VIDEO, obslua.OBS_SOURCE_AUDIO)

source_def.get_name = function()
    return "ZLS Input"
end

source_def.create = function(settings, source)
    -- typically source data would be stored as a table
    local my_source_data = {}
    my_source_data.width = 640
    my_source_data.height = 480

    local path = script_path() .. '../sources/2.mkv.raw.y420'
    local file = loadfile(path, 'rb')
    local size = 27648000
    local frame_size = size / 60

    --local frame
    --repeat
    --
    --until not frame

    local frame = {}
    frame.width = my_source_data.width
    frame.height = my_source_data.height
    frame.format = obs.VIDEO_FORMAT_I420
    frame.linesize = {}
    frame.timestamp = obs.os_gettime_ns()
    frame.data = { file }

    obs.obs_source_output_video(source, frame)

    return my_source_data
end

-- register the source
obslua.obs_register_source(source_def)
