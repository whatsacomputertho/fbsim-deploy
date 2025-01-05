# FBSim Deploy

> Deployment manifests for the FBSim UI and API

## Overview

Deployment configuration for deploying the FBSim UI and API across various platforms, including Kubernetes and Docker Compose.

## Deploying FBSim

To deploy FBSim locally using `docker compose`:
1. Clone this repository
2. In the command line, `cd` to `deploy/compose/local`
3. Run `docker compose up` (interactive) or `docker compose up -d` (non-interactive)

For instructions on deploying FBSim on a production system using `docker compose`, see [_Deploying FBSim in production_](deploy/compose/prod/README.md)
