function failed
    ntfy publish "$ntfyTopic" \
        "$argv[1]:"\n"$(cat rip.log)"
end

if ! test -n "$ntfyTopic"
    echo "NTFY topic not set. Exiting."
    return 2
end

ntfy publish "$ntfyTopic" "CD rip starting..."
abcde $argv &>rip.log
set abcde_success $status
rg -q "SSL connect attempt failed" rip.log
set ssl_failed $status

if test "$ssl_failed" -eq 0
    failed "SSL Error"
    return 1
end

if test "$abcde_success" -eq 0
    ntfy publish "$ntfyTopic" "CD rip complete."
else
    failed "Unknown Error"
    return 1
end
