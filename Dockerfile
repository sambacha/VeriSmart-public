FROM debian:bullseye-slim 

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    locale \
    tzdata \
    software-properties-common; \
    # Setup locale
    LANG=en_US.UTF-8; \
    echo $LANG UTF-8 > /etc/locale.gen; \
    locale-gen; \
    update-locale LANG=$LANG; \
    export LANG=$LANG; \
    && apt-get clean -q -y \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
# Install some basic pre-requisites
RUN set -eux; \
	  apt-get -qq update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -qqy --assume-yes --no-install-recommends \
    sudo \
    wget \
    git build-essential \
    g++ \ 
    gcc \
    m4 \
    make \
    pkg-config \
    libgmp3-dev \
    unzip \
    opam \
    python3 python3-pip \
    time \
    z3 \
    libz3-dev \
    cmak; \
    && apt-get clean -q -y \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install solc-select
RUN solc-select install 0.8.15 \
    && solc-select use 0.8.15;
    
ENV PATH=$PATH:/root/.solc-select/artifacts/

WORKDIR /build
ADD . ./verismart

WORKDIR /build/verismart
RUN opam init -y --disable-sandboxing \
    && eval $(opam env) \
    && opam update \
    && opam install -y \
    conf-m4.1 ocamlfind ocamlbuild num yojson batteries ocamlgraph zarith z3

# Make sure that ocamlbuild and such exists in the path
RUN echo 'eval $(opam env)' >> $HOME/.bashrc

RUN chmod +x build && eval $(opam env) && ./build && ./main.native --help >/dev/null
RUN ln -s $(realpath ./main.native) /usr/local/bin/verismart

USER root

RUN $SHELL
