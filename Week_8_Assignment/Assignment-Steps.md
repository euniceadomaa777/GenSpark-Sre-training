WEEK_8 Assignment

1. create terraform scripts to set up VPC & EKS cluster Infrastructure. set up desired size of 3 nodes when 
2. Terraform was executed using the following commands;
	i.  Terraform init
	ii. Terraform validate
	iii.Terraform plan
	iv. Terraform apply
	
3. confirm from AWS console if all resources were created.

4. Connect your EC2 instance using the SSH client(AWS CLI or ubuntu CLI). The following commands should be used to;

a. download splunk
b. move downloaded file into a folder of your choice.
c. unzip the folder
d. navigate into the splunk folder
e. navigate into the bin folder
f. cd bin folder & accept license agreement.

Below are the respective commands;

i.sudo wget -O splunk-9.0.0.1-9e907cedecb1-Linux-x86_64.tgz "https://download.splunk.com/products/splunk/releases/9.0.0.1/linux/splunk-9.0.0.1-9e907cedecb1-Linux-x86_64.tgz"

ii. sudo mv file.tgz /opt

iii. Go to opt folder(cd /opt/) and execute this following command

iv. sudo tar -xvzf file.tgz

v. cd splunk folder

vi. cd bin folder  - cd splunk/bin/

vii. sudo ./splunk start -—accept-license

5. Connect to your splunk using the public dns address on default port 8000

JENKINS APPLICATION INSTALLATION

1. Connect to Jenkins using the following commands;
  A. sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  B. yum install epel-release # repository that provides 'daemonize'
  C. yum install java-11-openjdk-devel
  D. yum install jenkins

2. Start Jenkins Service with `Service Jenkins start`

3. Access Jenkins by typing your EC2 public dns address and the Jenkins port(8080) in your browser. My EC2 IP address was:
http://ec2-54-176-113-98.us-west-1.compute.amazonaws.com:8080/computer/

4. Configure Jenkins steps to download python code/appplication from github repository
5. Build and deploy application with the Jenkins 
