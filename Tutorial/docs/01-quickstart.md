
```{r setup, include=FALSE}
#make sure to install th etufte package first
#install.packages("tufte")
library(tufte)
# invalidate cache when the tufte version changes
knitr::opts_chunk$set(tidy = FALSE, cache.extra = packageVersion('tufte'))
options(htmltools.dir.version = FALSE)
```

# __Chapter 1:__ Data Preparation{#quickstart}

Each cohort is required to assemble their data into an input file the standard Excel format from  a variety of sources (xls, stata, sas, or r). The input file is used for harmonization and analyses. This chapter guides you through the features of COMETS Analytics using the sample file to provide an introduction to the flow of analyses. 

</div>
<a href="static/COMETSAnalyticsOverview.png" target="_blank"><img src="static/COMETSAnalyticsOverview.png" style="width: 1000%"></a>

## 1.1 Sample Input File
There is a sample file located on the website that will serve as your data input template. After logging in, navigate to the *Correlate* tab. On the lower left side, there is text stating *Download Sample Input*. Click this text, and the sample file will download. This template illustrates how your input data should be formatted, and includes practice data for >600 metabolites and to conduct analyses of age and metabolite, and BMI and metabolite correlations. 

There are five sheets that are required: three of your own data following best practices and two for the project at hand which will be sent by the PI. The detailed requirements are outlined below. A tool is available on COMETS Analytics to help create this file called create input (see [Create Input]).


### Sheet 1: Metabolites
The __*Metabolites*__ sheet contains the meta-data related to the metabolite annotations, where the metabolites are the rows. This sheet requires two input columns: __metabid__ and __metabolite_name__. Additional columns are helpful in the harmonization of metabolites. There are no restrictions on the names of the helpful columns, except HMDB ID and COMP ID should be named __HMDB_ID__ and __COMP_ID__. Additional meta-data include chemical pathways, alternate names, database IDs (HMDB, PubChem, etc.), mass/charge, retention times, etc. This meta-information is important as we are continuously updating the harmonization of metabolite names across studies and platforms. Importantly, the metabolite IDs in the __metabid__ column (*highlighted in yellow*) are required to exactly match the Metabolite IDs used in the metabolite abundance matrix located in the __*SubjectMetabolites*__ sheet.

<span class='textintro'>The __*Metabolites*__ sheet contains the meta-data for metabolites used for harmonization.</span>

<div class="marginnote">
<span class='texta'>**a. metabid**</span> is the name of the metabolites which may be different than the chemical ID with the non-standard characters. This is a required field and text in this column should be an exact match to denote the metabolite columns in __*SubjectMetabolites*__ sheet. 
 
<span class='textb'>**b. metabolite_name** </span> is a required field to denote the biochemical name of the metabolite, with all the non-standard characters.
 
<span class='textc'>**c. Helpful columns**</span> columns C-H are an example of additional metabolite information. If possible, cohorts should include as much metabolite information as possible to help in harmonization, especially mass charge, retention time, and HMDB ID.
 
</div>
<a href="static/input_metabolites.PNG" target="_blank"><img src="static/input_metabolites.png" style="width: 60%"></a>


### Sheet 2: Subject Metabolites
The __*SubjectMetabolites*__ sheet contains the measured metabolite values for the cohort samples. This sheet would typically be your data analysis file, where the metabolites are the columns and the subjects are the rows. The first column in this sheet represents the sample ID. Each subsequent column represents the measured values of one metabolite. The column names in this sheet (*highlighted in yellow*) must match the row names under the column __metabid__ in sheet __*Metabolites*__. Row names in this sheet are hosted in the __SAMPLE_ID__ column (*highlighted in blue*) and are required to match the row names in the sheet __*SubjectData*__. <mark style="background-color: #FFFF00" >Metabolite values should be analyses-ready. Analyses ready means data has been transformed, </mark>

<span class='textintro'>The __*SubjectMetabolites*__ sheet contains the measured metabolite values for the cohort samples.</span>

<div class="marginnote">
<span class='texta'>**a. Metabolite IDs**</span> is indicated in the first row of the sheet to represent all metabolites listed in the __metabid__ column of the the __*Metabolites*__ sheet.
 
<span class='textb'>**b. SAMPLE_ID** </span> contains the study sample IDs, the subject identifier. The column name and IDs must match the __Sample_ID__ column of the __*SubjectData*__ sheet.
 
