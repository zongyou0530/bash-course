這份程式是 Bash 學生程式檔案管理系統（Student Program File Management System）。

我會按照你目前「計算機與實務應用（Bash）」的學習方式整理，從最基礎的語法開始，不假設你已經熟悉 Bash。

這次分成六大部分：
1. 今日使用的語法與英文單字總整理
2. 程式整體架構與執行流程
3. 逐行程式碼解釋
4. 重要語法深入拆解（符號、括號、引號）
5. 實際執行範例
6. 考試重點與容易搞混的地方
第一部分：今日使用的語法與字詞
先不要急著看程式碼，先認識今天會出現的所有語法。
1. Bash 基礎語法
語法	中文意思	用途
#!/bin/bash	指定 Bash	告訴系統使用 Bash 執行
#	註解	讓程式設計者閱讀，不執行
'=	指定變數	將資料存入變數
$	變數取值	取得變數裡的內容
"$變數"	雙引號	保留變數內容中的空格
local	區域變數	宣告函數內使用的變數
()	小括號	定義陣列、算術運算等
{}	大括號	定義函數、變數展開等
;	分號	分隔同一行的指令
\	反斜線	跳脫特殊字元
`	`	管線符號 | 將前一個指令輸出傳給下一個指令

2. 輸入與輸出
語法	中文意思	用途
echo	輸出	顯示文字
printf	格式化輸出	顯示提示文字等
read	讀取	接收使用者輸入
read -r	原樣讀取	不將反斜線當作跳脫字元
'-p	Prompt	在讀取輸入時顯示提示（本程式沒有使用 read -p）

3. 條件判斷
語法	中文意思	用途
if	如果	開始條件判斷
then	那麼	條件成立時執行
elif	否則如果	增加條件
else	否則	前面條件都不成立時執行
fi	結束 if	結束條件判斷
case	多重條件	根據不同內容執行不同指令
in	符合	開始列出 case 的比對模式
esac	結束 case	結束 case 判斷
&&	並且	兩個條件都必須成立（本程式未使用）
!	反向	將判斷結果反轉
'=~	正規表示式比對	檢查輸入是否符合指定格式

4. 檔案判斷語法
這次有一個很重要的觀念：Bash 可以直接檢查檔案的狀態。
語法	中文意思	判斷條件
'-e	Exists	檔案或路徑是否存在
'-f	Regular File	是否為一般檔案
'-r	Readable	是否具有讀取權限
'-gt	Greater Than	是否大於
'-eq	Equal	是否等於

注意：-e、-f、-r 是檔案測試運算子，而 -gt、-eq 是數值比較運算子。
5. 函數、選單與迴圈
語法	中文意思	用途
function_name()	函數	定義一組可以重複使用的程式
return	返回	結束函數
while	當……時	重複執行
true	永遠為真	搭配 while 建立無限迴圈
select	選單	自動建立編號選單
PS3	選單提示字串	設定 select 的提示文字
break	跳出	結束目前迴圈
break 2	跳出兩層	同時跳出兩層迴圈
exit	離開程式	結束整個 Shell 程序
[@]	陣列全部元素	取得陣列所有元素
${}	變數展開	取得變數或陣列內容

6. 數學與字串處理
語法	中文意思	用途
[[ ]]	Bash 條件判斷	進行較進階的條件判斷
[ ]	測試條件	進行一般條件判斷
'=~	正規表示式	比對輸入格式
^	開頭	正規表示式中代表字串開頭
$	結尾	正規表示式中代表字串結尾
[0-9]	數字範圍	代表 0 到 9
'+	一個以上	正規表示式中代表前一個元素至少出現一次
$(( ))	算術運算	執行整數數學運算
10#	十進位指定	將數字視為十進位，避免前導 0 問題
>>	附加寫入	將資料寫入檔案末尾


第二部分：程式整體架構
在逐行閱讀之前，先理解這個程式究竟要做什麼。

這個系統總共有五個功能：
學生程式檔案管理系統
主選單（select）

使用者選擇功能編號


1. check file

檢查檔案是否存在、是否為一般檔案、是否可讀取


2. check department

根據學號第一個英文字母判斷系所


3. show grade

檢查成績格式並轉換成等第


4. save result

將學生資料附加寫入 result 檔案



5. exit

