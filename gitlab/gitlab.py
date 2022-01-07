import requests
import json
import logging


class GitLab:
    token = ''
    auth_headers = None
    base_api = 'https://gitlab.com/api/v4'
    client = None

    def __init__(self, token):
        self.token = token
        self.auth_headers = {
            'PRIVATE-TOKEN': self.token
        }
        self.client = requests.sessions.Session()
        self.client.headers = self.auth_headers

    # https://docs.gitlab.com/ee/api/projects.html#list-user-projects
    def list_user_projects(self, user, page=1, per_page=100):
        params = {
            'per_page': per_page,
            'page': page,
            'owned': True,
            'order_by': 'created_at',
            'sort': 'desc'
        }
        with self.client.get(f'{self.base_api}/users/{user}/projects', params=params) as r:
            if r.status_code == requests.codes.ok:
                projects = json.loads(r.text)
                has_next = False
                links = r.headers['Link']
                if links:
                    for link in links.split(', '):
                        if link.endswith('rel="next"'):
                            has_next = True
                return dict(projects=projects, has_next=has_next)
            logging.error(f'list user projects failed: {r.text}')
            return None

    def list_all_user_projects(self, user):
        projects = []
        page = 1
        while True:
            res = self.list_user_projects(user, page=page)
            if res is None:
                return None

            projects.extend(res['projects'])
            if not res['has_next']:
                return projects
            page += 1

    # https://docs.gitlab.com/ee/api/protected_branches.html#list-protected-branches
    def list_protected_branches(self, project_id):
        with self.client.get(f'{self.base_api}/projects/{project_id}/protected_branches') as r:
            if r.status_code == requests.codes.ok:
                branches = json.loads(r.text)
                return branches
            logging.error(f'list protected branches failed: {r.text}')
            return None

    # https://docs.gitlab.com/ee/api/protected_branches.html#unprotect-repository-branches
    # Unprotects the given protected branch or wildcard protected branch.
    def unprotect_repository_branch(self, project_id, branch_name):
        with self.client.delete(f'{self.base_api}/projects/{project_id}/protected_branches/{branch_name}') as r:
            if r.status_code == requests.codes.no_content:
                return
            logging.error(
                f'unprotect repository branches failed: {r.text}')
