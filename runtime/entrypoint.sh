#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: Apache-2.0 AND MIT
set -e

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
source "${CUR_DIR_PATH}/common/common.bash"
source "${CUR_DIR_PATH}/common/api_dict.bash"

print_intro()
{
    cat <<-'EOF'
 _____            _                          _    ____          _
| ____|_ ____   _(_)___  __ _  __ _  ___  __| |  |  _ \ ___  __| |_   ___  __
|  _| | '_ \ \ / / / __|/ _` |/ _` |/ _ \/ _` |  | |_) / _ \/ _` | | | \ \/ /
| |___| | | \ V /| \__ \ (_| | (_| |  __/ (_| |  |  _ <  __/ (_| | |_| |>  <
|_____|_| |_|\_/ |_|___/\__,_|\__, |\___|\__,_|  |_| \_\___|\__,_|\__,_/_/\_\
******************************|___/******************************************
EOF
    local version
    version="$( cat "${CUR_DIR_PATH}/../VERSION" )"
    printf "%b%s%b\n\n" "\033[1m\033[4m" "Version ${version}" "\033[0m"
}
readonly -f print_intro

validate_env_vars()
{
    local env_vars
    readarray -d $'\n' -t env_vars <<< "$( printenv | sed 's@=.*@@' | grep -e '^GOURCE*' -e '^RUNTIME*' -e '^RENDER*' -e '^PREVIEW*' | sort -d )"
    for var in "${env_vars[@]}"; do
        if [ -n "${var}" ] && (( _api_dict[${var}] != 1 )); then
            log_warn "${var} is not a valid or known variable."
            unset "${var}"
        fi
    done
   if (( RUNTIME_PRINT_VARS == 1 )); then
        log_notice "Printing Configuration Variables:"
        local print_vars
        readarray -d $'\n' -t print_vars <<< "$( printenv | grep -e '^GOURCE*' -e '^RUNTIME*' -e '^RENDER*' -e '^PREVIEW*' | sort -d )"
        for var in "${print_vars[@]}"; do
            printf "        %s\n" "${var}"
        done
    fi
}
readonly -f validate_env_vars

parse_args()
{
    while [[ $# -gt 0 ]]; do
        local k
        k="$1"
        case $k in
            DEBUG)
                declare -grix RT_DEBUG=1
                log_warn "DEBUG Flag Invoked."
                ;;
            HOLD)
                log_info "Test mode enabled. Spinning main thread. Run docker stop on container when complete."
                trap 'exit 143' SIGTERM # exit = 128 + 15 (SIGTERM)
                tail -f /dev/null & wait ${!}
                exit 0
                ;;
            TEST)
                declare -grix RT_TEST=1
                log_warn "TEST Flag Invoked."
                mkdir -p "${ER_ROOT_DIRECTORY}"/save \
                ;;
            NO_RUN)
                declare -grix RT_NO_RUN=1
                log_warn "NO_RUN Flag Invoked."
                ;;
        esac
        shift
    done
}
readonly -f parse_args

parse_configs()
{
    # Check runtime mode.
    echo 0 > "${ER_ROOT_DIRECTORY}"/html/live_preview
    if [[ "${RUNTIME_LIVE_PREVIEW}" == "1" ]]; then
        log_info "Live Preview is enabled."
        declare -grix RT_LIVE_PREVIEW=1
        echo 1 > "${ER_ROOT_DIRECTORY}"/html/live_preview
    fi

    # Check for video saving mode
    if [ -d "${ER_ROOT_DIRECTORY}"/video ]; then
        log_info "Video export directory is set."
        log_warn "Will save video file into assigned export directory, then quit upon completion."
        declare -grix RT_LOCAL_OUTPUT=1
    else
        mkdir -p "${ER_ROOT_DIRECTORY}"/video
    fi

    # Print which Gource release is being used
    # RT_GOURCE_EXEC remains here from deprecation of gource_nightly option,
    # in case of future use with multiple gource subtypes.
    # For now, only one subtype is supported (gource)
    declare -grx RT_GOURCE_EXEC='gource'
    log_info "Using runtime ${RT_GOURCE_EXEC}: $("${RT_GOURCE_EXEC}" -h | head -n 1)."

    # Check for custom Gource log input
    if [ -f "${ER_ROOT_DIRECTORY}"/resources/gource.log ]; then
        log_info "Using provided Gource log file."
        cp "${ER_ROOT_DIRECTORY}"/resources/gource.log "${ER_ROOT_DIRECTORY}"/tmp/gource.log
        declare -grix RT_CUSTOM_LOG=1
    fi

    # Check for Gource log output
    if [ -d "${ER_ROOT_DIRECTORY}"/output ]; then
        log_info "Saving generated Gource log file."
        log_warn "Envisaged Redux will exit upon saving Gource Log file."
        declare -grix RT_SAVE_LOG=1
    fi

    # Check for avatar directory mount.
    if [ -d "${ER_ROOT_DIRECTORY}"/resources/avatars ]; then
        log_info "Using avatars directory."
        declare -grix RT_AVATARS=1
    fi

    # Check for captions
    if [ -f "${ER_ROOT_DIRECTORY}"/resources/captions.txt ]; then
        log_info "Using captions file."
        declare -grix RT_CAPTIONS=1
    fi

    # Check for default user image
    if [ -f "${ER_ROOT_DIRECTORY}"/resources/default_user.image ]; then
        log_info "Using default user image file."
        declare -grix RT_DEFAULT_USER_IMAGE=1
    fi

    # Check for font file
    if [ -f "${ER_ROOT_DIRECTORY}"/resources/font ]; then
        log_info "Using provided font file."
        declare -grix RT_FONT_FILE=1
    fi

    # Check for background image
    if [ -f "${ER_ROOT_DIRECTORY}"/resources/background.image ]; then
        log_info "Using background image file."
        declare -grix RT_BACKGROUND_IMAGE=1
    fi

    # Check for logo
    if [ -f "${ER_ROOT_DIRECTORY}"/resources/logo.image ]; then
        log_notice "Possible logo file detected. Attempting to transform..."
        set +e
        convert -geometry x160 "${ER_ROOT_DIRECTORY}"/resources/logo.image "${ER_ROOT_DIRECTORY}"/resources/logo_txfrmed.image
        if (( $? != 0 )); then
            log_error "Error: ImageMagick failed to convert the supplied logo file. Please check image file passed or convert to another format."
            exit 1
        else
            log_success "Success. Using logo file."
            declare -grix RT_LOGO=1
        fi
    fi


    # Check if repo exists
    if (( RT_CUSTOM_LOG != 1 )) && [ ! -d "${ER_ROOT_DIRECTORY}"/resources/vcs_source ]
    then
        log_error "Error: No VCS source found: ${ER_ROOT_DIRECTORY}/resources/vcs_source does not exist."
        exit 1
    fi
    return 0
}
readonly -f parse_configs

process_single_repo()
{
    if [ -n "$1" ]; then
        declare dir="$1"
        declare dir_slash_suffix="${dir}/"
        declare dir_slash_prefix="/${dir}"
        log_notice "Checking ${dir}... "
        if [ ! -d "${ER_ROOT_DIRECTORY}"/resources/vcs_source/"${dir}"/.git ]; then
            log_warn "${ER_ROOT_DIRECTORY}/vcs_source/${dir} is not a git repo, Skipping..."
            return 0
        fi
    fi
    if [[ "${RUNTIME_RECURSE_SUBMODULES}" == "1" ]]; then
        [ -z "${dir}" ] && log_info "Recursing through submodules." || log_info "Recursing through submodules in ${dir}"
        declare -a submod_paths=()
        git -C "${ER_ROOT_DIRECTORY}"/resources/vcs_source/"${dir}" submodule foreach --recursive '( echo "submod_paths+=($displaypath)" >> '"${ER_ROOT_DIRECTORY}"'/submods.bash )'
        if [ ! -f "${ER_ROOT_DIRECTORY}"/submods.bash ]; then
            [ -z "${dir}" ] && log_warn "No submodules found. Continuing..." || log_warn "No submodules found in ${dir}. Continuing..."
        else
            source submods.bash
            rm submods.bash
        fi
        submod_paths+=('') # include parent of course
        for submod_path in "${submod_paths[@]}"; do
            ((++total_count))
            gource --output-custom-log "${ER_ROOT_DIRECTORY}"/tmp/gource"${total_count}".log "${ER_ROOT_DIRECTORY}"/resources/vcs_source/"${dir}"/"${submod_path}"
            if [ -n "${submod_path}" ]; then
                sed -i -r "s#(.+)\|#\1|/${dir_slash_suffix}${submod_path}#" "${ER_ROOT_DIRECTORY}"/tmp/gource"${total_count}".log
                ((++submod_count))
            else
                sed -i -r "s#(.+)\|#\1|${dir_slash_prefix}#" "${ER_ROOT_DIRECTORY}"/tmp/gource${total_count}.log
            fi
            logs+=("${ER_ROOT_DIRECTORY}/tmp/gource${total_count}.log")
        done
    else
        # Single repo no submods - simple case.
        ((++total_count))
        gource --output-custom-log "${ER_ROOT_DIRECTORY}"/tmp/gource"${total_count}".log "${ER_ROOT_DIRECTORY}"/resources/vcs_source/"${dir}"
        sed -i -r "s#(.+)\|#\1|${dir_slash_prefix}#" "${ER_ROOT_DIRECTORY}"/tmp/gource${total_count}.log
        logs+=("${ER_ROOT_DIRECTORY}/tmp/gource${total_count}.log")
    fi
    return 0
}
readonly -f process_single_repo

multi_color_generator()
{
    log_info "Multi-color directory generator enabled."
    [ -n "${COLOR_GROUPS_SEED}" ] && RANDOM=${COLOR_GROUPS_SEED}
    declare -i mc_red mc_green mc_blue
    declare str_red str_green str_blue str_hex
    declare -i diff_a diff_b diff_c max_val min_val
    declare default_hex_color="#FFFFFF"
    declare -a dir_list parent_dir_list

    [ -n "${COLOR_GROUPS_CENTER_COLOR}" ] && default_hex_color="#${COLOR_GROUPS_CENTER_COLOR}"

    readarray -d $'\n' -t dir_list <<< "$( pcregrep -o '(?<=\\|/).*(?=/)' "${ER_ROOT_DIRECTORY}"/tmp/gource.log | sort | uniq )"
    for dir in ${dir_list[@]}; do
        [[ "${dir}" == *'/'* ]] && continue
        parent_dir_list+=("${dir}")
    done

    for dir in ${parent_dir_list[@]}; do
        # Generate a random hex
        log_debug "   dir: ${dir}"
        if [ -z "${COLOR_GROUPS_SEED}" ]; then
            mc_red=$(( $( od -A n -t d -N 1 /dev/urandom | tr -d ' \n' ) % 256 ))
            mc_green=$(( $( od -A n -t d -N 1 /dev/urandom | tr -d ' \n' ) % 256 ))
            mc_blue=$(( $( od -A n -t d -N 1 /dev/urandom | tr -d ' \n' ) % 256 ))
        else
            mc_red=$(( RANDOM % 256 ))
            mc_green=$(( RANDOM % 256 ))
            mc_blue=$(( RANDOM % 256 ))
        fi
        log_debug "red: ${mc_red}"
        log_debug "green: ${mc_green}"
        log_debug "blue: ${mc_blue}"

        # Check if all 3 are below a threshold. If so, invert and use as value of color.
        if (( mc_red < 128 )) && (( mc_green < 128 )) && (( mc_blue < 128 )); then
            mc_red=$(( 256 - mc_red ))
            mc_green=$(( 256 - mc_green ))
            mc_blue=$(( 256 - mc_blue ))
        fi

        # If the colors are too close to grey/white, perform color vibrance enhancement.
        diff_a=$(( mc_red - mc_green ))
        diff_b=$(( mc_green - mc_blue ))
        diff_c=$(( mc_red - mc_blue ))
        # Perform abs()
        diff_a=${diff_a#-}
        diff_b=${diff_b#-}
        diff_c=${diff_c#-}
        if (( $(( diff_a + diff_b + diff_c )) < 256 )); then
            max_val=$(( mc_red > mc_green ? mc_red : mc_green ))
            max_val=$(( max_val > mc_blue ? max_val : mc_blue ))
            min_val=$(( mc_red < mc_green ? mc_red : mc_green ))
            min_val=$(( min_val < mc_blue ? min_val : mc_blue ))
            (( mc_red == max_val )) && mc_red=$(( $(( mc_red + $(( mc_red / 4 )) )) < 255 ? $(( mc_red + $(( mc_red / 4 )) )) : 255 ))
            (( mc_green == max_val )) && mc_green=$(( $(( mc_green + $(( mc_green / 4 )) )) < 255 ? $(( mc_green + $(( mc_green / 4 )) )) : 255 ))
            (( mc_blue == max_val )) && mc_blue=$(( $(( mc_blue + $(( mc_blue / 4 )) )) < 255 ? $(( mc_blue + $(( mc_blue / 4 )) )) : 255 ))
            (( mc_red == min_val )) && mc_red=$(( mc_red / 3 ))
            (( mc_green == min_val )) && mc_green=$(( mc_green / 3 ))
            (( mc_blue == min_val )) && mc_blue=$(( mc_blue / 3 ))
        fi
        log_debug "red_final: ${mc_red}"
        log_debug "green_final: ${mc_green}"
        log_debug "blue_final: ${mc_blue}"
        str_red="$( printf '%.2x' "${mc_red}" | awk '{ print toupper($0) }' )"
        str_green="$( printf '%.2x' "${mc_green}" | awk '{ print toupper($0) }' )"
        str_blue="$( printf '%.2x' "${mc_blue}" | awk '{ print toupper($0) }' )"

        str_hex="#${str_red}${str_green}${str_blue}"
        log_debug "hex: ${str_hex}"

        # Append str_hex on lines with directory name 
        sed -i -r "/\|\/${dir}\// { s@\$@|${str_hex}@ }" "${ER_ROOT_DIRECTORY}"/tmp/gource.log
    done

    # Append default_hex_color on lines that do not have an existing |# pattern already set
    sed -i -r "/\|#/! { s@\$@|${default_hex_color}@ }" "${ER_ROOT_DIRECTORY}"/tmp/gource.log

    # Remove all pound symbols from the file to finish it off
    sed -i -r "s/#//g" "${ER_ROOT_DIRECTORY}"/tmp/gource.log
}
readonly -f multi_color_generator

process_repos()
{
    declare -ig total_count=0
    declare -ig submod_count=0
    declare -ag logs=()
    # Check if this is a single or multi repo
    if [ ! -d "${ER_ROOT_DIRECTORY}"/resources/vcs_source/.git ]; then
        log_info "Detected potential multi-repo git input. Assuming this is a multi-repo directory."
        while read -r dir; do 
            process_single_repo "${dir}"
        done <<< "$(find "${ER_ROOT_DIRECTORY}"/resources/vcs_source/ -maxdepth 1 -mindepth 1 -type d -printf '%f\n')"
    else
        log_info "Detected single-repo git repository input."
        process_single_repo
    fi
    # Check if numlogs = 0 
    (( ${#logs[@]} == 0 )) && log_error "Error: No suitable repos found in "${ER_ROOT_DIRECTORY}"/resources/vcs_source." && exit 1

    # Sort all logs
    sort -n "${logs[@]}" > "${ER_ROOT_DIRECTORY}"/tmp/gource.log
    rm "${logs[@]}"
    log_success "Processed $((total_count-submod_count)) repos and ${submod_count} submodules."

    [ "${RUNTIME_COLOR_GROUPS}" = "1" ] && multi_color_generator

    (( RT_TEST == 1 )) && cp "${ER_ROOT_DIRECTORY}"/tmp/gource.log "${ER_ROOT_DIRECTORY}"/save/gource.log
    if (( RT_SAVE_LOG == 1 )); then
        # Save gource.log file
        cp "${ER_ROOT_DIRECTORY}"/tmp/gource.log "${ER_ROOT_DIRECTORY}"/output/gource.log
        chmod 666 "${ER_ROOT_DIRECTORY}"/output/gource.log
        log_success "Gource log file saved. Exiting."
        exit 0
    fi
    log_info "Gource log generated."
    return 0
}
readonly -f process_repos

start_httpd()
{
    log_notice "Starting httpd..."
    cp "${ER_ROOT_DIRECTORY}"/html/processing_gource.html "${ER_ROOT_DIRECTORY}"/html/index.html
    lighttpd -f "${ER_ROOT_DIRECTORY}"/runtime/http.conf -D &
    _HTTPD_PID=$!
    typeset -gir _HTTPD_PID
    declare -i curl_exit_code=1
    declare -i watch_start=${SECONDS}
    while (( curl_exit_code != 0 )) && (( SECONDS - watch_start <= _HTTPD_TIMEOUT )); do
        curl -f --max-time 5 -s localhost:80 > /dev/null
        curl_exit_code=$?
    done
    if (( SECONDS - watch_start > _HTTPD_TIMEOUT )); then
        log_error "Timeout: httpd failed to start after ${_HTTPD_TIMEOUT} seconds. Observed error code [${curl_exit_code}]."
        stop_process ${_HTTPD_PID}
        exit 1
    fi
    log_success "httpd started successfully."
    return 0
}
readonly -f start_httpd

start_xvfb()
{
    log_notice "Starting Xvfb..."
    Xvfb :99 -ac -screen 0 "${XVFB_WHD}" -nocursor -noreset -nolisten tcp &
    _XVFB_PID=$!
    typeset -gir _XVFB_PID
    declare -i xdpy_exit_code=1
    declare -i watch_start=${SECONDS}
    while (( xdpy_exit_code != 0 )) && (( SECONDS - watch_start <= _XVFB_TIMEOUT )); do
        xdpyinfo -display :99 > /dev/null 2>&1
        xdpy_exit_code=$?
    done
    if (( SECONDS - watch_start > _XVFB_TIMEOUT )); then
        log_error "Timeout: Xvfb failed to start after ${_XVFB_TIMEOUT} seconds. Observed error code [${xdpy_exit_code}]."
        stop_process ${_HTTPD_PID}
        stop_process ${_XVFB_PID}
        exit 1
    fi
    log_success "Xvfb started successfully."
    return 0
}
readonly -f start_xvfb

start_services()
{
    # Disable strict error handling during this method.
    set +e

    start_httpd

    start_xvfb

    # Re-enable strict error handling
    set -e

    # Trap the services so we can shut them down properly later.
    trap 'stop_process ${_XVFB_PID};\
          stop_process ${_HTTPD_PID};\
          exit 130;' SIGINT
    trap 'stop_process ${_XVFB_PID};\
          stop_process ${_HTTPD_PID};\
          log_warn "Exiting with code [${EXIT_CODE}].";\
          exit ${EXIT_CODE};' SIGTERM
    return 0
}
readonly -f start_services


start_render()
{
    # Disable strict error handling during this method.
    set +e
    # Start the visualization render based on template chosen
    if [ -n "${RUNTIME_TEMPLATE}" ]; then
        case ${RUNTIME_TEMPLATE} in
            border)
                log_info "Using [${RUNTIME_TEMPLATE}] template..."
                "${ER_ROOT_DIRECTORY}"/runtime/templates/border.sh
                EXIT_CODE=$?
                ;;
            standard)
                log_info "Using [${RUNTIME_TEMPLATE}] template..."
                "${ER_ROOT_DIRECTORY}"/runtime/templates/standard.sh
                EXIT_CODE=$?
                ;;
            *)
                log_error "Unknown template option [${RUNTIME_TEMPLATE}]."
                EXIT_CODE=1
                kill -TERM $$
                ;;
        esac
    else
        log_info "No template choice provided, Defaulting to standard template..."
        "${ER_ROOT_DIRECTORY}"/runtime/templates/standard.sh
        EXIT_CODE=$?
    fi

    # Clean temporary files
    log_notice "Cleaning temporary files."
    rm -rf "${ER_ROOT_DIRECTORY}"/tmp

    (( EXIT_CODE != 0 )) && kill -TERM $$

    # Re-enable strict error handling
    set -e
    return 0
}
readonly -f start_render


handle_output()
{
    # Handle output
    if [ -f "${ER_ROOT_DIRECTORY}"/video/output.mp4 ]; then
        chmod 666 "${ER_ROOT_DIRECTORY}"/video/output.mp4
        log_success "Visualization process is complete."
    else
        log_error "Visualization process failed."
        EXIT_CODE=1
        kill -TERM $$
    fi

    if (( RT_LOCAL_OUTPUT != 1 )); then
        log_info "Output video file avaliable to download from web interface."
        log_info "To exit, send SIGINT (Ctrl+C)."
        # Wait for httpd process to end.
        while kill -0 ${_HTTPD_PID} >/dev/null 2>&1; do
            wait
        done
    fi
    return 0
}
readonly -f handle_output

main()
{
    # Print Banner
    print_intro

    # Local Constants
    declare -gri _XVFB_TIMEOUT=60
    declare -gri _HTTPD_TIMEOUT=15

    # Set exit code
    declare -gix EXIT_CODE=0

    # Create our temp directory
    mkdir -p "${ER_ROOT_DIRECTORY}"/tmp

    # Validate env vars
    validate_env_vars

    # Parse input args if any
    parse_args "$@"

    # Handle runtime configuration and checks
    parse_configs

    # Traverse repos and generate git logs to process
    (( RT_CUSTOM_LOG != 1 )) && process_repos

    # Activate services
    (( RT_NO_RUN != 1 )) && start_services

    # Start visualization rendering process
    start_render

    # Handle the output
    (( RT_NO_RUN != 1 )) && handle_output



    # Exit
    stop_process ${_XVFB_PID}
    stop_process ${_HTTPD_PID}
    log_debug "Exiting at end with code [${EXIT_CODE}]."
    exit ${EXIT_CODE}
}
readonly -f main


# Run main
main "$@"
