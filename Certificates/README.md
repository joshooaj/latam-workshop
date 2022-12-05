# Certificates

## Terminology

This is by no means a complete, or even a thorough list of the abbreviations and
terms associated with certificates and public key infrastructure.

| Abbreviation | Meaning                     |
| ------------ | --------------------------- |
| CA           | Certificate Authority       |
| CN           | Common Name                 |
| CRL          | Certificate Revocation List |
| DN           | Distinguished Name          |
| PKI          | Public Key Infrastructure   |
| Root CA      | Root Certificate Authority  |
| SAN          | Subject Alternative Name    |
| SSL          | Secure Sockets Layer        |
| TLS          | Transport Layer Security    |

## Ideas for questions

- If I have an all-in-one Milestone installation, do I need one certificate for
  each component? Management Server, Mobile Server, Recording Server, Event Server?
- In a distributed installation, do I need one certificate per server?
- Can I use a certificate signed by a public CA? What if the host and/or domain
  parts of the DNS name do not match the server hostname or domain name?
- Won't a public DNS name always resolve to a public IP address? How can I reach
  the server using that DNS name both inside the LAN and over the WAN?
- Do I have to use a certificate signed by a certificate authority, or can I use
  a self-signed certificate?

## Server Configurator

We can't talk about certificates in the context of Milestone software without
discussing the Server Configurator. All of the logic associated with registering
servers and enabling/disabling encryption is centralized here.

## Steps to setup encryption using custom DNS name

These are all the steps I had to follow to get encryption working using a custom
DNS name that did not match the server. The server is Windows Server 2022 with
no domain, and the hostname is a randomly assigned AWS EC2 instance hostname.
Milestone is installed here as an all-in-one system, and I am using a
certificate for "joshooaj.casacam.net".

1. Generate a self-signed certificate for DNS names "joshooaj.casacam.net" and "EC2AMAZ-9K7R2J1"
   `New-SelfSignedCertificate -DnsName joshooaj.casacam.net, (hostname)`
2. Launch `certlm.msc` and locate the new certificate in "Personal/Certificates"
3. Grant the Milestone service account permission to read the certificate private key.
   - Right-click and choose `All Tasks > Manage Private Keys...`
   - Add "Network Service" (or whatever your Milestone service account is) and grant the account "Read", and click OK.
4. Export the certificate _without_ the private key. The resulting certificate will contain only the public key and will be safe to copy to other computers if needed.
5. Import the exported certificate to Local Machine / Trusted Root Certificate Authorities so that the self-signed certificate will be trusted.
6. Edit `C:\Windows\System32\Drivers\etc\hosts` and add a record for the DNS name. In this case I added a line like "127.0.0.1 joshooaj.casacam.net".
   - __IMPORTANT:__ The IP address for the hosts file entry should be "127.0.0.1". I struggled for an hour because I used the LAN IP instead of the loopback address, and even though I could access "\\joshooaj.casacam.net\c$" in Windows File Explorer,
   I could _not_ use integrated Windows authentication with the custom DNS name. I could only authenticate as "Windows (current user)" if I changed the server address to the real hostname. Once I changed my hosts file entry to use the loopback IP instead of the LAN IP, it worked perfectly.
7. Create a registry value named "BackConnectionHostNames" in the HKEY_LOCAL_MACHINE hive under the key "SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0". The value should be of type "REG_MULTI_SZ", also called "MultiString" when creating the value from PowerShell.
   - PowerShell: `New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0\ -Name BackConnectionHostNames -Value joshooaj.casacam.net -PropertyType MultiString`
   - If the BackConnectionHostNames value already exists, make sure your desired DNS name is included in it's own line within the registry value.
8. Restart the computer so that the `BackConnectionHostNames` value will be recognized by Windows.

At this point, you should be able to open Windows File Explorer and access `\\joshooaj.casacam.net\c$`, and even though we haven't changed any Milestone settings, you
should be able to open Management Client and login as Windows Current User using
the custom DNS name instead of the hostname. If the login fails, but it works if
you manually enter the Windows username and password, then either you missed a
step or I forgot to include a step. Either way, something is wrong and that'll need
to be sorted out before you do anything else.

Assuming you can login using "Windows (current user)" with the custom DNS name,
it's now time to enable encryption.

1. Open Management Client, right click on the site at the top of the navigation pane,
   and select "Properties"
2. Add two new alternate addresses for your custom DNS name, one using "http://"
   and the other "https://". If you forget this step, you'll either have to
   manually add these using a SQL query, or roll back your changes in server configurator.
3. Open Server Configurator and enable "Server encryption", choosing the new
   self-signed certificate from the list, and click "Apply".
4. Verify that you can login with Management Client as current user, using the new DNS name.
5. Now, again in Server Configurator, open the registration tab and change the URL
   for registration to https://joshooaj.casacam.net.

You should now have server encryption enabled using the custom DNS name with a
self-signed certificate. There may be a couple additional clean-up tasks to make
sure all the registered services are correct, but


## Dynu DNS

URL: [Dynu DNS](https://www.dynu.com)
API Key: 55a344T66W6b2463c6c2db3ee345V46g
