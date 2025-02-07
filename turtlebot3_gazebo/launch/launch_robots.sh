#!/bin/bash

pairs=3
# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "Number of robot pairs not specified. Proceeding with the default number of robot pairs: $pairs"
else
	pairs=$1
	# Check if the argument is an integer
	if ! [[ "$pairs" =~ ^[0-9]+$ ]]; then
		pairs=3
	    echo "Invalid argument. Proceeding with the default number of robot pairs: $pairs"
	elif [ $pairs -lt 3 ]; then
		pairs=3
		echo "Number of robot pairs less than 3. Defaulting the value to: $pairs"
	else
		echo "Number of robot pairs: $pairs"
	fi

	# Initialize variables
	n=$((pairs * 2))
	s=2

	# While loop to find the appropriate value of s
	while [ $(echo "$s^2 < $n" | bc) -eq 1 ]; do
	    s=$((s + 1))
	done

	# Initialize arrays
	X=()
	Y=()
	m=$((s % 2))



	# Generate ln array and calculate X and Y
	for ((i=0; i<n; i++)); do
	    ln=$i
	    X[$i]=$(echo "$ln % $s" | bc)
	done

	max_X=$(echo "${X[@]}" | tr ' ' '\n' | sort -nr | head -n1)
	min_X=$(echo "${X[@]}" | tr ' ' '\n' | sort -n | head -n1)
	for ((i=0; i<n; i++)); do
	    X[$i]=$(echo "${X[$i]} - ($max_X + $min_X) / 2" | bc -l)
	done

	for ((i=0; i<n; i++)); do
	    ln=$i
	    Y[$i]=$(echo "$ln / $s" | bc)
	done

	max_Y=$(echo "${Y[@]}" | tr ' ' '\n' | sort -nr | head -n1)
	min_Y=$(echo "${Y[@]}" | tr ' ' '\n' | sort -n | head -n1)
	for ((i=0; i<n; i++)); do
	    Y[$i]=$(echo "${Y[$i]} - ($max_Y + $min_Y) / 2" | bc -l)
	done



# Create the launch file
launch_file="sim_launch.launch"
echo "<launch>" > $launch_file
cat <<EOL >> $launch_file

   <env name="GAZEBO_MODEL_PATH" value="\${GAZEBO_MODEL_PATH}:\$(find rotors_gazebo)/models"/>
  <env name="GAZEBO_RESOURCE_PATH" value="\${GAZEBO_RESOURCE_PATH}:\$(find rotors_gazebo)/resource:\$(find rotors_gazebo)/models:\$(find rotors_gazebo)/models"/>
  <include file="\$(find gazebo_ros)/launch/empty_world.launch">
    <arg name="world_name" value="\$(find rotors_gazebo)/worlds/basic.world" />
    <arg name="debug" value="false" />
    <arg name="paused" value="true" />
    <arg name="gui" value="true" />
    <arg name="verbose" value="false"/>
  </include>
EOL

for ((i=0; i<pairs; i++)); do
    ns_d="dcf$((i+1))"
    ns_g="demo_turtle$((i+1))"
    xd_pos=${X[$((i*2))]}
    yd_pos=${Y[$((i*2))]}
    zd="0.2"
    xg_pos=${X[$((i*2+1))]}
    yg_pos=${Y[$((i*2+1))]}
    zg="0.0"
    yaw=$(echo "$i * 1.5708" | bc -l)
    cat <<EOL >> $launch_file
  <group ns="$ns_g">
    <param name="robot_description" command="\$(find xacro)/xacro \$(find turtlebot3_description)/urdf/turtlebot3_waffle_pi.urdf.xacro" />
    <param name="tf_prefix" value="$ns_g" />

    <node pkg="robot_state_publisher" type="robot_state_publisher" name="robot_state_publisher" output="screen">
      <param name="publish_frequency" type="double" value="50.0" />
      <param name="tf_prefix" value="$ns_g" />
    </node>
    
    <node name="spawn_urdf" pkg="gazebo_ros" type="spawn_model" args="-urdf -model $ns_g -x $xg_pos -y $yg_pos -z $zg -Y $yaw -param robot_description" />
  </group>

  <group ns="$ns_d">
    <include file="\$(find rotors_gazebo)/launch/spawn_mav.launch">
      <arg name="namespace" value="$ns_d"/>
      <arg name="mav_name" value="hummingbird"/>
      <arg name="model" value="\$(find rotors_description)/urdf/mav_generic_odometry_sensor.gazebo" />
      <arg name="x" value="$xd_pos"/>
      <arg name="y" value="$yd_pos"/>
      <arg name="z" value="$zd"/>
    </include>

    <node name="robot_state_publisher" pkg="robot_state_publisher" type="robot_state_publisher" />
  </group>
  
EOL
done

echo "</launch>" >> $launch_file

echo "Launch file $launch_file created successfully."

roslaunch turtlebot3_gazebo sim_launch.py

fi