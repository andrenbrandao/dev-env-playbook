FROM ubuntu:jammy AS base
ARG TAGS
WORKDIR /usr/local/bin
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common curl git build-essential && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y sudo curl git ansible build-essential && \
    apt-get clean autoclean && \
    apt-get autoremove --yes

FROM base AS andrebrandao
ARG TAGS
RUN addgroup --gid 1000 andrebrandao
RUN adduser --gecos andrebrandao --uid 1000 --gid 1000 --disabled-password andrebrandao
RUN adduser andrebrandao sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER andrebrandao
WORKDIR /home/andrebrandao

FROM andrebrandao
COPY . ./ansible
CMD ["sh", "-c", "ansible-playbook $TAGS local.yml"]
