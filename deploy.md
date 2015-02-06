# Cron-tasks Deploy

## Basics
* The cron-tasks is deployed via git
* It is run using a node.js task runner called [forever.js](https://github.com/foreverjs/forever).
* Forever is run as a service using a tool called [forever-service](https://github.com/zapty/forever-service)
* The cron tasks run scripts that keep our tools running. [You can find them here](https://github.com/nationalparkservice/cron-tasks/blob/master/taskList.js)

### Install
```
sudo npm install -g forever
sudo npm install -g forever-service
git clone https://github.com/nationalparkservice/cron-tasks.git
cd ./cron-tasks
sudo forever-service install crontasks --script index.js
```

### Using Forever, restarting the service
```
Commands to interact with service places-website
Start   - "sudo start crontasks"
Stop    - "sudo stop crontasks"
Status  - "sudo status crontasks"
Restart - "sudo restart crontasks"
```

#### Note:
"restart service" command works like stop in Ubuntu due to bug in upstart https://bugs.launchpad.net/upstart/+bug/703800

To get around this run the command:

```sudo stop crontasks && sudo start crontasks```
