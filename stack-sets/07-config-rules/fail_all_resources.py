import boto3
import json
import os

config = boto3.client('config')
kms = boto3.client('kms')

CLOUDFORMATION_TYPE = 'AWS::CloudFormation::Stack'
DB_SECURITYGROUP_TYPES = {'AWS::RDS::DBSecurityGroup','AWS::Redshift::ClusterSecurityGroup'}


def handler(event, context):
    invoking_event = json.loads(event['invokingEvent'])
    configItem = invoking_event.get('configurationItem') or invoking_event['configurationItemSummary']
    resource_id = configItem['resourceId']
    resource_type = configItem['resourceType']
    arn = configItem['ARN']
    print("FunctionName: " + context.function_name)
    print("ResourceId: " + resource_id)
    print("Resourcetype: " + resource_type)
    print("ARN: " + arn)
    compliance_type = 'NON_COMPLIANT'
    annotation = 'No Resources should be deployed in this Region'
    if (
            (context.function_name == resource_id and resource_type == 'AWS::Lambda::Function') or
            (os.environ['StackName'] in resource_id and resource_type == CLOUDFORMATION_TYPE) or
            ('StackSet-' in resource_id and resource_type == CLOUDFORMATION_TYPE) or
            (resource_id == 'default' and resource_type in DB_SECURITYGROUP_TYPES)
    ):
        compliance_type = 'COMPLIANT'
        annotation = 'Compliant'
    elif resource_type == 'AWS::KMS::Key':
        kms_key_details = kms.describe_key(KeyId=resource_id)
        if kms_key_details['KeyMetadata']['KeyManager'] == 'AWS':
            compliance_type = 'COMPLIANT'
            annotation = 'Compliant'
    elif resource_type == 'AWS::EC2::SecurityGroup':
        default_security_group_arn = 'arn:aws:ec2:' + configItem['awsRegion'] + ':' + configItem['awsAccountId'] + ':security-group/default'
        if arn == default_security_group_arn:
            compliance_type = 'COMPLIANT'
            annotation = 'Compliant'

    print('ComplianceStatus: ' + compliance_type)
    config.put_evaluations(
        Evaluations=[
            {
                'ComplianceResourceType': resource_type,
                'ComplianceResourceId': resource_id,
                'ComplianceType': compliance_type,
                'Annotation': annotation,
                'OrderingTimestamp': configItem['configurationItemCaptureTime']
            }
        ],
        ResultToken=event['resultToken']
    )
