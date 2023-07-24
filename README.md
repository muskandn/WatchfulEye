## WatchfulEye

A CCTV-based  Violence Detection System .
With the increasing prevalence of surveillance cameras in modern cities, the human resources available for real-time monitoring of these screens are insufficient. By Merging computer vision and machine learning algorithms, we have successfully developed a system capable of real-time detection and identification of violent incidents in monitored areas.
Our user-friendly interface empowers security personnel to monitor live feeds, review notifications , and take necessary actions, thereby creating an active approach to violence detection.
We have built and implemented an automated system which can be integrated with the CCTV Systems and an appropriate notification will be sent to concerned authorities. 
The detection is done with the assistance of an ML Model implemented in TFLite, for lightweight and fast execution.This Model was trained on [RWF2000 Dataset](https://github.com/mchengny/RWF2000-Video-Database-for-Violence-Detection)  Dataset which is a collection of nearly 2000 video clips as a new data set for real-world violent behavior detection under surveillance camera.

### There are two parts of of this project:

#### 1) The implementation of an example System code in Python (in the `SystemCode` directory) :- 
This directory offers a Python script implementation that is simple to connect with CCTV systems. It is a multithreaded Python script that runs the ML model in one thread while simultaneously capturing frames from a video stream in another thread using the OpenCV library. This guarantees both the efficient use of computer resources and the seamless execution of many predictions by the ML model. Whenever this script detects violent behavior in the footage, it alerts a central Firebase server which then forwards the location of camera along with a small footage clip to all the authorities connected with the organization.

#### 2) The implementation of the Flutter App (in the `Flutter App` directory) :-
This Directory Implements our app can be installed in your devices and will serve as the receiving endpoint of any signal given off from the server.Users who are the security personnal or the security authorities can login to our app and they will get a notification whenever any violence is detected through the cctv cameras . The security authorities will get the details such as Location and a small footage . 
