function remove-trailing-spaces {
    sed -i 's/[ \t]*$//' "$1"
}
