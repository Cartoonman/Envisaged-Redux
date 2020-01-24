# Envisaged-Redux - Dockerized Gource Visualizations, Reborn
**Powered by Gource, FFMpeg, and the Gallium LLVMPipe Driver**

Built on top of Alpine 3.11. **No GPU is required**, this will run on any machine, such as a standard EC2 instance or any other VPS.

## About

Painless data visualizations from git history showing a repositories development progression over time.
This container combines the awesome [Gource][gource] program with the power of [FFmpeg][ffmpeg_home] and the H.265/HEVC codec to bring you high resolution (up to 4k at 60fps) video visualizations.

This container is 100% headless, it does this by leveraging [Xvfb][xvfb] combined with the [Mesa 3D Gallium LLVMPipe Driver][mesa]. 
Unlike other docker containers with Gource, this container does not eat up 100's of gigabytes of disk space, nor does it require an actual GPU to run. 
The process runs the Gource simulation concurrently with the FFmpeg encoding process using a set of named pipes. 
There is a slight trade off in performance, but this makes it very easy to run in any environment such as AWS, without the need to provision large amounts of storage or run any cleanup.

This project uses FFmpeg, libx264, libx265, and Gource, which are licensed under GPL of their respective copyright owners.
They are compiled from source and the source code is bundled with each image under `/gpl_sources`.
Compile-time configurations are derivable from the Dockerfile.
If there is any issue regarding GPL compliance, reach out to the maintainer of this project.

Envisaged Redux is a fork of the [Envisaged][envisaged] docker container.

## Example Scripts

Example scripts can be found under `examples/`.

- default.sh - Performs a video encoding with all default settings. Provides an extendable baseline script template for custom rendering configs. Note: if git repo is not specified, it will default to using this repo for the visualization.
- preview.sh - Builds upon default.sh to present an example generating a ~5-10 second snippet using optimized configs for the fastest rendering speed possible. Useful for quickly testing effects changes.

## Configuration

This container is configurable through docker runtime args and environment variables listed below. The generated video is delivered via HTTP.

### Docker Runtime Mounts

| Purpose  | Example                                                                                | Description                                                                                                                                                                                                                          |
| -------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Repo(s)  | `--mount type=bind,src=/path/to/git_repo(s)_dir,dst=/visualization/git_repo,readonly`  | Required. Mounts the path to a single git repo, or a directory of multiple git repos for multi-repo visualizations. (Recommended for multi-repo: add _root_ to GOURCE_HIDE_ITEMS list argument to visually separate multiple repos.) |
| Captions | `--mount type=bind,src=/path/to/captions.txt,dst=/visualization/captions.txt,readonly` | Optional. Gource will try given captions.txt file to render captions on video. See [gource] docs for supported caption format.                                                                                                       |
| Avatars  | `--mount type=bind,src=/path/to/avatars_dir,dst=/visualization/avatars,readonly`       | Optional. Gource will try given avatars directory to render user avatars on video. See [gource] docs for naming rules and supported image types.                                                                                     |
| Logo     | `--mount type=bind,src=/path/to/image.png,dst=/visualization/logo.image,readonly`      | Optional. Gource will try given logo image file to render the logo in the lower right hand corner of the video.                                                                                                                      |
| Output   | `--mount type=bind,src=/path/to/output_dir,dst=/visualization/video`                   | Optional. If this mount is made, Envisaged Redux will save the rendered video in the mounted directory and immediately exit once rendering completes.                                                                                |

### Environment Variables

This is the current list of supported environment runtime variables that you can use to customize how the container renders and works with your repo(s).

#### Mode Settings

| Variable                | Default Value | Description                                                                                                         |
| ----------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------- |
| RECURSE_SUBMODULES      | 0             | Flag to enable recursing through the repo(s) submodules                                                             |
| ENABLE_LIVE_PREVIEW     | 0             | Flag to enable Live Gource preview through the web interface. Read section below for details.                       |
| PREVIEW_SLOWDOWN_FACTOR | 2             | Slowdown Factor for easing buffer hangs from slow renders. 1 means no slowdown. Supported values are integers >= 1. |

##### Regarding Live Preview

Live preview requires H.264 codec support and JavaScript enabled in your browser. 
Has been confirmed working on the latest versions of Firefox, Chromium, and Edge, with likely support on Chrome, Safari and Opera. 
Since this works through the browser, it is inherently platform agnostic.

