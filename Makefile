CURRENT_SIGN_SETTING := $(shell git config commit.gpgSign)

.PHONY: clean-pyc clean-build docs

help:
	@echo "clean-build - remove build artifacts"
	@echo "clean-pyc - remove Python file artifacts"
	@echo "lint - check style with flake8"
	@echo "test - run tests quickly with the default Python"
	@echo "testall - run tests on every Python version with tox"
	@echo "release - package and upload a release"
	@echo "sdist - package"

clean: clean-build clean-pyc

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr *.egg-info

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +

lint:
	tox -e lint

test:
	python -m pytest tests

test-all:
	tox

build-docs:
	sphinx-apidoc -o docs/ . setup.py "eth_abi/utils/*" "*conftest*" "tests/*"
	$(MAKE) -C docs clean
	$(MAKE) -C docs html

docs: build-docs
	open docs/_build/html/index.html

linux-docs: build-docs
	xdg-open docs/_build/html/index.html

release: clean
	# git config commit.gpgSign true
	bumpversion --allow-dirty $(bump)
	git push && git push --tags
	python setup.py sdist bdist_wheel
	python -m twine upload --repository pypi dist/*
	# git config commit.gpgSign "$(CURRENT_SIGN_SETTING)"

sdist: clean
	python setup.py sdist bdist_wheel
	ls -l dist
	python -m twine check dist/*
