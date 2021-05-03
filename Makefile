# Variables

## xcodeproj filename
project_name=MVPApp

.PHONY: help
help: ## Show this usage
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: xcode
xcode: ## Select latest version of Xcode
	sudo xcode-select --switch /Applications/Xcode.app/

.PHONY: bootstrap
bootstrap: ## Install ruby tools
	brew bundle
	mint bootstrap
	bundle config set --local path 'vendor/bundle'
	bundle install

.PHONY: project
project: ## Generate Xcode project and workspace
	mint run SwiftGen swiftgen
	mint run XcodeGen xcodegen
	# bundle exec pod install
	sh ./scripts/carthage-workaround-xc12.sh bootstrap --platform iOS --cache-builds

.PHONY: open
open: ## Open Xcode workspace
	open $(project_name).xcodeproj

.PHONY: clean
clean: ## Clean generated files
	rm -rf $(project_name).xcodeproj
	rm -rf $(project_name).xcworkspace
	rm -rf ./**/Generated/*
	rm -rf Carthage
	rm -rf Pods
	rm -rf ~/Library/Developer/Xcode/DerivedData/

.PHONY: update
update: ## Update tool versions
	brew update
	brew upgrade
	bundle update
	mint bootstrap
	# bundle exec pod update
	sh ./scripts/carthage-workaround-xc12.sh update --platform iOS
