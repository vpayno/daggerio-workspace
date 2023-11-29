#!/bin/bash

alpine=$(
	dagger query <<-EOF | jq -r .container.from.withExec.withExec.stdout
		{
		    container {
		     from(address:"alpine:latest") {
		      withExec(args:["uname", "-nrio"]) {
		        withExec(args:["date"]) {
		        stdout
		      }
		     }
		    }
		  }
		}
	EOF
)

echo "${alpine}"
