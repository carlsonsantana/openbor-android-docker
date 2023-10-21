FROM archlinux:base-devel-20230921.0.180222

# Environment variables
ENV SDK_VERSION "9477386_latest"
ENV ANDROID_SDK_ROOT /android-sdk
ENV KEYSTORE_NAME keystore_name
ENV KEYSTORE_KEY_PASSWORD keystore_password
ENV KEYSTORE_STORE_PASSWORD keystore_password
ENV GAME_APK_NAME "com.mycompany.gamename"
ENV GAME_NAME "Game Name"

# Install operational system dependencies
RUN pacman -Syu --noconfirm && pacman -S jdk11-openjdk jdk17-openjdk unzip --noconfirm

# Install Android Command-line tools
RUN curl https://dl.google.com/android/repository/commandlinetools-linux-${SDK_VERSION}.zip --output cmdline-tools.zip
RUN unzip cmdline-tools.zip
RUN mkdir -p /android-sdk/cmdline-tools
RUN mv cmdline-tools /android-sdk/cmdline-tools/latest
RUN rm cmdline-tools.zip

# Install Android SDK
WORKDIR /android-sdk/cmdline-tools/latest/bin
RUN archlinux-java set java-17-openjdk
RUN echo "y" | ./sdkmanager "build-tools;29.0.3" "patcher;v4" "platform-tools" "platforms;android-29" "tools" "ndk-bundle"

# Copy OpenBOR repository
COPY openbor /openbor

# Create version header file
WORKDIR /openbor/engine
RUN ./version.sh

# Reduce build time in futher builds
RUN archlinux-java set java-11-openjdk
WORKDIR /openbor/engine/android
RUN keytool -genkey -noprompt -v \
  -keystore game_certificate.jks \
  -storepass 123456 \
  -keypass 123456 \
  -alias a \
  -keyalg RSA \
  -dname "CN=gamename.mycompany.com, OU=O, O=O, L=O, S=O, C=US"
RUN printf "storePassword=123456\nkeyPassword=123456\nkeyAlias=a\nstoreFile=/openbor/engine/android/game_certificate.jks\n" > keystore.properties
RUN ./gradlew assembleRelease
RUN rm keystore.properties game_certificate.jks /openbor/engine/android/app/build/outputs/apk/release/OpenBOR.apk

# Volumes
RUN mkdir /output
VOLUME /game_certificate.jks
VOLUME /bor.pak
VOLUME /output

# Run build
WORKDIR /openbor/engine/android
COPY run.sh /
CMD ["bash", "/run.sh"]
