all:

## ------ Setup ------

WGET = wget
PERL = perl
GIT = git
PERL_VERSION = latest
PERL_PATH = $(abspath local/perlbrew/perls/perl-$(PERL_VERSION)/bin)
REMOTEDEV_HOST = remotedev.host.example
REMOTEDEV_PERL_VERSION = $(PERL_VERSION)

PMB_PMTAR_REPO_URL =
PMB_PMPP_REPO_URL = 

Makefile-setupenv: Makefile.setupenv
	$(MAKE) --makefile Makefile.setupenv setupenv-update \
	    SETUPENV_MIN_REVISION=20120909

Makefile.setupenv:
	$(WGET) -O $@ https://raw.github.com/wakaba/perl-setupenv/master/Makefile.setupenv

lperl lprove lplackup local-perl perl-version perl-exec \
config/perl/libs.txt carton-install carton-update carton-install-module \
remotedev-test remotedev-reset remotedev-reset-setupenv \
local-submodules pmb-install pmb-update cinnamon \
generatepm: %: Makefile-setupenv
	$(MAKE) --makefile Makefile.setupenv $@ \
            REMOTEDEV_HOST=$(REMOTEDEV_HOST) \
            REMOTEDEV_PERL_VERSION=$(REMOTEDEV_PERL_VERSION) \
	    PMB_PMTAR_REPO_URL=$(PMB_PMTAR_REPO_URL) \
	    PMB_PMPP_REPO_URL=$(PMB_PMPP_REPO_URL)

git-submodules:
	$(GIT) submodule update --init

deps: git-submodules local-submodules pmb-install

## ------ Tests ------

PROVE = prove
PERL_ENV = PATH="$(abspath ./local/perl-$(PERL_VERSION)/pm/bin):$(PERL_PATH):$(PATH)" PERL5LIB="$(shell cat config/perl/libs.txt)"

test: test-deps test-main

test-deps: deps

test-main:
	$(PERL_ENV) $(PROVE) t/*.t
