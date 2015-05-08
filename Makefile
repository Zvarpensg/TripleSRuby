all: deps database

deps:
	@bundle install --path packages/bundle || (echo "Failed to download dependencies.")

database:
	@./initdb.rb && (echo "Created database.") || (echo "Failed to create database.")
