include .env
ifeq ($(OS),Windows_NT)
    # For Windows, use PowerShell to get the current timestamp
    CURRENT_TIMESTAMP := $(shell powershell Get-Date -Format "yyyyMMdd_HHmmss")
else
    # For Linux, use date command to get the current timestamp
    CURRENT_TIMESTAMP := $(shell date +"%Y%m%d_%H%M%S")
endif

test-traefik:
	@echo "Testing on web proxy traefik"
	artillery run --output $(APP_VERSION)_report_traefik_$(CURRENT_TIMESTAMP).json --target $(WEB_PROXY) load-test.yml && \
	artillery report --output $(APP_VERSION)_report_traefik_$(CURRENT_TIMESTAMP).html $(APP_VERSION)_report_traefik_$(CURRENT_TIMESTAMP).json 
	@echo "Finished"

test-nginx:
	@echo "Testing on web proxy nginx"
	artillery run --output $(APP_VERSION)_report_nginx_$(CURRENT_TIMESTAMP).json --target $(WEB_PROXY) load-test.yml && \
	artillery report --output $(APP_VERSION)_report_nginx_$(CURRENT_TIMESTAMP).html $(APP_VERSION)_report_nginx_$(CURRENT_TIMESTAMP).json
	@echo "Finished"

build-run-aio:
	docker compose up --build aio