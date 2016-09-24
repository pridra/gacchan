CronJob = require('cron').CronJob

sqlite3 = require('sqlite3').verbose()

module.exports = (robot) ->

    DUTY_DB = 'db/duty.db'

    robot.hear /(がっちゃんおはよ！)/i, (msg) ->
        msg.send "ピピッ！"
        return

    robot.hear /(昨日の最後の当番)/i, (msg) ->
        selectDb((lastDuty) ->
            msg.send "#{lastDuty}\nクピ！"
            return
        )
        return

    robot.hear /は([ -~]+)なのです。/i, (msg) ->
        upsertDb(msg.match[1])
        msg.send "クピペッパ！"
        return

    robot.hear /(がっちゃんよろしく！)/i, (msg) ->
        upsertDb("@#{msg.message.user.name}")
        msg.send "クピペッパ！"
        return

    robot.hear /今日の最後の当番は([ -~]+)です。/i, (msg) ->
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
