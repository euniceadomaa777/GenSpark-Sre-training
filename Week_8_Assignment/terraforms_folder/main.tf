# Create a VPC
resource "aws_vpc" "splunk_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy = "default"
  tags = {
    "Name"  = "splunk_vpc"
  }
}

# Create a internet_gateway
resource  "aws_internet_gateway" "splunk_vpc_igw" {
    vpc_id = aws_vpc.splunk_vpc.id
    tags = {
        Name = "internet-gate"
    }
}


# Create a Public Subnet
resource "aws_subnet" "splunk_subnet_1" {                             #create a Subnet resource
    vpc_id = aws_vpc.splunk_vpc.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-west-1a"
    tags = {
      "key" = "Public Subnet", 
      "Name" = "subnet_1"
    }
  
}

resource "aws_subnet" "splunk_subnet_2" {                             #create a Subnet resource
    vpc_id = aws_vpc.splunk_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-west-1c"
    tags = {
      "key" = "Public Subnet",
      "Name" = "subnet_2"
    }
  
}

# Create a public Route Table
resource "aws_route_table" "pubic_rt"{
    vpc_id = aws_vpc.splunk_vpc.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.splunk_vpc_igw.id
}
    tags = {
      Name = "public_route_table"
    }
}


# Create a Route
resource "aws_route_table_association" "splunk_rt_tbl_assoc_1" {              # creating aws_route_table_association resource & gave it the name "my_vpc_us_west1_public"
subnet_id = aws_subnet.splunk_subnet_1.id
route_table_id = aws_route_table.pubic_rt.id
}


resource "aws_route_table_association" "splunk_rt_tbl_assoc_2" {              # creating aws_route_table_association resource & gave it the name "my_vpc_us_west1_public"
subnet_id = aws_subnet.splunk_subnet_2.id
route_table_id = aws_route_table.pubic_rt.id
}

# Create Security Groups
resource "aws_security_group" "allow-ssh" {
        name = "allow_ssh_sg"
        description = "allow SSH inbound connections"
        vpc_id = aws_vpc.splunk_vpc.id 

        ingress{
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        } 

        egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }

        tags = {
          "Name" = "allow ssh sg"
        }
     }

resource "aws_security_group" "allow_http" {
  name        = "allow_http_sg"
  description = "Allow HTTP inbound connections"
  vpc_id = aws_vpc.splunk_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_Http_sg"
  }
}
     # Create our instance to test everything by declaring aws_instance

resource "aws_iam_role" "IAM_NEW_role" {
  name = "splunk-eks-cluster"
  assume_role_policy = <<POLICY
  {
        "Version": "2012-10-17",
        "Statement": [
                      {
                          "Effect": "Allow",
                          "Principal": {
                          "Service": "eks.amazonaws.com"
                          },
                          "Action": "sts:AssumeRole"
                      },
                      {
                              "Effect": "Allow",
                              "Principal": {
                              "Service": "ec2.amazonaws.com"
                            },
                        "Action": "sts:AssumeRole"
                      }  
]
}
  POLICY
}

# resource for creating IAM role policy attachment which is Amazon EC2 container

resource "aws_iam_role_policy_attachment" "splunk-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.IAM_NEW_role.name
}

resource "aws_iam_role_policy_attachment" "splunk-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.IAM_NEW_role.name
}

#rsource for worker node policy
resource "aws_iam_role_policy_attachment" "splunk-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.IAM_NEW_role.name
}

#resource for CNI policy on AmazonEkS
resource "aws_iam_role_policy_attachment" "splunk-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.IAM_NEW_role.name
}

#Resource for eks cluster 
resource "aws_eks_cluster" "splunk_cluster" {
  name = "splunk_cluster"
  role_arn = aws_iam_role.IAM_NEW_role.arn


vpc_config{
  subnet_ids = [aws_subnet.splunk_subnet_1.id, aws_subnet.splunk_subnet_2.id]
}

depends_on =[
    aws_iam_role_policy_attachment.splunk-role-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.splunk-role-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.splunk-role-AmazonEKSClusterPolicy
]
} 

# resource for aws_eks_node_group
resource "aws_eks_node_group" "splunk-nodegroup" {
  cluster_name = aws_eks_cluster.splunk_cluster.name
  node_group_name = "splunk_nodegroup"
  node_role_arn = aws_iam_role.IAM_NEW_role.arn
  subnet_ids = [aws_subnet.splunk_subnet_1.id, aws_subnet.splunk_subnet_2.id]

  scaling_config {
    desired_size = 3
    max_size = 3
    min_size = 3
  }
  ami_type = "AL2_x86_64"
  instance_types = ["t3.micro"]
  capacity_type = "ON_DEMAND"
  disk_size = 30

  remote_access {
    ec2_ssh_key = "new-eunice-keypair"
    source_security_group_ids = [aws_security_group.allow-ssh.id, aws_security_group.allow_http.id]  
  }

  depends_on = [
    aws_iam_role_policy_attachment.splunk-role-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.splunk-role-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.splunk-role-AmazonEKSWorkerNodePolicy
  ]
}


#terraform init
#terraform validate
#terraform plan
#terraform apply


  






















