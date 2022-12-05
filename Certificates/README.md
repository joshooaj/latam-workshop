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

## Dynu DNS

URL: [Dynu DNS](https://www.dynu.com)
API Key: 55a344T66W6b2463c6c2db3ee345V46g
