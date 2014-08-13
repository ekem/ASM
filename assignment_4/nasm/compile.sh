NAME="$1"
if [ -z "$NAME" ]; then
	NAME="hello"
fi
nasm -f elf -gdwarf -l $NAME.lst $NAME.asm
