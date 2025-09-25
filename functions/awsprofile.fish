function __awsprofile_list_profiles
  if test -f $HOME/.aws/config
    awk '/^\[profile /{gsub(/^\[profile |\]$/,""); print}' $HOME/.aws/config
  else
    echo "AWS config not found at $HOME/.aws/config"
  end
end

function awsprofile \
  --description "Switch active AWS profile" \
  --argument-names profile_name
  if test -z "$profile_name"
    if command -v fzf > /dev/null
      set profile_name (__awsprofile_list_profiles | fzf --header "Select AWS profile")
    else
      set profile_name (__awsprofile_list_profiles)
    end
  end

  if test -z "$profile_name"
    echo "No profile selected or provided."
    return 1
  end

  if not __awsprofile_list_profiles | grep -qx "$profile_name"
    echo "Profile '$profile_name' not found in AWS config."
    return 1
  end

  set -Ux AWS_PROFILE "$profile_name"
  echo "Switched to AWS profile: $profile_name"
end
