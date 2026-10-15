# Succeeds if a flag that ends the command (-c, -l, -h, -v) has already been typed
function __awsprofile_seen_terminal_flag
    set -l tokens (commandline -opc)
    set -e tokens[1]
    argparse -i 'c/clean' 'l/list' 'u/universal' 'h/help' 'v/version' -- $tokens 2>/dev/null
    or return 1
    set -q _flag_clean; or set -q _flag_list; or set -q _flag_help; or set -q _flag_version
end

# Succeeds if a profile name can still be completed
function __awsprofile_needs_profile
    set -l tokens (commandline -opc)
    set -e tokens[1]
    argparse -i 'c/clean' 'l/list' 'u/universal' 'h/help' 'v/version' -- $tokens 2>/dev/null
    or return 1
    not set -q _flag_clean; and not set -q _flag_list; and not set -q _flag_help; and not set -q _flag_version
    and test (count $argv) -eq 0
end

complete --command awsprofile --no-files
complete --command awsprofile --condition "not __awsprofile_seen_terminal_flag" --short-option c --long-option clean --description "Clear AWS_PROFILE environment variable"
complete --command awsprofile --condition "not __awsprofile_seen_terminal_flag" --short-option l --long-option list --description "List available profiles"
complete --command awsprofile --condition "not __awsprofile_seen_terminal_flag" --short-option u --long-option universal --description "Set AWS_PROFILE as universal variable (persists across sessions)"
complete --command awsprofile --condition "not __awsprofile_seen_terminal_flag" --short-option h --long-option help --description "Show help message"
complete --command awsprofile --condition "not __awsprofile_seen_terminal_flag" --short-option v --long-option version --description "Show version information"
complete --command awsprofile --condition "__awsprofile_needs_profile" --arguments "(__awsprofile_list_profiles 2>/dev/null)" --description "AWS profile"
