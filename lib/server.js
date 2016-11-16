var port = (process.env.PORT || 8080),
    http = require('http'),
    ecstatic = require('ecstatic'),
    server = http.createServer(
      ecstatic({ root: __dirname + '/../public' })
    );

server.listen(port);

console.log(`Listening on :${port}`);
