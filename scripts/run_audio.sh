rm segs/*.mka
ls segs/

NOW=$(($(date +%s%N)/1000000))
NOW="$1"
echo Now: $NOW msecs

arecord -f cd |
    ffmpeg -i pipe:0 -c:a libvorbis \
    -f segment -segment_time 2 \
    -segment_format mka \
    -metadata "ORG.MYOPENBACKBACK.ZLS=1" \
    -metadata "ORG.MYOPENBACKBACK.START=$NOW" \
    segs/%d.mka
