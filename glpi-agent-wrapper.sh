#!/bin/bash
# ------------------------------------------------------------------------
#
# LICENSE
#
# This file is part of the glpiagentutils GNU/Linux project.
#
# glpiagentutils scripts are free software: you can 
# redistribute it and/or modify it under the terms of the GNU Affero General 
# Public License as published by the Free Software Foundation, either version 3 
# of the License, or (at your option) any later version.
#
# glpiagentutils are distributed in the hope
# that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Notifications plugin. If not, see <http://www.gnu.org/licenses/>.
#
# ------------------------------------------------------------------------
#
# @script    glpi-agent-wrapper.sh
# @version   0.3.1
# @author    TICGAL
# @copyright Copyright (c) 2023-2024 TICGAL
# @license   AGPL License 3.0 or any later version
#            http://www.gnu.org/licenses/agpl-3.0-standalone.html
# @link      https://github.com/ticgal/glpiagentutils
# @link      https://tic.gal/
#
#!/bin/bash

# Help parameter
function show_help() {
  echo "Usage: $0 (--install|--update) [options]"
  echo ""
  echo "Options:"
  echo "  --help       Display this help message"
  echo "  --install    Install GLPI Agent with necessary parameters"
  echo "  --update     Reinstall GLPI Agent saving its configuration and tasks"
  echo ""
  echo "Note:"
  echo "  Parameters used are the same as the official glpi-agent-installer."
}

# Check if --help is provided
if [[ "$*" == *"--help"* ]]; then
  show_help
  exit 0
fi

# Check if both --install and --update are provided together
if [[ "$*" == *"--install"* && "$*" == *"--update"* ]]; then
  echo "Error: --install and --update options cannot be used together."
  show_help
  exit 1
fi

# Check if either --install or --update is provided
if [[ "$*" != *"--install"* && "$*" != *"--update"* ]]; then
  echo "Error: You must use either --install or --update option."
  show_help
  exit 1
fi

# Check if --install is used without server or local
if [[ "$*" == *"--install"* && "$*" != *"--server"* && "$*" != *"--local"* ]]; then
  echo "Error: The --install option requires either --server or --local parameter."
  show_help
  exit 1
fi

# Check if necessary commands exist
for cmd in curl jq wget chmod; do
  if ! command -v $cmd &> /dev/null; then
    echo "Error: $cmd is not installed."
    exit 1
  fi
done

# GitHub API URL for the latest release
API_URL="https://api.github.com/repos/glpi-project/glpi-agent/releases/latest"

# Use curl to GET the API response, and jq to parse out the tag_name, which corresponds to the latest version
echo "Fetching the latest release version..."
LATEST_GA_VERSION=$(curl --silent $API_URL | jq -r .tag_name)

# Check if version was successfully fetched
if [ -z "$LATEST_GA_VERSION" ]; then
  echo "Failed to fetch the latest version"
  exit 1
fi

# Create temp directory if not exists
TEMP_DIR="/tmp/glpi-agent"
mkdir -p $TEMP_DIR
cd $TEMP_DIR || exit 1

# URL for the unix installer
INSTALLER_FILE="https://github.com/glpi-project/glpi-agent/releases/download/$LATEST_GA_VERSION/glpi-agent-$LATEST_GA_VERSION-linux-installer.pl"

# Download the unix installer
echo "Downloading Installer from $INSTALLER_FILE"
curl -sS -L -O "$INSTALLER_FILE"

# If --install is the parameter make an installation with the parameters provided. No configuration is saved.
if [[ "$*" == *"--install"* ]]; then
  echo "Installing GLPI Agent $LATEST_GA_VERSION with the parameters $* ..."
  perl glpi-agent-"$LATEST_GA_VERSION"-linux-installer.pl --no-question --silent --runnow "$@"

# Else if --update keep config and tasks and update the agent
elif [[ "$*" == *"--update"* ]]; then
  EXTRA_OPTIONS=("${*#*--update}")
  
  # Command to get the currently installed GLPI agent version, adjust it based on your output format
  GA_VERSION=$(glpi-agent --version)
  INSTALLED_GA_LINUX_VERSION=$(echo "$GA_VERSION" | grep -oP 'GLPI Agent \(\K[0-9.-]+')
  INSTALLED_GA_VERSION=$(echo "$INSTALLED_GA_LINUX_VERSION" | cut -d'-' -f1)

  # Compare the versions
  if [[ "$INSTALLED_GA_VERSION" != "$LATEST_GA_VERSION" ]]; then
    echo "Update needed: Installed GLPI agent version $INSTALLED_GA_VERSION is different from the latest version $LATEST_GA_VERSION."
  
    # Save current config
    GA_CONFIG="/etc/glpi-agent/conf.d"
      if [ -d "$GA_CONFIG" ]; then
        cp $GA_CONFIG/*.cfg .
      else
        echo "No configuration is found. Cannot update the agent."
        exit
      fi

    # Save current installed packages
    GA_INSTALLED_TASKS=$(sudo glpi-agent --list-tasks) > /dev/null
    GA_AVAILABLE_TASKS=$(echo "$GA_INSTALLED_TASKS" | grep -oE '^[[:space:]]*-[[:space:]]+[^(]+' | awk -F ' ' '{print $2}' | paste -sd "," -)

    echo "Installed tasks: $GA_AVAILABLE_TASKS"

    # Update option. Reinstall on steroids
    perl glpi-agent-"$LATEST_GA_VERSION"-linux-installer.pl --reinstall --no-question --silent --type="$GA_AVAILABLE_TASKS" "${EXTRA_OPTIONS[@]}"

    # Recover config
    cp $TEMP_DIR/*.cfg $GA_CONFIG
    
    # Command to get the currently installed GLPI agent version, adjust it based on your output format
    GA_VERSION=$(glpi-agent --version)
    INSTALLED_GA_LINUX_VERSION=$(echo "$GA_VERSION" | grep -oP 'GLPI Agent \(\K[0-9.-]+')
    INSTALLED_GA_VERSION=$(echo "$INSTALLED_GA_LINUX_VERSION" | cut -d'-' -f1)
    
    # Compare versions after installation
    if [[ "$INSTALLED_GA_VERSION" != "$LATEST_GA_VERSION" ]]; then
      echo "Error. Agent not updated!"
      exit
    else
        # Execute agent if there's a new version
        glpi-agent
    fi

    # Clean up: delete the downloaded files and generated agent
    echo "Cleaning up..."
    rm -rf $TEMP_DIR 

    # Change back to the previous directory
    echo "New GLPI agent version $INSTALLED_GA_VERSION successfully updated."
    cd - || exit
  
  else
    echo "No update needed: Installed GLPI agent version $INSTALLED_GA_VERSION is up to date."
  fi
fi
exit 0
