#!/bin/bash

if [ $# -lt  1 ]; then
	echo "Utilizare: $0 fisier_vechi [fisier_nou]"
	exit 1
fi

FILE1=$1
FILE2=$2

# fisierele temporare stau intr-un director separat, sters automat la iesire
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

TEMP_LS_1="$TMP_DIR/ls_1.txt"
TEMP_DF_1="$TMP_DIR/df_1.txt"
TEMP_LS_2="$TMP_DIR/ls_2.txt"
TEMP_DF_2="$TMP_DIR/df_2.txt"
DIFF_REZ="$TMP_DIR/diff.txt"

process_input() {
	INPUT_SOURCE=$1
	OUT_LS=$2
	OUT_DF=$3

	CLEAN_CONTENT=$(cat "$INPUT_SOURCE" | col -b | sed -E "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")
	echo "$CLEAN_CONTENT" | grep "^[-d]........." | awk '{ $1=$2=$3=$4=$5=$6=$7=$8=""; sub(/^ +/, ""); print }' > "$OUT_LS"
	echo "$CLEAN_CONTENT" | grep "^/dev" > "$OUT_DF"
}

if [ ! -f "$FILE1" ]; then
	echo "Eroare: $FILE1 nu exista"
	exit 1
fi
process_input "$FILE1" "$TEMP_LS_1" "$TEMP_DF_1"

if [ -z "$FILE2" ]; then
	ls -l > "$TMP_DIR/current.raw"
	df >> "$TMP_DIR/current.raw"
	process_input "$TMP_DIR/current.raw" "$TEMP_LS_2" "$TEMP_DF_2"
else
	if [ ! -f "$FILE2" ]; then
		echo "Eroare: $FILE2 nu exista."
		exit 1
	fi
	process_input "$FILE2" "$TEMP_LS_2" "$TEMP_DF_2"
fi

echo "Raport monitorizare :"

diff "$TEMP_LS_1" "$TEMP_LS_2" > "$DIFF_REZ"

echo "Fisiere/directoare sterse :"
grep "^<" "$DIFF_REZ" | sed 's/^< //'

echo ""
echo "Fisiere/directoare noi : "
grep "^>" "$DIFF_REZ" | sed 's/^> //'

echo ""
echo "Modificari spatiu disc : "
diff "$TEMP_DF_1" "$TEMP_DF_2" > "$DIFF_REZ"
if [ -s "$DIFF_REZ" ]; then 
	grep "^<" "$DIFF_REZ" | while read -r line; do echo "Inainte : ${line#< }"; done	
	grep "^>" "$DIFF_REZ" | while read -r line; do echo "Acum : ${line#> }"; done
else
	echo "Nicio modificare majora pe disc" 
fi

exit 0
