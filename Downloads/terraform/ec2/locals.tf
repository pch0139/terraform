locals {
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr           = data.terraform_remote_state.vpc.outputs.vpc_cidr
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
}
