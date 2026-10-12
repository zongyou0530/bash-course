#先看有沒有員十檔存在

if [ ! -e "report.txt" ]; then
    echo "沒有原始黨"
    exit 1
fi

# 備份檔在不在
if [ ! -e "report.bak" ]; then
    cp "report.txt" "report.bak"
    echo "建立一個備份"
    
# 原 newer than 輩分黨
elif [ "report.txt" -nt "report.bak" ]; then
    cp "report.txt" "report.bak"
    echo "更新備份"

# 輩分黨 newer than 遠使黨
elif [ "report.txt" -ot "report.bak" ]; then
    echo "哈哈不用備份"

else
    echo "兩個的改的時間相同，不用來輩分"
fi
