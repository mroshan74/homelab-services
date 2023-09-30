# Nginx Proxy Manager
_This project comes as a pre-built docker image that enables you to easily forward to your websites running at home or otherwise, including free SSL, without having to know too much about Nginx or Letsencrypt._

## Guides
- [Docs](https://nginxproxymanager.com/)
- [Youtube](https://www.youtube.com/watch?v=qlcVx-k-02E&t=2s)

## Setup
##### Notes:
1. Move the `DNS` to `cloudflare` for easy setup.
2. Will take almost `24hrs` to propogate the changes. -> check [dnschecker](https://dnschecker.org/)
3. Create an API token with following permissions and save it to a secure location.\
	a. **Account** -> **Account: SSL and Certificates** -> **Read**\
	b. **Zone** -> **Zone** -> **Read**\
	c. **Zone** -> **DNS** -> **Edit**
4. Add a `CNAME` and `A` record with `proxy OFF`, can be any, this helps Let's Encrypt to query and safe validate the existance of the domain.

#####  In Nginx Proxy Manager:
1. Add ssl certificate
2. Use DNS challange with the cloudflare selected and pasting the access token saved earlier.
3. Let it cook.
4. After the ssl certificate is issued, start creating proxy hosts for the services.
5. Add in the domain, local ip to be ssled, add in the ssl certifite, etc
6. You are done