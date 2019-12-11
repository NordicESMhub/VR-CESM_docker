# VR-CESM_docker

docker container for VR-CESM docker container

VR-CESM historic with CAM6 and CLM5 (no ocean) using cesm2_2_beta01.

CESM docker container for HIST_CAM60_CLM50%BGC_CICE%PRES_DOCN%DOM_MOSART_CISM2%NOEVOLVE_SWAV  compset and resolution ne0uoslone30x8_ne0uoslone30x8_mt12.

- Input dataset is stored and available in zenodo (38.7 GB)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3533591.svg)](https://doi.org/10.5281/zenodo.3533591)


## Running VR-CESM with docker

### svn login to access the source code

- The CESM version used is cesm2_2_beta01 that can only be accessible if you authenticate yourself properly. We pass a tarball containing .subversion folder which we used to authenticate ourselves.

First you need to instal subversion:

sudo yum install subversion -y

```
svn co https://svn-ccsm-models.cgd.ucar.edu/cam1/trunk_tags/cam6_1_014/components/cam
```

**Remark**: you may have to install subversion on your virtual machine:

```
sudo yum install subversion -y
```

Enter the correct username and password. Then create the corresponding tarball:

```
cd $HOME
tar cvf subversion.tar .subversion
```
We then save it in a folder that we pass when running the docker container:

```
mkdir -p /opt/uio/svn_config
mv subversion.tar /opt/uio/svn_config/
```

### VR-CESM docker

Make sure inputdata is available (it won't download it as we suppose it is already on disk). 
- The location of the inputdata is `/opt/uio/inputdata` 
- The folder `vr_cesm_config/` contains the changes required for running our Variable resolution grid (made by Colin M. Zarzycki)
- Model outputs are stored in `/opt/uio/archive` along with the `case` folder (it can be interesting to check timing).

**Important**: the folder /opt/uio/archive needs to be writable by unix group `users` (see Dockerfile) otherwise you will get a permission denied when running.

```
sudo chgrp -R users /opt/uio/archive
sudo chmod -R g+w /opt/uio/archive
```

You can check it:

```
ls -lrt /opt/uio | grep archive
```

You should have:

```
drwxrwxr-x.  8 centos users        4096 Nov  9 15:21 archive
```

### Pull and run images

```
docker pull nordicesmhub/cesm_vr:latest
docker run -i -v /opt/uio/inputdata:/home/cesm/inputdata -v /opt/uio/archive:/home/cesm/archive \
              -v /opt/uio/svn_config:/home/cesm/svn_config -t nordicesmhub/cesm_vr:latest
```

- We are running 1 day (144 timestep of 30mn) using 8 processors. It takes about 13GB per processors.

