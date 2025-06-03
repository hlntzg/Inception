Inception - diving into Docker-based infrastructure and system administration
Objective:
	- build a containerized infrastructure on a virtual machine using only Docker Compose and Dockerfiles.

Required Containers:
	- nginx: Reverse proxy with TLS 1.2/1.3 (entrypoint via port 443)
	- wordpress: WordPress + PHP-FPM (no NGINX)
	- mariadb: MariaDB DB backend (no NGINX)

Required Volumes:
	- One volume for WordPress database data (MariaDB)
	- One volume for WordPress website files

Infrastructure Rules:
	- Built on Alpine or Debian (penultimate stable version)
	- Environment variables (stored in a .env file inside srcs/)
	- Makefile to build and start everything via docker-compose
	- Domain name is login.42.fr (login is replace login with your own)


inception/
├── Makefile
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        ├── wordpress/
        │   ├── Dockerfile
        └── nginx/
            ├── Dockerfile

Makefile: 
```all:
	docker-compose -f srcs/docker-compose.yml --env-file srcs/.env up --build -d

down:
	docker-compose -f srcs/docker-compose.yml down

fclean: down
	docker system prune -af --volumes

re: fclean all```

