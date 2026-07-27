*!	v0.5.2	IW	27jul2026	rename criteria() as cutoffs() option
*	v0.5.1	IW	24jul2026	nicer output format, corrected errors on graph
*	v0.5	IW	3jul2026	new syntax prior1d() etc; results match Becky's paper
*	v0.4	IW	2jul2026	make frequentist respect margin; try to match results with Becky's paper
*	v0.3.2	IW	5jun2026
*	v0.3.1	IW	8oct2024
*	v0.3	IW	21jun2024	moved to c:\ian\ado\personal
*	v0.2	IW	13jun2024	moved to n:\home\ado\personal
*	v0.1	IW	18mar2024	in N:\Home\Infections\RISEUP

prog def bayespower, rclass

/*
Based on Supplementary material to paper by Turner et al, "Practical approaches to Bayesian sample size determination in non-inferiority trials with binary outcomes".

Example use: 
bayespower, n1(310) n0(310) priorspec(a b) ///
	prior1d(66 302) prior0d(66 302) ///
	prior1a(1 1) prior0a(1 1) priorspec(ab) ///
	delta(.1) nograph cutoff(.975)

Note
	The sampling approach captures the discreteness of the sampling distribution,
		which makes the Bayesian power non-linear in sample size
*/


syntax, n1(int) n0(int) /// sample size per arm
	priorspec(string) ///
	prior1d(numlist min=2 max=2) prior0d(numlist min=2 max=2) /// design priors
	prior1a(numlist min=2 max=2) prior0a(numlist min=2 max=2) /// analysis priors
	[delta(real 0) CUToffs(numlist) NOBENefit(string) /// rest of problem specification
	reps(int 10000) noFReq seed(string) noINTeger /// calculation options
	noGRaph COLours(string) YPos(real 10) GRAPHoptions(string) /// graph options
	noPREServe format(string) /// output options
	debug /// undocumented option
	]

// PARSING

if mi("`cutoffs'") local cutoffs 0.975 
if mi("`colours'") local colours green black blue red
local priorspec=subinstr("`priorspec'"," ","",.)
foreach thing in 1d 0d 1a 0a {
	tokenize `prior`thing''
	if "`priorspec'"=="ab" {
		local a`thing' `1'
		local b`thing' `2'
		local priorn`thing' = `a`thing'' +`b`thing''
		local priormean`thing' = `a`thing'' / `priorn`thing''
		local priorsd`thing' = sqrt(`priormean`thing''*(1-`priormean`thing'') / (`priorn`thing''+1))
	}
	else if "`priorspec'"=="ms" {
		local priormean`thing' `1'
		local priorsd`thing' `2'
		if `priorsd`thing''==0 {
			local priorn`thing' = 2E6
			local a`thing' = 1E6
			local b`thing' = 1E6
		}
		local priorn`thing' = `priormean`thing''*(1-`priormean`thing'')/`priorsd`thing''^2-1
		local a`thing' = `priorn`thing'' * `priormean`thing''
		local b`thing' = `priorn`thing'' * (1-`priormean`thing'')
	}
	else {
		di as error "priorspec must be ab or ms"
		exit 198
	}
}
local type = sign(`priormean0d'+`delta'-`priormean1d')
if `type'==0 di as error "Warning: you are calculating power under the null"

if !mi("`debug'") local dicmd dicmd
else local dicmd qui

if mi("`nobenefit'") local nobenefit fail // power = p(sig result & true benefit)
if substr("`nobenefit'",1,4)=="cond" local nobenefit cond // power = p(sig result | true benefit)
if substr("`nobenefit'",1,4)=="cond" local nobenefit cond // power = p(sig result | true benefit)
assert inlist("`nobenefit'", "fail", "cond")

// END OF PARSING

preserve

clear
qui set obs `reps'
if !mi("`seed'") set seed `seed'
forvalues i = 0/1 {
	// Sample from priors assumed for failure proportions at design stage
	if `a`i'd'<1E5 & `b`i'd'<1E5 gen pi`i' = rbeta(`a`i'd',`b`i'd')
	else gen pi`i' = `priormean`i'd' // large a or b are taken as implying point priors
	gen r`i' = rbinomial(`n`i'',pi`i')
	if "`integer'"=="nointeger" {
		replace r`i' = r`i' + runiform() - 0.5
		qui replace r`i'=0 if r`i'<0
		qui replace r`i'=`n`i'' if r`i'>`n`i''
	}
	gen p`i' = r`i'/`n`i''

	// Use analysis priors to obtain posterior distributions for failure proportions
	gen pi_postmean`i' = (`a`i'a'+r`i') / (`a`i'a'+`b`i'a'+`n`i'')
	gen pi_postvar`i' = (pi_postmean`i'*(1-pi_postmean`i')) / (`a`i'a'+`b`i'a'+`n`i''+1) // Becky had -1
}

