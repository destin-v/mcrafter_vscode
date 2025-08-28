FROM nvidia/cuda:13.0.0-cudnn-devel-ubuntu24.04

# Disable interaction
# Set ARG as this is only available during build
ARG DEBIAN_FRONTEND=noninteractive

# Common packages
RUN apt -y update &&\ 
    apt -y upgrade &&\
    apt -y install \
    vim \
    curl \
    git \
    htop \
    pipx \
    unzip \
    wget \
    x11-apps &&\
    apt -y clean

# Install pipx
RUN pipx ensurepath
RUN pipx install nvitop

WORKDIR /root/

# Install Mamba
ENV PATH="/root/.local/bin/:$PATH"
ARG PATH="/root/.local/bin/:$PATH"
RUN curl -L micro.mamba.pm/install.sh | bash -s

# Oh my Posh
RUN curl -s https://ohmyposh.dev/install.sh | bash -s
RUN echo 'eval "$(oh-my-posh init bash)"' >> ~/.bashrc
RUN echo 'source .bashrc' >> ~/.profile
RUN echo 'PATH=$PATH:~/.local/bin/' >> ~/.bashrc

# VIM configuration
RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime &&\
    sh ~/.vim_runtime/install_awesome_vimrc.sh

# Clone Repo
RUN git clone https://github.com/prafull7/crafter_hackathon.git
WORKDIR crafter_hackathon

# To create a Mamba environment.  Need --format docker in build.
RUN micromamba env create -f environment.yml
RUN echo 'alias conda=micromamba' >> ~/.bashrc
SHELL ["micromamba", "run", "-n", "mcrafter", "/bin/bash", "-c"]

# RL Dependencies:
RUN pip install "gym==0.25.2"
RUN pip install crafter
RUN pip install --no-deps "stable-baselines3==1.8.0"

# Install VSCode server
RUN curl -fsSL https://code-server.dev/install.sh | sh

EXPOSE 8080

# code-server by default runs on 127.0.0.1 (only reachable inside the container).
ENTRYPOINT ["code-server", "--auth", "none", "--bind-addr", "0.0.0.0:8080"]

# Install Claude
RUN apt -y install npm nodejs
RUN npm install -g @anthropic-ai/claude-code
