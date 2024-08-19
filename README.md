# // covid-analysis

Bash script that allows the user to get and compare provincial COVID-19 info from a CSV dataset in order to understand the spread of the disease.

Script syntax:
./covidata.sh -r procedure id startDate endDate inputFile outputFile compareFile

Legal usage examples:
- ./covidata.sh get 35 data.csv result.csv
- ./covidata.sh -r get 35 2020-01 2020-03 data.csv result.csv
- ./covidata.sh compare 10 data.csv result2.csv result.csv
- ./covidata.sh -r compare 10 2020-01 2020-03 data.csv result2.csv result.csv

- Save to-do items to one of the default folders (Home, Today, Week) or create a custom folder.
- View to-do details, make an edit, delete and check off items.
- Three priority levels to assign a to-do item.
- Number of remaining unchecked items displayed by project name, total unchecked items displayed by Home title.
- Pinterest style notes section. Dynamically add, remove or edit notes.
- Fully responsive.
- Data saved to local storage.

![alt text](https://raw.githubusercontent.com/bscottnz/todo/master/todo.png "App Preview")
