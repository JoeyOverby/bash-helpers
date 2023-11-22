

# https://stackoverflow.com/questions/11393817/read-lines-from-a-file-into-a-bash-array
read_into_array {
    fileToRead="$1"
    variable="$2"

    IFS=$'\n' read -d '' -r -a $variable < $fileToRead

    echo "All Lines: "
    echo "${$variable[@]}"
}