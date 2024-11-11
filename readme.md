# This script is unfinished!
It will not work without manual interference. The django secret key often generates with special characters and thus sed fails to import it /sometimes/.
Selecting http as the network protocol, is not able to comment out reverse proxy tls and will generate nginx errors

I am not very literate with these issues at this time and the manual jigging has been easier than learning how to fix, so feel free to fork or pull request if u want :)

## Todo
 - [] Fix django secret key setting
 - [] Fix http reverse proxy config
 - [] Ask for custom media paths for in place imports // add optional web bucket support
 - [] Ask for federation
 - [] Implement checks for custom config files
 - [] Implement script memory (checking where left off in case of bad input??)
 - [] Optional system config stage to make sure container restarts and tunnels autostart on boot/crash

# Goblin Funkwhale Install Script
A script setup from the official docker install route of funkwhale, with fixes where commands were broken and added ease of use things like housing nginx config files within the home directory. Also automatic http configuring if planning to use cloudflare tunnels or the like !
Please make sure you're running the script from within its directory

# Data loss warning
The script will remake all config files when run, and will thus undo any manual config changes and thus may impact data access. Please use docker commands to start/stop the containers.
The important ones are, from within the funkwhale directory;
 - `docker compose up -d` to start the service and
 - `docker compose down` to stop the service
 - `docker compose down -v` will stop the service and clear volume data, use should be reserved for testing only!


# HTTPS
Please make sure you have the correct hostname and DNS setup prior to running the script, else nginx and certbot will fail.
