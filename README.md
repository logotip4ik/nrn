# nrn

Cross package manager scripts runner (and more). Why, if there is `ni` ? Switching node versions will require you to reinstall the `ni` every time and i forgor to do that.
I tried [`nrr`](https://github.com/ryanccn/nrr), it's fast, cool and maintained, but it lacks some of core package manager features like `install`, `remove` or `add`.

## benchmarks

Just for fun, i didn't expect to be on par with rust, using nim, but it's cool how high you can jump with this little language. I used decent sized package.json file
from my [Keycap](https://github.com/logotip4ik/keycap) project and added `test` script with `nuxt help;exit 0`.


<small>Mac M3 pro</small>

```sh
$ hyperfine --warmup 5 'nrn test' 'nrr test' 'yarn test'

Benchmark 1: nrn test
  Time (mean ± σ):     199.2 ms ±   0.6 ms    [User: 185.1 ms, System: 22.5 ms]
  Range (min … max):   198.5 ms … 200.3 ms    15 runs
 
Benchmark 2: ./nrr test
  Time (mean ± σ):     139.6 ms ±   0.7 ms    [User: 138.1 ms, System: 14.5 ms]
  Range (min … max):   138.3 ms … 140.8 ms    21 runs
 
Benchmark 3: yarn test
  Time (mean ± σ):     493.5 ms ±   5.7 ms    [User: 513.1 ms, System: 47.7 ms]
  Range (min … max):   483.3 ms … 504.6 ms    10 runs
 
Summary
  ./nrr test ran
    1.43 ± 0.01 times faster than nrn test
    3.54 ± 0.04 times faster than yarn test
```
