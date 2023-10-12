# HAProxy 세팅 관련

## HAProxy Stat Page Settings
```bash
listen stats *:8080
        mode http
        stats enable
        stats refresh 10s
        stats hide-version
        stats uri /haproxy/stats
        stats auth admin:admin
        http-request set-log-level silent
```

## HAProxy Failover Settings
```bash
frontend f_web
        bind *:80
        mode http
        option httplog
        default_backend web

backend web
        balance roundrobin
        option forwardfor
        server web-1 192.168.1.10:80 check
        server web-2 192.168.1.105:80 check backup
```