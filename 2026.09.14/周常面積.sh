echo "長多少"
read length

echo "寬多少"
read width

area=`expr $length \* $width`
perimeter=`expr \( $length + $width \) \* 2`

echo "面積是: $area"
echo "周長是: $perimeter"
