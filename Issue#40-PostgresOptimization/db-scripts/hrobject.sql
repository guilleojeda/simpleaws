--This SQL File creates the the below objects
--Get the maximum employee_id from hr.employees and reset the employee sequence start with the maximum_id
--Creates add_employee_data plpgsql function – used to populate the records in employees table with x number of records (x input number)
--Creates update_employee_data_fname plpgsql function –  used to update employee salary based on firstname for x number of records (x input number)
--update_employee_data_empid function - used to update employee salary based on employee_id for x number of records (x input number)
--Analyze all the tables in HR schema 
--disable triggers





--------------- set search path to hr----------------


set search_path to 'hr';



--------------- reset the sequence to maxvalue----------------


DO $$
DECLARE
  num numeric;
  schemaName VARCHAR := 'hr';
  seqname varchar := 'employees_seq';
BEGIN
  select max(employee_id)+1 into num from hr.employees;
      RAISE NOTICE 'alter sequence to start with %.%', schemaName||'-> '||seqname,num;
    EXECUTE 'alter sequence '||schemaName||'.'||seqname||' restart '|| num;

end
$$;


--------------- Analyze tables in hr schema -----------

DO $$
DECLARE
  tab RECORD;
  schemaName VARCHAR := 'hr';
BEGIN
  for tab in (select t.relname::varchar AS table_name
                FROM pg_class t
                JOIN pg_namespace n ON n.oid = t.relnamespace
                WHERE t.relkind = 'r' and n.nspname::varchar = schemaName
                order by 1)
  LOOP
    RAISE NOTICE 'ANALYZE %.%', schemaName, tab.table_name;
    EXECUTE 'ANALYZE '||schemaName||'.'||tab.table_name;
  end loop;
end
$$;



-- ------------ Write DROP-FUNCTION-stage scripts -----------

DROP FUNCTION IF EXISTS hr.add_employee_data(IN DOUBLE PRECISION);


-- ------------ Write CREATE-FUNCTION-for employee data generation-----------

CREATE OR REPLACE FUNCTION hr.add_employee_data(IN p_num_emp DOUBLE PRECISION)
RETURNS void
AS
$BODY$
DECLARE

/* Function to generate random data and insert records to employees table  */

    n bigint DEFAULT 0;
	minsal hr.employees.salary%TYPE;
	maxsal hr.employees.salary%TYPE;
    email hr.employees.email%TYPE;
    nam hr.employees.first_name%TYPE;
    lnam hr.employees.last_name%TYPE;
    sal hr.employees.salary%TYPE DEFAULT 10;
    dep hr.employees.department_id%TYPE DEFAULT 160;
    ph hr.employees.phone_number%TYPE DEFAULT '123445789';
    mgr_id hr.employees.manager_id%TYPE DEFAULT 200;
    job hr.employees.job_id%TYPE DEFAULT 'IT_PROG';
    error_transaction$returned_sqlstate TEXT;
    error_transaction$message_text TEXT;
    error_transaction$pg_exception_context TEXT;

BEGIN
  	
		
    FOR i IN 1..p_num_emp LOOP
        select nextval('hr.employees_seq') into n; 
		
	
		SELECT array_to_string(ARRAY(SELECT chr((97 + round(random() * 25)) :: integer) into email FROM generate_series(1,7)), '');
        email := CONCAT_WS(email, (n)::TEXT,'@mail.com');
        nam := CONCAT_WS('', (n)::TEXT,'-fname');
        lnam := CONCAT_WS('', (n)::TEXT,'-lname');
        sal := floor(random()*(10000-100+1)+100);
        ph := floor(random()*(900900900-100100100+1)+100100100);
        SELECT
            department_id, manager_id
            INTO STRICT dep, mgr_id
            FROM (SELECT
                *
                FROM hr.departments
                ORDER BY random() limit 1) AS var_sbq
            LIMIT 1;
        SELECT
            job_id,min_salary,max_salary
            INTO STRICT job,minsal,maxsal
            FROM (SELECT
                *
                FROM hr.jobs
                ORDER BY random() limit 1) AS var_sbq_2
            LIMIT 1;
        INSERT INTO hr.employees
        VALUES (n, nam, lnam, email, ph, current_date, job, sal, NULL, mgr_id, dep);
	END LOOP;

  	EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_transaction$returned_sqlstate = RETURNED_SQLSTATE,
                error_transaction$message_text = MESSAGE_TEXT,
                  error_transaction$pg_exception_context = PG_EXCEPTION_CONTEXT;
            RAISE NOTICE '% % %', error_transaction$returned_sqlstate, error_transaction$message_text || chr(10),   error_transaction$pg_exception_context;
            
END;
$BODY$
LANGUAGE  plpgsql;




-- ------------ Write DROP-FUNCTION-stage scripts -----------


DROP FUNCTION IF EXISTS hr.update_employee_data_fname(IN numeric);


