# Spatial Outlay of the recording
- During recording, a chamber was implanted for each monkey over each region. Several insertion windows were fixated on the grid.
![RecordingChamber](../../Figures/RecordingChamber.png)
    - Monkey R: **31** sites in PFC; **31** sites in VIP
    - Monkey W: **24** sites in PFC; **33** sites in VIP
- Each session 8 electrodes (4 pairs) were inserted into each region, thus as random spatial-sampling of the cortex
- Patterns change every several sessions, for PFC locations, see [locations](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/blob/master/code/14.OCPspatial/locations.txt) and [defineLoc_PFC](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/blob/master/code/14.OCPspatial/defineLoc_PFC.m)
- Count of electrodes at each site, see:
![SitesCont_R](../../Figures/SitesCont_R.png)![SitesCont_W](../../Figures/SitesCont_W.png)

# Sensory Beta bursts
- see [BetaTransSpatial](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/blob/master/code/14.OCPspatial/BetaTransSpatial.m)
- The number of channels that Beta onset transient was recorded at each site (in percentage):

<img src="uploads/2a10a856b3575c6853bf4e50a4609539/BetaTransSitesPerc_R.png" width="50%" height="50%"><img src="uploads/9d5556bd249b4ec8641a1a1daa89da69/BetaTransSitesPerc_W.png" width="50%" height="50%">

**The distribution of burst features are not homogeneous across spatial locations**

# Site-average burst prob. fluctuation
- See [Acrossess_Burst_Prof](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/tree/master/code/14.OCPspatial/Acrossess_Burst_Prof.m)
- Average burst-prob. traces at each site

<img src="uploads/2c9d1561f1a42262abe0f23c8d167b74/MonkeyR_Beta.gif" width="33%" height="33%"><img src="uploads/339b0611db620bae7ccc9a439f2835c5/MonkeyR_LowGamma.gif" width="33%" height="33%"><img src="uploads/7526421a50db76ccd8807902a132410b/MonkeyR_HighGamma.gif" width="33%" height="33%">

<img src="uploads/94e203262f842bf64dac40a31e073d32/MonkeyW_Beta.gif" width="33%" height="33%"><img src="uploads/acbc51951888331ff436055c1b897f58/MonkeyW_LowGamma.gif" width="33%" height="33%"><img src="uploads/cc586aa6dd4495e76c213c298539f393/MonkeyW_HighGamma.gif" width="33%" height="33%">

- Snapshots
![MonkeyR_series_all](uploads/724b46c8018156df653dc1b07e91ed3c/MonkeyR_series_all.png)

![MonkeyW_series_all](uploads/2bd63536faf83aaa5473c534772cd6ef/MonkeyW_series_all.png)

# Burst probability for different numbers
- See [Acrossess_Burst_Prob_Num](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/blob/master/code/14.OCPspatial/Acrossess_Burst_Prob_Num.m)
![Samp_sum](uploads/8bbb2f1a9b1915c313f86be88780c656/Samp_sum.png)
- Gifs see `./data/14.OCPspatial/AvgBrstSpatial/bynum`

# Burst sequences
- Burst occurrence in successive order across space can be used to identify bursts of similar origin
<details><summary> Example trials </summary>

- see [Sess_brst_spatial_exp_trls](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/blob/master/code/14.OCPspatial/Sess_brst_spatial_exp_trls.m)

<img src="uploads/ec5e76faa7468c56d21d497c99c09d49/R120525_trl604_Beta.gif" width="33%" height="33%"><img src="uploads/6c528f5d877e2223b2f811d165b8f79e/R120525_trl604_LowGamma.gif" width="33%" height="33%"><img src="uploads/1b334d5b999469a8c956cc1070823cd2/R120525_trl604_HighGamma.gif" width="33%" height="33%">

