if(!require("httpuv"))install.packages("httpuv")

if(!require("ggplot2"))install.packages("ggplot2")
if(!require("plotly"))install.packages("plotly")
if(!require("httr"))install.packages("httr")
if(!require("devtools"))install.packages("devtools")

if(!require("jsonlite"))install.packages("jsonlite")


# Can be github, linkedin etc depending on application
oauth_endpoints("github")

# Change based on what you
myapp <- oauth_app(appname = "gitInterrogation",
                   key = "b8e681e367792e61c7cb",
                   secret = "03aef5aadcba1e164865cedc44f3c6f4fb35d3d5")

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

#above code sourced from https://towardsdatascience.com/accessing-data-from-github-api-using-r-3633fb62cb08

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

otherData = GET("https://api.github.com/users/junghenp?client_id=b8e681e367792e61c7cb&client_secret=03aef5aadcba1e164865cedc44f3c6f4fb35d3d5")
otherDataContent = content(otherData)
otherDataDF = jsonlite::fromJSON(jsonlite::toJSON(otherDataContent))
otherDataDF$followers
otherDataDF$following
otherDataDF$public_repos

##The following gives real info about my account -> names of my followers, names of people i'm following,
#names of my repos

followers = fromJSON("https://api.github.com/users/arnottg/followers")
followers$login #usernames of followers

following = fromJSON("https://api.github.com/users/arnottg/following")
following$login #usernames of following

repos = fromJSON("https://api.github.com/users/arnottg/repos") #My repo info
repos$name #names of Repos
repos$created_at #Repo Creation date 
repos$full_name #names of repos

myDataDF$bio #My Bio

## The following code is an example of how to get commit messages using my
# own account - this also shows the number of commits through the nrow function

lca <- fromJSON("https://api.github.com/repos/arnottg/Lowest-Common-Ancestor/commits")


lca$commit$message
nrow(lca$commit)
length(lca$comments_url)

# Created Plotly Account - username = arnottg

##Visualisations: I chose to use Siddharth Dushantha's (sdushantha - creator of the Sherlock Project to find usernames across social
#Media Platforms) Github to produce social graphs as their data is likely a lot more interesting than my own.

data = GET("https://api.github.com/users/sdushantha/followers?per_page=100;?client_id=b8e681e367792e61c7cb&client_secret=03aef5aadcba1e164865cedc44f3c6f4fb35d3d5")
stop_for_status(data)
extract = content(data)
#converts Github data into a Data Frame in R
githubDB = jsonlite::fromJSON(jsonlite::toJSON(extract))
#prints out a list of the first 100 followers of sdushantha
githubDB$login

# Adding these usernames to a vector
ids = githubDB$login
userIds = c(ids)

# Creates vector and df to be used to store users
users = c()
usersDF = data.frame(
  username = integer(),
  noFollowing = integer(),
  noFollowers = integer(),
  repos = integer(),
  yearCreated = integer()
)




#loops through users in userIds DF and adds them to users vector and usersDF
for(i in 1:length(userIds))
{
  
  followingURL = paste("https://api.github.com/users/", userIds[i], "/following?client_id=b8e681e367792e61c7cb&client_secret=03aef5aadcba1e164865cedc44f3c6f4fb35d3d5", sep = "")
  followingRequest = GET(followingURL)
  followingContent = content(followingRequest)
  
  #If users don't have any followers then they aren't of much use - they won't be added
  if(length(followingContent) == 0)
  {
    next
  }
  
  followingDF = jsonlite::fromJSON(jsonlite::toJSON(followingContent))
  followingLogin = followingDF$login
  
  #Loop through 'following' users
  for (j in 1:length(followingLogin))
  {
    #Check for duplicate users
    if (is.element(followingLogin[j], users) == FALSE)
    {
      #Adds user to the users vector
      users[length(users) + 1] = followingLogin[j]
      
      #Interrogate API to obtain information from each user
      followingUrl2 = paste("https://api.github.com/users/", followingLogin[j],"?client_id=b8e681e367792e61c7cb&client_secret=03aef5aadcba1e164865cedc44f3c6f4fb35d3d5", sep = "")
      following2 = GET(followingUrl2)
      followingContent2 = content(following2)
      followingDF2 = jsonlite::fromJSON(jsonlite::toJSON(followingContent2))
      
      #Retrieves who the user is following
      followingNumber = followingDF2$following
      
      #Retrieves who follows the user
      followersNumber = followingDF2$followers
      
      #Retrieves how many repositories the user has 
      reposNumber = followingDF2$public_repos
      
      #Retrieve year which each user joined Github
      yearCreated = substr(followingDF2$created_at, start = 1, stop = 4)
      
      #Add users data to a new row in dataframe
      usersDF[nrow(usersDF) + 1, ] = c(followingLogin[j], followingNumber, followersNumber, reposNumber, yearCreated)
      
    }
    next
  }
  #Stop when there are more than 150 users
  if(length(users) > 150)
  {
    break
  }
  next
}


