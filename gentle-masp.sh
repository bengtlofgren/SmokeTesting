# !/bin/sh

SMOKE_TESTING_PREFIX="smoketesting-" # Prefix for all smoketesting keys and addresses
RND=$(echo $RANDOM | md5sum | head -c 20; echo;)
DEFAULT_PREFIX="${SMOKE_TESTING_PREFIX}${RND}-"
PREFIX="${PREFIX:-$DEFAULT_PREFIX}"

SCRIPT_DIR="$(dirname $0)"
source $SCRIPT_DIR/utils/commands.sh
source $SCRIPT_DIR/utils/validate.sh

validate_arguments "$@"

# Generate masp key
echo "Generating masp key pairs..."

generate_masp_keys "$NAMADA_BIN_DIR" "$PREFIX" 2

generate_masp_addresses "$NAMADA_BIN_DIR" "$PREFIX" 2

echo "successfully generated 2 masp key pairs with one payment address each"

# Generate transparent multisig account that is funded
echo "Generating multisig key pairs..."

basic_multisig "$NAMADA_BIN_DIR" "$PREFIX"

echo "successfully generated a 2 threshold multisig"

source $SCRIPT_DIR/utils/validate_output.sh

# Check that the multisig account is funded
ACCOUNT_NAME=$PREFIX"multisig-account-1"
SIGNING_KEYS="${PREFIX}multisig-key-1,${PREFIX}multisig-key-2"
check_balance "$NAMADA_BIN_DIR" $ACCOUNT_NAME 2000

# Fund masp payment addresses
echo "Funding masp payment addresses..."

PAYMENT_ADDRESS=$PREFIX"masp-address-1"

transfer "$NAMADA_BIN_DIR" "$ACCOUNT_NAME" 1000 "$SIGNING_KEYS" "$PAYMENT_ADDRESS"

PAYMENT_ADDRESS=$PREFIX"masp-address-2"

transfer "$NAMADA_BIN_DIR" "$ACCOUNT_NAME" 1000 "$SIGNING_KEYS" "$PAYMENT_ADDRESS"

echo "successfully funded masp payment addresses"

