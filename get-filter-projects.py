#!/usr/bin/env python

"""Script to filter project ids list using input patterns in Terraform"""

import sys
import json
import re
import subprocess as sp
from googleapiclient import discovery
from oauth2client.client import GoogleCredentials

credentials = GoogleCredentials.get_application_default()

service = discovery.build('cloudresourcemanager', 'v1', credentials=credentials)

all_project_ids = []
f_project_ids = []
pattern_project_ids = []


def get_subfolder_pid(pf_pid):
    pf_pid_list = []
    output = json.loads(sp.getoutput('gcloud resource-manager folders list --folder={} --format="json"'.format(pf_pid)))
    for i in range(len(output)):
        pf_pid_list.append(output[i].get('name').split('/')[1])
    return pf_pid_list


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


def filter_projects(fr_pid_list, project_patterns, project_exclusion):
    request = service.projects().list()
    response = request.execute()

    for project in response.get('projects', []):
        # Getting project ids based on parent folder ids
        if len(fr_pid_list) > 0:
            for fr_pid in fr_pid_list:
                if project['parent'].get('type') == 'folder' and project['parent'].get('id') == str(fr_pid) and project['lifecycleState'] == 'ACTIVE':
                    f_project_ids.append(project['projectId'])

        # Getting all ACTIVE projectIds
        if project['lifecycleState'] == 'ACTIVE':
            all_project_ids.append(project['projectId'])

        request = service.projects().list_next(previous_request=request, previous_response=response)

    # Filtering project Ids as per shared pattern
    if len(project_patterns) > 0:
        pattern_project_ids.extend(get_pattern_match(project_patterns, all_project_ids))

        # Removing projects based on exclusion list
    if project_exclusion and len(project_exclusion) > 0:
        final_list = list(set(pattern_project_ids + f_project_ids) - set(project_exclusion))
    else:
        final_list = list(set(pattern_project_ids + f_project_ids))

    return final_list


def read_in():
    input_json = sys.stdin.read()
    try:
        input_dict = json.loads(input_json)
        return input_dict
    except ValueError as e:
        sys.exit(e)


def main():
    data = read_in()
    folders = data.get('folder_id_include')
    project_patterns = data.get('project_id_include_pattern')
    project_exclusion = data.get('project_id_exclude')

    fr_pid_list = []
    if folders and len(folders) > 0:
        for f in folders.split(','):
            fr_pid_list.append(f)
            fr_pid_list.extend(get_folderids(str(f)))

    projects = filter_projects(fr_pid_list, project_patterns.split(','), project_exclusion.split(','))

    jsondata = {'final_projects_ids': ','.join([str(elem).replace('"', '') for elem in projects])}
    sys.stdout.write(json.dumps(jsondata))


if __name__ == '__main__':
    main()