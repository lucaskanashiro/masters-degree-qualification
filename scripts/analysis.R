require("ggplot2")

setwd("/home/kanashiro/Documents/USP/masters-degree-qualification/scripts")

data <- read.csv(file="response_time.csv", header=TRUE, sep=",")

data[c('request', 'answer')] <- sapply(data[c('request', 'answer')], function(x) strptime(x, "%Y-%m-%dT%H:%M:%S"))
#data[c('request', 'answer')] <- sapply(data[c('request', 'answer')], function(x) as.POSIXct(x, format="%Y-%m-%dT%H:%M:%S", tz="UTC"))
data['result'] <- sapply(data['result'], function(x) factor(x))
data['simulation_time'] <- sapply(data['simulation_time'], function(x) as.numeric(x))

convert_time <- function(x) {
	minutes = x / 60
	hours = minutes / 60
	minutes = minutes %% 60
	seconds = x %% 60
	sprintf("%1.0fh %1.0fmin %1.0fs", hours, minutes, seconds)
}

#data['simulatin_request'] <- sapply(data['simulation_time'], convert_time)

#print(data)


##############################################################################

result <- data$result
rate <- as.data.frame(table(result))
#print(rate)

Estado <- c("Erro", "Sucesso")
theme_set(theme_gray(base_size = 18))
png('rate.png')
ggplot(rate, aes(result, Freq, fill=Estado)) + geom_bar(stat="identity", width=.6) +
xlab("Estado da requisição") + ylab("Número de requisições") +
theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
dev.off()

##############################################################################

request <- data$request
#load <- as.data.frame(table(request))
#print(throughput)

data['request_sum'] <- sapply(data['request'], function(x) (as.numeric(format(x, "%H"))*60) + as.numeric(format(x, "%M")) )

initial <- data$request_sum[1] - 1
data['request_sum'] <- sapply(data['request_sum'], function(x) x - initial)

theme_set(theme_gray(base_size = 18))
png('load.png')
ggplot(data, aes(request_sum)) + geom_histogram(col='white') +
ylab("Número de requisições realizadas") + xlab("Tempo (min)") +
theme(legend.position="none")
dev.off()

##############################################################################

rate_data <- split(data, data$result)
#print(rate_data[['success']])
success <- rate_data[['success']]
error <- rate_data[['error']]

success$response_time <- success$answer - success$request
success['request_sum'] <- sapply(success['request'], function(x) (as.numeric(format(x, "%H"))*60) + as.numeric(format(x, "%M")) )
success['request_time'] <- sapply(success['request'], function(x) format(x, "%H:%M"))

success['simulation_response'] <- success['simulation_time'] + success['response_time']
success['simulation_response'] <- sapply(success['simulation_response'], function(x) as.numeric(x))
#success['simulation_response'] <- sapply(success['simulation_response'], convert_time)


rt_resume <- aggregate(success$response_time~success$request_sum, success, mean)
#rt_resume <- merge(aggregate(success$response_time~success$request_sum, FUN=c), success['request_time'])

#rt_resume

time <- unlist(rt_resume[1])
mean <- unlist(rt_resume[2])
plot <- data.frame(time, mean)

#plot['simulation'] <- sapply(plot['time'], function(x) unlist(success[which(success$request_sum == x),]['simulation_time']))
#plot

initial <- plot$time[1] - 1
plot['time'] <- sapply(plot['time'], function(x) x - initial)

#plot['time'] <- sapply(plot['time'], convert_time)


length(which(success$response_time <= 10 & success$response_time > 0))
length(which(success$response_time >= 50))
length(which(success$response_time > 0))

#theme_set(theme_gray(base_size = 18))
#png('response_time.png')
#ggplot(data=success, aes(x=success$response_time)) + geom_histogram(breaks=seq(0,360,1), fill="green") +
#scale_x_continuous(breaks=seq(0, 360, 50), lim=c(0,360)) +
#xlab("Tempo de resposta (s)") + ylab("Número de requisições")
#dev.off()

theme_set(theme_gray(base_size = 18))
png('response_time.png')
ggplot(plot, aes(time, mean)) + geom_bar(stat="identity") +
#scale_x_continuous(breaks=seq(0, 35, 5), lim=c(0,32)) +
xlab("Tempo (min)") + ylab("Média do tempo de resposta (s)")
dev.off()

print("DONE")

##############################################################################

#answer <- success$answer
#throughput <- as.data.frame(table(answer))
#print(throughput)

success['answer_sum'] <- sapply(success['answer'], function(x) (as.numeric(format(x, "%H"))*60) + as.numeric(format(x, "%M")) )

initial <- success$answer_sum[1] - 1
success['answer_sum'] <- sapply(success['answer_sum'], function(x) x - initial)

theme_set(theme_gray(base_size = 18))
png('throughput.png')
ggplot(success, aes(answer_sum)) + geom_histogram(col='white') +
#scale_x_continuous(breaks=seq(0, 35, 5), lim=c(0,33)) +
ylab("Número de respostas com sucesso") + xlab("Tempo (min)") +
theme(legend.position="none")
dev.off()

print("DONE 2")
