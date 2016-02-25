# tripper
A simple Sinatra app for interacting with the Twitter API, and graphically displaying results using Chartkick. Deployed on Openshift at <http://www.t-ripper.net/>.

## Deployment

Originally deployed on Heroku and now migrated to [Openshift](https://www.openshift.com/).

## Description

The app allows a user to search by Twitter handle and displays various statistics back, including:

* Pie graph of the sources (devices) the selected user accesses to post to Twitter;
* Bar graph showing the days the user posts to Twitter;
* Timeline of the user's Twitter activity; and
* Timeline showing source/ device activity over time.

## Technical description

Tripper makes use of the [Ruby for Twitter API](https://github.com/sferik/twitter/) and [Chartkick](http://chartkick.com/) 

The app uses [application-only authentication](https://dev.twitter.com/oauth/application-only/) to authenticate to the Twitter API. There is no requirement to use Twitter credentials.

Statistics for the graphs are based on the previous 200 tweets posted by a user. This provides a good baseline of the user's activity, while avoiding [Twitter API rate limits.](https://dev.twitter.com/rest/public/rate-limiting/)


