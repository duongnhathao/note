http://nginx.org/en/docs/http/ngx_http_limit_req_module.html


# Global Settings 

# /etc/nginx/nginx.conf
under http{..} block, add following


limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

limit_req zone=one burst=100 delay=100;
