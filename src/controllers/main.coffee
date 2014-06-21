FB = require 'fbgraph'
mysql = require 'mysql'
async = require 'async'

conn = mysql.createConnection
  host : 'ticino.ucsd.edu'
  user : 'tritonlink_121'
  password : 'db4TritonLink' 
  database : 'tritonlink_student_db'

conn.connect (err) ->
  if err?
    console.log err

exports.index = (req, res) ->
  authUrl = FB.getOauthUrl
    client_id: '247120735473149'
    redirect_uri: 'http://localhost:3000/auth/callback'
    scope: 'email'
  res.render "index", authUrl: authUrl

exports.register = (req, res) ->    
  res.render "register"

exports.signUp = (req, res) ->
  stmt = 'SELECT stu_internal_id FROM s_student WHERE stu_pid = ' + conn.escape(req.body.pid)
  conn.query stmt, (err,result) ->
    if err?
      console.log err
    else
      console.log req.session.fbUsername
      console.log result
      console.log result[0].stu_internal_id
      req.session.stu_internal_id = result[0].stu_internal_id

      stmt1 = 'INSERT INTO s_student_fbUsername (fbUsername, stu_internal_id) VALUES ('  + conn.escape(req.session.fbUsername) + ',' + conn.escape(result[0].stu_internal_id) + ')'
      console.log stmt1
      conn.query stmt1, (err,result) ->
        if err?
          console.log err
        res.render 'home'

exports.callback = (req, res, next) ->
  FB.authorize
    client_id: '247120735473149'
    client_secret: 'ff3aae689583d354a779c6b8b9030f2b'
    code: req.query.code
    redirect_uri: 'http://localhost:3000/auth/callback'
  , (err, fbRes) ->
    if err?
      return next new Error("Couldn't authenticate!")

    req.session.token = fbRes.access_token
    FB.setAccessToken(fbRes.access_token);
    FB.get '/me', (err, fbRes) ->
      if err? 
        console.log err
      req.session.fbUsername = fbRes.username
      res.render "register"

exports.home = (req, res) ->
  res.render "home"

exports.classInfo = (req, res) ->
  str = req.body.class
  str = /([a-zA-Z]+) ?([0-9]+)/.exec(str).slice 1, 3

  stmt = 'SELECT * FROM s_lec_timings WHERE dpt_department_code = ' + conn.escape(str[0]) + ' AND crs_course_id = ' + conn.escape(str[1])

  conn.query stmt, (err, result) ->
    if err?
      console.log err 
    else
      console.log result
      result = result[0]
      req.session.c_id = result.c_id
      res.render "classInfo", res : result

exports.getCalendarData = (req, res) ->  
  stmt1 = 'SELECT * FROM s_student_courses WHERE stu_internal_id = ' + conn.escape(req.session.stu_internal_id)
  jsonObj = { "classes" : [] }
  
  conn.query stmt1, (err,result) ->
    if err?
      console.log err
    
    func = (thing, callb) ->
      stmt2 = 'SELECT * FROM s_lec_timings WHERE c_id =' + conn.escape(thing.c_id)
      conn.query stmt2, (err, result2) ->
        if err?
          console.log err
          callb err

        jsonObj.classes.push(result2[0])
        callb null

    async.each result, func, (shitsfucked) ->
      schedule = []
      i = 0    
      while i < jsonObj.classes.length
        className = jsonObj.classes[i].dpt_department_code + ' ' + jsonObj.classes[i].crs_course_id
        
        startTime = jsonObj.classes[i].lec_time.split " "
        startTime = startTime[0]
        
        endTime = startTime.split ":"
        endTime = endTime[0] + 1

        classJson = 
          "title" : className
          "start" : null
          "end" : null

        console.log jsonObj.classes[i].lec_days
        console.log jsonObj.classes[i].lec_days.indexOf "Monday"
        console.log jsonObj.classes[i].lec_days.indexOf "Tuesday"
        console.log jsonObj.classes[i].lec_days.indexOf "Wedday"
        console.log jsonObj.classes[i].lec_days.indexOf "Thurs"
        console.log jsonObj.classes[i].lec_days.indexOf "Fri"

        if jsonObj.classes[i].lec_days.indexOf "Monday" > -1
          console.log "mon"
          classJson = 
            "className" : className
            "start" : '2014-5-26T' + startTime + ':00'
            "end" : '2014-5-26T' + endTime + ':00'
          schedule.push classJson
        
        if jsonObj.classes[i].lec_days.indexOf "Tuesday" > -1
          console.log "tu"
          classJson = 
            "className" : className
            "start" : '2014-5-27T' + startTime + ':00'
            "end" : '2014-5-27T' + endTime + ':00'
          schedule.push classJson

        if jsonObj.classes[i].lec_days.indexOf "Wednesday"  > -1
          console.log "wed"
          classJson = 
            "className" : className
            "start" : '2014-5-28T' + startTime + ':00'  > -1
            "end" : '2014-5-28T' + endTime + ':00'
          schedule.push classJson

        if jsonObj.classes[i].lec_days.indexOf "Thursday"  > -1
          console.log "thurs"
          classJson = 
            "className" : className
            "start" : '2014-5-29T' + startTime + ':00'  > -1
            "end" : '2014-5-29T' + endTime + ':00'
          schedule.push classJson

        if jsonObj.classes[i].lec_days.indexOf "Friday"  > -1
          console.log "fri"
          classJson = 
            "className" : className
            "start" : '2014-5-26T' + startTime + ':00'
            "end" : '2014-5-30T' + endTime + ':00'
          schedule.push classJson
        i++

      res.send JSON.stringify schedule

exports.addClass = (req, res) ->
  stmt = 'INSERT INTO s_student_courses (stu_internal_id, c_id) VALUES (' + conn.escape(req.session.stu_internal_id) + ', ' + conn.escape(req.session.c_id) + ')' 
  conn.query stmt, (err,result) ->
    if err?
      console.log err
  res.render "schedule"
