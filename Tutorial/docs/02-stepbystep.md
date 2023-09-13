---
output:
  pdf_document: default
  html_document: default
---
```{r setup, include=FALSE,echo=FALSE,cache=FALSE}
#make sure to install th etufte package first
#install.packages("tufte")
library(tufte)
# invalidate cache when the tufte version changes
knitr::opts_chunk$set(tidy = FALSE, cache.extra = packageVersion('tufte'))
options(htmltools.dir.version = FALSE)
```


# __Chapter 2:__ Conducting Cohort Data Analyses {#cohort}
This chapter describes the step-by-step process of conducting cohort analyses for correlation analyses. You will need to have an account set-up (see @ref(register)[Registration]) and have the prepared your data in accordance with the format outlined in the sample input file (see Chapter @ref(quickstart)[Data Preparation]).

## Running Models
There are two ways to run models: 1) interactive mode allows you to specify ad hoc models when exploring the data, and 2) batch mode models are prespecified through the model sheet in your input file which can be run one at a time or all models for running all models specified in the models sheet which uses a queueing system.

### Interactive Mode
   <span class='textintro'>Allows you to run individual models to specify model parameters and receive instantaneous results by clicking on interactive model specification.</span>
   
   <div class="marginnote"><span class='texta'>**a. Passed integrity check**</span> after harmonization, if data upload was successful and the data passed COMETS integrity checks, you will get a confirmation message.
    
   <span class='textb'>**b. Specify interactive** </span> by clicking on *Interactive user input* under *Specify Method of Analyses*.
   
   </div>
   
   
<a href="static/output_interactivemode_1.png"><img src="static/output_interactivemode_1.png" style="width: 60%"></a>

#### Explore Your Interactive Mode Output
 <span class='textintro'>Exploring your output. </span>
 
<div class="marginnote">
  <span class='texta'>**a. Correlation results **</span> if successful, click *Download Results*.
 
 <span class='textb'>**b. Specified model parameters ** </span> as defined in the interactive mode.

 <span class='textc'>**c. Correlation coefficient: **</span> Spearman Rank correlation coefficient between the specified outcome and the exposure (adjusting for the __adjvars__, and by strata if applicable).
 
 <span class='textd'>**d. p-value**</span> significance level for the correlation coefficient.
 
 <span class='texte'>**e. n**</span> number of samples included in the specified model.
 
 <span class='textf'>**f. Tag**</span> select metabolites for further analysis. This creates a subset of metabolites that can then be specified in the interactive output.
 
 </div>

<a href="static/output_interactivemode_3.png"><img src="static/output_interactivemode_3.png" style="width: 60%"></a>

**Explore further ** further results can be ordered according to name of outcome, exposure, or __adjvars__, or by correlation coefficient, p-value, or n. Alternatively, you can use the search boxes to search for specific metabolites or define thresholds. 

### Batch Mode

All Models is a special run of the prespecified models. In this mode, all models are run in a queue and you will get the results via email.

## Correlation Analyses Output 
After running your correlation analyses by [Interactive mode] or [Batch mode], results are available under the correlation results and heatmap tabs. For other types of analyses, see [Manual]. Some of the interactive features of the results and heatmap are described below.


### Metabolite Tagging 
The metabolite tagging (*Tag* option) is a feature in the correlate and heatmap tabs to select and create a subset of metabolites for further analysis based on results for further investigation. Once tagged, the list of metabolites can be used in interactive mode to specify other analyses to conduct.

<span class='textintro'>To select and create a subset of metabolites for further analysis based on the correlation results the tag function can be used.
Below an example with age (exposure) and metabolites (outcome) as run in the *Interactive user input Correlation Results* tab. </span>

<div class="marginnote">
<span class='texta'>**a. Set level of significance **</span> in this example the level of significance is defined as p<0.00001.
 
<span class='textb'>**b. Select significant metabolites** </span> by ticking the box all significant metabolites are selected.
 
<span class='textc'>**c. Tag metabolites **</span> by ticking the *Tag* box all selected metabolites are automatically marked.
</div>
<a href="static/output_heatmap3_1.PNG" target="_blank"><img src="static/output_heatmap3_1.PNG" style="width: 60%"></a>


