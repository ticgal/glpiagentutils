# GLPI Agent Utils

[![Twitter](https://img.shields.io/badge/Twitter-TICgal-blue.svg?style=flat-square)](https://twitter.com/ticgalcom)
[![Web](https://img.shields.io/badge/Web-TICgal-blue.svg?style=flat-square)](https://tic.gal/)
[![License](https://img.shields.io/badge/License-GNU%20AGPLv3-blue.svg)](https://github.com/ticgal/taskdrop/blob/master/LICENSE)



## What is GLPI Agent Utils?

GLPI-Agent-Utils aims to be a toolkit to complement GLPI Agent. It's a set of scripts designed to improve how you use the GLPI Agent for managing IT assets.

## What is the GLPI Agent?

For more information about the GLPI Agent, please visit this [link](https://github.com/glpi-project/glpi-agent#readme).

## What does GLPI Agent Utils include?

### glpi-agent-portable-inventory.sh

This is a script that lets you start a local inventory process without needing to install any agents.

IT relies on the GLPI Agent AppImage version and the [glpi-agent-portable.sh](https://github.com/glpi-project/glpi-agent/blob/develop/contrib/unix/glpi-agent-portable.sh) generator script

Currently it runs and saves a local inventory to /tmp

#### Supported OS

**glpi-agent-portable-inventory.sh** works with any operating system that supports both flatpak and the GLPI Agent. 

It has been tested on:

- Ubuntu

#### How to use it

To use GLPI-Agent-Utils, all you need to do is:

1. Download it
2. Run it as sudo 
3. This will create an inventory in the `/tmp` folder.

Alternatively you can run this one-liner:

`curl -s https://raw.githubusercontent.com/ticgal/glpiagentutils/master/glpi-agent-portable-inventory.sh | sudo bash`
