ntfy publish $ntfyTopic "CD rip starting..."
abcde >rip.log 2>&1
if test $status
    ntfy publish $ntfyTopic "CD rip complete."
else
    ntfy publish $ntfyTopic "$(cat rip.log)"
end
