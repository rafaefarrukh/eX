EmpowerX is a website written in R for the purpose of assisting FCCU undergraduate students in viewing courses/programs offered by FCCU and tracking their own degree. The following details are regarding the code.

The following link redirects to a google drive which contains the following files: https://drive.google.com/drive/folders/1BMhFFwi2kjcJrrBReenE3ZXKXEoKlxrV?usp=sharing
- EmpowerX - Sort Course Catalog: converts the course catalog pdf into a tabular form in a semi-manual method and stores all informaion regarding course and program details.
- EmpowerX - Degree Details: a presentation which shows details about FCCU Undergraduate Degree
- It also contains EmpowerX.Rproj, latest version of EmpowerX and a copy of this README file.

The following link redirects to the github page which contains all the relevant data files of this project: https://github.com/rafaefarrukh/EmpowerX

The following abbreviations are used: 
- dg = degree, ma = major, mi = minor, sp = specialization, ct = certification, ged = general education, frel = free elective
- cr = credits, co = courses
- c (as a suffix)  = core, e (as a suffix) = elective
- dept = department, preq = prerequisite, cc = cross listed courses

The following naming conventions are used:
- code chunks names = X/Y/Z, where X = H1 abv, Y = H2 abv, Z = H3 name
- semesters = sx.y, where x = {0,1,2,...,8}, y = {0,5}
- programs = xyz, where x = {ma,mi,sp}, y = {1,2}, z = {c,e}

The important datasets involved are:

- courses (csv) = details of all courses offered (offline copy from google sheets)
- programs (csv) = details of all programs offered (offline copy from google sheets)
- grades (data frame) = grading system

- timeline (reactive) =  semester details based on yd_sem, yd_yr
- user_data (reactive) = details of all courses based on timeline, sx.y, xyz
- user_overview (reactive) = credit and gpa distribution based on timeline, user_data, sx.y, xyz

- sx.y (reactive) = courses and grades taken in that semester. Uses rhandsontable to interact with user

- export (csv) = all user inputs that are to be exported to "import"
- import (reactive) = all user inputs that are to be imported from "export"
