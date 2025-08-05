# Development Environment Playbook

This repository contains my personal automation configuration for setting up a new system. Feel free to use any parts of it that you find useful, but please note that I provide no guarantees or warranties. Use the configurations at your own risk.

Inspired by [ThePrimeagen's Developer Productivity Course](https://frontendmasters.com/courses/developer-productivity/) at Frontend Masters.

The ansible playbook relies mostly on my dotfiles configuration at this [Dotfiles Repo](https://github.com/andrenbrandao/dotfiles).

Topics I have found to be most impactful from the course:

- Ansible: automating your personal environment installation in a new machine
- GNU Stow: dotfile management with symlinks
- Tmux: a terminal multiplexer. I have an [article](https://andrebrandao.me/articles/terminal-setup-with-zsh-tmux-dracula-theme/#tmux--dracula-theme) on how I configure mine.
- Fzf: a fuzzy finder

## Installation

There are two options of commands:

1. To install all the CLIs libraries, neovim, and dotfiles config, curl the [install.sh](./install.sh) script and run it.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/andrenbrandao/dev-env-playbook/main/install.sh)"
```

2. For a brand new Ubuntu installation, curl the [ubuntu.sh](./ubuntu.sh) script. It will install other GUI apps and backups.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/andrenbrandao/dev-env-playbook/main/ubuntu.sh)"
```

### Running per tags

Run specific actions (e.g. install neovim) with a given tag.

```bash
ansible-playbook ubuntu.yml --tags neovim --ask-become
```

Notice the usage of `--ask-become` as the action might require the superuser password.

## Running CI/CD Locally

In order to verify the GH Actions are running properly before submitting the code, use https://github.com/nektos/act. See the [installation guide](https://nektosact.com/installation/gh.html) with the GitHub CLI.

```bash
gh extension install https://github.com/nektos/gh-act
```

Then, create a Personal Acess Token with Contents read-only permissions and add it to a `.secrets` file.

Execute the following to run it locally:

```bash
gh act push -P ubuntu-24.04=ghcr.io/catthehacker/ubuntu:act-24.04
```

## How to experiment with Docker and Ansible

The point of using docker containers is that we can play with new instances of Ubuntu and check if the ansible scripts are working properly, simulating the situation of getting a new machine.

### Building

To build the docker images used in this project, run `build-dockers.sh`. It will create 3 images:

- `ubuntu-computer`: a clean ubuntu installation
- `nvim-computer`: ubuntu with neovim installed
- `ansible-computer`: ubuntu with ansible installed

The first one is the base where we can simulate a new machine, while the other 2 are used for development of the automation, hence the neovim and ansible installations to change the files.

Note that `nvim.Dockerfile` adds the ppa:neovim-ppa/unstable repository. That is how it is able to install the latest neovim. For the default Dockerfile, we need to add it during Ansible, or install it from source. The decision will depend on how much we have control of installing new things in the machine.

### Running it with neovim already installed

Build the images with:

```bash
./build-dockers.sh
```

After building the images, execute:

```bash
docker run -v .:/usr/local/bin --rm -it nvim-computer bash
```

It will spin up a new docker container. One can now test if all the programs/apps were installed correctly.

To run the ansible command and install all the packages, execute:

```bash
ansible-playbook ubuntu.yml
```

### Running from a installation with ansible, curl and git

Build the images with:

```bash
./build-dockers.sh
```

Run the new ubuntu installation:

```bash
docker run -v .:/home/andrebrandao/ansible --rm -it ansible-computer bash
```

Cd into the `~/ansible` directory and execute ansible:

```bash
cd ~/ansible
./ansible-run.sh
```

### Running from a clean ubuntu install

This is the image that really simulates a clean installation, running the install.sh script.

Build the images with:

```bash
./build-dockers.sh
```

Run the new ubuntu installation:

```bash
docker run -it ubuntu-computer bash
```

Curl the install.sh script and run it.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/andrenbrandao/dev-env-playbook/main/install.sh)"
```
