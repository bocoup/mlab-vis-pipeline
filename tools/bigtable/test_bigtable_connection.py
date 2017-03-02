#!/usr/bin/env python

import argparse
from gcloud import bigtable
from gcloud.bigtable import happybase

DEFAULT_PROJECT_ID = 'mlab-sandbox'
DEFAULT_INSTANCE_ID = 'mlab-data-viz'

def main(project_id, instance_id):
    client = bigtable.Client(project=project_id, admin=True)
    instance = client.instance(instance_id)

    connection = happybase.Connection(instance=instance)
    all_tables = connection.tables()
    print "There are {} tables for project {} on instance {}".format(len(all_tables), project_id, instance_id)
    for table in all_tables: print table


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--project_id', help='Your Cloud Platform project ID.', default=DEFAULT_PROJECT_ID)
    parser.add_argument(
        '--instance_id', help='ID of the Cloud Bigtable instance to connect to.', default=DEFAULT_INSTANCE_ID)

    args = parser.parse_args()
    main(args.project_id, args.instance_id)
