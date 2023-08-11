# Script that deletes all keys from wallet

# Usage: ./delete-wallet.sh <namada_base_dir>

if [ "$#" -eq 0 ]; then
        BASE_DIR="$($NAMADA_BIN_DIR/namadac utils default-base-dir)"
        echo "Using default BASE_DIR: $BASE_DIR"
    else [ "$#" -eq 3 ];
        NAMADA_BASE_DIR="$1"
    fi

# Get chain id
CHAIN_ID=$(cat "$NAMADA_BASE_DIR"/global-config.toml | grep chain_id | awk '{print $3}' | sed 's/"//g')

echo "The chain id is $CHAIN_ID"
# Delete all keys from wallet
echo "Deleting all smoketesting keys + addresses from wallet"

WALLET_PATH="$NAMADA_BASE_DIR"/"$CHAIN_ID"/wallet.toml
echo $WALLET_PATH

SCRIPT_DIR="$(dirname $0)"
$SCRIPT_DIR/utils/clear-wallet.py "$WALLET_PATH"