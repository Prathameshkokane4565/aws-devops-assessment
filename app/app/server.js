@'
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
    res.status(500).json({
      status: 'failed',
      error_message: error.message
    });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Node app running on port ${PORT}`);
});
'@ | Out-File -FilePath app/server.js -Encoding utf8