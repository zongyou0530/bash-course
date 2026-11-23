# 程式逐區塊解釋

我把程式拆成 7 個區塊，每塊先貼程式碼，再說明語法和邏輯。

## 區塊 1：開頭與全域設定

```bash
#!/bin/bash
PS3="請選擇功能 (輸入編號): "
options=("check file" "check department" "show grade" "save result" "exit")
```

| 語法 | 說明 |
|---|---|
| `#!/bin/bash` | shebang，告訴系統用 bash 執行這個檔案。`select` 和 `[[ ]]` 是 bash 的功能，所以不能用 `sh`。 |
| `PS3=` | `select` 專用的提示字串變數，選單印出後顯示在最下面。 |
| `options=( ... )` | 建立陣列，每個元素用引號包起來，因為 `"check file"` 中間有空格，不加引號會被拆成兩個元素。 |

## 區塊 2：check file 函式

```bash
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
```

**語法**
- `check_file() { ... }` 定義函式，呼叫時直接寫 `check_file`，不加括號。
- `local fname` 讓變數只在函式內有效，不污染其他地方。
- `printf` 不會自動換行，所以游標停在提示後面。我不用 `read -p`，是因為 `-p` 在輸入來自管線或檔案時不會顯示提示。
- `read -r` 的 `-r` 表示不處理反斜線跳脫，輸入什麼就存什麼。
- `[ ... ]` 是 `test` 指令，括號內側兩邊**一定要有空格**。
- `"$fname"` 一定要加雙引號，否則檔名有空格或輸入為空時會出錯。

**檔案測試運算子**

| 運算子 | 意義 |
|---|---|
| `-e` | 存在（任何類型，包含目錄） |
| `-f` | 是普通檔案（不是目錄、裝置） |
| `-r` | 目前使用者可讀 |
| `!` | 反相，`! -e` 就是「不存在」 |

**邏輯：檢查的順序不能換**
`if / elif / else` 由上往下，遇到第一個成立的就執行並跳出。
1. 先問「不存在？」是 → `file not found`。
2. 存在才有資格問「不是普通檔案？」例如輸入 `/tmp` 是目錄。
3. 是普通檔案才問「不可讀？」
4. 三關都過才是 `file ok`。

如果把順序倒過來，對不存在的檔案，`-f` 和 `-r` 也會是假，就會顯示錯誤的訊息。

## 區塊 3：check department 函式

```bash
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
```

**case 的語法結構**
```
case 變數 in
    樣式1) 指令 ;;
    樣式2) 指令 ;;
    *)     預設 ;;
esac
```
- `;;` 表示這個分支結束，相當於其他語言的 `break`。
- `esac` 是 `case` 倒著寫，用來結束。
- 樣式用的是**萬用字元（glob）**，不是正規表示式。

**樣式解析**
- `[eE]` 表示一個字元，是 `e` 或 `E`。
- `*` 表示後面接任意長度的任意字元。
- 合起來，`[eE]*` 就是「第一個字母是 e 或 E，後面隨便」，剛好符合「看學號第一個字母」。
- 最後的 `*)` 是預設分支，其他開頭（包含空字串）都會落到這裡。

## 區塊 4：show grade 函式

```bash
show_grade() {
    local score
    printf "請輸入數學成績 (0-100): "
    read -r score

    if [[ ! $score =~ ^[0-9]+$ ]]; then
        echo "invalid score"
        return
    fi

    score=$((10#$score))

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
```

這段分成三步：**驗證格式 → 轉成數字 → 判斷等級**。

**第一步：驗證格式**
- `[[ ... ]]` 是 bash 的加強版測試，支援 `=~`（正規表示式比對）。
- `^[0-9]+$`：`^` 開頭、`[0-9]` 數字、`+` 一個以上、`$` 結尾。意思是「整串都是數字」。
- 所以 `-5`（有負號）、`85.5`（有小數點）、`abc`、空字串都會被擋下，顯示 `invalid score`。這同時處理了「小於 0」的情況，因為負數一定有 `-`。
- `return` 直接離開函式，後面的程式不會再執行。

**第二步：轉成數字**
- `$(( ... ))` 是算術運算。
- `10#` 表示用十進位解讀。bash 會把 `0` 開頭的數字當八進位，所以 `085` 會出錯（8 不是合法的八進位數字）。加上 `10#` 之後 `085` 會變成 `85`。

