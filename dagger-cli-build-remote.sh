#!/bin/bash

# get Go examples source code repository
source=$(
	dagger query <<-EOF | jq -r .git.branch.tree.id
		{
		  git(url:"https://go.googlesource.com/example") {
		    branch(name:"master") {
		      tree {
		        id
		      }
		    }
		  }
		}
	EOF
)

# mount source code repository in golang container
# build Go binary
# export binary from container to host filesystem
result=$(
	dagger query <<-EOF | jq -r .container.from.withDirectory.withWorkdir.withExec.withExec.withExec.file.export
		{
		  container {
		    from(address:"golang:latest") {
		      withDirectory(path:"/src", directory:"$source") {
		        withWorkdir(path:"/src/hello") {
		          withExec(args:["pwd"]) {
		            withExec(args:["go", "clean", "./..."]) {
		              withExec(args:["go", "build", "-o", "dagger-builds-hello", "."]) {
		                file(path:"./dagger-builds-hello") {
		                  export(path:"./dagger-builds-hello")
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

printf "Result: [%s]\n" "${result}"

# check build result and display message
if [[ ${result} == "true" ]]; then
	echo "Build successful"
else
	echo "Build unsuccessful"
fi
