
Project Brief

1. The data which is going to be provided will consists of columns that has a list of the names of all students, all projects, and the time which students tendered for those projects and lastly how they rated those project. Each student is allowed to select the maximum of three projects and rate them as their 1st, 2nd or 3rd choice.

2. PSO algorithm will have to go through the data and allocate the projects to the most appropriate student.
  1) The allocation will be done based on who choose a project first.
  2) First preference should be given to that student who choose it as his/her first choice then second and third choice.
  3) If it happens that only one student tender for a particular project, that project will be allocated to that student regardless of his/her ratings.
  4) Once a student is allocated a project, the algorithm should take him/her out of the list so that we don’t end up with the situation where one student has more than one projects.
  5) If it happens that there is no student who tendered for a specific project, that project will be allocated randomly to any student who doesn’t have a project at the end of the allocation process.
  
3. At the end of the allocation, PSO has to check if the allocation is good or bad, if it is good then it will stop and if it’s not it will have to do the allocation again.
  1) A good allocation is believed to be that where all students are allocated their first choices but practically that can’t be possible since the number of students are more than the projects available and also because of there are more cases in this data where more students are interested on one project.
  2) So the an allocation will be taken as a good one if the allocation is done in a way that the number of students who are allocated their first choices are more than the number of students who are allocated their second choices and so to those who get their third choices.

