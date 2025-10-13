function __awsprofile_list_profiles
  if test -f "$HOME/.aws/config"
    awk '
      /^\[profile /{gsub(/^\[profile |\]$/, ""); print}
      /^\[default\]/{print "default"}
    ' "$HOME/.aws/config"
  else
    echo "AWS config not found at $HOME/.aws/config" >&2
    return 2
  end
end

function awsprofile --description "Switch active AWS profile" --argument-names profile_name
  if test -z "$profile_name"
      if command -v fzf > /dev/null
          set profile_name (__awsprofile_list_profiles | fzf --header "Select AWS profile")
          if test -z "$profile_name"
              # No profile selected, do not set AWS_PROFILE and just exit quietly
              return 0
          end
      else
          echo "Install fzf for interactive profile selection, or provide a profile name as argument."
          echo ""
          echo "Available profiles:"
          __awsprofile_list_profiles
          # Instead of returning 0 here, just do not set profile if no name given
          return 0
      end
  end

    # Accept flags --clean and --list for convenience while keeping existing positional args
    set -l do_clean 0
    set -l do_list 0

    # Parse flags manually to avoid external dependencies
    for token in $argv
      switch $token
        case --clean
          set do_clean 1
          # remove token from argv so it doesn't get treated as profile name
          set -e argv[(count $argv)]
        case --list
          set do_list 1
          set -e argv[(count $argv)]
        case --*
          # ignore other flags
        case '*'
          # positional args remain in argv
      end
    end

    # If positional profile name provided, use it (first positional arg)
    if test (count $argv) -ge 1
      set profile_name $argv[1]
    end

    # If --clean was provided, clear the variable and exit (positional "clean" still supported)
    if test $do_clean -eq 1 -o "$profile_name" = "clean"
      set -e AWS_PROFILE
      echo "Cleared AWS_PROFILE environment variable."
      return 0
    end

    # If --list provided or positional "list", print profiles and exit
    if test $do_list -eq 1 -o "$profile_name" = "list"
      __awsprofile_list_profiles
      return 0
    end

    if not __awsprofile_list_profiles | grep -qx -- "$profile_name"
      echo "Profile '$profile_name' not found in AWS config." >&2
      return 2
    end

    set -Ux AWS_PROFILE "$profile_name"
    echo "Switched to AWS profile: $profile_name"
end
