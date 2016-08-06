#!/usr/bin/env bash

# Written by rekoil 2016-08-06

find . -name "*.avi" -print0 | while IFS= read -r -d $'\0' line; do
    # Set variables
    bak="$HOME/songfile-backups"
    if [ ! -d "${bak}" ]; then
        mkdir -p "${bak}"
    fi
    dir="$(dirname "${line}")"
    avi="$(basename "${line}")"
    echo "Found: ${avi} in ${dir}"

    # Convert video
    mp4="${avi%.avi}.mp4"
    if [ -e "${dir}"/"${mp4}" ]; then
        rm "${dir}"/"${mp4}"
    fi
    echo "  Converting to: ${mp4}"
    pv "${dir}"/"${avi}" | ffmpeg -i pipe:0 -v warning -strict -2 "${dir}"/"${mp4}"

    # Update song txt file
    echo "  Updating song file(s)"
    find "${dir}" -name "*.txt" -print0 | while IFS= read -r -d $'\0' txt; do
        songfile="$(basename "${txt}")"
        # Backup first just in case, as this is important shit!
        cp "${txt}" "${bak}"/.
        # Convert non-utf-8 to utf-8
        encoding=$(file -bi "${txt}" | sed -e 's/.*[ ]charset=//')
        case "${encoding}" in
        utf-8|*ascii)
            echo "    ${songfile} has acceptable encoding: ${encoding}"
        ;;
        unknown*)
            echo "    ${songfile} has unknown encoding (${encoding}), update may fail!!!"
            ;;
        *)
            echo "    Converting ${songfile} to utf-8"
            iconv -f "${encoding}" -t "utf-8" "${txt}" -o "${txt}"
            ;;
        esac
        sed -i "s/$//" "${txt}"
        sed -i "/#VIDEO:/c\#VIDEO:${mp4}" "${txt}"
    echo "    Updated song file \"${songfile}\""
    done

    # Remove old video file
    echo "  Moving old video file \"${avi}\" to backup location"
    mv "${dir}"/"${avi}" "${bak}"/.
    echo
done
echo Conversion done.
