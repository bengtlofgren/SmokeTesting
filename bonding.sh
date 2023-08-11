# This script takes two arguments:
# 1. The path to the directory containing the Namada binaries
# 2. The number of bonds to make

# TODO: This script is currently broken. It needs to be fixed.


SCRIPT_DIR="$(dirname $0)"
source $SCRIPT_DIR/utils/validate.sh
source $SCRIPT_DIR/utils/commands.sh

validate_arguments "$1"

SMOKE_TESTING_PREFIX="smoketesting-" # Prefix for all smoketesting keys and addresses
RND=$(echo $RANDOM | md5sum | head -c 20; echo;)
DEFAULT_PREFIX="${SMOKE_TESTING_PREFIX}${RND}-"
PREFIX="${PREFIX:-$DEFAULT_PREFIX}"

NUM_LOOPS="$2"

# Assert that NUM_LOOPS is an integer
if ! [[ "$NUM_LOOPS" =~ ^[0-9]+$ ]]; then
    echo "Error: NUM_LOOPS must be an integer."
    exit 1
fi

# Generate key
echo "Generating key pairs..."

generate_keys "$NAMADA_BIN_DIR" "$PREFIX"

KEY_NAME="${PREFIX}multisig-key-1"

# Fund the key NUM_LOOPS times

for i in $(seq 1 $NUM_LOOPS); do
    fund_account_bo "$NAMADA_BIN_DIR" "$KEY_NAME" "$KEY_NAME" 1000
done

# echo "Sleeping for 10 seconds and a bit to allow transactions to be processed..."

# sleep $(($NUM_LOOPS + 10))

# Bond amount is NUM_LOOPS * 1000
BOND_AMOUNT=$(($NUM_LOOPS * 1000))

# init the validator account
init_validator "$NAMADA_BIN_DIR" "$PREFIX" "${PREFIX}validator-1"

bond_tokens "$NAMADA_BIN_DIR" "${PREFIX}multisig-key-1" $BOND_AMOUNT "${PREFIX}multisig-key-1" "${PREFIX}validator-1"