# GIT Component

Git component store private git (runtime git) and private env

## Install

```
git clone https://github.com/massbitprotocol/massbitroute_git /massbit/massbitroute/app/src/sites/services/git -b BRANCH
/massbit/massbitroute/app/src/sites/services/git/scripts/run _install
```

## Create repo

```
/massbit/massbitroute/app/src/sites/services/git/scripts/run _repo_init
```

* New repo save in `data/repo`

* New access info repo save in `vars`


## Create Administrator Repo

Administrator repo with commit permission create in `data/deploy`

### SSL Repo

SSL Repo store ssl certificate for all other components https config

* Request ssl by dns request

```
./scripts/cert.sh _get DOMAIN
```

Cert will create in /etc/letsencrypt.

Next step is copy certificate from /etc/letsencrypt to `data/deploy/ssl` , commit and push it

#### Env Repo

Env Repo store all authenticate git private for others commponents need to save and get info


- Git autenticate: `git.env` 
```
export GIT_APIDEPLOY_WRITE='apideploy:'
export GIT_ENV_WRITE='env:'
export GIT_GATEWAYDEPLOY_WRITE='gatewaydeploy:'
export GIT_GWMANDEPLOY_WRITE='gwmandeploy:'
export GIT_MONITORDEPLOY_WRITE='monitordeploy:'
export GIT_NODEDEPLOY_WRITE='nodedeploy:'
export GIT_PRIVATE_DOMAIN='git.DOMAIN'
export GIT_PRIVATE_IP=''
export GIT_PRIVATE_READ='massbit:'
export GIT_PRIVATE_READ_URL='http://massbit:'
export GIT_SSL_WRITE='ssl:'
export GIT_STATDEPLOY_WRITE='statdeploy:'
```

- Static DNS record: `domain`

```
@ A IP
* A IP

hostmaster A IP
ns1 A IP
ns2 A IP

api A IP
git A IP

chain A IP

stat.mbr A IP
session.mbr A IP
monitor.mbr A IP
```

- Base env: `base.env`

```
export DOMAIN="massbitroute.net"
export PORTAL_DOMAIN="portal.$DOMAIN"
export STAT_DOMAIN="stat.mbr.$DOMAIN"
export MONITOR_DOMAIN="monitor.mbr.$DOMAIN"
export GIT_PUBLIC_URL="https://github.com"
```

- Api env: `api.env`

```
export IPAPI_TOKEN=""
export SENDGRID_KEY=""
export SID=""
export PARTNER_ID=""
export WHITELIST_PARTNERS="allow 104.154.155.108"
```

- Monitor env: `monitor.env`

```
export CHECK_MK_AUTOMATION_SECRET=xxxx
```

- Session env: `session.env`

```
export SESSION_KEY="xxx"
export SESSION_IV="yyy"
export SESSION_EXPIRES="30d"
```

