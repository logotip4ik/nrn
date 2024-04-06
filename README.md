# nrn

Cross package manager scripts runner (and more). Why, if there is `ni` ? Switching node versions will require you to reinstall the `ni` every time and i forgor to do that.
I tried [`nrr`](https://github.com/ryanccn/nrr), it's fast, cool and maintained, but it lacks some of core package manager features like `install`, `remove` or `add` (currently `nrn` also lacks this features, but at this stage `nrn` is only a wip).

## benchmarks

Just for fun, i didn't expect to be on par with rust, using nim, but it's cool how high you can jump with this little language. I used decent sized package.json file from my [Keycap](https://github.com/logotip4ik/keycap) project and added `bench` script with `fd <somefile>`.


```sh
$ hyperfine --warmup 5 --shell=none 'nrr bench' 'nrn bench'

Benchmark 1: nrr bench
  Time (mean ± σ):      10.5 ms ±   1.5 ms    [User: 5.7 ms, System: 8.2 ms]
  Range (min … max):     6.6 ms …  14.2 ms    249 runs
 
Benchmark 2: nrn bench
  Time (mean ± σ):      10.4 ms ±   1.1 ms    [User: 6.8 ms, System: 7.6 ms]
  Range (min … max):     5.9 ms …  13.9 ms    313 runs
 
Summary
  nrn bench ran
    1.01 ± 0.18 times faster than nrr bench
```

