library(plyr)																												 
library(reshape2)
library(ggplot2)

# By episode-listener-day, sum up fractional requests. 																												 
accum.req <- ddply(logs.df, c("Address", "Episode", "Date"), .fun = function(x) {
																												 	 c(Accumulated = sum(x[, "Fraction"]),
																														 Requests = nrow(x))
																												 })																														 
																												 

# round down to 1 for overages
# this is a potential source of measurement error. 

accum.req[, "Accumulated"] <- pmin(1, accum.req[, "Accumulated"])

# Desktop podcatchers (of which iTunes is basically the only one) 
# grab the whole file in one request.

itunes.req <- accum.req[, "Requests"] == 1 & accum.req[, "Accumulated"] > 0.9


# By week

accum.req[, "Week"] <- cut(accum.req[, "Date"], breaks = "week")
accum.req[, "Week"] <- factor(accum.req[, "Week"],
                           levels = sort(levels(cut(accum.req[, "Date"], breaks = "week")), decreasing = FALSE),
                           ordered = TRUE)		

weekly.df <- ddply(accum.req, c("Episode", "Week"), .fun = function(x) {
																												 	 c(Mean = mean(x[, "Accumulated"]),
																														 Total = nrow(x[x[, "Accumulated"] > 0.05, ]),
																														 Complete = nrow(x[x[, "Accumulated"] > 0.8, ]))
																												 })			
weekly.sum.df <- ddply(weekly.df, "Week", summarise, Complete = sum(Complete), Total = sum(Total))


weekly.sum.df <- melt(weekly.sum.df, id.var = "Week", variable.name = "Type", value.name = "Listeners")   



weekplot <- ggplot(data = weekly.sum.df, aes(x = Week, y = Listeners, fill = Type)) + geom_bar(stat = "identity") +
  								 opts(axis.text.x = theme_text(angle = 45)) +
 									 scale_y_continuous(name = "Downloads") + 
  								 opts(title = expression("Downloads per Week, including partial downloads"))                        																								 																										 
