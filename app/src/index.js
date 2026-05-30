const htttp = require('http');

const port = process.env.PORT || 90;

const server = htttp.createServer((req, res) => {
    if (req.url == '/health' || req.url == '/') {
    res.writehead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
        status: "Healthy",
        enclave: "SECURE_ZONE_A",
        timestamep: new Date().toISOString()
    }));
} else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: "Not Found" }));
    }
});

server.listen(port, () => {
    console.log('Hardened microservice is now listening on port {port}');

});