# COLORS
RESET  := \033[0m
GREEN  := \033[1;32m
BLUE   := \033[1;34m
YELLOW := \033[1;33m
RED    := \033[1;31m

# CONFIG
DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
DATA_DIR := $(HOME)/data
DB_DIR := $(DATA_DIR)/mariadb
WP_DIR := $(DATA_DIR)/wordpress

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
	command -v docker >/dev/null 2>&1 || { echo "$(RED)Error: Docker is not installed.$(RESET)"; exit 1; }
	command -v docker-compose >/dev/null 2>&1 || command -v docker >/dev/null 2>&1 || { echo "$(RED)Error: Docker Compose is not installed.$(RESET)"; exit 1; }

up: check build_dirs
	echo -e "$(YELLOW)Building and starting containers...$(RESET)"
	$(DOCKER_COMPOSE) up --build -d
	echo -e "$(GREEN)All services are up and running.$(RESET)"

build_dirs:
	echo -e "$(BLUE)Creating data volumes...$(RESET)"
	mkdir -p $(DB_DIR) $(WP_DIR)

down:
	echo -e "$(RED)Stopping containers...$(RESET)"
	$(DOCKER_COMPOSE) down

ps:
	echo -e "$(BLUE)Listing container status...$(RESET)"
	$(DOCKER_COMPOSE) ps

logs:
	echo -e "$(BLUE)Streaming container logs...$(RESET)" 
	echo -e "$(BLUE)Press Ctrl+C to exit$(RESET)"
	-$(DOCKER_COMPOSE) logs -f

clean: down
	echo -e "$(RED)Removing data directories in $(DATA_DIR)...$(RESET)"
	if [ -d $(DATA_DIR) ]; then \
		sudo rm -rf $(DATA_DIR); \
		echo -e "$(GREEN)Removed $(DATA_DIR)$(RESET)"; \
	else \
		echo -e "$(RED)$(DATA_DIR) does not exist. Skipping removal.$(RESER)"; \
	fi

fclean: clean
	echo -e "$(RED)Removing all Docker data and local volumes...$(RESET)"
	$(DOCKER_COMPOSE) down -v --rmi all
	echo -e "$(GREEN)All docker images, volumes, and networks have been removed.$(RESET)"

re: fclean all

help:
	echo "Available targets:"
	echo "  all, up      Build and start containers"
	echo "  down         Stop containers"
	echo "  ps           Show container status"
	echo "  logs         Show container logs"
	echo "  clean        Stop containers and remove data directories"
	echo "  fclean       Remove all Docker data and volumes"
	echo "  re           Rebuild everything"
	echo "  help         Show this help message"

.PHONY: all up down build_dirs clean fclean re help 