<span class='textc'>**c.  Each row**</span> corresponds to metabolite data for a single subject sample in the cohort.
 
<span class='textd'>**d. Cells**</span>  reflect the analyses-ready metabolite abundances.
 
</div>
<a href="static/input_subjectmetabolites.png" target="_blank"><img src="static/input_subjectmetabolites.png" style="width: 60%"></a>


### Sheet 3: Subject Data
The __*SubjectData*__ sheet contains the subject-level data where columns are data and each row represents a unique subject. Importantly, the row names in the __*SubjectData*__ sheet must match the row names of the __*SubjectMetabolites*__ sheet (*highlighted in blue*). Columns names (*highlighted in orange*) must correspond to variable names in the __COHORTVARIABLE__ column of the __*VarMap*__ sheet. 

<span class='textintro'>The __*SubjectData*__ sheet contains the subject-level covariate data (all other information besides metabolites; the coding is laid out in the __*VarMap*__ sheet) for each sample. </span>

<div class="marginnote">
<span class='texta'>**a. Columns**</span> correspond to subject level covariates, as used in the cohort. Column names are in row 1 and (except the column named __SAMPLE_ID__) must match the entries in the column __COHORTVARIABLE__ from the sheet __*VarMap*__.
 
<span class='textb'>**b. SAMPLE_ID** </span> contains the sample identifiers.The column name and IDs must match the __Sample_ID__ column of the __*SubjectMetabolites*__ sheet

<span class='textc'>**c. Rows**</span> correspond to observations, with each row containing all of the subject-level covariate values for a single subject sample. 

<span class='textd'>**d. Cells**</span> contain subject-level covariate values.
 
</div>
<a href="static/input_subjectdata.png" target="_blank"><img src="static/input_subjectdata.png" style="width: 60%"></a>




### Sheet 4: VarMap
The __*VarMap*__ sheet contains the coding scheme for the covariates in your analysis, and maps the cohort variable names to the COMETS internal variable names. For projects in COMETS, which represent multi-cohort efforts coordinated by a central PI, this scheme will be completed by the PI and sent to you as part of their example data input files. There is no need to modify. 
<span class='textintro'>Example: The cohort variable __bmi__ would be mapped to the COMETS internal variable __bmi_grp__ and must be coded as “0” for BMI<18.5, “1” for BMI 18.5 to <25, “2” for BMI 25 to <30, “3” for BMI 30.0+, and “4” for missing as defined in the column __VARDEFINITION__.  </span>

<div class="marginnote">
<span class='texta'>**a. VARREFERENCE** </span> refers to COMETS internal variable names. Fields highlighted in red, __id__ & __metabolite_id__, are used to ensure accurate mapping of sample input within COMETS Analytics and should not be changed. The remaining fields, *highlighted in green*, correspond to variable names used in model building defined within the __*Models*___ sheet. In cases of single-cohort analyses outside COMETS, these variable names will exactly match variable names in the __COHORTVARIABLE__ column (*highlighted in orange*)
 
<span class='textb'>**b. VARDEFINITION**</span> defines how the variables should be coded.
 
<span class='textc'>**c. COHORTVARIABLE**</span> corresponds to the cohort variable name. The cohort variable identifying individual subjects (*highlighted in blue*) should exactly match the header of Column A in the __*SubjectMetabolites*__ and __*SubjectData*__ sheets. The cohort variable for metabolite identifiers (*highlighted in yellow*) should exactly match the header of Column A in the __*Metabolites*__ sheet. Remaining variables (*highlighted in orange*) should exactly match the column names of covariate variables in the __*SubjectData*__ sheet. 
 
<span class='textd'>**d. VARTYPE**</span> defines whether the variable type is categorical or continuous. As shown in the example image and sample input file, subject and metabolite variables should have NA entered as the variable type.  
 
<span class='texte'>**e. ACCEPTED_VALUES**</span> gives expected values for categorical covariate variables. Input files containing a categorical covariates with values not included in their corresponding cell in the __*VarMap*__ sheet will be flagged during the data integrity check. See \@ref(integrity) [Integrity Checks]. 
 
