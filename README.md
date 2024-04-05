## Typescript AWS Lambda Starter

Starter project to demonstrate how to setup a Typescript api deployed on an AWS lambda function using terraform.

## Prerequisites

- [Node.js](https://nodejs.org/en/download/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [pnpm](https://pnpm.io/installation)

To deploy the application, you will need to have an AWS account and have the AWS CLI configured with your credentials.

## Setup

1. Clone the repository
2. Run `pnpm install` to install the dependencies
3. `cd api`
4. Copy the `terraform.tfvars.example` file to `terraform.tfvars`
5. run `terraform init` to initialize the terraform project

## Development

To run the application locally, you can use the following command:

```bash
pnpm run dev
```

It will start a local server.

## Deployment

Go to api and run the following commands:

```bash
pnpm run build
terraform apply
```