結束程式


整體程式可以分成：
區塊	功能
開頭	指定 Bash 執行環境
選單設定	設定提示文字與選項
check_file	檢查檔案
check_department	判斷系所
show_grade	判斷成績
save_result	儲存資料
主選單	重複顯示選單、處理使用者選擇

接下來正式逐行解釋。

第三部分：逐行程式碼解釋
一、程式開頭與選單設定
原始程式碼：
#!/bin/bash
# 學生程式檔案管理系統

PS3="請選擇功能 (輸入編號): "
options=("check file" "check department" "show grade" "save result" "exit")


第 1 行
#!/bin/bash


這一行稱為 Shebang。
- #!：告訴作業系統，接下來要指定執行程式。
- /bin/bash：Bash Shell 的執行檔位置。
意思是：

請使用 Bash 來執行這份程式。
第 2 行
# 學生程式檔案管理系統


# 是註解符號。

這一行只是讓程式設計者知道這份程式的用途。

不會被執行。
第 3 行
PS3="請選擇功能 (輸入編號): "


這一行是設定 select 選單的提示文字。

先認識：
- PS3：Bash 內建的選單提示變數。
- =：指定內容。
- "..."：雙引號，將整段文字視為字串。
當執行 select 時，就會出現：
請選擇功能 (輸入編號):


注意：

PS3 是 Bash 專門提供給 select 使用的提示變數，不是一般自己隨意命名的變數。
第 4 行
options=("check file" "check department" "show grade" "save result" "exit")


這一行建立一個叫做 options 的陣列（Array）。

陣列就是：

在同一個變數中，儲存多筆資料。

例如：
options=("apple" "banana" "orange")


代表陣列裡面有三個元素。

本程式的陣列內容：
編號	陣列內容
1	check file
2	check department
3	show grade
4	save result
5	exit

為什麼使用小括號？
options=(...)


在 Bash 中，小括號可以用來建立陣列。

為什麼每個選項要加雙引號？
"check file"


因為 check file 中間有空格。

如果沒有妥善處理空格，可能會被拆成兩個不同的元素。

重點：Bash 陣列的索引從 0 開始，但 select 顯示的選單編號從 1 開始。

二、check_file()：檢查檔案
原始程式碼：
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


這個功能的目的：

