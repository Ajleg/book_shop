# Book Shop — CI/CD Pipeline

A Django web application for browsing and managing books, containerized with Docker and deployed via GitHub Actions.

## Group Size
Group of 2.

## Branch Strategy

| Branch | Philosophy     | What ships                          |
|--------|----------------|-------------------------------------|
| dev    | Artifact-first | Image built from a committed artifact |
| test   | Image-first    | Fresh image pushed to Docker Hub    |
| prod   | Promotion only | Pulls existing image — no build     |

## How Each Pipeline Works

**dev** — On every push, the workflow installs dependencies into a `vendor/` directory, packages the entire source tree plus vendor into a timestamped `app-<sha>.tar.gz`, commits that artifact to the `artifacts/` folder, then builds a Docker image by extracting the artifact (no pip install in Docker). The image is deployed to EC2 on port 8001.

**test** — On every push (typically a merge from dev), the workflow rebuilds the artifact completely from source — it never reuses the dev artifact. It builds a Docker image from that fresh artifact, pushes both a SHA-tagged version and `latest` to Docker Hub, then deploys to EC2 by pulling the image from the registry. Runs on port 8002.

**prod** — On every push, the workflow reads `vars.IMAGE_VERSION` from the GitHub Actions repository variables (Settings → Secrets and variables → Actions → Variables). It pulls that exact tagged image from Docker Hub and deploys it to EC2. No build step of any kind. Runs on port 8003.

## How Three Deployments Coexist on EC2

Each environment is fully isolated by: separate app directories (`~/book_shop_dev`, `~/book_shop_test`, `~/book_shop_prod`), separate compose project names (`-p dev`, `-p test`, `-p prod`), separate host ports (8001, 8002, 8003), separate named Docker volumes and networks, and separate `.env` files with separate database names (`bookshop_dev`, `bookshop_test`, `bookshop_prod`).

## Promoting to Production

1. Go to Settings → Secrets and variables → Actions → Variables
2. Update `IMAGE_VERSION` to the tag you want (e.g. `test-a1b2c3d4`)
3. Push or merge to the `prod` branch — the pipeline picks up the new value automatically
