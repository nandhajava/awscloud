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
LOCAL_IPV4=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
INSTANCE_LIFECYCLE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-life-cycle || echo "on-demand")

# Extract region from availability zone (remove the last character)
REGION=$(echo $AVAILABILITY_ZONE | sed 's/.$//')

# Create the HTML file
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EC2 Instance Dashboard</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            padding: 2rem;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .dashboard {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            padding: 2rem;
            backdrop-filter: blur(10px);
        }

        .header {
            text-align: center;
            margin-bottom: 3rem;
            position: relative;
            padding-bottom: 1rem;
        }

        .header::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 100px;
            height: 3px;
            background: linear-gradient(90deg, #007acc, #00a8e8);
            border-radius: 3px;
        }

        .header h1 {
            color: #2c3e50;
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
            background: linear-gradient(45deg, #007acc, #00a8e8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .header p {
            color: #666;
            font-size: 1.1rem;
        }

        .status-container {
            display: flex;
            justify-content: center;
            margin-top: 1rem;
        }

        .status {
            display: inline-flex;
            align-items: center;
            padding: 0.5rem 1rem;
            border-radius: 50px;
            background: linear-gradient(45deg, #00b09b, #96c93d);
            color: white;
            font-size: 0.9rem;
            gap: 0.5rem;
        }

        .status i {
            font-size: 0.8rem;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-top: 2rem;
        }

        .card {
            background: white;
            padding: 1.5rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            transition: all 0.3s ease;
            border: 1px solid rgba(0, 122, 204, 0.1);
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 15px rgba(0, 122, 204, 0.1);
            border-color: #007acc;
        }

        .card-header {
            display: flex;
            align-items: center;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #f0f0f0;
        }

        .card-header i {
            margin-right: 0.75rem;
            font-size: 1.25rem;
            color: #007acc;
            width: 24px;
        }

        .card-header h3 {
            color: #2c3e50;
            font-size: 1.1rem;
        }

        .card-value {
            font-size: 1.1rem;
            color: #2c3e50;
            word-break: break-all;
            padding: 0.5rem;
            background: #f8f9fa;
            border-radius: 6px;
            font-family: monospace;
        }

        .footer {
            margin-top: 3rem;
            text-align: center;
            color: #666;
            padding-top: 1.5rem;
            border-top: 1px solid #eee;
        }

        .timestamp {
            margin-top: 1rem;
            text-align: right;
            color: #666;
            font-size: 0.875rem;
            font-style: italic;
        }

        @media (max-width: 768px) {
            body {
                padding: 1rem;
            }

            .dashboard {
                padding: 1.5rem;
            }

            .grid {
                grid-template-columns: 1fr;
            }

            .header h1 {
                font-size: 2rem;
            }
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        .status i {
            animation: pulse 2s infinite;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="dashboard">
            <div class="header">
                <h1>EC2 Instance Dashboard</h1>
                <p>Real-time instance information and metrics</p>
                <div class="status-container">
                    <div class="status">
                        <i class="fas fa-circle"></i>
                        Active & Running
                    </div>
                </div>
            </div>

            <div class="grid">
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-fingerprint"></i>
                        <h3>Instance ID</h3>
                    </div>
                    <div class="card-value">$INSTANCE_ID</div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-server"></i>
                        <h3>Instance Type</h3>
                    </div>
                    <div class="card-value">$INSTANCE_TYPE</div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-map-marker-alt"></i>
                        <h3>Availability Zone</h3>
                    </div>
                    <div class="card-value">$AVAILABILITY_ZONE</div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-globe-americas"></i>
                        <h3>Region</h3>
                    </div>
                    <div class="card-value">$REGION</div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-wifi"></i>
                        <h3>Public IPv4</h3>
                    </div>
                    <div class="card-value">$PUBLIC_IPV4</div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-network-wired"></i>
                        <h3>Private IPv4</h3>
                    </div>
                    <div class="card-value">$LOCAL_IPV4</div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-barcode"></i>
                        <h3>AMI ID</h3>
                    </div>
                    <div class="card-value">$AMI_ID</div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-globe"></i>
                        <h3>Hostname</h3>
                    </div>
                    <div class="card-value">$HOSTNAME</div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-clock"></i>
                        <h3>Instance Lifecycle</h3>
                    </div>
                    <div class="card-value">$INSTANCE_LIFECYCLE</div>
                </div>
            </div>

            <div class="footer">
                <p>AWS EC2 Instance | Managed Infrastructure</p>
            </div>

            <div class="timestamp">
                Last Updated: $(date)
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Restart the Apache service
systemctl restart httpd