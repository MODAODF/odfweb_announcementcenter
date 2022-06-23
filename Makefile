# Makefile for building the project

app_name=announcementcenter

project_dir=$(CURDIR)/../$(app_name)
build_dir=$(CURDIR)/build/
sign_dir=$(build_dir)/sign
package_name=$(app_name)
version+=master
composer=$(shell which composer 2> /dev/null)
BRANCH:=$(shell cat dist_git_branch 2> /dev/null || git rev-parse --abbrev-ref HEAD 2> /dev/null)

all: appstore

# Dev env management
dev-setup: clean npm-init


# Installs and updates the composer dependencies. If composer is not installed
# a copy is fetched from the web
composer:
ifeq (, $(composer))
	@echo "No composer command available, downloading a copy from the web"
	mkdir -p $(build_tools_directory)
	curl -sS https://getcomposer.org/installer | php
	mv composer.phar $(build_tools_directory)
	php $(build_tools_directory)/composer.phar install --prefer-dist
	php $(build_tools_directory)/composer.phar update --prefer-dist
else
	composer install --prefer-dist
	composer update --prefer-dist
endif

npm-init:
	npm ci

npm-update:
	npm update

# Building
build-js:
	npm run dev

build-js-production:
	npm run build

watch-js:
	npm run watch

# Linting
lint:
	npm run lint

lint-fix:
	npm run lint:fix

# Style linting
stylelint:
	npm run stylelint

stylelint-fix:
	npm run stylelint:fix

release: appstore create-tag

create-tag:
	git tag -a v$(version) -m "Tagging the $(version) release."
	git push origin v$(version)

clean:
	rm -rf $(build_dir)
	rm -rf node_modules
	rm -f js/announcementcenter-dashboard.js
	rm -f js/announcementcenter-dashboard.js.map

js-templates:
	handlebars -n OCA.AnnouncementCenter.Templates js/templates -f js/templates.js

appstore: dev-setup build-js-production
	mkdir -p $(sign_dir)
	rsync -a \
	--exclude=/.git \
	--exclude=/.github \
	--exclude=/.tx \
	--exclude=/build \
	--exclude=/docs \
	--exclude=/l10n/l10n.pl \
	--exclude=/node_modules \
	--exclude=/src \
	--exclude=/tests \
	--exclude=/vendor \
	--exclude=/.eslintrc.js \
	--exclude=/.php_cs.cache \
	--exclude=/.php_cs.dist \
	--exclude=/.gitattributes \
	--exclude=/.gitignore \
	--exclude=/.scrutinizer.yml \
	--exclude=/.travis.yml \
	--exclude=/babel.config.js \
	--exclude=/Makefile \
	--exclude=/README.md \
	--exclude=/stylelint.config.js \
	--exclude=/webpack.js \
	--exclude=/package.json \
    --exclude=/package-lock.json \
    --exclude=/CHANGELOG.md \
    --exclude=/composer.json \
    --exclude=/composer.lock \
	--exclude=/COPYING \
	$(CURDIR)/ $(sign_dir)/$(app_name)
	tar -czf $(build_dir)/$(app_name)-$(version)-$(BRANCH).tar.gz \
		-C $(sign_dir) $(app_name)
