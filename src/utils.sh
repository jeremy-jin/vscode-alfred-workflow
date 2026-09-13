function checkApp() {
    # Check If App is already installed
    if [ ! -r "$APP_PATH" ]; then
        AppNotFound
	    exit
    fi
}

function getVersionInfo() {
    APP_INFO_PATH=${APP_PATH}'/Contents/Info.plist'
    VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_INFO_PATH")
    echo "$VERSION"
}

function splitVersionInfo() {
    local VERSION="$1"
    ead -r MAJOR_VERSION SUB_VERSION PHASE_VERSION <<< "${VERSION//./ }"
    echo "$MAJOR_VERSION" "$SUB_VERSION" "$PHASE_VERSION"
}


# Check If Shell Command is existing
cmd_exists() {
  local cmd_name="$1"
  command -v "$cmd_name" >/dev/null 2>&1
}

# compare_version
# usage: compare_version "1.23.4" "1.24.1"
# return:
# 0 equal
# 1 v1 > v2
# 2 v1 < v2
compare_version() {
    local v1="$1"
    local v2="$2"
    local IFS=.
    # split into array
    read -ra arr1 <<< "$v1"
    read -ra arr2 <<< "$v2"

    local i=0
    while [[ ${arr1[i]} || ${arr2[i]} ]]; do
        # empty segment treat as 0
        local a=${arr1[i]:-0}
        local b=${arr2[i]:-0}
        if (( a > b )); then
            return 1
        elif (( a < b )); then
            return 2
        fi
        ((i++))
    done
    return 0
}

# getRecentProjects
# Fetch VSCode recent projects, filter by keyword, output Alfred Script Filter JSON
# Param $1: search keyword (empty string to return all items)
get_vscode_recent_alfred() {
    local raw_input="$1"
    local search_key
    search_key=$(echo "$raw_input" | xargs)

    DB="$HOME/.vscode-shared/sharedStorage/state.vscdb"
    STORAGE="$HOME/Library/Application Support/Code/User/globalStorage/storage.json"

    declare -a path_arr=()

    # 读取 sqlite 主数据源
    if [ -f "$DB" ]; then
        RAW=$(sqlite3 "$DB" "SELECT value FROM ItemTable WHERE key = 'history.recentlyOpenedPathsList';")
        if [ -n "$RAW" ]; then
            while IFS= read -r uri; do
                if [ -n "$uri" ]; then
                    local_path=$(echo "$uri" | sed -e 's#^file://##g' -e 's/%20/ /g')
                    path_arr+=("$local_path")
                fi
            done <<< "$(echo "$RAW" | plutil -convert xml1 -o - - | xmllint --nonet --xpath '//key[text()="folderUri"]/following-sibling::string[1]/text()' -)"
        fi
    fi

    # 兜底 storage.json
    if [ ${#path_arr[@]} -eq 0 ] && [ -f "$STORAGE" ]; then
        while IFS= read -r uri; do
            if [ -n "$uri" ]; then
                local_path=$(echo "$uri" | sed -e 's#^file://##g' -e 's/%20/ /g')
                path_arr+=("$local_path")
            fi
        done <<< "$(plutil -convert xml1 -o - "$STORAGE" | xmllint --nonet --xpath '//key[text()="folderUri"]/following-sibling::string[1]/text()' -)"
    fi

    # 兼容bash3.2 数组去重
    declare -a unique_paths=()
    for p in "${path_arr[@]}"; do
        local found=0
        for u in "${unique_paths[@]}"; do
            if [[ "$p" == "$u" ]]; then
                found=1
                break
            fi
        done
        if [ $found -eq 0 ]; then
            unique_paths+=("$p")
        fi
    done

    # 模糊匹配
    declare -a filtered=()
    for p in "${unique_paths[@]}"; do
        base=$(basename "$p")
        base_lower=$(echo "$base" | tr '[:upper:]' '[:lower:]')
        key_lower=$(echo "$search_key" | tr '[:upper:]' '[:lower:]')

        if [[ -z "$search_key" ]]; then
            filtered+=("$p")
        else
            echo "$base_lower" | grep -q -- "$key_lower"
            if [ $? -eq 0 ]; then
                filtered+=("$p")
            fi
        fi
    done

    # ========== Alfred JSON输出，新增 uid type autocomplete ==========
    echo '{"items":['
    first=1
    if [ ${#filtered[@]} -eq 0 ]; then
        cat <<EOF
{"title":"No results found","subtitle":"No matched VSCode recent projects","arg":""}
EOF
    else
        for p in "${filtered[@]}"; do
            if [ $first -eq 1 ]; then
                first=0
            else
                echo ","
            fi
            base=$(basename "$p")
            cat <<EOF
{
	"uid": "$base",
	"type": "project",
	"title": "$base",
	"subtitle": "$p",
	"arg": "$p",
	"autocomplete": "$base"
}
EOF
        done
    fi
    echo ']}'
}


# 判断输入字符串是否是路径（支持 ~ 波浪号展开）
# 返回值：
# 0 = 是路径（包含 / 或者以 ~ 开头）
# 1 = 不是路径
# 输出：标准输出打印【展开后的绝对路径】，如果不是路径则输出空字符串
is_path() {
    local input="$1"
    local expanded_path

    # 情况1：以 ~ 开头：波浪号展开
    if [[ "$input" == ~* ]]; then
        # bash原生波浪号扩展
        expanded_path="${input/#\~/$HOME}"
        echo "$expanded_path"
        return 0
    fi

    # 情况2：以 / 开头，绝对路径
    if [[ "$input" == /* ]]; then
        expanded_path="$input"
        echo "$expanded_path"
        return 0
    fi

    # 其余判定不是路径，输出空，返回1
    echo ""
    return 1
}