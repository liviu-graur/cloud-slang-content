#   (c) Copyright 2016 Hewlett-Packard Enterprise Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
########################################################################################################################
#!!
#! @description: Performs an HTTP request to create a network security group
#!
#! @input subscription_id: The ID of the Azure Subscription on which the VM should be created.
#! @input resource_group_name: The name of the Azure Resource Group that should be used to create the VM.
#! @input auth_token: Azure authorization Bearer token
#! @input api_version: The API version used to create calls to Azure
#!                     Default: '2016-03-30'
#! @input location: Specifies the supported Azure location where the network security group should be created.
#!                  This can be different from the location of the resource group.
#! @input network_security_group_name: Reference to NSG that will be applied to all NICs in the subnet by default
#! @input security_rule_name: optional - Name of the security rule
#!                            Default: ''
#! @input security_rule_description: security rule description
#! @input protocol: optional - Network protocols
#!                  Default: '*'
#!                  Valid values: Tcp, Udp, * for both
#! @input priority: Specifies the priority of the rule
#!                  Default: '65000'
#! @input direction: The direction specifies if rule will be evaluated on incoming or outgoing traffic
#!                   Default: 'Inbound'
#! @input access: optional - Whether to allow access or not
#!                Default: 'Allow'
#!                Valida values: Allow, Deny
#! @input source_port_range: Source Port or Range.
#!                           Default: '*'
#! @input destination_port_range: Destination Port or Range.
#!                                Default: '*'
#! @input proxy_host: optional - proxy server used to access the web site
#! @input proxy_port: optional - proxy server port - Default: '8080'
#! @input proxy_username: optional - username used when connecting to the proxy
#! @input proxy_password: optional - proxy server password associated with the <proxy_username> input value
#! @input trust_all_roots: optional - specifies whether to enable weak security over SSL - Default: false
#! @input x_509_hostname_verifier: optional - specifies the way the server hostname must match a domain name in
#!                                 the subject's Common Name (CN) or subjectAltName field of the X.509 certificate
#!                                 Valid: 'strict', 'browser_compatible', 'allow_all' - Default: 'allow_all'
#!                                 Default: 'strict'
#! @input trust_keystore: optional - the pathname of the Java TrustStore file. This contains certificates from
#!                        other parties that you expect to communicate with, or from Certificate Authorities that
#!                        you trust to identify other parties.  If the protocol (specified by the 'url') is not
#!                       'https' or if trust_all_roots is 'true' this input is ignored.
#!                        Default value: ..JAVA_HOME/java/lib/security/cacerts
#!                        Format: Java KeyStore (JKS)
#! @input trust_password: optional - the password associated with the trust_keystore file. If trust_all_roots is false
#!                        and trust_keystore is empty, trust_password default will be supplied.
#!
#! @output output: json response with information about the network security group name
#! @output status_code: 200 if request completed successfully, others in case something went wrong
#! @output error_message: If the network security group could not be created the error message will be populated with
#!                        a response, empty otherwise
#!
#! @result SUCCESS: Network security group created successfully.
#! @result FAILURE: There was an error while trying to create the network security group.
#!!#
########################################################################################################################

namespace: io.cloudslang.microsoft.azure.compute.network.security_groups

imports:
  http: io.cloudslang.base.http
  json: io.cloudslang.base.json
  strings: io.cloudslang.base.strings

flow:
  name: create_network_security_group

  inputs:
    - subscription_id
    - resource_group_name
    - auth_token
    - api_version:
        required: false
        default: '2016-03-30'
    - location
    - network_security_group_name
    - security_rule_name:
        required: false
        default: ''
    - security_rule_description:
        required: false
        default: ''
    - protocol:
        required: false
        default: '*'
    - priority:
        required: false
        default: '65000'
    - direction:
        required: false
        default: 'Inbound'
    - access:
        required: false
        default: 'Allow'
    - source_port_range:
        required: false
        default: '*'
    - destination_port_range:
        required: false
        default: '*'
    - proxy_host:
        required: false
    - proxy_port:
        default: "8080"
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false
        sensitive: true
    - trust_all_roots:
        default: "false"
        required: false
    - x_509_hostname_verifier:
        default: "strict"
        required: false
    - trust_keystore:
        required: false
    - trust_password:
        required: false
        sensitive: true

  workflow:
    - create_network_security_group:
        do:
          http.http_client_put:
            - url: >
                ${'https://management.azure.com/subscriptions/' + subscription_id + '/resourceGroups/' +
                resource_group_name + '/providers/Microsoft.Network/networkSecurityGroups/' +
                network_security_group_name + '?api-version=' + api_version}
            - body: >
                ${'{"location":"' + location + '","properties":{"securityRules":[{"name":"' + security_rule_name +
                '","properties":{"description":"' + security_rule_description + '","protocol": "' + protocol +
                '","sourcePortRange":"' + source_port_range + '","destinationPortRange":"' + destination_port_range +
                '","sourceAddressPrefix":"*","destinationAddressPrefix":"*","access":"' + access + '","priority":' +
                priority + ',"direction":"' + direction + '"}}]}}'}
            - headers: "${'Authorization: ' + auth_token}"
            - auth_type: 'anonymous'
            - preemptive_auth: 'true'
            - content_type: 'application/json'
            - request_character_set: 'UTF-8'
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
            - trust_all_roots
            - x_509_hostname_verifier
            - trust_keystore
            - trust_password
        publish:
          - output: ${return_result}
          - status_code
        navigate:
          - SUCCESS: check_error_status
          - FAILURE: check_error_status

    - check_error_status:
        do:
          strings.string_occurrence_counter:
            - string_in_which_to_search: '400,401,404'
            - string_to_find: ${status_code}
        navigate:
          - SUCCESS: retrieve_error
          - FAILURE: retrieve_success

    - retrieve_error:
        do:
          json.get_value:
            - json_input: ${output}
            - json_path: 'error,message'
        publish:
          - error_message: ${return_result}
        navigate:
          - SUCCESS: FAILURE
          - FAILURE: retrieve_success

    - retrieve_success:
        do:
          strings.string_equals:
            - first_string: ${status_code}
            - second_string: '200'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE

  outputs:
    - output
    - status_code
    - error_message

  results:
    - SUCCESS
    - FAILURE