讓使用者輸入檔案名稱，然後判斷檔案狀態。
第 1 行
check_file() {


這是在定義函數（Function）。

函數的概念：

把一組指令包裝起來，未來只要呼叫函數名稱，就能執行裡面的程式。

例如：
hello() {
    echo "Hello"
}


呼叫：
hello


就會顯示：
Hello


這裡：
- check_file：函數名稱。
- ()：表示函數定義。
- {：函數內容開始。
第 2 行
local fname


宣告一個區域變數。
- local：區域變數。
- fname：變數名稱。
為什麼使用 local？

因為這個變數只需要在 check_file 函數裡使用。

假設其他函數也有一個叫做 fname 的變數，使用 local 可以避免不必要的變數互相影響。
第 3 行
printf "請輸入程式檔案名稱: "


顯示提示文字。

這裡使用 printf 而不是 echo。

兩者差別：
echo	printf
直接輸出文字	格式化輸出
使用簡單	格式控制能力較強
預設會換行	不會自動換行

因此這裡使用 printf，讓游標停留在提示文字後面，等待輸入。
第 4 行
read -r fname


接收使用者輸入。

拆開來看：
- read：讀取使用者輸入。
- -r：不要將反斜線 \ 解讀為跳脫字元。
- fname：將輸入內容存進 fname 變數。
例如使用者輸入：
test.sh


就會得到：
fname="test.sh"


第 5 行
if [ ! -e "$fname" ]; then


這一行非常重要。

它是在檢查檔案是否存在。

先看結構：
if [ 條件 ]; then
    指令
fi


拆開：
部分	意思
if	開始判斷
[	開始測試條件
!	反轉判斷結果
'-e	檢查路徑是否存在
"$fname"	要檢查的檔案名稱
]	結束測試條件
then	條件成立後執行

特別注意：
[ ! -e "$fname" ]


意思是：

如果檔案不存在。

為什麼？

因為：
-e "$fname"


代表檔案存在。

而前面加上：
!


就會反過來。

所以：
指令	判斷
[ -e "$fname" ]	存在
[ ! -e "$fname" ]	不存在

另外，[ 和 ] 前後必須保留空格。

這不是裝飾，而是 Shell 語法的一部分。
第 6 行
echo "file not found"


如果檔案不存在，就顯示：
file not found


第 7 行
elif [ ! -f "$fname" ]; then


elif 就是 else if。

意思是：

如果前面的條件不成立，再檢查另一個條件。

這裡：
-f "$fname"


代表是否為一般檔案。

例如：
路徑	'-f 結果
test.sh	True（一般檔案）
report.txt	True（一般檔案）
一般資料夾	False
不存在的檔案	False

前面加上 !：
! -f


就是不是一般檔案。
第 8 行
echo "not a regular file"


如果路徑存在，但不是一般檔案，就顯示：
not a regular file


例如使用者輸入資料夾名稱：
Documents


就可能得到這個結果。
第 9 行
elif [ ! -r "$fname" ]; then


這次檢查的是讀取權限。

-r：

Readable，代表是否可以讀取。

因此：
[ ! -r "$fname" ]


意思是：

檔案不可讀取。
第 10 行
echo "not readable"


如果檔案沒有讀取權限，就顯示：
not readable


第 11～12 行
else
    echo "file ok"


如果前面的三種情況都沒有發生，就代表：
1. 檔案存在。
2. 是一般檔案。
3. 可以讀取。
因此顯示：
file ok


第 13 行
fi


fi 是 if 的結束標記。

可以把它理解為：
if 開始
    條件判斷
fi 結束


第 14 行
}


函數結束。
check_file 判斷流程
輸入檔案名稱

-e 檔案存在嗎？

否

file not found


是

繼續檢查




-f 是一般檔案嗎？

否 → not a regular file；是 → 繼續

-r 可以讀取嗎？

否 → not readable；是 → file ok


三、check_department()：判斷學生系所
原始程式碼：
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


這個功能是根據學生學號第一個字母，判斷所屬系所。
第 1～4 行
check_department() {
    local sid
    printf "請輸入學生學號: "
    read -r sid


與上一個函數類似。

差別是這次使用：
local sid


sid 是 Student ID 的縮寫，也就是學生學號。
第 5 行
case $sid in


這裡使用 case。

case 是多重條件判斷。

如果使用 if，可能要寫很多個 elif。

但是使用 case，可以直接列出不同模式。

基本格式：
case 變數 in
    條件1)
        指令1
        ;;
    條件2)
        指令2
        ;;
    *)
        預設指令
        ;;
esac


注意：
- case：開始。
- in：開始列出條件。
- )：條件結束，後面開始執行指令。
- ;;：結束目前條件。
- esac：結束 case。
第 6 行
[eE]*) echo "electrical engineering" ;;


這是本函數最重要的一行。

先拆解：
[eE]*


這是一種 Shell 萬用字元模式（Pattern）。
符號	意思
[eE]	第一個字元必須是 e 或 E
*	後面可以接任意數量的字元

因此：

以下輸入都符合：
E123456
e123456
EABC


如果符合，就執行：
echo "electrical engineering"


第 7 行
[cC]*) echo "computer science" ;;


第一個字母是：
- c
- C
就顯示：
computer science


第 8 行
[mM]*) echo "mechanical engineering" ;;


第一個字母是：
- m
- M
就顯示：
mechanical engineering


第 9 行
*) echo "invalid student id" ;;


這個 * 是預設條件。

如果前面三個條件都不符合，就執行這一行。

例如：
A123456
123456
X123456


都會顯示：
invalid student id


第 10～11 行
esac
}


esac 結束 case。

} 結束函數。
case 系所判斷表
學號開頭	執行結果
E 或 e	electrical engineering
C 或 c	computer science
M 或 m	mechanical engineering
其他	invalid student id



四、show_grade()：成績判斷
這是整份程式中比較困難的部分。

因為同時使用：
- 輸入驗證
- 正規表示式
- 數學運算
- 數字比較
- case 多重判斷
原始程式碼：
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