**第三步：判斷範圍與等級**
- `-gt` 是數字比較「大於」。數字比較用 `-gt -lt -eq -ge -le -ne`，字串比較才用 `= !=`，這是常見考點。
- 因為前面已確認是非負整數，所以只需再檢查 `> 100`。
- case 樣式中的 `|` 表示「或」：`100|9[0-9]` 代表 100 或 90–99。
- `8[0-9]` 比對 80–89，依此類推。
- 預設 `*)` 會接住 0–59 和所有一位數，全部是 `f`。

## 區塊 5：save result 函式

```bash
save_result() {
    local sid score fname
    printf "請輸入學生學號: ";  read -r sid
    printf "請輸入數學成績: ";  read -r score
    printf "請輸入程式檔名: ";  read -r fname

    echo "$sid $score $fname" >> result
    echo "result saved"
}
```

（實際檔案中每個 `printf` 和 `read` 是分行寫的，這裡為了排版並成一行。）

| 語法 | 說明 |
|---|---|
| `local sid score fname` | 一次宣告多個區域變數。 |
| `>>` | **附加**到檔案尾端。檔案不存在會自動建立，已存在則保留原內容。 |
| `>` | 覆蓋，會清掉原內容，所以題目要求「不可覆蓋」時不能用它。 |

`result` 沒有路徑，所以會建立在**執行腳本時所在的目錄**。

## 區塊 6：主選單（本題核心）

```bash
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
                break 2
                ;;
            *)
                echo "invalid selection"
                ;;
        esac

        break
    done

    if [ "$picked" -eq 0 ]; then
        echo
        echo "goodbye"
        break
    fi
done
```

**select 的運作方式**
```
select 變數 in 清單; do
    ...
done
```
1. 把清單印成編號選單（`1) check file` …）。
2. 顯示 `PS3` 提示，等使用者輸入。
3. 輸入的內容存在 `REPLY`；如果是有效編號，`choice` 就被設成對應的選項文字，否則 `choice` 是**空字串**。
4. 執行 `do ... done` 本體。
5. 重複，直到遇到 `break` 或輸入結束（EOF）。

**語法重點**
- `"${options[@]}"` 把陣列每個元素原樣展開，**要加雙引號**，否則 `check file` 會被拆開成 `check` 和 `file`。
- case 的樣式因為有空格，所以要加引號：`"check file")`。
- 輸入 `6`、`0`、`abc` 時 `choice` 是空的，所以落入 `*)`，顯示 `invalid selection`。

**為什麼外面要包 while**
bash 的 `select` 有一個特性：選完一次後，**不會自動重印選單**，只會再顯示 `PS3`。但題目要求選單每次都再出現。解法是：
- 每次處理完功能就執行 `break`，離開 `select`。
- 外層 `while true` 馬上讓 `select` 重新開始，選單就重印了。

**兩個 break 的差別**

| 寫法 | 效果 |
|---|---|
| 最後的 `break` | 只離開 `select`，回到 `while` 重新顯示選單。 |
| `break 2` | 一次離開兩層（`select` 和 `while`），整個程式結束。 |

**picked 旗標的用途**
如果使用者按 Ctrl+D（輸入結束），`select` 會直接結束，根本沒進入本體，`picked` 仍是 0。沒有這個檢查的話，`while true` 會讓程式不斷重印選單，變成無窮迴圈。所以 `picked` 是 0 時就印 `goodbye` 並離開。

## 區塊 7：整體執行流程

```
開始
 └─ while true
     ├─ select 顯示選單，等待輸入
     │    ├─ 1 → check_file
     │    ├─ 2 → check_department
     │    ├─ 3 → show_grade
     │    ├─ 4 → save_result
     │    ├─ 5 → 印 goodbye，break 2 ──→ 結束
     │    └─ 其他 → 印 invalid selection
     ├─ break 回到 while（選單重新出現）
     └─ （Ctrl+D 時 picked=0 → 印 goodbye 結束）
```

## 常見考點整理

1. `[ ]` 的括號內側要有空格，變數要加引號。
2. 數字比較用 `-eq -gt -lt`，字串比較用 `= !=`。
3. `case` 每個分支用 `;;` 結尾，整體用 `esac` 結束，`*)` 當預設。
4. `>` 是覆蓋，`>>` 是附加。
5. `select` 不會自動重印選單，要靠外層迴圈加 `break`。
6. `break 2` 可以一次跳出兩層迴圈。

如果你想，我可以再針對某一段出幾題類似考題，或示範常見錯誤寫法會得到什麼結果。
