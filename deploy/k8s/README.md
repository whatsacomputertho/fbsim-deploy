# Deploying FBSim in Production (K3s)

> Steps to deploy the FBSim application in production using k3s

I will refine these steps tomorrow
1. Create AWS stack
2. Configure DNS to point at AWS stack with wildcard A record
3. SSH into the AWS stack and install k3s
4. Install the cert-manager CRDs
5. Clone fbsim-deploy repo
6. From the root of the repo, run `helm dependency build ./deploy/k8s`
7. Ensure the helm values are customized to your needs using `vi ./deploy/k8s/values.fbsim.yaml` from the root of the repo
8. From the root of the repo, run `helm install -f ./deploy/k8s/values.fbsim.yaml fbsim ./deploy/k8s`