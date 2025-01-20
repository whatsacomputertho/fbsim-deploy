# Deploying FBSim in Production (Single-node K3s)

> Steps to deploy the FBSim application in production using single-node k3s

## Step 1: Cluster setup

If no machine is currently available, provision a new machine for hosting.  Ensure inbound firewall rules are configured such that ports 80 and 443 can serve public HTTP and HTTPS traffic respectively, and such that SSH traffic over port 22 is only served to your current IP.

> Note: K3s does not run well on AWS t2 micro.  After moving up to t2 medium k3s ran without any apparent performance issue.

After provisioning the machine,
1. Save the private key in `~/.ssh` and `chmod 0400` the private key file for SSH into the node
2. Map the desired domain to the newly provisioned machine, ensure propagation via [DNS checker](https://dnschecker.org/) or equivalent tooling
   - It is recommended to 
3. SSH into the node (if ubuntu SSH in as `ubuntu@<ip>` and then `sudo su` to operate as root user) and [install k3s](https://docs.k3s.io/quick-start)
   - Verify the cluster is up and running by executing a `kubectl get nodes`
    ```
    # kubectl get nodes
    NAME      STATUS   ROLES                       AGE   VERSION
    fbsim-1   Ready    control-plane,etcd,master   62m   v1.31.4+k3s1
    ```
4. [Ensuse `git` is installed](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) on the machine, clone this repository onto the machine, and `cd` into the root of the repository
5. Ensure `helm` is installed on the machine (if ubuntu run `snap install helm --classic`)
6. Run `export KUBECONFIG=/etc/rancher/k3s/k3s.yaml` so that `helm` can mount the kubernetes context

## Step 2: Installation

Once the single-node cluster is set up with all dependencies installed on the machine, the installation is as simple as the following steps, assuming you are in the root of the cloned `fbsim-deploy repository:
1. Install the cert-manager CRDs on the cluster by running:
   ```sh
   export CERT_MANAGER_VERSION="v1.16.3" # Or replace with latest
   kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.crds.yaml
   ```
2. Run `helm dependency build ./deploy/k8s`
3. Ensure helm values file is properly customized by running `vi ./deploy/k8s/values.fbsim.yaml` and updating any values for your use case
4. Run `helm install -f ./deploy/k8s/values.fbsim.yaml fbsim ./deploy/k8s`
5. Wait for the certificate signing requests to complete
