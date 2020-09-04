import boto3
import json
import os

config = boto3.client('config')
kms = boto3.client('kms')

CLOUDFORMATION_TYPE = 'AWS::CloudFormation::Stack'


def handler(event, context):
    invoking_event = json.loads(event['invokingEvent'])
    configItem = invoking_event.get('configurationItem') or invoking_event['configurationItemSummary']
    resource_id = configItem['resourceId']
    resource_type = configItem['resourceType']
    print("FunctionName: " + context.function_name)
    print("ResourceId: " + resource_id)
    print("Resourcetype: " + resource_type)
    compliance_type = 'NON_COMPLIANT'
    annotation = 'No Resources should be deployed in this Region'
    if (
            (context.function_name == resource_id and resource_type == 'AWS::Lambda::Function') or
            (os.environ['StackName'] in resource_id and resource_type == CLOUDFORMATION_TYPE) or
            ('StackSet-' in resource_id and resource_type == CLOUDFORMATION_TYPE) or
            (resource_type == 'AWS::RDS::DBSecurityGroup' and resource_id == 'default')
    ):
        compliance_type = 'COMPLIANT'
        annotation = 'Compliant'
    elif resource_type == 'AWS::KMS::Key':
        kms_key_details = kms.describe_key(KeyId=resource_id)
        if kms_key_details['KeyMetadata']['KeyManager'] == 'AWS':
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
