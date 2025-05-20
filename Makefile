.PHONY: clean clean-build clean-pyc clean-test coverage dist docs help install lint lint/flake8
.DEFAULT_GOAL := help

MODULE_NAME = test_mod
DOCS_PATH = public
CURRENT_VERSION := $(shell python3 -c "import os; about={}; exec(open(os.path.join('$(MODULE_NAME)', '_metadata.py')).read(), about); print(about['__version__'])")
WHEEL_NAME = $(MODULE_NAME)-$(CURRENT_VERSION)-py3-none-any.whl
WHEEL_PATH = dist/$(WHEEL_NAME)
MAIN_FILES =
S3_BUCKET = s3://analytics.code.tools
S3_PATH = $(S3_BUCKET)/$(MODULE_NAME)
PYTHON = python3
PYTHON_VERSION ?= 3.12
VIRTUALENV_NAME=.venv
VIRTUALENV_PYTHON_VERSION=python$(PYTHON_VERSION)

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

module_name:
	@echo $(MODULE_NAME)

version:
	@echo $(CURRENT_VERSION)

mkvirtualenv:
	@ uv venv $(VIRTUALENV_NAME) --python="$(VIRTUALENV_PYTHON_VERSION)"

rmvirtualenv:
	@ rm -rf $(VIRTUALENV_NAME)

install_dependencies:
	@ uv sync --all-extras

install_dependencies_dev:
	@ uv sync --all-groups --all-extras

upgrade_dependencies:
	@ uv lock --upgrade

lint: lint-ruff

lint-ruff:
	@ uv run ruff check $(MODULE_NAME)

lint-pylint:
	@ uv run pylint $(MODULE_NAME)

make format: format-ruff

make format-ruff:
	@ uv run ruff format $(MODULE_NAME)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	@ rm -fr build/
	@ rm -fr dist/
	@ rm -fr .eggs/
	@ find . -name '*.egg-info' -exec rm -fr {} +
	@ find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	@ find . -name '*.pyc' -exec rm -f {} +
	@ find . -name '*.pyo' -exec rm -f {} +
	@ find . -name '*~' -exec rm -f {} +
	@ find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	@ rm -f .coverage
	@ rm -fr htmlcov/
	@ rm -fr .pytest_cache

docs:
	@ rm -rf $(DOCS_PATH)
	@ uv run sphinx-build -b html docs $(DOCS_PATH)

test:
	@ uv run pytest tests

wheel: clean-build
	@ uv build --wheel

build: clean-build
	@ uv build
