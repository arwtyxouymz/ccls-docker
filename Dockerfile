FROM ubuntu:16.04

LABEL maintainer "Ryutaro Matsumoto <taross0524.ss@gmail.com>"

# Install LLVM
RUN apt update && apt install -y --no-install-recommends \
    git \
    wget \
    build-essential \
    software-properties-common \
    libncurses5-dev \
    zlib1g-dev \
    # Install CMake
    && wget https://cmake.org/files/v3.10/cmake-3.10.1-Linux-x86_64.tar.gz \
    && tar xf cmake-3.10.1-Linux-x86_64.tar.gz \
    && rm cmake-3.10.1-Linux-x86_64.tar.gz \
    && ln -s /cmake-3.10.1-Linux-x86_64/bin/cmake /usr/bin/cmake \
    # Add llvm keys
    && /bin/bash -c 'echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-6.0 main" > /etc/apt/sources.list.d/llvm.list' \
    && /bin/bash -c 'echo "deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-6.0 main" > /etc/apt/sources.list.d/llvm.list' \
    && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    # Add gcc7 keys
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    # Install llvm and gcc7
    && apt update && apt install -y \
    g++-7 \
    libllvm6.0 \
    llvm-6.0 \
    llvm-6.0-dev \
    llvm-6.0-runtime \
    clang-6.0 \
    clang-tools-6.0 \
    libclang-common-6.0-dev \
    libclang-6.0-dev \
    libclang1-6.0 \
    clang-format-6.0 \
    python-clang-6.0 \
    lldb-6.0 \
    lld-6.0 \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-7 \
    && update-alternatives --config gcc

ENV PATH /usr/lib/llvm-6.0/bin:$PATH

# Install ccls
RUN git clone https://github.com/MaskRay/ccls --depth=1 \
    && cd ccls \
    && git submodule update --init \
    && cmake -H. -BRelease -DCMAKE_CXX_COMPILER=/usr/lib/llvm-6.0/bin/clang++ -DSYSTEM_CLANG=ON \
                            -DCLANG_USE_BUNDLED_LIBC++=on -DCMAKE_PREFIX_PATH=/usr/lib/llvm-6.0/ \
    && cmake --build Release \
    && cd Release \
    && make install \
    && cd / && rm -rf ccls
