-- SQL schema for the reports data

-- set the report to warnings
set client_min_messages='warning';


-- Create the sequences
Create SEQUENCE confSerialId START 1;

Create SEQUENCE confVersionId START 1;

-- Create the table for the configuration reports information
create table configurationReportsInfo (
	serialId integer PRIMARY KEY DEFAULT nextval('confSerialId'),
	versionId integer NOT NULL,
	configurationRuleId text NOT NULL CHECK (configurationRuleId <> ''),
	serial integer NOT NULL,
	policyInstanceId text NOT NULL CHECK (policyInstanceId <> ''),
	component text NOT NULL CHECK (component <> ''),
	cardinality integer NOT NULL,
	componentsValues text NOT NULL, -- this is the serialisation of the expected values 
	beginDate timestamp with time zone NOT NULL,
	endDate timestamp with time zone
);

create index configuration_versionId on configurationReportsInfo (versionId);
create index configuration_serialId on configurationReportsInfo (configurationRuleId, serial);

create table configurationServerList (
	versionId integer NOT NULL ,
	serverUuid varchar(50) NOT NULL  CHECK (serverUuid <> ''),
	primary key (versionId, serverUuid)
);

create index configurationServerList_versionId on configurationServerList (versionId);


-- create the table for the reports sent

create sequence serial START 101;

CREATE TABLE RudderSysEvents (
id integer PRIMARY KEY default nextval('serial'),
executionDate timestamp with time zone NOT NULL, 
nodeId text NOT NULL CHECK (nodeId <> ''),
policyInstanceId text NOT NULL CHECK (policyInstanceId <> ''),
configurationRuleId text NOT NULL CHECK (configurationRuleId <> ''),
serial integer NOT NULL,
component text NOT NULL CHECK (component <> ''),
keyValue text,
executionTimeStamp timestamp with time zone NOT NULL,
eventType varchar(64),
policy text,
msg text
);


create index nodeid_idx on RudderSysEvents (nodeId);
create index date_idx on RudderSysEvents (executionDate);
create index policyInstanceId_idx on RudderSysEvents (policyInstanceId);
create index configurationRuleId_idx on RudderSysEvents (configurationRuleId);
create index configurationRuleId_node_idx on RudderSysEvents (configurationRuleId, nodeId);
create index configurationRuleId_serialed_idx on RudderSysEvents (configurationRuleId, serial);
create index composite_idx on RudderSysEvents (configurationRuleId, policyInstanceId, serial, executionTimeStamp);


-- Log event part

CREATE SEQUENCE eventLogIdSeq START 1;


CREATE TABLE EventLog (
    id integer PRIMARY KEY  DEFAULT nextval('eventLogIdSeq'),
    creationDate timestamp with time zone NOT NULL DEFAULT 'now',
    severity integer,
    causeId integer,
    principal varchar(64),
    eventType varchar(64),
    data xml
); 

create index eventType_idx on EventLog (eventType);
create index causeId_idx on EventLog (causeId);



create sequence GroupsId START 101;


CREATE TABLE Groups (
id integer PRIMARY KEY default nextval('GroupsId'),
groupId text NOT NULL CHECK (groupId <> ''),
groupName text,
groupDescription text,
nodeCount int,
startTime timestamp with time zone default now(),
endTime timestamp with time zone
);



create index groups_id_start on Groups (groupId, startTime);
create index groups_end on Groups (endTime);


create sequence PolicyInstancesId START 101;


CREATE TABLE PolicyInstances (
id integer PRIMARY KEY default nextval('PolicyInstancesId'),
policyInstanceId text NOT NULL CHECK (policyInstanceId <> ''),
policyInstanceName text,
policyInstanceDescription text,
priority integer NOT NULL,
policyPackageName text,
policyPackageVersion text,
policyPackageDescription text,
startTime timestamp with time zone NOT NULL,
endTime timestamp with time zone
);


create index pi_id_start on PolicyInstances (policyInstanceId, startTime);
create index pi_end on PolicyInstances (endTime);

create sequence ConfigurationRulesId START 101;


CREATE TABLE ConfigurationRules (
id integer PRIMARY KEY default nextval('ConfigurationRulesId'),
configurationRuleId text NOT NULL CHECK (configurationRuleId <> ''),
serial integer NOT NULL,
name text,
shortdescription text,
longdescription text,
isActivated boolean,
startTime timestamp with time zone NOT NULL,
endTime timestamp with time zone
);

CREATE TABLE ConfigurationRulesGroups (
CrId integer, -- really the id of the table ConfigurationRules
groupId text NOT NULL CHECK (groupId <> ''),
PRIMARY KEY(CrId, groupId)
);

CREATE TABLE ConfigurationRulesPolicyInstance (
CrId integer, -- really the id of the table ConfigurationRules
policyInstanceId text NOT NULL CHECK (policyInstanceId <> ''),
PRIMARY KEY(CrId, policyInstanceId)
);


create index cr_id_start on ConfigurationRules (configurationRuleId, startTime);
create index cr_end on ConfigurationRules (endTime);


