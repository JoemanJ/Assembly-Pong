UPPER="$1"
nasm -f obj -o ${UPPER^^}.OBJ -l ${UPPER^^}.LST $1.asm