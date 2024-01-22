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
# @script    glpi-agent-autoupdater.sh
# @version   0.1.0
# @author    TICGAL
# @copyright Copyright (c) 2024 TICGAL
# @license   AGPL License 3.0 or any later version
#            http://www.gnu.org/licenses/agpl-3.0-standalone.html
# @link      https://github.com/ticgal/glpiagentutils
# @link      https://tic.gal/
#

# Define the URL and the download location of the script
SCRIPT_URL="https://raw.githubusercontent.com/ticgal/glpiagentutils/main/glpi-agent-wrapper.sh"
SCRIPT_NAME="/root/glpi-agent-wrapper.sh"
SERVICE_NAME="glpi-agent-wrapper.service"

# Function to check and install required commands
ensure_command() {
    local cmd=$1
    local package=$2

    if ! command -v $cmd &> /dev/null; then
        echo "$cmd could not be found, attempting to install it."

        if [[ -f /etc/debian_version ]]; then
            sudo apt-get update
            sudo apt-get install -y $package
        elif [[ -f /etc/redhat-release ]]; then
            sudo yum install -y $package
        else
            echo "Unsupported distribution. Exiting."
            exit 1
        fi
    fi
}

# Ensure required commands are installed
ensure_command curl curl
ensure_command jq jq
ensure_command wget wget
ensure_command chmod coreutils

# Check for root permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Download the script
echo "Downloading $SCRIPT_NAME to /root/..."
curl -o $SCRIPT_NAME $SCRIPT_URL

# Make the script executable
chmod 700 $SCRIPT_NAME

# Create systemd service file
echo "Creating $SERVICE_NAME in /etc/systemd/system/"
cat <<EOF > /etc/systemd/system/$SERVICE_NAME
[Unit]
Description=GLPI Agent Wrapper Service
After=network.target

[Service]
Type=simple
ExecStart=$SCRIPT_NAME
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to apply new service
systemctl daemon-reload

# Enable the service
systemctl enable $SERVICE_NAME

# Start the service
systemctl start $SERVICE_NAME

echo "Service $SERVICE_NAME has been created, enabled to run at startup and started."
