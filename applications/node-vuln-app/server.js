const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
    res.send('Vulnerable Node.js App (Node 14 - contains known CVEs)');
});

app.get('/health', (req, res) => {
    res.json({
        status: 'running',
        node: process.version,
        vulnerable: true
    });
});

app.listen(PORT, () => {
    console.log(`Node.js vulnerable app on port ${PORT}`);
});
