# COLORS
RESET  := \033[0m
GREEN  := \033[1;32m
BLUE   := \033[1;34m
YELLOW := \033[1;33m
RED    := \033[1;31m

# CONFIG
DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
#DOCKER_COMPOSE := docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file ./srcs/.env
DATA_DIR := $(HOME)/data
MARIADB_DIR := $(DATA_DIR)/mariadb
WORDPRESS_DIR := $(DATA_DIR)/wordpress

# Detect docker compose command
ifeq (, $(shell which docker-compose))
    DOCKER_COMPOSE := docker compose -f $(DOCKER_COMPOSE_FILE) --env-file ./srcs/.env
else
    DOCKER_COMPOSE := docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file ./srcs/.env
endif

.SILENT:

all: up

# Check for docker-compose installation
check:
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)Error: Docker is not installed.$(RESET)"; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || command -v docker >/dev/null 2>&1 || { echo "$(RED)Error: Docker Compose is not installed.$(RESET)"; exit 1; }

up: check build_dirs
	echo "$(YELLOW)Building and starting containers...$(RESET)"
	$(DOCKER_COMPOSE) up --build -d
	echo "$(GREEN)All services are up and running.$(RESET)"

build_dirs:
	echo "$(BLUE)Creating data volumes...$(RESET)"
	mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR)

down:
	echo "$(RED)Stopping containers...$(RESET)"
	$(DOCKER_COMPOSE) down

ps:
	echo "$(BLUE)Listing container status...$(RESET)"
	$(DOCKER_COMPOSE) ps

logs:
	echo "$(BLUE)Streaming container logs...$(RESET)" 
	echo "$(BLUE)Press Ctrl+C to exit$(RESET)"
	$(DOCKER_COMPOSE) logs -f

clean: down
	echo "Removing data directories in $(DATA_DIR)..."
	if [ -d $(DATA_DIR) ]; then \
		rm -rf $(DATA_DIR); \
		echo "Removed $(DATA_DIR)"; \
	else \
		echo "$(DATA_DIR) does not exist. Skipping removal."; \
	fi

fclean: clean
	echo "$(RED)Removing all Docker data and local volumes...$(RESET)"
	docker-compose down -v --rmi all
	echo "$(GREEN)All docker images, volumes, and networks have been removed.$(RESET)"

re: fclean all

help:
	echo "Available targets:"
	echo "  all, up      Build and start containers"
	echo "  down         Stop containers"
	echo "  ps           Show container status"
	echo "  logs         Show container logs"
	echo "  clean        Remove data directories"
	echo "  fclean       Remove all Docker data and volumes"
	echo "  re           Rebuild everything"
	echo "  help         Show this help message"

.PHONY: all up down build_dirs clean fclean re help 
