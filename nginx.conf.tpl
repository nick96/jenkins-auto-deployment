upstream jenkins {
  server jenkins:8080 fail_timeout=0;
}
 
server {
  listen 80;
  server_name jenkins.{{domain}};


  location /.well-known/acme-challenge/ {
    root /var/www/certbot; 
  }
  return 301 https://$host$request_uri;
}
 
server {
  listen 443 ssl;
  server_name jenkins.{{domain}};
 
  ssl_certificate /etc/letsencrypt/live/jenkins.{{domain}}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/jenkins.{{domain}}/privkey.pem;
 
  location / {
    proxy_set_header        Host $host:$server_port;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto $scheme;
    proxy_redirect          http:// https://;
    proxy_pass              http://jenkins;
    # Required for new HTTP-based CLI
    proxy_http_version      1.1;
    proxy_request_buffering off;
    proxy_buffering         off; # Required for HTTP-based CLI to work over SSL
    # workaround for https://issues.jenkins-ci.org/browse/JENKINS-45651
    add_header              'X-SSH-Endpoint' 'jenkins.{{domain}}:50022' always;
  }
}