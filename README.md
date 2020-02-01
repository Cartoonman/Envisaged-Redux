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




[gource]: https://github.com/acaudwell/Gource
[envisaged]: https://github.com/utensils/Envisaged
[ffmpeg_home]: https://www.ffmpeg.org/
[xvfb]: https://www.x.org/archive/X11R7.6/doc/man/man1/Xvfb.1.xhtml
[mesa]: https://www.mesa3d.org/llvmpipe.html
[ffmpeg_h265]: https://trac.ffmpeg.org/wiki/Encode/H.265