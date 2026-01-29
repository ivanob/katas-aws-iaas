The VPC now has:

Public subnets (10.0.0.0/24, 10.0.1.0/24) → internet access via IGW
Private subnets (10.0.2.0/24, 10.0.3.0/24) → no internet access

Both pairs span 2 availability zones for high availability.

![VPC Diagram](../../res/diagram%20kata1.jpeg)