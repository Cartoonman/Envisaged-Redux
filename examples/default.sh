#!/bin/bash
ARGS=""
while [[ $# -gt 0 ]]; do
    k="$1"

    case $k in 
        --git-repo)
            GIT_REPO=$2
            shift
        ;;
        --caption-file)
            CAPTION_URI="--mount type=bind,source=$2,target=/visualization/captions.txt,readonly"
            shift
        ;;
        -h)
            echo "Args:"
            echo "  --git-repo [absolute_path_to_repo]                Required"
            echo "  --caption-file [absolute_path_to_caption_file]    Optional"
            exit 1
        ;;
        --help)
            echo "Args:"
            echo "  --git-repo [absolute_path_to_repo]                Required"
            echo "  --caption-file [absolute_path_to_caption_file]    Optional"
            exit 1
        ;;
        *)
            ARGS="${ARGS} $1"
        ;;
    esac
    shift
done

if [ "${GIT_REPO}" = "" ]; then
    echo "Error: --git_repo argument required."
    exit 1
fi

docker run --rm \
-p 8080:80 \
--name envisaged-redux \
-v ${GIT_REPO}:/visualization/git_repo:ro \
${CAPTION_URI} \
$ARGS \
envisaged-redux:latest