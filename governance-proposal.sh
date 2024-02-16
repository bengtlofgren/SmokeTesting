

# Get the absolute path to script directory
SCRIPT_DIR="$(dirname $(realpath $0))"
source $SCRIPT_DIR/utils/validate.sh

validate_arguments "$1"
NAMADA_BIN_DIR="$1"
NODE="$2"
BASE_DIR_2="$3"

source $SCRIPT_DIR/transparent-multisig.sh "$NAMADA_BIN_DIR"

echo "The account name is $ACCOUNT_NAME"

ACCOUNT_ADDRESS=$($NAMADA_BIN_DIR/namadaw --base-dir $BASE_DIR_2 list --addr | grep $ACCOUNT_NAME | cut -d':' -f3- | cut -d':' -f2 | tr -d '[:space:]')

echo "The address of the multisig account is $ACCOUNT_ADDRESS"

echo "Signing keys are: $SIGNING_KEYS"

fund_account $NAMADA_BIN_DIR $ACCOUNT_ADDRESS 95000000000

# Bond to validators
bond_validator $NAMADA_BIN_DIR $ACCOUNT_ADDRESS $SIGNING_KEYS 90000000000


BONDED_EPOCH=$($NAMADA_BIN_DIR/namadac --base-dir $BASE_DIR_2 epoch --node $NODE | cut -d':' -f2 | tr -d '[:space:]')
CURRENT_EPOCH=$($NAMADA_BIN_DIR/namadac --base-dir $BASE_DIR_2 epoch --node $NODE | cut -d':' -f2 | tr -d '[:space:]')

# Wait until 2 epochs have passed since the account was bonded to the validator
while [ $CURRENT_EPOCH -lt 2 + $BONDED_EPOCH ]; do
    echo "sleeping for new epoch"
    sleep 10
    CURRENT_EPOCH=$($NAMADA_BIN_DIR/namadac --base-dir $BASE_DIR_2 epoch --node $NODE | cut -d':' -f2 | tr -d '[:space:]')
done

echo "The current epoch is $CURRENT_EPOCH"

# Find the next epoch that is a divisible of 2
VOTING_START_EPOCH=$(($CURRENT_EPOCH + 4 - $CURRENT_EPOCH % 4))
VOTING_END_EPOCH=$(($VOTING_START_EPOCH + 4))
GRACE_EPOCH=$(($VOTING_END_EPOCH + 2))

echo "The voting period starts at epoch $VOTING_START_EPOCH and ends at epoch $VOTING_END_EPOCH"
echo "The grace period starts at epoch $GRACE_EPOCH"

PROPOSAL=$SCRIPT_DIR/utils/proposal_with_wasm.json
echo $PROPOSAL
# Change the author field of the proposal to the multisig account name
sed -i -e "s/\"author\":.*/\"author\": \"$ACCOUNT_ADDRESS\",/g" $PROPOSAL
# Change the voting_start_epoch to be VOTING_START_EPOCH
sed -i -e "s/\"voting_start_epoch\":.*/\"voting_start_epoch\": $VOTING_START_EPOCH,/g" $PROPOSAL
# Change the voting_end_epoch to be VOTING_END_EPOCH
sed -i -e "s/\"voting_end_epoch\":.*/\"voting_end_epoch\": $VOTING_END_EPOCH,/g" $PROPOSAL
# Change the grace_epoch to be GRACE_EPOCH
sed -i -e "s/\"grace_epoch\":.*/\"grace_epoch\": $GRACE_EPOCH/g" $PROPOSAL

python3 $SCRIPT_DIR/utils/add_wasm_proposal.py $PROPOSAL $SCRIPT_DIR/utils/init_inflation_pos_and_pgf.wasm

echo "New proposal is catted below:"
cat $PROPOSAL

$NAMADA_BIN_DIR/namadac --base-dir $BASE_DIR_2 init-proposal --data-path $SCRIPT_DIR/utils/proposal_with_wasm.json --signing-keys $SIGNING_KEYS --node $NODE --gas-limit 80000 --gas-price 0.01

CURRENT_EPOCH=$($NAMADA_BIN_DIR/namadac --base-dir $BASE_DIR_2 epoch --node $NODE | cut -d':' -f2 | tr -d '[:space:]')

while [ $CURRENT_EPOCH -lt $VOTING_START_EPOCH ]; do
    echo "sleeping for new epoch"
    sleep 10
    CURRENT_EPOCH=$($NAMADA_BIN_DIR/namadac --base-dir $BASE_DIR_2 epoch --node $NODE | cut -d':' -f2 | tr -d '[:space:]')
done

# Vote on the proposal

$NAMADA_BIN_DIR/namadac --base-dir $BASE_DIR_2 vote-proposal --proposal-id 0 --vote yay --address $ACCOUNT_ADDRESS --signing-keys $SIGNING_KEYS --node $NODE



