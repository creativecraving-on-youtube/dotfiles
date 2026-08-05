#!/usr/bin/env bash
set -eo pipefail
TARGET="${TARGET:-$HOME}"
REPO_DIR="$PWD/dotfiles"

main() {
    local env_name="$(repo_setup "$@")"
    install "$env_name"
}

repo_setup() {
    local REPO=https://github.com/creativecraving-on-youtube/dotfiles
    local BARE="dotfiles.git"
    mkdir 1>&2 -p "$REPO_DIR"
    cd "$REPO_DIR"

    [[ -e "$BARE" ]] || {
        echo >&2 "Setting up dotfiles in \"$PWD\""
        git 1>&2 clone --bare "$REPO" "$BARE"
    }

    local env_name
    if [[ $# -gt 0 ]] then
        env_name="$1"; shift
    else
        GIT_DIR="$BARE" git branch | grep 1>&2 "env/"
        read -p "Select a branch> env/" env_name
    fi
    local env="env/${env_name}"

    [[ -e "$env_name" ]] || {
        echo >&2 "Checking out \"$env\""
        GIT_DIR="$BARE" git 1>&2 worktree add "./$env_name" "$env"
    }
    echo "$env_name"
}

install() {
    local env_name="$1"; shift
    local env="env/$env_name"

    cd "$REPO_DIR/$env_name"

    # TODO: Use -print0 & friends once we work out the algorithm

    find files -mindepth 1 -print0 | while read -d $'\0' source; do
        [[ "$source" == "files/dot" ]] && continue

        target="$TARGET/.${source#files/dot/}"

        # Simple case: File is missing, or a link
	[[ -L "$target" ]] && rm "$target"
        [[ ! -e "$target" ]] && {
            echo "Installing \"$(basename "$source")\" to \"$target\""
            ln -svT "$PWD/$source" "$target"
            continue
        }

        # Source and target are both directories; link over source contents instead
        [[ -d "$target" && -d "$source" ]] && continue

        if [[ -f "$target" && -f "$source" ]]; then
            local target_sum="$(b2sum --binary "$target")"
            target_sum="${target_sum%% *}"
            local source_sum="$(b2sum --binary "$source")"
            source_sum="${source_sum%% *}"

            if [[ "$source_sum" == "$target_sum" ]]; then
                echo "Target is identical to Source. Converting to symlink"
                echo >&2 "Error: Must manually verify and remove target"
                echo >&2 "Target: \"$target\""
                exit 1
                ln -svT --force "$source" "$target"
            else
                cat >&2 <<EOF
Error: target exists and does not match source
source: (file) "$source"
checksum: $source_sum
target: (file) "$target"
checksum: $target_sum
EOF
                exit 1
            fi
        fi

        cat >&2 <<EOF
Error: target exists and does not match source
Source: ($(file_type_str "$source")) $source
Target: ($(file_type_str "$target")) $target
EOF
        exit 1
    done
}

file_type_str() {
    local filename="$1"; shift
    [[ -e "$filename" ]] || { echo "non-existent"; return; }
    [[ -f "$filename" ]] && { echo "file"; return; }
    [[ -d "$filename" ]] && { echo "directory"; return; }
    [[ -L "$filename" ]] && { echo "link"; return; }
    echo "other"
}

(main "$@") # Use a subshell to avoid changing directories for the script user
