# This script takes two arguments:
# 1. The path to the directory containing the Namada binaries
# 2. The number of bonds to make


NODE="127.0.0.1:27657"
SCRIPT_DIR="$(dirname $0)"
source $SCRIPT_DIR/utils/validate.sh
source $SCRIPT_DIR/utils/commands.sh

BASE_DIR_2="/Users/unknowit/Library/Application Support/Namada"

validate_arguments "$1"

SMOKE_TESTING_PREFIX="smoketesting-" # Prefix for all smoketesting keys and addresses
RND=$(echo $RANDOM | md5sum | head -c 20; echo;)
DEFAULT_PREFIX="${SMOKE_TESTING_PREFIX}${RND}-"
PREFIX="${PREFIX:-$DEFAULT_PREFIX}"

# Get the validator addresses\
echo $NAMADA_BIN_DIR

validator_address_1=$($NAMADA_BIN_DIR/namadac --base-dir "$BASE_DIR_2" bonded-stake --node $NODE | grep tnam | awk 'NR==1{print $1}' | cut -d':' -f1)
validator_address_2=$($NAMADA_BIN_DIR/namadac --base-dir "$BASE_DIR_2" bonded-stake --node $NODE | grep tnam | awk 'NR==2{print $1}' | cut -d':' -f1)

echo "The validator addresses are $validator_address_1 and $validator_address_2"
# Generate key
echo "Generating key pairs..."

generate_keys "$NAMADA_BIN_DIR" "$PREFIX"

KEY_NAME="${PREFIX}multisig-key-1"

# Fund the key NUM_LOOPS times

for i in $(seq 1 4); do
    fund_account_bo "$NAMADA_BIN_DIR" "$KEY_NAME" "$KEY_NAME" 1000
done

# echo "Sleeping for 10 seconds and a bit to allow transactions to be processed..."

# sleep $(($NUM_LOOPS + 10))

# Bond amount is NUM_LOOPS * 1000
BOND_AMOUNT=$((2 * 900))


bond_tokens "$NAMADA_BIN_DIR" "${PREFIX}multisig-key-1" $BOND_AMOUNT "${PREFIX}multisig-key-1" "$validator_address_1"
bond_tokens "$NAMADA_BIN_DIR" "${PREFIX}multisig-key-1" $BOND_AMOUNT "${PREFIX}multisig-key-1" "$validator_address_2"

