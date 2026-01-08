FRONTEND_DIR := frontend
BACKEND_DIR := backend
FRONTEND_REPO ?=
BACKEND_REPO ?=

.PHONY: init
init:
	@FRONTEND_REPO="$(FRONTEND_REPO)"; \
	BACKEND_REPO="$(BACKEND_REPO)"; \
	if [ ! -d "$(FRONTEND_DIR)" ]; then \
		if [ -z "$$FRONTEND_REPO" ]; then \
			printf "Frontend repo URL: "; \
			read -r FRONTEND_REPO; \
		fi; \
		if [ -z "$$FRONTEND_REPO" ]; then \
			echo "Frontend repo URL is required."; \
			exit 1; \
		fi; \
		git clone "$$FRONTEND_REPO" "$(FRONTEND_DIR)"; \
	fi; \
	if [ ! -d "$(BACKEND_DIR)" ]; then \
		if [ -z "$$BACKEND_REPO" ]; then \
			printf "Backend repo URL: "; \
			read -r BACKEND_REPO; \
		fi; \
		if [ -z "$$BACKEND_REPO" ]; then \
			echo "Backend repo URL is required."; \
			exit 1; \
		fi; \
		git clone "$$BACKEND_REPO" "$(BACKEND_DIR)"; \
	fi; \
	if [ ! -d ".venv" ]; then \
		python3 -m venv .venv; \
	fi; \
	.venv/bin/python -m pip install --upgrade pip; \
	.venv/bin/python -m pip install pyyaml

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
		"  init                Prompt for frontend/backend repo URLs and clone if missing" \
		"  frontend-start      Start Volto frontend" \
		"  backend-start       Start Plone backend (standalone)" \
		"  frontend-relstorage Start frontend with RelStorage backend" \
		"  backend-relstorage  Start backend with RelStorage/PostgreSQL" \
		"  help                Show this help"
