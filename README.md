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
  Time (mean ± σ):     251.1 ms ±   3.0 ms    [User: 245.4 ms, System: 33.4 ms]
  Range (min … max):   246.4 ms … 255.9 ms    11 runs
 
Benchmark 2: nrr bench
  Time (mean ± σ):     252.8 ms ±   2.0 ms    [User: 252.4 ms, System: 32.2 ms]
  Range (min … max):   250.5 ms … 256.6 ms    11 runs
 
Benchmark 3: yarn bench
  Time (mean ± σ):     881.8 ms ±   9.6 ms    [User: 1035.9 ms, System: 106.3 ms]
  Range (min … max):   866.3 ms … 897.2 ms    10 runs
 
Summary
  nrn bench ran
    1.01 ± 0.01 times faster than nrr bench
    3.51 ± 0.06 times faster than yarn bench
```

