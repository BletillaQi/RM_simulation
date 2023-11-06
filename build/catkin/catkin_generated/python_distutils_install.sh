#!/bin/sh

if [ -n "$DESTDIR" ] ; then
    case $DESTDIR in
        /*) # ok
            ;;
        *)
            /bin/echo "DESTDIR argument must be absolute... "
            /bin/echo "otherwise python's distutils will bork things."
            exit 1
    esac
fi

echo_and_run() { echo "+ $@" ; "$@" ; }

echo_and_run cd "/home/bletilla/Code/sim/src/catkin"

# ensure that Python install destination exists
echo_and_run mkdir -p "$DESTDIR/home/bletilla/Code/sim/install/lib/python3/dist-packages"

# Note that PYTHONPATH is pulled from the environment to support installing
# into one location when some dependencies were installed in another
# location, #123.
echo_and_run /usr/bin/env \
    PYTHONPATH="/home/bletilla/Code/sim/install/lib/python3/dist-packages:/home/bletilla/Code/sim/build/lib/python3/dist-packages:$PYTHONPATH" \
    CATKIN_BINARY_DIR="/home/bletilla/Code/sim/build" \
    "/usr/bin/python3" \
    "/home/bletilla/Code/sim/src/catkin/setup.py" \
    egg_info --egg-base /home/bletilla/Code/sim/build/catkin \
    build --build-base "/home/bletilla/Code/sim/build/catkin" \
    install \
    --root="${DESTDIR-/}" \
    --install-layout=deb --prefix="/home/bletilla/Code/sim/install" --install-scripts="/home/bletilla/Code/sim/install/bin"
