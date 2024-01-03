USAGE:

1.Specify at the beginning of the script the path where your repository clone folders are.
2.For each repository create a folder and place inside that folder a file named source.txt containing the following data:




Git Repository:

```
repository_type=git
internet_address=https://github.com/example/example.git
branch=example

```

Subversion (SVN) Repository:

```
repository_type=svn
internet_address=https://svn.example.com/repo/trunk
branch=none

```

FTP Server:
Yes, I know there are servers which require a user other than anonymous. Get over it, wait for me to add it or create a pull request 

```
repository_type=ftp
internet_address=ftp://ftp.example.com/path/to/repository
branch=none
```

#Website Scraping
For website scraping, the internet_address should be the base URL of the website
```
repository_type=website
internet_address=https://www.example.com
branch=none
```
Note: Make sure to replace the placeholder values (e.g., internet_address, branch, etc.) with actual values specific to your repositories.


3.Run the script whenever you like, be it a cron job or whatever. the script will now for each repository update the local copy each time you run the script