------------- Write CREATE-FUNCTION-for update employee data -----------
CREATE OR REPLACE FUNCTION hr.update_employee_data_fname(p_num numeric default 5)
RETURNS void
AS
$BODY$
DECLARE

--Function to adjust employee salary to be within min and max range and run update by first_name 

    n hr.employees.employee_id%TYPE DEFAULT 0;
	m hr.employees.employee_id%TYPE DEFAULT 0;
	v_emp_id hr.employees.employee_id%TYPE DEFAULT 1;
	var_current_txn bigint DEFAULT 0;
	minsal hr.employees.salary%TYPE;
	maxsal hr.employees.salary%TYPE;
    nam hr.employees.first_name%TYPE;
    lnam hr.employees.last_name%TYPE;
    sal hr.employees.salary%TYPE;
    job hr.employees.job_id%TYPE;
    error_transaction$returned_sqlstate TEXT;
    error_transaction$message_text TEXT;
    error_transaction$pg_exception_context TEXT;

 BEGIN
select max(employee_id),min(employee_id) into m,n from hr.employees;

WHILE var_current_txn < p_num LOOP
v_emp_id := floor(random()*(m-n+1))+n;

var_current_txn := var_current_txn +1;

         begin
		 select e.first_name, e.last_name, e.salary, e.job_id, j.min_salary,j.max_salary into nam,lnam,sal,job,minsal,maxsal 
		 from hr.employees e, hr.jobs j  where e.employee_id = v_emp_id
		 and e.job_id= j.job_id;
				 

	
        if sal < minsal then
		
		update hr.employees set salary= minsal where first_name=nam;
	
		elsif sal > maxsal then
		update hr.employees set salary= maxsal where first_name=nam;
	
		else
		sal :=1;
	
		end if;
		
         exception when others then
			 continue when var_current_txn < p_num ;
		 end;
		
	END LOOP;

  	EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_transaction$returned_sqlstate = RETURNED_SQLSTATE,
                error_transaction$message_text = MESSAGE_TEXT,
                  error_transaction$pg_exception_context = PG_EXCEPTION_CONTEXT;
            RAISE NOTICE '% % %', error_transaction$returned_sqlstate, error_transaction$message_text || chr(10),   error_transaction$pg_exception_context;
            
END;
$BODY$
LANGUAGE  plpgsql;


-- ------------ Write DROP-FUNCTION-stage scripts -----------

DROP FUNCTION IF EXISTS hr.update_employee_data_empid(IN numeric);


-- ------------ Write CREATE-FUNCTION-stage scripts -----------

CREATE OR REPLACE FUNCTION hr.update_employee_data_empid(p_num numeric default 5 )
RETURNS void
AS
$BODY$
DECLARE
 --Function to adjust employee salary to be within min and max range and run update by employee_id

    n hr.employees.employee_id%TYPE DEFAULT 0;
	m hr.employees.employee_id%TYPE DEFAULT 0;
	v_emp_id hr.employees.employee_id%TYPE DEFAULT 1;
	var_current_txn bigint DEFAULT 0;
	minsal hr.employees.salary%TYPE;
	maxsal hr.employees.salary%TYPE;
    nam hr.employees.first_name%TYPE;
    lnam hr.employees.last_name%TYPE;
    sal hr.employees.salary%TYPE;
    job hr.employees.job_id%TYPE;
	error_transaction$returned_sqlstate TEXT;
    error_transaction$message_text TEXT;
    error_transaction$pg_exception_context TEXT;
  



 BEGIN
select max(employee_id),min(employee_id) into m,n from hr.employees;



WHILE var_current_txn < p_num LOOP

v_emp_id := floor(random()*(m-n+1))+n;



var_current_txn := var_current_txn +1;

         begin
		 select e.first_name, e.last_name, e.salary, e.job_id, j.min_salary,j.max_salary into nam,lnam,sal,job,minsal,maxsal 
		 from hr.employees e, hr.jobs j  where e.employee_id = v_emp_id
		 and e.job_id= j.job_id;
				 

	
        if sal < minsal then
		
		update hr.employees set salary= minsal where employee_id=v_emp_id;
		elsif sal > maxsal then
		update hr.employees set salary= maxsal where employee_id=v_emp_id;
		else
		sal :=1;
		end if;
		
         exception when others then
	
		 continue when var_current_txn < p_num ;
		 end;
		
	END LOOP;

  	EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_transaction$returned_sqlstate = RETURNED_SQLSTATE,
                error_transaction$message_text = MESSAGE_TEXT,
                  error_transaction$pg_exception_context = PG_EXCEPTION_CONTEXT;
            RAISE NOTICE '% % %', error_transaction$returned_sqlstate, error_transaction$message_text || chr(10),   error_transaction$pg_exception_context;
            
END;
$BODY$
LANGUAGE  plpgsql;

-- disable triggers 
--alter table hr.employees disable trigger secure_employees ;
--alter table hr.employees disable trigger update_job_history;