第 1～4 行
show_grade() {
    local score
    printf "請輸入數學成績 (0-100): "
    read -r score


宣告一個區域變數：
local score


score 就是成績。

接著使用 printf 顯示提示，再透過 read 接收輸入。

例如：
請輸入數學成績 (0-100): 85


這時：
score="85"


第 5 行：最重要的正規表示式
if [[ ! $score =~ ^[0-9]+$ ]]; then


這行看起來很複雜，我們拆成五個部分。

第一部分：[[ ]]
[[ 條件 ]]


這是 Bash 的條件判斷語法。

與之前的：
[ 條件 ]


有些不同。

[[ ]] 是 Bash 提供的進階條件測試結構，支援正規表示式 =~。

第二部分：!
! $score


這裡的 ! 代表反向判斷。

第三部分：=~
$score =~ 正規表示式


代表檢查左邊的資料是否符合右邊的格式。

第四部分：^[0-9]+$

這才是最需要記住的部分。
符號	意思
^	字串開頭
[0-9]	0 到 9 的任意一個數字
'+	前面的數字至少出現一次
$	字串結尾

合在一起：
^[0-9]+$


意思是：

整個字串必須由一個以上的數字組成。

例如：
輸入	符合嗎？	原因
85	符合	純數字
100	符合	純數字
0	符合	純數字
'-10	不符合	有負號
85.5	不符合	有小數點
abc	不符合	英文字母
8a	不符合	混合文字
空白	不符合	沒有數字

第五部分：整句的意思
if [[ ! $score =~ ^[0-9]+$ ]]; then


翻譯：

如果使用者輸入的內容不是純數字，就進入 if。
第 6～7 行
echo "invalid score"
return


如果輸入不是純數字：
1. 顯示 invalid score。
2. 使用 return 結束目前函數。
這裡要特別注意：

return 和 exit 不一樣。
指令	意思
return	結束目前函數
exit	結束整個 Shell 程式

例如：
show_grade


如果輸入錯誤，return 只會讓 show_grade 結束，主選單仍然可以繼續使用。
第 8 行：數字轉換
score=$((10#$score))


這是整份程式最值得理解的地方之一。

先認識：
$(( ))


這是 Bash 的算術運算。

例如：
a=10
b=20
c=$((a+b))
echo "$c"


輸出：
30


那麼為什麼這裡要寫：
10#$score


原因是前導 0。

例如使用者輸入：
085


有些 Bash 算術表示法會將以 0 開頭的數字視為八進位數字。

但是我們的成績應該是十進位。

因此：
10#085


意思是：

將 085 強制視為十進位。

所以：
score=$((10#$score))


可以將輸入轉成十進位整數。

例如：
原始輸入	轉換後
085	85
009	9
100	100
000	0

這裡還有一個細節：

因為前面已經確認輸入是純數字，所以才適合進行這項算術轉換。
第 9 行
if [ "$score" -gt 100 ]; then


檢查成績是否超過 100。

-gt 是 Greater Than。

意思是大於。

例如：
[ 101 -gt 100 ]


結果為 True。
[ 90 -gt 100 ]


結果為 False。

這裡的完整意思：

如果成績大於 100，就判定為無效。

注意：這份程式沒有檢查成績小於 0，因為前面已經透過正規表示式排除負號了。
第 10～11 行
echo "invalid score"
return


如果分數超過 100：

顯示錯誤並結束函數。
第 12 行
case $score in


開始根據成績判斷等第。
第 13 行
100|9[0-9]) echo "a+" ;;


這裡有一個新的符號：
|


在 case 模式裡，| 代表「或」。

因此：
100|9[0-9])


意思是：

符合 100 或 90～99。

其中：
9[0-9]


代表：

90、91、92、93、94、95、96、97、98、99。

符合就輸出：
a+


第 14 行
8[0-9]) echo "a" ;;


代表 80～89。

輸出：
a


第 15 行
7[0-9]) echo "b" ;;


代表 70～79。

輸出：
b


第 16 行
6[0-9]) echo "c" ;;


代表 60～69。

輸出：
c


第 17 行
*) echo "f" ;;


其他情況全部輸出：
f


例如：

- 0～59。
第 18～19 行
esac
}


結束 case 與函數。
成績對照表
數學成績	輸出
90～100	a+
80～89	a
70～79	b
60～69	c
0～59	f
負數、小數、文字、大於 100	invalid score

