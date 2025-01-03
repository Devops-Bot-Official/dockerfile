#!/bin/bash

set -e

# Function to display a stage
function show_stage() {
  echo -e "\n\033[1;32m>>> $1\033[0m"
}

# Function to install a package
function install_package() {
  if ! command -v "$1" &>/dev/null; then
    show_stage "Installing $1..."
    if [ "$PACKAGE_MANAGER" == "apt-get" ]; then
      apt-get install -y "$2"
    elif [ "$PACKAGE_MANAGER" == "yum" ] || [ "$PACKAGE_MANAGER" == "dnf" ]; then
      $PACKAGE_MANAGER install -y "$2"
    else
      echo "Unsupported package manager."
      exit 1
    fi
  else
    echo "$1 is already installed."
  fi
}

# Step 1: Detect the operating system and package manager
show_stage "Checking operating system..."
if [ -f "/etc/debian_version" ]; then
  PACKAGE_MANAGER="apt-get"
  update_command="apt-get update -y"
elif [ -f "/etc/os-release" ]; then
  . /etc/os-release
  if [[ "$ID" == "amzn" ]]; then
    PACKAGE_MANAGER="yum"
    update_command="yum update -y"
  elif [[ "$ID_LIKE" == *"rhel"* ]] || [[ "$ID" == "centos" ]] || [[ "$ID" == "fedora" ]]; then
    if command -v dnf &>/dev/null; then
      PACKAGE_MANAGER="dnf"
      update_command="dnf update -y"
    else
      PACKAGE_MANAGER="yum"
      update_command="yum update -y"
    fi
  else
    echo "Unsupported operating system."
    exit 1
  fi
else
  echo "Unsupported operating system."
  exit 1
fi

# Step 2: Update and install prerequisites
show_stage "Updating package list and installing prerequisites..."
eval "$update_command"
install_package "wget" "wget"
install_package "pip3" "python3-pip"

# Step 3: Download the .whl file
WHL_URL="https://raw.githubusercontent.com/Devops-Bot-Official/DOB-Installation-Package/master/devops_bot-0.1-py3-none-any.whl"
WHL_FILE="devops_bot-0.1-py3-none-any.whl"

show_stage "Downloading the package..."
wget -q "$WHL_URL" -O "$WHL_FILE"

# Step 4: Install the package
show_stage "Installing the package..."
pip3 install "$WHL_FILE"

# Step 5: Clean up
show_stage "Cleaning up..."
rm -f "$WHL_FILE"

# Step 6: Start the UI service as a background process
show_stage "Starting the DevOps Bot UI service in the background..."
nohup /usr/local/bin/dob run-ui --port=4102 > /var/log/devops-bot-ui.log 2>&1 &

show_stage "Installation and UI service setup complete!"
