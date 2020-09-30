bike[7,2]
daily<- bike[1:10,bike$cyc_freq == 'Daily']

# Find the number of students in the dataset
bike <- BikeData
table(bike$student)
student <- bike[bike$student == '1',]
table(student$cyc_freq)
distance <- student$distance
mean(distance)

daily <- bike[bike$cyc_freq== 'Daily',]
table(daily$gender)
mean(daily$age)
male <- daily[daily$gender== 'M',]
female <- daily[daily$gender== 'F',]
mean(male$age)
mean(female$age)
male_old <- male[male$age >= 30,]
