__zplug::core::cache::loadable()
{
    # Check if cache is up-to-date
    :
}

__zplug::core::cache::plugins()
{
    local repo="${1:?}"
    local -A tags
    local -aU unclassified_plugins
    local -aU load_plugins load_fpaths lazy_plugins nice_plugins
    local -aU ignore_patterns
    local -A reply_hash
    local plugin

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    # Packages to skip loading
    {
        # FROM tag
        if __zplug::core::sources::is_handler_defined check "$tags[from]"; then
            if ! __zplug::core::sources::use_handler check "$tags[from]" "$repo"; then
                return 1
            fi
        else
            if [[ ! -d $tags[dir] ]]; then
                return 1
            fi
        fi

        # IF tag
        if [[ -n $tags[if] ]]; then
            if ! eval "$tags[if]" 2> >(__zplug::io::log::capture) >/dev/null; then
                $is_verbose && __zplug::io::print::die "$tags[name]: (not loaded)\n"
                return 1
            fi
        fi

        # ON tag
        if [[ -n $tags[on] ]]; then
            __zplug::core::core::run_interfaces \
                'check' \
                ${~tags[on]}
            if (( $status != 0 )); then
                $is_verbose && __zplug::io::print::die "$tags[name]: (not loaded)\n"
                return 1
            fi
        fi
    }

    # Switch to the revision specified by its tags
    __zplug::utils::git::checkout "$repo"

    if __zplug::core::sources::is_handler_defined "load_plugin" "$tags[from]"; then
        # Custom handler for loading
        __zplug::core::sources::use_handler \
            "load_plugin" \
            "$tags[from]" \
            "$repo"
        reply_hash=( "$reply[@]" )

        # Temporary array until files get sorted into
        # {load,lazy,nice}_plugins
        unclassified_plugins=( ${(@f)reply_hash[unclassified_plugins]} )
        # Plugins
        load_plugins=( ${(@f)reply_hash[load_plugins]} )
        lazy_plugins=( ${(@f)reply_hash[lazy_plugins]} )
        nice_plugins=( ${(@f)reply_hash[nice_plugins]} )
        # fpath
        load_fpaths=( ${(@f)reply_hash[load_fpaths]} )

        if (( $#load_plugins > 0 )); then
            for plugin in "$load_plugins[@]"
            do
                __zplug::job::state::flock "$_zplug_cache[plugin]" "$plugin"
            done
        fi
        if (( $#nice_plugins > 0 )); then
            for plugin in "$nice_plugins[@]"
            do
                __zplug::job::state::flock "$_zplug_cache[before_plugin]" "$plugin"
                __zplug::job::state::flock "$_zplug_cache[after_plugin]" "$plugin"
            done
        fi
        if (( $#lazy_plugins > 0 )); then
            for plugin in "$lazy_plugin[@]"
            do
                __zplug::job::state::flock "$_zplug_cache[lazy_plugin]" "$plugin"
            done
        fi
        if (( $#load_fpaths > 0 )); then
            for plugin in "$load_fpaths[@]"
            do
                __zplug::job::state::flock "$_zplug_cache[fpath]" "$plugin"
            done
        fi
    fi
}

__zplug::core::cache::commands()
{
    local repo="${1:?}"
    local -A tags
    local -aU unclassified_plugins
    local -aU load_plugins load_fpaths lazy_plugins nice_plugins
    local -aU ignore_patterns
    local -A reply_hash
    local -A load_commands
    local pkg

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    # Packages to skip loading
    {
        # FROM tag
        if __zplug::core::sources::is_handler_defined check "$tags[from]"; then
            if ! __zplug::core::sources::use_handler check "$tags[from]" "$repo"; then
                return 1
            fi
        else
            if [[ ! -d $tags[dir] ]]; then
                return 1
            fi
        fi

        # IF tag
        if [[ -n $tags[if] ]]; then
            if ! eval "$tags[if]" 2> >(__zplug::io::log::capture) >/dev/null; then
                $is_verbose && __zplug::io::print::die "$tags[name]: (not loaded)\n"
                return 1
            fi
        fi

        # ON tag
        if [[ -n $tags[on] ]]; then
            __zplug::core::core::run_interfaces \
                'check' \
                ${~tags[on]}
            if (( $status != 0 )); then
                $is_verbose && __zplug::io::print::die "$tags[name]: (not loaded)\n"
                return 1
            fi
        fi
    }

    # Switch to the revision specified by its tags
    __zplug::utils::git::checkout "$repo"

    if __zplug::core::sources::is_handler_defined "load_command" "$tags[from]"; then
        __zplug::core::sources::use_handler \
            "load_command" \
            "$tags[from]" \
            "$repo"
        reply_hash=( "$reply[@]" )

        load_fpaths+=( ${(@f)reply_hash[load_fpaths]} )
        for pair in ${(@f)reply_hash[load_commands]}
        do
            # Each line (pair) is null character-separated
            load_commands+=( ${(@s:\0:)pair} )
        done

        if (( $#load_commands > 0 )); then
            for pkg in "${(k)load_commands[@]}"
            do
                __zplug::job::state::flock "$_zplug_cache[command]" "$pkg $load_commands[$pkg]"
            done
        fi
        if (( $#load_fpaths > 0 )); then
            for pkg in "$load_fpaths[@]"
            do
                __zplug::job::state::flock "$_zplug_cache[fpath]" "$pkg"
            done
        fi
    fi
}

__zplug::core::cache::themes()
{
    local repo="${1:?}"
    local -A tags
    local -aU unclassified_plugins
    local -aU load_plugins load_fpaths lazy_plugins nice_plugins
    local -aU ignore_patterns
    local -A reply_hash
    local pkg

    __zplug::core::tags::parse "$repo"
    tags=( "${reply[@]}" )

    # Packages to skip loading
    {
        # FROM tag
        if __zplug::core::sources::is_handler_defined check "$tags[from]"; then
            if ! __zplug::core::sources::use_handler check "$tags[from]" "$repo"; then
                return 1
            fi
        else
            if [[ ! -d $tags[dir] ]]; then
                return 1
            fi
        fi

        # IF tag
        if [[ -n $tags[if] ]]; then
            if ! eval "$tags[if]" 2> >(__zplug::io::log::capture) >/dev/null; then
                $is_verbose && __zplug::io::print::die "$tags[name]: (not loaded)\n"
                return 1
            fi
        fi

        # ON tag
        if [[ -n $tags[on] ]]; then
            __zplug::core::core::run_interfaces \
                'check' \
                ${~tags[on]}
            if (( $status != 0 )); then
                $is_verbose && __zplug::io::print::die "$tags[name]: (not loaded)\n"
                return 1
            fi
        fi
    }

    # Switch to the revision specified by its tags
    __zplug::utils::git::checkout "$repo"

    if __zplug::core::sources::is_handler_defined "load_theme" "$tags[from]"; then
        # Custom handler for loading
        __zplug::core::sources::use_handler \
            "load_theme" \
            "$tags[from]" \
            "$repo"
        reply_hash=( "$reply[@]" )
        load_themes=( ${(@f)reply_hash[load_themes]} "$unclassified_plugins[@]" )

        if (( $#load_themes > 0 )); then
            for pkg in "$load_themes[@]"
            do
                __zplug::job::state::flock "$_zplug_cache[theme]" "$pkg"
            done
        fi
    fi
    setopt prompt_subst
}
