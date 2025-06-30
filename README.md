# Inception
Diving into Docker-based infrastructure and system administration

## Overview
Inception is a DevOps project that focuses on system administration using containerization technologies. The goal is to build a secure, modular, and reproducible infrastructure using Docker, orchestrated with Docker Compose. This project introduces best practices in service isolation, data persistence, and environment management.

> [!TIP]
> Learn more about the basic concepts in a easy way from my personal notes: [Conceptual Overview](https://github.com/hlntzg/Inception/wiki)
 
The infrastructure includes:
- `NGINX` as a reverse proxy, handling HTTPS (TLS 1.2/1.3).
- `WordPress` running with PHP-FPM, serving dynamic content (no NGINX).
- `MariaDB` as the database backend (no NGINX).

All services are built on top of the second-to-latest stable version (at the time of writing) of lightweight Linux distributions such as Alpine or Debian. They are configured to communicate through isolated Docker networks and persistent volumes — one for the WordPress database (MariaDB) and one for the WordPress website files.

## Features
- Docker-based deployment using a single Makefile (build and start everything via docker-compose);
- Conditional logic to detect whether docker-compose or docker compose is available, making it compatible with various Docker setups;
- TLS-secured NGINX reverse proxy;
- Dynamic PHP website via WordPress;
- Persistent MariaDB storage and WordPress files;
- Declarative configuration with `.env` file.

## Usage
> [!IMPORTANT]
> While Docker Desktop allows running this project on **macOS** or **Windows**, it was developed and tested specifically for native **Linux** environments.
> Due to differences in filesystem structure, volume mounting, and permissions, running it outside Linux (even with Docker Desktop) may lead to unexpected behavior.
> For full compatibility and stability, use a ```Linux virtual machine (VM)``` if you're working on macOS or Windows.
> Follow this [VM Setup Guide](https://github.com/hlntzg/Inception/wiki/VM-Setup-Guide) to prepare your environment properly, before you start.

### 1. Start the Project
From the root directory, run: `make`. This command will:
- Check for Docker and Docker Compose
- Create persistent data directories
- Build and start all containers in the background

> [!TIP]
> Check the commands and walkthrough to explore containers, volumes, and networking: [Step-by-Step Usage Guide](https://github.com/hlntzg/Inception/wiki/Inception)

### 2. Access the Services
Open the browser and go to: `https://hutzig.42.fr`.

### 3. Monitor and Control
- Check container status: `make ps`.
- View real-time logs: `make logs`.
- Stop all containers: `make stop`.
- Rebuild everything from scratch: `make re`.

### 4. Clean Up
- Remove data volumes: `make clean`.
- Remove containers, volumes, images, and networks: `make fclean`.

## Architecture
The containerized infrastructure consists of three mandatory services, each running in its own isolated container and connected via a custom Docker network. The only public-facing service is NGINX, which handles secure HTTPS traffic on port 443. All other communication between containers happens internally. 
```
                       +--------------------+
                       |      Internet      |
                       +---------+----------+
                                 |
                            HTTPS :443
                                 |
                       +---------v----------+
                       |       NGINX        |
                       |  (Reverse Proxy)   |
                       +---------+----------+
                                 |
                             Port 9000
                                 |
                       +---------v----------+
                       |    WordPress +     |
                       |     PHP-FPM        |
                       +---------+----------+
                                 |
                         MySQL / Port 3306
                                 |
                       +---------v----------+
                       |      MariaDB       |
                       +--------------------+

Volumes:
--------
[MariaDB Volume]  -->  /home/<login>/data/mariadb
[WordPress Volume] --> /home/<login>/data/wordpress

```
Each container connects through defined ports:
- ```NGINX``` is the only public-facing container and listens on port 443 for HTTPS traffic from the internet.
- ```NGINX``` → ```WordPress``` communicates internally on port 9000.
- ```WordPress``` → ```MariaDB``` communicates internally on port 3306 (MySQL protocol).

All data is persisted via Docker volumes to ensure content and database durability across container restarts.
The data persistence is handled with host-mounted Docker volumes. All data stored under `~/data`:
- `~/data/mariadb` for MariaDB
- `~/data/wordpress` for WordPress content and uploads

## Project Structure
Each service is isolated into its own directory, with configuration and setup scripts neatly separated. This structure supports a modular and maintainable infrastructure, aligning with Docker best practices.
```bash
Inception/
├── Makefile
└── srcs/
    ├── docker-compose.yml                   # Main orchestration file
    ├── .env                                 # Environment variables used by services
    └── requirements/                        # All required services live here
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/                        # MariaDB config files (e.g. my.cnf)
        │   │   └── mariadb.cnf
        │   └── tools/                       # Entrypoint scripts
        │       └── mariadb-entrypoint.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/                        # WordPress configuration
        │   │   └── www.conf
        │   └── tools/                       # Entrypoint scripts
        │       └── wordpress-entrypoint.sh
        └── nginx/
            ├── Dockerfile
            ├── .dockerignore
            ├── conf/                       # NGINX virtual host + TLS config
            │   └── nginx.conf
            └── tools/                      # Entrypoint scripts, etc.
                └── nginx-entrypoint.sh
```
Why this directory structure matters?
- Service Isolation: Each container’s build context is separated, following Docker's single responsibility principle.
- Modularity: Easy to work on NGINX, WordPress, or MariaDB independently, simplifying debugging and refactoring.
- Configuration Hygiene: Grouping conf/ and tools/ ensures that configuration files and entrypoint logic stay out of the Dockerfile itself.

## License

This project is licensed under a custom Educational Use License. It is intended 
for personal and academic use within Hive Helsinki and the 42 Network. See [LICENSE](./LICENSE) for full terms.
