### docker-s3-archive

Taken from [gregory90/file-backup-s3](https://hub.docker.com/r/gregory90/file-backup-s3/), this image has the necessary utilties for you to perform continuous backup to S3.
The idea is here is to provide an easy ready-to-go way to archive a directory, encrypt it, and push it to Amazon s3.

##### Features:

* Symmetric Encryption via gpg
* Compression via xz (lzma2)
* Extreme configurability via environment variables :)

#### Up and Running

Without going through and providing all the required env vars, here is a quick docker run line for getting up and running with this container.

```
docker run -v DIRECTORY_TO_BACKUP:/data:ro inanimate/s3-archive
```

#### Environment variables

##### *Required*

* `AWS_ACCESS_KEY_ID` - AWS S3 access key.
* `AWS_SECRET_ACCESS_KEY` - AWS S3 secret key.
* `BUCKET` - AWS S3 bucket (and folder) to store the backup. i.e. `s3://herpderpbucket/folder`
* `SYMMETRIC_PASSPHRASE` - The gpg symmetric passphrase to use to encrypt your file.

##### *Optional*

* `TIMEOUT` - how often perform backup, in seconds. (default: `86400`)
* `DATADIR` - The data directory inside the container to archive. (default: `/data`)
* `NAME_PREFIX` - A prefix in front of the date i.e. `jira-data-dir-backup` (default: `backup-archive`)
* `GPG_COMPRESSION_LEVEL` - The compression level for gpg to use (0-9). (default: `0`; *not recommended since we're using xz*)
* `XZ_COMPRESSION_LEVEL` - The compression level for xz (lzma2) to use (0-9). (default: `9`; *this is the best compression level*)
* `CIPHER_ALGO` - The cipher for gpg to utilize when encrypting your archive. (default: `aes256`)
* `EXTENSION` - The extension to use for the backup file i.e. `tgz,tar.xz,bz2` (default: `tar.xz.gpg`)
* `AWSCLI_OPTIONS` - Provide some arguments to awscli i.e. `--sse` See [here](http://docs.aws.amazon.com/cli/latest/reference/s3/cp.html) for possibilities.

> All other [aws-cli](https://github.com/aws/aws-cli) variables are also supported.

#### A few notes

* Use spaces in your buckets, prefix, or extension *at your own risk*!
* I really didn't feel like using cron. Deal with it. (plus, gregory90 did it like this, not me ;)
* One day, I'll implement asymmetric encryption so you can use your gpg keys. For now, [this](https://hub.docker.com/r/siomiz/postgresql-s3/) image does...maybe you could make your own ;P


> **Restorability has not yet been completed. The following does not work.**

### Restore backup
Restore file from S3.

```
docker run -v DIRECTORY_TO_RESTORE_TO:/data gregory90/file-backup-s3 /app/restore
```

##### Environment variables
ACCESS_KEY - AWS S3 access key,  
SECRET_KEY - AWS S3 secret key,  
FILE - file to restore (without extension),  
BUCKET - AWS S3 bucket for backup.
