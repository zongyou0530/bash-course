# 1. 讀取使用者輸入
read -p "請輸入學號: " id
read -p "請輸入數學成績: " score
read -p "請輸入程式檔案名稱: " filename

# 檢查學號是否為空
if [ -z "$id" ]; then
    echo "錯誤：學號不得為空字串！"
    exit 1
fi

# 2. 透過 case 判斷科系 (取學號的第一個字元)[cite: 3]
first_char=$(echo "$id" | cut -c1)
case "$first_char" in
    E) dept="ELECTRICAL ENGINEERING" ;;[cite: 3]
    C) dept="COMPUTER SCIENCE" ;;[cite: 3]
    M) dept="MECHANICAL ENGINEERING" ;;[cite: 3]
    *) 
       echo "錯誤：非法的科系代號！"[cite: 3]
       exit 1
       ;;
esac

# 3. 檢查成績範圍並透過 case 判斷等級與評語[cite: 3]
if [ "$score" -ge 0 ] && [ "$score" -le 100 ]; then[cite: 3]
    case "$score" in
        100|9[0-9]) grade="A+"; comment="EXCELLENT" ;;[cite: 3]
        8[0-9])    grade="A";  comment="VERY GOOD" ;;[cite: 3]
        7[0-9])    grade="B";  comment="GOOD" ;;[cite: 3]
        6[0-9])    grade="C";  comment="PASS" ;;[cite: 3]
        *)         grade="F";  comment="FAIL" ;;[cite: 3]
    esac
else
    echo "錯誤：成績必須介於 0 到 100 之間！"[cite: 3]
    exit 1
fi

# 4. 檢查程式檔名與屬性[cite: 3]
expected_name="${id}.SH"
if [ "$filename" != "$expected_name" ]; then
    echo "錯誤：檔名不符合規定（必須為 學號.SH）！"[cite: 3]
    exit 1
fi

if [ ! -e "$filename" ]; then
    echo "錯誤：檔案不存在！"[cite: 3]
    exit 1
elif [ ! -f "$filename" ]; then
    echo "錯誤：不是普通的檔案！"[cite: 3]
    exit 1
elif [ ! -r "$filename" ]; then
    echo "錯誤：檔案無法讀取 (不可讀)！"[cite: 3]
    exit 1
elif [ ! -x "$filename" ]; then
    echo "錯誤：檔案無法執行 (不可執行)！"[cite: 3]
    exit 1
fi

# 5. 處理輸出檔名[cite: 3]
out_file="GRADE"
if [ -e "$out_file" ]; then
    if [ -d "$out_file" ]; then
        echo "錯誤：GRADE 是一個已存在的目錄！"[cite: 3]
        exit 1
    fi
    read -p "GRADE 檔案已存在，請輸入新的輸出檔名: " out_file
    if [ -z "$out_file" ] || [ "$out_file" = "GRADE" ] || [ -d "$out_file" ]; then
        echo "錯誤：新的輸出檔名不合法！"[cite: 3]
        exit 1
    fi
fi

# 6. 【BBBBBBBB】取得當前系統時間戳記並整合結果
current_time=$(date "+%Y-%m-%d %H:%M:%S")

result_str="[審核時間: $current_time] 學號: $id | 科系: $dept | 數學成績: $score | 等級: $grade | 評語: $comment | 程式檔名: $filename"

# 同時寫入指定輸出檔並顯示在畫面上[cite: 3]
echo "$result_str" | tee -a "$out_file"
echo "處理完成！結果已成功寫入 $out_file"
