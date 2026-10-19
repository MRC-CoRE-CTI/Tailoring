<a href="https://www.ucl.ac.uk/population-health-sciences/clinical-trials-and-methodology/about/mrc-centre-research-excellence-clinical-trial-innovation-partnership-nihr"><img src="MRC_CoRE_lock in NIHR RGB.png" width="100%" /></a>

# Better tailoring levels of evidence in trials comparing treatment options in common use: Supplementary materials

This document contains supplementary materials for the commentary:

White IR *et al.* (2026) 'Tailoring levels of evidence in trials
comparing common treatments', *The Lancet*, published online 12 Oct
2026. Available at: <https://doi.org/10.1016/S0140-6736(26)01948-3>.



# Sample size calculation methods

This section gives the concepts and code to compute the sample sizes. A
Stata program "samplesize calcs for supplement.do" and its output are
also available in the supplementary materials at
<https://github.com/MRC-CoRE-CTI/Tailoring>.

## Superiority of either of NACRT or NACT over the other

This is a standard sample size calculation: we find the number of
patients who must be randomised 1:1 between the two arms to have 90%
power to show evidence of superiority of either treatment over the other
at the two-sided 5% significance level (alpha).

One way to do this uses the ``artbin`` program in our ART package [1]:

    artbin, pr(0.50 0.55) power(0.90) alpha(0.05)

