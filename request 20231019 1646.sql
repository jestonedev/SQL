--
-- Скрипт сгенерирован Devart dbForge Studio for MySQL, Версия 7.4.201.0
-- Домашняя страница продукта: http://www.devart.com/ru/dbforge/mysql/studio
-- Дата скрипта: 19.10.2023 16:46:11
-- Версия сервера: 5.6.19-0ubuntu0.14.04.1-log
-- Версия клиента: 4.1
--

-- 
-- Отключение внешних ключей
-- 
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

-- 
-- Установить режим SQL (SQL mode)
-- 
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- 
-- Установка кодировки, с использованием которой клиент будет посылать запросы на сервер
--
SET NAMES 'utf8';

DROP DATABASE IF EXISTS request;

CREATE DATABASE IF NOT EXISTS request
CHARACTER SET utf8
COLLATE utf8_general_ci;

--
-- Установка базы данных по умолчанию
--
USE request;

--
-- Создать таблицу `fuel_types`
--
CREATE TABLE IF NOT EXISTS fuel_types (
  id_fuel_type int(11) NOT NULL AUTO_INCREMENT,
  fuel_type varchar(10) NOT NULL,
  PRIMARY KEY (id_fuel_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `car_models`
--
CREATE TABLE IF NOT EXISTS car_models (
  id_model int(11) NOT NULL AUTO_INCREMENT,
  model varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_model)
)
ENGINE = INNODB,
AUTO_INCREMENT = 20,
AVG_ROW_LENGTH = 1092,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `cars_chiefs`
--
CREATE TABLE IF NOT EXISTS cars_chiefs (
  id_chief int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  is_active tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_chief)
)
ENGINE = INNODB,
AUTO_INCREMENT = 29,
AVG_ROW_LENGTH = 1170,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `reason_cancellation`
--
CREATE TABLE IF NOT EXISTS reason_cancellation (
  id_reason int(5) NOT NULL AUTO_INCREMENT,
  name varchar(40) NOT NULL,
  PRIMARY KEY (id_reason)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `request_number`
--
CREATE TABLE IF NOT EXISTS request_number (
  id_request_number int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_request int(11) NOT NULL,
  user varchar(15) NOT NULL,
  department varchar(1000) NOT NULL,
  stage varchar(1000) DEFAULT NULL,
  request_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  request_state tinyint(4) NOT NULL,
  alien_department tinyint(1) NOT NULL DEFAULT 0,
  id_reason_cancel int(5) DEFAULT NULL,
  date_change datetime DEFAULT CURRENT_TIMESTAMP,
  reason_reject varchar(150) DEFAULT NULL,
  PRIMARY KEY (id_request_number)
)
ENGINE = INNODB,
AUTO_INCREMENT = 20775,
AVG_ROW_LENGTH = 234,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IX_request_number_alien_department` для объекта типа таблица `request_number`
--
ALTER TABLE request_number
ADD INDEX IX_request_number_alien_department (alien_department);

--
-- Создать индекс `IX_request_number_department` для объекта типа таблица `request_number`
--
ALTER TABLE request_number
ADD INDEX IX_request_number_department (department (255), stage (255));

--
-- Создать индекс `IX_request_number_id_request` для объекта типа таблица `request_number`
--
ALTER TABLE request_number
ADD INDEX IX_request_number_id_request (id_request);

--
-- Создать индекс `IX_request_number_request_date` для объекта типа таблица `request_number`
--
ALTER TABLE request_number
ADD INDEX IX_request_number_request_date (request_date);

--
-- Создать индекс `IX_request_number_request_state` для объекта типа таблица `request_number`
--
ALTER TABLE request_number
ADD INDEX IX_request_number_request_state (request_state);

--
-- Создать индекс `IX_request_number_user` для объекта типа таблица `request_number`
--
ALTER TABLE request_number
ADD INDEX IX_request_number_user (user);

--
-- Создать внешний ключ
--
ALTER TABLE request_number
ADD CONSTRAINT FK_request_number_id_reason_ca FOREIGN KEY (id_reason_cancel)
REFERENCES reason_cancellation (id_reason) ON DELETE NO ACTION;

--
-- Создать представление `v_request_number_2`
--
CREATE
VIEW v_request_number_2
AS
SELECT
  `rn`.`id_request_number` AS `id_request_number`,
  IF((`rn`.`department` = 'Организационно-контрольное управление'), 'Администрация', `rn`.`department`) AS `department`,
  IF((`rn`.`department` = 'Организационно-контрольное управление'), `rn`.`department`, `rn`.`stage`) AS `stage`,
  `rn`.`alien_department` AS `alien_department`,
  `rn`.`request_date` AS `request_date`,
  `rn`.`request_state` AS `request_state`,
  `rn`.`id_request` AS `id_request`,
  `rn`.`id_reason_cancel` AS `id_reason_cancel`
FROM `request_number` `rn`;

--
-- Создать представление `v_request_number`
--
CREATE
VIEW v_request_number
AS
SELECT
  `rn`.`id_request_number` AS `id_request_number`,
  IF((`rn`.`department` = 'Организационно-контрольное управление'), 'Администрация', `rn`.`department`) AS `department`,
  IF((`rn`.`department` = 'Организационно-контрольное управление'), `rn`.`department`, `rn`.`stage`) AS `stage`,
  `rn`.`alien_department` AS `alien_department`,
  `rn`.`request_date` AS `request_date`,
  `rn`.`request_state` AS `request_state`,
  `rn`.`id_request` AS `id_request`
FROM `request_number` `rn`;

--
-- Создать таблицу `request_data`
--
CREATE TABLE IF NOT EXISTS request_data (
  id_request_data int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_request_number int(10) UNSIGNED NOT NULL,
  id_field int(10) UNSIGNED NOT NULL,
  field_value varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_request_data)
)
ENGINE = INNODB,
AUTO_INCREMENT = 275670,
AVG_ROW_LENGTH = 64,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IX_request_data_id_field` для объекта типа таблица `request_data`
--
ALTER TABLE request_data
ADD INDEX IX_request_data_id_field (id_field);

--
-- Создать внешний ключ
--
ALTER TABLE request_data
ADD CONSTRAINT FK_request_data_request_number_id_request_number FOREIGN KEY (id_request_number)
REFERENCES request_number (id_request_number) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать представление `v_data_request`
--
CREATE
VIEW v_data_request
AS
SELECT
  `rn`.`department` AS `department`,
  `rn`.`stage` AS `stage`,
  STR_TO_DATE(`rd`.`field_value`, '%d.%m.%Y') AS `d`,
  `rn`.`id_request_number` AS `id_request_number`
FROM (`request_number` `rn`
  JOIN `request_data` `rd`
    ON ((`rn`.`id_request_number` = `rd`.`id_request_number`)))
WHERE (`rd`.`id_field` = 4)
ORDER BY STR_TO_DATE(`rd`.`field_value`, '%d.%m.%Y') DESC;

--
-- Создать таблицу `respondents`
--
CREATE TABLE IF NOT EXISTS respondents (
  id_respondent int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  PRIMARY KEY (id_respondent)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `mechanics`
--
CREATE TABLE IF NOT EXISTS mechanics (
  id_mechanic int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  is_active bit(1) DEFAULT b'1',
  is_third_party bit(1) DEFAULT b'0',
  PRIMARY KEY (id_mechanic)
)
ENGINE = INNODB,
AUTO_INCREMENT = 7,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `drivers`
--
CREATE TABLE IF NOT EXISTS drivers (
  id_driver int(11) NOT NULL AUTO_INCREMENT,
  id_invent_response_person int(11) DEFAULT NULL,
  name varchar(255) NOT NULL,
  employee_code int(11) DEFAULT NULL,
  license_number varchar(255) DEFAULT NULL,
  class int(11) DEFAULT NULL,
  is_active bit(1) DEFAULT b'1',
  PRIMARY KEY (id_driver)
)
ENGINE = INNODB,
AUTO_INCREMENT = 40,
AVG_ROW_LENGTH = 744,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `cars`
--
CREATE TABLE IF NOT EXISTS cars (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_chief_default int(11) DEFAULT NULL,
  id_model int(11) DEFAULT NULL,
  number varchar(10) DEFAULT NULL,
  type varchar(255) DEFAULT NULL,
  id_fuel_default int(11) NOT NULL DEFAULT 1,
  id_driver_default int(11) DEFAULT NULL,
  department_default varchar(255) DEFAULT NULL,
  is_active tinyint(1) NOT NULL DEFAULT 1,
  sort_order int(11) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 46,
AVG_ROW_LENGTH = 819,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Список автомобилей гаража';

--
-- Создать внешний ключ
--
ALTER TABLE cars
ADD CONSTRAINT FK_cars_cars_chiefs_id_chief FOREIGN KEY (id_chief_default)
REFERENCES cars_chiefs (id_chief) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars
ADD CONSTRAINT FK_cars_fuel_types_id_fuel_type FOREIGN KEY (id_fuel_default)
REFERENCES fuel_types (id_fuel_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars
ADD CONSTRAINT FK_cars_id_driver_default FOREIGN KEY (id_driver_default)
REFERENCES drivers (id_driver) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars
ADD CONSTRAINT FK_cars_id_model FOREIGN KEY (id_model)
REFERENCES car_models (id_model) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `waybills`
--
CREATE TABLE IF NOT EXISTS waybills (
  id_waybill int(11) NOT NULL AUTO_INCREMENT,
  id_car int(11) NOT NULL,
  id_driver int(11) NOT NULL,
  waybill_number varchar(2048) DEFAULT NULL,
  start_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  end_date timestamp NULL DEFAULT NULL,
  department varchar(255) DEFAULT NULL,
  mileage_before int(11) DEFAULT NULL,
  mileage_after int(11) DEFAULT NULL,
  fuel_before float DEFAULT NULL,
  given_fuel float DEFAULT NULL COMMENT 'Выдано топлива',
  fuel_after float DEFAULT NULL,
  id_fuel_type int(11) DEFAULT NULL COMMENT 'Вид топлива',
  deleted tinyint(1) DEFAULT 0,
  locked tinyint(1) DEFAULT 0,
  PRIMARY KEY (id_waybill)
)
ENGINE = INNODB,
AUTO_INCREMENT = 21717,
AVG_ROW_LENGTH = 217,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE waybills
ADD CONSTRAINT FK_waybills_cars_id FOREIGN KEY (id_car)
REFERENCES cars (id) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE waybills
ADD CONSTRAINT FK_waybills_drivers_id_driver FOREIGN KEY (id_driver)
REFERENCES drivers (id_driver) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE waybills
ADD CONSTRAINT FK_waybills_fuel_types_id_fuel_type FOREIGN KEY (id_fuel_type)
REFERENCES fuel_types (id_fuel_type) ON DELETE NO ACTION ON UPDATE CASCADE;

DELIMITER $$

--
-- Создать процедуру `test_proc`
--
CREATE PROCEDURE test_proc ()
BEGIN
  SELECT
    *
  FROM waybills w;
END
$$

DELIMITER ;

--
-- Создать таблицу `ways`
--
CREATE TABLE IF NOT EXISTS ways (
  id_way int(11) NOT NULL AUTO_INCREMENT,
  id_waybill int(11) NOT NULL,
  way varchar(255) DEFAULT NULL,
  start_time time DEFAULT NULL,
  end_time time DEFAULT NULL,
  distance int(11) DEFAULT NULL,
  PRIMARY KEY (id_way)
)
ENGINE = INNODB,
AUTO_INCREMENT = 435,
AVG_ROW_LENGTH = 2048,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE ways
ADD CONSTRAINT FK_ways_waybills_id_waybill FOREIGN KEY (id_waybill)
REFERENCES waybills (id_waybill) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `fuel_month_limit`
--
CREATE TABLE IF NOT EXISTS fuel_month_limit (
  id_fuel_limit int(11) NOT NULL AUTO_INCREMENT,
  id_car int(11) NOT NULL,
  start_date datetime NOT NULL,
  `limit` float NOT NULL,
  PRIMARY KEY (id_fuel_limit)
)
ENGINE = INNODB,
AUTO_INCREMENT = 75,
AVG_ROW_LENGTH = 282,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE fuel_month_limit
ADD CONSTRAINT FK_fuel_limit_id_car FOREIGN KEY (id_car)
REFERENCES cars (id) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `fuel_consumption`
--
CREATE TABLE IF NOT EXISTS fuel_consumption (
  id_fuel_consumption int(11) NOT NULL AUTO_INCREMENT,
  id_car int(11) NOT NULL,
  start_date datetime NOT NULL,
  fuel_consumption float NOT NULL,
  PRIMARY KEY (id_fuel_consumption)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3379,
AVG_ROW_LENGTH = 133,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE fuel_consumption
ADD CONSTRAINT FK_fuel_consumption_cars_id FOREIGN KEY (id_car)
REFERENCES cars (id) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `cars_repair_acts`
--
CREATE TABLE IF NOT EXISTS cars_repair_acts (
  id_repair int(11) NOT NULL AUTO_INCREMENT,
  id_car int(11) NOT NULL,
  id_performer int(11) NOT NULL,
  id_driver int(11) NOT NULL,
  id_respondent int(11) NOT NULL,
  repair_act_number int(11) DEFAULT NULL,
  act_date datetime DEFAULT NULL COMMENT 'Дата создания акта',
  reason_for_repairs varchar(255) DEFAULT NULL,
  work_performed varchar(255) DEFAULT NULL,
  odometer int(11) DEFAULT NULL,
  wait_start_date datetime DEFAULT NULL COMMENT 'Дата начала ожидания запчасти',
  wait_end_date datetime DEFAULT NULL COMMENT 'Дата окончания ожидания запчасти',
  repair_start_date datetime DEFAULT NULL COMMENT 'Дата начала ремонта',
  repair_end_date datetime DEFAULT NULL COMMENT 'Дата окончания ремонта',
  self_repair tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Собственный ремонт',
  id_document int(11) DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_repair)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1231,
AVG_ROW_LENGTH = 260,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE cars_repair_acts
ADD CONSTRAINT FK_cars_repair_acts_cars_id FOREIGN KEY (id_car)
REFERENCES cars (id) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars_repair_acts
ADD CONSTRAINT FK_cars_repair_acts_drivers_id_driver FOREIGN KEY (id_driver)
REFERENCES drivers (id_driver) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars_repair_acts
ADD CONSTRAINT FK_cars_repair_acts_mechanics_id_mechanic FOREIGN KEY (id_performer)
REFERENCES mechanics (id_mechanic) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars_repair_acts
ADD CONSTRAINT FK_cars_repair_acts_respondents_id_respondent FOREIGN KEY (id_respondent)
REFERENCES respondents (id_respondent) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `expended`
--
CREATE TABLE IF NOT EXISTS expended (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_repair int(11) NOT NULL,
  material varchar(255) NOT NULL,
  count float NOT NULL,
  description varchar(2048) DEFAULT NULL,
  id_material int(11) DEFAULT NULL,
  id_contractor int(11) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 6571,
AVG_ROW_LENGTH = 120,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE expended
ADD CONSTRAINT FK_expended_cars_repair_acts_id_repair FOREIGN KEY (id_repair)
REFERENCES cars_repair_acts (id_repair) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `cars_maintenances`
--
CREATE TABLE IF NOT EXISTS cars_maintenances (
  id_maintenance int(11) NOT NULL AUTO_INCREMENT,
  id_car int(11) NOT NULL,
  id_performer int(11) NOT NULL,
  id_driver int(11) NOT NULL,
  id_respondent int(11) NOT NULL,
  maintenance_number int(11) DEFAULT NULL,
  maintenance_date datetime DEFAULT NULL COMMENT 'Дата создания акта',
  reason_for_maintenance varchar(255) DEFAULT NULL,
  odometer int(11) DEFAULT NULL,
  wait_start_date datetime DEFAULT NULL COMMENT 'Дата начала ожидания запчасти',
  wait_end_date datetime DEFAULT NULL COMMENT 'Дата окончания ожидания запчасти',
  maintenance_start_date datetime DEFAULT NULL COMMENT 'Дата начала ремонта',
  maintenance_end_date datetime DEFAULT NULL COMMENT 'Дата окончания ремонта',
  id_document int(11) DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_maintenance)
)
ENGINE = INNODB,
AUTO_INCREMENT = 177,
AVG_ROW_LENGTH = 172,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE cars_maintenances
ADD CONSTRAINT FK_cars_maintenance_cars_id FOREIGN KEY (id_car)
REFERENCES cars (id) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars_maintenances
ADD CONSTRAINT FK_cars_maintenance_drivers_id_driver FOREIGN KEY (id_driver)
REFERENCES drivers (id_driver) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars_maintenances
ADD CONSTRAINT FK_cars_maintenance_mechanics_id_mechanic FOREIGN KEY (id_performer)
REFERENCES mechanics (id_mechanic) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars_maintenances
ADD CONSTRAINT FK_cars_maintenance_respondents_id_respondent FOREIGN KEY (id_respondent)
REFERENCES respondents (id_respondent) ON DELETE NO ACTION ON UPDATE CASCADE;

DELIMITER $$

--
-- Создать процедуру `UpdateTrailingWaybills`
--
CREATE PROCEDURE UpdateTrailingWaybills (IN id_car_param int, IN from_date_param date,
IN fuel_after_prev_param float, IN mileage_after_prev_param int, IN calc_for_first_record bit)
BEGIN
  DECLARE id_waybill_prop int;
  DECLARE mileage_before_prop int;
  DECLARE mileage_after_prop int;
  DECLARE mileage_after_prev_prop int;
  DECLARE fuel_before_prop decimal(18, 3);
  DECLARE given_fuel_prop decimal(18, 3);
  DECLARE fuel_after_prop decimal(18, 3);
  DECLARE fuel_after_prev_prop decimal(18, 3);
  DECLARE start_date_prop date;
  DECLARE is_first_record bit DEFAULT 1;
  DECLARE fuel_consumption_prop decimal(18, 3);
  DECLARE id_repair_prop int;
  DECLARE id_maintenance_prop int;
  DECLARE repair_date_prop date;
  DECLARE maintenance_date_prop date;
  DECLARE id_car_prop int;
  DECLARE done integer DEFAULT 0;
  DECLARE cur CURSOR FOR
  SELECT
    w.id_waybill,
    w.mileage_before,
    w.mileage_after,
    w.fuel_before,
    w.given_fuel,
    w.fuel_after,
    w.start_date
  FROM waybills w
  WHERE w.deleted <> 1
  AND w.id_car = id_car_param
  AND w.start_date >= from_date_param
  ORDER BY w.start_date, LPAD(w.waybill_number, 10, '0');
  DECLARE cur_rep_acts CURSOR FOR
  SELECT
    cra.id_repair,
    IFNULL(cra.repair_start_date, cra.act_date) AS repair_date,
    cra.id_car
  FROM cars_repair_acts cra
  WHERE cra.deleted <> 1
  AND IFNULL(cra.repair_start_date, cra.act_date) >= from_date_param;
  DECLARE cur_maintenances CURSOR FOR
  SELECT
    cm.id_maintenance,
    IFNULL(cm.maintenance_start_date, cm.maintenance_date) AS maintenance_date,
    cm.id_car
  FROM cars_maintenances cm
  WHERE cm.deleted <> 1
  AND IFNULL(cm.maintenance_start_date, cm.maintenance_date) >= from_date_param;
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

  IF (fuel_after_prev_param IS NOT NULL
    AND mileage_after_prev_param IS NOT NULL) THEN
    SET is_first_record = 0;
    SET fuel_after_prev_prop = IF(YEAR(from_date_param) <= 2018, ROUND(fuel_after_prev_param, 3), ROUND(fuel_after_prev_param, 2));
    SET mileage_after_prev_prop = mileage_after_prev_param;
  END IF;

  IF ((SELECT
        COUNT(*)
      FROM waybills w
      WHERE w.deleted <> 1
      AND w.locked = 1
      AND w.start_date >= from_date_param
      AND w.id_car = id_car_param) = 0) THEN
    OPEN cur;

  circle1:
    WHILE done = 0 DO
      FETCH cur INTO id_waybill_prop, mileage_before_prop, mileage_after_prop,
      fuel_before_prop, given_fuel_prop, fuel_after_prop, start_date_prop;
      IF (done = 1) THEN
        LEAVE circle1;
      END IF;
      IF is_first_record = 1
        AND calc_for_first_record = 0 THEN
        SET is_first_record = 0;
        IF (fuel_after_prop IS NOT NULL) THEN
          SET fuel_after_prev_prop = fuel_after_prop;
        END IF;
        IF (mileage_after_prop IS NOT NULL) THEN
          SET mileage_after_prev_prop = mileage_after_prop;
        END IF;
      ELSE
        IF (is_first_record = 1) THEN
          SET is_first_record = 0;
          IF (fuel_after_prop IS NOT NULL) THEN
            SET fuel_after_prev_prop = fuel_before_prop;
          END IF;
          IF (mileage_after_prop IS NOT NULL) THEN
            SET mileage_after_prev_prop = mileage_before_prop;
          END IF;
        END IF;

        SELECT
          fc.fuel_consumption INTO fuel_consumption_prop
        FROM fuel_consumption fc
        WHERE fc.id_car = id_car_param
        AND date (fc.start_date) <= start_date_prop
        ORDER BY fc.start_date DESC
        LIMIT 1;

        UPDATE waybills w
        SET w.fuel_after =
            IF(YEAR(w.start_date) <= 2018,
            ROUND(ROUND(fuel_after_prev_prop, 3) - ROUND((w.mileage_after - w.mileage_before) * fuel_consumption_prop / 100, 3) + IFNULL(given_fuel_prop, 0), 3),
            ROUND(ROUND(fuel_after_prev_prop, 2) - ROUND((w.mileage_after - w.mileage_before) * fuel_consumption_prop / 100, 2) + IFNULL(given_fuel_prop, 0), 2)
            ),
            w.fuel_before = IF(YEAR(w.start_date) <= 2018, ROUND(fuel_after_prev_prop, 3), ROUND(fuel_after_prev_prop, 2)),
            w.mileage_after = mileage_after_prev_prop + (w.mileage_after - w.mileage_before),
            w.mileage_before = mileage_after_prev_prop
        WHERE w.id_waybill = id_waybill_prop;

        SELECT
          IF(YEAR(w.start_date) <= 2018, ROUND(fuel_after, 3), ROUND(fuel_after, 2)) INTO fuel_after_prev_prop
        FROM waybills w
        WHERE w.id_waybill = id_waybill_prop;

        SELECT
          mileage_after INTO mileage_after_prev_prop
        FROM waybills w
        WHERE w.id_waybill = id_waybill_prop;


      END IF;
    END WHILE;
    CLOSE cur;
  END IF;

  SET done = 0;
  OPEN cur_rep_acts;

circle2:
  WHILE done = 0 DO
    FETCH cur_rep_acts INTO id_repair_prop, repair_date_prop, id_car_prop;
    IF (done = 1) THEN
      LEAVE circle2;
    END IF;
    SELECT
      mileage_after INTO mileage_after_prop
    FROM (SELECT
        *
      FROM (SELECT
          w.mileage_after
        FROM waybills w
        WHERE w.id_car = id_car_prop
        AND w.deleted <> 1
        AND w.start_date < repair_date_prop
        ORDER BY w.start_date DESC, w.id_waybill DESC) v
      UNION ALL
      SELECT
        0
      LIMIT 1) v;
    UPDATE cars_repair_acts cra
    SET cra.odometer = mileage_after_prop
    WHERE cra.id_repair = id_repair_prop;
  END WHILE;

  CLOSE cur_rep_acts;

  SET done = 0;
  OPEN cur_maintenances;

circle3:
  WHILE done = 0 DO
    FETCH cur_maintenances INTO id_maintenance_prop, maintenance_date_prop, id_car_prop;
    IF (done = 1) THEN
      LEAVE circle3;
    END IF;
    SELECT
      mileage_after INTO mileage_after_prop
    FROM (SELECT
        *
      FROM (SELECT
          w.mileage_after
        FROM waybills w
        WHERE w.id_car = id_car_prop
        AND w.deleted <> 1
        AND w.start_date < maintenance_date_prop
        ORDER BY w.start_date DESC, w.id_waybill DESC) v
      UNION ALL
      SELECT
        0
      LIMIT 1) v;
    UPDATE cars_maintenances cm
    SET cm.odometer = mileage_after_prop
    WHERE cm.id_maintenance = id_maintenance_prop;
  END WHILE;

  CLOSE cur_maintenances;

END
$$

DELIMITER ;

--
-- Создать таблицу `cars_hided_from_managment`
--
CREATE TABLE IF NOT EXISTS cars_hided_from_managment (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  id_car int(11) DEFAULT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 40,
AVG_ROW_LENGTH = 910,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE cars_hided_from_managment
ADD CONSTRAINT FK_cars_hided_from_managment_i FOREIGN KEY (id_car)
REFERENCES cars (id) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `cars_for_transport_requests`
--
CREATE TABLE IF NOT EXISTS cars_for_transport_requests (
  id_request_number int(10) UNSIGNED NOT NULL,
  id_car int(11) NOT NULL,
  PRIMARY KEY (id_car, id_request_number)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 33,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `id_request_number` для объекта типа таблица `cars_for_transport_requests`
--
ALTER TABLE cars_for_transport_requests
ADD UNIQUE INDEX id_request_number (id_request_number);

--
-- Создать внешний ключ
--
ALTER TABLE cars_for_transport_requests
ADD CONSTRAINT FK_cars_for_transport_requests FOREIGN KEY (id_car)
REFERENCES cars (id) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars_for_transport_requests
ADD CONSTRAINT FK_cars_for_transport_requests_request_number_id_request_number FOREIGN KEY (id_request_number)
REFERENCES request_number (id_request_number) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `sp_tire_states`
--
CREATE TABLE IF NOT EXISTS sp_tire_states (
  id_state int(11) NOT NULL AUTO_INCREMENT,
  state varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_state)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `tires`
--
CREATE TABLE IF NOT EXISTS tires (
  id_tire int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  count_in_set int(11) NOT NULL DEFAULT 4,
  width int(11) DEFAULT NULL,
  height int(11) DEFAULT NULL,
  diameter int(11) DEFAULT NULL,
  start_working_date date DEFAULT NULL,
  id_state int(11) DEFAULT NULL,
  id_document int(11) DEFAULT NULL,
  id_material int(11) DEFAULT NULL,
  id_contractor int(11) DEFAULT NULL,
  PRIMARY KEY (id_tire)
)
ENGINE = INNODB,
AUTO_INCREMENT = 43,
AVG_ROW_LENGTH = 390,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE tires
ADD CONSTRAINT FK_tires_id_state FOREIGN KEY (id_state)
REFERENCES sp_tire_states (id_state) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `sp_maintenance_work_types`
--
CREATE TABLE IF NOT EXISTS sp_maintenance_work_types (
  id_work_type int(11) NOT NULL AUTO_INCREMENT,
  work_type varchar(255) NOT NULL,
  PRIMARY KEY (id_work_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 14,
AVG_ROW_LENGTH = 1820,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `cars_maintenances_plan`
--
CREATE TABLE IF NOT EXISTS cars_maintenances_plan (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  id_car int(11) DEFAULT NULL,
  id_work_type int(11) NOT NULL,
  control_period int(11) DEFAULT NULL,
  maintenance_period int(11) DEFAULT NULL,
  maintenance_distance int(11) DEFAULT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 87,
AVG_ROW_LENGTH = 207,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `UK_cars_maintenances_plan` для объекта типа таблица `cars_maintenances_plan`
--
ALTER TABLE cars_maintenances_plan
ADD UNIQUE INDEX UK_cars_maintenances_plan (id_car, id_work_type);

--
-- Создать внешний ключ
--
ALTER TABLE cars_maintenances_plan
ADD CONSTRAINT FK_cars_maintenances_plan_id_c FOREIGN KEY (id_car)
REFERENCES cars (id) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars_maintenances_plan
ADD CONSTRAINT FK_cars_maintenances_plan_id_w FOREIGN KEY (id_work_type)
REFERENCES sp_maintenance_work_types (id_work_type) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `cars_maintenance_works_monitoring`
--
CREATE TABLE IF NOT EXISTS cars_maintenance_works_monitoring (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  id_work_type int(11) NOT NULL,
  id_car int(11) DEFAULT NULL,
  control_period int(11) DEFAULT NULL,
  maintenance_period int(11) DEFAULT NULL,
  maintenance_distance int(11) DEFAULT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE cars_maintenance_works_monitoring
ADD CONSTRAINT FK_cars_maintenance_works_mon2 FOREIGN KEY (id_car)
REFERENCES cars (id) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars_maintenance_works_monitoring
ADD CONSTRAINT FK_cars_maintenance_works_moni FOREIGN KEY (id_work_type)
REFERENCES sp_maintenance_work_types (id_work_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `sp_maintenance_work_categories`
--
CREATE TABLE IF NOT EXISTS sp_maintenance_work_categories (
  id_work_category int(11) NOT NULL AUTO_INCREMENT,
  work_category varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_work_category)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `cars_maintenance_works`
--
CREATE TABLE IF NOT EXISTS cars_maintenance_works (
  id_work int(11) NOT NULL AUTO_INCREMENT,
  id_maintenance int(11) DEFAULT NULL,
  id_work_type int(11) DEFAULT NULL,
  id_work_category int(11) DEFAULT NULL,
  PRIMARY KEY (id_work)
)
ENGINE = INNODB,
AUTO_INCREMENT = 787,
AVG_ROW_LENGTH = 66,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE cars_maintenance_works
ADD CONSTRAINT FK_cars_maintenance_works_id_2 FOREIGN KEY (id_work_category)
REFERENCES sp_maintenance_work_categories (id_work_category) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars_maintenance_works
ADD CONSTRAINT FK_cars_maintenance_works_id_m FOREIGN KEY (id_maintenance)
REFERENCES cars_maintenances (id_maintenance) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE cars_maintenance_works
ADD CONSTRAINT FK_cars_maintenance_works_id_w FOREIGN KEY (id_work_type)
REFERENCES sp_maintenance_work_types (id_work_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать представление `v_last_maintenance_date`
--
CREATE
VIEW v_last_maintenance_date
AS
SELECT
  `cm`.`id_car` AS `id_car`,
  `cmw`.`id_work_type` AS `id_work_type`,
  `cmw`.`id_work_category` AS `id_work_category`,
  MAX(`cm`.`maintenance_date`) AS `maintenance_date`
FROM (`cars_maintenances` `cm`
  JOIN `cars_maintenance_works` `cmw`
    ON ((`cm`.`id_maintenance` = `cmw`.`id_maintenance`)))
WHERE ((`cm`.`deleted` <> 1)
AND (`cmw`.`id_work_category` = 2))
GROUP BY `cm`.`id_car`,
         `cmw`.`id_work_type`,
         `cmw`.`id_work_category`;

--
-- Создать представление `v_last_control_date`
--
CREATE
VIEW v_last_control_date
AS
SELECT
  `cm`.`id_car` AS `id_car`,
  `cmw`.`id_work_type` AS `id_work_type`,
  `cmw`.`id_work_category` AS `id_work_category`,
  MAX(`cm`.`maintenance_date`) AS `control_date`
FROM (`cars_maintenances` `cm`
  JOIN `cars_maintenance_works` `cmw`
    ON ((`cm`.`id_maintenance` = `cmw`.`id_maintenance`)))
WHERE ((`cm`.`deleted` <> 1)
AND (`cmw`.`id_work_category` = 1))
GROUP BY `cm`.`id_car`,
         `cmw`.`id_work_type`,
         `cmw`.`id_work_category`;

--
-- Создать таблицу `cars_maintenance_work_materials`
--
CREATE TABLE IF NOT EXISTS cars_maintenance_work_materials (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_work int(11) NOT NULL,
  material varchar(255) NOT NULL,
  count float NOT NULL,
  description varchar(2048) DEFAULT NULL,
  id_material int(11) DEFAULT NULL,
  id_contractor int(11) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 932,
AVG_ROW_LENGTH = 173,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE cars_maintenance_work_materials
ADD CONSTRAINT FK_cars_maintenance_work_materials_id_work FOREIGN KEY (id_work)
REFERENCES cars_maintenance_works (id_work) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `sp_polarities`
--
CREATE TABLE IF NOT EXISTS sp_polarities (
  id_polarity int(11) NOT NULL AUTO_INCREMENT,
  polarity varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_polarity)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `sp_accumulator_states`
--
CREATE TABLE IF NOT EXISTS sp_accumulator_states (
  id_state int(11) NOT NULL AUTO_INCREMENT,
  state varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_state)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `accumulators`
--
CREATE TABLE IF NOT EXISTS accumulators (
  id_accumulator int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  capacity int(11) DEFAULT NULL,
  start_amperage float DEFAULT NULL,
  is_serviced bit(1) DEFAULT NULL,
  id_polarity int(11) DEFAULT NULL,
  start_working_date datetime DEFAULT NULL COMMENT 'Дата ввода в эксплуатацию',
  id_state int(11) DEFAULT 1,
  id_document int(11) DEFAULT NULL,
  id_material int(11) DEFAULT NULL,
  id_contractor int(11) DEFAULT NULL,
  PRIMARY KEY (id_accumulator)
)
ENGINE = INNODB,
AUTO_INCREMENT = 39,
AVG_ROW_LENGTH = 682,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE accumulators
ADD CONSTRAINT FK_accumulators_id_polarity FOREIGN KEY (id_polarity)
REFERENCES sp_polarities (id_polarity) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE accumulators
ADD CONSTRAINT FK_accumulators_id_state FOREIGN KEY (id_state)
REFERENCES sp_accumulator_states (id_state) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `accumulators_maintenances`
--
CREATE TABLE IF NOT EXISTS accumulators_maintenances (
  id_maintenance int(11) NOT NULL AUTO_INCREMENT,
  id_accumulator int(11) DEFAULT NULL,
  start_date date DEFAULT NULL,
  end_date date DEFAULT NULL,
  input_voltage_under_load float DEFAULT NULL,
  input_voltage_without_load float DEFAULT NULL,
  output_voltage_under_load float DEFAULT NULL,
  output_voltage_without_load float DEFAULT NULL,
  electrolyte_level int(11) DEFAULT NULL,
  deleted bit(1) DEFAULT b'0',
  PRIMARY KEY (id_maintenance)
)
ENGINE = INNODB,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE accumulators_maintenances
ADD CONSTRAINT FK_accumulators_maintenances_2 FOREIGN KEY (id_accumulator)
REFERENCES accumulators (id_accumulator) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `accumulators_exploitation`
--
CREATE TABLE IF NOT EXISTS accumulators_exploitation (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  id_car int(11) DEFAULT NULL,
  id_accumulator int(11) DEFAULT NULL,
  install_date datetime DEFAULT NULL,
  uninstall_date datetime DEFAULT NULL,
  mileages int(11) DEFAULT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 71,
AVG_ROW_LENGTH = 546,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE accumulators_exploitation
ADD CONSTRAINT FK_accumulators_exploitation_2 FOREIGN KEY (id_accumulator)
REFERENCES accumulators (id_accumulator) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE accumulators_exploitation
ADD CONSTRAINT FK_accumulators_exploitation_i FOREIGN KEY (id_car)
REFERENCES cars (id) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `sp_request_status`
--
CREATE TABLE IF NOT EXISTS sp_request_status (
  id_request_status int(11) NOT NULL AUTO_INCREMENT,
  request_status varchar(30) NOT NULL,
  email_notify_template varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_request_status)
)
ENGINE = INNODB,
AUTO_INCREMENT = 7,
AVG_ROW_LENGTH = 2730,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Статусы заявок. Названия статусов жестко завязаны на подсветку (может потом поменяю). При смене названия статуса, необходимо править код подсветки статуса.';

--
-- Создать представление `requests`
--
CREATE
VIEW requests
AS
SELECT
  `a`.`id_request` AS `id_request`,
  `a`.`id_request_number` AS `id_request_number`,
  `a`.`user` AS `user`,
  `a`.`department` AS `department`,
  `a`.`request_date` AS `request_date`,
  `b`.`request_status` AS `request_status`
FROM (`request_number` `a`
  JOIN `sp_request_status` `b`
    ON ((`a`.`request_state` = `b`.`id_request_status`)))
ORDER BY `a`.`id_request_number`;

--
-- Создать таблицу `sp_tire_uninstall_reasons`
--
CREATE TABLE IF NOT EXISTS sp_tire_uninstall_reasons (
  id_uninstall_reason int(11) NOT NULL AUTO_INCREMENT,
  uninstall_reason varchar(255) NOT NULL,
  PRIMARY KEY (id_uninstall_reason)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `tires_exploitation`
--
CREATE TABLE IF NOT EXISTS tires_exploitation (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  id_car int(11) DEFAULT NULL,
  id_tire int(11) DEFAULT NULL,
  install_date datetime DEFAULT NULL,
  uninstall_date datetime DEFAULT NULL,
  mileages int(11) DEFAULT NULL,
  install_tread_depth float DEFAULT NULL,
  install_description varchar(2048) DEFAULT NULL,
  install_description_file_attachment varchar(1024) DEFAULT NULL,
  id_uninstall_reason int(11) DEFAULT NULL,
  uninstall_tread_depth float DEFAULT NULL,
  uninstall_description varchar(2048) DEFAULT NULL,
  uninstall_description_file_attachment varchar(1024) DEFAULT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 21,
AVG_ROW_LENGTH = 963,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE tires_exploitation
ADD CONSTRAINT FK_tiers_exploitation_id_car FOREIGN KEY (id_car)
REFERENCES cars (id) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tires_exploitation
ADD CONSTRAINT FK_tiers_exploitation_id_tier FOREIGN KEY (id_tire)
REFERENCES tires (id_tire) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tires_exploitation
ADD CONSTRAINT FK_tiers_exploitation_id_unins FOREIGN KEY (id_uninstall_reason)
REFERENCES sp_tire_uninstall_reasons (id_uninstall_reason) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `_repair_doc_assoc`
--
CREATE TABLE IF NOT EXISTS _repair_doc_assoc (
  id_repair int(11) NOT NULL DEFAULT 0,
  id_document int(11) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 58,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_invent_doc_assoc`
--
CREATE TABLE IF NOT EXISTS _invent_doc_assoc (
  Id int(11) DEFAULT NULL,
  IdOld int(11) DEFAULT NULL,
  DocumentTypeId int(11) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 88,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `warning_message`
--
CREATE TABLE IF NOT EXISTS warning_message (
  id int(11) NOT NULL,
  message varchar(255) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `id_UNIQUE` для объекта типа таблица `warning_message`
--
ALTER TABLE warning_message
ADD UNIQUE INDEX id_UNIQUE (id);

--
-- Создать таблицу `user_privileges`
--
CREATE TABLE IF NOT EXISTS user_privileges (
  id int(11) NOT NULL AUTO_INCREMENT,
  user varchar(255) NOT NULL,
  privilege int(11) NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 145,
AVG_ROW_LENGTH = 297,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Привелегии пользоватлей. Используется маска привелегий. Полный перечень есть в файле auth.php';

--
-- Создать индекс `user` для объекта типа таблица `user_privileges`
--
ALTER TABLE user_privileges
ADD UNIQUE INDEX user (user);

--
-- Создать таблицу `sp_request`
--
CREATE TABLE IF NOT EXISTS sp_request (
  id_request int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  request_name varchar(50) NOT NULL COMMENT 'название заявки',
  request_description varchar(500) NOT NULL COMMENT 'описание заявки',
  PRIMARY KEY (id_request)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `sp_field_type`
--
CREATE TABLE IF NOT EXISTS sp_field_type (
  id_field_type int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  field_type varchar(20) NOT NULL,
  PRIMARY KEY (id_field_type)
)
ENGINE = INNODB,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `sp_field_data`
--
CREATE TABLE IF NOT EXISTS sp_field_data (
  id_field_data int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_field int(10) UNSIGNED NOT NULL,
  field_data_value varchar(100) NOT NULL,
  field_data_order tinyint(4) UNSIGNED NOT NULL,
  PRIMARY KEY (id_field_data)
)
ENGINE = INNODB,
AUTO_INCREMENT = 15,
AVG_ROW_LENGTH = 1170,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `sp_field`
--
CREATE TABLE IF NOT EXISTS sp_field (
  id_field int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_request int(10) UNSIGNED NOT NULL,
  field_name varchar(50) NOT NULL COMMENT 'название поля',
  field_type varchar(10) NOT NULL DEFAULT 'text' COMMENT 'тип поля - textarea text checkbox select',
  field_order tinyint(4) NOT NULL DEFAULT 1 COMMENT 'порядок отображения поля в заявке',
  field_value_type varchar(20) NOT NULL DEFAULT 'string' COMMENT 'тип значения поля',
  field_required tinyint(1) NOT NULL DEFAULT 0 COMMENT 'обязательное для заполнения',
  PRIMARY KEY (id_field)
)
ENGINE = INNODB,
AUTO_INCREMENT = 31,
AVG_ROW_LENGTH = 606,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IX_sp_field_id_request` для объекта типа таблица `sp_field`
--
ALTER TABLE sp_field
ADD INDEX IX_sp_field_id_request (id_request);

--
-- Создать таблицу `reports_info`
--
CREATE TABLE IF NOT EXISTS reports_info (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL COMMENT 'Отображаемое название запроса',
  query mediumtext NOT NULL,
  columns_names varchar(255) NOT NULL COMMENT 'Имена столбцов стаблицы через запятую',
  index_column varchar(255) NOT NULL,
  id_request int(11) NOT NULL,
  is_active bit(1) DEFAULT b'1',
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 50,
AVG_ROW_LENGTH = 6931,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Информация для формирования отчетной формы';

--
-- Создать индекс `name` для объекта типа таблица `reports_info`
--
ALTER TABLE reports_info
ADD UNIQUE INDEX name (name);

--
-- Создать таблицу `mileages`
--
CREATE TABLE IF NOT EXISTS mileages (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_car int(11) NOT NULL,
  id_car_chief int(11) DEFAULT NULL COMMENT 'Руководитель/владелец автомобиля на данный момент',
  mileage int(11) NOT NULL COMMENT 'пробег',
  date date NOT NULL COMMENT 'дата начисления пробега',
  mileage_type int(11) NOT NULL DEFAULT 0 COMMENT 'Тип пробега: лимит по пробегу - 1, фактический пробег - 0',
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 21241,
AVG_ROW_LENGTH = 84,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Таблица хранит информацию о пробегах каждого автомобиля';

--
-- Создать таблицу `limite_req_except_dep`
--
CREATE TABLE IF NOT EXISTS limite_req_except_dep (
  ID int(11) NOT NULL AUTO_INCREMENT,
  Department varchar(1000) NOT NULL,
  MaxReq int(11) NOT NULL,
  Stage varchar(1000) DEFAULT NULL,
  PRIMARY KEY (ID)
)
ENGINE = INNODB,
AUTO_INCREMENT = 27,
AVG_ROW_LENGTH = 1092,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Список департаментов, для которых заданы особые значения лимита';

--
-- Создать таблицу `dep_abbrs`
--
CREATE TABLE IF NOT EXISTS dep_abbrs (
  ID int(11) NOT NULL AUTO_INCREMENT,
  department varchar(1000) NOT NULL,
  abbr varchar(10) NOT NULL,
  PRIMARY KEY (ID)
)
ENGINE = INNODB,
AUTO_INCREMENT = 56,
AVG_ROW_LENGTH = 512,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Ассоциация наименований департаментов с их аббривиатурами';

--
-- Создать индекс `assoc` для объекта типа таблица `dep_abbrs`
--
ALTER TABLE dep_abbrs
ADD UNIQUE INDEX assoc (abbr);

--
-- Создать таблицу `calendar_fields`
--
CREATE TABLE IF NOT EXISTS calendar_fields (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_request int(11) NOT NULL,
  start_date_field int(11) NOT NULL,
  start_time_field int(11) NOT NULL,
  duration_field int(11) NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Информация об индексах полей начальной даты, времени и продолжительности для календаря в таблице sp_field';

--
-- Создать индекс `id_request` для объекта типа таблица `calendar_fields`
--
ALTER TABLE calendar_fields
ADD UNIQUE INDEX id_request (id_request);

--
-- Создать таблицу `broadcast_notify_users`
--
CREATE TABLE IF NOT EXISTS broadcast_notify_users (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_request int(11) NOT NULL,
  user varchar(15) NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 8,
AVG_ROW_LENGTH = 2730,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Список broadcast-пользователей, которым приходит уведомление о новых заявках';

--
-- Создать индекс `user` для объекта типа таблица `broadcast_notify_users`
--
ALTER TABLE broadcast_notify_users
ADD UNIQUE INDEX user (id_request, user);

DELIMITER $$

--
-- Создать процедуру `Get_Users_String`
--
CREATE PROCEDURE Get_Users_String ()
COMMENT 'делает строку пользователей, пригождается когда нужно узнать о них инфу(http://turniket/test/test.php?login_list=)'
BEGIN
  SELECT
    GROUP_CONCAT(REPLACE(up.user, 'PWR\\', ''))
  FROM user_privileges up
  WHERE (up.privilege & 0x80) = 0x80; -- только на транспорт

END
$$

--
-- Создать функцию `ReplaceAllExcerptDigits`
--
CREATE FUNCTION ReplaceAllExcerptDigits (str varchar(2048))
RETURNS int(11)
BEGIN
  DECLARE result varchar(2048);
  DECLARE curChar char;
  SET result = '';
  WHILE CHARACTER_LENGTH(str) > 0 DO
    SET curChar = SUBSTRING(str, 1, 1);
    SET str = SUBSTRING(str, 2);
    IF curChar REGEXP '[0-9]' THEN
      SET result = CONCAT(result, curChar);
    END IF;
  END WHILE;
  RETURN result;
END
$$

--
-- Создать функцию `repair_time_calc`
--
CREATE FUNCTION repair_time_calc (repair_start_date datetime, repair_end_date datetime, wait_start_date datetime, wait_end_date datetime)
RETURNS float
BEGIN
  IF repair_start_date >= repair_end_date THEN
    RETURN 0;
  END IF;

  IF wait_start_date IS NULL
    OR wait_end_date IS NULL
    OR wait_end_date <= wait_start_date THEN
    RETURN TIME_TO_SEC(TIMEDIFF(repair_end_date, repair_start_date)) / 60 / 60;
  END IF;

  IF wait_start_date >= repair_start_date
    AND wait_start_date < repair_end_date
    AND wait_end_date >= repair_end_date THEN
    RETURN TIME_TO_SEC(TIMEDIFF(wait_start_date, repair_start_date)) / 60 / 60;
  END IF;

  IF wait_end_date > repair_start_date
    AND wait_end_date <= repair_end_date
    AND wait_start_date <= repair_start_date THEN
    RETURN TIME_TO_SEC(TIMEDIFF(repair_end_date, wait_end_date)) / 60 / 60;
  END IF;

  IF wait_start_date >= repair_start_date
    AND wait_start_date < repair_end_date
    AND wait_end_date > repair_start_date
    AND wait_end_date <= repair_end_date THEN
    RETURN (
    TIME_TO_SEC(TIMEDIFF(repair_end_date, repair_start_date)) -
    TIME_TO_SEC(TIMEDIFF(wait_end_date, wait_start_date))) / 60 / 60;
  END IF;

  IF (wait_start_date >= repair_end_date
    OR wait_end_date <= repair_start_date) THEN
    RETURN TIME_TO_SEC(TIMEDIFF(repair_end_date, repair_start_date)) / 60 / 60;
  END IF;

  RETURN 0;
END
$$

--
-- Создать функцию `repair_time`
--
CREATE FUNCTION repair_time (start_repair_datetime datetime, end_repair_datetime datetime, start_wait_datetime datetime, end_wait_datetime datetime)
RETURNS double
BEGIN
  DECLARE part1_start_datetime datetime;
  DECLARE part1_end_datetime datetime;
  DECLARE part2_start_datetime datetime;
  DECLARE part2_end_datetime datetime;
  DECLARE part1_start_middle_datetime datetime;
  DECLARE part1_end_middle_datetime datetime;
  DECLARE part2_start_middle_datetime datetime;
  DECLARE part2_end_middle_datetime datetime;
  DECLARE part1_start_dinner datetime DEFAULT CURRENT_TIME();
  DECLARE part1_end_dinner datetime DEFAULT part1_start_dinner;
  DECLARE part2_start_dinner datetime DEFAULT part1_start_dinner;
  DECLARE part2_end_dinner datetime DEFAULT part1_start_dinner;

  DECLARE hour_count double DEFAULT 0;

  IF ((DAYOFWEEK(start_repair_datetime) MOD 7) <= 1) THEN
    SET start_repair_datetime = DATE_ADD(DATE_ADD(date (start_repair_datetime), INTERVAL 9 HOUR), INTERVAL (2 - (DAYOFWEEK(start_repair_datetime) MOD 7)) DAY);
  END IF;
  IF ((DAYOFWEEK(start_wait_datetime) MOD 7) <= 1) THEN
    SET start_repair_datetime = DATE_ADD(DATE_ADD(date (start_repair_datetime), INTERVAL 9 HOUR), INTERVAL (2 - (DAYOFWEEK(start_repair_datetime) MOD 7)) DAY);
  END IF;
  IF ((DAYOFWEEK(end_repair_datetime) MOD 7) <= 1) THEN
    SET end_repair_datetime = DATE_SUB(DATE_ADD(date (end_repair_datetime), INTERVAL 18 HOUR), INTERVAL ((DAYOFWEEK(end_repair_datetime) MOD 7) + 1) DAY);
  END IF;
  IF ((DAYOFWEEK(end_wait_datetime) MOD 7) <= 1) THEN
    SET end_wait_datetime = DATE_SUB(DATE_ADD(date (end_wait_datetime), INTERVAL 18 HOUR), INTERVAL ((DAYOFWEEK(end_wait_datetime) MOD 7) + 1) DAY);
  END IF;

  IF (start_repair_datetime < DATE_ADD(date (start_repair_datetime), INTERVAL 9 HOUR)) THEN
    SET start_repair_datetime = DATE_ADD(date (start_repair_datetime), INTERVAL 9 HOUR);
  END IF;
  IF (start_wait_datetime < DATE_ADD(date (start_wait_datetime), INTERVAL 9 HOUR)) THEN
    SET start_wait_datetime = DATE_ADD(date (start_wait_datetime), INTERVAL 9 HOUR);
  END IF;
  IF (end_repair_datetime > DATE_ADD(date (end_repair_datetime), INTERVAL 18 HOUR)) THEN
    SET end_repair_datetime = DATE_ADD(date (end_repair_datetime), INTERVAL 18 HOUR);
  END IF;
  IF (end_wait_datetime > DATE_ADD(date (end_wait_datetime), INTERVAL 18 HOUR)) THEN
    SET end_wait_datetime = DATE_ADD(date (end_wait_datetime), INTERVAL 18 HOUR);
  END IF;

  IF (start_repair_datetime < start_wait_datetime) THEN
    SET part1_start_datetime = start_repair_datetime;
    IF (end_repair_datetime < start_wait_datetime) THEN
      SET part1_end_datetime = end_repair_datetime;
    ELSE
      SET part1_end_datetime = start_wait_datetime;
    END IF;
  ELSE
    SET part1_start_datetime = start_wait_datetime;
    SET part1_end_datetime = start_wait_datetime;
  END IF;

  IF (end_repair_datetime < end_wait_datetime) THEN
    SET part2_start_datetime = end_wait_datetime;
    SET part2_end_datetime = end_wait_datetime;
  ELSE
    SET part2_end_datetime = end_repair_datetime;
    IF (start_repair_datetime < end_wait_datetime) THEN
      SET part2_start_datetime = end_wait_datetime;
    ELSE
      SET part2_start_datetime = start_repair_datetime;

    END IF;
  END IF;

  SET part1_start_middle_datetime = DATE_ADD(date (part1_start_datetime), INTERVAL 1 DAY);
  SET part1_end_middle_datetime = date (part1_end_datetime);
  SET part2_start_middle_datetime = DATE_ADD(date (part2_start_datetime), INTERVAL 1 DAY);
  SET part2_end_middle_datetime = date (part2_end_datetime);

  IF (TIMESTAMPDIFF(DAY, part1_start_middle_datetime, part1_end_middle_datetime) < 0) THEN
    SET hour_count = hour_count + TIMESTAMPDIFF(MINUTE, part1_start_datetime, part1_end_datetime) / 60;

    IF ((part1_start_datetime <= DATE_ADD(date (part1_start_datetime), INTERVAL 13 HOUR))
      AND (part1_end_datetime >= DATE_ADD(date (part1_end_datetime), INTERVAL 13 HOUR))) THEN
      SET part1_start_dinner = DATE_ADD(date (part1_start_datetime), INTERVAL 13 HOUR);
    ELSEIF ((part1_start_datetime >= DATE_ADD(date (part1_start_datetime), INTERVAL 13 HOUR))
      AND (part1_start_datetime <= DATE_ADD(date (part1_start_datetime), INTERVAL 14 HOUR))) THEN
      SET part1_start_dinner = part1_start_datetime;
    END IF;
    IF ((part1_end_datetime >= DATE_ADD(date (part1_end_datetime), INTERVAL 14 HOUR))
      AND (part1_start_datetime <= DATE_ADD(date (part1_start_datetime), INTERVAL 14 HOUR))) THEN
      SET part1_end_dinner = DATE_ADD(date (part1_end_datetime), INTERVAL 14 HOUR);
    ELSEIF ((part1_end_datetime >= DATE_ADD(date (part1_end_datetime), INTERVAL 13 HOUR))
      AND (part1_end_datetime <= DATE_ADD(date (part1_end_datetime), INTERVAL 14 HOUR))) THEN
      SET part1_end_dinner = part1_end_datetime;
    END IF;
    SET hour_count = hour_count - TIMESTAMPDIFF(MINUTE, part1_start_dinner, part1_end_dinner) / 60;
  ELSE
    IF ((part1_start_datetime >= DATE_ADD(date (part1_start_datetime), INTERVAL 13 HOUR))
      AND (part1_start_datetime <= DATE_ADD(date (part1_start_datetime), INTERVAL 14 HOUR))) THEN
      SET part1_start_datetime = DATE_ADD(date (part1_start_datetime), INTERVAL 14 HOUR);
    END IF;
    IF (18 * 60 * 60 - (HOUR(part1_start_datetime) * 60 * 60 + MINUTE(part1_start_datetime) * 60 + SECOND(part1_start_datetime)) > 0) THEN
      SET hour_count = hour_count + 18 - (HOUR(part1_start_datetime) * 60 * 60 + MINUTE(part1_start_datetime) * 60 + SECOND(part1_start_datetime)) / 3600;
    END IF;
    IF (HOUR(part1_start_datetime) <= 13) THEN
      SET hour_count = hour_count - 1;
    END IF;
    IF ((part1_end_datetime >= DATE_ADD(date (part1_end_datetime), INTERVAL 13 HOUR))
      AND (part1_end_datetime <= DATE_ADD(date (part1_end_datetime), INTERVAL 14 HOUR))) THEN
      SET part1_end_datetime = DATE_ADD(date (part1_end_datetime), INTERVAL 13 HOUR);
    END IF;
    IF ((HOUR(part1_end_datetime) * 60 * 60 + MINUTE(part1_end_datetime) * 60 + SECOND(part1_end_datetime)) - 9 * 60 * 60 > 0) THEN
      SET hour_count = hour_count + (HOUR(part1_end_datetime) * 60 * 60 + MINUTE(part1_end_datetime) * 60 + SECOND(part1_end_datetime)) / 3600 - 9;
    END IF;
    IF (HOUR(part1_end_datetime) >= 14) THEN
      SET hour_count = hour_count - 1;
    END IF;
    SET hour_count = hour_count + (TIMESTAMPDIFF(DAY, part1_start_middle_datetime, part1_end_middle_datetime)) * 8;
  END IF;

  IF (TIMESTAMPDIFF(DAY, part2_start_middle_datetime, part2_end_middle_datetime) < 0) THEN
    SET hour_count = hour_count + TIMESTAMPDIFF(MINUTE, part2_start_datetime, part2_end_datetime) / 60;

    IF ((part2_start_datetime <= DATE_ADD(date (part2_start_datetime), INTERVAL 13 HOUR))
      AND (part2_end_datetime >= DATE_ADD(date (part2_end_datetime), INTERVAL 13 HOUR))) THEN
      SET part2_start_dinner = DATE_ADD(date (part2_start_datetime), INTERVAL 13 HOUR);
    ELSEIF ((part2_start_datetime >= DATE_ADD(date (part2_start_datetime), INTERVAL 13 HOUR))
      AND (part2_start_datetime <= DATE_ADD(date (part2_start_datetime), INTERVAL 14 HOUR))) THEN
      SET part2_start_dinner = part2_start_datetime;
    END IF;
    IF ((part2_end_datetime >= DATE_ADD(date (part2_end_datetime), INTERVAL 14 HOUR))
      AND (part2_start_datetime <= DATE_ADD(date (part2_start_datetime), INTERVAL 14 HOUR))) THEN
      SET part2_end_dinner = DATE_ADD(date (part2_end_datetime), INTERVAL 14 HOUR);
    ELSEIF ((part2_end_datetime >= DATE_ADD(date (part2_end_datetime), INTERVAL 13 HOUR))
      AND (part2_end_datetime <= DATE_ADD(date (part2_end_datetime), INTERVAL 14 HOUR))) THEN
      SET part2_end_dinner = part2_end_datetime;
    END IF;
    SET hour_count = hour_count - TIMESTAMPDIFF(MINUTE, part2_start_dinner, part2_end_dinner) / 60;
  ELSE
    IF ((part2_start_datetime >= DATE_ADD(date (part2_start_datetime), INTERVAL 13 HOUR))
      AND (part2_start_datetime <= DATE_ADD(date (part2_start_datetime), INTERVAL 14 HOUR))) THEN
      SET part2_start_datetime = DATE_ADD(date (part2_start_datetime), INTERVAL 14 HOUR);
    END IF;
    IF (18 * 60 * 60 - (HOUR(part2_start_datetime) * 60 * 60 + MINUTE(part2_start_datetime) * 60 + SECOND(part2_start_datetime)) > 0) THEN
      SET hour_count = hour_count + 18 - (HOUR(part2_start_datetime) * 60 * 60 + MINUTE(part2_start_datetime) * 60 + SECOND(part2_start_datetime)) / 3600;
    END IF;
    IF (HOUR(part2_start_datetime) <= 13) THEN
      SET hour_count = hour_count - 1;
    END IF;
    IF ((part2_end_datetime >= DATE_ADD(date (part2_end_datetime), INTERVAL 13 HOUR))
      AND (part2_end_datetime <= DATE_ADD(date (part2_end_datetime), INTERVAL 14 HOUR))) THEN
      SET part2_end_datetime = DATE_ADD(date (part2_end_datetime), INTERVAL 13 HOUR);
    END IF;
    IF ((HOUR(part2_end_datetime) * 60 * 60 + MINUTE(part2_end_datetime) * 60 + SECOND(part2_end_datetime)) - 9 * 60 * 60 > 0) THEN
      SET hour_count = hour_count + (HOUR(part2_end_datetime) * 60 * 60 + MINUTE(part2_end_datetime) * 60 + SECOND(part2_end_datetime)) / 3600 - 9;
    END IF;
    IF (HOUR(part2_end_datetime) >= 14) THEN
      SET hour_count = hour_count - 1;
    END IF;
    SET hour_count = hour_count + (TIMESTAMPDIFF(DAY, part2_start_middle_datetime, part2_end_middle_datetime)) * 8;
  END IF;

  IF (TIMESTAMPDIFF(DAY, part1_start_middle_datetime, part1_end_middle_datetime) > 0) THEN
    IF (TIMESTAMPDIFF(DAY, DATE_ADD(part1_start_middle_datetime, INTERVAL (7 - DAYOFWEEK(part1_start_middle_datetime)) DAY), part1_end_middle_datetime) >= 0) THEN
      SET hour_count = hour_count -
      (TIMESTAMPDIFF(DAY, DATE_ADD(part1_start_middle_datetime, INTERVAL (7 - DAYOFWEEK(part1_start_middle_datetime)) DAY), part1_end_middle_datetime) DIV 7) * 8;
    END IF;
    IF (TIMESTAMPDIFF(DAY, DATE_ADD(part1_start_middle_datetime, INTERVAL (8 - DAYOFWEEK(part1_start_middle_datetime)) DAY), part1_end_middle_datetime) >= 0) THEN
      SET hour_count = hour_count -
      (TIMESTAMPDIFF(DAY, DATE_ADD(part1_start_middle_datetime, INTERVAL ((8 - DAYOFWEEK(part1_start_middle_datetime)) MOD 7) DAY), part1_end_middle_datetime) DIV 7) * 8;
    END IF;
  END IF;

  IF (TIMESTAMPDIFF(DAY, part2_start_middle_datetime, part2_end_middle_datetime) > 0) THEN
    IF (TIMESTAMPDIFF(DAY, DATE_ADD(part2_start_middle_datetime, INTERVAL (7 - DAYOFWEEK(part2_start_middle_datetime)) DAY), part2_end_middle_datetime) >= 0) THEN
      SET hour_count = hour_count -
      ((TIMESTAMPDIFF(DAY, DATE_ADD(part2_start_middle_datetime, INTERVAL (7 - DAYOFWEEK(part2_start_middle_datetime)) DAY), part2_end_middle_datetime) DIV 7) + 1) * 8;
    END IF;
    IF (TIMESTAMPDIFF(DAY, DATE_ADD(part2_start_middle_datetime, INTERVAL (8 - DAYOFWEEK(part2_start_middle_datetime)) DAY), part2_end_middle_datetime) >= 0) THEN
      SET hour_count = hour_count -
      ((TIMESTAMPDIFF(DAY, DATE_ADD(part2_start_middle_datetime, INTERVAL ((8 - DAYOFWEEK(part2_start_middle_datetime)) MOD 7) DAY), part2_end_middle_datetime) DIV 7) + 1) * 8;
    END IF;
  END IF;
  RETURN hour_count;
END
$$

DELIMITER ;

-- 
-- Восстановить предыдущий режим SQL (SQL mode)
-- 
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;

-- 
-- Включение внешних ключей
-- 
/*!40014 SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS */;