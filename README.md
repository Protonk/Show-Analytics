# How to read analytics for the show.

This will be a rough step-by step guide for anyone who wants to play with show analytics on their own. Some minimal competency is expected, but not much. If I can do it, anyone can.

## Get the data

Rackspace keeps month-day-hour logs in a hidden file on the root level of the cloud container. In order to access it you need to open up Cyberduck (or any FTP client) and show hidden files (Shift+Command+R on Cyberduck). You'll see a folder named `.CDN_ACCESS_LOGS` and inside that a folder named `Podcasts`. Download this folder.

**THIS WILL TAKE SOME FUCKING TIME**

Because rackspace splits up folders by months, days and hours, there are a shitload of folders and subfolders. About 7300 folders organized into 24 folders per day, ~30 folders per month and 10 months (so far). Even though the total file size (when we're done) is less than 20 MB, it takes forever to crawl that many folders. 

You can shorten this considerable if you only download a month or so.

## Flatten and preprocess

Now you have that same folder structure sitting on your computer somewhere. 

In order to do something sensible with this you need to take that 7000-10000 files and fold them into a single file. 

We can do this with the following terminal command:

    >find . -name "*.gz" -exec cat {} \; > ../logs.txt.gz
    
If you're in the top folder (e.g. `Podcasts` or `2012`) that will walk all the subfolders, find everything that's gzipped and write it to one big file in a directory immediately above your current directory. 

Once you've done that you can unzip the file with the terminal (or with The Unarchiver) and you have some gargantuan logs.txt file. 

We're not quite ready yet, though. Rackspace formats logs somewhat strangely and this format has changed over the months since we've started. In most cases it looks like this:

    X.X.X.X - - [24/Jul/2012:23:29:01 +0000] "GET /c281268.r68.cf1.rackcdn.com/The.Impromptu.E26.mp3 HTTP/1.1" 200 65883668 "-" "Instacast/2.2 CFNetwork/548.1.4 Darwin/11.0.0" "-"

So to get it into a relatively well behaved format we use a tiny preprocessing script. You can run it with something like this:

    >perl /path/to/script/preprocess.pl logs.txt > cleaned.txt
    
This assumes you're in the directory that the log files are in. If you aren't you can turn the relative paths (e.g. `logs.txt`) into absolute paths (`/path/to/logs.txt`)

## Set up R 

R is a free statistical programming language/environment with a number of cool packages which make graphs pretty and life easy. You can download it [from here](http://www.r-project.org/) and it will even run on Shadoe's G5 (no promises about the packages though)

Once you have it set up you need to install a few packages so the script can run. You can do this by opening up R and at the console, pasting in the following:

    install.packages("stringr")
    install.packages("plyr")
    install.packages("ggplot2")
    install.packages("reshape2")

You only need to do this once. 

## Run the scripts

There are two scripts, `import.cleaned.r` and `plot.r` (I'm very creative). Both run without much input from you. The only thing you want to check is the path to the cleaned log files. I assume it's on the desktop. If it isn't, change the code to reflect that. 

If you have the right file path you can just type 

    source("/path/to/import.cleaned.r")

to import and convert the data. Same with `plot.r`. 

**This will also take some time**

Because iOS 6 generates an absurd number of requests per download, even a modest number of downloads corresponds to a gigantic log file. I'll improve this performance over time but it's slow for now. 
   

