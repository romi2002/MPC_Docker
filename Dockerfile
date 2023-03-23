FROM ros:melodic-ros-core
RUN apt-get update && \
 apt-get install -y vim python3-pip git software-properties-common coinor-libipopt-dev python3-dev gcc g++ swig ipython3 python3-dev python3-numpy python3-scipy python3-matplotlib wget gfortran git cmake liblapack-dev pkg-config --install-recommends && \
 rm -rf /var/lib/apt/lists/*
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null \
 && apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" && \
 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6AF7F09730B3F0A4 && apt-get update && apt-get install -y cmake && rm -rf /var/lib/apt/lists/*
#RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.6 1
#RUN update-alternatives --config python
RUN git clone https://github.com/casadi/casadi.git -b master /tmp/casadi
WORKDIR /tmp/casadi

# Casadi install
RUN mkdir build && cd build && cmake -DWITH_PYTHON=ON .. && make && make install

# Fatrop install
RUN git clone https://gitlab.kuleuven.be/robotgenskill/fatrop/fatrop.git /tmp/fatrop
WORKDIR /tmp/fatrop
RUN git checkout develop &&  git submodule update --recursive --init
#ENV BLASFEO_TARGET=ARMV8A_APPLE_M1
ENV BLASFEO_TARGET=ARMV8A_ARM_CORTEX_A57
#ENV BLASFEO_TARGET=GENERIC
COPY fatropy/setup.py.patch /tmp/
RUN mkdir build && \
 cd build && \
 cmake -DBLASFEO_TARGET=${BLASFEO_TARGET} .. && \
  make -j && \ 
  make install && ldconfig
WORKDIR /tmp/fatrop/fatropy
RUN pip3 install Cython && \
  pip3 install setuptools==59.5.0 && \
  bash -c "patch setup.py < /tmp/setup.py.patch" && \
  pip3 install .

WORKDIR /
RUN pip3 install rockit-meco --no-deps

# Manually install rockit_fatrop_plugin
COPY fatrop_plugin/fatrop_plugin_gitmodules.patch /tmp/fatrop_plugin_gitmodules.patch
RUN cd /usr/local/lib/python3.6/dist-packages/rockit/external && \
    rm -R fatrop && git clone https://gitlab.kuleuven.be/u0110259/rockit_fatrop_plugin.git fatrop && \
    cd fatrop && bash -c "patch .gitmodules < /tmp/fatrop_plugin_gitmodules.patch" && git submodule update --init --recursive

ADD https://raw.githubusercontent.com/alexglzg/rockit/master/examples/ASV_examples/working_integration.py /working_integration.py
RUN bash -c "echo \"source /opt/ros/melodic/setup.bash\" >> /root/.bashrc"

# Install ROS desktop (image not available on arm :( )
RUN apt-get update && apt-get install -y ros-melodic-desktop python-catkin-pkg ros-melodic-tf2-geometry-msgs ros-melodic-gazebo-ros && rm -rf /var/lib/apt/lists/*
