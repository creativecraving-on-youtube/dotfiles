# Dotfiles
This project has two components

1. My personal configuration for all of my systems, barring any sensitive values, like SSH keys
2. An installer that makes it effortless to install, update and switch out my configuration.

## ⚠️ Warning! ⚠️
This project will **overwrite** your home folder, and is currently in a lightly-tested pre-release status.
Do not try it unless you like pain, or want to evaluate your backup process.
## Goals
- [x] Manage multiple, distinct configurations (called "environments")
	- E.g, "work" and "home"
- [x] Painlessly install and update configuration in your home folder
	- [ ] Ensure we don't delete any files or data we aren't managing. (Probably works? Needs testing)
- [ ] Share common configuration subsets across related environments
- [ ] Support for
	- [x] NixOS
	- [ ] MSYS2
