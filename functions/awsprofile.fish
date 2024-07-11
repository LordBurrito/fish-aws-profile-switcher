function __awsprofile_list_profiles
  cat ~/.aws/config | grep profile | cut -d " " -f 2 | cut -d "]" -f 1
end

function awsprofile \
  --description 'Switch active AWS profile' \
  --argument-names profile_name
  
  if test -z $profile_name
    if command -q fzf
      set profile_name (__awsprofile_list_profiles | fzf --header "Select AWS profile")
    else
      echo "Available profiles:"
      __awsprofile_list_profiles
    end
  end

  set -Ux AWS_PROFILE $profile_name
end
