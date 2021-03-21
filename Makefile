# \ <sec:var>
MODULE  = $(notdir $(CURDIR))
OS      = $(shell uname -s)
NOW     = $(shell date +%d%m%y)
REL     = $(shell git rev-parse --short=4 HEAD)
CORES  = $(shell grep processor /proc/cpuinfo| wc -l)
# / <sec:var>
# \ <sec:dir>
CWD     = $(CURDIR)
DOC     = $(CWD)/doc
BIN     = $(CWD)/bin
TMP     = $(CWD)/tmp
# / <sec:dir>
# \ <sec:tool>
CURL    = curl -L -o
PY      = bin/python3
PIP     = bin/pip3
PEP     = bin/autopep8
PYT     = bin/pytest
# / <sec:tool>
# \ <sec:src>
P += config.py
S += $(MODULE).py test_$(MODULE).py
# / <sec:src>
# \ <sec:all>
.PHONY: all
all: $(PY) $(MODULE).py
	$^ $@
.PHONY: test
test: $(PYT) test_$(S)
	$^
	$(MAKE) format
.PHONY: format
format: $(PEP)
$(PEP): $(S)
	$@ --ignore=E26,E302,E401,E402,E701,E702 --in-place $? && touch $@
# / <sec:all>
# \ <sec:install>
.PHONY: install
install: $(OS)_install js doc
	$(MAKE) $(PIP)
	$(MAKE) update
.PHONY: update
update: $(OS)_update
	$(PIP) install -U    pip autopep8
	$(PIP) install -U -r requirements.txt
.PHONY: Linux_install Linux_update
Linux_install Linux_update:
	sudo apt update
	sudo apt install -u `cat apt.txt`
# \ <sec:py>
$(PY) $(PIP):
	python3 -m venv .
	$(MAKE) update
$(PYT):
	$(PIP) install -U pytest
# / <sec:py>
# / <sec:install>
# \ <sec:merge>
MERGE  = README.md Makefile .gitignore apt.txt apt.dev $(S)
MERGE += .vscode bin doc tmp
.PHONY: main
main:
	git push -v
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)
.PHONY: shadow
shadow:
	git push -v
	git checkout $@
	git pull -v
.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v && git push -v --tags
	$(MAKE) shadow
.PHONY: zip
zip:
	git archive \
	    --format zip \
	    --output $(TMP)/$(MODULE)_$(NOW)_$(REL).src.zip \
	HEAD
# / <sec:merge>

