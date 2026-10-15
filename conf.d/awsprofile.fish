# Fisher emits awsprofile_uninstall when the plugin is removed
function _awsprofile_uninstall --on-event awsprofile_uninstall
    if set -q __awsprofile_set_universal
        set -e -U AWS_PROFILE
        set -e -U __awsprofile_set_universal
    end
    functions -e _awsprofile_uninstall
end
