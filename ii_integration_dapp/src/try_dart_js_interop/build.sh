#!/usr/bin/env bash

# Load the .env file
source .env

# Check if CANISTER_ID_GREET_BACKEND is set and GREET_BACKEND_CANISTER_ID is not set
if [[ -n $CANISTER_ID_GREET_BACKEND ]] && [[ -z $GREET_BACKEND_CANISTER_ID ]]; then
    # If CANISTER_ID_GREET_BACKEND is set and GREET_BACKEND_CANISTER_ID is not set,
    # find the line number of CANISTER_ID_GREET_BACKEND in .env
    line_number=$(grep -n "CANISTER_ID_GREET_BACKEND" .env | cut -d : -f 1)

    # Increment the line number
    line_number=$((line_number+1))

    # Add GREET_BACKEND_CANISTER_ID with the same value right after CANISTER_ID_GREET_BACKEND
    sed -i "${line_number}i GREET_BACKEND_CANISTER_ID=$CANISTER_ID_GREET_BACKEND" .env
fi

echo "DFX_NETWORK=$DFX_NETWORK"

# Check if DFX_NETWORK is set to 'playground'
if [[ $DFX_NETWORK == 'playground' ]]; then
    # If it is, change it to 'ic'
    sed -i "s/DFX_NETWORK='playground'/DFX_NETWORK='ic'/g" .env
fi

npx webpack