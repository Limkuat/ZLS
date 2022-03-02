REMOTE="http://192.168.0.16:65535"
DIR=segs

inotifywait -m -e CLOSE_WRITE $DIR | stdbuf -o0 grep -oE '[0-9]+\.mkv' | while read -r file; do
    echo Just appeared: $file
    echo "curl --data-binary "@$DIR/$file" $REMOTE/ingest/$file"
    curl -m 2 --data-binary @$DIR/$file $REMOTE/ingest/$file
    echo Sent $(du -sh $DIR/$file).
    echo Remove $DIR/$file
    rm $DIR/$file
done
