NAME = PROJECT
VERSION = 0.1.0
VENV = .venv
SRC_DIR = src/
MAIN = app/main.py


all: install

install: setup
	@uv sync

setup:
	@python3 -c "import sys; exit(1) if sys.version_info < (3, 10) else exit(0)" || \
	(echo "Error: Python 3.10 or higher is required."; exit 1)
	@if ! command -v uv > /dev/null 2>&1; then \
		echo "uv is not installed on this computer."; \
		echo "Installing the uv package manager..."; \
		python3 -m pip install --user uv; \
	else \
		echo "uv is already installed. Version:"; \
		uv --version --short; \
		echo "Proceeding..."; \
	fi

build: install
	@uv build

run:
	@uv run $(SRC_DIR)$(MAIN)

debug:
	@uv run python3 -m pdb $(SRC_DIR)$(MAIN)

clean:
	@echo "Removing temporary files or caches"
	@rm -rf .mypy_cache .pytest_cache src/*.egg-info
	@find . -type d -name "__pycache__" -exec rm -rf {} +

fclean: clean
	@echo "Removing virtual environment and distribution files"
	@rm -rf $(VENV)
	@rm -rf dist/

re: fclean all

lint:
	@echo "running linter..."
	@uv run flake8 $(SRC_DIR)
	@uv run mypy $(SRC_DIR)

lint-strict:
	@echo "running strict linter..."
	@uv run flake8 $(SRC_DIR)
	@uv run mypy $(SRC_DIR) --strict

test:
	@echo "Running test suite..."
	@uv run pytest -v

test-file:
	@if [ -z "$(FILE)" ]; then \
		echo "ERROR: You must specify the file."; \
		echo "Usage: make test-file FILE=tests/test_your_file.py"; \
	else \
		echo "Running tests for : $(FILE)..."; \
		uv run pytest $(FILE) -v; \
	fi


.PHONY: all install setup run build debug clean fclean re lint lint-strict test test-file