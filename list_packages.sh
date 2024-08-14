#!/usr/bin/env bash

usage() {
    cat <<EOF

listp - CLI tool for package listing

Options:

-h - show help
-s - set device id. Needed if there is more than 1 device connected. Autocomplete is on for this option 
EOF
}

# Auto-completion function
_listp() {
    # Array variable storing the possible completions.
    COMPREPLY=()

    # Pointer to current & previous completion word
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD - 1]}

    if [[ ${cur} == -* ]]; then
        COMPREPLY=($(compgen -W "-s -h" -- "$cur")) #   Generate the completion matches and load them into $COMPREPLY array.
        return 0
    fi

    # Use the compgen for specific CLI options
    case "$prev" in
    -s) COMPREPLY=($(compgen -W "$(adb devices | awk '{if (NR > 1) print $1}')" -- "$cur")) ;;
    esac

    return 0
}

listp() {
    cmd="adb "

    local SERIAL_ID=""

    while getopts ":hs:" opt_char; do
        case $opt_char in
        s) SERIAL_ID=$OPTARG ;;
        h)
            usage
            return 1
            ;;
        \?) # invalid option provided
            echo "Invalid option provided\n"
            usage
            return 1
            ;;
        *)
            usage
            return 1
            ;;
        esac
    done

    shift $((OPTIND - 1))

    _setSerialId $SERIAL_ID

    _showPackages $cmd
}

# Set serial id of device
_setSerialId() {
    if [ ! -z "$1" ]; then
        echo "Serial ID: $1"
        cmd+="-s $1 "
    fi
}

# Execute command and parse results
_showPackages() {
    local result=$(eval "$@" shell cmd package list packages -3 | awk -F: '{print $2}')

    if [ -z $result ]; then
        echo "No packages found\nCheck if app is runnung on your device or package name is correct"
    else
        echo "Package list:"
        echo "$result"
    fi
}

# Assign the auto-completion function
complete -F _listp listp
