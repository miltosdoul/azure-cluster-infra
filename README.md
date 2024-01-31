# Azure test Platform

This repository contains the infrastructure code and creation pipelines for provisioning of an environment in the Azure platform.

The components which make up the environment are:
 - Azure Kubernetes Service (AKS): A Kubernetes cluster managed by Azure
 - Azure Application Gateway: An OSI-Layer-7 load balancer used in the platform's edge
 - Azure Web Application Firewall: A firewall used along with the Application Gateway to filter traffic and prevent various types of attacks (Cross site scripting, SQL injection, layer 7 DDoS etc.)

## Architecture

## Authentication
Authentication of Github Actions and Terraform with Azure is achieved using a Service Principal and uses repository secrets to retrieve the credentials in the pipeline.

## Kubernetes cluster services
Currently in the Kubernetes cluster two basic Go services are used as placeholders, the [counter service](https://github.com/miltosdoul/counter-service) and the [caller service](https://github.com/miltosdoul/caller-service). The first simply increments a local counter variable on every received request and responds with the updated value, while the second service acts as a proxy between the caller and the counter service, returning the received number to the user.
