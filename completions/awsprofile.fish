# ~/.config/fish/completions/awsprofile.fish

complete --command awsprofile --no-files --arguments "--clean" --description "Clean profiles variable"
complete --command awsprofile --no-files --arguments "--list" --description "List available profiles"
complete --command awsprofile --condition '__fish_use_subcommand' --arguments "(__awsprofile_list_profiles)" --description "AWS profile"