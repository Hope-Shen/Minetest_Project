
# Minetest Project
This project aims to create a virtual learning environment(VLE) with four features: <br>
1. Whitelist for allowed users  
2. Auided tour for new enter the world
3. Student attendance registration for teacher role
4. Presentation for teaher provide an in-game slides presentation
<br>

*The main code is from Minetest (version 5.4.1), this project only creates the "university" mod. <br>
*This project use Web API to transmit data, the related repository please check [this repository](https://github.com/Hope-Shen/Minetest_Project_WebAPI).

## Language
Lua

## How to run this application

### New to Minetest
1. Download and extract the zip file
2. Direct to \bin directory and execute "minetest.exe". 
3. *Note that only contents in “```~/mods/university```” is relevant to this project, and the rest of the source code is from the original Minetest (https://www.minetest.net/downloads/) 

### Existing Minetest user
This source code repository contains the Minetest engine (version 5.4.1). The minimum requirement for this mod is 5.0.0, please ensure your Minetest version meets this requirement or go to the official Minetest website to update to version 5.4.1.

Copy the "```~/mods/university```" folder from the GitHub repository to your Minetest mods directory. Also, copy the "```minetest.conf```" into your repository and make sure you follow the statement below:
```
name = <admin name>
secure.enable_security = true
secure.http_mods = university
secure.trusted_mods = university
```


## User Manual
### B.1 Start the Minetest engine server
As an online-platform, the teacher as the admin should start the server with a list of whitelisted users to allow users access. 
1. Run the Minetest engine server:
Execute ~/bin/srartserver.bat file by double clicking on the file or run ```minetest.exe --server --worldname <world name>``` in terminal (figure B.1 green box).
2. Wait for 1 second. The server will load the whitelist. If loaded successfully, the terminal should show a message “Whitelist has been loaded successfully" (figure B.1 red box). Otherwise, please check your Web API connection.
3. Minetest is started and enabled for users to login.
<figure>
  <figcaption>Figure B.1 Screenshot of running server and whitelist loaded message</figcaption>
  <img
  src="https://user-images.githubusercontent.com/73281304/132339951-9157f117-36dc-48fb-85b7-465e4b7513a1.png"
  width="500"
  alt="Figure B.1 Screenshot of running server and whitelist loaded message.">
</figure>

### B.2 Login and the Guided Tour
After the server has been started, users are ready to join the world. 
1. To join the world, open ```~/bin/minetest.exe``` and select the “Join Game” tab (figure B.2). 
2. The IP address should be the virtual machine IP and the port is 30000.
3. Login with your verified name and password. The login user should be listed in the whitelist and the default password is 123456. Take student “vivian” whose student id is 3 for example, this student’s name box should input 3-vivian and password box should input 123456. If the login user is not on the whitelist then the login will be denied. 
4. When login is successful, the welcome and guided tour interface will pop up and provide the basic controls and functions of the application.
5. There are three pages in the guided tour and buttons for navigating to the next/previous page or close the modal.
<figure>
  <figcaption>Figure B.2 Screenshot of login UI</figcaption>
  <img
  src="https://user-images.githubusercontent.com/73281304/132340047-7c78624e-8ef2-4482-804e-dd5b7c28786e.png"
  width="500"
  alt="Figure B.2 Screenshot of login UI.">
</figure>

### B.3 Give a Presentation
This function is only for the teacher role. If the user is not a teacher, the operation will be denied. Only the admin can give teacher privilege. Admin can type ```\grantme teacher``` or ```\grant <user> teacher``` to grant users teacher privilege. To revoke the privilege is the same way, replace grant to revoke ```\revokeme teacher``` or ```\revoke <user>``` teacher.

Before a teacher can give a presentation in Minetest, the teacher should put the slides in png format in the ```~/mods/university/textures/``` folder and follow the name convention which is ”```PPT_{CourseID}_{SlideNumber}```”.  For example, suppose that there are two courses and each course has two slides. The directory should have four png files which are ”PPT_COMP0001_1.png”, ”PPT_COMP0001_2.png”, ”PPT_COMP0002_1.png” and ”PPT_COMP0002_2.png".
1. Put the slides into the assigned folder
2. Type “```i```” to open the inventory and search “```university```” (figure B.3 green box).
3. Find the course slide object and drag the slides object into the bottom area (figure B.3 red box and arrow). Note there will only be one object per course for the first slide showing in the inventory.
4. Press “```Esc```” to close the inventory
5. Scroll your mouse to select the slide’s object from the quick menu at the bottom of the screen.
6. Find a wall and place the slides by right-clicking the mouse.
7. To move to the next slide, right-click again on the slides. The server should cycle through all slides with the course prefix.
8. To remove the slides from the wall, left click on the slides. 
<figure>
  <figcaption>Figure B.3 Screenshot of login UI</figcaption>
  <img
  src="https://user-images.githubusercontent.com/73281304/132340071-85e98b75-901d-4a38-86b6-7d7a48088bdb.png"
  width="500"
  alt="Figure B.3 Screenshot of login UI.">
  <figcaption>Figure B.4 Screenshot of presentation</figcaption>
  <img
  src="https://user-images.githubusercontent.com/73281304/132340205-138a37f6-bdfa-4afb-b59c-669a7ed194da.jpg"
  width="500"
  alt="Figure B.4 Screenshot of presentation.">
</figure>

### B.4 Take Student Attendance
This function is only for the teacher role. If the user is not a teacher, the operation will be denied. Only the admin can give teacher privilege. Admin can type ```\grantme teacher``` or ```\grant <user> teacher``` to grant users teacher privilege. To revoke the privilege is the same way, replace grant to revoke ```\revokeme teacher``` or ```\revoke <user> teacher```.

The following step shows the correct way to take attendance:
1. Type “```i```” to open the inventory and search “```university```” (figure B.5 green box).
2. Find the “computer” object and drag the object into the bottom area (figure B.5 red box and arrow).
3. Press “```Esc```” to close the inventory.
4. Scroll your mouse to select the computer object from the quick menu at the bottom of the screen.
5. Find a place to place the object by right-clicking the mouse.
6. Left-click on the object to download course and attendance data.
7. Right-click on the object to open the UI.
8. Select the course in the dropdown list (figure B.6 red circle label 1).
9. To take students' attendance, choose an online student who is listed in the left column and click the "```>>```” button (figure B.6 red circle label 2) which will move the student name to the right to record this student’s attendance.
10. To remove students’ attendance, choose a student who is listed in the right column and click the “```<<```” button (figure B.6 red circle label 3) which will move the student name to the left to delete the student’s attendance record.

<figure>
  <figcaption>Figure B.5 Screenshot of login UI</figcaption>
  <img
  src="https://user-images.githubusercontent.com/73281304/132340138-1b002386-02cd-48ee-8c81-721c1489c1d2.png"
  width="500"
  alt="Figure B.5 Screenshot of finding the computer object.">
  <figcaption>Figure B.6 Screenshot of attendance registration UI</figcaption>
  <img
  src="https://user-images.githubusercontent.com/73281304/132340147-9dbf8fbb-39cc-49bf-8f86-0006e5f6dd1e.png"
  width="500"
  alt="Figure B.6 Screenshot of attendance registration UI.">
</figure>


