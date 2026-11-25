# Developer Documentation

This guide explains how to set up the Inception stack from scratch, build and launch it, manage the containers and volumes, and understand where the data lives.

**Contents:** [Set up](#set-up-the-environment-from-scratch) · [Build and launch](#build-and-launch) · [Manage containers and volumes](#manage-containers-and-volumes) · [Data and persistence](#data-storage-and-persistence)

---

## Set up the environment from scratch

### Prerequisites

- A Linux virtual machine (the project is built and tested on Debian).
- `make`, `git`, Docker Engine and Docker Compose installed.
- A user allowed to run Docker (member of the `docker` group, or `sudo`):

  ```bash
  sudo usermod -aG docker <user>
  ```

  Log out and back in afterwards.

### Project layout

```text
.
├── Makefile                  # builds and drives the whole stack
├── secrets/                  # confidential files (ignored by Git)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── credentials.txt
│   ├── wp_user_password.txt
│   └── wp_admin_password.txt
└── srcs/
    ├── docker-compose.yml    # services, network, volumes, secrets
    ├── .env                  # non-confidential variables (ignored by Git)
    └── requirements/
        ├── nginx/            # Dockerfile, configuration, scripts
        ├── wordpress/        # Dockerfile, configuration, scripts
        └── mariadb/          # Dockerfile, configuration, scripts
```

### Configuration files

**1. Secrets** — create the five files in `secrets/`, one secret per file:

| File | Content |
| --- | --- |
| `db_password.txt` | Password of the database user |
| `db_root_password.txt` | Password of the database root user |
| `credentials.txt` | WordPress and MariaDB account credentials |
| `wp_user_password.txt` | Password of the WordPress user |
| `wp_admin_password.txt` | Password of the WordPress administrator |

Compose declares them as Docker secrets. Each one is mounted as a file in `/run/secrets/` inside the containers that need it, and the init scripts read them at startup. No password appears in a Dockerfile or in the Git repository.

**2. Environment file** — create `srcs/.env` with the non-confidential values:

```bash
DOMAIN_NAME=srosu.42.fr
# database settings (name, user, ...)
# WordPress settings (site title, usernames, ...)
```

**3. Domain name** — add this line to `/etc/hosts` so the domain points to the VM:

```text
127.0.0.1   srosu.42.fr
```

> [!IMPORTANT]
> `secrets/` and `srcs/.env` must stay in `.gitignore`. A credential committed to the repository is a failure of the project.

---

## Build and launch

The Makefile wraps Docker Compose (`docker-compose -f ./srcs/docker-compose.yml ...`).

| Rule | What it does |
| --- | --- |
| `make` / `make all` | `dirs` + `build` + `up`: creates the data folders, builds the images, starts the containers |
| `make build` | Builds the images from the Dockerfiles |
| `make up` | Starts the containers in the background |
| `make down` | Removes the containers and the network, keeps the data |
| `make start` / `make stop` | Restarts / stops the existing containers |
| `make logs` | Displays the logs |
| `make status` | Displays the running containers (`docker ps`) |
| `make rmi` | Deletes the images |
| `make prune` | Deletes the data, the volumes and all unused Docker objects |
| `make re` | `prune` + `all`: full rebuild from scratch |

**What happens on `make all`:**

1. `dirs` creates `../data/mariadb` and `../data/wordpress` on the host.
2. `build` builds one image per service, from Debian 12 (bookworm), with the Dockerfiles in `srcs/requirements/`.
3. `up` creates the network and the volumes, then starts MariaDB, WordPress and nginx.
4. On the first start only, MariaDB initializes the database and WordPress installs the site and creates its two users.

---

## Manage containers and volumes

All commands can be run from the project root. For readability, define a shortcut:

```bash
alias dc='docker-compose -f ./srcs/docker-compose.yml'
```

### Containers

| Goal | Command |
| --- | --- |
| List running containers | `docker ps` |
| List all containers (including stopped) | `docker ps -a` |
| Open a shell in a container | `docker exec -it <container> sh` |
| Follow the logs of one service | `docker logs -f <container>` |
| Rebuild and restart one service | `dc up -d --build <service>` |
| Restart one service | `dc restart <service>` |
| Check the restart policy | `docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' <container>` |

`<container>` and `<service>` are `nginx`, `wordpress` or `mariadb`.

### Volumes and network

| Goal | Command |
| --- | --- |
| List volumes | `docker volume ls` |
| Show where a volume is stored | `docker volume inspect mariadb` |
| Inspect the network | `docker network ls` then `docker network inspect <network>` |
| Check which secrets a container sees | `docker exec <container> ls /run/secrets` |

### Useful checks

```bash
# Connect to the database from inside the container
docker exec -it mariadb mariadb -u root -p

# Check that only TLS 1.2 / 1.3 are accepted by nginx
openssl s_client -connect srosu.42.fr:443 -tls1_1   # must fail
openssl s_client -connect srosu.42.fr:443 -tls1_3   # must succeed
```

---

## Data storage and persistence

The two persistent storages are Docker **named volumes**:

| Volume | Used by | Content | Host location |
| --- | --- | --- | --- |
| `mariadb` | mariadb | WordPress database | `/home/user/data/mariadb` |
| `wordpress` | wordpress, nginx | WordPress website files | `/home/user/data/wordpress` |

They are declared in `docker-compose.yml` as named volumes whose data is stored in `/home/user/data` on the host (the `../data` folder created by `make dirs`, when the repository sits in the home directory). They remain Docker named volumes, not bind mounts in the services. `docker volume inspect <volume>` shows the exact path.

**How the data persists:**

| Operation | Data |
| --- | --- |
| `make stop` / `make start` | Kept |
| `make down` / `make up` | Kept |
| Container crash and automatic restart | Kept |
| `make prune` / `make re` | **Deleted** |

Because the data survives `make down`, the init scripts only configure the database and WordPress on the first start, when the volumes are empty. To apply a change that happens at initialization (a password, a username), run `make re`.

Files written by the containers belong to their internal users (such as `mysql` or `www-data`), so deleting them from the host requires `sudo`. This is why `make prune` uses it.