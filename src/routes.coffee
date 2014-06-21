controllers = require './controllers'

module.exports = (app) ->

  app.get '/', (req, res, next) ->
    controllers.main.index req, res, next

  app.get '/auth/callback', controllers.main.callback

  app.get '/home', controllers.main.home

  app.get '/register', controllers.main.register

  app.post '/signUp', controllers.main.signUp

  app.post '/classInfo', controllers.main.classInfo

  app.post '/addClass', controllers.main.addClass

  app.get '/getCalendarData', controllers.main.getCalendarData