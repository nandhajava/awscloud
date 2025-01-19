#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Instance 1" > /var/www/html/instance.txt

# Create index.html
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Home Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        nav {
            margin-bottom: 20px;
        }
        nav a {
            margin-right: 15px;
            color: #0066cc;
            text-decoration: none;
        }
        h1 { color: #333; }
    </style>
</head>
<body>
    <div class="container">
        <nav>
            <a href="/">Home</a>
            <a href="/products.html">Products</a>
            <a href="/orders.html">Orders</a>
        </nav>
        <h1>Welcome to Our Store</h1>
        <p>This is the home page of our store.</p>
        <p>Instance ID: <span id="instance-id">Instance 1</span></p>
    </div>
</body>
</html>
EOF

# Create products.html
cat > /var/www/html/products.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Products</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        nav {
            margin-bottom: 20px;
        }
        nav a {
            margin-right: 15px;
            color: #0066cc;
            text-decoration: none;
        }
        h1 { color: #333; }
        .product {
            border: 1px solid #ddd;
            padding: 10px;
            margin: 10px 0;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <nav>
            <a href="/">Home</a>
            <a href="/products.html">Products</a>
            <a href="/orders.html">Orders</a>
        </nav>
        <h1>Our Products</h1>
        <div class="product">
            <h3>Product 1</h3>
            <p>Description of product 1</p>
        </div>
        <div class="product">
            <h3>Product 2</h3>
            <p>Description of product 2</p>
        </div>
        <p>Instance ID: <span id="instance-id">Instance 1</span></p>
    </div>
</body>
</html>
EOF

# Create orders.html
cat > /var/www/html/orders.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Orders</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        nav {
            margin-bottom: 20px;
        }
        nav a {
            margin-right: 15px;
            color: #0066cc;
            text-decoration: none;
        }
        h1 { color: #333; }
        .order {
            border: 1px solid #ddd;
            padding: 10px;
            margin: 10px 0;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <nav>
            <a href="/">Home</a>
            <a href="/products.html">Products</a>
            <a href="/orders.html">Orders</a>
        </nav>
        <h1>Your Orders</h1>
        <div class="order">
            <h3>Order #12345</h3>
            <p>Status: Shipped</p>
        </div>
        <div class="order">
            <h3>Order #12346</h3>
            <p>Status: Processing</p>
        </div>
        <p>Instance ID: <span id="instance-id">Instance 1</span></p>
    </div>
</body>
</html>
EOF

# Update instance ID in all files
sed -i 's/Instance 1/Instance 1/g' /var/www/html/*.html