export RELEASE_NOTE := "no release notes"

.PHONY: all run_dev_web run_dev_mobile run_unit clean upgrade lint format build_dev_mobile help watch gen run_stg_mobile run_prd_mobile build_apk_dev build_apk_stg build_apk_prd purge

all: lint format run_dev_mobile

# Adding a help file: https://gist.github.com/prwhite/8168133#gistcomment-1313022
help: ## This help dialog.
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
	for help_line in $${help_lines[@]}; do \
		IFS=$$'#' ; \
		help_split=($$help_line) ; \
		help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		printf "%-30s %s\n" $$help_command $$help_info ; \
	done

run_unit: ## Runs unit tests
	@echo "╠ Running the tests"
	@flutter test || (echo "Error while running tests"; exit 1)

clean: ## Cleans the environment
	@echo "╠ Cleaning the project..."
	@rm -rf pubspec.lock
	@flutter clean
	@flutter pub get

fvm_clean: ## Cleans the environment
	@echo "╠ Cleaning the project..."
	@rm -rf pubspec.lock
	@fvm flutter clean
	@fvm flutter pub get

watch: ## Watches the files for changes
	@echo "╠ Watching the project..."
	@flutter pub run build_runner watch --delete-conflicting-outputs

build: ## Build the files for changes
	@echo "╠ Building the project..."
	@flutter pub run build_runner build --delete-conflicting-outputs

fvm_build: ## Build the files for changes
	@echo "╠ Building the project..."
	@fvm flutter pub run build_runner build --delete-conflicting-outputs


gen: ## Generates the assets
	@echo "╠ Generating the assets..."
	@flutter pub get
	@flutter packages pub run build_runner build  --delete-conflicting-outputs

fvm_gen: ## Generates the assets
	@echo "╠ Generating the assets..."
	@fvm flutter pub get
	@fvm flutter packages pub run build_runner build  --delete-conflicting-outputs

format: ## Formats the code
	@echo "╠ Formatting the code"
	@dart format lib .
	@flutter pub run import_sorter:main
	@flutter format lib

fvm_format: ## Formats the code
	@echo "╠ Formatting the code"
	@dart format lib .
	@fvm flutter pub run import_sorter:main
	@fvm flutter format lib
	@fvm flutter pub run pubspec_dependency_sorter:main

lint: ## Lints the code
	@echo "╠ Verifying code..."
	@dart analyze . || (echo "Error in project"; exit 1)

auto_fix_dry_run:
	@echo "╠ Checking auto fix code..."
	@dart fix --dry-run

auto_fix_apply:
	@echo "╠ Checking auto fix code..."
	@dart fix --apply

upgrade: clean ## Upgrades dependencies
	@echo "╠ Upgrading dependencies..."
	@flutter pub upgrade

commit: format lint run_unit
	@echo "╠ Committing..."
	git add .
	git commit

fvm_build_apk_prod: ## Runs the mobile application in prod
	@fvm flutter build apk --flavor production -t lib/main_production.dart

fvm_build_appbundle_prod: ## Runs the mobile application in prod
	@fvm flutter build appbundle --release

fvm_build_ipa_prod: ## Runs the mobile application in prod
	@fvm flutter build ipa --release

fvm_generate_launcher_icon:
	@fvm flutter pub run flutter_launcher_icons

fvm_generate_native_splash:
	@dart run flutter_native_splash:create --flavor production
	@dart run flutter_native_splash:create --flavor development

purge: ## Purges the Flutter
	@pod deintegrate
	@flutter clean
	@flutter pub get


