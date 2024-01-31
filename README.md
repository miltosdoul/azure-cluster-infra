## Azure test Platform

This repository contains the infrastructure code and creation pipelines for provisioning of an environment in the Azure platform.

The components which make up the environment are:
 - Azure Kubernetes Service (AKS): A Kubernetes cluster managed by Azure
 - Azure Application Gateway: An OSI-Layer-7 load balancer used in the platform's edge
 - Azure Web Application Firewall: A firewall used along with the Application Gateway to filter traffic and prevent various types of attacks (Cross site scripting, SQL injection, layer 7 DDoS etc.) 
