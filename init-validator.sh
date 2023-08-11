
SMOKE_TESTING_PREFIX="smoketesting-" # Prefix for all smoketesting keys and addresses
RND=$(echo $RANDOM | md5sum | head -c 20; echo;)
DEFAULT_PREFIX="${SMOKE_TESTING_PREFIX}${RND}-"
PREFIX="${PREFIX:-$DEFAULT_PREFIX}"

SCRIPT_DIR="$(dirname $0)"
source $SCRIPT_DIR/utils/commands.sh
source $SCRIPT_DIR/utils/validate.sh

validate_arguments "$@"

# Generate keypairs
generate_keys "$NAMADA_BIN_DIR" "$PREFIX"

# Name validator
VALIDATOR_ALIAS="${PREFIX}validator-1"

$NAMADA_BIN_DIR/namada client init-validator \
--alias "$VALIDATOR_ALIAS" \
--account-keys "${PREFIX}multisig-key-1,${PREFIX}multisig-key-2,${PREFIX}multisig-key-3" \
--commission-rate 0.05 \
--max-commission-rate-change 0.1 \
--signing-keys "${PREFIX}multisig-key-1" \
--unsafe-dont-encrypt \
--threshold 2

echo "done initalising account"


# Transfer from validator account to multisig account

# Fund account
fund_account "$NAMADA_BIN_DIR" "$VALIDATOR_ALIAS" "${PREFIX}multisig-key-1" 1000

# Create target account
ACCOUNT_NAME="${PREFIX}multisig-account-1"
PUBLIC_KEYS="${PREFIX}multisig-key-1,${PREFIX}multisig-key-2,${PREFIX}multisig-key-3"
init_account "$NAMADA_BIN_DIR" "$ACCOUNT_NAME" "$PUBLIC_KEYS" 2

# Make transfer
transfer "$NAMADA_BIN_DIR" "$VALIDATOR_ALIAS" 1000 "${PREFIX}multisig-key-1,${PREFIX}multisig-key-2" "${PREFIX}multisig-account-1"

# Check balance
source $SCRIPT_DIR/utils/validate_output.sh
echo $ACCOUNT_NAME
check_balance "$NAMADA_BIN_DIR" "$ACCOUNT_NAME" 1000
