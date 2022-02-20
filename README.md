
# Instructions:
### [1 of 4] Coding Sample_1 - Automated ELISA data processing

<pre>
#### PURPOSE OF THE SHINY APPLICATION:
<p>     Example of Shiny app automating research (ELISA) data munging ( non-proprietary source data ).
<p>     Purpose: This app automates processing of common immunology research data (ELISA reader output).
<p>       App saves time for research scientists, who no longer have do manually clean up
<p>       their data through error prone copying & pasting. Cleaned data can be downloaded in 
<p>       'tidy' format, i.e. suitable for Tableau or SQL database. Data are also plotted for 
<p>       quick review and QC of the data. 
<p>
#### INSTRUCTIONS FOR USE:
<p>     Step 1) Download all files (click the green "Code" button above; download .zip folder)
<p>     Step 2) Extract the zip folder contents 
<p>     Step 3) Open R Studio and run <b>install.packages("shiny")</b> in the console
<p>     Step 4) Open the Shiny app. 
<p>     Step 5) Use the app to upload the example ELISA data, and review the output plots. 
<p>     Step 6) Download the cleaned data for experiment-tailored processing/plotting in Tableau/Spotfire. 
<p>
<p>
</pre>

### [2 of 4] Coding Sample_2 - FACS Analysis & Discussion

<pre>
#### PURPOSE OF THE CODE:
<p>     Example of R analysis using FACS data ( non-proprietary source data ), 
<p>     including munging, plotting, and analysis narrative.
<p>
#### INSTRUCTIONS FOR USE:
<p>     Step 1) Download all files (click the green "Code" button above; download .zip folder)
<p>     Step 2) Extract the zip folder contents
<p>     Step 3) Run the .Rmd file
<p>     Step 4) Use the "Preview" button in R Studio to view the html report output
<p>
<p>
</pre>


### [3 of 4] Coding Sample_3 - Derivation of a prognostic signature KIRC

<pre>
#### PURPOSE OF THE CODE:
<p>     This script derives a prognostic signature for renal cell carcinoma using transcriptomic data (from GDC/TCGA)
<p>     Analysis provides an example of of data exploration, differential expression analysis (Voom/Limma),
<p>     and survival analysis ( taken from the GDC public database )
<p>
#### INSTRUCTIONS FOR USE:
<p>     Step 1) Download all files (click the green "Code" button above; download .zip folder)
<p>     Step 2) Extract the zip folder contents
<p>     Step 3) Optional: Input a local directory where you want the GDC files saved (default download uses be "api" method. Files total 156MB).
<p>     Step 4) Run the .Rmd file using 'knit' OR just look at the included .nb file to view analysis. 
<p>
<p>
</pre>


### [4 of 4] Coding Sample_4 - FASTER FACS - Automated processing of FlowJo statistics

<pre>
#### PURPOSE OF THE CODE:
<p>     Shiny app combines FlowJo-exported stats & experimental metadata and outputs plot-ready tables. 
<p>     User can upload raw FACS stats & download processed data ready for GraphpadPrism or Tableau (or Spotfire), 
<p>     thereby automating appx. twenty-five data processing steps. 
<p>     Non-proprietary demo data are included. 
<p>
#### INSTRUCTIONS FOR USE:
<p>     Step 1) Download all files (click the green "Code" button above; download .zip folder)
<p>     Step 2) Extract the zip folder contents
<p>     Step 3) Install both R & R Studio
<p>     Step 4) Open R Studio and run <b>install.packages("shiny")</b> in the console (this only needs to be done once)
<p>     Step 5) Open the "app_FASTER FACS.R" file in R Studio & then click the "Run App" button. 
<p>             The first time the app is run, it will automatically install required R packages. 
<p>             Package installation may take a few minutes, but it will only happen once. Follow the instructions in the app.
<p>
<p>
</pre>


