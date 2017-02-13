# TableauUpdateRelated
codes to update database for IWZ online visualization using Tableau

### For TCP program, Iowa DOT

This code is created to calculate desired performance measures of the on-going work zone project in Iowa from the extracted data from HDFS and append result to a Tableau linked database.

3 tags of the visualization panel are dependent on this code:
1. daily performance measure
2. daily event log
3. daily speed heatmaps and sensor condition heatmaps

All codes are converted to excutable jar and scheduled on local machine to daily auto-update the visualization panel on REACTOR website: [REACTOR-IWZ](http://reactor.ctre.iastate.edu/TCP/overview.html)

