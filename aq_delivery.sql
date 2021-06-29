use `es_extended`;

INSERT INTO `jobs` (name, label, whitelisted) VALUES
  ('delivery', 'Delivery', 0)
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
  ('delivery', 0, 'employee', 'Employee', 0, '{}', '{}')
;
