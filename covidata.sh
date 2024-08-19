#/bin/bash

errorMsg() {
	echo
	echo "Error: $1"
	echo
	echo "Stript syntax: $2"
	echo
	echo "Legal usage examples:"
	echo "./covidata.sh get 35 data.csv result.csv"
	echo "./covidata.sh -r get 35 2020-01 2020-03 data.csv result.csv"
	echo "./covidata.sh compare 10 data.csv result2.csv result.csv"
	echo "./covidata.sh -r compare 10 2020-01 2020-03 data.csv result2.csv result.csv"
	exit
}

getRows(){
	currentFile=$1
	pasteFile=$2

	if [ -f fileWithM.csv ]
        then
            rm fileWithM.csv
        fi

	if [ -f $pasteFile ]
        then
            rm $pasteFile
        fi

	if grep -q ^$id $currentFile
	then
		grep ^$id $currentFile | awk 'BEGIN {FS=","} { print $0 }' >> fileWithM.csv
		sed -e "s/\r//g" fileWithM.csv > $pasteFile
		rm fileWithM.csv
	else
		errorMsg "ID number does not exist in the given file" "$scriptSyntax"
	fi
}	

computeStats(){
	currentFile=$1
	rowcount=`cat $currentFile | awk 'BEGIN {FS=","; count=0} {count++} END{print count}'`
	if [[ $rowcount -eq 0 ]]
	then
		rowcount=0
		avgconf=0
		avgdeaths=0
		avgtests=0
	else
		conf=`cat $currentFile | awk 'BEGIN {FS=","; conf=0} {conf+=$6} END{print conf}'`
		avgconf=$(( conf / rowcount ))

        deaths=`cat $currentFile | awk 'BEGIN {FS=","; deaths=0} {deaths+=$8} END{print deaths}'`
        avgdeaths=$(( deaths / rowcount ))

        tests=`cat $currentFile | awk 'BEGIN {FS=","; tests=0} {tests+=$11} END{print tests}'`
		avgtests=$(( tests / rowcount ))
	fi
}

