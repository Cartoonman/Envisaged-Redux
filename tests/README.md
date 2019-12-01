# Tests

- Known to work on Linux and Mac only.

## Build Dockerfile

From parent directory:

```bash
docker build -f tests/Dockerfile . -t cartoonman/test-envisaged-redux:latest
```

This will build on top of `cartoonman/envisaged-redux:latest`

## Run Tests

To run the test suite, run `tests/scripts/start.sh`
