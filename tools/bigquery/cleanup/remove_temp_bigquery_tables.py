#!/usr/bin/env python
'''
Cleans up remaining temp_**** datasets as a result of our pipeline
from the mlab-sandbox project
'''
import os
import pprint
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from google.oauth2 import service_account

# List all tables
def list_tables(service, project, dataset):
    '''
    Get a list of available tables within a dataset
    '''
    try:
        tables = service.tables()
        list_reply = tables.list(projectId = project,
                                 dataset_id = dataset).execute()
        print 'Tables list:'
        pprint.pprint(list_reply)

    except HttpError as err:
        print 'Error in list_tables:', pprint.pprint(err.content)

def list_datasets(service, project_id):
    '''
    Get a list of available datasets within a project
    '''
    dataset_ids = []
    try:
        dataset_list = service.datasets()
        list_reply = dataset_list.list(projectId = project_id).execute()
        dataset_ids = [d['id'] for d in list_reply['datasets']]
        # print 'dataset list:'
        # pprint.pprint(list_reply)

    except HttpError as err:
        print 'Error in list_tables:', pprint.pprint(err.content)

    return dataset_ids

def get_table(service, project_id, dataset_id, table_id):
    '''
    Retrieve a specific table resource from a project and dataset
    '''

    table_collection = service.tables()
    try:
        table_reply = table_collection.get(projectId = project_id,
                                           datasetId = dataset_id,
                                           tableId = table_id).execute()
        print 'Printing table resource %s:%s.%s' % (project_id, dataset_id,
                                                    table_id)
        pprint.pprint(table_reply)

    except HttpError as err:
        print 'Error in querytableData: ', pprint.pprint(err)


def delete_table(service, project_id, dataset_id, table_id):
    '''
    Delete a specific table within a dataset
    '''
    service.tables().delete(projectId = project_id,
                            datasetId = dataset_id,
                            tableId = table_id).execute()

def delete_dataset(service, project_id, dataset_id):
    '''
    Delete a dataset within a specific project
    '''
    try:
        service.datasets().delete(projectId = project_id,
                                  datasetId = dataset_id,
                                  deleteContents = True).execute()
    except HttpError as err:
        print 'Error in delete_dataset:', pprint.pprint(err.content)

def main():
    '''
    Main application entry point
    Required environment parameters:
    PROJECT = mlab-sandbox|mlab-staging|mlab-oti...
    KEY_FILE = <path to your json key file>
    '''

    project_id = os.environ.get("PROJECT")

    # Grab the application's credentials from key file
    credentials = service_account.Credentials.from_service_account_file(
        os.environ['KEY_FILE'])

    # Construct the service object for interacting with the BigQuery API.
    bigquery_service = build('bigquery', 'v2', credentials=credentials)
    datasets = list_datasets(bigquery_service, project_id)

    for dataset_id in datasets:
        if "temp" in dataset_id:
            real_id = dataset_id.split(":")[1]
            print "Going to remove {0}".format(real_id)

            delete_dataset(bigquery_service, project_id, real_id)

if __name__ == '__main__':
    main()
