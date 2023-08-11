function check_balance {
    # The script expects 3 arguments:
    # 1. The path to the directory containing the Namada binaries
    # 2. The name of the account
    # 3. The expected balance of the account

    if [ "$#" != 3 ]; then
        echo "Error: Invalid number of arguments. Expected 3 arguments : NAMADA_BIN_DIR, ACCOUNT_NAME, AMOUNT."
        exit 1
    fi

    local namada_bin_dir="$1"
    local account_name="$2"
    local amount="$3"

    echo "Checking balance of account: $account_name"

    command_output=$($namada_bin_dir/namadac balance --owner "$account_name" --token nam)

    if echo "$command_output" | grep -q $amount; then
        echo "Output verification succeeded!"
    else
        echo "Output verification failed!"
        echo "Expected: $amount"
        echo "Actual: $command_output"
    fi
}