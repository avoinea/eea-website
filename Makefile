FRONTEND_DIR := frontend
BACKEND_DIR := backend

.PHONY: init
init:
	@if [ ! -d "$(FRONTEND_DIR)" ]; then \
		git clone https://github.com/eea/eea-website-frontend "$(FRONTEND_DIR)"; \
	fi
	@if [ ! -d "$(BACKEND_DIR)" ]; then \
		git clone https://github.com/eea/eea-website-backend "$(BACKEND_DIR)"; \
	fi
	@if [ ! -d ".venv" ]; then \
		python3 -m venv .venv; \
	fi
	@.venv/bin/python -m pip install --upgrade pip
	@.venv/bin/python -m pip install pyyaml

.PHONY: frontend-start
frontend-start:
	@$(MAKE) -C "$(FRONTEND_DIR)" start

.PHONY: backend-start
backend-start:
	@$(MAKE) -C "$(BACKEND_DIR)/develop" start

.PHONY: frontend-relstorage
frontend-relstorage:
	@$(MAKE) -C "$(FRONTEND_DIR)" relstorage

.PHONY: backend-relstorage
backend-relstorage:
	@$(MAKE) -C "$(BACKEND_DIR)/develop" relstorage

.PHONY: help
help:
	@printf "%s\n" \
		"Targets:" \
		"  init                Clone frontend/backend repos if missing" \
		"  frontend-start      Start Volto frontend" \
		"  backend-start       Start Plone backend (standalone)" \
		"  frontend-relstorage Start frontend with RelStorage backend" \
		"  backend-relstorage  Start backend with RelStorage/PostgreSQL" \
		"  help                Show this help"
