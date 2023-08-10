-- ------------ Write DROP-FUNCTION-stage scripts -----------

DROP FUNCTION IF EXISTS hr.add_job_history(IN DOUBLE PRECISION, IN TIMESTAMP WITHOUT TIME ZONE, IN TIMESTAMP WITHOUT TIME ZONE, IN TEXT, IN DOUBLE PRECISION);



DROP FUNCTION IF EXISTS hr.secure_dml();





-- ------------ Write CREATE-DATABASE-stage scripts -----------

CREATE SCHEMA IF NOT EXISTS hr;



-- ------------ Write CREATE-SEQUENCE-stage scripts -----------

CREATE SEQUENCE IF NOT EXISTS hr.departments_seq
INCREMENT BY 10
START WITH 1
MAXVALUE 9990
MINVALUE 1
NO CYCLE;



CREATE SEQUENCE IF NOT EXISTS hr.employees_seq
INCREMENT BY 1
START WITH 1
MAXVALUE 9223372036854775807
MINVALUE 1
NO CYCLE;



CREATE SEQUENCE IF NOT EXISTS hr.locations_seq
INCREMENT BY 100
START WITH 1
MAXVALUE 9900
MINVALUE 1
NO CYCLE;



-- ------------ Write CREATE-TABLE-stage scripts -----------

