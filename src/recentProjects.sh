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

# 调用函数
expanded_path=$(is_path "$QUERY")
ret=$?

if [ $ret -eq 0 ]; then
    # 输入是路径（~/xxx 或者 /xxx），expanded_path 是完整绝对路径
    if [[ -d "$expanded_path" ]]; then
        # 文件夹存在，直接返回Alfred item
        echo '{"items": [
        {
            "uid": "",
            "type": "",
            "title": "Your Search exists",
            "subtitle": "'"$QUERY"'",
            "arg": "",
            "autocomplete": "",
        }]}'
    else
        # 路径格式合法，但文件夹不存在
        echo '{"items": [
        {
            "uid": "",
            "type": "",
            "title": "Your Search does not exist",
            "subtitle": "try another search",
            "arg": "",
            "icon": {
                "path": "./warning.png"
            },
            "autocomplete": "",
        }]}'
    fi
else
    # 普通关键词，执行mdfind搜索
    # Search Recent Projects
    get_vscode_recent_alfred "$QUERY"
fi




