cmake_minimum_required(VERSION 2.8.3)

project(building)

find_package(catkin REQUIRED)

catkin_package()

find_package(roslaunch)

foreach(dir test_model world)
	install(DIRECTORY ${dir}/
		DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/${dir})
endforeach(dir)
