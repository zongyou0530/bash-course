if [ $# -ne 3 ]; then
    echo "：OECELAB NUM1 NUM2 NUM3"
    exit 1
fi



a=$1
b=$2
c=$3



if [ $a -gt $b ] && [ $a -gt $c ]; then
    temp=$a
    a=$c
    c=$temp
elif [ $b -gt $a ] && [ $b -gt $c ]; then
    temp=$b
    b=$c
    c=$temp
fi



if [ $a -gt $b ]; then
    temp=$a
    a=$b
    b=$temp
fi



if [ $a -le 0 ] || [ $a -ge $((b + c)) ]; then
    echo "這哪是三角形要三個邊"
    exit 0
fi



sum=$((a * a + b * b))
max=$((c * c))

if [ $sum -eq $max ]; then
    type="直角"
elif [ $sum -gt $max ]; then
    type="銳角"
else
    type="鈍角"
fi
echo $type
