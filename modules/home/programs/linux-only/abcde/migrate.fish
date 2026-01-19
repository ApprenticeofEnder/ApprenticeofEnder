for folder in (fd -d 1 -t d '-')
    set split_folder (string split - $folder)
    set artist $split_folder[1]
    set album $split_folder[2]
    echo "Moving '$folder' to '$artist/$album'"
    mkdir $artist || echo "Folder exists: $artist"
    mv $folder "$artist/$album"
end
