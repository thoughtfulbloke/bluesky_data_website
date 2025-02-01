library(quarto)

# we want to update the underlying data before updating the site
source("R/update_site_data.R")
named_vars <- global_defaults("Data/datavars.txt")
update_data_csv(named_vars)

# now we rerender the site
quarto_render()

# you could be publishing a public version with a 
# publish command within the script,
# or using some other kind of automated process to make the local site
# a live one.