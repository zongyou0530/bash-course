#!/bin/bash
# grade.sh - 學生數學成績輸入與統計系統

total=0        # 合法學生總人數
invalid=0      # 非法資料筆數
cntAplus=0
cntA=0
cntB=0
cntC=0
cntF=0
pass=0         # 通過人數
max=-1         # 目前最高分

echo "===== 學生數學成績系統 (學號輸入 END 結束) ====="

while true
do
    read -p "請輸入學生學號: " id

    # 結束條件
    if [ "$id" = "END" ]; then
        break
    fi

    # 判斷科系 (case)
    case $id in
        E*) dept="Electrical Engineering" ;;
        C*) dept="Computer Science" ;;
        M*) dept="Mechanical Engineering" ;;
        *)
            echo "Invalid student ID"
            invalid=$((invalid + 1))
            continue
            ;;
    esac

    read -p "請輸入數學成績: " score

    # 檢查是否為純數字（負數、小數、文字都會被擋下）
    case $score in
        ""|*[!0-9]*)
            echo "Invalid score"
            invalid=$((invalid + 1))
            continue
            ;;
    esac

    # 避免超長數字或前導 0 造成問題
    if [ ${#score} -gt 3 ]; then
        echo "Invalid score"
        invalid=$((invalid + 1))
        continue
    fi
    score=$((10#$score))

    # 範圍檢查
    if [ "$score" -lt 0 ] || [ "$score" -gt 100 ]; then
        echo "Invalid score"
        invalid=$((invalid + 1))
        continue
    fi

    # 成績等級 (case)
    case $score in
        9[0-9]|100) grade="A+"; cntAplus=$((cntAplus + 1)) ;;
        8[0-9])     grade="A";  cntA=$((cntA + 1)) ;;
        7[0-9])     grade="B";  cntB=$((cntB + 1)) ;;
        6[0-9])     grade="C";  cntC=$((cntC + 1)) ;;
        *)          grade="F";  cntF=$((cntF + 1)) ;;
    esac

    # 更新統計
    total=$((total + 1))

    if [ "$score" -ge 60 ]; then
        pass=$((pass + 1))
    fi

    if [ "$score" -gt "$max" ]; then
        max=$score
    fi

    # 顯示該學生資料
    echo "學號: $id | 科系: $dept | 成績: $score | 等級: $grade"
    echo "目前最高分: $max"
    echo "-----------------------------------"
done

# 顯示最終統計
echo
echo "========== 統計結果 =========="

if [ "$total" -eq 0 ]; then
    echo "No valid student data."
    echo "非法資料筆數: $invalid"
else
    echo "總合法學生人數: $total"
    echo "非法資料筆數: $invalid"
    echo "A+ 人數: $cntAplus"
    echo "A  人數: $cntA"
    echo "B  人數: $cntB"
    echo "C  人數: $cntC"
    echo "F  人數: $cntF"
    echo "最高分: $max"
    echo "通過人數: $pass"

    # pass >= total/2  等價於  pass*2 >= total（避免整數除法誤差）
    if [ $((pass * 2)) -ge "$total" ]; then
        echo "Class Status: PASS"
    else
        echo "Class Status: NEED IMPROVEMENT"
    fi
fi