show_grade 的完整判斷順序
1. 使用者輸入成績
2. 檢查是否為純數字 ^[0-9]+$
3. 不是純數字 → invalid score，return
4. 轉換成十進位整數 10#
5. 檢查是否大於 100
6. 大於 100 → invalid score，return
7. 透過 case 判斷等第
8. 輸出 a+、a、b、c 或 f


五、save_result()：儲存學生資料
原始程式碼：
save_result() {
    local sid score fname
    printf "請輸入學生學號: "
    read -r sid
    printf "請輸入數學成績: "
    read -r score
    printf "請輸入程式檔名: "
    read -r fname

    echo "$sid $score $fname" >> result
    echo "result saved"
}


這個功能的目的：

將學生的學號、成績與程式檔名儲存到 result 檔案。
第 1 行
save_result() {


定義函數。
第 2 行
local sid score fname


一次宣告三個區域變數。

相當於：
local sid
local score
local fname


三個變數分別代表：
變數	意思
sid	學生學號
score	數學成績
fname	程式檔案名稱

第 3～4 行
printf "請輸入學生學號: "
read -r sid


顯示提示並讀取學號。
第 5～6 行
printf "請輸入數學成績: "
read -r score


讀取數學成績。
第 7～8 行
printf "請輸入程式檔名: "
read -r fname


讀取程式檔名。
第 9 行：非常重要
echo "$sid $score $fname" >> result


這一行負責儲存資料。

先看：
echo "$sid $score $fname"


假設使用者輸入：
E123456
85
main.sh


這行會組合成：
E123456 85 main.sh


接下來：
>> result


代表將輸出附加寫入 result 檔案。

>> 與 > 的差別：
符號	功能	原本檔案內容
>	覆蓋寫入	會被清空
>>	附加寫入	會保留

例如第一次執行：
echo "E123456 85 main.sh" >> result


result 內容：
E123456 85 main.sh


第二次執行：
echo "C123456 90 test.sh" >> result


result 內容：
E123456 85 main.sh
C123456 90 test.sh


這就是附加寫入。

另外，如果 result 不存在，Shell 會嘗試自動建立它。
第 10 行
echo "result saved"


顯示儲存成功訊息。
第 11 行
}


函數結束。

注意：這個函數目前沒有檢查輸入是否合法，也沒有確認檔案寫入是否成功。它只是直接把三筆輸入組合後寫入 result。

六、主選單：整份程式最重要的控制結構
這個部分負責把前面四個功能串起來。

原始程式碼：
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


這裡同時使用 while、select、case、break。
1. while true
while true; do


while 是迴圈。

意思是只要條件成立，就不斷執行。

而：
true


代表永遠成立。

因此：
while true; do


就是建立一個無限迴圈。

為什麼要使用無限迴圈？

因為我們希望使用者執行完某個功能後，可以再次回到選單。

例如：
1. check file
輸入 test.sh
file ok

再次顯示選單


如果沒有 while，選單不會自動重複。
2. picked=0
picked=0


建立一個變數 picked，初始值為 0。

它的用途是：

判斷使用者有沒有真正進入 select 的迴圈本體。

這個變數不是 Bash 的特殊變數，而是程式設計者自己設定的。

為什麼要這樣做？

因為使用者可能按下 Ctrl+D，讓輸入結束。

這時 select 不會正常取得選項，因此需要另外判斷。
3. select 選單
select choice in "${options[@]}"; do


這是整份程式的核心。

select 可以自動建立編號選單。

首先：
choice


代表使用者選擇的變數。

而：
in


表示接下來提供選項。

最重要的是：
"${options[@]}"


拆解：
部分	意思
$	取出變數
{}	變數展開
options	陣列名稱
[@]	取得所有陣列元素
"	保留每個元素的完整內容

為什麼要使用 [@]？

因為 options 是陣列，我們需要把裡面的所有選項交給 select。

例如：
options=("apple" "banana" "orange")


使用：
select choice in "${options[@]}"; do


就會產生：
1) apple
2) banana
3) orange


而使用者輸入：
2


此時：
choice="banana"


注意：select 裡面的 choice 是選項的內容，不是編號。

編號會另外存在於 Bash 的 REPLY 變數中。
4. picked=1
picked=1


代表：

使用者已經進入 select 迴圈本體。

因此將 picked 從 0 改成 1。

這是為了後面判斷 Ctrl+D。
5. case $choice
case $choice in


