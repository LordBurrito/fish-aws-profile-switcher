complete \
  --command awsprofile \
  --exclusive 

complete \
  --command awsprofile \
  --condition '__fish_use_subcommand' \
  --arguments '__awsprofile_list_profiles'
