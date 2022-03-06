gem install telegram-bot

ruby ./telegram/bot.rb
npm i reverso-api
node v >= 14

source = open("./telegram/reverso.js").read
context = ExecJS.compile(source)
context.call('exports')

gem install whenever
whenever --update-crontab
bundle exec wheneverize .