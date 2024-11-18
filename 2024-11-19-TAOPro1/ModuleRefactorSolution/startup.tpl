#!/bin/bash

# Update the system
sudo yum update -y

# Install nginx
sudo amazon-linux-extras install nginx1.12 -y

# Start nginx service
sudo systemctl start nginx

# Enable nginx to start on boot
sudo systemctl enable nginx

# Create a basic web page with three taco emojis
echo "<html>
<head>
    <title>Tacos and TAO Pro!</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>🌮🌮🌮</h1>
</body>
</html>" | sudo tee /usr/share/nginx/html/index.html

# Restart nginx to apply changes
sudo systemctl restart nginx