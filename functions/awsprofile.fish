function __awsprofile_list_profiles
    set config_file "$HOME/.aws/config"
    if test -f $config_file
        awk -F' ' '/^\[profile /{gsub(/\[profile |]/,"",$2); print $2} /^\[default\]/{print "default"}' $config_file
    else
        echo "AWS config not found at $config_file" >&2
        return 2
    end
end

function awsprofile --description "Switch active AWS profile"
    set -l profilename ""
    
    # Parse positional argument and flags
    argparse --ignore-unknown 'c/clean' 'l/list' -- $argv
    or return 1
    
    if set -q _flag_clean
        set -e AWS_PROFILE
        echo "Cleared AWS_PROFILE environment variable."
        return 0
    end
    
    if set -q _flag_list
        __awsprofile_list_profiles
        return 0
    end
    
    # Get profile name from remaining arguments
    if test (count $argv) -ge 1
        set profilename $argv[1]
    end
    
    if test -z "$profilename"
        if type -q fzf
            set profilename (__awsprofile_list_profiles | fzf --header="Select AWS profile")
            if test -z "$profilename"
                echo "No profile selected." >&2
                return 0
            end
        else
            echo "Install fzf for interactive profile selection, or provide a profile name as argument." >&2
            echo "Available profiles:"
            __awsprofile_list_profiles
            return 0
        end
    end
    
    if not __awsprofile_list_profiles | grep -qx -- "$profilename"
        echo "Profile '$profilename' not found in AWS config." >&2
        return 2
    end
    
    set -Ux AWS_PROFILE $profilename
    echo "Switched to AWS profile: $profilename"
end
