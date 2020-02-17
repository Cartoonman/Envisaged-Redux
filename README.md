# Envisaged Redux

## About

<img style="float: right;" align="right" src="https://envisaged-redux.now.sh/resources/envisaged_redux_logo.png" alt="Envisaged Redux Logo">

**Envisaged Redux** is a Docker container application that combines the power of Gource and FFmpeg to generate visualizations. Currently the focus and capability of **Envisaged Redux** is on Git commit history visualizations. However it can easily be extended to visualize anything using Gource's custom log format.

What makes this stand apart from other similar containerized applications is its portable-focused approach. **Envisaged Redux** can and will run on any platform that supports Docker, and it requires no extra hardware support to run (e.g. GPU's). This enables **Envisaged Redux** to be used in CI/CD chains and basic cloud VPS services without issue. This is achieved by leveraging the Gallium LLVMPipe Driver and Xvfb to render in software.

**Envisaged Redux** is a fork of the original [Envisaged Project](https://github.com/utensils/Envisaged).

## Documentation

The official documentation for **Envisaged Redux** is hosted by [Zeit](https://zeit.co). 
The latest documentation tracking the `master` branch can be reached at **https://envisaged-redux.now.sh**.

For current and previous tagged releases, please see the [Releases Page](https://gitlab.com/Cartoonman/Envisaged-Redux/-/releases) or the [Changelog](CHANGELOG.md) for links to their documentation.

Note that official documentation only exists from version v0.12.0 onward. 
For documentation for prior versions, the project's `README.md` file serves as the only documentation available. 