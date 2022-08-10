# Git Component

## Prepare Docker compose file

```
services:
  git:
    privileged: true
    restart: unless-stopped
    image: massbit/massbitroute_git:_BRANCH_
    hostname: "git"
    domainname: "massbitroute.net"
    build:
      context: /massbit/massbitroute/app/src
      dockerfile: install/mbr/build/git/Dockerfile
      args:
        MYAPP_IMAGE: massbit/massbitroute_base:_BRANCH_               
        BRANCH: _BRANCH_
    container_name: mbr_git    
    volumes:
      - ./run/git/data:/massbit/massbitroute/app/src/sites/services/git/data:rw
      - ./run/git/logs:/massbit/massbitroute/app/src/sites/services/git/logs:rw
      - ./run/git/vars:/massbit/massbitroute/app/src/sites/services/git/vars:rw
      - ./run/git/db:/massbit/massbitroute/app/src/sites/services/git/db:rw
      - ./run/git/tmp:/massbit/massbitroute/app/src/sites/services/git/tmp:rw
    environment:
      - DOMAIN=massbitroute.net
      - MBR_ENV=_BRANCH_
    extra_hosts:
      - "git.massbitroute.net:172.20.0.2"
      - "api.massbitroute.net:172.20.0.3"
```

## Init credential info
```
docker exec -it mbr_git /massbit/massbitroute/app/src/sites/services/git/scripts/run _repo_init
docker exec -it mbr_git cat /massbit/massbitroute/app/src/sites/services/git/env/git.env
```
