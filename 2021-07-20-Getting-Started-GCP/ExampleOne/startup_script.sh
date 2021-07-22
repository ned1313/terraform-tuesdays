#! /bin/bash
apt update
apt -y install apache2
cat <<EOF > /var/www/html/index.html
<html><body><p>&#127790; &#127790; &#127790;</p></body></html>
