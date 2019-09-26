# SelfContainedDemo
Setup a standalone demo environment without having to deploy any physical or virtual managed entities in a lab.

At the end of this setup OpenMSA will be loaded with:

- A new tenant named BLR
- A customer named Tyrell
- 2 Linux managed entities: HQ and OffWorld


NOTE the 2 linux managed entities are OpenMSA itself (using different loopback address) so they share the same credentials.

# Self Contained Lab Installation process
1) Install OpenMSA docker https://hub.docker.com/r/openmsa/openmsa

docker pull openmsa/openmsa

docker run -d -p 443:443 -p 80:80 -p 222:22 -h openmsa --name OpenMSA --cap-add=NET_ADMIN openmsa/openmsa

2) git clone the Repository

3) copy the OpenMSA_Self_Demo_Setup folder into /root

4) Launch the installation script

cd /root

OpenMSA_Self_Demo_Setup/OpenMSA_Self_Demo_Setup.sh 
