NOW=$(($(date +%s%N)/1000000))
echo START=$NOW

bash run.sh /dev/video2 $NOW &
sleep 3s
bash run_audio.sh $NOW &
wait
