#!/bin/bash

# Update the system and install Apache
yum update -y
yum install -y httpd

# Start the Apache service
systemctl start httpd
systemctl enable httpd

# Fetch the IMDSv2 token
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`

# Fetch EC2 instance metadata using the IMDSv2 token
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type)
AVAILABILITY_ZONE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
PUBLIC_IPV4=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
AMI_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/ami-id)
HOSTNAME=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/hostname)

# Create the HTML file
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EC2 Instance Details</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f0f8ff;
            margin: 0;
            padding: 20px;
            color: #333;
        }
        .container {
            max-width: 700px;
            background-color: #ffffff;
            padding: 30px;
            margin: 50px auto;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
            border-top: 5px solid #007acc;
        }
        h1 {
            text-align: center;
            color: #007acc;
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            text-align: left;
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #007acc;
            color: white;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>EC2 Instance Details</h1>
        <table>
            <tr>
                <th>Attribute</th>
                <th>Value</th>
            </tr>
            <tr>
                <td>Instance ID</td>
                <td>$INSTANCE_ID</td>
            </tr>
            <tr>
                <td>Instance Type</td>
                <td>$INSTANCE_TYPE</td>
            </tr>
            <tr>
                <td>Availability Zone</td>
                <td>$AVAILABILITY_ZONE</td>
            </tr>
            <tr>
                <td>Public IPv4</td>
                <td>$PUBLIC_IPV4</td>
            </tr>
            <tr>
                <td>AMI ID</td>
                <td>$AMI_ID</td>
            </tr>
            <tr>
                <td>Hostname</td>
                <td>$HOSTNAME</td>
            </tr>
        </table>
    </div>
</body>
</html>
EOF

# Restart the Apache service to ensure it serves the latest content
systemctl restart httpd
