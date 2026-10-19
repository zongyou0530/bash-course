read -p "請輸入成績" score
if [ "$score" -ge 90 ]; then
echo "gradeA"
elif [ "$score" -ge 80 ]; then
echo "gradeB"
elif [ "$score" -ge 70 ]; then
echo "gradeC"
elif [ "$score" -ge 60 ]; then
echo "gradeD"
else
echo "gradeF"
fi


