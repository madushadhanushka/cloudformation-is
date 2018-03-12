# AWS CloudFormation Templates for WSO2 Identity Server Deployments

This repository contains AWS CloudFormation templates for WSO2 Identity Server.

## Setup instructions

NOTE : The Cloud Formation templates in this release assumes that the AWS deployment has internet connectivity. It has been recorded as an [improvement](https://github.com/wso2/cloudformation-is/issues/4) to be made.

1. Clone the repository
  ```
  $ git clone https://github.com/wso2/cloudformation-is.git
  ```
2. Go to [AWS console](https://console.aws.amazon.com/ec2/v2/home#KeyPairs:sort=keyName) and create a key value pair. This will be used to ssh to the nodes.
3. Add a self signed certificate for AWS ACM as explained [here](https://medium.com/@chamilad/adding-a-self-signed-ssl-certificate-to-aws-acm-88a123a04301). Copy the ARN value of the created certificate. This certificate will be used for the ALB fronting WSO2 Identity Server.
4. Go to [AWS CloudFormer console](https://console.aws.amazon.com/cloudformation/home).
5. Select Create Stack option and select choose a template option.
6. Browse and select the cloudformation template under cloudformation-templates directory for the deployment pattern
preferred and proceed with the deployment. Supported deployment patterns are as below.
   1. Pattern1: WSO2 Identity Server single node deployment with external datasources
   2. Pattern2: WSO2 Identity Server two node clustered deployment with external datasources

   Note:
   Above deployment patterns use a puppet master agent setup for the deployment.
7. Follow the on screen instructions, and provide the ARN of the certificate uploaded in step 3, SSH key, and other
requested information and proceed.

