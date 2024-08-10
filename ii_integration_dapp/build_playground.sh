#!/usr/bin/env bash

set -e

script_params=("$@")


use_original_greet_canisters_on_mainnet () {
    for index in "${!script_params[@]}"; do
        if [ "${script_params[index]}" == "--use_original_greet_canisters_on_mainnet" ]; then
            unset 'script_params[index]'
            return 0
        fi
    done
    return 1
}

update_env_var() {
    VAR_NAME=$1
    VAR_VALUE=$2

    if grep -q "$VAR_NAME" .env; then
        sed -i "s/$VAR_NAME=.*/$VAR_NAME='$VAR_VALUE'/" .env
    else
        echo "$VAR_NAME='$VAR_VALUE'" >> .env
    fi
}

write_hardcoded_canister_ids_to_env(){
    CANISTER_ID_GREET_FRONTEND='qsgof-4qaaa-aaaan-qekqq-cai'
    CANISTER_ID_GREET_BACKEND='qvhir-riaaa-aaaan-qekqa-cai'

    update_env_var "CANISTER_ID_GREET_FRONTEND" "$CANISTER_ID_GREET_FRONTEND"
    update_env_var "CANISTER_ID_GREET_BACKEND" "$CANISTER_ID_GREET_BACKEND"
}


if use_original_greet_canisters_on_mainnet "$1"
then
  echo "Using original greet canisters on mainnet"
  write_hardcoded_canister_ids_to_env
else
  echo "Using greet canisters built on playground"
  dfx deploy --playground
fi


cd src/flutter_project
dart run ./lib/generate_constants.dart

# Run the flutter app
flutter run "${script_params[@]}"

# Run flutter web server
# flutter build web --profile --dart-define=Dart2jsOptimization=O0 --source-maps
# cd build/webq
# http-server



