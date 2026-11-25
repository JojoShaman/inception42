RED = \033[1;31m
GREEN = \033[1;32m
YELLOW = \033[1;33m
BLUE = \033[1;34m
RESET = \033[0m

all: dirs banner build up

build: dirs
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━ [ BUILDING IMAGES ] ━━━━━━━━━━━━━━━━━━$(RESET)"
	docker-compose -f ./srcs/docker-compose.yml build

up: dirs
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━ [ STARTING SERVICES ] ━━━━━━━━━━━━━━━━━$(RESET)"
	@docker-compose -f ./srcs/docker-compose.yml up -d
	@echo ""
	@echo "$(RED)╭────────────────────────── NOTE ──────────────────────────╮$(RESET)"
	@echo "$(RED)│  $(BLUE)To check your containers logs, use: $(YELLOW)make logs$(RED)             │$(RESET)"
	@echo "$(RED)╰─────────────────────────────────────────────────────────╯$(RESET)"

down:
	@echo "$(RED)━━━━━━━━━━━━━━━━━━ [ STOPPING SERVICES ] ━━━━━━━━━━━━━━━━━$(RESET)"
	docker-compose -f ./srcs/docker-compose.yml down

start:
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━ [ STARTING CONTAINERS ] ━━━━━━━━━━━━━━━━$(RESET)"
	docker-compose -f ./srcs/docker-compose.yml start

stop:
	@echo "$(RED)━━━━━━━━━━━━━━━━━━ [ STOPPING CONTAINERS ] ━━━━━━━━━━━━━━━━$(RESET)"
	docker-compose -f ./srcs/docker-compose.yml stop

logs:
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━ [ CONTAINER LOGS ] ━━━━━━━━━━━━━━━━━━━━$(RESET)"
	docker-compose -f ./srcs/docker-compose.yml logs

status:
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━ [ RUNNING CONTAINERS ] ━━━━━━━━━━━━━━━━━$(RESET)"
	docker ps

prune: down
	@echo "$(RED)━━━━━━━━━━━━━━━━━━ [ CLEANING EVERYTHING ] ━━━━━━━━━━━━━━━$(RESET)"
	@sudo rm -rf ../data/mariadb/* ../data/wordpress/*
	@docker volumes rm mariadb wordpress
	@docker system prune -fa --volumes

rmi:
	@echo "$(RED)━━━━━━━━━━━━━━━━━━ [ REMOVING DOCKER IMAGES ] ━━━━━━━━━━━━━$(RESET)"
	@docker rmi wordpress mariadb nginx

dirs:
	@echo "$(RED)━━━━━━━━━━━━━━━━━━ [ MAKING LOCAL STOARAGE FOLDERS ] ━━━━━━━━━━━━━$(RESET)"	
	@mkdir -p ../data/mariadb ../data/wordpress

re: prune all

banner:
	@echo ""
	@echo "$(BLUE)██╗███╗   ██╗ ██████╗███████╗██████╗ ████████╗██╗ ██████╗ ███╗   ██╗$(RESET)"
	@echo "$(BLUE)██║████╗  ██║██╔════╝██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║$(RESET)"
	@echo "$(BLUE)██║██╔██╗ ██║██║     █████╗  ██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║$(RESET)"
	@echo "$(BLUE)██║██║╚██╗██║██║     ██╔══╝  ██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║$(RESET)"
	@echo "$(BLUE)██║██║c╚████║╚██████╗███████╗██║        ██║   ██║╚██████╔╝██║ ╚████║$(RESET)"
	@echo "$(BLUE)╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝$(RESET)"
	@echo "$(YELLOW)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "                    Made with Docker by: $(RED)srosu$(RESET)"
	@echo "$(YELLOW)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo ""

.PHONY: all build up down start stop logs status prune rmi re banner dirs
