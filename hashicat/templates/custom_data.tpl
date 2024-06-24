#!/bin/bash

sudo apt -y update
sudo apt -y install apache2 cowsay
sudo systemctl start apache2
sudo chown -R ${admin_username}:${admin_username} /var/www/html

cat << EOM > /var/www/html/index.html
<html>
  <head><title>Meow!</title></head>
  <body>
  <div style="width:800px;margin: 0 auto">

  <!-- BEGIN -->
  <center><img src="http://${placeholder}/${width}/${height}"></img></center>
  <center><h2>Meow World!</h2></center>
  Welcome to ${prefix}'s app. Replace this text with your own. 
  <!-- END -->
  
  </div>
  </body>
</html>
EOM