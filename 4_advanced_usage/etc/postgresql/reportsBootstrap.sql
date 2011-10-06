insert into configurationReportsInfo (versionId, configurationRuleId, policyInstanceId, serial, component, cardinality, componentsvalues, beginDate)
values (1, 'root-DP', 'root-distributePolicy', 1, 'distributePolicy', 1, '["None"]',  '2011-01-03 11:22:52.272');

insert into configurationServerList (versionId, serverUuid)
values (1, 'root');

insert into configurationReportsInfo (versionId, configurationRuleId, policyInstanceId, serial, component, cardinality, componentsvalues, beginDate)
values (2, 'hasPolicyServer-root', 'common-root', 1, 'comomn', 1, '["None"]', '2011-01-03 11:22:52.272');

insert into configurationServerList (versionId, serverUuid)
values (2, 'root');

select nextval('confVersionId');
select nextval('confVersionId');
