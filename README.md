# EMBL_workshop_2025

A [workflowr][] project.

[workflowr]: https://github.com/workflowr/workflowr

Welcome to the homepage for the 2025 Spatial Transcriptomics website.

# Schedule 

## Morning

### Visium HD

We'll run:
1. Space Ranger on Pawsey
2. Loupe Browser on your local laptops :)
3. R (through Singularity) on Pawsey

## Afternoon

### Xenium

- [Xenium part 1](analysis/01.Xenium.Rmd)
- [Xenium part 2](analysis/02.Xenium.Rmd)
- [Xenium part 3](analysis/03.Xenium.Rmd)

**Tip, make RBioformats work by running this line:**

```
dyn.load('/usr/lib/jvm/default-java/lib/server/libjvm.so')
```

# Setup

You will be given a username and password to login on the day.

You then have two options for connecting:

1. ssh in directly, using username@setonix.pawsey.org.au

2. connect to an RStudio instance already running via your browser: https://embl.sagc-dataviz.cloud.edu.au/username

## SSH setup

To ssh in directly, you need an ssh client installed.

### **Windows**

The latest builds of Windows 10 and 11 come with SSH server and client. To see if your windows installation has SSH:
- start Command Prompt (cmd) or Powershell
- type in 'ssh'

If SSH is available, you should see something like 

```
usage: ssh [-46AaCfGgKkMNnqsTtVvXxYy] [-B bind_interface]
           [-b bind_address] [-c cipher_spec] [-D [bind_address:]port]
           [-E log_file] [-e escape_char] [-F configfile] [-I pkcs11]
           [-i identity_file] [-J [user@]host[:port]] [-L address]
           [-l login_name] [-m mac_spec] [-O ctl_cmd] [-o option] [-p port]
           [-Q query_option] [-R address] [-S ctl_path] [-W host:port]
           [-w local_tun[:remote_tun]] destination [command]
```

If SSH is not available, please install [PuTTY](https://www.putty.org/).

Open PuTTY and connect using `setonix.pawsey.org.au` as the host name, and set port to 22.

When prompted, type in your username and password.


### **macOS**

Use `ssh` in the *Terminal* app. For example, if your user name is `user`, you would enter:

```
ssh user@setonix.pawsey.org.au
```

When prompted, type your password and then press `return`.


### **Linux** 

Same as macOS, an SSH client should be included. If not, install via the default package manager. e.g.:

```
# ubuntu
sudo apt install openssh-client
```

