## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| address\_allocation\_ids | A list of address allocation IDs that are required to attach an Elastic IP address to your SFTP server's endpoint. This property can only be used when endpoint\_type is set to VPC. | `list(string)` | `[]` | no |
| attributes | Additional attributes (e.g. `1`). | `list(any)` | <pre>[<br>  "transfer"<br>]</pre> | no |
| domain | Where your files are stored. S3 or EFS | `string` | `"S3"` | no |
| domain\_name | Domain to use when connecting to the SFTP endpoint | `string` | `""` | no |
| eip\_enabled | Whether to provision and attach an Elastic IP to be used as the SFTP endpoint. An EIP will be provisioned per subnet. | `bool` | `false` | no |
| enable\_sftp | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| enable\_workflow | n/a | `bool` | `false` | no |
| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| force\_destroy | Forces the AWS Transfer Server to be destroyed | `bool` | `false` | no |
| identity\_provider\_type | The mode of authentication enabled for this service. The default value is SERVICE\_MANAGED, which allows you to store and access SFTP user credentials within the service. API\_GATEWAY. | `string` | `"SERVICE_MANAGED"` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | `[]` | no |
| managedby | ManagedBy, eg 'CloudDrove'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-sftp"` | no |
| restricted\_home | Restricts SFTP users so they only have access to their home directories. | `bool` | `true` | no |
| retention\_in\_days | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `3` | no |
| s3\_bucket\_name | This is the bucket that the SFTP users will use when managing files | `string` | n/a | yes |
| security\_policy\_name | Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, and TransferSecurityPolicy-FIPS-2020-06. Default value is: TransferSecurityPolicy-2018-11. | `string` | `"TransferSecurityPolicy-2018-11"` | no |
| sftp\_users | List of SFTP usernames and public keys. The keys `user_name`, `public_key` are required. The keys `s3_bucket_name` are optional. | `any` | `{}` | no |
| subnet\_ids | A list of subnet IDs that are required to host your SFTP server endpoint in your VPC. This property can only be used when endpoint\_type is set to VPC. | `list(string)` | `[]` | no |
| vpc\_id | VPC ID | `string` | `null` | no |
| vpc\_security\_group\_ids | A list of security groups IDs that are available to attach to your server's endpoint. If no security groups are specified, the VPC's default security groups are automatically assigned to your endpoint. This property can only be used when endpoint\_type is set to VPC. | `list(string)` | `[]` | no |
| workflow\_details | Workflow details for triggering the execution on file upload. | <pre>object({<br>    on_upload = object({<br>      execution_role = string<br>      workflow_id    = string<br>    })<br>  })</pre> | n/a | yes |
| zone\_id | Route53 Zone ID to add the CNAME | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The Server ID of the Transfer Server (e.g. s-12345678). |
| tags | A mapping of tags to assign to the resource. |
| transfer\_server\_endpoint | The endpoint of the Transfer Server (e.g. s-12345678.server.transfer.REGION.amazonaws.com). |

