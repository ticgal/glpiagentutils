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
# @script    glpi-agent-portable-inventory.sh
# @version   0.1.0
# @author    TICGAL
# @copyright Copyright (c) 2023 TICGAL
# @license   AGPL License 3.0 or any later version
#            http://www.gnu.org/licenses/agpl-3.0-standalone.html
# @link      https://github.com/ticgal/glpiagentutils
# @link      https://tic.gal/
#
#!/bin/bash

# Check if necessary commands exist
for cmd in curl jq wget chmod; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

# GitHub API URL for the latest release
API_URL="https://api.github.com/repos/glpi-project/glpi-agent/releases/latest"

# Variables for resources
PORTABLE_SCRIPT_URL="https://raw.githubusercontent.com/glpi-project/glpi-agent/master/contrib/unix/glpi-agent-portable.sh"

# Variable for temp directory
TEMP_DIR="./glpi_agent_portable"

# Create temp directory if not exists
mkdir -p $TEMP_DIR

# Change into temp directory
cd $TEMP_DIR

# Use curl to GET the API response, and jq to parse out the tag_name, which corresponds to the latest version
echo "Fetching the latest release version..."
VERSION=$(curl --silent $API_URL | jq -r .tag_name)

# Check if version was successfully fetched
if [ -z "$VERSION" ]; then
    echo "Failed to fetch the latest version"
    exit 1
fi

# URL for the latest AppImage
APPIMAGE_URL="https://github.com/glpi-project/glpi-agent/releases/download/$VERSION/glpi-agent-$VERSION-x86_64.AppImage"

# Download the AppImage
echo "Downloading AppImage..."
wget $APPIMAGE_URL

# Download the portable script
echo "Downloading portable script..."
wget $PORTABLE_SCRIPT_URL

# Get the downloaded AppImage file name
APPIMAGE_FILE=$(basename $APPIMAGE_URL)

# Make both downloaded files executable
chmod +x $APPIMAGE_FILE
chmod +x glpi-agent-portable.sh

# Generate the agent using the portable script
echo "Generating the GLPI agent..."
./glpi-agent-portable.sh

# The generated agent should now be in the current directory. 
# Adjust the following command to suit how you'd like to launch the agent.
# In this example, it's assumed that the generated agent is named 'glpi-agent'.

# Check if agent was successfully generated
if [ ! -f ./glpi-agent ]; then
    echo "Failed to generate the GLPI agent"
    exit 1
fi

# Run the agent for a local inventory in /tmp directory
echo "Launching the GLPI agent for a local inventory..."
./glpi-agent --local /tmp

# Clean up: delete the downloaded files and generated agent
echo "Cleaning up..."
# rm -f $APPIMAGE_FILE
# rm -f glpi-agent-portable.sh
# rm -f glpi-agent

# Change back to the previous directory
cd -

# Complete clean up: remove temp folder
rm -rf $TEMP_DIR

# Exit message
echo "Done. The requested inventory is at the /tmp folder"