All results are given in [Table 1](#table-1-trial-designs).

## Superiority of NACRT over NACT or of NACT over NACRT

This method is not discussed in the main text, but is included here for
completeness.

The previous sample size calculation is changed to test at the
one-sided, rather than two-sided, 5% level:

    artbin, pr(0.50 0.55) power(0.90) alpha(.05) onesided

## Non-inferiority of NACT to NACRT OR Non-inferiority of NACRT to NACT

This method is not discussed in the main text, but is included here for
completeness.

The previous sample size calculation is changed to give 90% power to
show statistically significant evidence of superiority of one treatment,
with a non-inferiority margin of a 5% risk difference:

    artbin, pr(0.50 .5) power(0.90) margin(-.05) onesided

## Novel frequentist

This is the same as the original sample size calculation, but with the
two-sided type 1 error rate increased to 20%:

    artbin, pr(0.50 0.55) power(0.90) alpha(.2)

or to 40%:

    artbin, pr(0.50 0.55) power(0.90) alpha(.4)

## Bayesian design (non-informative prior)

We computed this with the user-written software ``bayespower`` (based on the
methods of Turner et al [2] and available at
<https://github.com/CoRE-CTI/Tailoring>). The command below demonstrates
that the total sample size of 1780 (890+890) is enough to give 90%
probability that the posterior probability of benefit, calculated with
non-informative priors, will exceed 0.8:

    bayespower, n1(890) n0(890) priorspec(ms) 
        prior1d(0.55 0) prior0d(0.50 0) 
        prior1a(0.50 0.29) prior0a(0.50 0.29) 
        seed(3) cutoff(0.80)

In this command, ``priorspec(ms)`` specifies that the design and analysis
priors for the true outcome probabilities in the two arms will be
specified by their mean and standard deviation (SD). The design priors
specified by ``prior1d()`` and ``prior0d()`` are given zero SD, indicating that
the outcome probabilities are fixed (as in the frequentist calculation).
The non-informative analysis priors specified by ``prior1a()`` and ``prior0a()``
are taken as beta(1,1), which has mean 0.50 and standard deviation 0.29.

The command below demonstrates that the total sample size of 564
(282+282) is enough to give 90% probability that the posterior
probability of benefit, calculated with non-informative priors, will
have mean 0.8:

    bayespower, n1(282) n0(282) priorspec(ms) 
        prior1d(0.55 0) prior0d(0.50 0) 
        prior1a(0.50 0.29) prior0a(0.50 0.29) 
        seed(3) cutoff(0.80)

## Decision-based approach

We use standard software for this using the following argument.

1.  Decision theory proposes using the better treatment, regardless of
    the significance level. However, standard sample size software is
    based on significance levels. We use a trick to link these two
    approaches. Suppose treatment A is truly better, and we do a
    one-sided test of the null hypothesis that treatments are equal
    against the alternative that A is better. In this test, the
    one-sided p-value is below 0.5 if and only if the estimated
    treatment difference favours A. So the probability of correctly
    identifying the better treatment equals the power from a standard
    sample size calculation with a highly non-standard 50% one-sided
    significance level.

2.  The expected health benefit, on a scale where equal use of NACT and
    NACRT is 0 and use of the truly better treatment is 1, can be shown
    to equal twice the power to correctly identify the better treatment,
    minus one. A mathematical explanation of this result follows.

Let $p_{A}$ and $p_{B}$ be the probabilities of the adverse outcome on
treatments A and B respectively, and suppose $p_{A} < p_{B}$. The table
shows the probabilities of adverse outcome under various treatment
settings.

  |Treatment       |       Probability of adverse outcome|
  |---|---|
  |Use A (perfect knowledge)    |    $$p_{A}$$|
  |Use B      |            $$p_{B}$$|
  |No data: equal use of A and B |$$(p_{A} + p_{B})/2$$ |
  |Trial data: use A with probability $power$ | $$power \times p_{A} + (1 - power) \times p_{B}$$ |
  |Benefit from perfect knowledge cf no data | $$1/2 \times \left( p_{A} - p_{B} \right)$$|
  |Benefit from trial data cf no data  |  $$(power - 1/2) \times \left( p_{A} - p_{B} \right)$$|

The benefit from trial data, expressed as a fraction of the benefit from
perfect data, is therefore

$$\frac{(power - 1/2) \times \left( p_{A} - p_{B} \right)}{1/2 \times \left( p_{A} - p_{B} \right)} = \frac{(power - 1/2)}{1/2} = 2 \times power - 1.$$

It follows that a trial with 90% power achieves an expected health
benefit which is 80% of the benefit from perfect data
($2 \times 0.9 - 1 = 0.8$).

3.  Hence for expected health benefit of 80% of the maximum, we can use
    standard sample size software with one-sided significance level set
    to 0.5 and the power set to 90%:

        artbin, pr(0.50 0.55) power(0.90) alpha(0.50) onesided

# References

1\. Marley-Zagar E, White IR, Royston P, Barthel FMS, Parmar MKB,
Babiker AG. artbin: Extended sample size for randomized trials with
binary outcomes. *Stata J*. 2023;23(1):24-52.
doi:10.1177/1536867X231161971

2\. Turner RM, Clements MN, Quartagno M, et al. Practical approaches to
Bayesian sample size determination in non‐inferiority trials with binary
outcomes. *Stat Med*. 2023;42(8):1127-1138. doi:10.1002/sim.9661

## Table 1: Trial designs
Possible trial designs for comparing neoadjuvant chemotherapy (NACT) and neoadjuvant chemoradiotherapy (NACRT) in operable squamous oesophageal cancer. 
Non-inferiority calculation assumes the primary outcome rate (e.g.
three-year disease-free survival) is 50% with either treatment and
margin is 5%. All other calculations assume the primary outcome rate is
50% with one treatment and 55% with the other.

| **Trial design**       | **Criterion**        | **Criterion target value**     | **Total sample size required**  | **% relative reduction in sample size**        |
|--------------|-----------|---------|------------|----------|
| **Standard approaches**                                                                           |
| Superiority of either of NACRT or NACT over the other | Power, two-sided alpha (2α) = 5%     | 90%              | 4190             | -|
|Superiority of NACRT over NACT OR Superiority of NACT over NACRT* | Power, one-sided alpha (1α) = 5%     | 90%              | 3414             | 19%         |
| Non-inferiority of NACT to NACRT OR Non-inferiority of NACRT to NACT*    | Power, one-sided alpha (1α) = 5%     | 90%              | 3422             | 18%         |
| **Novel approaches**                                                                           |
| Frequentist | Power, two-sided alpha (2α) = 20%  | 90% |2618 | 38% |
|  | Power, two-sided alpha (2α) = 40% | 90% | 1796 | 57% |
| Bayesian design (non-informative prior)  | Power for 80-20 evidence (>80% probability of superiority) | 90% | 1780 | 58% |
|  | Mean p(effective) | 80% | 564 | 87% |
| Decision-based approach | Expected health benefit as % of possible health benefit compared with equal use of NACT and NACRT  | 80% | 654 | 84% |

\* Assuming community agrees which of NACT/NACRT should be considered as
reference intervention.
