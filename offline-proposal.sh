NODE="127.0.0.1:27657"
BASE_DIR_2="/Users/unknowit/Library/Application Support/Namada"

RND=$(echo $RANDOM | md5sum | head -c 20; echo;)
DEFAULT_PREFIX="${SMOKE_TESTING_PREFIX}${RND}-"
PREFIX="${PREFIX:-$DEFAULT_PREFIX}"

SCRIPT_DIR="$(dirname $0)"
source $SCRIPT_DIR/utils/validate.sh
source $SCRIPT_DIR/utils/commands.sh

validate_arguments "$1"

echo "Creating a multisig account..."
source $SCRIPT_DIR/transparent-multisig.sh "$NAMADA_BIN_DIR"

echo "The account name is $ACCOUNT_NAME"

ACCOUNT_ADDRESS=$($NAMADA_BIN_DIR/namadaw list --addr | grep $ACCOUNT_NAME | cut -d':' -f3- | cut -d':' -f2 | tr -d '[:space:]')

echo "The address of the multisig account is $ACCOUNT_ADDRESS"

# Fund account
echo "Funding the account..."
fund_account "$NAMADA_BIN_DIR" "$ACCOUNT_NAME" 300000

sleep 5

VALIDATOR_ADDRESS="validator-0"
echo "Bonding tokens to ${VALIDATOR_ADDRESS}..."
bond_tokens "$NAMADA_BIN_DIR" "$ACCOUNT_NAME" 300000 $SIGNING_KEYS $VALIDATOR_ADDRESS

CURRENT_EPOCH=$($NAMADA_BIN_DIR/namadac --base-dir "$BASE_DIR_2" epoch --node $NODE | cut -d':' -f2 | tr -d '[:space:]')
sleep 10
NEW_EPOCH=$($NAMADA_BIN_DIR/namadac --base-dir "$BASE_DIR_2" epoch --node $NODE | cut -d':' -f2 | tr -d '[:space:]')
while [ $CURRENT_EPOCH -ge $(($NEW_EPOCH-12)) ]; do
    echo "sleeping for new epoch"
    sleep 10
    NEW_EPOCH=$($NAMADA_BIN_DIR/namadac --base-dir "$BASE_DIR_2" epoch --node $NODE | cut -d':' -f2 | tr -d '[:space:]')
done

echo "The old epoch was $CURRENT_EPOCH"
PROPOSAL=$SCRIPT_DIR/utils/offline_proposal.json

TALLY_EPOCH=$(($NEW_EPOCH - 1))

sed -i -e "s/\"author\":.*/\"author\": \"$ACCOUNT_ADDRESS\",/g" $PROPOSAL
# Change the voting_start_epoch to be VOTING_START_EPOCH
sed -i -e "s/\"tally_epoch\":.*/\"tally_epoch\": $TALLY_EPOCH/g" $PROPOSAL

echo "New proposal is catted below:"
cat $PROPOSAL

# Create the offline proposal
rm -rf offline_proposals
mkdir offline_proposals
$NAMADA_BIN_DIR/namadac --base-dir "$BASE_DIR_2" init-proposal --offline --data-path $SCRIPT_DIR/utils/offline_proposal.json --output-folder-path offline_proposals --signing-keys $SIGNING_KEYS

# Get the filename in offline_proposals
PROPOSAL_FILENAME=$(ls offline_proposals | grep .json)

# Vote on the proposal
$NAMADA_BIN_DIR/namadac --base-dir "$BASE_DIR_2" vote-proposal --offline --vote yay --data-path offline_proposals/$PROPOSAL_FILENAME --signing-keys "${PREFIX}multisig-key-1","${PREFIX}multisig-key-2","${PREFIX}multisig-key-3"  --address $ACCOUNT_ADDRESS --output-folder-path offline_proposals

NEW_EPOCH=$($NAMADA_BIN_DIR/namadac --base-dir "$BASE_DIR_2" epoch --node $NODE | cut -d':' -f2 | tr -d '[:space:]')
echo "The epoch when querying the proposal is $NEW_EPOCH"
# Query the result of the proposal
$NAMADA_BIN_DIR/namadac --base-dir "$BASE_DIR_2" query-proposal-result --offline --data-path offline_proposals --node $NODE

