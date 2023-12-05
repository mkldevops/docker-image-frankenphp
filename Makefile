build:
	docker build -t mkldevops/ri7-prospector:latest .

push:
	docker login -u mkldevops -p $(DOCKERHUB_TOKEN)
	docker push mkldevops/ri7-prospector:latest

## —— Git 🎵 ———————————————————————————————————————————————————————————————

git-rebase:
	git pull --rebase
	git pull --rebase origin main

message ?= $(shell git branch --show-current | sed -E 's/^([0-9]+)-([^-]+)-(.+)/\2: \#\1 \3/' | sed "s/-/ /g")
git-auto-commit:
	git add .
	git commit -m "${message}" -q || true

current_branch=$(shell git rev-parse --abbrev-ref HEAD)
git-push:
	git push origin "$(current_branch)" --force-with-lease --force-if-includes

commit:
	@$(MAKE) --no-print-directory git-auto-commit git-rebase git-push ## Commit and push the current branch
