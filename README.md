<p align="center">
  <img src="http://www.nps.gov/npmap/img/nps-arrowhead-medium.png" alt="NPS Arrowhead">
</p>

# cron-tasks
This is a task manager based off of the [cron](https://github.com/ncb000gt/node-cron) project.

The tasks are defined in the taskList.js file.

Most of the tasks that this script runs are bash scripts that are stored in the ./tasks/ directory.

Scripts are not required to be stored in the ./tasks/ directory, nor are they required to be in bash.

## Task Definitions
```
{
    'enabled': true,
    'interval': '0 15 * * * *', // On the 15 of every hour
    'name': 'Places_POI_update',
    'task': {
      'type': 'script',
      'path': handlebars('/bin/bash {{tasksDir}}/places/update_geojson.sh'),
    }
  }
  ```
  
  *enabled* describes if the particular task is going to run on a schedule
  *name* defines the name of the script
  *task* contains two fields
    *type* Decides if the script is run through the shell or otherwise, "script" is the only think working as of now
    *path* This is the path to the script, it uses handlebars to make it easier to pass parameters
  *interval* is the interval in which the task is run. Intervals are based on the [crontab schedule definitions](http://en.wikipedia.org/wiki/Cron#Predefined_scheduling_definitions) with the exception that seconds can also be defined by using an extra leading column.
  
```
 * * * * * * 
 | │ │ │ │ │
 | │ │ │ │ │
 | │ │ │ │ └───── day of week (0 - 6) (0 to 6 are Sunday to Saturday, or use names; 7 is Sunday, the same as 0)
 | │ │ │ └────────── month (1 - 12)
 | │ │ └─────────────── day of month (1 - 31)
 | │ └──────────────────── hour (0 - 23)
 | └───────────────────────── min (0 - 59)
 └────────────────────────────── seconds (0 - 59)
```
