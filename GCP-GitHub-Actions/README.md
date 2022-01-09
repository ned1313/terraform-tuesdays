# Deploying infrastructure for GCP with GitHub Actions

In this directory are the necessary files to provision a basic application in GCP using a custom VPC, managed instance groups, and a cloud spanner DB. What application will it run? We'll deploy something really basic. A web page that allows you to vote whether a folded slice of pizza is a taco. (The correct answer is yes.) Each vote will be recorded in the database along with the date and time of the vote. On the main page you'll be able to see the current vote tally and the votes over time by month.

I've never written a web application like this before, so it should be interesting. I'm thinking I'll use Python to do it. The code for the web application and the infrastructure to run it will both be in this directory. We will deploy the application using a basic startup script for each managed instance. Shouldn't take much, just a simple git clone of the desired branch.

