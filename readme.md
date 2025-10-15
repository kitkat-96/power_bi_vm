# power_bi_vm

A Terraform project to quickly spin up a Windows Virtual Machine (VM) for using Power BI.

Since Power BI isn’t available natively on macOS, this project allows you to provision a Windows VM, use Power BI, and then destroy the VM when you’re done—making your workflow fast and temporary.

> ⚠️ Currently, this project only provisions the Windows VM. Automatic installation of Power BI is planned for future updates.

## Table of Contents

* [Prerequisites](#prerequisites)
* [Setup](#setup)
* [Credentials](#credentials)
* [Usage](#usage)
* [Destroying the VM](#destroying-the-vm)
* [Future Improvements](#future-improvements)
* [Contributing](#contributing)
* [License](#license)

## Prerequisites

* [Terraform](https://www.terraform.io/downloads) installed on your machine
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed (on macOS, you can use Homebrew):

```bash
brew update
brew install azure-cli
```

* [Microsoft Remote Desktop](https://apps.apple.com/us/app/microsoft-remote-desktop/id1295203466) installed on macOS
* Access to an Azure account configured with proper credentials
* Basic familiarity with Terraform and Azure

## Setup

1. Clone the repository:

```bash
git clone https://github.com/yourusername/power_bi_vm.git
cd power_bi_vm
```

2. Initialize Terraform:

```bash
terraform init
```

## Credentials

Create a `credentials.tf` file in the project root with your VM login credentials:

```hcl
variable "username" {
  default = "your-windows-username"
}

variable "password" {
  default = "your-secure-password"
}
```

> ⚠️ Keep this file secure and **do not commit it to version control**.

## Usage

1. Login to Azure CLI:

```bash
az login
```

2. Plan the Terraform deployment:

```bash
terraform plan
```

3. Apply the configuration to create the VM:

```bash
terraform apply
```

4. After the apply finishes, Terraform outputs the VM’s IP address.

5. Connect to the Windows VM using **Microsoft Remote Desktop** (MRD) on your Mac:

   * Open **Microsoft Remote Desktop**.
   * Click **Add PC** or the **+** button.
   * Enter the **PC name** as the VM’s IP address (from Terraform output). 
   * Click **Add User Account**, and enter the `username` and `password` from your `credentials.tf` file.
   * Double-click the new entry to connect to your VM.

> You can now use your Windows VM as a temporary Power BI environment.

## Destroying the VM

To remove the VM and clean up resources:

```bash
terraform destroy
```

> This ensures you aren’t charged for resources you no longer need.

## Future Improvements

* Automatic installation of Power BI on the VM
* Support for multiple cloud providers
* Optional preconfigured datasets or templates for Power BI