判斷使用者選擇了哪一個功能。

例如：

如果選擇：
1


那麼：
choice="check file"


接下來就會比對：
"check file")


6. 五個功能的對應
"check file") check_file ;;


意思是：

如果 choice 等於 check file，就呼叫 check_file 函數。

其他功能也是同樣的概念：
使用者選擇	呼叫函數
check file	check_file
check department	check_department
show grade	show_grade
save result	save_result
exit	結束程式

這就是函數與主選單的連結方式。
7. exit 選項
"exit")
    echo "goodbye"
    break 2
    ;;


這裡有一個非常重要的語法：
break 2


先理解一般的 break：
break


代表跳出目前所在的迴圈。

但是現在有兩層結構：
while true; do

    select choice in ...; do

    done

done


所以：
語法	意思
break	跳出一層
break 2	跳出兩層

因此：
break 2


會同時跳出：
1. select
2. while
整個程式就結束了。

這裡也可以注意：

break 2 不等於 exit。

它是離開兩層迴圈，不是直接結束 Shell 程序。
8. invalid selection
*)
    echo "invalid selection"
    ;;


這是預設條件。

如果使用者輸入不符合任何選項，就顯示：
invalid selection


例如輸入：
9


或其他不存在的選項。
9. esac
esac


結束 case。
10. 第二個 break
break


這個 break 非常重要。

為什麼前面已經有 break 2，這裡又要有 break？

因為這裡的目的不同。

一般選擇功能時：
1. 執行功能。
2. 跳出 select。
3. 回到 while。
4. 重新顯示選單。
所以這裡只需要：
break


跳出 select 就好。

而：
break 2


是用在使用者選擇 exit 時，直接跳出兩層迴圈。
11. done
done


結束 select 迴圈。
12. picked 的判斷
if [ "$picked" -eq 0 ]; then


這裡檢查：

picked 是否等於 0。

-eq 是 Equal，代表數值相等。

因為：
picked=0


代表使用者沒有成功進入 select 的迴圈本體。

這種情況可能發生在 Ctrl+D。
第 13～15 行
echo
echo "goodbye"
break


如果使用者按 Ctrl+D：
1. 顯示空白行。
2. 顯示 goodbye。
3. 跳出 while 迴圈。
最後一行
done


結束 while。

第四部分：最容易搞混的語法比較
這一部分建議你特別熟悉，因為這份程式有很多相似但不同的符號。
1. [ ] 與 [[ ]]
比較	[ ]	[[ ]]
用途	一般條件測試	Bash 進階條件測試
支援 -e	是	是
支援 -gt	是	是
支援 =~	否	是
本程式用途	檔案與數字判斷	正規表示式

記憶：
- [ ]：一般條件。
- [[ ]]：進階條件，尤其是正規表示式。
2. > 與 >>
符號	意思	範例
>	覆蓋寫入	echo hello > a.txt
>>	附加寫入	echo hello >> a.txt

考試常考！
3. break、break 2、return、exit
語法	用途
break	跳出一層迴圈
break 2	跳出兩層迴圈
return	結束函數
exit	結束整個 Shell 程序

這四個一定要分清楚。
4. case 中的 * 與 [0-9]
語法	意思
*	任意字元序列
[0-9]	任意一個數字
[eE]	e 或 E
9[0-9]	90～99
100\|9[0-9]	100 或 90～99

注意：在 case 裡的 * 是 Shell Pattern，不是正規表示式中的 *。兩者概念相似，但規則不完全一樣。
5. "$變數" 與 $變數
建議一般情況都養成加雙引號的習慣：
echo "$fname"


而不是：
echo $fname


原因是避免變數內容中的空格被拆開。

例如：
fname="my program.sh"


加上雙引號：
echo "$fname"


會完整輸出：
my program.sh



第五部分：實際執行範例
現在假設我們在 Webminal 或 Linux 終端機執行這份程式。
範例一：檢查檔案
請選擇功能 (輸入編號):
1) check file
2) check department
3) show grade
4) save result
5) exit
#? 1

請輸入程式檔案名稱: test.sh
file ok


執行過程：
1. select 收到 1。
2. choice 變成 check file。
3. case 找到 check file。
4. 呼叫 check_file。
5. 檢查 test.sh。
6. 顯示 file ok。
7. break 跳出 select。
8. 回到 while，重新顯示選單。
範例二：判斷系所
#? 2

