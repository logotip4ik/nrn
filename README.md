# nrn

Cross package manager scripts runner (and more). Why, if there is `ni` ? Switching node versions will require you to reinstall the `ni` every time and i forgor to do that.
I tried [`nrr`](https://github.com/ryanccn/nrr), it's fast, cool and maintained, but it lacks some of core package manager features like `install`, `remove` or `add`.

## Build

You firstly need to go into `src` folder and have nim installed.

```sh
$ nim c -d:release --opt:speed --passC:-flto --passL:-flto --passC:-march=native --passL:-march=native --threads:off --out:../release/nrn nrn.nim
```

## Benchmarks

Just for fun, i didn't expect to be (nearly) on par with rust, using nim, but it's cool how high you can jump with this little language. I used decent sized package.json file
from my [Keycap](https://github.com/logotip4ik/keycap) project and added `start` script with `node ./index.js` (where index.js is an empty file).


<small>Mac M3 pro</small>

```sh
$ hyperfine --shell=none --warmup=5 --output=pipe 'nrr start' 'nrn start' 'yarn start'

Benchmark 1: nrr start
  Time (mean ± σ):      21.8 ms ±   0.3 ms    [User: 14.2 ms, System: 4.1 ms]
  Range (min … max):    20.8 ms …  22.4 ms    137 runs
 
Benchmark 2: nrn start
  Time (mean ± σ):      31.6 ms ±   0.5 ms    [User: 17.9 ms, System: 6.6 ms]
  Range (min … max):    30.2 ms …  32.9 ms    95 runs
 
Benchmark 3: yarn start
  Time (mean ± σ):     202.0 ms ±   3.2 ms    [User: 114.8 ms, System: 20.3 ms]
  Range (min … max):   191.9 ms … 204.7 ms    14 runs
 
Summary
  nrr start ran
    1.45 ± 0.03 times faster than nrn start
    9.29 ± 0.19 times faster than yarn start
```
