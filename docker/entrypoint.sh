#!/bin/bash

# Source the ROS setup
source /opt/ros/noetic/setup.bash

# Pull the latest updates from the repositories
cd /root/catkin_ws/src
if [ -d "turtlebot3_simulations" ]; then
    cd turtlebot3_simulations && git pull && cd ..
else
    git clone https://github.com/achilleas2942/turtlebot3_simulations.git
fi

# Build the workspace
cd /root/catkin_ws/
catkin_make

# Source the workspace
source /root/catkin_ws/devel/setup.bash

# pass gazebo args
export TURTLEBOT3_MODEL=waffle_pi

# Execute the provided command
roslaunch turtlebot3_gazebo multiple_turtles.launch