for i in {1..9}
do
    for j in {1..9}
    do
        echo "print('$i x $j =', $i * $j)" | python
    done
done
