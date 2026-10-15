function __awsprofile_show_help
    echo "Usage: awsprofile [OPTIONS] [PROFILE]"
    echo ""
    echo "Switch between AWS profiles or manage AWS_PROFILE environment variable"
    echo ""
    echo "Options:"
    echo "  -c, --clean       Clear AWS_PROFILE environment variable"
    echo "  -l, --list        List available AWS profiles"
    echo "  -u, --universal   Set AWS_PROFILE as a universal variable (persists across sessions)"
    echo "  -h, --help        Show this help message"
    echo "  -v, --version     Show version information"
    echo ""
    echo "Profiles are read from ~/.aws/config and ~/.aws/credentials"
    echo "(or \$AWS_CONFIG_FILE and \$AWS_SHARED_CREDENTIALS_FILE if set)."
    echo ""
    echo "Examples:"
    echo "  awsprofile               # Interactive selection with fzf"
    echo "  awsprofile production    # Switch to 'production' profile"
    echo "  awsprofile -u production # Switch and persist across sessions"
    echo "  awsprofile --clean       # Clear AWS_PROFILE"
    echo "  awsprofile --list        # List all profiles"
end

function awsprofile --description "Switch active AWS profile"
    set -l awsprofile_version 1.2.0

    # -x: mutually exclusive flags, -X 1: at most one profile argument
    argparse -X 1 -x c,l,h,v -x u,c -x u,l -x u,h -x u,v \
        'c/clean' 'l/list' 'u/universal' 'h/help' 'v/version' -- $argv
    or return 1

    if set -q _flag_help
        __awsprofile_show_help
        return 0
    end

    if set -q _flag_version
        echo "awsprofile version $awsprofile_version"
        return 0
    end

    if set -q _flag_clean; or set -q _flag_list
        if test (count $argv) -gt 0
            echo "awsprofile: --clean and --list do not take a profile argument" >&2
            return 1
        end
    end

    if set -q _flag_clean
        set -e AWS_PROFILE
        set -e -U __awsprofile_set_universal
        echo "Cleared AWS_PROFILE environment variable." >&2
        return 0
    end

    if set -q _flag_list
        __awsprofile_list_profiles
        return $status
    end

    # Cache profiles list to avoid multiple calls
    set -l profiles (__awsprofile_list_profiles)
    or return 2

    set -l profilename $argv[1]

    if test -z "$profilename"
        set -l current "(none)"
        set -q AWS_PROFILE; and set current $AWS_PROFILE

        if type -q fzf
            set profilename (printf '%s\n' $profiles | fzf --header="Select AWS profile (current: $current)")
            if test -z "$profilename"
                echo "No profile selected." >&2
                return 1
            end
        else
            echo "Current profile: $current" >&2
            echo "Install fzf for interactive profile selection, or provide a profile name as argument." >&2
            echo "Available profiles:" >&2
            printf '%s\n' $profiles
            return 1
        end
    end

    if not contains -- "$profilename" $profiles
        echo "Profile '$profilename' not found in AWS config." >&2
        return 2
    end

    if set -q _flag_universal
        set -Ux AWS_PROFILE "$profilename"
        # Remembered so the uninstall hook only removes a universal variable we created
        set -U __awsprofile_set_universal 1
        echo "Switched to AWS profile: $profilename (universal)" >&2
    else
        set -gx AWS_PROFILE "$profilename"
        echo "Switched to AWS profile: $profilename" >&2
    end
end
