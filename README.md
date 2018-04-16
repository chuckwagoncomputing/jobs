# jobs
A small, simple app for tracking your small business' jobs.

## Installation
This program uses therecipe/qt.
Follow the instructions for installation found [here](https://github.com/therecipe/qt/wiki/Installation).  
Then clone this project, `cd` into its directory and run `qtdeploy test desktop`

## Setup
You will need a database server to store jobs and a CardDAV server to store customers.  
This app should support Postgres, MySql, MSSQL, and Sqlite, though I have only tested Postgres.  
This app is not for editing and creating customers. There are plenty of contacts apps that can do that.  
Pro tip: Use DAVDroid to sync your contacts to your android phone, then use the built-in Contacts app.
Warning: Do not attempt to use Google's contacts sync service. At best, you will lose data.
