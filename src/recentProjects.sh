#!/usr/bin/env bash
source .config
source errors.sh
source utils.sh

QUERY=$1

# Check If App is already installed
if [ ! -r "$APP_PATH" ]; then
  AppNotFound
	exit
fi

# Check If Command Line of App is already installed
if ! cmd_exists "code"; then
  CommandLineNotFound
  exit
fi

# Check Version
VS_VER=$(getVersionInfo)
MIN_VER="1.118.0"
compare_version "$VS_VER" "$MIN_VER"
ret=$?
if [[ $ret -eq 2 ]]; then
  UnSupportVersion
  exit
fi

# # 新路径（v1.118+）
# DB_NEW="$HOME/.vscode-shared/sharedStorage/state.vscdb"
# # 旧路径（<v1.118）
# DB_OLD="$HOME/Library/Application Support/Code/User/globalStorage/state.vscdb"

# # 优先用新库，不存在则切换旧库
# if [ -f "$DB_NEW" ]; then
#     DB="$DB_NEW"
# else
#     DB="$DB_OLD"
# fi

# Search Recent Projects
get_vscode_recent_alfred "$QUERY"


