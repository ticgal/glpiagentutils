# GLPI Agent Utils

[![Twitter](https://img.shields.io/badge/Twitter-TICgal-blue.svg?style=flat-square)](https://twitter.com/ticgalcom)
[![Web](https://img.shields.io/badge/Web-TICgal-blue.svg?style=flat-square)](https://tic.gal/)
[![License](https://img.shields.io/badge/License-GNU%20AGPLv3-blue.svg)](https://github.com/ticgal/taskdrop/blob/master/LICENSE)

## Disclaimer
You can use them at your own risk.
If you need professional support, please get in touch with us.

## What are GLPI Agent Utils?

GLPI-Agent-Utils aims to be a toolkit to complement GLPI Agent. It's a set of scripts designed to improve how you use the GLPI Agent for managing IT assets.
Currently, these are the scripts:
- [glpi-agent-portable-inventory.sh](#glpi-agent-portable-inventory.sh)
- [glpi-agent-wrapper.sh](#glpi-agent-wrapper.sh)
## What is the GLPI Agent?

For more information about the GLPI Agent, please visit this [link](https://github.com/glpi-project/glpi-agent#readme).

## What do GLPI Agent Utils include?

### [glpi-agent-portable-inventory.sh](#glpi-agent-portable-inventory.sh)

This script lets you start a local inventory process without installing any agents.

It relies on the GLPI Agent AppImage version and the [glpi-agent-portable.sh](https://github.com/glpi-project/glpi-agent/blob/develop/contrib/unix/glpi-agent-portable.sh) generator script

Currently, it runs and saves a local inventory to /tmp

#### Supported OS

**glpi-agent-portable-inventory.sh** works with any operating system supporting Flatpak and the GLPI Agent. 

It has been tested on:

- Ubuntu

#### How to use it

To use GLPI-Agent-Utils, all you need to do is:

1. Download it
2. Run it as sudo 
3. This will create an inventory in the `/tmp` folder.

Alternatively, you can run this one-liner:

`curl -s https://raw.githubusercontent.com/ticgal/glpiagentutils/master/glpi-agent-portable-inventory.sh | sudo bash`

### [glpi-agent-wrapper.sh](#glpi-agent-wrapper.sh)

A quick GLPI Agent updater script 
It relies on the `glpi-agent-linux-installer.pl` to perform the update.

#### Supported OS

**`glpi-agent-wrapper.sh`** works with any operating system supported by the official `glpi-agent-linux-installer.pl `

It has been tested on:

- Ubuntu
However, it should work on any glpi-agent-linux-installer.pl  supported OS

#### How to use it

To use GLPI-Agent-Utils, all you need to do is:

1. Download it
2. Make it executable (chmod +x)
2. Run it as sudo 

There are three parameters:
1. --install
2. --update
3. --help

#### --install
It works as a wrapper to the plugin, making the installation pass the parameters to the script. 
At least a --server or --local is needed to install and generate an inventory. 
All the installations are silent by default. If you want them lengthy, use the official script.

Alternatively, you can run this one-liner:

`curl -s https://raw.githubusercontent.com/ticgal/glpiagentutils/develop/glpi-agent-wrapper.sh | sudo bash --install --server="https://yourserver.tld/" [add any other parameters needed]`

#### --update
This is a helpful parameter since the official script won't update the agent, preserving the parameters nor the installed modules.

Running the agent with the `--update´ parameter will:

- Check for the last version of the agent
- Download it
- Save your agent settings
- Save your installed agent modules
- Install the new agent with the previously installed modules
- Retrieve previous settings
- Run the agent

A convenient one-liner:
`curl -s https://raw.githubusercontent.com/ticgal/glpiagentutils/develop/glpi-agent-wrapper.sh | sudo bash --update`

#### --help
Self-explanatory :)
