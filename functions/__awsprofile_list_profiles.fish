function __awsprofile_list_profiles --description "List AWS profiles from the config and credentials files"
    set -l config_file "$HOME/.aws/config"
    set -q AWS_CONFIG_FILE; and set config_file $AWS_CONFIG_FILE
    set -l credentials_file "$HOME/.aws/credentials"
    set -q AWS_SHARED_CREDENTIALS_FILE; and set credentials_file $AWS_SHARED_CREDENTIALS_FILE

    # awk operands of the form var=value are assigned before the next file is read,
    # so each file is parsed with the right section syntax
    set -l operands
    test -f "$config_file"; and set -a operands mode=config "$config_file"
    test -f "$credentials_file"; and set -a operands mode=credentials "$credentials_file"

    if test (count $operands) -eq 0
        echo "No AWS config found at $config_file or $credentials_file" >&2
        return 2
    end

    # config:      [default], [profile NAME]  (other sections like [sso-session x] are skipped)
    # credentials: [NAME]
    # Tolerates CRLF line endings, surrounding whitespace and trailing comments.
    awk '
        { sub(/\r$/, "") }
        /^[ \t]*\[/ {
            name = $0
            sub(/^[ \t]*\[[ \t]*/, "", name)
            if (!sub(/[ \t]*\].*$/, "", name)) next
            if (mode == "config" && name != "default" && !sub(/^profile[ \t]+/, "", name)) next
            if (name != "" && !seen[name]++) print name
        }
    ' $operands
end
