# awsprofile.fish

Fish shell plugin to switch between AWS profiles.  
Works better with [fzf](https://github.com/junegunn/fzf).

## Features

- **List AWS profiles**: Lists all profiles found in `~/.aws/config`.
- **Switch AWS profile**: Sets the `AWS_PROFILE` environment variable to the selected profile.
- **Interactive selection**: If [fzf](https://github.com/junegunn/fzf) is installed, allows interactive profile selection.
- **Direct selection**: You can specify the profile name directly as an argument.
- **Clear profile (flag)**: Run `awsprofile --clean` to unset the `AWS_PROFILE` variable.
- **Clear profile (positional)**: `awsprofile clean` is still supported for backwards compatibility.
- **List subcommand and flag**: `awsprofile list` or `awsprofile --list` prints all available profiles.
- **Error handling**: Warns if the profile does not exist or if the AWS config file is missing.
- **Profile listing fallback**: If `fzf` is not installed, prints available profiles for manual selection.
- **Shell completion**: The plugin provides completions for `awsprofile` using available profiles and flags.

## Usage

```sh
# Select profile interactively (requires fzf)
awsprofile

# Directly pick profile
awsprofile <profile_name>

# Clear AWS_PROFILE (flag)
awsprofile --clean

# Clear AWS_PROFILE (positional, legacy)
awsprofile clean

# Print available profiles (subcommand)
awsprofile list

# Print available profiles (flag)
awsprofile --list
```

If `fzf` is not installed, running `awsprofile` will print a list of available profiles.

The plugin also installs Fish completions that suggest profile names and provide `--clean`/`--list` options when typing `awsprofile`.

## Installation

```sh
fisher install LordBurrito/fish-aws-profile-switcher
```

## License

[0BSD](LICENSE)
