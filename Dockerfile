FROM quay.io/nordicesmhub/cesm_libs:latest

#####EXTRA LABELS#####
LABEL autogen="no" \ 
    software="CESM" \ 
    version="2" \
    software.version="2.1.1" \ 
    about.summary="Community Earth System Model" \ 
    base_image="quay.io/nordicesmhub/cesm_libs" \
    about.home="VR-CESM" \
    about.license="Copyright (c) 2017, University Corporation for Atmospheric Research (UCAR). All rights reserved." 
      
MAINTAINER Anne Fouilloux <annefou@geo.uio.no>

ENV USER=root
ENV HOME=/root

RUN mkdir -p $HOME/.cime \
             $HOME/work \
             $HOME/inputdata \
             $HOME/archive \
             $HOME/cases 

COPY subversion.tar $HOME/
COPY config_files/* $HOME/.cime/
COPY vr_cesm_config/*  $HOME/vr_cesm_config/
COPY local_nl_clm $HOME/
COPY local_nl_cam $HOME/

RUN cd $HOME \
    && tar xf subversion.tar \
    && git clone -b cesm2_2_beta01 https://github.com/ESCOMP/CESM.git \
    && cd CESM \
    && sed -i.bak "s/'checkout'/'checkout', '--trust-server-cert', '--non-interactive'/" ./manage_externals/manic/repository_svn.py \
    && ./manage_externals/checkout_externals

ENV CESM_PES=12

RUN sed -i -e "s/\$CESM_PES/$CESM_PES/g" $HOME/.cime/config_machines.xml \
    && cd $HOME/CESM/cime/scripts \
    && cp $HOME/vr_cesm_config/config_grids_common.xml       \
       $HOME/CESM/cime/config/cesm/ \
    && cp $HOME/vr_cesm_config/config_grids.xml              \
       $HOME/CESM/cime/config/cesm/ \
    && cp $HOME/vr_cesm_config/horiz_grid.xml                \
       $HOME/CESM/components/cam/bld/config_files/ \
    && cp $HOME/vr_cesm_config/namelist_defaults_cam.xml     \
       $HOME/CESM/components/cam/bld/namelist_files/ \
    && cp $HOME/vr_cesm_config/namelist_defaults_ctsm.xml    \
       $HOME/CESM/components/clm/bld/namelist_files/ \
    && cp $HOME/vr_cesm_config/namelist_definition_ctsm.xml  \
       $HOME/CESM/components/clm/bld/namelist_files/

RUN CASE=case1 && \
    cd $HOME/CESM/cime/scripts && \
    ./create_newcase --case $HOME/cases/vr-cesm$CASE \
    --compset HIST_CAM60_CLM50%BGC_CICE%PRES_DOCN%DOM_MOSART_CISM2%NOEVOLVE_SWAV \
    --res ne0uoslone30x8_ne0uoslone30x8_mt12 --machine espresso \
    --run-unsupported  && \
    cd $HOME/cases/vr-cesm$CASE && \                       
    ./case.setup && \
    ./xmlchange EPS_AAREA=0.001 && \
    ./xmlchange ATM_NCPL=144 && \
    cat $HOME/local_nl_cam >> user_nl_cam  && \
    cat $HOME/local_nl_clm >> user_nl_clm && \
    ./xmlchange STOP_N=1 && \
    ./xmlchange STOP_OPTION=ndays && \
    ./case.build 

RUN CASE=case2 && \
    cd $HOME/CESM/cime/scripts && \
    ./create_newcase --case $HOME/cases/vr-cesm$CASE \
    --compset HIST_CAM60_CLM50%BGC_CICE%PRES_DOCN%DOM_MOSART_CISM2%NOEVOLVE_SWAV \
    --res ne0uoslone30x8_ne0uoslone30x8_mt12 --machine espresso \
    --run-unsupported  && \
    cd $HOME/cases/vr-cesm$CASE && \                       
    NUMNODES="$((4*$CESM_PES))"                                   && \
    ./xmlchange --file env_mach_pes.xml --id NTASKS --val ${NUMNODES} && \
    ./xmlchange --file env_mach_pes.xml --id NTASKS_ESP --val 1 && \
    ./xmlchange --file env_mach_pes.xml --id ROOTPE --val 0 && \
    ./case.setup && \
    ./xmlchange EPS_AAREA=0.001 && \
    ./xmlchange ATM_NCPL=144 && \
    cat $HOME/local_nl_cam >> user_nl_cam  && \
    cat $HOME/local_nl_clm >> user_nl_clm && \
    ./xmlchange STOP_N=1 && \
    ./xmlchange STOP_OPTION=ndays && \
    ./case.build 

RUN CASE=case3 && \
    cd $HOME/CESM/cime/scripts && \
    ./create_newcase --case $HOME/cases/vr-cesm$CASE \
    --compset HIST_CAM60_CLM50%BGC_CICE%PRES_DOCN%DOM_MOSART_CISM2%NOEVOLVE_SWAV \
    --res ne0uoslone30x8_ne0uoslone30x8_mt12 --machine espresso \
    --run-unsupported  && \
    cd $HOME/cases/vr-cesm$CASE && \                       
    NUMNODES="$((8*$CESM_PES))"                                   && \
    ./xmlchange --file env_mach_pes.xml --id NTASKS --val ${NUMNODES} && \
    ./xmlchange --file env_mach_pes.xml --id NTASKS_ESP --val 1 && \
    ./xmlchange --file env_mach_pes.xml --id ROOTPE --val 0 && \
    ./case.setup && \
    ./xmlchange EPS_AAREA=0.001 && \
    ./xmlchange ATM_NCPL=144 && \
    cat $HOME/local_nl_cam >> user_nl_cam  && \
    cat $HOME/local_nl_clm >> user_nl_clm && \
    ./xmlchange STOP_N=1 && \
    ./xmlchange STOP_OPTION=ndays && \
    ./case.build 

RUN CASE=case4 && \
    cd $HOME/CESM/cime/scripts && \
    ./create_newcase --case $HOME/cases/vr-cesm$CASE \
    --compset HIST_CAM60_CLM50%BGC_CICE%PRES_DOCN%DOM_MOSART_CISM2%NOEVOLVE_SWAV \
    --res ne0uoslone30x8_ne0uoslone30x8_mt12 --machine espresso \
    --run-unsupported  && \
    cd $HOME/cases/vr-cesm$CASE && \                       
    NUMNODES="$((16*$CESM_PES))"                                   && \
    ./xmlchange --file env_mach_pes.xml --id NTASKS --val ${NUMNODES} && \
    ./xmlchange --file env_mach_pes.xml --id NTASKS_ESP --val 1 && \
    ./xmlchange --file env_mach_pes.xml --id ROOTPE --val 0 && \
    ./case.setup && \
    ./xmlchange EPS_AAREA=0.001 && \
    ./xmlchange ATM_NCPL=144 && \
    cat $HOME/local_nl_cam >> user_nl_cam  && \
    cat $HOME/local_nl_clm >> user_nl_clm && \
    ./xmlchange STOP_N=1 && \
    ./xmlchange STOP_OPTION=ndays && \
    ./case.build 

RUN CASE=case5 && \
    cd $HOME/CESM/cime/scripts && \
    ./create_newcase --case $HOME/cases/vr-cesm$CASE \
    --compset HIST_CAM60_CLM50%BGC_CICE%PRES_DOCN%DOM_MOSART_CISM2%NOEVOLVE_SWAV \
    --res ne0uoslone30x8_ne0uoslone30x8_mt12 --machine espresso \
    --run-unsupported  && \
    cd $HOME/cases/vr-cesm$CASE && \                       
    NUMNODES="$((42*$CESM_PES))"                                   && \
    ./xmlchange --file env_mach_pes.xml --id NTASKS --val ${NUMNODES} && \
    ./xmlchange --file env_mach_pes.xml --id NTASKS_ESP --val 1 && \
    ./xmlchange --file env_mach_pes.xml --id ROOTPE --val 0 && \
    ./case.setup && \
    ./xmlchange EPS_AAREA=0.001 && \
    ./xmlchange ATM_NCPL=144 && \
    cat $HOME/local_nl_cam >> user_nl_cam  && \
    cat $HOME/local_nl_clm >> user_nl_clm && \
    ./xmlchange STOP_N=1 && \
    ./xmlchange STOP_OPTION=ndays && \
    ./case.build 

COPY run_vrcesm $HOME/

WORKDIR $HOME/cases

CMD ["/bin/bash"]

