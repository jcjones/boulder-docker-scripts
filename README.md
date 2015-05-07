These scripts help you to run Boulder + CFSSL in Docker in monolithic mode.

Easy use:

```shell
git clone https://github.com/jcjones/boulder-docker-scripts.git boulder-docker
cd boulder-docker/
./boulder-docker.sh start
```

Note: You will need to execute `boulder-docker.sh` as a user with privileges to access Docker.

You can configure custom locations for the CFSSL storage, and Boulder's configuration, by editing the top of the `boulder-docker.sh` script.

