#使用elif

CORRECT_USER="zongyou"
CORRECT_PASS="5267"


read -p "請輸入帳號: " USERNAME
read -p "請輸入密碼: " PASSWORD


if [ -z "USERNAME"]||[-z"PASSWORD" ]; then
    echo "USERNAME OR PASSWORD CANNOT BE EMPTY."


elif [ "USERNAME"="CORRECT_USER" ] && [ "PASSWORD"="CORRECT_PASS" ]; then
    echo "LOGIN SUCCESSFUL."


elif [ "USERNAME"!="CORRECT_USER" ]; then
    echo "INVALID USERNAME."


else
    echo "INCORRECT PASSWORD."
fi
