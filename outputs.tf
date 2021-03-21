output "aws-ami" {
  value = data.aws_ami.latest-amazon-linux-image.id

}