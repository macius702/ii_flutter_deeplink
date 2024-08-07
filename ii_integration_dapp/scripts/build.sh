#! /usr/bin/env bash
# Build and Run Modes:
# 1. local: Deploys to the local replica. Ideal for development and testing.
# 2. playground: Deploys to the playground (which is on the mainnet). This is a free service but is limited to 20-minute sessions.
# 3. mainnet: Deploys to the mainnet. This is the production environment and consumes cycles.


export ROOT_DIRECTORY=$(pwd)

echo "ROOT_DIRECTORY=$ROOT_DIRECTORY"

# Check if dfx.json is located in the current directory
if [ -f "$ROOT_DIRECTORY/dfx.json" ]; then
    echo "dfx.json found."
else 
    echo "Error: dfx.json not found in the root directory."
    exit 1
fi

set -e







mode=${1:-local}

echo "mode=$mode"

if [ -z "$mode" ]
then
    echo "Please provide the mode as the first parameter: local, playground or mainnet"
    exit 1
fi

if [ "$mode" == "playground" ]
then
    echo "Deploying to the playground"
    deploy_param="--playground"
elif [ "$mode" == "local" ]
then
    echo "Deploying to local"
    deploy_param=""
elif [ "$mode" == "mainnet" ]
then
    echo "Deploying to mainnet"
    deploy_param="--network=ic"
else
    echo "Invalid mode. Please provide the mode as the first parameter: local, playground or mainnet"
    exit 1
fi



dart format $ROOT_DIRECTORY/src/flutter_project/lib/*.dart
# dart format --line-length 120 src/mahjong_icp_frontend/lib/*.dart


# Motoko, so no Rust: (cd $ROOT_DIRECTORY/src/greet_backend && cargo fmt)

# dfx stop
dfx start --clean --background &

sleep 3

# dfx start --background &
# flutter clean
# flutter pub get

# Needed for flutter build web
echo "Running canister create with parameter: $deploy_param"
dfx canister create internet_identity $deploy_param
dfx canister create greet_backend  $deploy_param
dfx canister create greet_frontend $deploy_param
dfx canister create flutter_project $deploy_param

echo "Running dart generate_config.dart with parameter: $mode"
dart $ROOT_DIRECTORY/scripts/generate_config.dart $mode

pushd $ROOT_DIRECTORY/src/flutter_project
    dart pub get

    flutter build apk --debug


    if [ "$mode" == "mainnet" ]
    then
        flutter build web --release
    else
        flutter build web --profile --dart-define=Dart2jsOptimization=O0 --source-maps
    fi

    # ugly way to change base href
    # sed -i 's|<base href="/ED-Mahjong/">|<base href="">|g' build/web/index.html
popd
#dfx build || true
dfx build



dfx deploy -v $deploy_param

flutter devices

if [ "$mode" == "playground" ]
then
    source web_front_end.sh
    xdg-open https://$FRONTEND_CANISTER_ID.ic0.app &
    # pushd $ROOT_DIRECTORY/src/mahjong_icp_frontend
    #     flutter run --release -d emulator-5554 &
    # popd
elif [ "$mode" == "local" ]
then
    echo
    # flutter run -d chrome
fi

