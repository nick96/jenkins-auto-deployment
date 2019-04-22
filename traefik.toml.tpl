debug = false
logLevel = "INFO"
defaultEntryPoints = ["https", "http"]

[file]
watch = true

[traefikLog]

[accessLog]

[entryPoints]
    [entryPoints.http]
    address = ":80"
       [entryPoints.http.redirect]
       entryPoint = "https"
    [entryPoints.https]
    address = ":443"
    [entryPoints.https.tls]

[retry]

[docker]
endpoint = "unix:///var/run/docker.sock"
watch = true
exposedByDefault = false

[acme]
email = "{{letsencrypt_email}}"
storage = "acme.json"
entryPoint = "https"
[acme.dnsChallenge]
provider = "digitalocean"
delayBeforeCheck = 0
[[acme.domains]]
  main = "*.{{domain}}"
  sans = [ "{{domain}}" ]