function failed
    ntfy publish "$ntfyTopic" "$(cat rip.log)"
    return 1
end

if test -n "$ntfyTopic"
    echo "NTFY topic not set. Exiting."
    return 2
end

ntfy publish "$ntfyTopic" "CD rip starting..."
abcde $argv &>rip.log
set abcde_success $status
rg -q "SSL connect attempt failed" rip.log
set ssl_failed $status

if test "$ssl_failed"
    failed
end

if test "$abcde_success"
    ntfy publish "$ntfyTopic" "CD rip complete."
else
    failed
end
