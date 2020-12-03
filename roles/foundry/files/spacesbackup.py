#!/usr/bin/env python3

import argparse
import configparser
import datetime
import logging
import os
import tarfile

import boto3


logging.basicConfig(level=logging.INFO)


class ConfigError(Exception):
    """ConfigError is raised if an expected section or attribute is missing in the config file."""
    def __init__(self, section, attribute=None):
        self.section = section
        self.attribute = attribute

    def __str__(self):
        if self.attribute is None:
            return 'config is missing {}'.format(self.section)
        return 'config is missing attribute {} for section {}'.format(self.attribute, self.section)

class BackupClient(object):
    """BackupClient will backup and restore the configured directory using spaces.

    Credentials to connect to spaces are read through the $SPACES_KEY
    and $SPACES_SECRET environment file.

    The config file is an ini file which must contain the following:
        [space]
        name = <string>
        region = <string>
        url = <string>

    However the full file may contain the following:
        [space]
        name = <string>
        region = <string>
        url = <string>
        path = <string:foundry>

        [backup]
        path = <string:$HOME>
    """
    def __init__(self, config):
        if not 'space' in config:
            raise ConfigError('space')
        if not 'name' in config['space']:
            raise ConfigError('space', 'name')
        if not 'region' in config['space']:
            raise ConfigError('space', 'region')
        if not 'url' in config['space']:
            raise ConfigError('space', 'url')

        self._space = config.get('space', 'name')
        self._path = config.get('space', 'path', fallback='foundry')
        self._directory = config.get('backup', 'path', fallback=os.path.expanduser('~'))

        session = boto3.session.Session()
        self.bclient = session.client('s3', region_name=config['space']['region'], endpoint_url=config['space']['url'],
                aws_access_key_id=os.getenv('SPACES_ACCESS_KEY_ID'), aws_secret_access_key=os.getenv('SPACES_SECRET_ACCESS_KEY'))

    def backup(self):
        """backup creates and uploads a tar.gz file with data from the configured directory.
        """
        logging.info('Creating backup.')
        ts = datetime.datetime.now()
        bfile = '/tmp/backup-{}.tar.gz'.format(ts.strftime('%d%m%YT%H%M'))
        with tarfile.open(bfile, 'w:gz') as tar:
            tar.add(self._directory, arcname='')
        try:
            logging.info('Uploading backup')
            self.bclient.upload_file(bfile,
                    Bucket=self._space,
                    Key='{}/backup-{}.tar.gz'.format(self._path, ts.strftime('%d%m%YT%H%M'))
            )
        except Exception as e:
            logging.error('Unable to push backup to spaces.', e)
            raise e
        finally:
            os.remove(bfile)
        logging.info('Backup successful.')

    def restore(self, key):
        """restore will restore data to the directory using the object located at key.
        """
        logging.info('Downloading restore data.')
        self.bclient.download_file(self._space, key, '/tmp/restore.tar.gz')
        logging.info('Restoring data.')
        try:
            with tarfile.open('/tmp/restore.tar.gz', 'r:gz') as tar:
                tar.extractall(path=self._directory)
        except Exception as e:
            logging.error('Unable to unpack archive. Down present at /tmp/restore.tar.gz')
            raise e
        logging.info('Restore successful.')
        os.remove('/tmp/restore.tar.gz')

def main():
    parser = argparse.ArgumentParser(description='Spaces backup agent.')
    parser.add_argument('-f', '--config-file', default='/etc/spacesbackup.ini', help='The configuration file to use.')

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--backup', action='store_true', help='Take a backup and place it in spaces.`')
    group.add_argument('--restore', help='Key to use for data restore from spaces.')

    args = parser.parse_args()

    config = configparser.ConfigParser()
    config.read(args.config_file)

    client = BackupClient(config)
    if args.backup:
        client.backup()
    else:
        client.restore(args.restore)

if __name__ == "__main__":
    main()
