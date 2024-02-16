
NODE="127.0.0.1:27657"
BASE_DIR_2="/Users/unknowit/Library/Application Support/Namada"
# Get the absolute path to script directory
SCRIPT_DIR="$(dirname $(realpath $0))"
source $SCRIPT_DIR/utils/validate.sh

validate_arguments "$1"
NAMADA_BIN_DIR="$1"

source $SCRIPT_DIR/transparent-multisig.sh "$NAMADA_BIN_DIR"

echo "The account name is $ACCOUNT_NAME"

ACCOUNT_ADDRESS=$($NAMADA_BIN_DIR/namadaw list --addr | grep $ACCOUNT_NAME | cut -d':' -f3- | cut -d':' -f2 | tr -d '[:space:]')

echo "The address of the multisig account is $ACCOUNT_ADDRESS"


CURRENT_EPOCH=$($NAMADA_BIN_DIR/namadac --base-dir "$BASE_DIR_2" epoch --node $NODE | cut -d':' -f2 | tr -d '[:space:]')

echo "The current epoch is $CURRENT_EPOCH"

# Find the next epoch that is a divisible of 6
VOTING_START_EPOCH=$(($CURRENT_EPOCH + 6 - $CURRENT_EPOCH % 6))
VOTING_END_EPOCH=$(($VOTING_START_EPOCH + 6))
GRACE_EPOCH=$(($VOTING_END_EPOCH + 6))

echo "The voting period starts at epoch $VOTING_START_EPOCH and ends at epoch $VOTING_END_EPOCH"
echo "The grace period starts at epoch $GRACE_EPOCH"

PROPOSAL=$SCRIPT_DIR/utils/pgf_proposal.json
echo $PROPOSAL
# Change the author field of the proposal to the multisig account name
sed -i -e "s/\"author\":.*/\"author\": \"$ACCOUNT_ADDRESS\",/g" $PROPOSAL
# Change the voting_start_epoch to be VOTING_START_EPOCH
sed -i -e "s/\"voting_start_epoch\":.*/\"voting_start_epoch\": $VOTING_START_EPOCH,/g" $PROPOSAL
# Change the voting_end_epoch to be VOTING_END_EPOCH
sed -i -e "s/\"voting_end_epoch\":.*/\"voting_end_epoch\": $VOTING_END_EPOCH,/g" $PROPOSAL
# Change the grace_epoch to be GRACE_EPOCH
sed -i -e "s/\"grace_epoch\":.*/\"grace_epoch\": $GRACE_EPOCH/g" $PROPOSAL

# Change tha address field of the steward
sed -i -e "s/\"target\":.*/\"target\": \"$ACCOUNT_ADDRESS\"/g" $PROPOSAL

echo "New proposal is catted below:"
cat $PROPOSAL

$NAMADA_BIN_DIR/namadac --base-dir "$BASE_DIR_2" init-proposal --pgf-funding --data-path $SCRIPT_DIR/utils/pgf_proposal.json --signing-keys $SIGNING_KEYS --node $NODE