gen diff_postmean = pi_postmean1 - pi_postmean0
gen diff_postvar = pi_postvar1 + pi_postvar0

// Rejection of null hypothesis in Bayesian analysis
gen benefit_postprob = normprob(`type'*(`delta' - diff_postmean)/sqrt(diff_postvar))
label var benefit_postprob "P(effective): posterior prob. that intervention is effective"
qui ci mean benefit_postprob
local col2 _col(43)
local col3 _col(54)
local col4 _col(65)
local col5 _col(76)
di as text "{hline 27} PROBLEM {hline 26}"
di as text `col2' "Group 1" `col3' "Group 0"
di as text "Sample size" as result `col2' `n1' `col3' `n0'
di as text "Design prior:   mean" as result `col2' `format' `priormean1d' `col3' `format' `priormean0d'
di as text "                SD" as result `col2' `format' `priorsd1d' `col3' `format' `priorsd0d'
di as text "Analysis prior: mean" as result `col2' `format' `priormean1a' `col3' `format' `priormean0a'
di as text "                SD" as result `col2' `format' `priorsd1a' `col3' `format' `priorsd0a'
di as text "Margin" as result `col3' `format' `delta'
di as text "Power is p(evidence of benefit... " as result `col2' _c
if "`nobenefit'"=="fail" di "AND" _c
else di "|" _c
di " true benefit)"
di as text "{hline 62}" _n

if "`freq'" != "nofreq" local moredup "{hline 11}""
di as text "{hline 27} RESULTS {hline 37}`moredup'"
di as text "Cut-off" `col2' "Value" `col3' "$S_level% Monte Carlo intl" _c
if "`freq'" != "nofreq" di `col5' "Frequent."
else di
di as text "Mean post. prob. of benefit" as result `col2' `format' r(mean) `col3' `format' r(lb) `col4' `format' r(ub) 

local bmean = string(r(mean),"%5.3f")
local PPBmean = r(mean)
local returns PPBmean

tokenize "`colours'"
local thisypos `ypos'
foreach cutoff of local cutoffs {
	local col `1'
	if !inrange(`cutoff',0,1) {
		di as error "Cut-off `cutoff' ignored: not in [0,1]"
		continue
	}
	local cutoffname = strtoname("`cutoff'")
	local ifand = cond("`nobenefit'"=="fail", "&", "if")
	local gt = cond(`type'==1,">","<")
	gen peff_gt_`cutoffname'  = (benefit_postprob > `cutoff') `ifand' pi0+`delta' `gt' pi1
	label var peff_gt_`cutoffname' "Posterior prob of benefit > `cutoff'?"
	qui ci prop peff_gt_`cutoffname'
	local PPB`cutoffname' = r(proportion)
	local PPB`cutoffname'_low = r(lb)
	local PPB`cutoffname'_upp = r(ub)
	local cutoff`cutoffname' = `cutoff'
	if "`freq'" != "nofreq" {
		local alpha=1-`cutoff'
		local n=`n1'+`n0'
		local aratio  `n1' `n0'
		`dicmd' artbin, pr(`priormean1d' `priormean0d') n(`n') aratio(`aratio') alpha(`alpha') onesided margin(`delta')
		local freqpow`cutoffname' = r(power)
		local returns `returns' freqpow`cutoffname'
	}
	di as text "Power for post. prob. of benefit > `cutoff'" as result `col2' `format' `PPB`cutoffname'' `col3' `format' `PPB`cutoffname'_low' `col4' `format' `PPB`cutoffname'_upp' `col5' `format' `freqpow`cutoffname''
	local PPB`cutoffname'_formatted = string(`PPB`cutoffname'',"%5.3f")
	local xlines `xlines' xli(`cutoff', lcol(`col'))
	local texts `texts' text(`thisypos' `cutoff' "Proportion with Peff>`cutoff' = `PPB`cutoffname'_formatted'", place(9) col(`col'))
	mac shift
	local thisypos = `thisypos' - `ypos'/10
	local returns `returns' PPB`cutoffname'_upp PPB`cutoffname'_low PPB`cutoffname' 
}
di as text "{hline 73}`moredup'""

foreach thing of local returns {
	return scalar `thing' = ``thing''
}

// Histogram
if "`graph'" != "nograph" {
	di as text _n "Drawing histogram..."
	global F9 histogram benefit_postprob, `xlines' `texts' ///
	note("n1=`n1', n0=`n0', `reps' simulated trials") ///
	scheme(mrc) `graphoptions'
	`dicmd' $F9
}

if "`preserve'"=="nopreserve" restore, not

end
