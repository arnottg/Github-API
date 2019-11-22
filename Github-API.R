#install.packages("jsonlite")
library(jsonlite)
#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)

oauth_endpoints("github")

myapp <- oauth_app(appname = "Access_Github",
                   key = "322cc5e338050d04a076",
                   secret = "ad15687363f7c3bf5c0376fb0e2298c81db6528f")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/arnottg/repos", gtoken)

# Accounting for http error
stop_for_status(req)

# Extract content from a request
extContent = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(extContent))

# Subset data.frame
gitDF[gitDF$full_name == "arnottg/datasharing", "created_at"]



# The following code is used to interrogate the Github API and return some basic information
#eg: number of followers, number following, my public repositories

myData = GET("https://api.github.com/users/arnottg", gtoken)
myDataContent = content(myData)
myDataDF = jsonlite::fromJSON(jsonlite::toJSON(myDataContent))
myDataDF$followers
myDataDF$following
myDataDF$public_repos

##The followuing code is used to interrogate the Github API to return the same basic info about
# one of my classmates.

otherData = GET("https://api.github.com/users/junghenp", gtoken)
otherDataContent = content(otherData)
otherDataDF = jsonlite::fromJSON(jsonlite::toJSON(otherDataContent))
otherDataDF$followers
otherDataDF$following
otherDataDF$public_repos