Live preview works concurrently with the normal video rendering process, so at the end of the render you will have the original video available to save.

The PREVIEW_SLOWDOWN_FACTOR option is used to slow the preview stream to reduce buffer hangs from slow renders. 
This setting only affects the preview, and will not affect the resultant `output.mp4`.

Excluding H265_PRESET, H265_CRF, and PREVIEW_SLOWDOWN_FACTOR > 1, all other render settings, Gource effects, and templates represented in the live_preview are exactly shown as what is rendered to `output.mp4`.
Of the given exclusions, the CRF config is the configuration with the biggest impact on visual differences between the saved video and the live preview.
The live preview uses a CRF of 1 and a fixed max bitrate ceiling.
Because of this, visual artifacts seen in the live preview may not manifest in `output.mp4` and vice versa.

If you want to ensure the video will look like what you expect from a visual quality point of view, it is recommended you run a separate run with a small time segment and view the rendered video.

If you are unable to use live preview, the `preview.sh` script is the best alternative to quickly check the effects of your configs before rendering a longer run.
You can also make `preview.sh` run for the whole duration by removing the `-e GOURCE_STOP_AT_TIME="5"` argument from the `docker run` step.

#### Render Settings

| Variable         | Default Value | Description                                                                                                                          |
| ---------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| H265_PRESET      | medium        | h.265 encoding preset. Refer to [FFmpeg's wiki][ffmpeg_h265].                                                                        |
| H265_CRF         | 21            | The Constant Rate Factor (CRF). Refer to [FFmpeg's wiki][ffmpeg_h265].                                                               |
| VIDEO_RESOLUTION | 1080p         | Output video resolution, options are **2160p, 1440p, 1080p, 720p, 480p**                                                             |
| FPS              | 30            | Output video Frames per Second. Supported framerates are 25,30, or 60 only.                                                          |
| TEMPLATE         |               | Specify a template to use. Two templates currently exist: **standard** and **border**. If not specified, will use standard template. |
| INVERT_COLORS    | 0             | Inverts the colors on the visualization.                                                                                             |

##### General Gource Settings

| Variable                   | Default Value        | Description                                                                                      |
| -------------------------- | -------------------- | ------------------------------------------------------------------------------------------------ |
| GOURCE_TITLE               | Software Development | [--title] Title to be displayed in the lower left hand corner of video.                          |
| GOURCE_CAMERA_MODE         | overview             | [--camera-mode] Camera mode (overview, track).                                                   |
| GOURCE_START_DATE          |                      | [--start-date] Start after given date (and optional time) (see [gource] docs for formats)        |
| GOURCE_STOP_DATE           |                      | [--stop-date] Stop after given date (and optional time) (see [gource] docs for formats)          |
| GOURCE_START_POSITION      |                      | [--start-position] Begin at some position in the log (between 0.0 and 1.0 or 'random').          |
| GOURCE_STOP_POSITION       |                      | [--stop-position] Stop at some position in the log (between 0.0 and 1.0)                         |
| GOURCE_STOP_AT_TIME        |                      | [--stop-at-time] Stop after a specified number of seconds.                                       |
| GOURCE_SECONDS_PER_DAY     | 0.1                  | [--seconds-per-day] Speed of simulation in seconds per day.                                      |
| GOURCE_AUTO_SKIP_SECONDS   | 3.0                  | [--auto-skip-seconds] Skip to next entry if nothing happens for a number of seconds.             |
| GOURCE_TIME_SCALE          | 1.0                  | [--time-scale] Change simulation time scale.                                                     |
| GOURCE_USER_SCALE          | 1.0                  | [--user-scale] Change scale of user avatars.                                                     |
| GOURCE_MAX_USER_SPEED      | 500                  | [--max-user-speed] Max speed users can travel per second.                                        |
| GOURCE_HIDE_ITEMS          | mouse                | [--hide] Hide one or more display elements (border template overrides date)                      |
| GOURCE_FILE_IDLE_TIME      | 0.0                  | [--file-idle-time] Time in seconds files remain idle before they are removed or 0 for no limit.  |
| GOURCE_MAX_FILES           | 0                    | [--max-files] Set the maximum number of files or 0 for no limit. Excess files will be discarded. |
| GOURCE_MAX_FILE_LAG        | 5.0                  | [--max-file-lag] Max time files of a commit can take to appear. Use -1 for no limit.             |
| GOURCE_FILENAME_TIME       | 2                    | [--filename-time] Duration to keep filenames on screen (>= 2.0).                                 |
| GOURCE_FONT_SIZE           | 48                   | [--font-size] Font size for title and date.                                                      |
| GOURCE_FONT_COLOR          | FFFFFF               | [--font-colour] Font color for title and date in hex. (FFFFFF=rgb(255,255,255))                  |
| GOURCE_BACKGROUND_COLOR    | 000000               | [--background-colour] Background color in hex.                                                   |
| GOURCE_DATE_FORMAT         | %m/%d/%Y %H:%M:%S    | [--date-format] Date Format (based on strftime format)                                           |
| GOURCE_DIR_DEPTH           | 3                    | [--dir-name-depth] Draw names of directories down to a specific depth in the tree.               |
| GOURCE_BLOOM_MULTIPLIER    | 1.2                  | [--bloom-multiplier] Adjust the amount of bloom. (>= 0.0)                                        |
| GOURCE_BLOOM_INTENSITY     | 0.75                 | [--bloom-intensity] Adjust the intensity of the bloom. (>= 0.0)                                  |
| GOURCE_PADDING             | 1.1                  | [--padding] Camera view padding (between 0.0-2.0 exclusive)                                      |
| GOURCE_HIGHLIGHT_ALL_USERS | 1                    | [--highlight-users] Keeps all contributing user's names visible.                                 |
| GOURCE_MULTI_SAMPLING      | 1                    | [--multi-sampling] Enables anti-aliasing multi-sampling for smoother edges                       |
| GOURCE_SHOW_KEY            | 1                    | [--key] Enables the file extension key legend                                                    |

##### Caption Specific Settings

| Variable                | Default Value | Description                                       |
| ----------------------- | ------------- | ------------------------------------------------- |
| GOURCE_CAPTION_SIZE     | 48            | [--caption-size] Caption font size.               |
| GOURCE_CAPTION_COLOR    | FFFFFF        | [--caption-colour] Caption color in hex.          |
| GOURCE_CAPTION_DURATION | 5.0           | [--caption-duration] Caption duration in seconds. |

##### Border Template Specific Settings

| Variable                       | Default Value | Description                                                    |
| ------------------------------ | ------------- | -------------------------------------------------------------- |
| GOURCE_BORDER_TITLE_FONT_SIZE  | 48            | [--font-size] Font size for title                              |
| GOURCE_BORDER_DATE_FONT_SIZE   | 60            | [--font-size] Font size for date                               |
| GOURCE_BORDER_TITLE_TEXT_COLOR | FFFFFF        | [--font-colour] Font color for Title (FFFFFF=rgb(255,255,255)) |
| GOURCE_BORDER_DATE_FONT_COLOR  | FFFFFF        | [--font-colour] Font Color for Date (FFFFFF=rgb(255,255,255))  |

##### Experimental Gource Settings

| Variable                 | Default Value | Description                                                                                 |
| ------------------------ | ------------- | ------------------------------------------------------------------------------------------- |
| USE_GOURCE_NIGHTLY       | 0             | Flag to use nightly (master branch) [gource]. Enables pre-release configs in this table.    |
| GOURCE_FILE_EXT_FALLBACK | 0             | [--file-extension-fallback] Use filename as extension if the extension is missing or empty. |

## Troubleshooting

- If you receive this error:
  ```
  convert: no decode delegate for this image format `IMAGE' @ error/constitute.c/ReadImage/556.
  convert: no images defined `/visualization/logo_txfrmed.image' @ error/convert.c/ConvertImageCommand/3273.
  ```
  This means the image logo passed into the docker container is not compatible with the image converter onboard. Try using another format or image.

[gource]: https://github.com/acaudwell/Gource
[envisaged]: https://github.com/utensils/Envisaged
[ffmpeg_home]: https://www.ffmpeg.org/
[xvfb]: https://www.x.org/archive/X11R7.6/doc/man/man1/Xvfb.1.xhtml
[mesa]: https://www.mesa3d.org/llvmpipe.html
[ffmpeg_h265]: https://trac.ffmpeg.org/wiki/Encode/H.265