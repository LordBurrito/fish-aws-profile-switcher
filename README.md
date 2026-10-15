# Fish AWS Profile Switcher

A lightweight [Fish shell](https://fishshell.com) plugin that makes switching between AWS profiles fast and effortless. Select profiles interactively with [fzf](https://github.com/junegunn/fzf), pass them directly as an argument, or manage the `AWS_PROFILE` environment variable with simple flags.

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```sh
fisher install LordBurrito/fish-aws-profile-switcher
```

### Prerequisites

- [Fish shell](https://fishshell.com) 3.0+
- AWS profiles in `~/.aws/config` and/or `~/.aws/credentials`
- [fzf](https://github.com/junegunn/fzf) (optional, for interactive selection)

## How It Works

The plugin reads profiles from `~/.aws/config` (`[default]` and `[profile NAME]` sections) and `~/.aws/credentials` (`[NAME]` sections), the same places the AWS CLI looks. If `AWS_CONFIG_FILE` or `AWS_SHARED_CREDENTIALS_FILE` is set, those paths are used instead. It then sets the `AWS_PROFILE` environment variable, so any AWS CLI or SDK call will use the selected profile.

By default the profile is set with `set -gx`, meaning it applies to the current shell and any child processes, but **not** to other terminal windows or sessions. Use `-u`/`--universal` to set it as a universal variable instead, which persists across all fish sessions and restarts.

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

The fzf header shows the currently active profile. If fzf is not installed, the current profile and the available profiles are printed so you can re-run the command with a profile name.

### Direct selection

Pass the profile name as an argument to skip the interactive picker:

```sh
$ awsprofile staging
Switched to AWS profile: staging

$ aws s3 ls  # uses the "staging" profile
```

### Persist across sessions

Use `-u` to set the profile as a universal variable, shared by every fish session (including ones opened later):

```sh
$ awsprofile -u production
Switched to AWS profile: production (universal)
```

A plain `awsprofile NAME` afterwards overrides it in the current shell only; other sessions keep the universal profile. `awsprofile --clean` removes both. If you uninstall the plugin with Fisher, a universal `AWS_PROFILE` set by `awsprofile -u` is removed as well.

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
| `-l`, `--list` | List all available profiles |
| `-u`, `--universal` | Set `AWS_PROFILE` as a universal variable (persists across sessions) |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version information |

`--clean`, `--list`, `--help` and `--version` can't be combined with each other or with `--universal`, and `--clean`/`--list` don't take a profile argument.

### Exit codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Invalid arguments, or no profile selected (fzf cancelled / fzf not installed) |
| `2` | No AWS config found, or the profile doesn't exist |

## Tab Completion

The plugin includes Fish completions out of the box. Tab-completing `awsprofile` will suggest all available profiles and flags -- no extra setup needed.

```sh
$ awsprofile <TAB>
default    dev    staging    production    --clean    --list    --universal    --help    --version
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

## Development

Run the test suite with:

```sh
fish tests/awsprofile.fish
```

## License

[0BSD](LICENSE)
