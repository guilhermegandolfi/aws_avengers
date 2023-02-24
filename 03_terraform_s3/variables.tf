variable "project" {
  type    = string
  default = "avengers"
}

variable "tags" {
  type = map(any)
  default = {
    "Project" = "avengers"
    "Owner"   = "Guilherme Gandolfi"
  }
}

variable "env" {

}

variable "enviorment" {
  type = map(any)
  default = {
    "dev"  = "dev"
    "prod" = "prod"
  }
}