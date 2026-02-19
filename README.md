# IaC Template for Terraform

This template provides a getting started guide for creating an IaC-managed project in GCP.

## Initialize the project (single workspace)

First, we need to fill in the empty fields like base_name and the folder where the project will be created, update provider versión, etc.

Then we'll run a ``terraform init`` and create the state bucket by executing

```bash
terraform apply --target=module.state_bucket
```

When the command finishes, it will return the name of the created bucket at the end of the command

```bash
state_bucket_name = "bucket-de-ejemplo-3424234"
```

We take that name and put it in the ``versions.tf`` by uncommenting the backend block. Now we run

```bash
terraform init -migrate-state
```
This will move our state to the newly created bucket. From here you can run a complete ``terraform apply`` to create the Google project and start working.

## Initialize the project (multiple workspaces)

Here there's a small change. When we need to create a project with environments like dev, pro, etc., we need to make modifications. Follow the instructions in ``project.tf`` and change the single workspace block to the multiple one, and in ``state.tf`` uncomment the indicated line. Also in `kms.tf` and `outputs.tf` are files to be reviewed for multiple workspaces setup.

What these changes do is treat the ``default`` workspace as if it were ``sys`` (workspace where the state and all resources common to the 3 projects are deployed). To ensure that certain resources are only deployed in ``sys``, you have to add this line at the beginning of the resources.

```hcl
count  = terraform.workspace == "default" ? 1 : 0
```

And for those that should only be deployed in any environment except ``sys``, you have to add

```hcl
count  = terraform.workspace == "default" ? 0 : 1
```

Keep in mind that resources with that ``count`` will have two instances ``[0]`` and ``[1]``, and to reference values from those resources you have to specify the instance index. The one you'll always want is ``[0]``, for example:

```hcl
google_project.project[0].id
```

The rest of the guide is the same as the previous one.

## 🧼 Code Formatting and Validation with pre-commit
This repo uses pre-commit to automatically format and validate Terraform files before every commit.

### Installation
Recommeded: use Python virtualenv

```
python3 -m venv .venv
source .venv/bin/activate
```

Install pre-commit:

```bash
pip install pre-commit
```
Set up the hooks in your local repo:

```bash
pre-commit install
```

To run manually:

```bash
pre-commit run --all-files
```
