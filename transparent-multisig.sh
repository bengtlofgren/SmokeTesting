# Creates a transparent multisignature account and then funds it with 2000 NAM
# Usage: ./transparent-multisig.sh <namada_bin_dir>
# Create a new account

validate_arguments() {
    # The script expects 3 arguments:
    # 1. The path to the directory containing the Namada binaries
    
    if [ "$#" != 1 ]; then
        echo "Error: Invalid number of arguments. Expected 1 argument : NAMADA_BIN_DIR."
        exit 1
    fi

    NAMADA_BIN_DIR="$1"

    if [ ! -d "$NAMADA_BIN_DIR" ]; then
        echo "Error: Invalid directory. The specified directory does not exist."
        echo "Trying to find $NAMADA_BIN_DIR"
        exit 1
    fi

    local namadac_path="$NAMADA_BIN_DIR/namadac"

    if [ ! -x "$namadac_path" ]; then
        echo "Error: Missing executable 'namadac' in the specified directory."
        exit 1
    fi
}

validate_arguments "$@"

SMOKE_TESTING_PREFIX="smoketesting-"
SCRIPT_DIR="$(dirname $0)"

RND=$(echo $RANDOM | md5sum | head -c 20; echo;)
DEFAULT_PREFIX="${SMOKE_TESTING_PREFIX}${RND}-"
PREFIX="${PREFIX:-$DEFAULT_PREFIX}"

source $SCRIPT_DIR/utils/commands.sh

basic_multisig "$NAMADA_BIN_DIR" "$PREFIX"

source $SCRIPT_DIR/utils/validate_output.sh

ACCOUNT_NAME=$PREFIX"multisig-account-1"
SIGNING_KEYS="${PREFIX}multisig-key-1,${PREFIX}multisig-key-2"
check_balance "$NAMADA_BIN_DIR" $ACCOUNT_NAME 2000