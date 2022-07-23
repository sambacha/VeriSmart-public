variable "VERISMART_CONTAINER" {
  default = "manifoldfinance/verismart"
}

target "default" {
  tags = [VERISMART_CONTAINER]
}

target "all" {
  inherits = ["default"]
  platforms = [
    "linux/amd64",
  ] 
}
