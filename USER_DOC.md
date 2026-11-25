# User Documentation

This guide explains how to use the Inception stack: what it provides, how to start and stop it, how to reach the website, where the credentials are, and how to check that everything works.

**Contents:** [Services](#services) · [Start and stop](#start-and-stop) · [Access](#access-the-website-and-the-admin-panel) · [Credentials](#credentials) · [Checks](#check-that-everything-works)

---

## Services

The stack runs three services, each in its own container:

| Service | What it does |
| --- | --- |
| **nginx** | The only entrypoint from the internet (HTTPS, port 443). It forwards dynamic requests to WordPress and serves static files (images, CSS) directly. |
| **wordpress** | The WordPress website, run by php-fpm. It builds the pages and talks to the database. |
| **mariadb** | The database. It stores the content and users of the website. Only WordPress can reach it. |

Data is kept in two volumes, so it survives a restart:

- the **WordPress files**, shared by nginx and WordPress;
- the **database**, used only by MariaDB.

---

## Start and stop

All commands are run from the root of the project folder.

| Action | Command | Effect |
| --- | --- | --- |
| Start (first time) | `make all` | Builds the images, creates the network and volumes, starts everything |
| Pause | `make stop` | Stops the containers, keeps them in place |
| Resume | `make start` | Restarts the stopped containers |
| Shut down | `make down` | Removes the containers and the network. **Data is kept** in the volumes |

> [!WARNING]
> `make re` deletes all data (website and database) and rebuilds everything from scratch.

---

## Access the website and the admin panel

1. Make sure your machine knows the domain name. This line must be in `/etc/hosts`:

   ```text
   127.0.0.1   srosu.42.fr
   ```

2. Open these addresses in a browser:

   | Page | Address |
   | --- | --- |
   | Website | `https://srosu.42.fr` |
   | Login / admin panel | `https://srosu.42.fr/wp-admin` |

The certificate is self-signed, so the browser shows a security warning the first time. Accept it to continue.

After logging in, the available tools depend on the role of the account (administrator or regular user).

---

## Credentials

Credentials are stored in the `secrets/` folder at the root of the project:

| File | Content |
| --- | --- |
| `db_password.txt` | Password of the database user |
| `db_root_password.txt` | Password of the database root user |
| `credentials.txt` | WordPress and mariadb account credentials|
| `wp_user_password.txt` | Password of the wordpress user |
| `wp_admin_password.txt` | Password of the wordpress admin |

Docker mounts each secret as a file inside the container that needs it, in `/run/secrets/`.

Non-confidential settings (domain name, database name and user, etc.) are in `srcs/.env`.

**To change a credential:**

1. Edit the file in `secrets/` (or the value in `srcs/.env`).
2. Run `make re`.

> [!NOTE]
> The database and the WordPress site are configured only on the first start. A change in `secrets/` has no effect on existing data, which is why `make re` is needed. It erases the data.

These files are ignored by Git and must never be committed.

---

## Check that everything works

**1. The containers are running**

```bash
make status
```

`nginx`, `wordpress` and `mariadb` must all be listed with the status `Up`. Only nginx should publish a port (`443`).

**2. The website answers**

```bash
curl -k -I https://srosu.42.fr
```

A response starting with `HTTP/1.1 200` (or a redirection) means nginx and WordPress are working. The `-k` option accepts the self-signed certificate. You can also simply open the website in a browser.

**3. Something looks wrong**

```bash
make logs
```

This displays the logs of the services. The nginx error log is inside its container:

```bash
docker exec nginx cat /var/log/nginx/error.log
```