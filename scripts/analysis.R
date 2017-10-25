require("ggplot2")

setwd("/home/kanashiro/Documents/USP/masters-degree-qualification/scripts")

data <- read.csv(file="response_time.csv", header=TRUE, sep=",")

data[c('request', 'answer')] <- sapply(data[c('request', 'answer')], function(x) as.POSIXct(x, format="%Y-%m-%dT%H:%M:%S", tz="UTC"))
data['result'] <- sapply(data['result'], function(x) factor(x))
#print(data)

##############################################################################

result <- data$result
rate <- as.data.frame(table(result))
#print(rate)

Status <- c("Erro", "Sucesso")
theme_set(theme_gray(base_size = 18))
png('rate.png')
ggplot(rate, aes(result, Freq, fill=Status)) + geom_bar(stat="identity", width=.6) +
xlab("Status da requisição") + ylab("Número de requisições") +
theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
dev.off()

##############################################################################

rate_data <- split(data, data$result)
#print(rate_data[['success']])
success <- rate_data[['success']]
error <- rate_data[['error']]

success$response_time <- success$answer - success$request
#print(success)

theme_set(theme_gray(base_size = 18))
png('response_time.png')
ggplot(data=success, aes(x=success$response_time)) + geom_histogram(breaks=seq(0,360,1), fill="green") +
scale_x_continuous(breaks=seq(0, 360, 50), lim=c(0,360)) +
xlab("Tempo de resposta (segundos)") + ylab("Número de requisições")
dev.off()

##############################################################################

answer <- success$answer
throughput <- as.data.frame(table(answer))
#print(throughput)

theme_set(theme_gray(base_size = 18))
png('throughput.png')
ggplot(throughput, aes(answer, Freq, fill="green")) + geom_bar(stat="identity", width=.4) +
ylab("Número de respostas com sucesso") + xlab("Tempo (segundos)") +
theme(axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.position="none")
dev.off()

##############################################################################

request <- data$request
load <- as.data.frame(table(request))
#print(throughput)

theme_set(theme_gray(base_size = 18))
png('load.png')
ggplot(load, aes(request, Freq, fill="green")) + geom_bar(stat="identity", width=.4) +
ylab("Requisições realizadas por segundo") + xlab("Tempo de simulação (segundos)") +
theme(axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.position="none")
dev.off()

