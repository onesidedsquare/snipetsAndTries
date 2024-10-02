import json
import os
import requests
from datetime import datetime
from os import path
from contextlib import closing
from IPython.utils.io import Tee
import sys

# Defining colot pallette for our Soiree
CGREEN = '\33[32m'
CYELLOW = '\33[33m'
CVIOLET = '\33[35m'
CBLUE = '\33[34m'
CEND = '\33[0m'

# API Authorization Definition
snyk_api_token = str(os.environ.get('SNYK_TOKEN'))
reset = False
APItoken = str(sys.argv[1])
headers = {
  'Content-Type': 'application/json; charset=utf-8',
  'Authorization': 'token '+APItoken
}

#Defining file read and write processes for json files
def read_json_from_file(filename):
    # Import file to json
    with open(filename) as json_file:
        return json.load(json_file)

def write_json_to_file(filename, json_data):
    file = open(filename, "w")
    file.write(json.dumps(json_data, indent=4))
    file.close()

# Retrieving list of Snyk organizations for ORG and adding them to an array called orgs
def get_snyk_orgs():
    request = requests.get('https://snyk.io/api/v1/orgs', headers=headers)
    status_code = request.status_code
    hash = {'orgs':[]}

    if status_code != 200:
        print(str(datetime.now())+": Failure getting list of orgs"+
        "; status code = "+str(status_code)+
        "; response text = "+str(request.text))
        return hash
    orgs = request.json()['orgs']

    for org in orgs:
        hash['orgs'].append({
            'id': org['id'],
            'name': org['name'].rstrip()
        })
    return hash

# "Retrieving a complete list of Snyk projects and adding them to an array called all_projects"
def get_snyk_projects(org_dict):
    all_projects = []
    for i, org in enumerate(org_dict['orgs']):
        projects = get_snyk_projects_per_org(org)
        if projects:
            all_projects.extend(projects)
    return all_projects

# "Retrieving list of Snyk projects by organization and generating the project_array"
def get_snyk_projects_per_org(org):
    request = requests.post('https://snyk.io/api/v1/org/'+org['id']+'/projects', headers=headers)
    status_code = request.status_code
    project_array = []

    if status_code != 200:
        print(str(datetime.now())+": getting projects from "+org['id']+
        "; status code = "+str(status_code)+
        "; response text = "+str(request.text))
        return project_array
    projects = request.json()['projects']

    for project in projects:
        if any(issueCount>0 for issueCount in project['issueCountsBySeverity'].values()):
            project_array.append({
                'id': project['id'],
                'name': project['name'],
                'org': org
            })
    return project_array
# "Retrieving list of issues per project per org and updating the project_array"
def get_issues(projects):
    project_array = []
    for project in projects:
        issues = get_project_issues(project['org']['id'],project['id'])
        if issues:
            project_array.append({
                'id': project['id'],
                'name': project['name'],
                'issues': issues,
                'org': project['org']
            })
    return project_array

# "Retrieving details of issues by project by org"
def get_project_issues(org_id,project_id):
    payload = """
        {
            "filters": {
                "severities": [
                    "high",
                    "medium",
                    "low"
                ],
                "exploitMaturity": [
                    "mature",
                    "proof-of-concept",
                    "no-known-exploit",
                    "no-data"
                ],
                "types": [
                    "vuln"
                ],
                "ignored": false,
                "patched": false
            }
        }
    """
    request = requests.post('https://snyk.io/api/v1/org/'+org_id+'/project/'+project_id+'/aggregated-issues', headers=headers, data=payload)
    status_code = request.status_code

# Define array named unfixable_issue_ids and populate with any issue that has the unfixable attribute
    unfixable_issue_ids = []
    if status_code != 200:
        print(str(datetime.now())+": Failure getting issue for org "+org_id+" and project "+project_id+
        "; status code = "+str(status_code)+
        "; response text = "+str(request.text))
        return unfixable_issue_ids
    issues = request.json()['issues']
    print("Marking unfixable issues for ignore")
    for issue in issues:
        if all(not fixable for fixable in issue['fixInfo'].values()):
            unfixable_issue_ids.append(issue['id'])
    return unfixable_issue_ids

# "Marking unfixable issues for ignore until 12-31-2922"
def ignore_issue(org_id,project_id,issue_id):
    payload = """
        {
            "ignorePath": "",
            "reason": "not-fixable",
            "reasonType": "temporary-ignore",
            "disregardIfFixable": false,
            "expires": "2022-12-31T00:00:00.000Z"
        }
    """
    #print("Ignoring issue in org " + CBLUE + org_id + CEND + " in project " + CVIOLET + project_id + CEND + " for issue " + CGREEN + issue_id + CEND)

    # "Opening file ignored_full.txt to store details of every issue ignored in every project in every org"
    file1 = open("ignored_full.txt", "a")
    file1.write("\n")
    file1.write("Org" + org_id + "Project" + project_id + "Issue" + issue_id)
    file1.close()

    # "Opening file isses.txt to store details of every issue ignored (non-unique)"
    file2 = open("issues.txt", "a")
    file2.write("\n")
    file2.write(issue_id)
    file2.close()
    #with closing(Tee("issues.txt", "w", channel="stdout")) as outputstream:

    # "Contacting Snyk API and marking ignore for each unfixable issue"
    request = requests.post('https://snyk.io/api/v1/org/'+org_id+'/project/'+project_id+'/ignore/'+issue_id, headers=headers, data=payload)
    status_code = request.status_code

    if status_code != 200:
        print(str(datetime.now())+": Failure ignoring issue "+issue_id+" for org "+org_id+" and project "+project_id+
        "; status code = "+str(status_code)+
        "; response text = "+str(request.text))

    return request.text

# "Reads from local file snyk_orgs.json and adds any new orgs identified in orgs array from this run of the script"
if not reset and path.exists('snyk_orgs.json'):
    orgs = read_json_from_file('snyk_orgs.json')
else:
    orgs = get_snyk_orgs()
    write_json_to_file('snyk_orgs.json', orgs)

# "Reads from local file snyk_projects.json and adds any new orgs identified in projects array from this run of the script"
if not reset and path.exists('snyk_projects.json'):
    projects = read_json_from_file('snyk_projects.json')
else:
    projects = get_snyk_projects(orgs)
    write_json_to_file('snyk_projects.json', projects)

# "Reads from local file snyk_issues2.json and adds any new orgs identified in all_issues array from this run of the script"
if not reset and path.exists('snyk_issues2.json'):
    issues = read_json_from_file('snyk_issues2.json')
else:
    issues = get_issues(projects)
    write_json_to_file('snyk_issues2.json', issues)

# "Reads ignored_issues array from this run of the script and creates json output file with org and project IDs including API response code. Writes this to file snyk_ignored_issues.json"
ignored_issues = []
for project in issues:
    for issue in project['issues']:
        org_id = project['org']['id']
        project_id = project['id']
        response = ignore_issue(org_id,project_id,issue)
        ignored_issues.append({
            'org_id': org_id,
            'project_id': project_id,
            'issue_id': issue,
            'response': response
        })
write_json_to_file('snyk_ignored_issues.json', ignored_issues)