getDateRows(){
	fileForAwk=$1
	fileFromAwk=$2
	fileSTATS=$3
	startYear=${startDate:0:4}
	startMonth=${startDate:5:2}
	endYear=${endDate:0:4}
	endMonth=${endDate:5:2}
	
	numMonths="$(( ( $endMonth + 12 * ( $endYear - $startYear ) ) - $startMonth ))"
	currentNumMonth=0

	startDay="1"
	endDay="15"

	if [[ -f $fileFromAwk ]]
	then
		rm $fileFromAwk
	fi

        if [[ -f $fileSTATS ]]
        then
            rm $fileSTATS
        fi 
	
	if [[ -f awkOutput.csv ]]
        then
		rm awkOutput.csv
        fi

	while [[ "$currentNumMonth" -le "$numMonths" ]] && [[ "$startYear" -le "$endYear" ]]
	do
		if [[ ${#startDay} -lt 2 ]]
		then
            newStartDate=$startYear-$startMonth-0$startDay
		else
			newStartDate=$startYear-$startMonth-$startDay
		fi

		newEndDate=$startYear-$startMonth-$endDay

		dateLine=`grep $newStartDate $fileForAwk | awk 'BEGIN {FS=","} { print $0 }'` 
		
		if [[ ! -z $dateLine ]]
		then
			echo $dateLine >> $fileFromAwk
			echo $dateLine >> awkOutput.csv
		fi

		if [[ $startDay -eq "15" ]]
		then
			computeStats "awkOutput.csv"
			echo "$rowcount,$avgconf,$avgdeaths,$avgtests" >> $fileSTATS

			endDay="31"

            :> awkOutput.csv

		elif [[ $startDay -eq "31" ]]
		then
			computeStats "awkOutput.csv"
			echo "$rowcount,$avgconf,$avgdeaths,$avgtests" >> $fileSTATS

			startDay="00"
			endDay="15"

			startMonth=$(expr $startMonth + 1)
			currentNumMonth=$(expr $currentNumMonth + 1)
			
			if [[ ${#startMonth} -lt 2 ]]
			then
				startMonth=0$startMonth

			elif [[ ${startMonth} -eq 13 ]]
			then
				startMonth=01
				startYear=$(expr $startYear + 1)
			fi

            :> awkOutput.csv
		fi

                startDay=$(expr $startDay + 1)
	done
}

compValuesAndDiff() {
	currentLine=$1

	rowcountCOMP=`echo $currentLine | awk 'BEGIN {FS=","; rowcount=0} {rowcount+=$1} END{print rowcount}'`
	avgconfCOMP=`echo $currentLine | awk 'BEGIN {FS=","; avgconf=0} {avgconf+=$2} END{print avgconf}'`
	avgdeathsCOMP=`echo $currentLine | awk 'BEGIN {FS=","; avgdeaths=0} {avgdeaths+=$3} END{print avgdeaths}'`
	avgtestsCOMP=`echo $currentLine | awk 'BEGIN {FS=","; avgtests=0} {avgtests+=$4} END{print avgtests}'`

	diffcount=$((rowcountINPUT - rowcountCOMP))
	diffavgconf=$((avgconfINPUT - avgconfCOMP))
	diffavgdeaths=$((avgdeathsINPUT - avgdeathsCOMP))
	diffavgtests=$((avgtestsINPUT - avgtestsCOMP))
}

scriptSyntax="$0 $*"
avgTitles="rowcount,avgconf,avgdeaths,avgtests"
diffTitles="diffcount,diffavgconf,diffavgdeath,diffavgtests"

if [[ $1 == "get" ]] # Get procedure: Collects all data for a provided province given the province ID.
then
	if [[ $# != 4 ]]
	then
		errorMsg "Wrong number of arguments" "$scriptSyntax"
	else
		id=$2
		inputFile=$3
		outputFile=$4
		
		getRows "$inputFile" "inputFileIDs.csv"

		computeStats "inputFileIDs.csv"
		
		cat inputFileIDs.csv > $outputFile 
		echo $avgTitles >> $outputFile
		echo "$rowcount,$avgconf,$avgdeaths,$avgtests" >> $outputFile
		rm inputFileIDs.csv
	fi

elif [[ $1 == "compare" ]] # Compare procedure: Compares the collected data of a province with another province's data.
							# Uses a previously-computed comp (compare) results CSV file.
then
	if [[ $# != 5 ]]
	then
		errorMsg "Wrong number of arguments" "$scriptSyntax"
	elif [ ! -f $3 ]
        then
        	errorMsg "Input file name does not exist" "$scriptSyntax"
	else
		id=$2
		inputFile=$3
		outputFile=$4
		compFile=$5
		
		getRows "$inputFile" "inputFileIDs.csv"
		computeStats "inputFileIDs.csv"

		cat inputFileIDs.csv > $outputFile

		awk '/rowcount,avgconf,avgdeaths,avgtests/ {exit} {print}' $compFile >> $outputFile
		
		echo $avgTitles >> $outputFile
        echo "$rowcount,$avgconf,$avgdeaths,$avgtests" >> $outputFile
		
		lastCompLine=`sed -n '$p' $compFile`
		
		rowcountINPUT=$rowcount
		avgconfINPUT=$avgconf
		avgdeathsINPUT=$avgdeaths
		avgtestsINPUT=$avgtests

		compValuesAndDiff "$lastCompLine"

		echo $avgTitles >> $outputFile
		echo "$rowcountCOMP,$avgconfCOMP,$avgdeathsCOMP,$avgtestsCOMP" >> $outputFile

		echo $diffTitles >> $outputFile
		echo "$diffcount,$diffavgconf,$diffavgdeaths,$diffavgtests" >> $outputFile
		rm inputFileIDs.csv
	fi

elif [[ $1 == "-r" ]] && [[ $2 == "get" ]] # Get procedure with -r: Collects provincial data within a provided date range
then
	if [[ $# != 7 ]]
	then
		errorMsg "Wrong number of arguments" "$scriptSyntax"
	else
		id=$3
		startDate=$4
		endDate=$5
		inputFile=$6
		outputFile=$7

		getRows "$inputFile" "inputFileIDs.csv"
		getDateRows "inputFileIDs.csv" "inputFileIDsDates.csv" "inputFileSTATS.csv"
		cat inputFileIDsDates.csv > $outputFile
		echo $avgTitles >> $outputFile
		cat inputFileSTATS.csv >> $outputFile
		rm inputFileIDs.csv inputFileIDsDates.csv inputFileSTATS.csv awkOutput.csv

	fi

elif [[ $1 == "-r" ]] && [[ $2 == "compare" ]] # Compare procedure with -r: Collects provincial data within a provided date range
then
	if [[ $# != 8 ]]
	then
		errorMsg "Wrong number of arguments" "$scriptSyntax"
	else
		id=$3
		startDate=$4
		endDate=$5
		inputFile=$6
		outputFile=$7
		compFile=$8
			
		getRows "$inputFile" "inputFileIDs.csv"
		getDateRows "inputFileIDs.csv" "inputFileIDsDates.csv" "inputFileSTATS.csv"
		getDateRows "$compFile" "compFileIDsDates.csv" "compFileSTATS.csv"
		
		counter=1
		
		if [[ -f diffSTATS.csv ]]
		then
			rm diffSTATS.csv
		fi

		halfMonths=`cat inputFileSTATS.csv | awk 'BEGIN {FS=","} {count++} END{print count}'`
		
		for i in $(seq $halfMonths)
		do
			currentInputLine=`sed -n "${counter}p" < inputFileSTATS.csv`
			
			rowcountINPUT=`echo $currentInputLine | awk 'BEGIN {FS=","; rowcount=0} {rowcount+=$1} END{print rowcount}'`
			avgconfINPUT=`echo $currentInputLine | awk 'BEGIN {FS=","; avgconf=0} {avgconf+=$2} END{print avgconf}'`
			avgdeathsINPUT=`echo $currentInputLine | awk 'BEGIN {FS=","; avgdeaths=0} {avgdeaths+=$3} END{print avgdeaths}'`
			avgtestsINPUT=`echo $currentInputLine | awk 'BEGIN {FS=","; avgtests=0} {avgtests+=$4} END{print avgtests}'`
			
			currentCompLine=`sed -n "${counter}p" < compFileSTATS.csv`
			
			compValuesAndDiff "$currentCompLine"		

			diffValues="echo $diffcount,$diffavgconf,$diffavgdeaths,$diffavgtests"
			$diffValues >> diffSTATS.csv

			counter=$(expr $counter + 1)

		done

		cat inputFileIDsDates.csv > $outputFile
		cat compFileIDsDates.csv >> $outputFile
		echo "rowcount,avgconf,avgdeaths,avgtests" >> $outputFile
		cat inputFileSTATS.csv >> $outputFile
		echo "rowcount,avgconf,avgdeaths,avgtests" >> $outputFile
		cat compFileSTATS.csv >> $outputFile
		echo "diffcount,diffavgconf,diffavgdeath,diffavgtests" >> $outputFile
		cat diffSTATS.csv >> $outputFile
		
		rm inputFileIDs.csv inputFileIDsDates.csv inputFileSTATS.csv compFileIDsDates.csv compFileSTATS.csv diffSTATS.csv awkOutput.csv
	fi

else
	errorMsg "Procedure not provided" "$scriptSyntax"
fi
