echo "-------------------------------------------------"
echo " Building Multiple Turtles Simulator docker image"
echo "-------------------------------------------------"

DOCKER_BUILDKIT=1 docker build -t ghcr.io/achilleas2942/multiple_turtles_simulator .