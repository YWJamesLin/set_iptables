set_iptables
============

script to set iptables

# Usage

```zsh
chmod u+x ./setipt.sh

# edit this script to be the one you need
vim setipt.sh

#make $1 as 1 to set up filter input default accept mode (for testing purpose)
./setipt.sh 1

#make $1 as 0 to set up filter input default drop mode (for most product env.)
./setipt.sh 0
```

## Warning
1. Do not try to execute script without any modify and $1 == 0. If you connect your device via SSH, you will be blockd.
