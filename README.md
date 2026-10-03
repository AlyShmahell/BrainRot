# BrainRot
An interpreter for the [esoteric](https://esolangs.org/wiki/Brainfuck) programming language [Brainfuck](https://brainfuck.org/).

## Installation
- from source
    ```sh
    git clone https://github.com/AlyShmahell/BrainRot
    cd BrainRot
    ./build/run
    ```
    `./build/run` leaves the executable at `build/dist/brainrot`.

- from the latest release
    ```sh
    mkdir -p ~/.local/bin
    curl -L https://github.com/AlyShmahell/BrainRot/releases/latest/download/brainrot -o ~/.local/bin/brainrot
    chmod +x ~/.local/bin/brainrot
    ```
    `~/.local/bin` has to be on `PATH` for `brainrot` to run by name.

## Example Programs
check [examples](examples/)
- [ROT13](https://en.wikipedia.org/wiki/ROT13):
    ```sh
    printf 'Hello, World!' | ./build/dist/brainrot examples/rot13.bf
    ```
    That prints `Uryyb, Jbeyq!`.
