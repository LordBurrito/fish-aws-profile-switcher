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
    set -l doclean 0
    set -l dolist 0
    set -l profilename
    # Parse flags
    for token in $argv
        switch $token
            case '--clean'
                set doclean 1
                set argv (string match -v -- "--clean" $argv)
            case '--list'
                set dolist 1
                set argv (string match -v -- "--list" $argv)
        end
    end
    # First positional argument is profile name
    if test (count $argv) -ge 1
        set profilename $argv[1]
    end
    if test $doclean -eq 1 -o "$profilename" = "clean"
        set -e AWS_PROFILE
        echo "Cleared AWS_PROFILE environment variable."
        return 0
    end
    if test $dolist -eq 1 -o "$profilename" = "list"
        __awsprofile_list_profiles
        return 0
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
