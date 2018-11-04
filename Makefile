# target: help - Display callable targets
help:
	@echo "This makefile assumes you have docker installed ...\n"
	@echo "Available targets:"
	@egrep "^# target:" Makefile

# target: build - Builds a docker container
build:
	PLATFORM=ubuntu bin/release build
