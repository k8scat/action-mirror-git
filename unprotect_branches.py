from gitlab.gitlab import GitLab
import sys


def unprotect_branches(user, token):
    g = GitLab(token)

    projects = g.list_all_user_projects(user)
    if projects is None:
        return
    print(f'found projects: {len(projects)}')

    for project in projects:
        project_id = project['id']
        project_name = project['name']
        protected_branches = g.list_protected_branches(project_id)
        if len(protected_branches) == 0:
            print(f'{project_name} has no protected branches')
            continue
        for branch in protected_branches:
            branch_name = branch['name']
            print(f'unprotect branch: {project_name}/{branch_name}')
            g.unprotect_repository_branch(project_id, branch_name)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('usage: python unprotect_branches.py <user> <token>')
        sys.exit(1)
    user = sys.argv[1]
    token = sys.argv[2]
    unprotect_branches(user, token)
