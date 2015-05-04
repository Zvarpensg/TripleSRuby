all: deps


deps:
	@bundle install --path packages/bundle || (echo "Failed to download dependencies.")
