FROM ubuntu:plucky AS base
ARG TAGS
WORKDIR /usr/local/bin
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt install -y software-properties-common curl git build-essential && \
    apt install -y sudo curl git ansible build-essential && \
    apt clean autoclean && \
    apt autoremove --yes

FROM base AS andrebrandao
ARG TAGS
RUN deluser ubuntu
RUN addgroup --gid 1000 andrebrandao
RUN adduser --gecos andrebrandao --uid 1000 --gid 1000 --disabled-password andrebrandao
RUN adduser andrebrandao sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER andrebrandao
WORKDIR /home/andrebrandao

FROM andrebrandao
COPY . ./ansible
