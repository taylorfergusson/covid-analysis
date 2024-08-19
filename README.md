# // COVID-19 Analysis

Bash script that allows the user to get and compare provincial COVID-19 info from a CSV dataset in order to understand the spread of the disease. The data.csv file contains a data visualization of COVID-19 in Canada, which can be analyzed. 

Procedure explanation:
- get: Allows the user to receive in an output file only the rows pertaining the specified province ID, and provides calculated information regarding the number of rows, average number of confirmed cases, average number of deaths, and average number of tests. 
- compare: Computes statistics for extracted rows and compares them to the statistics in the compare file (assumed to be formatted as an output file from the get procedure). The output file contains in order the rows from the new action, the rows from the compare file, the newly calculated statistics, the statistics from the compare file, then a comparative statistic. The comparative statistic provides the differences in row count, average number of confirmed cases, average number deaths, and average number of tests. The compare values are subtracted from the newly calculated values.


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
- ./covidata.sh -r procedure id startDate endDate inputFile outputFile compareFile

Legal usage examples:
- ./covidata.sh get 35 data.csv result.csv
- ./covidata.sh -r get 35 2020-01 2020-03 data.csv result.csv
- ./covidata.sh compare 10 data.csv result2.csv result.csv
- ./covidata.sh -r compare 10 2020-01 2020-03 data.csv result2.csv result.csv


![alt text](https://raw.githubusercontent.com/taylorfergusson/covid-analysis/master/demovideo.mp4 "Demo Example Video")
