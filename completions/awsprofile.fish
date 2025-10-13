complete --command awsprofile --no-files -f -a "'--clean --list'" -d 'Options'

complete \
  --command awsprofile \
  --condition '__fish_use_subcommand' \
  --arguments '(__awsprofile_list_profiles)'