請輸入學生學號: E123456
electrical engineering


因為 E 符合 [eE]*。
範例三：成績判斷
#? 3

請輸入數學成績 (0-100): 85
a


因為：
8[0-9]


代表 80～89。
範例四：錯誤成績
#? 3

請輸入數學成績 (0-100): 85.5
invalid score


因為：
^[0-9]+$


不接受小數點。
範例五：儲存資料
#? 4

請輸入學生學號: E123456
請輸入數學成績: 85
請輸入程式檔名: main.sh
result saved


result 檔案內容：
E123456 85 main.sh


範例六：離開
#? 5

goodbye


因為執行：
break 2


跳出 select 和 while。

第六部分：考試重點整理
以下是這份程式最值得背熟的語法。
今日 Bash 考試重點
1. 函數定義
function_name() {
    指令
}



2. 條件判斷
if [ 條件 ]; then
    指令
elif [ 條件 ]; then
    指令
else
    指令
fi



3. 多重條件
case $variable in
    條件1) 指令 ;;
    條件2) 指令 ;;
    *) 預設指令 ;;
esac



4. 正規表示式
[[ $score =~ ^[0-9]+$ ]]



5. 算術運算
result=$((a+b))



6. 檔案判斷
[ -e "$file" ]
[ -f "$file" ]
[ -r "$file" ]



7. 選單
PS3="請選擇: "
options=("A" "B" "C")

select choice in "${options[@]}"; do
    echo "$choice"
    break
done



8. 迴圈
while true; do
    指令
    break
done



9. 檔案寫入
echo "資料" >> result



10. 函數與迴圈結束
return
break
break 2
exit



最後：今日英文單字表
英文	中文
file	檔案
regular file	一般檔案
readable	可讀取
department	系所
electrical engineering	電機工程
computer science	資訊科學
mechanical engineering	機械工程
student ID	學生學號
score	成績
grade	等第
invalid	無效
selection	選擇
result	結果
save	儲存
function	函數
array	陣列
variable	變數
condition	條件
pattern	模式
regular expression	正規表示式
loop	迴圈
readable permission	讀取權限
append	附加
overwrite	覆蓋
prompt	提示文字
exit	離開


第七部分：自我測驗
我幫你設計 8 題，檢查你是否真的理解這份程式，而不是只有看過解釋。
Bash 語法理解測驗
0/8 已作答

第 1 題：`local fname` 的主要用途是什麼？

A. 建立全域變數

B. 建立函數內的區域變數

C. 讀取檔案

D. 輸出文字



第 2 題：`[ ! -e "$fname" ]` 代表什麼？

A. 檔案存在

B. 檔案可以讀取

C. 檔案不存在

D. 檔案是資料夾



第 3 題：`^[0-9]+$` 可以接受哪一種輸入？

A. 85.5

B. -85

C. 85a

D. 085



第 4 題：`score=$((10#$score))` 的用途是什麼？

A. 轉成八進位

B. 轉成十進位整數

C. 將成績乘以 10

D. 檢查是否大於 100



第 5 題：`>> result` 的用途是什麼？

A. 讀取 result

B. 刪除 result

C. 附加寫入 result

D. 執行 result



第 6 題：`[eE]*` 在 case 中代表什麼？

A. 只能輸入 E

B. 第一個字元是 e 或 E，後面可接任意字元

C. 所有字元都必須是 E

D. 輸入不能有 E



第 7 題：在主選單中，`break 2` 的用途是什麼？

A. 跳出函數

B. 跳出一層迴圈

C. 跳出兩層迴圈

D. 結束電腦



第 8 題：`return` 和 `exit` 最大的差別是什麼？

A. 兩者完全相同

B. return 結束函數，exit 結束 Shell 程序

C. return 結束整個程式，exit 只結束函數

D. return 用來讀檔


提交答案並查看解析
建議學習順序： 先熟悉 if、case、while、select，再理解 [[ ]]、正規表示式與 $(( ))。這些是這份程式最核心的 Bash 知識。

下一步可以把這份程式拆成老師考試可能要求的「填空題、除錯題、手寫程式題」，讓你練習自己從零寫出來。
