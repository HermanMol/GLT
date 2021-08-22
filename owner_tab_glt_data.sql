prompt *I: ~_DATE. Start of file owner_tab_glt_data.sql
create table ~v_user..glt_data
	(glt_pkid         number not null
	,glt_datetime     date   not null
	,glt_msg_type     varchar2(  10 char) not null -- trace/debug/info
	,glt_msg_level    varchar2(  10 char) not null -- normal/warning/error/severe
	,glt_msg_text     varchar2(4000 char) not null
	,glt_process      varchar2( 100 char) not null -- default: unique per logical db process
	,glt_label        varchar2( 100 char)          -- e.g. the issue reference
	,glt_scope        varchar2(  50 char)          -- e.g. the addressed role, user/programmer/tester/admin/operations
	,glt_domain       varchar2(  50 char)          -- e.g. the company, department
	,glt_db_server    varchar2(  30 char) not null -- db_server
	,glt_db_name      varchar2(  30 char) not null -- db_name
	,glt_db_schema    varchar2(  30 char) not null -- current db-schema
	,glt_db_user      varchar2(  30 char) not null -- current db-user
	,glt_db_sesid     varchar2(  32 char) not null -- db session ID
	,glt_dbobj_owner  varchar2(  30 char)          -- issued from db-object owner
	,glt_dbobj_name   varchar2(  30 char)          -- issued from db-object name
	,glt_dbobj_method varchar2(  30 char)          -- issued from db-object method
	,glt_dbobj_line   integer                      -- issued from db-object line (NOT: db-object method!)
	,glt_ext_ref	  varchar2( 100 char)		   -- External reference e.g. APEX sessionid. Expected format: refname=refid
	,glt_os_user      varchar2(  30 char) not null -- OS user
	,glt_exe_level    integer                      -- Future use: execution level
	,constraint glt_data_pk 
		primary key (glt_pkid)
		using index
	);

comment on table  ~v_user..glt_data              is 'Generic Loging Tools - base data table.'
/
comment on column ~v_user..glt_data.glt_pkid     is 'Unique Primary key ID';
comment on column ~v_user..glt_data.glt_dtm      is 'Datetime the row was inserted.';
comment on column ~v_user..glt_data.glt_scope    is 'For whom is the message meant. See package ~v_user..glt.gc_developer, gc_tester, gc_admin, gc_operations, gc_user, gc_keyuser.';
comment on column ~v_user..glt_data.glt_msgtyp   is 'Type of the message.  See package ~v_user..glt.gc_debug, gc_trace, gc_operational, gc_functional, gc_testing, gc_auditing, gc_security.';
comment on column ~v_user..glt_data.glt_level    is 'Level of the message. See package ~v_user..glt.gc_info, gc_attention, gc_warning, gc_error, gc_critical.';
comment on column ~v_user..glt_data.glt_process  is 'Process name or code.';
comment on column ~v_user..glt_data.glt_label    is 'Some kind of a free text label, like a bug fix ID.';
comment on column ~v_user..glt_data.glt_script   is 'Name of the script which inserted the message.';
comment on column ~v_user..glt_data.glt_msgtxt   is 'The actual message.';
comment on column ~v_user..glt_data.glt_sesid    is 'Session ID.';
comment on column ~v_user..glt_data.glt_server   is 'Server Host.';
comment on column ~v_user..glt_data.glt_dbname   is 'Database.';
comment on column ~v_user..glt_data.glt_dbschema is 'Current Schema.';
comment on column ~v_user..glt_data.glt_dbuser   is 'Session user.';
comment on column ~v_user..glt_data.glt_osuser   is 'OS user.';

create or replace trigger ~v_user..bir_glt
	before insert on ~v_user..glt_data
	for each row
begin
	-- 20210725 hmo Re-engineered based on many assignments in the past 10+ years
	--	baseline = new
	if :new.glt_pkid is null
	then
		select ~v_user..glt_seq.nextval
		into :new.glt_pkid
		from dual;
	end if;

	--:new.glt_dtm		:= cast (systimestamp at time zone 'GMT' as date);
	:new.glt_dtm		:= sysdate;	-- use sysdate i.s.o. GMT
	:new.glt_scope      := coalesce(upper(:new.glt_scope) ,~v_user..glt.gc_admin);
	:new.glt_msgtyp     := coalesce(upper(:new.glt_msgtyp),~v_user..glt.gc_operational);
	:new.glt_level      := coalesce(upper(:new.glt_level) ,~v_user..glt.gc_info);

	:new.glt_sesid      := coalesce(:new.glt_sesid   ,sys_context('USERENV','SESSIONID')     );
	:new.glt_server     := coalesce(:new.glt_server  ,sys_context('USERENV','SERVER_HOST')   );
	:new.glt_dbname     := coalesce(:new.glt_dbname  ,sys_context('USERENV','DB_NAME')       );
	:new.glt_dbschema   := coalesce(:new.glt_dbschema,sys_context('USERENV','CURRENT_SCHEMA'));
	:new.glt_dbuser     := coalesce(:new.glt_dbuser  ,sys_context('USERENV','SESSION_USER')  );
	:new.glt_osuser     := coalesce(:new.glt_osuser  ,sys_context('USERENV','OS_USER')       );

end;
/
prompt *I: ~_DATE. End of file owner_tab_glt_data.sql
