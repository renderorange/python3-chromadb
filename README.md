# ChromaDB Debian Package Builder

Builds `.deb` packages for [ChromaDB](https://pypi.org/pypi/chromadb) from pre-built wheels.

## Usage

Build requires: `curl`, `python3`

```bash
# Build latest version
MAINTAINER_EMAIL=you@example.com ./bin/build-deb

# Build specific version
MAINTAINER_EMAIL=you@example.com ./bin/build-deb 1.5.7

# Build with debug output
MAINTAINER_EMAIL=you@example.com ./bin/build-deb --debug 1.5.7
```

Set `MAINTAINER_EMAIL` to your email (required).

Output: `python3-chromadb_<version>-1_<arch>.deb` (e.g., `amd64`)

## Install

```bash
sudo apt install ./python3-chromadb_*.deb
```

Package dependencies (`python3`, `python3-pydantic`, `python3-hnswlib`) are automatically installed by apt.

## Remove

```bash
sudo apt remove python3-chromadb
```

## Supported Architectures

- `amd64` (x86_64)

## Tests

```bash
# Run all tests
./tests/run.sh

# Run with debug output
./tests/run.sh --debug

# Run individual tests
./tests/01-syntax.sh   # Script syntax check
./tests/02-build.sh    # Build package and validate
```

## Build Automation

This repo runs two github actions to automate building and releasing new versions.

### Poll for New Versions

[poll.yml](.github/workflows/poll.yml) runs every hour through Github actions cron.  It checks for a new version of ChromaDB that doesn't have a release in this repo, then creates a release branch with version, and triggers the build process.

### Build and Release 

[build.yml](.github/workflows/build.yml) is triggered by poll.  It fetches the version as outlined in the release branch, then runs the build-deb script, runs the tests, creates a tag and release, then attaches the deb to the release.  The release branch is then removed.

## LICENSE AND COPYRIGHT

ChromaDB is Copyright (c) 2023 ChromaDB Contributors (Apache License 2.0).

This packaging script is Copyright (c) 2026 Blaine Motsinger (MIT License).
