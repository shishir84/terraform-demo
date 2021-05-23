variable "cidr_block" {
    type = list(string)
    default = ["172.20.0.0/16", "172.20.10.0/24"]
}

variable "ports" {
    type = list(number)
    default = [22,80,8080,443,8081]
}

variable "ami" {
    type = string
    default = "ami-010aff33ed5991201"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "instance_type_nexus" {
    type = string
    default = "t2.medium"
}