validate_arguments() {
    # The script expects 1 argument:
    # 1. The path to the directory containing the Namada binaries
    
    if [ "$#" != 1 ]; then
        echo "Error: Invalid number of arguments. Expected 1 argument : NAMADA_BIN_DIR."
        exit 1
    fi

    NAMADA_BIN_DIR="$1"

    if [ ! -d "$NAMADA_BIN_DIR" ]; then
        echo "Error: Invalid directory. The specified directory does not exist."
        exit 1
    fi

    local namadac_path="$NAMADA_BIN_DIR/namadac"

    if [ ! -x "$namadac_path" ]; then
        echo "Error: Missing executable 'namadac' in the specified directory."
        exit 1
    fi
}