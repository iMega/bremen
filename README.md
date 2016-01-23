# Bremen

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
