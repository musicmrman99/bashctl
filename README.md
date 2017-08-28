# bashctl
bashctl is a small set of functions (the full list is available in the main help file) for writing, organising, running and sourcing bash/sh scripts and definitions (functions, aliases, etc.).

## A little history
###### (skip this bit if you don't care and just want to use it)
To be honest, I didn't even look for software or scripts for script/definition development and management before I wrote this. This was partially because at the time I didn't do much customization and because this project started out a lot smaller than it is now. [The very original version](https://github.com/musicmrman99/bashctl/blob/master/misc-info/src.sh.orig) was put straight into my `.bashrc`. Then it grew a bit and I put it in a separate script I sourced in my `.bashrc` called `ualias.sh` (for 'User-defined Aliases', ie. not the predefined ones in Ubuntu's default `.bashrc`), as it was originally only for organizing aliases, before I got onto writing more complex scripts and functions. I thought it would be quicker to write something myself just to source the aliases I used than to search for something that did the same, and originally it probably was. But then I started to think 'oh, I need it to do *this* as well', 'ooh, and *this*', 'and *that*', ... Each time I wanted another feature, I kept thinking "well, it's just one more feature, it can't be that hard ...". And each individual feature wasn't too hard (sort of), only, they kept piling up.

Over time `ualias` changed to encompass functions and the name was changed to `src` (in fact, I kept that name for that part of `bashctl`). Then I added the ability to execute scripts as well as source them and the name changed to `bash-exec`. But `bash-exec` sounds a bit too similar to the `exec` system call, which doesn't work in the same way that `bash-exec` actually did. So, I changed its name one last time to `bashctl`, without modifying any code (the name is derived from `systemctl`, from systemd).

Then, when I finally plucked up the courage to share my code on GitHub, I realised I had an irritation: `.git`. That folder and the other files that GitHub adds to a project, like `README.md` and `LICENSE`, looked messy in my Bash Library once I'd pulled the repo in, not to mention the fact that I could *theoretically* execute these files with `bashctl`. So, back to the editor for me ;) I invented a system whereby I could:
1. hold the files for the library in subdirectories of a separate directory (`$BASH_LIB_COMPONENTS_ROOT`, for which I often use the folder `~/Bash Library - Components`), then
2. symlink to these files in the main library (`$BASH_LIB_ROOT`, usually `~/Bash Library`), excluding any files I don't want to show through the use of a blacklist file (`blacklist.txt`).

As for the present, this little project may well gather dust and end up only being used by me, but there's no reason not to share ... just in case.

## Why use it?
###### (you should probably still read this, though)
Because it's useful. It's not **awesome**, it doesn't reimagine how you use the shell and it's not the perfect tool for *every* job. It's just useful for some.

Reasons why it's useful:
- It's simple
  - Well, it's actually not that simple, but you don't need to understand the complex parts (like templating, versioning and suites) to use the more basic actions (list, run, source, find and edit) on single files.

- It's local.
  - I don't like relying on external resources, particularly not from the internet - what if I have no internet connection, or my connection is slow?

## Setup
This is the way I would set up basctl, but change it to suit yourself ...

### Required setup
Create components directory and bashctl's component directory:
```
# Or however you want to name these directories.
mkdir -p "$HOME/Bash Library"
mkdir -p "$HOME/Bash Library - Components"
mkdir -p "$HOME/Bash Library - Components/bashctl"
```

Clone into the `bashctl` component:
```
git clone https://github.com/musicmrman99/bashctl.git "$HOME/Bash Library - Components/bashctl/"
```

Build the main library (of symlinks) for the first time - this is a 'chicken and egg' problem, so it's quite long:
```
# These will later be set on shell startup by bash (from your '.bashrc' file).
BASH_LIB_ROOT="$HOME/Bash Library"
BASH_LIB_COMPONENT_ROOT="$HOME/Bash Library - Components"

# This will be set on shell startup by bashctl, once we've set up the library
# and '.bashrc'.
# Set this here so the following commands know where to find bashctl's files.
bashctl__component="/bashctl"

# Source bashctl.
. "$BASH_LIB_COMPONENT_ROOT/$bashctl__component/bashctl/bashctl.def.sh"
. "$BASH_LIB_COMPONENT_ROOT/$bashctl__component/bashctl/helpers.def.sh"
. "$BASH_LIB_COMPONENT_ROOT/$bashctl__component/bashctl/init.sh"

# Set this again here, so `bashctl` knows where to find `update_symlinks`.
# 'init.sh' will have just overwritten it with the default value, so if you set
# it to anything other than '/bashctl' earlier, you'll have to re-set it.
bashctl__component="/bashctl"

# Perform the update. It shouldn't output anything unless debugging is on.
bashctl --update-symlinks
```

Finally, add at least this to your `.bashrc`:
```
# Or whatever you called these.
BASH_LIB_ROOT="$HOME/Bash Library"
BASH_LIB_COMPONENT_ROOT="$HOME/Bash Library - Components"

# Just in case something bad happens.
if [ ! -f "$BASH_LIB_ROOT/bashctl/bashctl.def.sh" ]; then
    printf '%s\n' "Error: $BASH_LIB_ROOT/bashctl/bashctl.def.sh: file not found!"
    return 1
elif [ ! -f "$BASH_LIB_ROOT/bashctl/helpers.def.sh" ]; then
    printf '%s\n' "Error: $BASH_LIB_ROOT/bashctl/helpers.def.sh: file not found!"
    return 1
elif [ ! -f "$BASH_LIB_ROOT/bashctl/init.sh" ]; then
    printf '%s\n' "Error: $BASH_LIB_ROOT/bashctl/init.sh: file not found!"
    return 1
fi

. "$BASH_LIB_ROOT/bashctl/bashctl.def.sh"
. "$BASH_LIB_ROOT/bashctl/helpers.def.sh"
. "$BASH_LIB_ROOT/bashctl/init.sh"

# Note: If you cloned bashctl into a component named anything other than
#       'bashctl', then you'll have to set the to the name of the component you
#       cloned it into here.
#bashctl-set --bashctl-component='/[component-name]'
```

### Optional Setup
After the code you put into your `.bashrc` earlier, you may also want to set some preferences and other settings. These are my settings, for example:
```
# Note: Preferences are implemented as bash global variables, so be aware of
#       this when dealing with subshels, su/sudo, etc.

# Preferences
# C=color, T=default-template, To=default-template-options (t=type, e=extension), E=default-editor
bashctl-set -C -T=basic-function-full -To='-t=definition -e=dev' -E=nano

# Other Settings
# U=fail-unrecognized, Af=attributes-fatal
bashctl-set -U -Af='+dev'
```
See `bashctl --help` for the full list of settings.

And after that, you may also want to source some things on tty/terminal startup. I use this:
```
# Source everything stable and enabled (including any temporary defs).
# '--quiet' stops it issuing warnings about files that were not sourced -
# including merely disabled definitions.
src --quiet 'aliases|functions|variables|tmp:.*'
```

After sourcing the above, you might want to enable the `force` setting generally. The `force` setting forces bashctl to run/source any files that match the references you give, regardless of their attributes. Personally, I don't, and for good reason - accidentally running something with an, eg. `dev` attribute (for 'under development'), could well end up being *very bad* for your system. But on the other hand, "If I say run it, THEN RUN IT - DON'T COMPLAIN ABOUT IT!" ... sometimes applies :wink:.
```
bashctl-set -F
```
You can always just add `-F` on the front of the command you *definitely* want to run, to to make the force specific to that command. I find doing that is best, but it depends on how you work.

## Basic usage
### Definitions
- `group`
  - Any directory under the bash library root, possibly including the root itself, depending on how you look at it.
- `name`
  - The name of a file, excluding its file extension.
- `attributes`
  - The parts of the file extension, each separated by a `.`.
- `script`
  - Any file with the `sh` attribute and without the `def` attribute, which is designed to be executed in a subshell.
- `definition`
  - Any file with both the `sh` and `def` attributes, which is designed to be executed in the current shell.
- `reference`
  - A string that `bashctl` expands to zero or more files to perform an action upon.

### General Notes
- In many programs (particularly GNU programs), options have a short and a long version. Some options take an argument. For options with an argument, the option's short version takes its argument as a separate argument to the command (ie. `-o value`) and the option's long version takes its argument with an assignment-like construct (ie. `--option=value`). This program follows most of these practices, except one - it uses the assignment-like construct for both long and short options (ie. `-o=value`, `--option=value`). It's odd (not very GNU-like at least), but you'll get used to it. I think it makes the source code of `bashctl` itself more readable and easier to understand, and therefore easier to maintain and to add new features.

- It is recommended not to ctrl-C bashctl if you have made any modifications to global settings (options with upper-case short versions), because then the code to reset them won't be executed. You may have to reset the modified settings manually, or reset them all to your defaults by executing `bashctl__unset_globals 'manual'; bashctl__set_global_defaults 'manual'`, then re-sourcing your `.bashrc`.

  There are some circumstances where it is fine, but these are limited:
  - If you are using `bashctl-get` or `bashctl-set` this also isn't relevant, as the code to reset the globals would not be run anyway (for different reasons).
  - If you are using `const-run` or `const-src` this isn't relevant, as modifications cannot be made to globals in that case.
  - This does not apply during execution of the scripts specified for the `run` action, where either the script itself, or another script/program that the script runs (in the foreground), somehow handles the SIGINT signal to exit gracefully. You may want to add at least `trap 'exit 1' SIGINT` to the top of all scripts that are meant to be run through bashctl.

- Each part of a normal reference (ie. not a `create` reference) is a (grep extended) regex, but that regex must match the entire group/file name.

- References often have to be quoted to avoid the shell interpreting certain characters. Some examples are:
  - `|` (ie. OR in regex, not pipe in sh)
  - `(` and `)` (ie. sub-expression in regex, not sub-shell in sh)
  - `*` (ie. the 'repeat 0 or more times' token in regex, not the wildcard in sh)

  In the case of the wildcard character, is is unlikely that references with more that one part will match any files in the current directory. For example, a reference like `.*:.*` would only match files in the current directory that begin with a `.` and contain at least one occurence of `:.` after that. For example, a file called `.my-file:.sh` would match, but would you name a file like that?!
  
  However, to be on the safe side, it is probably a good idea to get into the habit of single-quoting all references, as is often done with the arguments to programs like `sed` and `awk`, or at least single-quote any references that contain any globbing characters.

- References are **not** recursive. For example, the reference `.*` would only match the files in the root of the bash library - no further.

- The (small) built-in template library contains the templates that I use myself, although you can replace any or all of the templates as you wish.

- The templates of the built-in template library are designed to be, at least partially, mix-and-match. You can use more than one `create` action on the same reference, but with different templates. In the built-in template library, I have mostly used this feature to separate the code files and help files, mostly to prevent code/text duplication. The code templates can have any name, really, just avoid the main suffixes. The help templates have the suffix `-help`. The combinations of templates that I use the most have their own 'templates' (which contain only symbolic links), with the suffix `-full`. I used the suffix `-full` because you really should include help files - code without help, or at least some kind of information to explain how to use the code, isn't really 'complete'. To me, it's only *half* written.

### Examples
These are the main actions, with examples of some common uses of them. For detailed info of each, you should read the help files, or other information stated in the examples. They are listed in rough order of when they would be used over the course of development, maintenance and management of scripts/definitions, with inverse actions listed together.

#### Help
Your best friend.

Print the main help file.
```
bashctl --help
bashctl -h
```

Print help for a particular action or component.
```
bashctl --help=list
```

#### Create and Delete
The `create` and `delete` actions are the most useful actions, and therefore most complex :wink:. If you just want to get started, then commit them to memory and continue. If you want to learn how to use them properly and fully, then read the `TEMPLATES.md` file.

Create (`-c`) two instances of the blank template, including help file (`=blank-full`), named `disk` and `network`, in the `aliases` group, with the attributes `def` and `sh` (the `-t=def` part of `-To=...`) and no additional attributes (the `-e=` part of `-To=...`).
```
bashctl -To='-t=def -e=' -c=blank-full aliases:disk aliases:network
```

To delete the instances created above, the template copier must be given the same parameters, but the opposite action. Basically, just duplicate the line for `create` and replace `-c` with `-del`.
```
bashctl -To='-t=def -e=' -del=blank-full aliases:disk aliases:network
```

#### List
Lists everything that matches what you give it. This can be useful to show which files another action would affect, before performing it.

List everything in the root and one level down.
```
bashctl -l '.*:.*'
```

List everything in the `aliases` group. Note that this would also list the versions of the file named `aliases` in the root, if any exist.
```
bashctl -l 'aliases:.*'
```

List everything with the `disabled` attribute in the root and one level down. `bashctl` doesn't natively support doing this (yet), so this workaround will have to do for now. The workaround isn't 100% reliable - if a group or name contains a `(` character, it may break. Why *might* it break? ... it depends on which attribute you're looking for and where that attribute is in the file extension of the files you're searching.
```
bashctl -C=raw -l '.*:.*' | grep -E '.*?\((.*/|)disabled(|/.*)\)$'
```

#### Run and Source
Runs/Sources the files that match what you give them.

bashctl has two main wrappers for doing this - `run` and `src`. These are currently equivalent to `bashctl -s` and `bashctl -r`, respectively, although this may change in the future. There are two others - `const-run` and `const-src` - but these are primarily used within suites, or, generally, for running/sourcing scripts and definitions from within another script/definition. On the command-line, you'll probably only use `run` and `src`.

Source everything in the `aliases` group. Note that this would also source one of the versions of the file named `aliases` in the root, if any exist.
```
src 'aliases:.*'
```

#### Enable and Disable
Set and unset attributes of the files that match what you give them.

The default attribute to set/unset (if another is not given) is the `disabled` attribute. The problem with this is that it means that `-e` on its own *disables* a script/definition, while `-d` on its own *enables* a script/definition. This is pretty counter-intuitive when thinking about the `-e`/`-d` options without an argument, but is in-keeping with the idea of setting/unsetting *any* attribute, not only setting/unsetting a 'disabled' status.

- Note to developers/anyone with an interest:

  It would be a pretty straightforward change to make `-e`/`-d` set/unset the `enabled` attribute, instead, which would be more intuitive for use without an argument, but has two downsides that I can see straight off, both of which related to scripts/definitions being used outside of the management of `bashctl`:
  - Without the `enabled` attribute/file extension, `bashctl` considers the file 'disabled', but outside of the management of `bashctl`, it would be seen as *normal*, but **files may be disabled for a good reason**.
  - Outside the management of `bashctl`, the `enabled` attribute/file extension is just 'some arbitrary extra file extension' and, if placed as the last attribute (end of the file extension), it could mess up type detection in some programs, such as file managers.

Disable, then re-enable the `network` file in the `aliases` group. Note that this would also do the same to one version of the file named `aliases` in the root, if any versions exist.
```
bashctl -e aliases:network

# You can also specify the 'disabled' attribute, but you don't need to,
# as it's the default attribute. For scripts, however, it may make the
# command a little more self-explanatory.
bashctl -d=disabled aliases:network
```

Set the `dev` attribute (for 'under development') of the `network` file in the `aliases` group. Note that this would also do the same to one version of the file named `aliases` in the root, if any versions exist.
```
bashctl -e=dev aliases:network
```

#### Find
Print the `bashctl`-style location of the files that match the reference(s) you give it, and whose contents match the string you specify. It's useful if you need to quickly find where you defined *this*, or where *that* program is used.

`-g`/`--grep` is synonymous with `-f`/`--find`.

Find all occurences of `man` in all aliases (... and in one version of the `aliases` file in the root, if it exists).
```
bashctl -f='man' 'aliases:.*'
```

#### Edit
Edit the files that match what you give it.

Edit all the files in the `aliases` group (probably with the editor specified in your `.bashrc`) (... and one version of the file named 'aliases' in the root, if any versions exist ... I'll stop saying that now).
```
bashctl -ed 'aliases:.*'
```

Edit the `disk` file in the `aliases` group with `gedit`.
```
bashctl -ed=gedit aliases:disk
```
