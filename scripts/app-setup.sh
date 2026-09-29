#!/bin/bash
set -euxo pipefail

mkdir -p /opt/app
cd /opt/app

cat > /opt/app/index.html <<'HTMLEOF'
<!DOCTYPE html>
<html>
  <head><title>App</title></head>
  <body><h1>Private Instance Application</h1></body>
</html>
HTMLEOF

cat > /etc/systemd/system/app.service <<'SERVICEEOF'
[Unit]
Description=Static HTML app
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/app
ExecStart=/usr/bin/python3 -m http.server 8000 --bind 0.0.0.0
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICEEOF

systemctl daemon-reload
systemctl enable app.service
systemctl start app.service