find . -name "*.avi" -print0 | while IFS= read -r -d $'\0' line; do
    mp4="${line%.avi}.mp4"
    echo $line
    < /dev/null ffmpeg -i "$line" "$mp4"
done
