# nrn

Cross package manager scripts runner (and more). Why, if there is `ni` ? Switching node versions will require you to reinstall the `ni` every time and i forgor to do that.
I tried [`nrr`](https://github.com/ryanccn/nrr), it's fast, cool and maintained, but it lacks some of core package manager features like `install`, `remove` or `add`.

> Note: it currently doesn't pass colors from started process back to the shell ?

## benchmarks

Just for fun, i didn't expect to be on par with rust, using nim, but it's cool how high you can jump with this little language. I used decent sized package.json file
from my [Keycap](https://github.com/logotip4ik/keycap) project and added `bench` script with `nuxt help;exit 0`.


```sh
$ hyperfine --warmup 5 'nrn bench' 'nrr bench' 'yarn bench'

Benchmark 1: nrn bench
  Time (mean ± σ):     252.6 ms ±   3.9 ms    [User: 250.5 ms, System: 32.9 ms]
  Range (min … max):   246.7 ms … 257.4 ms    11 runs
 
Benchmark 2: nrr bench
  Time (mean ± σ):     252.5 ms ±   4.0 ms    [User: 253.1 ms, System: 30.4 ms]
  Range (min … max):   245.8 ms … 260.0 ms    11 runs
 
Benchmark 3: yarn bench
  Time (mean ± σ):     885.5 ms ±   6.9 ms    [User: 1040.5 ms, System: 110.8 ms]
  Range (min … max):   876.7 ms … 895.1 ms    10 runs
 
Summary
  nrr bench ran
    1.00 ± 0.02 times faster than nrn bench
    3.51 ± 0.06 times faster than yarn bench
```

