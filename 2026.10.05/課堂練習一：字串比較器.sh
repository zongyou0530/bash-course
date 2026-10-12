read -p "第一個字串 " STRING1
read -p "第二個字串 " STRING2


if [ -z "$STRING1" ]; then
    echo "STRING1 是空字串。"
else
    echo "STRING1 不是空字串。"
fi


if [ -z "$STRING2" ]; then
    echo "STRING2 是空字串。"
else
    echo "STRING2 不是空字串。"
fi


if [ "STRING1" = "STRING2" ]; then
    echo "兩個相同。"
else
    echo "兩個不相同。"


    if [[ "STRING1" < "STRING2" ]]; then
        echo "在字典順序中，STRING1 ('$STRING1') 較前面。"
    else
        echo "在字典順序中，STRING2 ('$STRING2') 較前面。"
    fi
fi
