# Mandatory exercise 2

I am going to solve this exercise using Elixir and its tools provided to host TCP servers and clients. 

TODO:

- [X] Add mutual TLS
  - [X] [Generate certs](https://kevinhoffman.medium.com/mutual-tls-over-grpc-with-elixir-a071d514deb3) for both Alice and Bob:
  - [X] Configure [HTTPoison to work with mutual TLS](https://elixirforum.com/t/2-way-ssl-mutual-tls-with-httpoison-and-hackney/31206/6)
  - [X] Probably need to also look at [this](https://michaelviveros.medium.com/mutual-tls-in-elixir-part-1-httpoison-b8a727669d88) article for mutual TLS
- [X] Add more logging to server module
- [X] General code clean up:
  - [X] Make sure that all commitment business goes through the `Commitment` module
  - [X] Organize Client code in separate functions for cleaner code
  - [X] Organize Server code in separate functions for cleaner code (?)
- [X] Capture logs for the written report
- [ ] Write the report

## Usage






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