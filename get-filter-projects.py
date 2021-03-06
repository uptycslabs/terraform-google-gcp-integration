#!/usr/bin/env python3

"""Script to filter project ids list using input patterns in Terraform
   Run Command :-
   python3 get-filter-projects.py '{"project_ids_include_patterns":"*ops*,dev*", "folder_ids_include":"12345678,77784655", "project_ids_exclude": "test-ops-100,smart-project-3000"}'
"""

import sys
import json
import re
import argparse
from googleapiclient import discovery
from oauth2client.client import GoogleCredentials

credentials = GoogleCredentials.get_application_default()
service = discovery.build('cloudresourcemanager', 'v1', credentials=credentials)
servicev2 = discovery.build('cloudresourcemanager', 'v2', credentials=credentials)


all_project_ids = []
f_project_ids = []
pattern_project_ids = []


def get_subfolder_pid(pf_pid):
    pf_pid_list = []
    try:
        p_id = "folders/{}".format(pf_pid)
        request = servicev2.folders().list(parent=p_id)
        response = request.execute()

        if bool(response):
            folder_data = response['folders']
            for i in range(len(folder_data)):
                pf_pid_list.append(folder_data[i].get('name').split('/')[1])
            return pf_pid_list
        else:
            return pf_pid_list
    except Exception as e:
        print("ERROR, Something wrong ,Please verify inputs , gcloud oauth connection OR permission.")
        sys.exit(e)


def get_folderids(pid):
    r = []
    subpids = [x for x in get_subfolder_pid(str(pid))]
    r.extend(subpids)
    for subpid in subpids:
        spidlist = [x for x in get_subfolder_pid(str(subpid))]
        r.extend(spidlist)
        if len(spidlist) > 0:
            for sp in spidlist:
                r.extend(get_folderids(sp))
    return r


def get_pattern_match(patterns, all_pids):
    temp_list = []
    for i in range(len(patterns)):
        if patterns[i][0] == '*':
            temp_list.append("." + str(patterns[i]))
        else:
            temp_list.append(patterns[i])
    listToStr = '|'.join([str(elem) for elem in temp_list])
    r = re.compile(listToStr)
    r_projects = list(filter(r.match, all_pids))
    return r_projects


def filter_projects(folders, project_patterns, project_exclusion):
    try:
        request = service.projects().list()
        response = request.execute()

        fr_pid_list = []
        if len(folders) > 0 and folders[0] != '*':
            for f in folders:
                fr_pid_list.append(f)
                fr_pid_list.extend(get_folderids(str(f)))

        for project in response.get('projects', []):
            # Getting project ids based on parent folder ids
            if len(folders) == 1 and folders[0] == '*':
                if project['parent'].get('type') == 'folder' and project['lifecycleState'] == 'ACTIVE':
                    f_project_ids.append(project['projectId'])

            if len(fr_pid_list) > 0:
                for fr_pid in fr_pid_list:
                    if project['parent'].get('type') == 'folder' and project['parent'].get('id') == str(fr_pid) \
                            and project['lifecycleState'] == 'ACTIVE':
                        f_project_ids.append(project['projectId'])

            # Getting all ACTIVE projectIds
            if project['lifecycleState'] == 'ACTIVE':
                all_project_ids.append(project['projectId'])

            request = service.projects().list_next(previous_request=request, previous_response=response)

        # Filtering project Ids as per shared pattern
        if len(project_patterns) == 1 and project_patterns[0] == '*':
            pattern_project_ids.extend(all_project_ids)
        elif len(project_patterns) > 0 and project_patterns[0] != '*':
            pattern_project_ids.extend(get_pattern_match(project_patterns, all_project_ids))

            # Removing projects based on exclusion list
        if project_exclusion and len(project_exclusion) > 0:
            final_list = list(set(pattern_project_ids + f_project_ids) - set(project_exclusion))
        else:
            final_list = list(set(pattern_project_ids + f_project_ids))
        return final_list
    except Exception as e:
        print("ERROR, Something wrong ,Please verify inputs , gcloud oauth connection OR permission.")
        sys.exit(e)


def main():
    try:
        folders = []
        project_patterns = []
        project_exclusion = []

        data = json.loads(sys.argv[1])
        print("Passed input parameters :", data, "\n")

        if data.get('folder_ids_include'):
            folders = data.get('folder_ids_include').split(',')
        if data.get('project_ids_include_patterns'):
            project_patterns = data.get('project_ids_include_patterns').split(',')
        if data.get('project_ids_exclude'):
            project_exclusion = data.get('project_ids_exclude').split(',')

    except ValueError as e:
        print("ERROR ,Not a valid input ,Please verify usage.")
        print('''
Run Command :-
python3 get-filter-projects.py '{"project_ids_include_patterns":"*ops*,dev*", "folder_ids_include":"12345678,77784655", "project_ids_exclude": "test-ops-100,smart-project-3000"}'
        ''')
        sys.exit(e)

    while '' in folders:
        folders.remove('')
    while '' in project_patterns:
        project_patterns.remove('')
    while '' in project_exclusion:
        project_exclusion.remove('')

    projects = filter_projects(folders, project_patterns, project_exclusion)
    final_projects_ids = ','.join([str(elem).replace('"', '') for elem in projects])
    print("integration_projects =", '"'+final_projects_ids+'"', "\n")


if __name__ == '__main__':
    main()