<span class='textf'>**f. COHORTNOTES**</span> gives additional info for some variables. 
</div>
<a href="static/input_varmap.PNG" target="_blank"><img src="static/input_varmap.PNG" style="width: 60%"></a>


### Sheet 5: Models {#inputmodels}
This __*Models*__ sheet specifies the models to run, with each row representing a different family of models defined by the lead analyst. Model types defined in Column J (*highlighted in purple*) exactly match  different statistical operations implemented in R with default or user-defined options specified in the __*Model_Types*__ sheet. It is **ESSENTIAL** that all variables specified in this sheet (*highlighted in green*) exactly match the corresponding to variable names in the __VARREFERENCE__ column of the __*VarMap*__ sheet. For analyses involving multiple outcomes, exposures, or adjustment variables should be entered into the same cell separated by a space. To run analyses across all metabolites, enter the text "All metabolites" into the appropriate fields as demonstrated in the sample input file. For analyses involving specific metabolites (e.g., lactate lactate), enter each metabolite id as defined in the __metabid__ column of the __*Metabolites*__ sheet (*highlighted in yellow*). 

<span class='textintro'>Specify the analytical models you wish to run. For eaxample, Model “2.1” is named “Gender stratified” and the analysis will be run with “age” as the exposure and “All metabolites” as the outcomes, while adjusting for smoking status (__smk_grp__), BMI (__bmi_grp__), race (__race_grp__), education (__educ_grp__), alcohol consumption (__alc_grp__), and hormone use (__horm_curr__). This analysis will be stratified by gender using the internal COMETS variable __female__. </span> 


 <div class="marginnote"> <span class='texta'>**a. MODEL** </span> contains the model number and the model name. The results files will be named according to the chosen model name.
  
 <span class='textb'>**b. OUTCOMES**</span> specifies which variable(s) will be the dependent variable(s).
  
 <span class='textc'>**c. EXPOSURE**</span> specifies the independent variable of interest. The beta coefficient for this variable will be returned in the results. If the analysis plan includes a categorical exposures, then the lowest value is chosen by default as the referent category for categorical exposures. If analyses requires a different category to be used as a reference this can be defined by subset definition in the __EXPOSURE_REFERENCE__ column (e.g., "age_grp==3" in Model 1.1). See Chapter @ref(advanced)[Conducting Advanced Analyses] [Linear Models] for specific guidance on conducting linear modeling in COMETS Analytics. 
  
 <span class='textd'>**d. ADJUSTMENT**</span> specifies the potential confounders to be included in the model (optional).
  
 <span class='texte'>**e. STRATIFICATION**</span> for stratified analyses only. Results will be returned for all strata within this variable (optional).
  
 <span class='textf'>**f. WHERE**</span> if the analysis is meant to be run on only a subset of the cohort, this column will contain the subset definition (e.g., “age_grp<70” in Model 2.7.1)(optional).
   
 <span class='textg'>**g. Time**</span> if the analysis plan includes survival analysis, this column will contain the variable describing the time to the event modeled as the OUTCOME (e.g., "Time" in Model 6). See Chapter @ref(advanced)[Conducting Advanced Analyses] [Survival Models] for specific guidance on conducting survival analyses in COMETS Analytics.  
 
  <span class='texth'>**h. GROUP**</span> if the analysis plan includes conditional logistic regression, this column will contain the  the variable defining the experimental groups of interest (e.g., "matchedSet" for Model 7). See Chapter @ref(advanced)[Conducting Advanced Analyses] [Logistic Models] for specific guidance on conducting logistic and conditional logistic analyses in COMETS Analytics. 
  
  <span class='texti'>**i. MODEL_TYPE**</span> column used by the analysis PI to define the names of underlying models to be used in each analysis. Each model here type here  (*highlighted in purple*) must exactly match a defined model in the __*Model_Types*__ sheet. See Chapter @ref(advanced)[Conducting Advanced Analyses] for more guidance on creating custom parameters for user-defined model types. 
 
 </div>

<a href="static/input_models.png"><img src="static/input_models.png" style="width: 60%"></a>


## 1.2 Data and Model Integrity {#integrity}
Prior to running the models for analyses, CA conducts multi-level checks to ensure data and models are appropriate for analyses. Please take note of the messages to correct your input file. In some cases, you will not be able to proceed to the analyses step. 

### Data
If any of the following conditions failed, the analyses will be suspended and corrections to the data are required.:

