#!/bin/bash

declare REPO_URL="https://github.com/vpayno/daggerio-workspace.git"
declare REPO_PATH="/src/daggerio-workspace"

declare CI_IMAGE="vpayno/ci-generic-debian:latest"

declare REPO_BRANCH
declare JOB_OUTPUT
declare SOURCE

REPO_BRANCH="$(git branch --show-current)"

SOURCE=$(
	dagger query <<-EOF | jq -r .git.branch.tree.id
		{
		  git(url:"${REPO_URL}") {
		    branch(name:"${REPO_BRANCH}") {
		      tree {
		        id
		      }
		    }
		  }
		}
	EOF
)

JOB_OUTPUT=$(
	dagger query <<-EOF | jq -r .container.from.withExec.withExec.stdout
		{
		  container {
		    from(address:"${CI_IMAGE}") {
		      withDirectory(path:"${REPO_PATH}", directory:"${SOURCE}") {
		        withWorkdir(path:"${REPO_PATH}") {
		          withExec(args:["rustc", "--version"]) {
		            withExec(args:["go", "version"]) {
		              withExec(args:["node", "--version"]) {
		                withExec(args:["ruby", "--version"]) {
		                  withExec(args:["gcc", "--version"]) {
		                    withExec(args:["clang-16", "--version"]) {
		                      withExec(args:["llvm-cov-16", "--version"]) {
		                        withExec(args:["dagger", "version"]) {
		                          withExec(args:["pwd"]) {
		                            withExec(args:["ls"]) {
		                              stdout
		                            }
		                          }
		                        }
		                      }
		                    }
		                  }
		                }
		              }
		            }
		          }
		        }
		      }
		    }
		  }
		}
	EOF
)

echo "${JOB_OUTPUT}"
