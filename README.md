<H1>EmpowerX</H1>

EmpowerX is a website written in R for the purpose of assisting FCCU undergraduate students in viewing courses/programs offered by FCCU and tracking their own degree.

<H2> Requirements </H2>

EmpowerX requires the following to function:
- R (any version above 4.0.0)
- R Studio (any version)
- The following packages: flexdashboard, shiny, shinyWidgets, tidyverse, DT, lubridate, rhandsontable. Use the following command in the console to install these pacakges:

```console
> install.packages("flexdashboard"); install.packages("shiny"); install.packages("shinyWidgets"); install.packages("tidyverse"); install.packages("DT"); install.packages("lubridate"); install.packages("rhandsontable")
```
<H2> Installation Instructions </H2>

EmpowerX is simply a Rmarkdown file which needs to be rendered. To do so, do the following;
1. Ensure you have R, R Studio and the pacakges
2. Download this repo
3. Open EmpowerX.Rproj
4. Render the document by clicking the "Run Document" button or by using the shortcut keys "Ctrl + Shift + K"

<H2> Data Files </H2>

The course catalog is obtained from the official [FCCU website](https://www.fccollege.edu.pk/academic-catalogs-and-handbooks/)

This [google drive](https://drive.google.com/drive/folders/1BMhFFwi2kjcJrrBReenE3ZXKXEoKlxrV?usp=sharing) contains the following files:
- EmpowerX - Sort Course Catalog: converts the course catalog pdf into a tabular form in a semi-manual method and stores all informaion regarding course and program details
- EmpowerX - Degree Details: a presentation which shows details about FCCU Undergraduate Degree

This [github repo](https://github.com/rafaefarrukh/EmpowerX) contains the following files:
- data files which consist of offline copies of files in the google drive
- the latest version of EmpowerX
- EmpowerX_v0.0.0: a layout showing future plans of EmpowerX
- README.md: this file

<H2> Code Details and Notations </H2>

The following abbreviations are used: 
- dg = degree, ma = major, mi = minor, sp = specialization, ct = certification, ged = general education, frel = free elective
- cr = credits, co = courses
- c (as a suffix")  = core, e (as a suffix") = elective
- dept = department, preq = prerequisite, cc = cross listed courses

The following naming conventions are used:
- code chunks names = X/Y/Z, where X = H1 abv, Y = H2 abv, Z = H3 name
- semesters = sx.y, where x = {0,1,2,...,8}, y = {0,5}
- programs = xyz, where x = {ma,mi,sp}, y = {1,2}, z = {c,e}

The important datasets involved are:

- external:
  - courses (csv) = details of all courses offered (offline copy from google sheets)
  - programs (csv) = details of all programs offered (offline copy from google sheets)
  - degree_details (pdf) = presentation explaining FCCU undergraduate degree
- internal:
  - grades (data frame) = grading system
- evaluated:
  - timeline (reactive) =  semester details based on yd_sem, yd_yr
  - user_data (reactive) = details of all courses based on timeline, sx.y, xyz
  - user_overview (reactive) = credit and gpa distribution based on timeline, user_data, sx.y, xyz
  - sx.y (reactive) = courses and grades taken in that semester. Uses rhandsontable to interact with user
- export/import:
  - export (csv) = all user inputs that are to be exported to "import"
  - import (reactive) = all user inputs that are to be imported from "export"
