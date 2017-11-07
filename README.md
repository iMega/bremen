# Bremen

[![Build Status](https://semaphoreci.com/api/v1/irvis/bremen/branches/master/badge.svg)](https://semaphoreci.com/irvis/bremen)

[![Build Status](https://travis-ci.org/imega-teleport/bremen.svg?branch=master)](https://travis-ci.org/imega-teleport/bremen)

```
upstream bremen {
    server localhost:8083 fail_timeout=1s;
}
server {
    location /bremen {
        client_body_in_file_only on;
        proxy_pass http://bremen/;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-FILE $request_body_file;
    }
}
```