CREATE TABLE hr.countries(
    country_id CHARACTER(2) NOT NULL,
    country_name CHARACTER VARYING(40),
    region_id DOUBLE PRECISION
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE hr.departments(
    department_id NUMERIC(8,0) NOT NULL,
    department_name CHARACTER VARYING(30) NOT NULL,
    manager_id NUMERIC(8,0),
    location_id NUMERIC(8,0)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE hr.employees(
    employee_id NUMERIC(8,0) NOT NULL,
    first_name CHARACTER VARYING(20),
    last_name CHARACTER VARYING(25) NOT NULL,
    email CHARACTER VARYING(25) NOT NULL,
    phone_number CHARACTER VARYING(20),
    hire_date TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    job_id CHARACTER VARYING(10) NOT NULL,
    salary NUMERIC(8,2),
    commission_pct NUMERIC(8,2),
    manager_id NUMERIC(8,0),
    department_id NUMERIC(8,0)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE hr.job_history(
    employee_id NUMERIC(8,0) NOT NULL,
    start_date TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    end_date TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    job_id CHARACTER VARYING(10) NOT NULL,
    department_id NUMERIC(8,0)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE hr.jobs(
    job_id CHARACTER VARYING(10) NOT NULL,
    job_title CHARACTER VARYING(35) NOT NULL,
    min_salary NUMERIC(8,0),
    max_salary NUMERIC(8,0)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE hr.locations(
    location_id NUMERIC(8,0) NOT NULL,
    street_address CHARACTER VARYING(40),
    postal_code CHARACTER VARYING(12),
    city CHARACTER VARYING(30) NOT NULL,
    state_province CHARACTER VARYING(25),
    country_id CHARACTER(2)
)
        WITH (
        OIDS=FALSE
        );



CREATE TABLE hr.regions(
    region_id DOUBLE PRECISION NOT NULL,
    region_name CHARACTER VARYING(25)
)
        WITH (
        OIDS=FALSE
        );



-- ------------ Write CREATE-VIEW-stage scripts -----------

CREATE OR REPLACE VIEW hr.emp_details_view (employee_id, job_id, manager_id, department_id, location_id, country_id, first_name, last_name, salary, commission_pct, department_name, job_title, city, state_province, country_name, region_name) AS
SELECT
    e.employee_id, e.job_id, e.manager_id, e.department_id, d.location_id, l.country_id, e.first_name, e.last_name, e.salary, e.commission_pct, d.department_name, j.job_title, l.city, l.state_province, c.country_name, r.region_name
    FROM hr.employees AS e, hr.departments AS d, hr.jobs AS j, hr.locations AS l, hr.countries AS c, hr.regions AS r
    WHERE e.department_id = d.department_id AND d.location_id = l.location_id AND l.country_id = c.country_id AND c.region_id = r.region_id AND j.job_id = e.job_id;



-- ------------ Write CREATE-CONSTRAINT-stage scripts -----------

ALTER TABLE hr.countries
ADD CONSTRAINT country_c_id_pk PRIMARY KEY (country_id);



ALTER TABLE hr.departments
ADD CONSTRAINT dept_id_pk PRIMARY KEY (department_id);



ALTER TABLE hr.employees
ADD CONSTRAINT emp_emp_id_pk PRIMARY KEY (employee_id);



ALTER TABLE hr.employees
ADD CONSTRAINT emp_salary_min CHECK (salary > 0);



ALTER TABLE hr.job_history
ADD CONSTRAINT jhist_date_interval CHECK (end_date > start_date);



ALTER TABLE hr.job_history
ADD CONSTRAINT jhist_emp_id_st_date_pk PRIMARY KEY (employee_id, start_date);



ALTER TABLE hr.jobs
ADD CONSTRAINT job_id_pk PRIMARY KEY (job_id);



ALTER TABLE hr.locations
ADD CONSTRAINT loc_id_pk PRIMARY KEY (location_id);



ALTER TABLE hr.regions
ADD CONSTRAINT reg_id_pk PRIMARY KEY (region_id);



-- ------------ Write CREATE-FOREIGN-KEY-CONSTRAINT-stage scripts -----------

ALTER TABLE hr.countries
ADD CONSTRAINT countr_reg_fk FOREIGN KEY (region_id) 
REFERENCES hr.regions (region_id)
ON DELETE NO ACTION;



ALTER TABLE hr.departments
ADD CONSTRAINT dept_loc_fk FOREIGN KEY (location_id) 
REFERENCES hr.locations (location_id)
ON DELETE NO ACTION;



ALTER TABLE hr.departments
ADD CONSTRAINT dept_mgr_fk FOREIGN KEY (manager_id) 
REFERENCES hr.employees (employee_id)
ON DELETE NO ACTION;



ALTER TABLE hr.employees
ADD CONSTRAINT emp_dept_fk FOREIGN KEY (department_id) 
REFERENCES hr.departments (department_id)
ON DELETE NO ACTION;



ALTER TABLE hr.employees
ADD CONSTRAINT emp_job_fk FOREIGN KEY (job_id) 
REFERENCES hr.jobs (job_id)
ON DELETE NO ACTION;



ALTER TABLE hr.employees
ADD CONSTRAINT emp_manager_fk FOREIGN KEY (manager_id) 
REFERENCES hr.employees (employee_id)
ON DELETE NO ACTION;



ALTER TABLE hr.job_history
ADD CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id) 
REFERENCES hr.departments (department_id)
ON DELETE NO ACTION;



ALTER TABLE hr.job_history
ADD CONSTRAINT jhist_emp_fk FOREIGN KEY (employee_id) 
REFERENCES hr.employees (employee_id)
ON DELETE NO ACTION;



ALTER TABLE hr.job_history
ADD CONSTRAINT jhist_job_fk FOREIGN KEY (job_id) 
REFERENCES hr.jobs (job_id)
ON DELETE NO ACTION;



ALTER TABLE hr.locations
ADD CONSTRAINT loc_c_id_fk FOREIGN KEY (country_id) 
REFERENCES hr.countries (country_id)
ON DELETE NO ACTION;



-- ------------ Write CREATE-FUNCTION-stage scripts -----------

CREATE OR REPLACE FUNCTION hr.add_job_history(
     IN p_emp_id DOUBLE PRECISION, 
     IN p_start_date TIMESTAMP WITHOUT TIME ZONE, 
     IN p_end_date TIMESTAMP WITHOUT TIME ZONE, 
     IN p_job_id TEXT, 
     IN p_department_id DOUBLE PRECISION)
RETURNS void
AS
$BODY$
BEGIN
    /*
    [5340 - Severity CRITICAL - PostgreSQL doesn't support the ADD_JOB_HISTORY.P_EMP_ID function. Use suitable function or create user defined function., 5340 - Severity CRITICAL - PostgreSQL doesn't support the ADD_JOB_HISTORY.P_START_DATE function. Use suitable function or create user defined function., 5340 - Severity CRITICAL - PostgreSQL doesn't support the ADD_JOB_HISTORY.P_END_DATE function. Use suitable function or create user defined function., 5340 - Severity CRITICAL - PostgreSQL doesn't support the ADD_JOB_HISTORY.P_JOB_ID function. Use suitable function or create user defined function., 5340 - Severity CRITICAL - PostgreSQL doesn't support the ADD_JOB_HISTORY.P_DEPARTMENT_ID function. Use suitable function or create user defined function.]
    INSERT INTO job_history (employee_id, start_date, end_date,
                               job_id, department_id)
        VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id)
    */
    BEGIN
    END;
END;
$BODY$
LANGUAGE  plpgsql;



CREATE OR REPLACE FUNCTION hr.secure_dml()
RETURNS void
AS
$BODY$
BEGIN
    IF aws_oracle_ext.TO_CHAR(aws_oracle_ext.SYSDATE(), 'HH24:MI') NOT BETWEEN '08:00' AND '18:00' OR aws_oracle_ext.TO_CHAR(aws_oracle_ext.SYSDATE(), 'DY') IN ('SAT', 'SUN') THEN
        RAISE USING hint = -20205, message = 'You may only make changes during normal office hours', detail = 'User-defined exception';
    END IF;
END;
$BODY$
LANGUAGE  plpgsql;