* Missing Subject ID or Metabolite ID in the _VarMap_ sheet (*highlighted in red*)
* Metabolite IDs in the _SubjectMetabolites_ sheet do not match text in the _metabid_ column of the _Metabolites_ sheet (*highlighted in yellow*)
* Variables in the _VarMap_ sheet do not correspond to a column in the _SubjectData_ sheet (*highlighted in orange*)
* Subject IDs in _SubjectData_ and _SubjectMetabolites_ sheets do not match (*highlighted in blue*)

 The data integrity checks will also flag the following but will proceed with the analyses:

* Number of subjects in _SubjectData_ and _SubjectMetabolites_ sheets do not match
* Metabolite abundances from _SubjectMetabolites_ contains duplicate columns (metabolites) or rows (subjects)
* There are duplicate subject IDs in the subject information _SubjectData_ sheet
* There are duplicate metabolite IDs in the metabolite information _Metabolites_ sheet

### Models
Models are also validated using the CARET package to check for the following conditions:

 * Variables with zero variance.
 * Highly correlated covariates. 
 * ???


## 1.3 Harmonization 
The harmonization step will assess whether your cohort's metabolites are available in the master metabolites list, so that a universal ID (named __UID_01__) can be associated with your metabolites. The COMETS master metabolite list contains universal IDs for over 4,500 metabolites and is maintained by IMS and can be sent in advance of the analyses to ensure availability of a universal ID for each of your metabolites. The universal ID ensures alignment of metabolites across the different cohorts to ensure identification for meta-analyses. Metabolite harmonization is made possible by maintaining an up-to-date master list of metabolites across platforms and cohorts to establish a universal metabolite ID. This activity is managed by the data harmonization work group and IMS. In order to maximize harmonization of metabolites, it is important to include as much information (i.e., metabolite meta-data) in the input file such as HMDB ID, KEGG ID, or other identifiers. 



### Harmonization File
<span class='textintro'>The names of metabolites input into the software are automatically harmonized to a common name. This important feature facilitates comparison of metabolites across different studies that use different platforms and/or naming conventions.</span>

<div class="marginnote">

<span class='texta'>**a. metabid**</span> corresponds to metabolite IDs as defined by each individual cohort. The metabolite IDs correspond to the column __metabid__ from the sheet __*Metabolites*__ of the input file.

<span class='textb'>**b. metabolite_names**</span> corresponds to metabolite names as defined by each individual cohort. The metabolite names correspond to the column __metabolite_name__ from the sheet __*Metabolites*__ of the input file.

<span class='textc'>**c. Columns**</span> (except A, B, and C) correspond to metabolite meta-information that was either already present in the input file or was matched from the internal COMETS database. We highly recommend to add at least one public database identifier (e.g., HMDB ID).

<span class='textd'>**d. Rows**</span> correspond to metabolites, with each row containing all available meta-information for one metabolite.

</div>

<a href="static/output_harmonization.png"><img src="static/output_harmonization.png" style="width: 60%"></a>



## 1.4 Quick Analysis with the Sample Input File
To upload your the sample input file to the COMETS Analytics website, please follow these steps:

  1. Select the *Correlate* tab. 
  2. Specify your cohort from the dropdown menu.
  3. Choose your input data file, formatted as described above, using the *Choose File* button.
  4. Once you have uploaded your file the *Check Integrity* button will activate, use this button to check the integrity of your data input file.
  5. If integrity checks fail, please email (Kaitlyn.mazzilli@nih.gov) to troubleshoot. If all integrity checks are passed, as indicated in a green banner above the summary output, please click *Download Results* in the right corner and email the file to comets.analytics@gmail.com.
  6. You may choose to analyze your data in interactive mode, which allows you to select your exposures, outcomes, and covariates of interest. Pictured below is an age x metabolites analysis adjusted for smoking group.
  7. Our analyses will be done in batch mode. Please select *Batch as specified in the input file* on the left panel. Select *All Models* from the drop down menu. You will be prompted to enter an email address. 
  8. After clicking *Run Model* an email will be sent to your account.  Please note that the email will take about 10-15 minutes to arrive but may take longer if others are using COMETS Analytics concurrently.
  9. Please note that the link in the email is only valid for 7 days.  Once you have received the email, please forward it to comets.analytics@gmail.com.
