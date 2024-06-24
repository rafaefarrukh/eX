<H1>empowerX</H1>

eX is an unofficial collection of services meant to make degree planning easier for undergraduate students of FCCU.

**Note: eX is made available online using free version of shinyapps making the website versions slow. Hence it is suggested that you download eX if possible.**

<H2> Quick Links </H2>

[Course Catalog](https://empowerx.shinyapps.io/CourseCatalog/): Search courses and programs offered by FCCU.

[Time Table](https://empowerx.shinyapps.io/TimeTable/): Easily view coursed offered by FCCU each semester and generate a time table for your semester.

[Checklist](https://empowerx.shinyapps.io/Checklist/): Generate a checklist of courses you need to study to graduate (can act as a degree audit as well).


<H2> Installation </H2>

<H3> Requirements </H3>

EmpowerX requires the following to function:
- R
- R Studio
- The following packages: flexdashboard, shiny, shinyWidgets, tidyverse, DT, lubridate, rhandsontable. Use the following command in the console to install these pacakges:

```console
> install.packages("flexdashboard"); install.packages("shiny"); install.packages("shinyWidgets"); install.packages("tidyverse"); install.packages("DT")
```
<H3> Installation Instructions </H3>

EmpowerX is simply a Rmarkdown file which needs to be rendered. To do so, do the following;
1. Ensure you have R, R Studio and the pacakges mentioned above
2. Download this repo (Code --> Download ZIP --> Extract the file)
3. Open EmpowerX.Rproj
4. Open a .Rmd file
5. Render the document by clicking the "Run Document" button or by using the shortcut keys "Ctrl + Shift + K"

<H2> Data Files </H2>

The course catalog is obtained from the official [FCCU website](https://www.fccollege.edu.pk/academic-catalogs-and-handbooks/)

This [google drive](https://drive.google.com/drive/folders/1BMhFFwi2kjcJrrBReenE3ZXKXEoKlxrV?usp=sharing) contains the following files:
- EmpowerX - Sort Course Catalog: converts the course catalog pdf into a tabular form in a semi-manual method and stores all informaion regarding course and program details
- EmpowerX - Degree Details: a presentation which shows details about FCCU Undergraduate Degree

This [github repo](https://github.com/rafaefarrukh/EmpowerX) contains the following files:
- data files which consist of offline copies of files in the google drive
- Rmd files (main)
- README.md: this file
