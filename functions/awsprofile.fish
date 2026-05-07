function __awsprofile_list_profiles
    set -l config_file "$HOME/.aws/config"
    if test -f "$config_file"
        awk '/^\[profile / {gsub(/^\[profile |\]$/, ""); print} /^\[default\]/ {print "default"}' "$config_file"
    else
        echo "AWS config not found at $config_file" >&2
        return 2
    end
end

function __awsprofile_show_help
    echo "Usage: awsprofile [OPTIONS] [PROFILE]"
    echo ""
    echo "Switch between AWS profiles or manage AWS_PROFILE environment variable"
    echo ""
    echo "Options:"
    echo "  -c, --clean       Clear AWS_PROFILE environment variable"
    echo "  -l, --list        List available AWS profiles"
    echo "  -h, --help        Show this help message"
    echo "  -v, --version     Show version information"
    echo ""
    echo "Examples:"
    echo "  awsprofile              # Interactive selection with fzf"
    echo "  awsprofile production   # Switch to 'production' profile"
    echo "  awsprofile --clean      # Clear AWS_PROFILE"
    echo "  awsprofile --list       # List all profiles"
end

function awsprofile --description "Switch active AWS profile"
    set -l profilename ""

    # Parse positional argument and flags
    argparse --ignore-unknown 'c/clean' 'l/list' 'h/help' 'v/version' -- $argv
    or return 1

    if set -q _flag_help
        __awsprofile_show_help
        return 0
    end

    if set -q _flag_version
        echo "awsprofile version 1.1.0"
        return 0
    end

    if set -q _flag_clean
        set -e AWS_PROFILE
        echo "Cleared AWS_PROFILE environment variable." >&2
        return 0
    end

    if set -q _flag_list
        __awsprofile_list_profiles
        return 0
    end

    # Cache profiles list to avoid multiple calls
    set -l profiles (__awsprofile_list_profiles)
    or return 2

    # Get profile name from remaining arguments
    if test (count $argv) -ge 1
        set profilename $argv[1]
    end

    if test -z "$profilename"
        if type -q fzf
            set profilename (printf '%s\n' $profiles | fzf --header="Select AWS profile")
            if test -z "$profilename"
                echo "No profile selected." >&2
                return 0
            end
        else
            echo "Install fzf for interactive profile selection, or provide a profile name as argument." >&2
            echo "Available profiles:" >&2
            printf '%s\n' $profiles
            return 0
        end
    end

    if not printf '%s\n' $profiles | grep -Fqx -- "$profilename"
        echo "Profile '$profilename' not found in AWS config." >&2
        return 2
    end

    set -gx AWS_PROFILE "$profilename"
    echo "Switched to AWS profile: $profilename" >&2
end
