#!/bin/bash
# 學生程式檔案管理系統

PS3="請選擇功能 (輸入編號): "
options=("check file" "check department" "show grade" "save result" "exit")

# ---------- check file ----------
check_file() {
    local fname
    printf "請輸入程式檔案名稱: "
    read -r fname

    if [ ! -e "$fname" ]; then
        echo "file not found"
    elif [ ! -f "$fname" ]; then
        echo "not a regular file"
    elif [ ! -r "$fname" ]; then
        echo "not readable"
    else
        echo "file ok"
    fi
}

# ---------- check department ----------
check_department() {
    local sid
    printf "請輸入學生學號: "
    read -r sid

    case $sid in
        [eE]*) echo "electrical engineering" ;;
        [cC]*) echo "computer science" ;;
        [mM]*) echo "mechanical engineering" ;;
        *)     echo "invalid student id" ;;
    esac
}

# ---------- show grade ----------
show_grade() {
    local score
    printf "請輸入數學成績 (0-100): "
    read -r score

    # 必須是非負整數 (負數、小數、文字都視為 invalid score)
    if [[ ! $score =~ ^[0-9]+$ ]]; then
        echo "invalid score"
        return
    fi

    score=$((10#$score))        # 去掉前導 0，避免 "085" 被當成八進位

    if [ "$score" -gt 100 ]; then
        echo "invalid score"
        return
    fi

    case $score in
        100|9[0-9]) echo "a+" ;;
        8[0-9])     echo "a"  ;;
        7[0-9])     echo "b"  ;;
        6[0-9])     echo "c"  ;;
        *)          echo "f"  ;;
    esac
}

# ---------- save result ----------
save_result() {
    local sid score fname
    printf "請輸入學生學號: "
    read -r sid
    printf "請輸入數學成績: "
    read -r score
    printf "請輸入程式檔名: "
    read -r fname

    # >> 為附加寫入：result 不存在會自動建立，已存在則接在最後面
    echo "$sid $score $fname" >> result
    echo "result saved"
}

# ---------- 主選單 ----------
# bash 的 select 在選完後不會自動重印選單，
# 所以外面包一層 while，每次處理完就 break 讓 select 重新開始。
while true; do
    picked=0

    select choice in "${options[@]}"; do
        picked=1

        case $choice in
            "check file")        check_file ;;
            "check department")  check_department ;;
            "show grade")        show_grade ;;
            "save result")       save_result ;;
            "exit")
                echo "goodbye"
                break 2          # 同時跳出 select 與 while
                ;;
            *)
                echo "invalid selection"
                ;;
        esac

        break                    # 回到 while，重新顯示選單
    done

    # select 沒進入過迴圈本體 = 輸入結束 (Ctrl+D)，避免無窮迴圈
    if [ "$picked" -eq 0 ]; then
        echo
        echo "goodbye"
        break
    fi
done
