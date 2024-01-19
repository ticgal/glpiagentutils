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
# @script    glpi-agent-autoupdate.sh
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
chmod +x $SCRIPT_NAME

# Add script to cron for execution at startup
(crontab -l 2>/dev/null; echo "@reboot $SCRIPT_NAME") | crontab -

echo "Script $SCRIPT_NAME has been set up to run at startup."