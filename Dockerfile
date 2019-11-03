FROM quay.io/biocontainers/cesm:2.1.1--py37he9b5208_1

#####EXTRA LABELS#####
LABEL autogen="no" \ 
    software="CESM" \ 
    version="2" \
    software.version="2.1.1" \ 
    about.summary="Community Earth System Model" \ 
    base_image="cesm:2.1.1--py37he9b5208_1" \
    about.home="http://www.cesm.ucar.edu/models/simpler-models/N1850/index.html" \
    about.license="Copyright (c) 2017, University Corporation for Atmospheric Research (UCAR). All rights reserved." 
      
MAINTAINER Anne Fouilloux <annefou@geo.uio.no>

RUN ln -s /usr/local/bin/x86_64-conda_cos6-linux-gnu-ar /usr/local/bin/ar

RUN adduser -D cesm -G users

USER cesm

RUN mkdir -p /home/cesm/.cime && \
    mkdir -p /home/cesm/work \
             /home/cesm/inputdata \
             /home/cesm/archive \
             /home/cesm/cases 

COPY config_files/* /home/cesm/.cime/

ENV AR=ar

ENV USER=cesm

ENV CESM_PES=4

RUN sed -i -e "s/\$CESM_PES/$CESM_PES/g" /home/cesm/.cime/config_machines.xml && \
    create_newcase --case /home/cesm/cases/VR-CESM \
    --compset HIST_CAM60_CLM50%BGC_CICE%PRES_DOCN%DOM_MOSART_CISM2%NOEVOLVE_SWAV \
    --res ne0uoslone30x8_ne0uoslone30x8_mt12 --machine espresso --run-unsupported && \
    cd /home/cesm/cases/VR-CESM                          && \
    ./case.setup && ./case.build
    
WORKDIR /home/cesm/cases/VR-CESM

COPY run_f1850 /home/cesm/cases/VR-CESM

ENTRYPOINT ./run_vrcesm
