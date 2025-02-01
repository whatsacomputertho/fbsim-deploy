# Deploying FBSim in production (compose)

> Steps to deploy the FBSim application in production using docker-compose

## Step 1: Preparation

Some initial steps include
- If no machine is currently available, provision a new machine for hosting
  - Save the private key in `~/.ssh` and `chmod 0400` the private key file for SSH into the machine
  - Map the desired domain to the newly provisioned machine, ensure propagation via [DNS checker](https://dnschecker.org/) or equivalent tooling
  - Ensure inbound firewall rules are configured such that ports 80 and 443 can serve public HTTP and HTTPS traffic respectively, and such that SSH traffic over port 22 is only served to your current IP
  - SSH into the machine, if ubuntu SSH in as `ubuntu@<ip>` and then `sudo su` to operate as super-user
- Ensure dependencies are installed on the machine used for hosting
  - [Install the docker engine, including `docker` and `docker compose`](https://docs.docker.com/engine/install/ubuntu/) on the host
  - [Install `git`](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) on the host
  - Clone this repository onto the host and `cd` into `deploy/compose/prod`

## Step 2: TLS Configuration

In order to enable TLS, we will need to create a TLS certificate signed by a valid certificate authority.  To do so, we will use [`certbot`](https://certbot.eff.org/) and [Let's Encrypt](https://letsencrypt.org/).

For authentication, certbot will create a temporary token file on our host, and then query our domain expecting our webserver to serve up that token file.  We will create a temporary Nginx webserver which will handle serving the token file to complete the auth dance.  Once complete, certbot will generate valid TLS certificates which we will then mount in our main proxy server.

Steps for doing so are outlined as follows:
1. In the `deploy/compose/prod` directory, run `mkdir -p data/certbot/conf` and `mkdir -p data/certbot/www`
2. Run the `acme-responder` image in the background, which we will use as a temporary webserver to respond to the certbot challenge
    ```sh
    # Run the acme-responder container
    export FBSIM_DOMAIN="my.domain.com" # Set to your domain
    docker run -d -it -p 80:80 --env FBSIM_DOMAIN="${FBSIM_DOMAIN}" --volume ./data/certbot/www:/var/www/certbot ghcr.io/whatsacomputertho/fbsim-acme-responder:v1.0.0-alpha.1
    
    # List running container images, check the logs to ensure healthy startup
    docker container ls
    docker logs ${CONTAINER_ID} # Get the container ID from the docker container ls command output
    ```
3. Run the `certbot` image interactively in dry run mode, which will issue the challenge and tell us if the challenge is handled successfully without granting our signed certificate
    ```sh
    # Run the certbot container in dry run mode
    # Select option 2
    #     2: Saves the necessary validation files to a .well-known/acme-challenge/
    #        directory within the nominated webroot path. A separate HTTP server must be
    #        running and serving files from the webroot path. HTTP challenge only (wildcards
    #        not supported). (webroot)
    docker run -it --volume ./data/certbot/www:/var/www/certbot --volume ./data/certbot/conf:/etc/letsencrypt certbot/certbot certonly -d whatsacomputertho.com --webroot-path /var/www/certbot --dry-run
    ```
4. Run the `certbot` image again without the `--dry-run` option to grant the certificates.  It will ask for additional user input which must be provided interactively.
5. Stop the `acme-responder` container and prune all stale containers on the system
    ```sh
    docker container stop ${CONTAINER_ID} # Container ID from step 2 above, get from docker container ls output
    docker container prune # Will prompt for y/N input, pass -f to force prune
    ```

At this point, you should find that certbot has populated the `./data/certbot/conf` directory with certificate data.  However, there are still additional files that we must add in order for our reverse proxy to load successfully.

6. Add [the default `options-ssl-nginx.conf` file from certbot](https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf) under `./data/certbot/conf/options-ssl-nginx.conf`
7. Add [the default `ssl-dhparams.pem` file from certbbot](https://raw.githubusercontent.com/certbot/certbot/refs/heads/master/certbot/certbot/ssl-dhparams.pem) under `./data/certbot/conf/ssl-dhparams.pem`

## Step 3: Deploy

In the `deploy/compose/prod` directory, simply run `docker compose up`, which will deploy the reverse proxy, API, and UI containers interactively and display their log streams.  If you wish to deploy non-interactively, then run `docker compose up -d`
