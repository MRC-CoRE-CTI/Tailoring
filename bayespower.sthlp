{smcl}
{* *! version 0.5.1  24jul2026}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Help artbin (if installed)" "help artbin"}{...}
{viewerjumpto "Syntax" "bayespower##syntax"}{...}
{viewerjumpto "Description" "bayespower##description"}{...}
{viewerjumpto "Options" "bayespower##options"}{...}
{viewerjumpto "Remarks" "bayespower##remarks"}{...}
{viewerjumpto "Examples" "bayespower##examples"}{...}
{title:Title}
{phang}
{bf:bayespower} {hline 2} Power calculation for a Bayesian analysis with a binary outcome

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:bayespower}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Sample sizes (required)}
{synopt:{opt n1(#)}} Sample size in group 1.{p_end}
{synopt:{opt n0(#)}} Sample size in group 0.{p_end}

{syntab:Options specifying the priors (required)}
{synopt:{opt priorspec(ab|ms)}} Whether the beta priors Beta(a,b) below are specified via their alpha and beta parameters (ab) or via their mean and standard deviation (ms). These
are equivalent using m=a/(a+b) and s^2=m(1-m)/(a+b+1).{p_end}
{synopt:{opt prior1d(# #)}} Design prior pi1~Beta(a,b) for the true probability in group 1.{p_end}
{synopt:{opt prior0d(# #)}} Design prior pi0~Beta(a,b) for the true probability in group 0. {p_end}
{synopt:{opt prior1a(# #)}} Analysis prior pi1~Beta(a,b) for the true probability in group 1. {p_end}
{synopt:{opt prior0a(# #)}} Analysis prior pi0~Beta(a,b) for the true probability in group 0. {p_end}

{syntab:Options specifying the problem}
{synopt:{opt delta(#)}} Non-inferiority margin. Default value is 0.{p_end}
{synopt:{opt crit:eria(numlist)}} One or more cut-offs for posterior p(effective).{p_end}
{synopt:{opt noben:efit}} How to handle the possibility of treatment not being truly beneficial 
(i.e. pi1>pi0+delta). nobenefit(fail), the default, handles this as a failure in the power 
calculation, so power is defined as probability of evidence of benefit AND true benefit. The 
alternative, nobenefit(cond), calculates power conditional on true benefit, so power is defined 
as probability of evidence of benefit GIVEN true benefit.{p_end}

{syntab:Calculation options}
{synopt:{opt reps(#)}} Number of trials to be simulated (number of repetitions).  Default value is 10000.{p_end}
{synopt:{opt nofr:eq}} Don't report the analogous power for a frequentist analysis.{p_end}
{synopt:{opt seed(string)}} Random number seed.{p_end}
{synopt:{opt noint:eger}} Allow simulated clinical trials to have fractional data. [Why is this helpful?]{p_end}

{syntab:Output options}
{synopt:{opt nogr:aph}} Don't graph the histogram of posterior p(effective){p_end}
{synopt:{opt col:ours(string)}} Colours to be used in the graph for the cut-off(s) for posterior p(effective){p_end}
{synopt:{opt yp:os(#)}} Vertical position of the text "Proportion with Peff>[criterion]". Default value is 10.{p_end}
{synopt:{opt nopres:erve}} Leaves the simulated trials and their results in memory (one row per trial). Default is to restore the data as it was.{p_end}
{synopt:{opt graph(graph_options)}} Any options for {help graph histogram}.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}bayespower computes the power of a simple two-arm clinical trial with binary outcome, 
allowing the design prior to differ from the analysis prior. 
The design prior is used to sample parameter values when generating the data. 
The analysis prior is used to perform the Bayesian analysis. 
Both priors are assumed to be Beta distributions and hence can be specified by their alpha and beta parameters, or by their mean and standard deviation.

{pstd}The program is based on Supplementary material to the paper by {help bayespower##Turner23:Turner et al}, which:{break}
1. draws the arm-specific outcome probabilities (pi1, pi0) from the Design priors{break}
2. simulates the number of events (d1, d0) for each trial arm{break}
3. forms the posterior using the Analysis priors{break}
4. computes p(effective), the posterior probability that the treatment is effective{break}
5. repeats steps 1-4 for many repetitions

{pstd}The Bayesian power is calculated as the proportion of simulated datsasets for which p(effective) exceeds a cut-off specified in {cmd:criteria()}. The program
also calculates the mean of p(effective), and optionally draws its histogram.

{pstd}The sampling approach captures the discreteness of the sampling distribution,
which makes the Bayesian power non-linear in sample size. This seems unreasonable: if 
a larger sample size reduces power at the chosen criterion, it must still increase power at other criteria. The option
{cmd:nointeger} implements a fix for this, in which a random value drawn from U(-0.5,0.5) is added to each sampled number of events d1, d0.

{pstd}A frequentist power calculation is also reported. This fixes the true parameter values at their prior means and uses standard power software ({help artbin}).


{marker examples}{...}
{title:Examples}

{pstd}The first example from {help bayespower##Turner23:Turner et al} is a redesign of the ODYSSEY trial where outcome proportions are expected to be 0.18 in each arm, 
and the NI margin is 0.1.

{pstd}We first do the Bayesian calculation corresponding to 
the frequentist approach, by setting the Design priors close to point priors at 0.18, and the
Analysis prior as very diffuse (we express no prior information). We expect 
the power to be 90% at a same size of 310 per arm.

{phang}. {stata "bayespower, n1(310) n0(310) priorspec(ab) prior1d(6600 30200) prior0d(6600 30200) prior1a(1 1) prior0a(1 1) delta(.1) seed(3)"}

{pstd}We now do a more Bayesian analysis: the design priors allow the true proportions to vary around the target 0.18 with a SD of 0.02,
while the analysis uses a sceptical prior centred at the null (i.e. with pi1=0.28 and 
pi0=0.18). This gives a much lower power of 41%.

{phang}. {stata "bayespower, n1(310) n0(310) priorspec(ab) prior1d(66 302) prior0d(66 302) prior1a(141 362) prior0a(66 302) delta(.1) seed(3)"}


{title:Stored results}

{synoptset 15 tabbed}{...}
{syntab:Scalars}
{synopt:r(PPB_#)}Estimated probability that p(effective) exceeds 0.# (Bayesian power), where # is the digits after the decimal point for a value specified in {cmd:criteria()}{p_end}
{synopt:r(PPB_#_low)}Lower Monte Carlo confidence limit for r(PPB_#), at {help level:the current significance level}{p_end}
{synopt:r(PPB_#_upp)}Upper Monte Carlo confidence limit for r(PPB_#), at {help level:the current significance level}{p_end}
{synopt:r(freqpow_#)}Calculated frequentist power at significance level #, where # is the digits after the decimal point for a value specified in {cmd:criteria()}{p_end}
{synopt:r(PPBmean)}Estimated expectation of p(effective){p_end}


{title:Reference}

{phang}{marker Turner23}Turner RM et al (2023). ‘Practical approaches to Bayesian sample size 
determination in non‐inferiority trials with binary outcomes’, Statistics in Medicine, 42(8), 
pp. 1127–1138. {browse "https://doi.org/10.1002/sim.9661"}.

{title:Authors}

{pstd}Ian White {browse "mailto:ian.white@ucl.ac.uk":(email)} and Becky Turner.

{pstd}MRC Centre of Research Excellence in Clinical Trial Innovation in partnership with NIHR, UCL, London, UK {break}
UCL Innovative Clinical Trials Unit (formerly MRC Clinical Trials Unit at UCL), London, UK

