#!/bin/bash -e
# CRUM - Catalog Removable USB Media

VERSION='0.1.0'

CRUMDBDIR="${HOME}/.crum"
CRUMDB="${CRUMDBDIR}/crumdb"

check_crumdbdir() {
        if [[ ! -d "${CRUMDBDIR}" ]]; then
                mkdir "${CRUMDBDIR}" || return 1
        fi
        return 0
}

helpmsg() {
        echo "Usage:"
        echo " crum.sh -v|h"
        echo " crum.sh -a|r <mountpoint>"
        echo " crum.sh -f <file>"
        echo ""
        echo "Options:"
        echo " -a       add usb media to catalog"
        echo " -r       remove usb media from catalog"
        echo " -f       find specified file"
        echo ""
        echo " -h       display this help"
        echo " -v       display version"
}

add_media() {
        MOUNTPOINT="${1}"
        if [[ -d "${MOUNTPOINT}" ]]; then
                MEDIANAME=$(basename "${MOUNTPOINT}")
                find "${MOUNTPOINT}" |
                while IFS= read -r FOUND;
                do
                        echo "${MEDIANAME},${FOUND}" >> "${CRUMDB}"
                done
        fi
}

remove_media() {
        if [[ -w "${CRUMDB}" ]]; then
                MEDIANAME="${1}"
                sed -i /"${MEDIANAME}"/d "${CRUMDB}"
        else
                echo "No catalog or catalog write protected"
        fi
}

find_file() {
        if [[ -r "${CRUMDB}" ]]; then
                FILE="${1}"
                grep "${FILE}" "${CRUMDB}" | cut -d, -f1
        else
                echo "No catalog or catalog unreadable"
        fi
}

check_crumdbdir || exit 1
while getopts 'hva:r:' OPT
do
        case "${OPT}" in
                'v') echo "crum.sh v${VERSION}"
                     ;;
                'h') helpmsg
                     ;;
                'a') add_media "${OPTARG}"
                     ;;
                'f') find_file "${OPTARG}"
                     ;;
                'r') remove_media "${OPTARG}"
                     ;;
                *)   echo "Invalid option: ${OPT}"
                     helpmsg
                     ;;
        esac
done

exit 0;
                   