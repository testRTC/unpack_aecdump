# Originally based on Jan Keromnes "janx@linux.com" chromium image
FROM ubuntu:14.04
MAINTAINER Andrey Korin "a.korin@outlook.com"

# Install Chromium build dependencies and JDK 7
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty multiverse" >> /etc/apt/sources.list # && dpkg --add-architecture i386
RUN apt-get update && apt-get install -qy git build-essential clang curl openjdk-7-jdk
RUN curl -SL https://chromium.googlesource.com/chromium/src/+/master/build/install-build-deps.sh?format=TEXT \
 | base64 --decode > /tmp/install-build-deps.sh \
 && chmod +x /tmp/install-build-deps.sh \
  && /tmp/install-build-deps.sh --no-prompt --no-arm --no-chromeos-fonts --no-nacl \
   && rm /tmp/install-build-deps.sh

# Don't be root.
RUN useradd -m user
RUN echo "user:user" | chpasswd
USER user
ENV HOME /home/user
WORKDIR /home/user

# Install Chromium's depot_tools.
ENV DEPOT_TOOLS /home/user/depot_tools
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $DEPOT_TOOLS
ENV PATH $PATH:$DEPOT_TOOLS
RUN echo "\n# Add Chromium's depot_tools to the PATH." >> .bashrc \
 && echo "export PATH=\"\$PATH:$DEPOT_TOOLS\"" >> .bashrc

# Force Chromium to build with clang.
RUN echo "{ 'GYP_DEFINES': 'clang=1' }" > /home/user/chromium.gyp_env

# https://webrtc.org/native-code/development/

# Download source code.
RUN mkdir webrtc-checkout
WORKDIR webrtc-checkout
RUN fetch --nohooks webrtc

RUN gclient sync -j1 -v -v -v --ignore_locks --no-history

# Build
WORKDIR src
RUN gn gen out/Default --args='is_debug=false'
RUN ninja -C out/Default unpack_aecdump

CMD ["cat", "/home/user/webrtc-checkout/src/out/Default/unpack_aecdump"]
