## Backup Helix Data Bases

### Backup
Use mongobackup command to get a backup of the Orion Context Broker database. It is strongly recommended that you stop the broker before doing a backup.

```
sudo mongodump --host localhost:27000 --db <database>
```

This will create the backup in the dump/ directory.

### Restore

Use the mongorestore command to restore a previous backup of the Orion Context Broker database. It is strongly recommended that you stop the broker before doing a backup and to remove (drop) the database used by the broker.

Let's assume that the backup is in the dump/ directory. To restore it:

```
sudo mongorestore --host localhost:27000 --db <database> dump/<database>
```
