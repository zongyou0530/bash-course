today=$(date +%Y-%m-%d)

echo "今天是: $today"

number1="台幣多少"
echo -n $number1
read number1

echo"日幣=`expr $number1 \* 5 `"
echo"美元=`expr $number1 \* 3 / 100 `"
echo"歐元=`expr $number1 \* 3 / 100 `"
