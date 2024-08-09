#!/usr/bin/env bash

dfx deploy --playground

(cd src/flutter_project &&  dart run ./lib/generate_constants.dart && flutter run)