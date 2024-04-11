# nrn

Cross package manager scripts runner (and more). Why, if there is `ni` ? Switching node versions will require you to reinstall the `ni` every time and i forgor to do that.
I tried [`nrr`](https://github.com/ryanccn/nrr), it's fast, cool and maintained, but it lacks some of core package manager features like `install`, `remove` or `add`.

## benchmarks

Just for fun, i didn't expect to be on par with rust, using nim, but it's cool how high you can jump with this little language. I used decent sized package.json file
from my [Keycap](https://github.com/logotip4ik/keycap) project and added `bench` script with `nuxt help;exit 0`.


```sh
$ hyperfine --warmup 5 'nrn bench' 'nrr bench' 'yarn bench'

Benchmark 1: nrn bench
  Time (mean ± σ):     250.5 ms ±   3.8 ms    [User: 254.9 ms, System: 29.7 ms]
  Range (min … max):   243.6 ms … 256.2 ms    11 runs
 
Benchmark 2: nrr bench
  Time (mean ± σ):     251.7 ms ±   2.4 ms    [User: 255.2 ms, System: 29.9 ms]
  Range (min … max):   249.0 ms … 257.0 ms    11 runs
 
Benchmark 3: yarn bench
  Time (mean ± σ):     879.6 ms ±   8.2 ms    [User: 1039.4 ms, System: 105.0 ms]
  Range (min … max):   870.1 ms … 896.1 ms    10 runs
 
Summary
  nrn bench ran
    1.01 ± 0.02 times faster than nrr bench
    3.51 ± 0.06 times faster than yarn bench
```

