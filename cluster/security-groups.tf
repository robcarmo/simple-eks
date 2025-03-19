resource "aws_security_group_rule" "demo-node-ingress-http" {
  description              = "Allow HTTP inbound"
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.demo-node.id
  to_port                  = 80
  type                     = "ingress"
  cidr_blocks              = ["0.0.0.0/0"]
}
