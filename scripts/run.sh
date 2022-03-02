rm segs/*.mkv
ls segs/

NOW=$(($(date +%s%N)/1000000))
NOW="$2"
echo Now: $NOW msecs

ffmpeg -vaapi_device /dev/dri/renderD128 -f video4linux2 \
    -s 720x480 \
    -i "$1" \
    -vf 'format=nv12|vaapi,hwupload' \
    -force_key_frames "expr:gte(t,n_forced*2)" \
    -map 0 -c:v h264_vaapi \
    -f segment -segment_time 2 \
    -framerate 30 \
    -segment_format matroska \
    -metadata "ORG.MYOPENBACKBACK.ZLS=1" \
    -metadata "ORG.MYOPENBACKBACK.START=$NOW" \
    segs/%d.mkv
