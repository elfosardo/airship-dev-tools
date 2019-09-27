#!/bin/bash
set -ue

#------------------------------------------
# Workflow:
# -clone repos to jenkins if not there
# -rebase jenkins local repos from upstream
# -push jenkins local repos to Nordix forks
#------------------------------------------

SCRIPTPATH="$(dirname "$(readlink -f "${0}")")"
#LOCAL_REPO_PATH="${GOPATH}/src"
LOCAL_REPO_PATH="${WORKSPACE}"

CAPIPB_REPO="https://github.com/metal3-io/cluster-api-provider-baremetal.git"
CAPI_REPO="https://github.com/kubernetes-sigs/cluster-api.git"
BMO_REPO="https://github.com/metal3-io/baremetal-operator.git"
M3DOCS_REPO="https://github.com/metal3-io/metal3-docs.git"
M3DEVENV_REPO="https://github.com/metal3-io/metal3-dev-env.git"

NORDIX_CAPIPB_REPO="git@github.com:Nordix/cluster-api-provider-baremetal.git"
NORDIX_CAPI_REPO="git@github.com:Nordix/cluster-api.git"
NORDIX_BMO_REPO="git@github.com:Nordix/baremetal-operator.git"
NORDIX_M3DOCS_REPO="git@github.com:Nordix/metal3-docs.git"
NORDIX_M3DEVENV_REPO="git@github.com:Nordix/metal3-dev-env.git"

JAAKKO_TEST_REPO="git@github.com:Jaakko-Os/test.git"

LOCAL_CAPIPB_REPO="${LOCAL_REPO_PATH}/cluster-api-provider-baremetal"
LOCAL_CAPI_REPO="${LOCAL_REPO_PATH}/cluster-api"
LOCAL_BMO_REPO="${LOCAL_REPO_PATH}/baremetal-operator"
LOCAL_M3DOCS_REPO="${LOCAL_REPO_PATH}/metal3-docs"
LOCAL_M3DEVENV_REPO="${LOCAL_REPO_PATH}/metal3-dev-env"

pushd "${SCRIPTPATH}"
cd ..

#UPDATE_REPO="${1:-${LOCAL_CAPIPB_REPO} ${LOCAL_CAPI_REPO} ${LOCAL_BMO_REPO} ${LOCAL_M3DOCS_REPO} ${LOCAL_M3DEVENV_REPO}}"
UPDATE_REPO="${1:-${LOCAL_M3DOCS_REPO}}"
UPDATE_BRANCH="${2:-master}"
#UPSTREAM_REPO="${3:-${CAPIPB_REPO} ${CAPI_REPO} ${BMO_REPO} ${M3DOCS_REPO} ${M3DEVENV_REPO}}"
UPSTREAM_REPO="${3:-${M3DOCS_REPO}}"
#NORDIX_REPO="${4:-${NORDIX_CAPIPB_REPO} ${NORDIX_CAPI_REPO} ${NORDIX_BMO_REPO} ${NORDIX_M3DOCS_REPO} ${NORDIX_M3DEVENV_REPO}}"
NORDIX_REPO="${4:-${NORDIX_M3DOCS_REPO}}"

# clone upstream repos to jenkins if not found
i=0
locarray=(${UPDATE_REPO})
upsarray=(${UPSTREAM_REPO})

pushd ${LOCAL_REPO_PATH}

for index in ${UPDATE_REPO}
do
    if [ ! -d "${locarray[$i]}" ]; then
      echo "CLONE "${upsarray[$i]}""
      git clone ${upsarray[$i]}
    fi
i=$(($i+1));
done

cd -

for repo in ${UPDATE_REPO}
do
  echo "PWD ${PWD}"
  echo "Updating ${repo}"
  pushd "${repo}"
  echo "PWD after pushd ${PWD}"
  # Update "master" on Nordix
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  git checkout "${UPDATE_BRANCH}"
  # origin points to upstream repos
  echo "Start rebase!!! UPSTREAM"
  git fetch origin
  git rebase origin/master
  #git remote add nordixrepo ${NORDIX_M3DOCS_REPO}
  #git remote remove testrepo
  git remote add testrepo ${JAAKKO_TEST_REPO}
  remotes=$(git remote -v)
  echo "\n REMOTE repos ${remotes}"
  echo "Start push!!!"
  #git push --repo="${NORDIX_REPO}"
  #git push nordixrepo master
  git push -uf testrepo master
  echo "Push done!!! ---NORDIX"
  git checkout "${BRANCH}"
  popd
  echo -e "\n"
done

popd
