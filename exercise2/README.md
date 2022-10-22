# Mandatory exercise 2

The code part of the project is implemented in [Elixir](https://elixir-lang.org/). Running the project takes place within [Docker](https://www.docker.com/) containers, using the [docker-compose](https://docs.docker.com/compose/) tool to manage running containers for Alice and Bob.



## Requirements

In order to run this project, you need to have the following:

- Be using a shell like `zsh`
- Have installed the following programs:
  - `make`
  - `openssl`
  - `docker`
  - `docker-compose`
### Usage

#### Initial setup

You firstly need to setup the project by having certificates generated and building the docker container, like so:

```sh
$ make setup
```
#### Running without building

Assuming you've already built the container for the project, you can simply run them:

```sh
$ make run
```

#### Building

To build the docker containers you can run:

```sh
$ make build
```


#### Building and running

To build and run the containers immediately after:

```sh
$ make dev
```

#### Generating new certificates

```sh
$ make gen-certs
```

## Log capture from a game

```log
exercise2-alice-1  | 12:37:34.715 [info] Rolling dice: 6
exercise2-alice-1  | 12:37:34.723 [info] Generating bitstring: "ZdVa30943c87vIatZD0_yMO+4nFTVhH4EtgMXIe5arr5aTMDVHlbafn9YpphCs63k0rmGkJ4AWNf6b0CAANwdPeI9eT0iWUsWzxCy+WgF438iK6+nbFIrX8ptvjTBN5CbO5kCGunpTLpL2WNdBAbAGTAd3QydkYA7I1_2wzTx9MsqxGpmDt1il5rs9YysabJdDDPrgsxgCMpNJh81RvHI2yUwosTVXxH0qlykUlxv+PJvAw4WRjIixvHN1qbJsZQvSYsaDpyipyK09HA6kr9yC9EVbkxgqLzo0Q_7gXpWKntAHwAW2XSP9cGxazrGNAOf5WjOqRe9Q1gTQhF3zs0+w=="
exercise2-alice-1  | 12:37:34.723 [info] Generating commitment: "35VS4inX2SIhkH3AugzQHWJBS90HFTpaUXByppEFcjdRCnJRTF7StJksQfwencPp0EK6JPt8sox9yqaMFNinbg=="
exercise2-alice-1  | 12:37:34.723 [info] Sending commitment to bob:4040
exercise2-bob-1    | 12:37:34.943 [info] Rolling dice: 6
exercise2-bob-1    | 12:37:34.945 [info] Generating bitstring: "t4kFlD9GnjKgwvkN4P3Kjio8jAR61RWVwUnPlVPO4ZQTI5lDBaXHMbAGeYVnxYomS1fN_eTcO4W_bAIYEeEjr_lyT8aMR056VN_5XXbsEBBtNdWmwfX2sVzYKoXWeFwSG3djWAkmFSGR_PQw9v+QdZD93rY3FH27jiGFyRGlg8qevOXona0hnKDzhF3gjxFdZRBefGYUMZdecSa+OcEKqqKVM+xjLW2e6auR6dbLCo2+mYvuuXKtJ3YFazafsMGufaT+jqtPggRqvqXAHZ_jg6NKsn6RpFhcRw_cyW8UrrjPnl7jKF5AAvysbY2fTHI3+PUOapl1t7iW0ipRM4Ygew=="
exercise2-bob-1    | 12:37:34.945 [info] Replying with generated commitment: "reOOzZ8zXzLo0SZNGWe6YUi78FZlFfdk60dunEgNJxuFWNPRm3SSvELivHKTAxOzzJ29XGdarD5jNmQTPhYLhg=="
exercise2-alice-1  | 12:37:34.961 [info] Received commitment from opponent "reOOzZ8zXzLo0SZNGWe6YUi78FZlFfdk60dunEgNJxuFWNPRm3SSvELivHKTAxOzzJ29XGdarD5jNmQTPhYLhg=="..
exercise2-alice-1  | 12:37:34.961 [info] Reveals commitment to opponent
exercise2-bob-1    | 12:37:34.964 [info] Opponent revealing commitment was successful! Game won by draw
exercise2-alice-1  | 12:37:34.967 [info] Received opponent bitstring: "t4kFlD9GnjKgwvkN4P3Kjio8jAR61RWVwUnPlVPO4ZQTI5lDBaXHMbAGeYVnxYomS1fN_eTcO4W_bAIYEeEjr_lyT8aMR056VN_5XXbsEBBtNdWmwfX2sVzYKoXWeFwSG3djWAkmFSGR_PQw9v+QdZD93rY3FH27jiGFyRGlg8qevOXona0hnKDzhF3gjxFdZRBefGYUMZdecSa+OcEKqqKVM+xjLW2e6auR6dbLCo2+mYvuuXKtJ3YFazafsMGufaT+jqtPggRqvqXAHZ_jg6NKsn6RpFhcRw_cyW8UrrjPnl7jKF5AAvysbY2fTHI3+PUOapl1t7iW0ipRM4Ygew=="
exercise2-alice-1  | 12:37:34.967 [info] Received opponent roll: 6
exercise2-alice-1  | 12:37:34.974 [info] Verifies opponent commitment :ok
exercise2-alice-1  | 12:37:34.976 [info] Game result: own:6 vs opponent:6. Verdict: :draw
exercise2-alice-1  | 12:37:34.976 [info] The game has concluded.
```