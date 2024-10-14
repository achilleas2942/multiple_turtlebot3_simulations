# Use the base ROS Noetic core image
FROM ros:noetic-ros-core-focal

# Install required dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-vcstools \
    python3-pip \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    wget \
    git \
    libeigen3-dev \
    libgoogle-glog-dev \
    linux-tools-common \
    linux-tools-generic \
    linux-tools-$(uname -r) \
    && rm -rf /var/lib/apt/lists/*

# catkin build
RUN mkdir -p /root/catkin_ws/src && cd /root/catkin_ws/

# Initialize rosdep
RUN rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO

# Install additional ROS packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-ros-base=1.5.0-1* \
    ros-noetic-octomap \
    ros-noetic-octomap-msgs \
    ros-noetic-octomap-ros \
    ros-noetic-xacro \
    ros-noetic-gazebo-plugins \
    ros-noetic-gazebo-ros-pkgs \
    ros-noetic-tf2 \
    ros-noetic-tf \
    ros-noetic-tf-conversions \
    ros-noetic-turtlebot3 \ 
    ros-noetic-turtlebot3-msgs \
    ros-noetic-rqt-gui \
    ros-noetic-rqt-gui-py \
    && rm -rf /var/lib/apt/lists/*

# Create an entrypoint script to pull the latest updates and build the workspace
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# Source ROS setup scripts
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN echo "source /root/catkin_ws/devel/setup.bash" >> ~/.bashrc

# Set the entrypoint
ENTRYPOINT ["/root/entrypoint.sh"]

# Default command (can be overridden)
CMD ["bash"]
