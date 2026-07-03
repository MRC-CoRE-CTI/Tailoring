*!	v0.4	IW	2jul2026	make frequentist respect margin; try to match results with Becky's paper
*	v0.3.2	IW	5jun2026
*	v0.3.1	IW	8oct2024
*	v0.3	IW	21jun2024	moved to c:\ian\ado\personal
*	v0.2	IW	13jun2024	moved to n:\home\ado\personal
*	v0.1	IW	18mar2024	in N:\Home\Infections\RISEUP

prog def bayesSS, rclass

/*
Based on Supplementary material to paper by Turner et al, "Practical approaches to Bayesian sample size determination in non-inferiority trials with binary outcomes".

Example use: 
bayesSS, n1(500) n2(500) ///
	priornd1(100000) priormeand1(.03) priorna1(0) priormeana1(0.03) ///
	priornd2(100000) priormeand2(.015) priorna2(0) priormeana2(0.015) ///
	freq graph

Note
	The sampling approach captures the discreteness of the sampling distribution,
		which makes the Bayesian power non-linear in sample size
	Prior specification:
		Argument prior*d1 sets the design prior for p(outcome) in arm 1 (experimental):
			priornd1 = effective sample size of prior
			priormeand1 = prior mean
		Similarly prior*a1 sets the analysis prior in arm 1 etc.
		But priorn*=0 means a spike prior, not a flat prior

To do: 
	make syntax more like artbin including n1() n2() -> n() aratio()
	allow Normal approximation rather than sampling calculation
	pass graph options in graph2()
*/


syntax, n1(int) n2(int) [reps(int 10000) delta(real 0) ///
	priornd1(real 0) priormeand1(real 0.5) priorna1(real 0) priormeana1(real 0.5) ///
	priornd2(real 0) priormeand2(real 0.5) priorna2(real 0) priormeana2(real 0.5) ///
	noFReq noGRaph CRITeria(numlist) COLours(string) YPos(real 10) seed(string) ///
	noPREServe noINTeger debug *]

// PARSING

if mi("`criteria'") local criteria 0.975 0.8
if mi("`colours'") local colours green black blue red

foreach thing in d1 d2 a1 a2 {
	local alpha`thing' =  `priormean`thing'' * `priorn`thing''
	local beta`thing' =  (1-`priormean`thing'') * `priorn`thing''
}

local type = sign(`priormeand2'+`delta'-`priormeand1')
if `type'==0 di as error "Warning: you are calculating power under the null"

if !mi("`debug'") local dicmd dicmd
else local dicmd qui

// END OF PARSING

preserve

clear
qui set obs `reps'
if !mi("`seed'") set seed `seed'
forvalues i = 1/2 {
	// Sample from priors assumed for failure proportions at design stage
	if `priornd`i''>0 gen pi`i' = rbeta(`alphad`i'',`betad`i'')
	else gen pi`i' = `priormeand`i''
	gen r`i' = rbinomial(`n`i'',pi`i')
	if "`integer'"=="nointeger" {
		replace r`i' = r`i' + runiform() - 0.5
		qui replace r`i'=0 if r`i'<0
		qui replace r`i'=`n`i'' if r`i'>`n`i''
	}
	gen p`i' = r`i'/`n`i''

	// Use analysis priors to obtain posterior distributions for failure proportions
	gen pi_postmean`i' = (`alphaa`i''+r`i') / (`alphaa`i''+`betaa`i''+`n`i'')
	gen pi_postvar`i' = (pi_postmean`i'*(1-pi_postmean`i')) / (`alphaa`i''+`betaa`i''+`n`i''+1) // becky had -1
}

gen diff_postmean = pi_postmean1 - pi_postmean2
gen diff_postvar = pi_postvar1 + pi_postvar2

// Rejection of null hypothesis in Bayesian analysis
gen benefit_postprob = normprob(`type'*(`delta' - diff_postmean)/sqrt(diff_postvar))
label var benefit_postprob "Peff: posterior probability that intervention is effective"
qui ci mean benefit_postprob
local col2 _col(43)
local col3 _col(54)
local col4 _col(65)
local col5 _col(76)
di as text "Criterion" `col2' "Value" `col3' "$S_level% Monte Carlo intl" _c
if "`freq'" != "nofreq" di `col5' "Frequent."
else di
di as text "Mean post. prob. of benefit" as result `col2' r(mean) `col3' r(lb) `col4' r(ub) 
local bmean = string(r(mean),"%5.3f")
local PPBmean = r(mean)
local returns PPBmean

tokenize "`colours'"
local thisypos `ypos'
foreach crit of local criteria {
	local col `1'
	if !inrange(`crit',0,1) {
		di as error "Criterion `crit' ignored: not in [0,1]"
		continue
	}
	local critname = strtoname("`crit'")
	if `type'==1 gen peff_gt_`critname'  = (benefit_postprob > `crit') if pi2+`delta'>pi1
	if `type'==-1 gen peff_gt_`critname'  = (benefit_postprob > `crit') if pi2+`delta'<pi1
	label var peff_gt_`critname' "Posterior prob of benefit > `crit'?"
	qui ci prop peff_gt_`critname'
	local PPB`critname' = r(proportion)
	local PPB`critname'_low = r(lb)
	local PPB`critname'_upp = r(ub)
	local crit`critname' = `crit'
	if "`freq'" != "nofreq" {
		local alpha=1-`crit'
		local n=`n1'+`n2'
		local aratio  `n1' `n2'
		`dicmd' artbin, pr(`priormeand1' `priormeand2') n(`n') aratio(`aratio') alpha(`alpha') onesided margin(`delta')
		local freqpow`critname' = r(power)
		local returns `returns' freqpow`critname'
	}
	di as text "Power for post. prob. of benefit > `crit'" as result `col2' `PPB`critname'' `col3' `PPB`critname'_low' `col4' `PPB`critname'_upp' `col5' `freqpow`critname''
	local rejprop`critname' = string(r(proportion),"%5.3f")
	local xlines `xlines' xli(`crit', lcol(`col'))
	local texts `texts' text(`thisypos' `crit' "Proportion with Peff>`crit' = `rejprop`critname''", place(9) col(`col'))
	mac shift
	local thisypos = `thisypos' - `ypos'/10
	local returns `returns' PPB`critname' PPB`critname'_low PPB`critname'_upp
}

foreach thing of local returns {
	return scalar `thing' = ``thing''
}

// Histogram
if "`graph'" != "nograph" {
	di as text _n "--- Drawing histogram ---"
	global F9 histogram benefit_postprob, `xlines' `texts' ///
	note("pE=`priormeand1', pC=`priormeand2', nE=`n1', nC=`n2', non-informative analysis prior" "`reps' simulated trials") ///
	scheme(mrc) `options'
	$F9
}

if "`preserve'"=="nopreserve" restore, not

end
