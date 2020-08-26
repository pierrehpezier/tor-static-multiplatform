FROM ubuntu:rolling
RUN apt-get update
RUN apt-get upgrade -y
RUN apt install locales -y
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install cmake upx-ucl wget wine64-preloader patch dos2unix g++-arm-linux-gnueabihf libc6-dev-armel-armhf-cross build-essential libunistring-dev libssl-dev mingw-w64 git g++-mingw-w64-i686 g++-mingw-w64-x86-64 gcc-mingw-w64-i686 gcc-mingw-w64-x86-64 -y
ADD . /build/
WORKDIR /build
RUN bash -xe ./build.sh
