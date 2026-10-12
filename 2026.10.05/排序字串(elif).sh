read -p "請輸入第一個字串: " STR1
read -p "請輸入第二個字串: " STR2
read -p "請輸入第三個字串: " STR3


if [ -z "STR1"]||[-z"STR2" ] || [ -z "$STR3" ]; then
    echo "大錯特錯在搞什麼：字串不能為空！"
    exit 1
fi


if [ "STR1"="STR2" ] || [ "STR1"="STR3" ] || [ "STR2"="STR3" ]; then
    echo "大錯特錯你在搞什麼：字串不能有重複！"
    exit 1
fi


if [[ "STR1"<"STR2" ]] && [[ "STR1"<"STR3" ]]; then
    MIN="$STR1"
    if [[ "STR2"<"STR3" ]]; then
        MID="$STR2"
        MAX="$STR3"
    else
        MID="$STR3"
        MAX="$STR2"
    fi
elif [[ "STR2"<"STR1" ]] && [[ "STR2"<"STR3" ]]; then
    MIN="$STR2"
    if [[ "STR1"<"STR3" ]]; then
        MID="$STR1"
        MAX="$STR3"
    else
        MID="$STR3"
        MAX="$STR1"
    fi
else
    MIN="$STR3"
    if [[ "STR1"<"STR2" ]]; then
        MID="$STR1"
        MAX="$STR2"
    else
        MID="$STR2"
        MAX="$STR1"
    fi
fi


echo "最小的是: $MIN"
echo "中間的是: $MID"
echo "最大的是: $MAX"
