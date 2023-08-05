# path directories to build the go package
locals {
  paths = {
    dynamodbCrud = {
      binary_path  = "${path.cwd}/src/dynamoCrud/main"
      src_path     = "${path.cwd}/src/dynamoCrud/main.go"
      archive_path = "${path.cwd}/src/dynamoCrud/main.zip"
      go_mod       = "${path.cwd}/src/dynamoCrud/go.mod"
      go_sum       = "${path.cwd}/src/dynamoCrud/go.sum"
    }
    helloWorld = {
      binary_path  = "${path.cwd}/src/helloWorld/main"
      src_path     = "${path.cwd}/src/helloWorld/main.go"
      archive_path = "${path.cwd}/src/helloWorld/main.zip"
      go_mod       = "${path.cwd}/src/helloWorld/go.mod"
      go_sum       = "${path.cwd}/src/helloWorld/go.sum"
    }
  }
}


// build the binary for the lambda function in a specified path
resource "null_resource" "go_build" {
  for_each = local.paths

  triggers = {
    hash_go_mod = filemd5(each.value.go_mod)
    hash_go_sum = filemd5(each.value.go_sum)
  }

  provisioner "local-exec" {
    command = "cp -f ${each.value.go_mod} ."
  }

  provisioner "local-exec" {
    command = "cp -f ${each.value.go_sum} ."
  }

  provisioner "local-exec" {
    command = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-trimpath go build -mod=readonly -ldflags='-s -w' -o ${each.value.binary_path} ${each.value.src_path}"
    # command = "GOOS=linux GOARCH=amd64 go build -o ${each.value.binary_path} ${each.value.src_path}"
    # command = "/bin/bash ${path.cwd}/src/dynamoCrud/build.sh"
    # command = "echo HELLO-WORLD!"
  }
}

