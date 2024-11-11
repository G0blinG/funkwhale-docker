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