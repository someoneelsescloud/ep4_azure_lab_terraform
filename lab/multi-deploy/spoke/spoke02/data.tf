data "terraform_remote_state" "hub_1" {
  backend = "local"

  config = {
    path = "../../hub/hub01/terraform.tfstate"
  }
}

data "terraform_remote_state" "hub_2" {
  backend = "local"

  config = {
    path = "../../hub/hub02/terraform.tfstate"
  }
}