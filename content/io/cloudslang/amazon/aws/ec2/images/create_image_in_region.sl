#   (c) Copyright 2016 Hewlett-Packard Enterprise Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
########################################################################################################################
#!!
#! @description: Creates an Amazon EBS-backed AMI from an Amazon EBS-backed instance that is either running or stopped.
#!
#! @input endpoint: optional - Endpoint to which first request will be sent
#!                  Example: 'https://ec2.amazonaws.com'
#!
#! @input identity: Amazon Access Key ID
#! @input credential: Amazon Secret Access Key that corresponds to the Amazon Access Key ID
#! @input proxy_host: optional - Proxy server used to access the provider services
#! @input proxy_port: optional - Proxy server port used to access the provider services
#!                    Default: '8080'
#! @input proxy_username: optional - proxy server user name.
#! @input proxy_password: optional - proxy server password associated with the <proxyUsername> input value.
#! @input headers: optional - string containing the headers to use for the request separated by new line (CRLF).
#!                 The header name-value pair will be separated by ":".
#!                 Format: Conforming with HTTP standard for headers (RFC 2616)
#!                 Examples: "Accept:text/plain"
#! @input query_params: optional - string containing query parameters that will be appended to the URL. The names
#!                      and the values must not be URL encoded because if they are encoded then a double encoded
#!                      will occur. The separator between name-value pairs is "&" symbol. The query name will be
#!                      separated from query value by "=".
#!                      Examples: "parameterName1=parameterValue1&parameterName2=parameterValue2"
#! @input version: version of the web service to make the call against it.
#!                 Example: "2016-04-01"
#!                 Default: "2016-04-01"
#! @input instance_id: ID of the server (instance) to be used to create image for
#! @input name: A name for the new image
#! @input description: optional - A description for the new image.
#! @input no_reboot: optional - By default, Amazon EC2 attempts to shut down and reboot the instance before creating
#!                   the image. If the 'No Reboot' option is set, Amazon EC2 doesn't shut down the instance
#!                   before creating the image. When this option is used, file system integrity on the created
#!                   image can't be guaranteed
#!                   Default: 'true'
#!
#! @output return_result: contains the exception in case of failure, success message otherwise
#! @output return_code: '0' if operation was successfully executed, '-1' otherwise
#! @output exception: exception if there was an error when executing, empty otherwise
#!
#! @result SUCCESS: the image was successfully created
#! @result FAILURE: an error occurred when trying to create image
#!!#
########################################################################################################################

namespace: io.cloudslang.amazon.aws.ec2.images

operation:
  name: create_image_in_region

  inputs:
    - endpoint:
        default: 'https://ec2.amazonaws.com'
        required: false
    - identity
    - credential:
        sensitive: true
    - proxy_host:
        required: false
    - proxyHost:
        default: ${get("proxy_host", "")}
        required: false
        private: true
    - proxy_port:
        required: false
    - proxyPort:
        default: ${get("proxy_port", "8080")}
        required: false
        private: true
    - proxy_username:
       required: false
    - proxyUsername:
       default: ${get("proxy_username", "")}
       required: false
       private: true
    - proxy_password:
       required: false
       sensitive: true
    - proxyPassword:
       default: ${get("proxy_password", "")}
       required: false
       private: true
       sensitive: true
    - headers:
       required: false
    - query_params:
       required: false
    - queryParams:
       default: ${get("query_params", "")}
       required: false
       private: true
    - version:
       default: "2016-04-01"
       required: false
    - instance_id
    - instanceId:
        default: ${get("instance_id", "")}
        required: false
        private: true
    - description:
        default: ''
        required: false
    - name
    - no_reboot:
        required: false
    - noReboot:
        default: ${get("no_reboot", "true")}
        required: false
        private: true

  java_action:
    gav: 'io.cloudslang.content:cs-amazon:1.0.7'
    class_name: io.cloudslang.content.amazon.actions.images.CreateImageAction
    method_name: execute

  outputs:
    - return_result: ${returnResult}
    - return_code: ${returnCode}
    - exception: ${get("exception", "")}

  results:
    - SUCCESS: ${returnCode == '0'}
    - FAILURE