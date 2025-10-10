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

  if not __awsprofile_list_profiles | grep -qx -- "$profile_name"
    echo "Profile '$profile_name' not found in AWS config." >&2
    return 2
  end

  set -Ux AWS_PROFILE "$profile_name"
  echo "Switched to AWS profile: $profile_name"
end
