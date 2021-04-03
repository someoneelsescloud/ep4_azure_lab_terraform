# Use to clean Terraform working folders
function Clean-Terraform {

if ( Test-Path -Path .terraform ) { Remove-Item .terraform -Recurse -Force }
if ( Test-Path -Path .terraform.lock.hcl ) { Remove-Item .terraform.lock.hcl -Recurse -Force }
if ( Test-Path -Path terraform.tfstate ) { Remove-Item terraform.tfstate -Recurse -Force }
if ( Test-Path -Path terraform.tfstate.backup ) { Remove-Item terraform.tfstate.backup -Recurse -Force }

}