# Envisaged-Redux - Dockerized Gource Visualizations

A fork of James Brink's excellent Envisaged docker container.

Built on top of [`utensils/opengl:stable`][utensils/opengl] (Alpine 3.10). **No GPU is required**, this will run on any machine, such as a standard EC2 instance or any other VPS.  

## About

Painless data visualizations from git history showing a repositories development progression over time.  
This container combines the awesome [Gource][gource] program with the power of [FFmpeg][ffmpeg_home] and the h.265 codec to bring you high resolution (up to 4k at 60fps) video visualizations.

This container is 100% headless, it does this by leveraging [Xvfb][xvfb] combined with the [Mesa 3d Gallium llvmpipe Driver][mesa]. Unlike other docker containers with Gource, this container does not eat up 100's of gigabtyes of disk space, nor does it require an actual GPU to run. The process runs the Gource simulation concurrently with the FFmpeg encoding process using a set of named pipes. There is a slight trade off in performance, but this makes it very easy to run in any environment such as AWS without the need to provision large amounts of storage, or run any cleanup.  

Envisaged uses "template" scripts to generate specific looks, such as the one included in this container which is simply called **border** which places a frame around the Gource visualization and isolates the date and key on the outside of this border. If you would like to run the container with normal Gource output, simply pass `-e TEMPLATE=none` and it will use the `no_template.sh` script.



This container is configurable through environment variables listed below. The generated video is delivered via HTTP.


## Usage Example
Running a visualization against a local git repo.  

```
docker run --rm -p 8080:80 --name envisaged \
       -v /path/to/your/repo:/visualization/git_repo:ro \
       -e GOURCE_TITLE="Your Project Development" \
       utensils/envisaged
```

You can also combine multiple repositories into a single rendering by mounting a directory of repository
directories onto `/visualization/git_repos` (the plural of `visualization/git_repo`).

```
docker run --rm -p 8080:80 --name envisaged \
       -v /path/to/your/repos:/visualization/git_repos:ro \
       -e GOURCE_TITLE="Your Project Development" \
       utensils/envisaged
```

Optionally, you can have gource render avatars of the authors by mounting a volume with images of the authors.

```
docker run --rm -p 8080:80 --name envisaged \
       -v /path/to/your/repo:/visualization/git_repo:ro \
       -v /path/to/your/avatars:/visualization/avatars:ro \
       -e GOURCE_TITLE="Your Project Development" \
       utensils/envisaged
```

The avatars in that directory must have filenames that match the author id, e.g. `utensils.gif`, etc.

Now open your browser to <http://localhost:8080/> and once the video is completed you will see the link with the video size.

## Environment Variables

