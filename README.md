# oci-sap
These are Terraform modules for deploying a basic Infrastructure to support SAP on Oracle Cloud Infrastructure (OCI):

* [single-ad](single-ad) deploys all infrastructure on a single availability domain. This is a good fit for people who want to explore SAP on OCI.
  
## Prerequisites
First off you'll need to do some pre deploy setup.  That's all detailed [here](https://github.com/cloud-partners/oci-prerequisites).

## Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/cloud-partners/oci-sap.git
    cd oci-sap
    ls

## Deploy
Pick a module and `cd` into the directory containing it.  You can deploy with the following Terraform commands:

    terraform init
    terraform plan
    terraform apply

When complete, Terraform will print information on how you can access the deployment.

## Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy it:

    terraform destroy