# // COVID-19 Analysis

Bash script that allows the user to get and compare provincial COVID-19 info from a CSV dataset in order to understand the spread of the disease.


Argument details:
- -r: Switch indicating that the results should only be from the provided startDate and endDate.
- procedure: Specified action on the dataset, either "get" or "compare".
- id: Province Unsigned ID (pruid), unique identifier for each province and territory.
- startDate: Beginning year and month for range, in YYYY-MM format.
- endDate: Ending year and month for range, in YYYY-MM format.
- inputFile: Filename for CSV dataset to be analyzed, titled data.csv in this case.
- outputFile: Desired filename for output file, must be CSV format.
- comparefile: CSV filename of previously generated results, will be compared to new province.

Script syntax:
./covidata.sh -r procedure id startDate endDate inputFile outputFile compareFile

Legal usage examples:
- ./covidata.sh get 35 data.csv result.csv
- ./covidata.sh -r get 35 2020-01 2020-03 data.csv result.csv
- ./covidata.sh compare 10 data.csv result2.csv result.csv
- ./covidata.sh -r compare 10 2020-01 2020-03 data.csv result2.csv result.csv


<!-- ![alt text](https://raw.githubusercontent.com/bscottnz/todo/master/todo.png "App Preview") -->
