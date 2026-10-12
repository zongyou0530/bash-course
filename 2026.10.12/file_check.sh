#先輸入
read -p "請輸入 " file


#是否存在 –e
if [ -e "$file" ]; then
echo "exist"
else
echo "nonono"
fi


#是一般檔案 -f 還是目錄 –d
if [ -f "$file" ]; then
echo "一般檔案喔"
else
echo "這不識一班檔案"
fi

if [ -d "$file" ]; then
echo "這是目錄"
else
echo "這不識目錄"
fi


#是否為 symbolic link –L
if [ -l "$file" ]; then
echo "是symbolic link"
else
echo "哭哭不是symbolic link"
fi

#是否可讀 –r
if [ -r "$file" ]; then
echo "可讀喔"
else
echo "哭哭不可讀"
fi


#是否可寫 –w
if [ -w "$file" ]; then
echo "可寫"
else
echo "哭哭不可寫"
fi


#是否可執行 -x
if [ -x "$file" ]; then
echo "讚啦可以執行"
else
echo "哭哭不可執行"
fi
