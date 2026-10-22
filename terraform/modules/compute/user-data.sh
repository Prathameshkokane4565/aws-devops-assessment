#!/bin/bash
set -e

# System updates and Node.js installation
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs git

mkdir -p /opt/app
cd /opt/app

# Package file
cat << 'EOF' > /opt/app/package.json
{
  "name": "devops-assessment-app",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "@aws-sdk/client-secrets-manager": "^3.500.0",
    "express": "^4.19.2",
    "mysql2": "^3.9.2"
  }
}
EOF

# Server file
cat << 'EOF' > /opt/app/server.js
const express = require('express');
const mysql = require('mysql2/promise');
const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');

const app = express();
const PORT = process.env.PORT || 80;
const REGION = process.env.AWS_REGION || 'ap-south-1';
const SECRET_NAME = process.env.DB_SECRET_NAME || 'prod/rds/mysql';

const secretsClient = new SecretsManagerClient({ region: REGION });

async function getDatabaseCredentials() {
  const command = new GetSecretValueCommand({ SecretId: SECRET_NAME });
  const response = await secretsClient.send(command);
  return JSON.parse(response.SecretString);
}

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/db-check', async (req, res) => {
  try {
    const creds = await getDatabaseCredentials();
    const connection = await mysql.createConnection({
      host: creds.host,
      user: creds.username,
      password: creds.password,
      database: creds.dbname || 'appdb',
      connectTimeout: 4000
    });
    const [rows] = await connection.execute('SELECT 1 + 1 AS solution');
    await connection.end();
    res.status(200).json({
      status: 'connected',
      database: 'MySQL accessible via private subnet',
      query_result: rows[0].solution
    });
  } catch (error) {
    res.status(500).json({ status: 'failed', error_message: error.message });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Node app running on port ${PORT}`);
});
EOF

npm install --omit=dev

# Systemd Service Setup
cat << 'EOF' > /etc/systemd/system/nodeapp.service
[Unit]
Description=Node.js Production Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/app
ExecStart=/usr/bin/node /opt/app/server.js
Restart=always
Environment=NODE_ENV=production
Environment=PORT=80
Environment=AWS_REGION=ap-south-1
Environment=DB_SECRET_NAME=prod/rds/mysql

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nodeapp
systemctl start nodeapp