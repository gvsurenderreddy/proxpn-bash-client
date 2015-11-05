#!/usr/bin/env bash

SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

CONF_BASE_PATH="/etc/proxpn";
CONF_FILE="proxpn.ovpn";
configFilePath="$SDIR/$CONF_FILE"
systemConfigFilePath="$CONF_BASE_PATH/$CONF_FILE";
executableFileName="proxpn";
executableFilePath="$SDIR/$executableFileName";
systemInstallPath="/usr/local/bin";
executableSystemInstallPath="$systemInstallPath/$executableFileName";
CREDS_FILE="login.conf";
systemCredsFilePath="$CONF_BASE_PATH/$CREDS_FILE";

if [ $EUID -ne 0 ]; then
   echo "This script must be run as root in order to install system-wide configuration and program link.";
   exit 1;
fi

if [[ ! -d "$CONF_BASE_PATH" ]]; then
  mkdir "$CONF_BASE_PATH";
fi

## Install system-wide configuration, if not already installed.
if [[ -f "$systemConfigFilePath" ]]; then
  echo "System-wide configuration file already exists; continuing installation...";
elif [[ -f "$configFilePath" ]]; then
  if cp "$configFilePath" "$systemConfigFilePath"; then
    echo "Successfully installed system-wide configuration file.";
  else
    echo "Error: Not able to install system-wide configuration file; exiting...";
    exit 1;
  fi
else
  echo "Error: OpenVPN configuration file not found in project: \"$SDIR/$CONF_FILE\"";
  echo "Exiting...";
  exit 1;
fi

## Install system-wide program link, if not already installed.
if [[ -f "$executableSystemInstallPath" ]]; then
  echo "System-wide program link already exists; continuing installation...";
elif [[ -f "$executableFilePath" ]]; then
  if ln -s "$(readlink -f "$executableFilePath")" "$executableSystemInstallPath"; then
    echo "Successfully installed system-wide program link.";
  else
    echo "Error: Not able to install system-wide program link; exiting...";
    exit 1;
  fi
else
  echo "Error: Main executable file not found in project: \"$executableFilePath\"";
  echo "Exiting...";
  exit 1;
fi

## Install system-wide credentials file, if not already installed.
if [[ -f "$systemCredsFilePath" ]]; then
  echo "System-wide credentials file already exists; continuing installation...";
else
  while [[ "$storeCredentialsChoice" != "y" && "$storeCredentialsChoice" != "n" ]]; do
    read -p "Do you want to enter and store your credentials? (y/n): " storeCredentialsChoice;
  done
  if [[ "$storeCredentialsChoice" == "y" ]]; then
    read -p "Username: " username;
    read -s -p "Password: " password;
    if echo -e "$username\n$password" > "$systemCredsFilePath"; then
      echo "Successfully installed system-wide credentials file.";
      unset username;
      unset password;
    else
      echo "Error: Not able to install system-wide credentials file; exiting...";
      unset username;
      unset password;
      exit 1;
    fi
  else
    echo "Choosing to not permanently store credentials.  They will have to be entered upon successive executions of the main script.";
  fi
fi
