for file in (fd -d 1 '-')
    set album (string split - $file)[2]
    mv $file $album
end
