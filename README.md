# GLPI-Agent-Utils

[![Twitter](https://img.shields.io/badge/Twitter-TICgal-blue.svg?style=flat-square)](https://twitter.com/ticgalcom)
[![Web](https://img.shields.io/badge/Web-TICgal-blue.svg?style=flat-square)](https://tic.gal/)
[![License](https://img.shields.io/badge/License-GNU%20AGPLv3-blue.svg)](https://github.com/ticgal/taskdrop/blob/master/LICENSE)

GLPI-Agent-Utils is a set of scripts designed to make working with the GLPI Agent, an IT asset management tool, easier and more efficient.

## What is GLPI-Agent-Utils?

GLPI-Agent-Utils is a toolkit for the GLPI Agent. It's a set of scripts designed to improve how you use the GLPI Agent for managing IT assets.

## What is the GLPI Agent?

For more information about the GLPI Agent, please visit this [link](https://github.com/glpi-project/glpi-agent).

## What does it include?

### glpi-agent-portable-inventory.sh

This is a script that lets you start a local inventory process without needing to install any agents.

#### Supported Operating Systems

glpi-agent-portable-inventory.sh works with any operating system that supports both flatpak and the GLPI Agent. 

It has been tested on:
- Ubuntu

#### How to use it

To use GLPI-Agent-Utils, all you need to do is:
1. Download it
2. Run it as sudo 
3. This will create an inventory in the `/tmp` folder.
