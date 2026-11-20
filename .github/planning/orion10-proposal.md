# Proposal: simulate a cholesterol study modelled on ORION-10

We propose building simulated clinical trial data modelled on
[ORION-10](https://clinicaltrials.gov/study/NCT03399370), the phase 3 trial
behind the FDA's 2021 approval of inclisiran (Leqvio), a cholesterol-lowering
drug. Every subject would be made up. The trial supplies the design, the
analysis rules and the published results the simulated data must match.

## Why ORION-10

1. **Longitudinal.** Each subject is followed for 18 months, with LDL
   cholesterol measured on Days 90, 150, 270, 330, 450 and 510.
2. **Mixed models.** The primary analysis is a mixed model for repeated
   measures (MMRM). The statistical analysis plan gives it in full, down to
   the SAS code (Appendix 1): treatment, visit, treatment by visit and baseline
   as fixed effects, an unstructured covariance, and Kenward-Roger degrees of
   freedom.
3. **Large.** 1,561 subjects, randomized 1:1 to inclisiran (781) or placebo
   (780).
4. **Public rules.** The full
   [statistical analysis plan](https://cdn.clinicaltrials.gov/large-docs/70/NCT03399370/SAP_001.pdf)
   is posted on ClinicalTrials.gov. It includes two missing-data methods, a
   multiple-imputation "washout" model and a pattern-mixture model, so the
   simulated dropouts can behave like real ones.
5. **Results to check against.** The
   [FDA statistical review](https://www.accessdata.fda.gov/drugsatfda_docs/nda/2022/214012Orig1s000StatR.pdf)
   reports ORION-10's demographics (Table 5) and outcomes, and the
   [NEJM paper](https://doi.org/10.1056/NEJMoa1912387) the treatment effect.
   Fitting the plan's model to the simulated data should give results close to
   the published ones.

## Alternatives considered

| # | Trial | Why not |
|---|---|---|
| 1 | [ODYSSEY LONG TERM](https://clinicaltrials.gov/study/NCT01507831) (alirocumab) | Uses an MMRM too, but its statistical analysis plan isn't public |
| 2 | [CLEAR Harmony](https://clinicaltrials.gov/study/NCT02666664) (bempedoic acid) | Its primary analysis is an analysis of covariance, not a mixed model |
| 3 | [ELIPSE HoFH](https://clinicaltrials.gov/study/NCT03399786) (evinacumab) | 65 subjects, too small |

The candidates came from a census of the statistical analysis plans behind
684 FDA novel drug approvals (2011 to 2026).
