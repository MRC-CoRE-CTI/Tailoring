/*
bayespower_test.do
Apply bayespower to Bayesian power examples in Becky's paper
IW 3jul2026
*/

prog drop _all
set seed 610160

* like frequentist: n=310/arm
bayespower, n1(310) n0(310) priorspec(ab) ///
	prior1d(6600 30200) prior0d(6600 30200) ///
	prior1a(1 1) prior0a(1 1) ///
	delta(.1) crit(.975) nopreserve nograph format(%6.3f)
assert abs(r(PPB_975) - 0.9) < 0.01

* same problem, alternative formulation
bayespower, n1(310) n0(310) priorspec(ms) ///
	prior1d(.18 .002) prior0d(.18 .002) ///
	prior1a(.5 .28867513) prior0a(.5 .28867513) ///
	delta(.1) crit(.975) nopreserve nograph format(%6.3f)
assert abs(r(PPB_975) - 0.9) < 0.01
* expect power = 90%

* prior SD = 0.2: n=310/arm
bayespower, n1(310) n0(310) priorspec(ab) ///
	prior1d(66 302) prior0d(66 302) ///
	prior1a(1 1) prior0a(1 1) ///
	delta(.1) nograph crit(.975)
assert abs(r(PPB_975) - 0.83) < 0.01
* expect power = 83%

* prior SD = 0.2: n=440/arm
bayespower, n1(440) n0(440) priorspec(ab) ///
	prior1d(66 302) prior0d(66 302) ///
	prior1a(1 1) prior0a(1 1) ///
	delta(.1) nograph crit(.975)
assert abs(r(PPB_975) - 0.9) < 0.01
* expect power = 90%

* "enthusiastic" analysis priors Be(11,48)
bayespower, n1(310) n0(310) priorspec(ab) ///
	prior1d(66 302) prior0d(66 302) ///
	prior1a(11 48) prior0a(11 48) ///
	delta(.1) nograph crit(.975)
assert abs(r(PPB_975) - 0.9) < 0.01
* expect power = 90%

* "sceptical" analysis priors Be(11,48)
bayespower, n1(310) n0(310) priorspec(ab) ///
	prior1d(66 302) prior0d(66 302) ///
	prior1a(141 362) prior0a(66 302) ///
	delta(.1) nograph crit(.975)
assert abs(r(PPB_975) - 0.41) < 0.01
* expect power = 41%

bayespower, n1(760) n0(760) priorspec(ab) ///
	prior1d(66 302) prior0d(66 302) ///
	prior1a(141 362) prior0a(66 302) ///
	delta(.1) crit(.975) graph(name(post1, replace))
assert abs(r(PPB_975) - 0.9) < 0.01
local PPB = r(PPB_975)
* expect power = 90%

// check that corresponding formulations give ~same answers
* (1) small SD = no SD
bayespower, n1(760) n0(760) priorspec(ms) ///
	prior1d(.18 .001) prior0d(.18 .001) ///
	prior1a(.5 .29) prior0a(.5 .29) ///
	delta(.1) crit(.975) nograph seed(3)
local PPB = r(PPB_975)

bayespower, n1(760) n0(760) priorspec(ms) ///
	prior1d(.18 0) prior0d(.18 0) ///
	prior1a(.5 .29) prior0a(.5 .29) ///
	delta(.1) crit(.975) nograph seed(3)
assert `PPB' == r(PPB_975)

* (2) ab = ms
bayespower, n1(760) n0(760) priorspec(ab) ///
	prior1d(18000 82000) prior0d(18000 82000) ///
	prior1a(1 1) prior0a(1 1) ///
	delta(.1) crit(.975) nograph seed(3)
di `PPB', r(PPB_975)
assert abs(`PPB' - r(PPB_975)) < 1E-4
