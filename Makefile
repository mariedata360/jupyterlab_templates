testjs: ## Clean and Make js tests
	yarn test

testpy: ## Clean and Make unit tests
	python3 -m pytest -v jupyterlab_templates/tests --cov=jupyterlab_templates

tests: lint ## run the tests
	python3 -m pytest -v jupyterlab_templates/tests --cov=jupyterlab_templates --junitxml=python_junit.xml --cov-report=xml --cov-branch
	cd js; yarn test

build: ## build python and js
	python3 setup.py build

lint: ## run linter
	python3 -m flake8 jupyterlab_templates setup.py
	cd js; yarn lint

fix:  ## run autopep8/tslint fix
	python3 -m autopep8 --in-place -r -a -a jupyterlab_templates/ jupyterlab_templates/*/*
	cd js; yarn fix

annotate: ## MyPy type annotation check
	mypy -s jupyterlab_templates

annotate_l: ## MyPy type annotation check - count only
	mypy -s jupyterlab_templates | wc -l

clean: ## clean the repository
	find . -name "__pycache__" | xargs  rm -rf
	find . -name "*.pyc" | xargs rm -rf
	find . -name ".ipynb_checkpoints" | xargs  rm -rf
	rm -rf .coverage coverage cover htmlcov logs build dist *.egg-info lib node_modules .autoversion .pytest_cache lab-dist
	# make -C ./docs clean

docs:  ## make documentation
	make -C ./docs html
	open ./docs/_build/html/index.html

install:  ## install to site-packages
	python3 -m pip install .

serverextension: install ## enable serverextension
	python3 -m jupyter serverextension enable --py jupyterlab_templates

js:  ## build javascript
	cd js; yarn
	cd js; yarn build

labextension: js ## enable labextension
	cd js; jupyter labextension install .

dist: js  ## create dists
	rm -rf dist build
	python3 setup.py sdist bdist_wheel

publish: dist  ## dist to pypi and npm
	python3 -m twine check dist/* && twine upload dist/*
	cd js; npm publish

# Thanks to Francoise at marmelab.com for this
.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

print-%:
	@echo '$*=$($*)'

.PHONY: clean install serverextension labextension test tests help docs dist build lint test tests testjs testpy js
