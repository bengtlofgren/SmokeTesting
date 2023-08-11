RND=$(echo $RANDOM | md5sum | head -c 20; echo;)
DEFAULT_PREFIX="${SMOKE_TESTING_PREFIX}${RND}-"
PREFIX="${PREFIX:-$DEFAULT_PREFIX}"

SCRIPT_DIR="$(dirname $0)"
source $SCRIPT_DIR/utils/validate.sh
source $SCRIPT_DIR/utils/commands.sh

validate_arguments "$1"

echo "Creating a multisig account..."
basic_multisig "$NAMADA_BIN_DIR" "$PREFIX"

