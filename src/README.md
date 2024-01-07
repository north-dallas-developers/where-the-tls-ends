# New project

```
cd ndd.202401
dotnet new webapi
```

THe ONLY edit to the new project was the `Kestrel` node in the [appsettings.json](ndd.202401/appsettings.json) file.

# dotnet dev-certs

https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-dev-certs

Check, create, but don't trust the certificate yet: `dotnet dev-certs https`
Remove certificate: `dotnet dev-certs https --clean`
Check certificate: `dotnet dev-certs https --check`
Check and trust dev certificate: `dotnet dev-certs https --check --trust`

# Configuring HTTPS in Kestrel

https://learn.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel/endpoints?view=aspnetcore-8.0

# Installing Certbot

https://certbot.eff.org/instructions?ws=other&os=centosrhel7

# AWS Resources

* key pair for the instance
* security group allowing ingress for 22, 80, and 443 (0.0.0.0/0)
* EC2 instance, instance type: Amazon Linux 2, no IAM role

For the sample site, EC2 should have ports 22, 80, and 443 open. Port 80 is for the certificate coordination and can be removed afterwards.

Port 22 for code delivery and configuration.
Port 80 for certificate configuration. This can be closed afterwards.
Port 443 for HTTPS/TLS.

```
sudo dnf install -y augeas-libs
sudo python3 -m venv /opt/certbot/
sudo /opt/certbot/bin/pip install --upgrade pip
sudo /opt/certbot/bin/pip install certbot certbot-apache
sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot
```

# Creating certificate

```
sudo /usr/bin/certbot certonly --standalone
```

This will spin up a standalone webserver that will manage creating the certificate. There are multiple ways to have this work for you.

```
sudo /usr/bin/certbot certonly --standalone

Saving debug log to /var/log/letsencrypt/letsencrypt.log
Please enter the domain name(s) you would like on your certificate (comma and/or
space separated) (Enter 'c' to cancel): api.pentonizer.com
Requesting a certificate for api.pentonizer.com

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/api.pentonizer.com/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/api.pentonizer.com/privkey.pem
This certificate expires on 2024-04-02.
These files will be updated when the certificate renews.

NEXT STEPS:
- The certificate will need to be renewed before it expires. Certbot can automatically renew the certificate in the background, but you may need to take steps to enable that functionality. See https://certbot.org/renewal-setup for instructions.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```