| Variable                   | Default Value            | Description                                                                                                                           |
| -------------------------- | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| `LOGO_URL`                 | ``                       | URL of logo to be overlayed in lower right hand corner of video.                                                                      |
| `H265_PRESET`              | `medium`                 | h.265 encoding preset. Refer to [FFmpeg's wiki][ffmpeg_h265].                                                                         |
| `H265_CRF`                 | `21`                     | The Constant Rate Factor (CRF). Refer to [FFmpeg's wiki][ffmpeg_h265].                                                                |
| `VIDEO_RESOLUTION`         | `1080p`                  | Output video resolution, options are **2160p, 1440p, 1080p, 720p, 480p**                                                              |
| `FPS`                      | `60`                     | Output video Frames per Second. Supported framerates are 25,30, or 60 only.                                                           |
| `TEMPLATE`                 | `border`                 | This is the template script that will be run. Options are **border**, and **none**.                                                   |
| `RECURSE_SUBMODULES`       | `0`                      | If set to 1, enables recursing through the repo(s) submodules                                                                       |
| `GOURCE_TITLE`             | `Software Development`   | [--title] Title to be displayed in the lower left hand corner of video.                                                               |
| `GOURCE_DATE_FONT_COLOR`   | `FFFFFF`                 | [--font-colour] Font Color for Date (for border template)                                                                             |
| `GOURCE_TITLE_TEXT_COLOR`  | `FFFFFF`                 | [--font-colour] Font color for Title (for border template)                                                                            |
| `GOURCE_CAMERA_MODE`       | `overview`               | [--camera-mode] Camera mode (overview, track).                                                                                        |
| `GOURCE_SECONDS_PER_DAY`   | `0.1`                    | [--seconds-per-day] Speed of simulation in seconds per day.                                                                           |
| `GOURCE_TIME_SCALE`        | `1.0`                    | [--time-scale] Change simulation time scale.                                                                                          |
| `GOURCE_USER_SCALE`        | `1.0`                    | [--user-scale] Change scale of user avatars.                                                                                          |
| `GOURCE_AUTO_SKIP_SECONDS` | `3.0`                    | [--auto-skip-seconds] Skip to next entry if nothing happens for a number of seconds.                                                  |
| `GOURCE_BACKGROUND_COLOR`  | `000000`                 | [--background-colour] Background color in hex.                                                                                        |
| `GOURCE_HIDE_ITEMS`        | `mouse,date,filenames`   | [--hide] Hide one or more display elements (border template does not need date)                                                       |
| `GOURCE_FILE_IDLE_TIME`    | `0.0`                    | [--file-idle-time] Time in seconds files remain idle before they are removed or 0 for no limit.                                       |
| `GOURCE_MAX_FILES`         | `0`                      | [--max-files] Set the maximum number of files or 0 for no limit. Excess files will be discarded.                                      |
| `GOURCE_MAX_FILE_LAG`      | `5.0`                    | [--max-file-lag] Max time files of a commit can take to appear. Use -1 for no limit.                                                  |
| `GOURCE_TITLE_FONT_SIZE`   | `48`                     | [--font-size] Font size for title (for border template)                                                                               |
| `GOURCE_DATE_FONT_SIZE`    | `60`                     | [--font-size] Font size for date (for border template)                                                                                |
| `GOURCE_DIR_DEPTH`         | `3`                      | [--dir-name-depth] Draw names of directories down to a specific depth in the tree.                                                    |
| `GOURCE_FILENAME_TIME`     | `2`                      | [--filename-time] Duration to keep filenames on screen (>= 2.0).                                                                      |
| `GOURCE_MAX_USER_SPEED`    | `500`                    | [--max-user-speed] Max speed users can travel per second.                                                                             |
| `INVERT_COLORS`            | `false`                  | Inverts the colors on the visualization.                                                                                              |
| `GLOBAL_FILTERS`           | ``                       | Global FFmpeg filter options.                                                                                                         |
| `GOURCE_FILTERS`           | ``                       | Gource scene FFmpeg filter options.                                                                                                   |
| `GOURCE_DATE_FORMAT`       | `%m/%d/%Y %H:%M:%S`      | Date Format (based on strftime format)                                                                                                |
| `GOURCE_START_DATE`        | ``                       | [--start-date] Start with the first entry after the supplied date and optional time. (see [gource] docs for formats)                  |
| `GOURCE_STOP_DATE`         | ``                       | [--stop-date] Stop after the last entry prior to the supplied date and optional time. (see [gource] docs for formats)                 |
| `GOURCE_START_POSITION`    | ``                       | [--start-position] Begin at some position in the log (between 0.0 and 1.0 or 'random').                                               |
| `GOURCE_STOP_POSITION`     | ``                       | [--stop-position] Stop at some position in the log.                                                                                   |
| `GOURCE_STOP_AT_TIME`      | ``                       | [--stop-at-time] Stop after a specified number of seconds.                                                                            |
| `GOURCE_PADDING`           | `1.1`                    | [--padding] Camera view padding (between 0.0-2.0 exclusive)                                                                           |
| `GOURCE_CAPTION_SIZE`      | `48`                     | [--caption-size] Caption font size.                                                                                                   |
| `GOURCE_CAPTION_COLOR`     | `FFFFFF`                 | [--caption-colour] Caption color in hex.                                                                                              |
| `GOURCE_CAPTION_DURATION`  | `5.0`                    | [--caption-duration]  Caption duration in seconds.                                                                                    |


[alpine linux image]: https://github.com/gliderlabs/docker-alpine

[gource]: https://github.com/acaudwell/Gource

[ffmpeg_home]: https://www.ffmpeg.org/

[xvfb]: https://www.x.org/archive/X11R7.6/doc/man/man1/Xvfb.1.xhtml

[mesa]: https://www.mesa3d.org/llvmpipe.html

[ffmpeg_h265]: https://trac.ffmpeg.org/wiki/Encode/H.265

[utensils/opengl]: https://github.com/utensils/docker-opengl

[elixir-school]: https://github.com/elixirschool/elixirschool
