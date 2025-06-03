# COLORS
RESET  := \033[0m
GREEN  := \033[1;32m
BLUE   := \033[1;34m
YELLOW := \033[1;33m
RED    := \033[1;31m

# CONFIG
COMPOSE := docker-compose -f srcs/docker-compose.yml --env-file srcs/.env
DATA_DIR := $(HOME)/data
MARIADB_DIR := $(DATA_DIR)/mariadb
WORDPRESS_DIR := $(DATA_DIR)/wordpress

# TARGETS

all: prepare_dirs
	@echo "$(YELLOW)Building and starting containers...$(RESET)"
	@$(COMPOSE) up --build -d
	@echo "$(GREEN)✅ All services are up and running.$(RESET)"

prepare_dirs:
	@echo "$(BLUE)Creating data volumes...$(RESET)"
	@mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR)

down:
	@echo "$(RED)Stopping containers...$(RESET)"
	@$(COMPOSE) down -v

fclean: down
	@echo "$(RED)Removing all Docker data and local volumes...$(RESET)"
	@rm -rf $(DATA_DIR)
	@docker system prune -af --volumes

re: fclean all

.PHONY: all down fclean re prepare_dirs
