# awsprofile.fish

Fish shell plugin to switch between AWS profiles.  
Optimized for use with [fzf](https://github.com/junegunn/fzf).

## Features

- **List AWS profiles**: Lists all profiles found in `~/.aws/config`.
- **Switch AWS profile**: Switch profiles by setting `AWS_PROFILE` for the current shell session.
- **Interactive selection**: Interactive profile selection using fzf, if installed.
- **Direct selection**: You can specify the profile name directly as an argument.
- **Clear profile**: Clear profile with `awsprofile --clean`.
- **List profiles**: List profiles with `awsprofile --list`.
- **Error handling**: Warns if the profile does not exist or if the AWS config file is missing.
- **Shell completion**: Fish shell completions for profiles and flags.
- **Help and version**: Built-in help (`--help`) and version (`--version`) information.

## Usage

```sh
# Select profile interactively (If fzf is not installed, profiles will be listed for manual selection.)
awsprofile

# Directly switch to a profile
awsprofile <profile_name>

# Clear AWS_PROFILE
awsprofile --clean

# Print available profiles
awsprofile --list

# Show help
awsprofile --help

# Show version
awsprofile --version
```

## Important Notes

- The `AWS_PROFILE` environment variable is set globally (`-gx`) for the current shell session only, not universally across all sessions.
- Profile switching only affects the current Fish shell session and its child processes.

## Installation

```sh
fisher install LordBurrito/fish-aws-profile-switcher
```

## License

[0BSD](LICENSE)
