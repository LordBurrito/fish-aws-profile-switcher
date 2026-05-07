# Fish AWS Profile Switcher

A lightweight [Fish shell](https://fishshell.com) plugin that makes switching between AWS profiles fast and effortless. Select profiles interactively with [fzf](https://github.com/junegunn/fzf), pass them directly as an argument, or manage the `AWS_PROFILE` environment variable with simple flags.

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```sh
fisher install LordBurrito/fish-aws-profile-switcher
```

### Prerequisites

- [Fish shell](https://fishshell.com) 3.0+
- An AWS config file at `~/.aws/config` with named profiles
- [fzf](https://github.com/junegunn/fzf) (optional, for interactive selection)

## How It Works

The plugin reads your `~/.aws/config` file, extracts all named profiles (including `default`), and sets the `AWS_PROFILE` environment variable in your current shell session. Any AWS CLI or SDK call in that session will then use the selected profile.

The profile is set with `set -gx`, meaning it applies to the current shell and any child processes, but **not** to other terminal windows or sessions.

## Usage

```
awsprofile [OPTIONS] [PROFILE]
```

### Interactive selection

Run `awsprofile` with no arguments to pick a profile using fzf:

```sh
$ awsprofile
# => fzf opens with a list of your AWS profiles
# => Select one and press Enter

Switched to AWS profile: production
```

If fzf is not installed, the available profiles are printed so you can re-run the command with a profile name.

### Direct selection

Pass the profile name as an argument to skip the interactive picker:

```sh
$ awsprofile staging
Switched to AWS profile: staging

$ aws s3 ls  # uses the "staging" profile
```

### List available profiles

```sh
$ awsprofile --list
default
dev
staging
production
```

### Clear the active profile

```sh
$ awsprofile --clean
Cleared AWS_PROFILE environment variable.
```

### Check the current profile

Since `awsprofile` sets a standard environment variable, you can check it anytime:

```sh
$ echo $AWS_PROFILE
production
```

### Options

| Flag | Description |
|------|-------------|
| `-c`, `--clean` | Clear the `AWS_PROFILE` environment variable |
| `-l`, `--list` | List all profiles found in `~/.aws/config` |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version information |

## Tab Completion

The plugin includes Fish completions out of the box. Tab-completing `awsprofile` will suggest all available profiles and flags -- no extra setup needed.

```sh
$ awsprofile <TAB>
default    dev    staging    production    --clean    --list    --help    --version
```

## Example Workflow

```sh
# See what profiles are available
$ awsprofile --list
default
dev
production

# Switch to dev
$ awsprofile dev
Switched to AWS profile: dev

# Do some work...
$ aws sts get-caller-identity

# Switch to production
$ awsprofile production
Switched to AWS profile: production

# Done for the day -- clear the profile
$ awsprofile --clean
Cleared AWS_PROFILE environment variable.
```

## License

[0BSD](LICENSE)
