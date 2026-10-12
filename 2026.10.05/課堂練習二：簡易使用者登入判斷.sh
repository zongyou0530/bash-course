CORRECT_USER="zongyou"
CORRECT_PASS="5267"

read -p "請輸入帳號: " USERNAME
read -p "請輸入密碼: " PASSWORD

if [ -z "USERNAME"]||[-z"PASSWORD" ]; then
    echo "USERNAME OR PASSWORD CANNOT BE EMPTY."
else
    if [ "USERNAME"="CORRECT_USER" ]; then
        if [ "PASSWORD"="CORRECT_PASS" ]; then
            echo "LOGIN SUCCESSFUL."
        else
            echo "INCORRECT PASSWORD."
        fi
    else
        echo "INVALID USERNAME."
    fi
fi
