CronJob = require('cron').CronJob

sqlite3 = require('sqlite3').verbose()

module.exports = (robot) ->

    DUTY_DB = 'db/duty.db'

    robot.hear /(がっちゃん。おはやう。)/i, (msg) ->
        msg.send "ピピッ！"
        return

    robot.hear /(昨日最後に当番を当てられた人)/i, (msg) ->
        selectDb((lastDuty) ->
            msg.send "#{lastDuty}クピ！"
            return
        )
        return

    robot.hear /(がっちゃんよろしく！)/i, (msg) ->
        upsertDb("@#{msg.message.user.name}")
        msg.send "クピペッパ！"
        return

    robot.hear /本日最後に当番を当てられた人は([ -~]+)です。/i, (msg) ->
        upsertDb(msg.match[1])
        msg.send "クピポー！"
        return

    new CronJob('59 11 * * 1-5', () ->
        robot.send {room: "random"}, "クプー"
        return
    ).start()

    upsertDb = (name) ->
        db = new sqlite3.Database(DUTY_DB)
        console.log "successfully connected."
        db.serialize ->
            db.run "CREATE TABLE IF NOT EXISTS duty (id INTEGER NOT NULL PRIMARY KEY, name TEXT)"
            stmt = db.prepare('INSERT OR REPLACE INTO duty VALUES (?, ?)')
            stmt.run 0, name
            stmt.finalize()
            console.log "table upserted."
            return
        db.close()
        return

    selectDb = (callback) ->
        db = new sqlite3.Database(DUTY_DB)
        console.log "successfully connected."
        db.serialize ->
            db.get 'SELECT name FROM duty', (err, row) ->
                throw err if err
                console.log "table selected."
                callback(row.name)
                return
            return
        db.close()
        return
