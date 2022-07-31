variable "vpc" {
    type = string
    default = "vpc_sre"
  }

variable "az" {
    type = map
    default = {
        "az1" = "us-west-1a"
        "az2" = "us-west-1c"
    }
  
}
























