#!/bin/bash

# Argument parsing functions for dotfiles setup script

show_help() {
    cat << EOF
Usage: $0 [GLOBAL_OPTIONS] COMMAND [COMMAND_OPTIONS]

Commands:
    install       Install the application

Global Options:
    -h, --help          Show this help message

Command-Specific Options:

  install:
    --only-configs      Install only configuration files
    --env <ENV>         Override environment detection (omarchy, local, codespace)

Examples:
    $0 install
    $0 install --only-configs
    $0 install --env omarchy
EOF
}

parse_global_options() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            *)
                if [[ -n "$1" ]]; then
                    echo "Error: Unknown global option: $1"
                    echo "Use -h or --help for usage information"
                    exit 1
                fi
                shift
            ;;
        esac
    done
}

parse_install_options() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --only-configs)
                ONLY_CONFIGS=true
                shift
            ;;
            --env)
                if [[ -z "${2:-}" ]]; then
                    echo "Error: --env requires a value"
                    exit 1
                fi
                OS_ENV="$2"
                shift 2
            ;;
            *)
                echo "Error: Unknown install option: $1"
                echo "Valid install options: --only-configs, --env <ENV>"
                exit 1
            ;;
        esac
    done
}

parse_and_separate_args() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi
    local args=("$@")
    local command_found=false
    local in_command=false
    GLOBAL_ARGS=()
    COMMAND_ARGS=()
    COMMAND=""

    for arg in "${args[@]}"; do
        if [[ "$arg" == "install" ]]; then
            COMMAND="$arg"
            command_found=true
            in_command=true
            continue
        fi

        if [[ "$in_command" == false ]]; then
            GLOBAL_ARGS+=("$arg")
        else
            COMMAND_ARGS+=("$arg")
        fi
    done

    if [[ "$command_found" == false ]]; then
        echo "Error: No command specified"
        show_help
        exit 1
    fi
    parse_global_options "${GLOBAL_ARGS[@]}"
}