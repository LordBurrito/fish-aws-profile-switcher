#!/usr/bin/env fish
# Run with: fish tests/awsprofile.fish
# Each case runs in a fresh fish process with an isolated HOME and universal variable store.

set -g root (path resolve (status dirname)/..)
set -g failures 0
set -g passed 0
set -g fish_bin (command -s fish)

function setup
    set -g tmp (mktemp -d)
    mkdir -p $tmp/.aws $tmp/xdg
end

function teardown
    rm -rf $tmp
end

# Runs a command in an isolated fish; sets $out (stdout), $err (stderr) and $code
function run
    set -l script "set -p fish_function_path $root/functions; set -p fish_complete_path $root/completions; source $root/conf.d/awsprofile.fish; $argv"
    set -g out (env HOME=$tmp XDG_CONFIG_HOME=$tmp/xdg PATH=/usr/bin:/bin $fish_bin -c $script 2>$tmp/stderr)
    set -g code $status
    set -g err (cat $tmp/stderr)
end

function check -a name
    set -e argv[1]
    if $argv
        set passed (math $passed + 1)
    else
        set failures (math $failures + 1)
        echo "FAIL: $name"
        echo "  out:  $out"
        echo "  err:  $err"
        echo "  code: $code"
    end
end

function write_config
    printf '[default]\nregion = us-east-1\n\n[profile crlf]\r\nregion = eu-west-1\r\n[profile trailing]   \n[profile  spaced ]\n[profile commented] # prod\n[sso-session corp]\n[services svc]\n[profile default]\n' >$tmp/.aws/config
    printf '[default]\naws_access_key_id = x\n[keys-only]\naws_access_key_id = y\n' >$tmp/.aws/credentials
end

# --- profile parsing ---
setup; write_config
run awsprofile --list
check "list parses config and credentials" test "$out" = "default crlf trailing spaced commented keys-only"
check "list exits 0" test $code -eq 0
teardown

setup
mkdir $tmp/elsewhere
printf '[profile custom]\n' >$tmp/elsewhere/config
printf '[custom-creds]\n' >$tmp/elsewhere/credentials
run "set -gx AWS_CONFIG_FILE $tmp/elsewhere/config; set -gx AWS_SHARED_CREDENTIALS_FILE $tmp/elsewhere/credentials; awsprofile --list"
check "AWS_CONFIG_FILE and AWS_SHARED_CREDENTIALS_FILE respected" test "$out" = "custom custom-creds"
teardown

setup
run awsprofile --list
check "missing config exits 2" test $code -eq 2
run awsprofile foo
check "switch with missing config exits 2" test $code -eq 2
teardown

# --- switching ---
setup; write_config
run 'awsprofile trailing; echo $AWS_PROFILE'
check "switch to profile with trailing whitespace" test "$out" = trailing
run 'awsprofile keys-only; echo $AWS_PROFILE'
check "switch to credentials-only profile" test "$out" = keys-only
run awsprofile nope
check "unknown profile exits 2" test $code -eq 2
run awsprofile
check "no fzf and no argument exits 1" test $code -eq 1
check "no fzf lists profiles" string match -q "*keys-only*" -- "$out"
teardown

# --- argument validation ---
setup; write_config
run awsprofile -c default
check "--clean with profile is rejected" test $code -eq 1
run awsprofile -l -u
check "--list with --universal is rejected" test $code -eq 1
run awsprofile -l -c
check "--list with --clean is rejected" test $code -eq 1
run awsprofile default crlf
check "two profiles are rejected" test $code -eq 1
run awsprofile --version
check "--version" test "$out" = "awsprofile version 1.2.0" -a $code -eq 0
run awsprofile --help
check "--help exits 0" test $code -eq 0
teardown

# --- universal variable and uninstall ---
setup; write_config
run 'awsprofile -u crlf; echo $AWS_PROFILE'
check "universal switch" test "$out" = crlf
run 'echo $AWS_PROFILE'
check "universal persists across sessions" test "$out" = crlf
run 'awsprofile -c; echo "[$AWS_PROFILE]"; set -q __awsprofile_set_universal; echo $status'
check "clean removes universal and marker" test "$out" = "[] 1"
run 'awsprofile -u crlf; emit awsprofile_uninstall; echo "[$AWS_PROFILE]"'
check "uninstall removes universal set by plugin" test "$out" = "[]"
run 'set -Ux AWS_PROFILE mine; emit awsprofile_uninstall; echo $AWS_PROFILE'
check "uninstall keeps universal set by user" test "$out" = mine
teardown

# --- completions ---
setup; write_config
run "complete -C 'awsprofile ' | string replace -r '\t.*' ''"
check "completes profiles" string match -q "*keys-only*" -- "$out"
run "complete -C 'awsprofile crlf '"
check "no profiles after a profile" string match -qv "*keys-only*" -- "$out"
run "complete -C 'awsprofile -l '"
check "nothing after --list" test -z "$out"
run "complete -C 'awsprofile -'"
check "flags complete" string match -q "*--universal*" -- "$out"
teardown

setup
run "complete -C 'awsprofile '"
check "no stderr when config missing" test -z "$err"
teardown

echo "$passed passed, $failures failed"
test $failures -eq 0
