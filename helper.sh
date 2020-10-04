OUTFILE="t${TEST}_output"
re='^[0-9]+$'

echo "Running Test ${TEST} ..."
echo -e "-------------------------------------------"

rm -f $OUTFILE
echo -e "./receiver $OUTFILE $TIMEOUT"
(./receiver $OUTFILE $TIMEOUT | while read line; do echo "Terminal output: Receiver: 	$line"; done) &

sleep 1

echo -e "\nChecking if port file is created..."
if [[ -f "port" ]]; then
	echo -e "port file exists in current directory! port: $(cat port)\n"
fi

echo -e "./sender localhost $(<port) $PAYLOAD_SZ $INFILE"
./sender localhost $(<port) $PAYLOAD_SZ $INFILE | while read line; do echo "Terminal output: Sender: 	$line"; done

# sleep for the timeout value
sleep $((($TIMEOUT / 1000) + 1))

if [ "$(jobs -r)" ]; then
	echo "Timeout value exceeded: killing job"
	pkill %1
else
	if ! [[ $INFILE =~ $re ]]; then
		echo "Comparing ${INFILE} with $OUTFILE"
		if cmp -s "${INFILE}" "$OUTFILE"; then
			echo "Match!"
		else
			echo "NOT Match! (could be UDP packet losses or reordering)"
		fi
	else
		echo "Expecting:     $INFILE bytes"
		if [[ -f "t${TEST}_output" ]]; then
			FILESIZE=$(stat -c%s "t${TEST}_output")
			echo "Actual:     $FILESIZE bytes"
			if [ "$INFILE" -eq "$FILESIZE" ]; then
				echo "Match!"
			else
				echo "NOT Match! (could be UDP packet losses, reordering, or timeout)"
			fi
		else
			echo "Error, reciever did not write to t${TEST}_output."
		fi
	fi

fi

echo -e "----------------------------------------------\n\n\n"
