# MPC Docker
## Install guide
Build the docker container:
```
docker build . -t mpc
```

Run the docker container:
```
docker run --rm --name MPC_Docker -v $PWD:/ws --network='host' -it mpc bash
```

Attach a new terminal session to docker:
```
docker exec -it MPC_Docker bash
```
