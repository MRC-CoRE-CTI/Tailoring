{smcl}
{* *! version 1.0  2 Jul 2026}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "bayesSS##syntax"}{...}
{viewerjumpto "Description" "bayesSS##description"}{...}
{viewerjumpto "Options" "bayesSS##options"}{...}
{viewerjumpto "Remarks" "bayesSS##remarks"}{...}
{viewerjumpto "Examples" "bayesSS##examples"}{...}
{title:Title}
{phang}
{bf:bayesSS} {hline 2} Power calculation for a Bayesian analysis with a binary outcome

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:bayesSS}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Required}
{synopt:{opt n1(#)}} Sample size in group 1

{synopt:{opt n2(#)}} Sample size in group 0

{syntab:Options specifying the priors}

{synopt:{opt a1d(#)}} "a" value in the design prior pi1~Beta(a,b) for the true probability in group 1. Default value is 0.

{synopt:{opt b1d(#)}} "b" value in the design prior pi1~Beta(a,b) for the true probability in group 1. Default value is 0.

{synopt:{opt a1d(#)}} "a" value in the design prior pi0~Beta(a,b) for the true probability in group 0. Default value is 0.

{synopt:{opt b1d(#)}} "b" value in the design prior pi0~Beta(a,b) for the true probability in group 0. Default value is 0.

{synopt:{opt a1a(#)}} "a" value in the analysis prior pi1~Beta(a,b) for the true probability in group 1. Default value is 0.

{synopt:{opt b1a(#)}} "b" value in the analysis prior pi1~Beta(a,b) for the true probability in group 1. Default value is 0.

{synopt:{opt a1a(#)}} "a" value in the analysis prior pi0~Beta(a,b) for the true probability in group 0. Default value is 0.

{synopt:{opt b1a(#)}} "b" value in the analysis prior pi0~Beta(a,b) for the true probability in group 0. Default value is 0.

{syntab:Options specifying the problem}

{synopt:{opt delta(#)}} Non-inferiority margin. Default value is 0.

{synopt:{opt crit:eria(numlist)}} One or more cut-offs for posterior p(effective)

{synopt:{opt noben:efit}} How to handle the possibility of treatment not being truly beneficial (i.e. pi1>pi0+delta). nobenefit(fail), the default,
handles this as a failure in the power calculation, so power is defined as probability of evidence of benefit AND true 
benefit. nobenefit(cond)
calculates power conditional on true benefit, , so power is defined as probability of evidence of benefit GIVEN true 
benefit.

{syntab:Calculation options}

{synopt:{opt reps(#)}} Number of trials to be simulated (number of repetitions).  Default value is 10000.

{synopt:{opt nofr:eq}} Don't report the analogous power for a frequentist analysis.

{synopt:{opt seed(string)}} Random number seed.

{synopt:{opt noint:eger}} Allow simulated clinical trials to have fractional data. [Why is this helpful?]

{syntab:Output options}

{synopt:{opt nogr:aph}} Don't graph the histogram of posterior p(effective)

{synopt:{opt col:ours(string)}} Colours to be used in the graph for the cut-off(s) for posterior p(effective)

{synopt:{opt yp:os(#)}} Vertical position of the text "Proportion with Peff>[criterion]". Default value is 10.

{synopt:{opt nopres:erve}} Leaves the simulated trials and their results in memory (one row per trial). Default is to restore the data as it was.

{synopt:{opt graph(graph_options)}} Any options for {help graph histogram}.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}bayesSS computes the power of a simple two-arm clinical trial with binary outcome, 
allowing the design prior to differ from the analysis prior. 
The design prior is used to sample parameter values when generating the data. 
The analysis prior is used to perform the Bayesian analysis. 
Both priors are assumed to be Beta distributions and hence can be specified by their effective sample size and their mean.

[it should really be called bayespower]

{pstd}The program is based on Supplementary material to paper by Turner et al, "Practical approaches to Bayesian sample size determination in non-inferiority trials with binary outcomes".

{pstd}The sampling approach captures the discreteness of the sampling distribution,
	which makes the Bayesian power non-linear in sample size.
Prior specification:
	Argument prior*d1 sets the design prior for p(outcome) in arm 1 (experimental):
		priornd1 = effective sample size of prior,
		priormeand1 = prior mean.
	Similarly prior*a1 sets the analysis prior in arm 1 etc.
	But priorn*=0 means a spike prior, not a flat prior


{marker examples}{...}
{title:Examples}

{pstd} This example corresponds to the frequentist approach, because we use large values of priornd to set the design prior as very precise (effectively, we know that theta1=.03 and theta2=0.015)
and we use zero values of priorna to set the analysis prior as very diffuse (we express no prior information):

{phang}. {stata "bayesSS, n1(500) n2(500) priornd1(100000) priormeand1(.03) priorna1(0) priormeana1(0.03) priornd2(100000) priormeand2(.015) priorna2(0) priormeana2(0.015)"}

{pstd} A more Bayesian example where This example corresponds to the frequentist approach, because we use large values of priornd to set the design prior as very precise (effectively, we know that theta1=.03 and theta2=0.015)
and we use zero values of priorna to set the analysis prior as very diffuse (we express no prior information):

{phang}. {stata "bayesSS, n1(500) n2(500) priornd1(100000) priormeand1(.03) priorna1(0) priormeana1(0.03) priornd2(100000) priormeand2(.015) priorna2(0) priormeana2(0.015)"}


{title:Stored results}

{synoptset 15 tabbed}{...}


{title:Author}
{p}



