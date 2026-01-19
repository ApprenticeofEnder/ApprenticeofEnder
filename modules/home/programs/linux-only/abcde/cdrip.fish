ntfy publish $ntfyTopic "CD rip starting..."
abcde 2>&1 | tee rip.log
if test $status
    ntfy publish $ntfyTopic "CD rip complete."
else
    ntfy publish $ntfyTopic "$(cat rip.log)"
end
