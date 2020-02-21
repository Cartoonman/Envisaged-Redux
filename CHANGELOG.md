# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### [Documentation](https://envisaged-redux.now.sh/)

### Added
- GOURCE_REALTIME added.
- GOURCE_ELASTICITY added.
- Background Image functionality added.
- GOURCE_FOLLOW_USER added.
- GOURCE_HIGHLIGHT_DIRS added.
- GOURCE_HIGHLIGHT_COLOR added.
- GOURCE_SELECTION_COLOR added.
- GOURCE_FILENAME_COLOR added.
- GOURCE_DIR_COLOR added.
- GOURCE_FILE_EXTENSIONS added.
- GOURCE_USER_FRICTION added.
- GOURCE_DISABLE_AUTO_ROTATE added.
- Default User Image functionality added.
- GOURCE_COLOR_IMAGES added.
- PDF Documentation build on Zeit upstream.
- Versioned docs accessible in Changelog.

### Updated
- External links in documentation now opens new tab in browsers.
- **API Change:** GOURCE_HIGHLIGHT_ALL_DIRS changed to GOURCE_HIGHLIGHT_DIRS for consistency.
- **API Change:** GOURCE_DIR_DEPTH changed to GOURCE_DIR_NAME_DEPTH for consistency.


## [0.13.0] - 2020-02-12

### [Documentation](https://envisaged-redux-v0-13-0.now.sh/)

### Added
- RUNTIME_PRINT_VARS added to print variables.
- Validation of Environment Variables.
- Avatars and Logo added to quick-start example.

### Updated
- **API Change:** Standardizing namespaces of input variables.
- **API Change:** Migrating user-defined mount files into `/resources` subdirectory.
- Documentation.

### Fixed
- Regression bug where image2pipe doesn't run in sync with frame rate, causing duplicate frames.
- Regression bug where Env Vars with spaces in values were not handled properly.
- Hanging if provided vcs directory contained no valid repos.
- Missing PNG decoding support in FFmpeg.
- Fixed broken Logo handling.

## [0.12.1] - 2020-02-07

### [Documentation](https://envisaged-redux-v0-12-1.now.sh/)

### Added
- Adding tests for Border Template variable handling.
- Documentation on building Envisaged Redux.

### Updated
- Cleaned up and refactored Tests suite.

### Fixed

- Fixed handling of SIGINT in interactive mode.
- Fixed handling of end-of-stream event for HLS client.
- Fixed FFmpeg thread queue blocking.

## [0.12.0] - 2020-02-01

### [Documentation](https://envisaged-redux-v0-12-0.now.sh/)

### Added

- Sources placed under /gpl_sources to comply with GPL.
- Added System tests, but disabled by default. Pending updates to Gource and further testing to see if reproducible behavior exists.
- Asciidoc Documentation.

### Updated

- Replaced static build of FFmpeg with local source build.
- Additional functionality and refactoring to example scripts.

### Fixed

- Improper string handling in example's arg parser.
- Typo where GOURCE_BORDER_DATE_SIZE was not propagated to the border template correctly.

## [0.11.0] - 2020-01-19

### Added

- Unit and Integration Test Suite with Dockerfile and start script.
- quick_start.sh script and suite for new users to become familiar with using Envisaged-Redux and its capabilities.
- Version file.
- Added correctness check for httpd startup with curl.

### Updated

- Updated base image to Alpine Linux 3.11.
- Updated Mesa to 19.2.8.
- Updated hls.js to 13.1.
- Ported the deprecated autotools-based build of Mesa to Meson.
- Updated to LLVM 5.
- Affixed gource_stable to v0.49 and built from source.
- Replaced upstream reference to utensils/opengl with local build of mesa library for direct control and to keep it up to date.
- Migrated project to Apache 2 License (from MIT).
- Refactored template runtime command args for Gource and ffmpeg for better observation thru tests.
- Refactored common imports for entrypoint and templates.
- Refactored entrypoint and modularized components.
- Renamed template names.
- VBV bufsize increased for preview.
- Colored logging now only colors the tag indicator.
- Migrated echo statements in loggers to printf for better reliability.
- Consistent punctuation in Changelog.

### Fixed

- Edge case of multi-repo support failing if directory is a symbolic link.
- Slowdown Factor now an assigned default when Live Preview is enabled.
- Added check if logo is given but no assigned logo stream label was set.
- Fixed broken background pid kill chain.
- Fixed exit code to accurately reflect system state.
- A number of shell and Docker cleanups and fixes through shellcheck and hadolint.
- Race condition fixed in preview.html when intervalFn is null when not expected.
- Typo during Xvfb check that ran xdpyinfo in the background.
- Fixed hanging background processes if failure occurs during bootup of httpd or xvfb (before the traps are set).
- Fixed bug where gource background processes are not explicitly killed upon exit, hanging fd 1 if an error occurred.

### Removed
- swr libraries (Will be added back in later when further testing occurs with swr. Does not affect LLVMPipe).

## [0.10.0] - 2019-11-23

### Added

- This Changelog.
- Local output support (saving output.mp4 to a local directory via mount).
- Multi-sampling and key Gource options.
- Font color Gource option.
- Hook for testing.

### Updated

