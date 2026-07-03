/*
Comparing Interventions Used in Practice: Supplemental material
samplesize calcs for supplement.do
Stata program to calculate sample size for Table 1
requires: bayesSS.ado (also supplied)
IW 8/10/2024
*/




//// Set up
ssc install artbin // if needed
* install bayesSS


//// Standard approaches

// Superiority of either of NACRT or NACT over the other
// 90% power for superiority
// Assumes benefit of better treatment = 5%
artbin, pr(.5 .55) power(.9) alpha(.05)

// Superiority of NACRT over NACT: 90% power for superiority. 
// Assumes NACRT benefit = 5% and 50% 3-year DFS 

artbin, pr(.5 .55) power(.9) alpha(.05) onesided

// Non-inferiority of NACT to NACRT. 
// 90% power for non-inferiority
// Assumes treatments equal and NI margin = 5%
artbin, pr(.5 .5) power(.9) margin(-.05) onesided




//// Novel approaches

// Frequentist
// 90% power for p<0.2	
artbin, pr(.5 .55) power(.9) alpha(.2)

artbin, pr(.5 .55) power(.9) alpha(.4) 


// Bayesian design 	
// 90% power for 80-20 evidence
// Assumes benefit of better treatment = 5%
bayesSS, n1(890) n2(890) priormeand1(.5) priormeand2(.55) reps(1000000) ///
	seed(3) nofreq nograph criteria(.80) 

// Expected 80-20 evidence
// Assumes benefit of better treatment = 5%
bayesSS, n1(282) n2(282) priormeand1(.5) priormeand2(.55) reps(1000000) ///
	seed(3) nofreq nograph


// Decision-based approach
/* Explanation: a trial with two-sided alpha=1 always declares statistical 
significance in favour of the arm with better mean outcome, so power is the 
same as probability of declaring the better treatment to be better. Let 
probabilities of good outcome be p1 and p2 where p1<p2. The current 
probability of good outcome is taken as (p1+p2)/2. After the trial, expected 
probability of good outcome is power*p2 + (1-power)*p1. Scaling the current 
probability (p1+p2)/2 as 0 and the best possible probability p2 as 1, the 
post-trial expected probability equates to 2*power-1.
*/
// Expected health benefit is 80% of possible health benefit
artbin, pr(.5 .55) power(.9) alpha(.5) onesided

