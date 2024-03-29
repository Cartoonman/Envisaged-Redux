#!/bin/bash
declare -a tmp_api_dict=()

# Runtime Args
_tmp_api_dict+=( \
    RUNTIME_LIVE_PREVIEW \
    RUNTIME_PRINT_VARS \
    RUNTIME_RECURSE_SUBMODULES \
    RUNTIME_TEMPLATE \
    RUNTIME_COLOR_GROUPS \
)

# Render Args
_tmp_api_dict+=( \
    RENDER_CODEC \
    RENDER_FPS \
    RENDER_H264_CRF \
    RENDER_H265_CRF \
    RENDER_H264_PRESET \
    RENDER_H265_PRESET \
    RENDER_INVERT_COLORS \
    RENDER_VIDEO_RESOLUTION \
    RENDER_PROFILE \
    RENDER_LEVEL \
    RENDER_VERBOSE \
    RENDER_NO_PROGRESS \
)

# Preview Args
_tmp_api_dict+=( \
    PREVIEW_SLOWDOWN_FACTOR \
)

# Color Groups Args
_tmp_api_dict+=( \
    COLOR_GROUPS_SEED \
    COLOR_GROUPS_CENTER_COLOR \
)

# Gource General Args
_tmp_api_dict+=( \
    GOURCE_AUTO_SKIP_SECONDS \
    GOURCE_BACKGROUND_COLOR \
    GOURCE_BLOOM_INTENSITY \
    GOURCE_BLOOM_MULTIPLIER \
    GOURCE_CAMERA_MODE \
    GOURCE_DATE_FORMAT \
    GOURCE_DIR_COLOR \
    GOURCE_DIR_FONT_SIZE \
    GOURCE_DIR_NAME_DEPTH \
    GOURCE_DIR_NAME_POSITION \
    GOURCE_DISABLE_AUTO_ROTATE \
    GOURCE_ELASTICITY \
    GOURCE_FILE_EXTENSIONS \
    GOURCE_FILE_EXTENSION_FALLBACK \
    GOURCE_FILE_FONT_SIZE \
    GOURCE_FILE_IDLE_TIME \
    GOURCE_FILENAME_COLOR \
    GOURCE_FILENAME_TIME \
    GOURCE_FOLLOW_USER \
    GOURCE_FONT_COLOR \
    GOURCE_FONT_SCALE \
    GOURCE_FONT_SIZE \
    GOURCE_HIDE_ITEMS \
    GOURCE_HIGHLIGHT_COLOR \
    GOURCE_HIGHLIGHT_USERS \
    GOURCE_HIGHLIGHT_DIRS \
    GOURCE_MAX_FILE_LAG \
    GOURCE_MAX_FILES \
    GOURCE_MAX_USER_SPEED \
    GOURCE_MULTI_SAMPLING \
    GOURCE_NO_TIME_TRAVEL \
    GOURCE_PADDING \
    GOURCE_REALTIME \
    GOURCE_SECONDS_PER_DAY \
    GOURCE_SELECTION_COLOR \
    GOURCE_SHOW_KEY \
    GOURCE_START_DATE \
    GOURCE_START_POSITION \
    GOURCE_STOP_AT_TIME \
    GOURCE_STOP_DATE \
    GOURCE_STOP_POSITION \
    GOURCE_TIME_SCALE \
    GOURCE_TITLE \
    GOURCE_USER_FRICTION \
    GOURCE_COLOR_IMAGES \
    GOURCE_USER_FONT_SIZE \
    GOURCE_USER_SCALE \
)

# Captions
_tmp_api_dict+=( \
    GOURCE_CAPTION_COLOR \
    GOURCE_CAPTION_DURATION \
    GOURCE_CAPTION_OFFSET \
    GOURCE_CAPTION_SIZE \
)

# Border Gource Args
_tmp_api_dict+=( \
    GOURCE_BORDER_DATE_COLOR \
    GOURCE_BORDER_DATE_SIZE \
    GOURCE_BORDER_TITLE_COLOR \
    GOURCE_BORDER_TITLE_SIZE \
)

declare -gA _api_dict=()
for var in "${_tmp_api_dict[@]}"; do
    _api_dict[${var}]=1
done
unset _tmp_api_dict