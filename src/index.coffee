path = require 'path'

express = require 'express'
cookieParser = require 'cookie-parser'
session = require 'express-session'
bodyParser = require 'body-parser'
stylus = require 'stylus'
assets = require 'connect-assets'
jade = require 'jade'

app = express()

# Set port
app.port = process.env.PORT or 3000

# Get out config
config = require './config'
# Initialize the config
config.setEnvironment app.settings.env

# Use Rails-esque asset pipeline
app.use assets()
app.use express.static process.cwd() + '/public'
# Automagic parsing of JSON post body, et cetera
app.use cookieParser()
app.use session(secret: 'FUCKINGAWESOMESECRETKEY')
app.use bodyParser()
# Jade, since raw HTML is hard
app.set 'view engine', 'jade'

# Set up our routes
routes = require './routes'
routes app

module.exports = app
