#!/bin/sh

set -e

rm -f /output/openbor.apk

# Change APK name
sed -i "s|org\.openbor\.engine|$GAME_APK_NAME|g" /openbor/engine/android/app/build.gradle
sed -i "s|\"Openbor\"|\"$GAME_NAME\"|g" /openbor/engine/android/app/build.gradle

printf "storePassword=$KEYSTORE_STORE_PASSWORD\nkeyPassword=$KEYSTORE_KEY_PASSWORD\nkeyAlias=$KEYSTORE_NAME\nstoreFile=/game_certificate.jks\n" > keystore.properties

cp /bor.pak /openbor/engine/android/app/src/main/assets/bor.pak

./gradlew assembleRelease

mv /openbor/engine/android/app/build/outputs/apk/release/OpenBOR.apk /output/OpenBOR.apk
