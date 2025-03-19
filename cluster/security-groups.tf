resource "aws_security_group_rule" "demo-node-ingress-http" {
  description              = "Allow HTTP inbound"
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.demo-node.id
  to_port                  = 80
  type                     = "ingress"
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "breno-node-ingress-http" {
  description              = "Allow HTTP inbound"
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.breno-node.id
  to_port                  = 80
  type                     = "ingress"
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "breno-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.breno-node.id
  source_security_group_id = aws_security_group.breno-node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "breno-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.breno-node.id
  source_security_group_id = aws_security_group.demo-cluster.id
  to_port                  = 65535
  type                     = "ingress"
}