- Updated tags in example scripts to use correct image name.
- Documentation.
- Significant refactor work on Gource and ffmpeg arg parsing. 
- Refactored border template specific variables.
- Updated VCS repo to point to Gitlab in Docker Label.
- Logger output now has labels.

### Fixed

- Various typos throughout the project.
- GOURCE_HIDE_ITEMS_ARG was not properly checked in no-template runtime. This is now fixed.
- Fixed inconsistent DIR path discovery to get current script DIR path for common imports.

## [0.9.1] - 2019-11-15

### Updated

- Reformatted and linted all shell scripts, html files, and Dockerfile.

## [0.9.0] - 2019-11-15

### Added

- Live Preview with PREVIEW_SLOWDOWN_FACTOR option.

### Removed

- GOURCE_FILTER and GLOBAL_FILTER input variables.

### Updated

- Reworked ffmpeg filter chains for both runtime templates.
- Documentation updated for Live Preview.

### Fixed

- Patched edge condition trying to use an unsupported or invalid video resolution.

## [0.8.0] - 2019-11-13

### Added

- highlight-all-users, bloom-multiplier, bloom-intensity, and general font-size added.

### Updated

- Intro banner minor update.
- Non-template runtime now updated in parity with border template.
- Documentation Environment variable table refactored.

## [0.7.0] - 2019-11-09

### Added

- Nightly Gource option, with nightly option file-ext-fallback.
- org.label-schema labels added back in with updated fields.
- Intro banner

### Updated

- Bash scripts now use common.bash for common functions for scalability and ease of maintenance.
- Reworked logging to use common functions for improved cleanliness.

### Fixed

- Xvfb race condition handling now deterministic with wait loop. Significantly faster start times observed.
- Entrypoint sometimes being superseded by old embedded entrypoint, so explicit entrypoint was defined.
- End notice now checks if a video file was saved before declaring if visualization process completed successfully.

## [0.6.0] - 2019-11-07

### Added

- Recursive submodule support for multi-repo use case.
- Documentation for Docker Runtime Args (mounts).
- Documentation for troubleshooting image conversion problems when using logo feature.
- Color tagged output logging.
- Hard checks on gource custom log parsing.
- Example scripts support args for avatars, and logo-file.

### Removed

- LOGO_URL variable. Logos are local-only for now.

### Updated

- Logo and avatar support updated to be in-line with methodology used by captions.
- Example scripts's help output updated.

### Fixed

- -it added to example scripts to fix terminal handling.
- Recursive submodule bug not handling nested submodules correctly; using $displaypath instead of $path fixes this.

## [0.5.0] - 2019-11-02

### Added

- MIT License SPDX format propagated to src files.
- Recursive submodule support.
- Link back to original Envisaged repo in Readme.

### Removed

- Reverted back to using utencils/opengl as base image for now to make things simpler.
- Old usage examples that are no longer applicable in Readme.

### Updated

- MIT License updated with copyrights.
- Backticks removed from Readme table to make it easier to read.

## [0.4.0] - 2019-10-13

### Added

- Multi-repository support (single level, non-recursive multirepo).
- Variadic argument support for example launch scripts.
- Help function for example scripts.

### Removed

- Title input argument in example launch scripts (Variadic args supersedes this).

### Updated

- Example scripts given variadic argument support.

## [0.3.1] - 2019-10-13

### Removed

- Build script.

### Fixed

- Documentation to reflect 480p resolution addition.
- Documentation to clarify hide args for border template.
- preview.sh's default video resolution.

## [0.3.0] - 2019-10-13

### Added

- 480p resolution support.
- Pulled in the opengl docker image into Dockerfile for a pure build.
- Support for captions, along with caption-size, caption-colour, and caption-duration.
- Added multisampling on by default.
- Example launch scripts.
- start-date, stop-date, start-position, stop-position, and stop-at-time options.
- auto-skip-seconds, file-idle-time, max-files, max-file-lag, and padding options.

### Removed

- Bootstrap and jquery dependencies, and cleaned up html files to be bare.

### Updated

- Documentation.
- FPS as a variable configurable by user to 25, 30, or 60 FPS.
- Font size and color variables for border template.

## [0.2.0] - 2019-10-10

### Updated

- Documentation to reflect relationship with original [Envisaged].
- Replaced H.264 with H.265/HEVC in ffmpeg render steps.
- Documentation to reflect H.265 support.

## [0.1.0] - 2019-10-10

Initial fork from [Envisaged].

[unreleased]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.13.0...master
[0.13.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.12.1...v0.13.0
[0.12.1]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.12.0...v0.12.1
[0.12.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.11.0...v0.12.0
[0.11.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.10.0...v0.11.0
[0.10.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.9.1...v0.10.0
[0.9.1]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.9.0...v0.9.1
[0.9.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.8.0...v0.9.0
[0.8.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.7.0...v0.8.0
[0.7.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.6.0...v0.7.0
[0.6.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.5.0...v0.6.0
[0.5.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.4.0...v0.5.0
[0.4.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.3.1...v0.4.0
[0.3.1]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.3.0...v0.3.1
[0.3.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.2.0...v0.3.0
[0.2.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/compare/v0.1.0...v0.2.0
[0.1.0]: https://gitlab.com/Cartoonman/Envisaged-Redux/-/releases#v0.1.0
[Envisaged]: https://github.com/utensils/Envisaged
