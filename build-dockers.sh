#!/usr/bin/env bash

docker build . -t ansible-computer
docker build . -f nvim.Dockerfile -t nvim-computer
docker build . -f ubuntu.Dockerfile -t ubuntu-computer
docker build . -f arch.Dockerfile -t arch-computer
