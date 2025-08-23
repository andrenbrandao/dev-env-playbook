# Development Environment Playbook

[![Verify Ansible Playbook](https://github.com/andrenbrandao/dev-env-playbook/actions/workflows/verify-playbook.yml/badge.svg)](https://github.com/andrenbrandao/dev-env-playbook/actions/workflows/verify-playbook.yml)

This repository contains my personal automation configuration for setting up a new system. Feel free to use any parts of it that you find useful, but please note that I provide no guarantees or warranties. Use the configurations at your own risk.

Inspired by [ThePrimeagen's Developer Productivity Course](https://frontendmasters.com/courses/developer-productivity/) at Frontend Masters.

The ansible playbook relies mostly on my dotfiles configuration at this [Dotfiles Repo](https://github.com/andrenbrandao/dotfiles).

Topics I have found to be most impactful from the course:

- Ansible: automating your personal environment installation in a new machine
- GNU Stow: dotfile management with symlinks
- Tmux: a terminal multiplexer. I have an [article](https://andrebrandao.me/articles/terminal-setup-with-zsh-tmux-dracula-theme/#tmux--dracula-theme) on how I configure mine.
- Fzf: a fuzzy finder

## Installation

The recommended way to install is using the interactive TUI (Text User Interface) installer. It will guide you through the setup process and allow you to choose the installation type that best suits your needs.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/andrenbrandao/dev-env-playbook/main/tui.sh)"
```

### Installation Types

The installer offers two main choices:

1.  **Full Desktop Setup:** This is recommended for new personal machines. It installs a complete desktop environment and uses the **private** version of the dotfiles, which requires an Ansible Vault password to decrypt secrets.
2.  **Custom CLI Setup:** This is ideal for remote servers or for installing specific tools. It uses the **public** version of the dotfiles and does not require a vault password. You can select which components (tags) you want to install.

### Manual Installation

Run the `install.sh` script directly. This is useful to bypass the TUI or automate the installation.

The script accepts the following flags:

- `--tags "tag1,tag2"`: A comma-separated list of Ansible tags to install (e.g., `"dotfiles,zsh,tmux"`).
- `--dotfiles-mode "public|private"`: Choose between the public or private dotfiles. Defaults to `private`.
- `--dev`: Run in development mode, using the local files instead of cloning the repository.

**Example:**

```bash
./install.sh --tags "dotfiles,zsh,tmux" --dotfiles-mode "public"
```

## Development

To quickly check the changes, run docker with a new ubuntu installation:

```bash
docker run -v .:/home/andrebrandao/ansible --rm -it ubuntu-computer bash
```

Cd into the `~/ansible` directory and execute `tui.sh` with the `--dev` flag to fetch the changes from the local directory:

```bash
cd ~/ansible
./tui.sh --dev
```

### Running CI/CD Locally

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
ansible-playbook ubuntu.yml --ask-become --ask-vault-pass
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

### Running from a clean ubuntu install

This is the image that really simulates a clean installation, running the tui.sh script.

Build the images with:

```bash
./build-dockers.sh
```

Run the new ubuntu installation:

```bash
docker run -it ubuntu-computer bash
```

Curl the tui.sh script and run it.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/andrenbrandao/dev-env-playbook/main/tui.sh)"
```
