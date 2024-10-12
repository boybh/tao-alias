# Define the plugin name and version
declare -r alias_maker_version="1.1.1"
declare -r alias_maker_name="tao-alias"

# Check if Oh My Zsh is installed
if [[ -z "$ZSH" ]]; then
#    echo "Lỗi: Oh My Zsh không được cài đặt trên hệ thống của bạn. Vui lòng cài đặt trước khi sử dụng #plugin 
    $alias_maker_name."
 #   echo "Bạn có thể tải Oh My Zsh từ https://ohmyz.sh"
$    return 1
#fi

# Check if aliases.zsh file exists
if [[ ! -f "/mnt/e/config/cauhinh/aliases.zsh" ]]; then
    echo "Đang tạo file aliases.zsh..."
    touch "/mnt/e/config/cauhinh/aliases.zsh"
fi

# Define the main function for the alias_maker plugin
function am() {
    local subcommand=$1

    case $subcommand in
    -h | --help)
        show_help
        return 0
        ;;
    create_alias)
        amc "$2" "$3" # Thêm tham số thứ hai cho command
        ;;
    delete_alias)
        amd "$2"
        ;;
    -l | --list)
        list_aliases
        ;;
    *)
        echo "Lỗi: Lệnh phụ '$subcommand' không hợp lệ. Sử dụng 'am -h' để biết thêm thông tin." >&2
        return 1
        ;;
    esac
}

# Define a function to create a new zsh alias
function amc() {
    local -r alias_name="$1"
    local -r alias_command="$2"

    # Check if the alias name or command is empty or contains invalid commands
    if [[ $alias_name == *[';\`$']* || $alias_command == *[';\`$']* ]]; then
        echo "Lỗi: Dữ liệu đầu vào không hợp lệ" >&2
        return 1
    fi

    # Check if the alias already exists
    if alias "$alias_name" >/dev/null 2>&1; then
        echo "Lỗi: Alias '$alias_name' đã tồn tại." >&2
        return 1
    fi

    # Create the new alias and save it to the aliases.zsh file
    echo "alias $alias_name=\"$alias_command\"" >> "/mnt/e/config/cauhinh/aliases.zsh"
    source "/mnt/e/config/cauhinh/aliases.zsh"  # Nguồn file aliases.zsh để áp dụng alias ngay lập tức

    # Output the success message
    echo "Alias đã được tạo:"
    echo "Lệnh: \`$alias_name\` sẽ thực thi: \`$alias_command\`"
}

# Delete an existing zsh alias
function amd() {
    local -r alias_name="$1"

    # Check if the alias exists
    if ! alias | grep -q "$alias_name="; then
        echo "Alias '$alias_name' không tồn tại."
        return 1
    fi

    # Delete the alias from aliases.zsh
    sed -i.bak "/alias $alias_name=/d" "/mnt/e/config/cauhinh/aliases.zsh"
    # Remove backup file
    rm /mnt/e/config/cauhinh/aliases.zsh.bak
    # Unset the alias
    unalias $alias_name
    echo "Alias '$alias_name' đã được xóa."
}

# Define a function to list all custom zsh aliases
function list_aliases() {
    local -a aliases=()
    local rc_file="/mnt/e/config/cauhinh/aliases.zsh" # Đường dẫn tới file aliases.zsh

    # Check if aliases.zsh file exists
    if [ ! -f "$rc_file" ]; then
        echo "Không tìm thấy file aliases.zsh." >&2
        return 1
    fi

    # Read the aliases.zsh file and find all aliases
    while read -r line; do
        if [[ $line == alias* ]]; then
            aliases+=("$line")
        fi
    done <"$rc_file"

    # Check if any aliases were found
    if [ ${#aliases[@]} -gt 0 ]; then
        echo "≡ƒöº Các alias tùy chỉnh được tìm thấy trong $rc_file:"
        echo ""

        for alias in "${aliases[@]}"; do
            name="${alias%%=*}"
            command="${alias#*=}"
            name="${name#alias }"
            echo "  - $name ΓåÆ ${command//\'/}"
        done
    else
        echo "Không có alias tùy chỉnh nào được tìm thấy trong $rc_file"
    fi
}

function show_help() {
    echo "Cách sử dụng: am [lệnh phụ]"
    echo "Các lệnh phụ:"
    echo "  amc <alias_name> <alias_command>: Tạo một alias zsh tùy chỉnh mới"
    echo "  amd <alias_name>: Xóa một alias zsh tùy chỉnh hiện có"
    echo "  -h, --help: Hiển thị thông điệp trợ giúp này"
    echo "  -l, --list: Liệt kê tất cả các alias zsh tùy chỉnh được định nghĩa trong file aliases.zsh của bạn"
}