<img src="uploads/d4ce5363ad0009a776d4d6f329d91fdc/W120915_trl226_Beta.gif" width="33%" height="33%"><img src="uploads/d97ba71986d13769b2875eb57d4ebedb/W120915_trl226_LowGamma.gif" width="33%" height="33%"><img src="uploads/44ae24bd69715d4740a5eee607f8c15f/W120915_trl226_HighGamma.gif" width="33%" height="33%">

</details>

- See section [6.BurstSeq](Burst-sequence-sorting)

# Spatial spread of bursts
- Burst-triggered average spectrograms, see [BTA_spec_pipeline](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/blob/master/code/14.OCPspatial/BTA_spec_pipeline.m) and [BTA_spec](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/blob/master/code/14.OCPspatial/BTA_spec.m):
<details><summary> Example session </summary>

- see [plot_BTA_spec](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/blob/master/code/14.OCPspatial/plot_BTA_spec.m)
![R120410-AD01_Beta](uploads/4ccb86e8655239e10e6de700f8b0ff4b/R120410-AD01_Beta.png)
![R120410-AD01_HighGamma](uploads/de7468c0efc75909ac8ba4464db1f06c/R120410-AD01_HighGamma.png)

</details>

- plot by distance, see [BTA_spec_dist](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/blob/master/code/14.OCPspatial/BTA_spec_dist.m):
![BTA_spec_dist](uploads/6e74727177234ea356339a80c19472c9/BTA_spec_dist.png)

# OCP correlation between channels
- Correlation matrix for each session, see [OCP_corr_sites](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/tree/master/code/14.OCPspatial/OCPcrosscorr/OCP_corr_sites.m)
    - Session-figures at `/mnt/storage/xuanyu/MONKEY/Non-ion/13.PerfOCP/OCPcorrSites_figs`
    <details><summary> Example sessions</summary>

    - Dark bars indicate channels without valid unit
    ![R120501](uploads/520ee6821ce108cfca1f1f5273454e72/R120501.png)
    ![R120508](uploads/8cd159d868033b12187de74753091e8e/R120508.png)

    </details>
## OCP coupling by distance
- Correlation sorted and averaged by distance (binned by the floor value), see [OCP_corr_dist](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/tree/master/code/14.OCPspatial/OCPcrosscorr/OCP_corr_dist.m)
    - In case OCP coupling is biased by electrodes in CSF, the results obtained only from channels with valid neuron (`validneu`) is also displayed
    - All pairs: 4872 (2436 bi-directional pairs)
    - Valid neuron: 2288/4872 (47.0%)
![OCP_corr_dist](uploads/a9403ed588ff488f344bb716f92d6ba2/OCP_corr_dist.png)
- Only Valid neuron plotted (shaded: MSE)
![OCP_corr_dist_validneu](uploads/905e064304371984d828551e26b26250/OCP_corr_dist_validneu.png)

## OCP coupling with spatial layout
- Correlation matrix was sorted by the sites across sessions, average CC displayed as heatmap. See [OCP_corr_sites](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/blob/master/code/14.OCPspatial/OCPcrosscorr/OCP_corr_sites.m)
![OCP_corr_gransites](uploads/c3a27dd174d023f644ffd0dae37d16ff/OCP_corr_gransites.png)
![OCP_corr_gransites_spatial](uploads/4eb795229d0d6bedb06cc40bba6c8415/OCP_corr_gransites_spatial.png)
- spatial glittering added to minimize overlap between lines

## PEV by spatial location
- see [PEVspatial](https://gitlab.lrz.de/jacob_lab/jacoblabmonkey/-/blob/master/code/14.OCPspatial/PEVspatial/PEVspatial.m)
<details><summary> Too few MUAs for each site: </summary>
![PEVspatial_R](uploads/148683bfa67377d8906af7f03d192720/PEVspatial_R.png)
![PEVspatial_W](uploads/d4a370541678fa7bc4fd9eb2e632ddf4/PEVspatial_W.png)
</details>
