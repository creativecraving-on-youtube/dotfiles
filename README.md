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

## Usage
1. Install the installer
	1. Download the install script file from the *install* branch.
	2. Copy it to a folder on your path, and give it a cute name. `pone-my-home-folder.sh` looks appropriate.
	3. Mark it as executable.
2. Navigate to the folder where you usually keep code assets.
3. Run the script. It will download the project to a folder called `dotfiles` in the current directory.
4. During the run, interactively select a configuration to apply from the provided list.
	- Your selected environment will exist under `dotfiles/<env-name>`.
5. Verify that all the files in your home folder have been appropriately borked. Read the `while` loop under the `install()` function to see how borked it is. :-)

## Environments
An *environment* is a git branch prefixed with `env/` that contains a `files/` folder at the toplevel of the work tree. Only files and folders under `files/` will be copied into the home folder by the install script. This allows you to store junk at the top level.

Additionally, there's a special folder, `files/dot`. Files under this folder will have a dot prefixed to their name as they are copied into the home folder. For example, `~/.bashrc` should be stored in the configuration as `files/dot/bashrc`. The reason for this is that "dot files" are ignored by git by default, and it gets really annoying having to do `git add --force` each time.

If you want to manage a file or folder called `~/dot` in your environment, then too bad! There's no workaround. However, `~/.dot` is fine, of course, since it is stored at `files/dot/dot`.

### Creating a new environment

```bash
git switch --orphan env/my-happy-place # --orphan is recommended!
mkdir -p files/dot
touch files/dot/{bashrc,bash_profile,profile}
mkdir -p files/dot/config/nixpkgs
cat > files/dot/config/nixpkgs/config.nix <<EOF
{
  strictDepsByDefault = true; # Break every package on your system
  enableParallelBuildingByDefault = true; # Just say no to cached builds
  allowUnfreePackages = [
    "vscode-fhs" "reaper"
  ]
}
EOF
cat > files/affirmations <<EOF
You OWN the world! But, you lent it out to your neighbor, Bill; who sent it to his friend, Elon; who isn't ready to give it back yet. Call him again in a few days, and __BE FIRM__ this time!
EOF
```

In this new environment, we've configured files to be installed to these locations in the home folder:

```
~/affirmations
~/.bashrc
~/.bash_profile
~/.profile
~/.config/nixpkgs/config.nix
```
