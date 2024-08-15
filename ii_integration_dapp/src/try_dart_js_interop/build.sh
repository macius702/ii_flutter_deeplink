#!/usr/bin/env bash

set -e

pushd ../.. >/dev/null
    echo "Creating canisters..."
    output=$(dfx canister create --all --playground 2>&1)
    count=$(echo $output | grep -o "canister was already created" | wc -l)
    if [[ $count -eq 2 ]]; then
        echo "Both canisters were already created, doing nothing."
    else
        echo "Deploying fresh canisters..."
        dfx deploy --playground
    fi
popd >/dev/null

echo "Removing existing .env file..."
rm .env | true

echo "Creating symbolic link to ../../.env..."
ln -s ../../.env .env

# Load the .env file
source .env

# Check if CANISTER_ID_GREET_BACKEND is set and GREET_BACKEND_CANISTER_ID is not set
if [[ -n $CANISTER_ID_GREET_BACKEND ]] && [[ -z $GREET_BACKEND_CANISTER_ID ]]; then
    # If CANISTER_ID_GREET_BACKEND is set and GREET_BACKEND_CANISTER_ID is not set,
    # find the line number of CANISTER_ID_GREET_BACKEND in .env
    line_number=$(grep -n "CANISTER_ID_GREET_BACKEND" .env | cut -d : -f 1)

    # Increment the line number
    line_number=$((line_number + 1))

    # Add GREET_BACKEND_CANISTER_ID with the same value right after CANISTER_ID_GREET_BACKEND
    sed "${line_number}i GREET_BACKEND_CANISTER_ID='$CANISTER_ID_GREET_BACKEND'" .env >.env.new

    # Copy the new file to the original file, preserving symbolic links
    cp -P .env.new .env
    rm .env.new
fi

if [ -L .env ]; then
    echo ".env is a symbolic link."
else
    echo ".env is not a symbolic link."
fi

echo "DFX_NETWORK=$DFX_NETWORK"

# Check if DFX_NETWORK is set to 'playground'
if [[ $DFX_NETWORK == 'playground' ]]; then
    # If it is, change it to 'ic'
    sed "s/DFX_NETWORK='playground'/DFX_NETWORK='ic'/g" .env >.env.new
    cp -P .env.new .env
    rm .env.new
fi

npx webpack

# or: flutter run -d chrome --web-renderer auto
# or: flutter build web --release && (cd build/web && http-server )
