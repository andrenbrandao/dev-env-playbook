FROM archlinux:latest AS base
ARG TAGS
WORKDIR /usr/local/bin
RUN pacman -Syu curl --noconfirm && \
    pacman -Syu sudo --noconfirm

FROM base AS andrebrandao
ARG TAGS
RUN groupadd --gid 1000 andrebrandao
RUN useradd -m -u 1000 -g andrebrandao -G wheel -s /bin/bash andrebrandao
RUN sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
USER andrebrandao
WORKDIR /home/andrebrandao

