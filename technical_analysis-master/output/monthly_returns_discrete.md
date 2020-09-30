# Note to the chart 'monthly discrete reutrns':

| Date      | AIR.PA.Open	| AIR.PA.High	| AIR.PA.Low | AIR.PA.Close | AIR.PA.Volume |	AIR.PA.Adjusted |
|-----------|-------------|-------------|------------|--------------|---------------|-----------------|
|2012-12-28 |	29.775 | 29.830 |	29.350 | 29.395 |	836695 | 26.04086 |
|2013-01-31 |	34.250 | 34.980	| 34.130 |	34.605|	1742410 |30.65637 |
|2013-02-28 |	38.000	| 39.250	|37.520	|39.180	 |7888501	| 34.70934|


define p_t as closing price, with t in {0,1,...,T}. 
Then, each point on the curve is given by:

``` 
delta(p)_t = (p_t+1 /p_t) -1
```
So returns are m/m % 
  
### Example

for t =1, ie 2013-01-31, 
```
delta(p)_t = (30.65637 / 26.04086) - 1 = 0.1772 =  + 17.72 %
```