length(users)

#Plotly
#Setting up Plotly for R:
Sys.setenv("plotly_username"="arnottg")
Sys.setenv("plotly_api_key"="ecH9HI95GOgDaNkeOTFN")

#plot 1 - graphs following vs followers again coloured by year
plot1 = plot_ly(data = usersDF, x = ~noFollowing, y = ~noFollowers, text = ~paste("Followers: ", noFollowers, "<br>Following: ", noFollowing), color = ~yearCreated)
plot1

#plot 2 - graphs repositories vs followers coloured by year
plot2 = plot_ly(data = usersDF, x = ~repos, y = ~noFollowers, text = ~paste("Followers: ", noFollowers, "<br>Repositories: ", repos, "<br>Date Created:", yearCreated), color = ~yearCreated)
plot2










#below code is to graph the top 10 most popular languages used by the same 250 users.
languages = c()
#h = data.frame()
for (i in 1:length(users))
{
  RepositoriesUrl = paste("https://api.github.com/users/", users[i], "/repos?client_id=b8e681e367792e61c7cb&client_secret=03aef5aadcba1e164865cedc44f3c6f4fb35d3d5", sep = "")
  Repositories = GET(RepositoriesUrl)
  RepositoriesContent = content(Repositories)
  RepositoriesDF = jsonlite::fromJSON(jsonlite::toJSON(RepositoriesContent))
  RepositoriesNames = RepositoriesDF$name
  
  #Loop through all the repositories of an individual user
  for (j in 1: length(RepositoriesNames))
  {
    
    #Find all repositories and save in data frame
    RepositoriesUrl2 = paste("https://api.github.com/repos/", users[i], "/",  RepositoriesNames[j], "/?client_id=b8e681e367792e61c7cb&client_secret=03aef5aadcba1e164865cedc44f3c6f4fb35d3d5",sep = "")
    Repositories2 = GET(RepositoriesUrl2)
    RepositoriesContent2 = content(Repositories2)
    RepositoriesDF2 = jsonlite::fromJSON(jsonlite::toJSON(RepositoriesContent2))
    language = RepositoriesDF2$language
    #h = cbind(h, RepositoriesDF2$commits_url)
    
    #Removes repositories containing no specific languages
    if (length(language) != 0 && language != "<NA>")
    {
      languages[length(languages)+1] = language
    }
    next
  }
  next
}

#ncol(h)

#head(h)
#Prints the length of the language vector
length(languages)


#Puts 10 most popular languages in table 
allLanguages = sort(table(languages), increasing=TRUE)
top10Languages = as.data.frame(allLanguages[(length(allLanguages)-9):length(allLanguages)])



#x = cbind(top10Languages, rep(0))
 
# for(i in 1:length(RepositoriesDF2)){
#   for(k in 1:10){
#      if(x$languages[k] == RepositoriesDF2$language[i]){
#        print("hi")
#      }
#   }
#    
# }
#  for(i in 1:10){
#    x[i,3] = x[i,3]/x[i,2]
# }
# x
#converts to dataframe
languageDF = as.data.frame(top10Languages)

#Plot 3 - top 10 languages from these users
plot3 <- plot_ly(data = languageDF, labels = ~languageDF$languages, values = ~languageDF$Freq, type = 'pie')
plot3

api_create(plot1, filename = "Followers vs Following")
api_create(plot2, filename = "Followers vs Repositories")
api_create(plot3, filename = "10 Most Popular Languages")

##Attempted to make an average commits vs Repo Language graph & an average merges vs Repo Language graph
#But the Github API only allows a certain number of entries per webpage so this was not possible