### Create Subset of 'Tagged' Metabolites 

<span class='textintro'>Once the *Tag* button is clicked a screen will appear </span>

<div class="marginnote">
<span class='texta'>**a. Name your Tag **</span> give the subset of metabolites a name (e.g., “age_related_metabolites”). 
 
<span class='textb'>**b. Create Tag **</span> click the button *Create Tag* to create the tag. 
 
<span class='textc'>**c. Tag is created **</span> a new box appears with an overview of your tagged metabolites. Close the newly created tag.
</div>

<a href="static/output_heatmap3_2.PNG" target="_blank"><img src="static/output_heatmap3_2.PNG" style="width: 60%"></a>


### Create A Heatmap 

<span class='textintro'>Go back to the *Interactive user input* and select your newly created subset, using the *Tag* function
</span>

<div class="marginnote">
<span class='texta'>**a. Select your exposure **</span> select the newly created "age_related_metabolites" tag. 
 
<span class='textb'>**b. Select your outcome** </span> select the newly created "age_related_metabolites" tag. 
 
<span class='textc'>**c. Run the model **</span> click the *Run* button.
 
<span class='textd'>**d. Heatmap**</span> select the *Heatmap* tab to view the heatmap. 
</div>
<a href="static/output_heatmap3_3.PNG" target="_blank"><img src="static/output_heatmap3_3.PNG" style="width: 60%"></a>

### The Heatmap 

<span class='textintro'>Exposures are specified on the x-axis and the outcomes on the y-axis. Different features are available in this interface.
</span>

<div class="marginnote">
<span class='texta'>**a. Sort by outcome **</span> the display of the heatmap can be sorted by outcome or exposure (in the *Outcomes Sort By* box). 

<span class='textb'>**b. Sort by strata** </span> when a stratified analysis is performed, the display of the heatmap can be sorted by the different strata (in the *Strata Sort By* box). 
 
<span class='textc'>**c. Choose your color **</span> in the *Palette* box different color schemes for the heatmap can be selected. 
 
<span class='textd'>**d. Adjust plot height and width**</span> the *Plot height* and *Plot width* can be adjusted using their respective boxes. 
</div>

<a href="static/output_heatmap3_4.PNG" target="_blank"><img src="static/output_heatmap3_4.PNG" style="width: 60%"></a>


### The Heatmap (2)

<span class='textintro'>Additional features of the heatmap can be chosen.
</span>

<div class="marginnote">
<span class='texta'>**a. Additional toolbar **</span> when moving the mouse in the top right corner of the graph an extra toolbar will be visible which allows you to:

   Download plot as png
 
   Save and edit plot in cloud
 
   Zoom in and out
 
   Pan
 
   Autoscale
 
   Reset axes
 
   Use Plotly features (e.g., toggle spike lines, show closest data on hover, compare data on hover)  
</div>

<a href="static/output_heatmap3_5.PNG" target="_blank"><img src="static/output_heatmap3_5.PNG" style="width: 60%"></a>


### Annotations and Hierarchical Clustering

<span class='textintro'>Annotations (display of the correlation coefficients in numbers) and hierarchical clustering (showing the metabolite clusters) can be superimposed on the heatmap.
</span>

<div class="marginnote">
<span class='texta'>**a. Annotations **</span> ticking this box will allow you to display the correlation coefficients in the plot. 
 
<span class='textb'>**b. Hierachical clustering **</span> ticking this box will allow you to display the metabolite clusters on the left side of the heatmap. 
 
<span class='textc'>**c. Choose your dimensions **</span> by clicking the *Plot height* and *Plot width* and entering values (e.g., 900 by 1100) the plot will show in the chosen dimensions. 
</div>

<a href="static/output_heatmap3_6.PNG" target="_blank"><img src="static/output_heatmap3_6.PNG" style="width: 60%"></a>



<a href="static/output_heatmap3.PNG" target="_blank"><img src="static/output_heatmap3.PNG" style="width: 60%"></a>

<a href="static/output_heatmap4.PNG" target="_blank"><img src="static/output_heatmap4.PNG" style="width: 60%"></a>


<span class='textintro'>For details on outputs from other models, see the output section of each method under Chapter \@ref(manual) [Manual]. </span>

