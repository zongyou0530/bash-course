#!/bin/bash

read -r -p "請輸入學生學號: " id

if [ -z "$id" ]; then
    echo "錯誤：學號不得為空字串！"
    exit 1
fi

read -r -p "請輸入數學成績: " score
read -r -p "請輸入程式檔案名稱: " filename

first_char="${id:0:1}"

case "$first_char" in
    E)
        dept="ELECTRICAL ENGINEERING"
        ;;
    C)
        dept="COMPUTER SCIENCE"
        ;;
    M)
        dept="MECHANICAL ENGINEERING"
        ;;
    *)
        echo "錯誤：非法的學號！"
        exit 1
        ;;
esac

case "$score" in
    ''|*[!0-9]*)
        echo "錯誤：成績必須是 0 到 100 之間的整數！"
        exit 1
        ;;
esac

score_num="${score#"${score%%[!0]*}"}"

if [ -z "$score_num" ]; then
    score_num=0
fi

if [ "${#score_num}" -gt 3 ] || [ "$score_num" -gt 100 ]; then
    echo "錯誤：成績必須介於 0 到 100 之間！"
    exit 1
fi

case "$score_num" in
    100|9[0-9])
        grade="A+"
        comment="EXCELLENT"
        ;;
    8[0-9])
        grade="A"
        comment="VERY GOOD"
        ;;
    7[0-9])
        grade="B"
        comment="GOOD"
        ;;
    6[0-9])
        grade="C"
        comment="PASS"
        ;;
    *)
        grade="F"
        comment="FAIL"
        ;;
esac

expected_name="${id}.SH"

if [ "$filename" != "$expected_name" ]; then
    echo "錯誤：程式檔名必須是 $expected_name！"
    exit 1
fi

if [ ! -e "$filename" ]; then
    echo "錯誤：程式檔案不存在！"
    exit 1
elif [ ! -f "$filename" ]; then
    echo "錯誤：程式檔案不是普通檔案！"
    exit 1
elif [ ! -r "$filename" ]; then
    echo "錯誤：程式檔案不可讀取！"
    exit 1
fi

out_file="GRADE"

if [ -e "$out_file" ]; then
    read -r -p "GRADE 已存在，請輸入新的輸出檔名: " out_file

    if [ -z "$out_file" ] || [ "$out_file" = "GRADE" ] || [ -d "$out_file" ]; then
        echo "錯誤：輸出檔名不合法，請再輸入一次。"
        read -r -p "請輸入新的輸出檔名: " out_file

        if [ -z "$out_file" ] || [ "$out_file" = "GRADE" ] || [ -d "$out_file" ]; then
            echo "錯誤：輸出檔名仍不合法，程式結束。"
            exit 1
        fi
    fi
fi

result="
學生學號：$id
學生科系：$dept
數學成績：$score_num
成績等級：$grade
評語：$comment
程式檔名：$filename
"

if printf '%s\n' "$result" | tee -a "$out_file"; then
    echo "資料已儲存至 $out_file"
else
    echo "錯誤：無法寫入輸出檔案！"
    exit 1
fi
