# Results

List of attempts and results 

### 1st Attempt

* Binary labels only [`positive`, `negative`]
* Sample size `n=907` 
* Support features kept as `factors`
* Support features: `count(Vneg)`, `count(neg)`, `count(pos)`, `count(Vpos)`

| 1 | Actual negative | Actual positive | 
| ---- | ------------ | --------------- | 
| predicted negative | 713 | 154 | 
| predicted positive | 0 | 40 | 

```
# 95 percent confidence interval: 0.8041619 0.8540908
# Final probability of success: 0.8302095 

Improvement: NA
```

### 2nd Attempt

* Binary labels only [`positive`, `negative`]
* Sample size `n=907` 
* Support features converted to `numeric`
* Support features: `count(Vneg)`, `count(neg)`, `count(pos)`, `count(Vpos)`

| 2 | Actual negative | Actual positive | 
| ---- | ------------ | --------------- | 
| predicted negative | 711 | 161 | 
| predicted positive | 2 | 33 | 

```
# 95 percent confidence interval:  0.7937209 0.8447525
# Final probability of success: 0.8202867

Improvement: -0.010138
```

### 3rd Attempt

* Binary labels only [`positive`, `negative`]
* Sample size `n=907` 
* Support features converted to `numeric`
* Support features: `count(Vneg)`, `count(neg)`, `count(pos)`, `count(Vpos)`, `hour_num`, `dayofweek_num`

| 3 | Actual negative | Actual positive | 
| ---- | ------------ | --------------- | 
| predicted negative | 711 | 159 | 
| predicted positive | 4 | 35 | 

```
# 95 percent confidence interval:  0.7941674 0.8450989
# Final probability of success: 0.8206821 

Improvement: +0.0003954
```

### 4th Attempt

* Trinary labels [`positive`, `negative`, `neutral`]
* Sample size `n=1205` 
* Support features converted to `numeric`
* Support features: `count(Vneg)`, `count(neg)`, `count(pos)`, `count(Vpos)`, `hour_num`, `dayofweek_num`, `num_words`

| 4 | Actual negative | Actual neutral | Actual positive | 
| ---- | ------------ | -------------- | --------------- |
| predicted negative | 177 | 11 | 8 
| predicted neutral | 537 | 282 | 154
| predicted positive | 1 | 3 | 32

```
# 95 percent confidence interval:  0.3787464 0.4349884
# Final probability of success 0.406639

Improvement: NA (first trinary attempt)
```

### 5th Attempt

* Trinary labels [`positive`, `negative`, `neutral`]
* Sample size `n=1205` 
* Support features converted to `numeric`
* Support features: `count(Vneg)`, `count(neg)`, `count(pos)`, `count(Vpos)`, `num_words`, `net_score`

| 5 | Actual negative | Actual neutral | Actual positive | 
| ---- | ------------ | -------------- | --------------- |
| predicted negative | 180 | 7 | 6 
| predicted neutral | 525 | 284 | 132
| predicted positive | 10 | 5 | 56

```
# 95 percent confidence interval: 0.4033516 0.4600539
# Final probability of success: 0.4315353

Improvement: +0.0248963
```

### 6th(A) Attempt - Uber Dataset

* Trinary labels [`positive`, `negative`, `neutral`]
* Sample size `n=1468`, *additional `neutral` samples tagged* 
* Support features converted to `numeric`
* Support features: `count(Vneg)`, `count(neg)`, `count(pos)`, `count(Vpos)`, `num_words`, `net_score`

| 6 | Actual negative | Actual neutral | Actual positive | Total |
| ---- | ------------ | -------------- | --------------- | ----- |
| predicted negative | 174 | 34 | 16 | 224 (15%)
| predicted neutral | 219 | 807 | 165 | 1191 (81%)
| predicted positive | 13 | 12 | 79 | 104 (7%)
| Total | 406 (27%) | 853 (56%) | 260 (17%)

```
# 95 percent confidence interval: 0.6740394 0.7208483
# Final probability of success: 0.6978275 

Improvement: +0.2662922
```

### 6th(B) Attempt - Grabtaxi Dataset

* Trinary labels [`positive`, `negative`, `neutral`]
* Sample size `n=1519`, *additional `neutral` samples tagged* 
* Support features converted to `numeric`
* Support features: `count(Vneg)`, `count(neg)`, `count(pos)`, `count(Vpos)`, `num_words`, `net_score`

| 6 | Actual negative | Actual neutral | Actual positive | Total | 
| ---- | ------------ | -------------- | --------------- | ----- |
| predicted negative | 18 | 44 | 175 | 237 (16%)
| predicted neutral | 113 | 740 | 179 | 1032 (70%)
| predicted positive | 137 | 33 | 29 | 199 (14%)
| Total | 268 (20%) | 817 (55%) | 383 (25%)

```
# 95 percent confidence interval: 0.6928107 0.7395618
# Final probability of success: 0.7166213 

Improvement: +0.285086
```

# Conclusion

* Keep support features to `factors` where possible; (eg. for standard features like `days of week` with only 7 options)
* Build more support features where possible; `num_words` and `net_score` most useful; throw all into machine anyway?
* `MAX_ENTROPY` model shows most promise, but can't seem to make it work with trinary labels. 

Overall mostly satisfied with model 6's accuracy considering that trinary labels have 33% chance of guessing correct; 
model prediction about doubles that chance. 

