# Mandatory exercise 2

The code part of the project is implemented in [Elixir](https://elixir-lang.org/). Running the project takes place within [Docker](https://www.docker.com/) containers, using the [docker-compose](https://docs.docker.com/compose/) tool to manage running containers for Alice and Bob.

## Requirements

In order to run this project, you need to have the following:

- Ideally run on a UNIX based operating system (MacOS, Linux or WSL).
- Have the `bash` shell available.
- Have installed the following programs:
  - `make`
  - `openssl`
  - `docker`
  - `docker-compose`


### Running the containers from remote

I have built the a version of the image before the handin deadline and pushed it to my own [Docker Hub repository](https://hub.docker.com/r/andreaswachs/itu.sec1.ma2). With this, you can run with the `remote` version of the docker-compose file. This means that you only need to have docker and docker-compose installed on your machine, regardless of OS.
Do note that the images are built on the x86 architecture, from an Intel based MacBook. You might have problems with the pre-built image if you run on an arm based system.

```sh
$ make run-remote
```

### Initial setup

You firstly need to setup the project by having certificates generated and building the docker container, like so:

```sh
$ make setup
```
### Running without building

Assuming you've already built the container for the project, you can simply run them:

```sh
$ make run
```

### Building

To build the docker containers you can run:

```sh
$ make build
```

### Building and running

To build and run the containers immediately after:

```sh
$ make dev
```

### Generating new certificates

```sh
$ make gen-certs
```

## Log capture from a game

```log
exercise2-alice-1  | 05:19:59.783 [info] Rolling dice: 1
exercise2-alice-1  | 05:19:59.793 [info] Generating bitstring: "enmoNSiLUYj5VSe8jqoYOSpmQ0x7Jj6Y1jHPBuwjJ4rXeOB5_UdwNUZjtm5WNMqFNROZEMC9+l7NSfj4wkaxj3OzTJ_lR_sB+N+J0daNP2Gn8D5w0IUYHPU2Cr6f3VkDldDqtoZWslttxAT3BL8G_Y_LiV5XPzWZbwyP6AniHrLYs0K5OisZZbl62FUQ9rlVRMHFsNbAj4oWg4LWwI7_Q1q5X99w90Md4p6pOqSc2LnbSnDLcz1zQuB_Y+XYD+gRk4zm29YuNNRVVY2CQ7AL45tK0yTm_mtZKPGj0EBQL3IIhdIAaXyEZNfW_gYx3_KQiUO4V8ecjEPWRA00ndu54A=="
exercise2-alice-1  | 05:19:59.793 [info] Generating commitment: "bvQb7o5Vu0AHf1YLtor3cSNDAhiwih3BebA0sM2lrsZ9UjB+J+xalYe7A6eMFWCmA39pb5HkYQbmjoY5hwrhXg=="
exercise2-alice-1  | 05:19:59.793 [info] Sending commitment to bob:4040
exercise2-bob-1    | 05:19:59.987 [info] Rolling dice: 3
exercise2-bob-1    | 05:19:59.988 [info] Generating bitstring: "A7nOoiNGXQXxx5XoF8L_d4QTKeu6f9kZUhwAQc0Z6p55W8E2uoavhEOIwi6wD5bDl9jMh2OUgWJvXWFimu_NWxpzCzRmsHULwgNA+EOzCNHXWxoI5nqxOIfyMH+qNtDU1LAcxU8fflf4kAIqCHei4Ze2Vb9oejkkL5hIPYgf6XP_1XGUBEX957tKadq5TJ1wild+vWGF33dqjE2y+FUJjl6mUtu0zOhSil42h_e+SsOioscm26nlQsu_L9KqYAL2BnnJBpN2zYXimA4cHtGrJo2PvX1TgrQRyJyO6wRQO2coo5uPU21rgQMQ+nj+wudeXD0cQbyXX+ilP3jbmoLdqQ=="
exercise2-bob-1    | 05:19:59.988 [info] Replying with generated commitment: "B+FXndvrSYVYEKEeYRsBwBmeXEccD5QNVhruo65feV3Sg2pWFq_+aY2dlxa3gdjXO_pA0cgHkEGHUy0meylDKQ=="
exercise2-alice-1  | 05:20:00.004 [info] Received commitment from opponent "B+FXndvrSYVYEKEeYRsBwBmeXEccD5QNVhruo65feV3Sg2pWFq_+aY2dlxa3gdjXO_pA0cgHkEGHUy0meylDKQ=="..
exercise2-alice-1  | 05:20:00.004 [info] Reveals commitment to opponent
exercise2-bob-1    | 05:20:00.007 [info] Opponent revealing commitment was successful! Results: server roll: 3, client roll: 1. Game won by server
exercise2-alice-1  | 05:20:00.010 [info] Received opponent bitstring: "A7nOoiNGXQXxx5XoF8L_d4QTKeu6f9kZUhwAQc0Z6p55W8E2uoavhEOIwi6wD5bDl9jMh2OUgWJvXWFimu_NWxpzCzRmsHULwgNA+EOzCNHXWxoI5nqxOIfyMH+qNtDU1LAcxU8fflf4kAIqCHei4Ze2Vb9oejkkL5hIPYgf6XP_1XGUBEX957tKadq5TJ1wild+vWGF33dqjE2y+FUJjl6mUtu0zOhSil42h_e+SsOioscm26nlQsu_L9KqYAL2BnnJBpN2zYXimA4cHtGrJo2PvX1TgrQRyJyO6wRQO2coo5uPU21rgQMQ+nj+wudeXD0cQbyXX+ilP3jbmoLdqQ=="
exercise2-alice-1  | 05:20:00.010 [info] Received opponent roll: 3
exercise2-alice-1  | 05:20:00.015 [info] Verifies opponent commitment :ok
exercise2-alice-1  | 05:20:00.016 [info] Game result: own:1 vs opponent:3. Verdict: :loss
exercise2-alice-1  | 05:20:00.016 [info] The game has concluded.```
