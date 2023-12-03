function main()
{
    declare -A env_files
    declare -a sorted_env_basenames
    local env_file env_filepath
    local pattern="*.sh"

    if [ $# -eq 0 ]; then
        export ENVMAN_D_DIRS=("${XDG_CONFIG_HOME:-${HOME}/.config}/envman/env.d")
    else
        export ENVMAN_D_DIRS=($@)
    fi

    find_env_files "${pattern}"
    for env_file in "${sorted_env_basenames[@]}"; do
        env_filepath=${env_files[$env_file]}
        if [[ "${-#*i}" != "$-" ]]; then
            source "${env_filepath}"
        else
            source "${env_filepath}" > /dev/null 2>&1
        fi
    done
}

find_env_files()
{
    local pattern="${1}"
    local file_paths=()
    local src_path src_file d_dir file_path

    for d_dir in "${ENVMAN_D_DIRS[@]}"; do
        if [[ -r "${d_dir}" ]]; then
            for src_path in $(find "${d_dir}" -name "${pattern}") ; do
                if [[ -r "${src_path}" ]]; then
                    file_paths+=("${src_path}")
                fi
            done
        fi
    done

    for file_path in "${file_paths[@]}"; do
        src_file=$(basename "$file_path")
        env_files["$src_file"]="$file_path"
    done

    get_sorted_keys
}

get_sorted_keys() {
    if [ -n "$ZSH_VERSION" ]; then
        sorted_env_basenames=($(printf "%s\n" "${(k)env_files[@]}" | sort))
    else
        sorted_env_basenames=($(printf "%s\n" "${!env_files[@]}" | sort))
    fi
}

main ${@}
