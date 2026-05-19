.PHONY: dev build deploy

dev:
	cd dulval && pnpm dev

build:
	cd dulval && pnpm build

deploy:
	bash scripts/deploy.sh
