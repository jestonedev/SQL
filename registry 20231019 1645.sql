--
-- Скрипт сгенерирован Devart dbForge Studio for MySQL, Версия 7.4.201.0
-- Домашняя страница продукта: http://www.devart.com/ru/dbforge/mysql/studio
-- Дата скрипта: 19.10.2023 16:45:07
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

DROP DATABASE IF EXISTS registry;

CREATE DATABASE IF NOT EXISTS registry
CHARACTER SET utf8
COLLATE utf8_general_ci;

--
-- Установка базы данных по умолчанию
--
USE registry;

--
-- Создать таблицу `log`
--
CREATE TABLE IF NOT EXISTS log (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  `table` varchar(255) NOT NULL,
  id_key int(11) NOT NULL COMMENT 'Первичный ключ изменяемой записи в таблице',
  field_name varchar(255) NOT NULL,
  field_old_value text DEFAULT NULL,
  field_new_value text DEFAULT NULL,
  operation_type varchar(255) NOT NULL,
  operation_time datetime NOT NULL,
  user_name varchar(255) NOT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 74359020,
AVG_ROW_LENGTH = 104,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `date_index` для объекта типа таблица `log`
--
ALTER TABLE log
ADD INDEX date_index (operation_time);

--
-- Создать таблицу `tenancy_reasons`
--
CREATE TABLE IF NOT EXISTS tenancy_reasons (
  id_reason int(11) NOT NULL AUTO_INCREMENT,
  id_process int(11) NOT NULL,
  id_reason_type int(11) NOT NULL,
  reason_number varchar(50) DEFAULT NULL,
  reason_date date DEFAULT NULL,
  reason_prepared text NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_reason)
)
ENGINE = INNODB,
AUTO_INCREMENT = 20239,
AVG_ROW_LENGTH = 157,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `tenancy_reasons_after_insert`
--
CREATE TRIGGER tenancy_reasons_after_insert
AFTER INSERT
ON tenancy_reasons
FOR EACH ROW
BEGIN
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_reasons', NEW.id_reason, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_reason_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_reasons', NEW.id_reason, 'id_reason_type', NULL, NEW.id_reason_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.reason_number IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_reasons', NEW.id_reason, 'reason_number', NULL, NEW.reason_number, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.reason_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_reasons', NEW.id_reason, 'reason_date', NULL, NEW.reason_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.reason_prepared IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_reasons', NEW.id_reason, 'reason_prepared', NULL, NEW.reason_prepared, 'INSERT', NOW(), USER());
  END IF;
  UPDATE tenancy_processes tp
  INNER JOIN (SELECT
      *
    FROM (SELECT
        tr.id_process,
        tr.reason_date,
        tr.reason_number
      FROM tenancy_reasons tr
        INNER JOIN (SELECT
            tr.id_process,
            MAX(tr.reason_date) AS reason_date
          FROM tenancy_reasons tr
          WHERE tr.deleted <> 1
          GROUP BY tr.id_process) v
          ON tr.id_process = v.id_process
          AND tr.reason_date = v.reason_date
      WHERE tr.deleted <> 1
      ORDER BY tr.id_reason DESC) tr
    GROUP BY tr.id_process,
             tr.reason_date) tr
    ON tp.id_process = tr.id_process
  SET tp.residence_warrant_num = tr.reason_number,
      tp.residence_warrant_date = tr.reason_date
  WHERE tp.id_process = NEW.id_process;
END
$$

--
-- Создать триггер `tenancy_reasons_after_update`
--
CREATE TRIGGER tenancy_reasons_after_update
AFTER UPDATE
ON tenancy_reasons
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_reasons', NEW.id_reason, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
    IF (@deleting_tenancy_process IS NULL) THEN
      UPDATE tenancy_processes tp
      LEFT JOIN (SELECT
          *
        FROM (SELECT
            tr.id_process,
            tr.reason_date,
            tr.reason_number
          FROM tenancy_reasons tr
            INNER JOIN (SELECT
                tr.id_process,
                MAX(tr.reason_date) AS reason_date
              FROM tenancy_reasons tr
              WHERE tr.deleted <> 1
              GROUP BY tr.id_process) v
              ON tr.id_process = v.id_process
              AND tr.reason_date = v.reason_date
          WHERE tr.deleted <> 1
          ORDER BY tr.id_reason DESC) tr
        GROUP BY tr.id_process,
                 tr.reason_date) tr
        ON tp.id_process = tr.id_process
      SET tp.residence_warrant_num = tr.reason_number,
          tp.residence_warrant_date = tr.reason_date
      WHERE tp.deleted <> 1
      AND tp.id_process = NEW.id_process;
    END IF;
  ELSEIF (OLD.deleted <> 1) THEN
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_reasons', NEW.id_reason, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_reason_type <> OLD.id_reason_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_reasons', NEW.id_reason, 'id_reason_type', OLD.id_reason_type, NEW.id_reason_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.reason_number IS NULL
      AND OLD.reason_number IS NULL)
      AND ((NEW.reason_number IS NULL
      AND OLD.reason_number IS NOT NULL)
      OR (NEW.reason_number IS NOT NULL
      AND OLD.reason_number IS NULL)
      OR (NEW.reason_number <> OLD.reason_number))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_reasons', NEW.id_reason, 'reason_number', OLD.reason_number, NEW.reason_number, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.reason_date IS NULL
      AND OLD.reason_date IS NULL)
      AND ((NEW.reason_date IS NULL
      AND OLD.reason_date IS NOT NULL)
      OR (NEW.reason_date IS NOT NULL
      AND OLD.reason_date IS NULL)
      OR (NEW.reason_date <> OLD.reason_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_reasons', NEW.id_reason, 'reason_date', OLD.reason_date, NEW.reason_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.reason_prepared <> OLD.reason_prepared) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_reasons', NEW.id_reason, 'reason_prepared', OLD.reason_prepared, NEW.reason_prepared, 'UPDATE', NOW(), USER());
    END IF;

    UPDATE tenancy_processes tp
    INNER JOIN (SELECT
        *
      FROM (SELECT
          tr.id_process,
          tr.reason_date,
          tr.reason_number
        FROM tenancy_reasons tr
          INNER JOIN (SELECT
              tr.id_process,
              MAX(tr.reason_date) AS reason_date
            FROM tenancy_reasons tr
            WHERE tr.deleted <> 1
            GROUP BY tr.id_process) v
            ON tr.id_process = v.id_process
            AND tr.reason_date = v.reason_date
        WHERE tr.deleted <> 1
        ORDER BY tr.id_reason DESC) tr
      GROUP BY tr.id_process,
               tr.reason_date) tr
      ON tp.id_process = tr.id_process
    SET tp.residence_warrant_num = tr.reason_number,
        tp.residence_warrant_date = tr.reason_date
    WHERE tp.id_process = NEW.id_process;

  END IF;
END
$$

--
-- Создать триггер `tenancy_reasons_before_insert`
--
CREATE TRIGGER tenancy_reasons_before_insert
BEFORE INSERT
ON tenancy_reasons
FOR EACH ROW
BEGIN
  IF (NOT EXISTS (SELECT
        *
      FROM tenancy_processes tp
      WHERE tp.deleted = 0
      AND tp.id_process = NEW.id_process)) THEN
    SIGNAL SQLSTATE '45000' SET
    MESSAGE_TEXT = 'Невозможно добавить запись из-за нарушения ссылочной целостности';
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `tenancy_reason_types`
--
CREATE TABLE IF NOT EXISTS tenancy_reason_types (
  id_reason_type int(11) NOT NULL AUTO_INCREMENT,
  reason_name varchar(150) NOT NULL,
  reason_template text NOT NULL,
  `order` int(11) NOT NULL DEFAULT 100,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_reason_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 36,
AVG_ROW_LENGTH = 606,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `tenancy_reason_types_after_insert`
--
CREATE TRIGGER tenancy_reason_types_after_insert
AFTER INSERT
ON tenancy_reason_types
FOR EACH ROW
BEGIN
  IF (NEW.reason_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_reason_types', NEW.id_reason_type, 'reason_name', NULL, NEW.reason_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.reason_template IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_reason_types', NEW.id_reason_type, 'reason_template', NULL, NEW.reason_template, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.order IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_reason_types', NEW.id_reason_type, 'order', NULL, NEW.order, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `tenancy_reason_types_after_update`
--
CREATE TRIGGER tenancy_reason_types_after_update
AFTER UPDATE
ON tenancy_reason_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_reason_types', NEW.id_reason_type, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.reason_name <> OLD.reason_name) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_reason_types', NEW.id_reason_type, 'reason_name', OLD.reason_name, NEW.reason_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.reason_template <> OLD.reason_template) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_reason_types', NEW.id_reason_type, 'reason_template', OLD.reason_template, NEW.reason_template, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.order <> OLD.order) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_reason_types', NEW.id_reason_type, 'order', OLD.order, NEW.order, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `tenancy_reason_types_before_update`
--
CREATE TRIGGER tenancy_reason_types_before_update
BEFORE UPDATE
ON tenancy_reason_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM tenancy_reasons
        WHERE deleted <> 1
        AND id_reason_type = NEW.id_reason_type) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить тип основания найма, т.к. существуют основания найма данного типа';
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_reasons
ADD CONSTRAINT FK_contract_reasons_premises_types_id_premises_type FOREIGN KEY (id_reason_type)
REFERENCES tenancy_reason_types (id_reason_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `tenancy_prolong_reason_types`
--
CREATE TABLE IF NOT EXISTS tenancy_prolong_reason_types (
  id_reason_type int(11) NOT NULL AUTO_INCREMENT,
  reason_name varchar(255) NOT NULL,
  reason_template_genetive text NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_reason_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 10,
AVG_ROW_LENGTH = 1820,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `tenancy_prolong_reason_types_after_insert`
--
CREATE TRIGGER tenancy_prolong_reason_types_after_insert
AFTER INSERT
ON tenancy_prolong_reason_types
FOR EACH ROW
BEGIN
  IF (NEW.reason_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_prolong_reason_types', NEW.id_reason_type, 'reason_name', NULL, NEW.reason_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.reason_template_genetive IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_prolong_reason_types', NEW.id_reason_type, 'reason_template_genetive', NULL, NEW.reason_template_genetive, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `tenancy_prolong_reason_types_after_update`
--
CREATE TRIGGER tenancy_prolong_reason_types_after_update
AFTER UPDATE
ON tenancy_prolong_reason_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_prolong_reason_types', NEW.id_reason_type, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.reason_name <> OLD.reason_name) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_prolong_reason_types', NEW.id_reason_type, 'reason_name', OLD.reason_name, NEW.reason_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.reason_template_genetive <> OLD.reason_template_genetive) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_prolong_reason_types', NEW.id_reason_type, 'reason_template_genetive', OLD.reason_template_genetive, NEW.reason_template_genetive, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `tenancy_notifies`
--
CREATE TABLE IF NOT EXISTS tenancy_notifies (
  id_notify int(11) NOT NULL AUTO_INCREMENT,
  id_process int(11) NOT NULL,
  notify_date datetime NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_notify)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4592,
AVG_ROW_LENGTH = 47,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `tenancy_notifies_after_insert`
--
CREATE TRIGGER tenancy_notifies_after_insert
AFTER INSERT
ON tenancy_notifies
FOR EACH ROW
BEGIN
  INSERT INTO `log`
    VALUES (NULL, 'tenancy_notifies', NEW.id_notify, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'tenancy_notifies', NEW.id_notify, 'notify_date', NULL, NEW.notify_date, 'INSERT', NOW(), USER());
END
$$

--
-- Создать триггер `tenancy_notifies_after_update`
--
CREATE TRIGGER tenancy_notifies_after_update
AFTER UPDATE
ON tenancy_notifies
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_notifies', NEW.id_notify, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `tenancy_notifies_before_insert`
--
CREATE TRIGGER tenancy_notifies_before_insert
BEFORE INSERT
ON tenancy_notifies
FOR EACH ROW
BEGIN
  IF (NOT EXISTS (SELECT
        *
      FROM tenancy_processes tp
      WHERE tp.deleted = 0
      AND tp.id_process = NEW.id_process)) THEN
    SIGNAL SQLSTATE '45000' SET
    MESSAGE_TEXT = 'Невозможно добавить запись из-за нарушения ссылочной целостности';
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `tenancy_agreements`
--
CREATE TABLE IF NOT EXISTS tenancy_agreements (
  id_agreement int(11) NOT NULL AUTO_INCREMENT,
  id_process int(11) NOT NULL,
  agreement_date date DEFAULT NULL,
  agreement_content text DEFAULT NULL,
  issued_date date DEFAULT NULL,
  id_executor int(11) DEFAULT NULL,
  id_warrant int(11) DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_agreement)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4811,
AVG_ROW_LENGTH = 485,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `tenancy_agreements_after_insert`
--
CREATE TRIGGER tenancy_agreements_after_insert
AFTER INSERT
ON tenancy_agreements
FOR EACH ROW
BEGIN
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.agreement_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'agreement_date', NULL, NEW.agreement_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.agreement_content IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'agreement_content', NULL, NEW.agreement_content, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.issued_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'issued_date', NULL, NEW.issued_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_executor IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'id_executor', NULL, NEW.id_executor, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_warrant IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'id_warrant', NULL, NEW.id_warrant, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `tenancy_agreements_after_update`
--
CREATE TRIGGER tenancy_agreements_after_update
AFTER UPDATE
ON tenancy_agreements
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.agreement_date IS NULL
      AND OLD.agreement_date IS NULL)
      AND ((NEW.agreement_date IS NULL
      AND OLD.agreement_date IS NOT NULL)
      OR (NEW.agreement_date IS NOT NULL
      AND OLD.agreement_date IS NULL)
      OR (NEW.agreement_date <> OLD.agreement_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'agreement_date', OLD.agreement_date, NEW.agreement_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.agreement_content IS NULL
      AND OLD.agreement_content IS NULL)
      AND ((NEW.agreement_content IS NULL
      AND OLD.agreement_content IS NOT NULL)
      OR (NEW.agreement_content IS NOT NULL
      AND OLD.agreement_content IS NULL)
      OR (NEW.agreement_content <> OLD.agreement_content))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'agreement_content', OLD.agreement_content, NEW.agreement_content, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.issued_date IS NULL
      AND OLD.issued_date IS NULL)
      AND ((NEW.issued_date IS NULL
      AND OLD.issued_date IS NOT NULL)
      OR (NEW.issued_date IS NOT NULL
      AND OLD.issued_date IS NULL)
      OR (NEW.issued_date <> OLD.issued_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'issued_date', OLD.issued_date, NEW.issued_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_executor <> OLD.id_executor) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'id_executor', OLD.id_executor, NEW.id_executor, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_warrant IS NULL
      AND OLD.id_warrant IS NULL)
      AND ((NEW.id_warrant IS NULL
      AND OLD.id_warrant IS NOT NULL)
      OR (NEW.id_warrant IS NOT NULL
      AND OLD.id_warrant IS NULL)
      OR (NEW.id_warrant <> OLD.id_warrant))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_agreements', NEW.id_agreement, 'id_warrant', OLD.id_warrant, NEW.id_warrant, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `tenancy_agreements_before_insert`
--
CREATE TRIGGER tenancy_agreements_before_insert
BEFORE INSERT
ON tenancy_agreements
FOR EACH ROW
BEGIN
  IF (NOT EXISTS (SELECT
        *
      FROM tenancy_processes tp
      WHERE tp.deleted = 0
      AND tp.id_process = NEW.id_process)) THEN
    SIGNAL SQLSTATE '45000' SET
    MESSAGE_TEXT = 'Невозможно добавить запись из-за нарушения ссылочной целостности';
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `restrictions_premises_assoc`
--
CREATE TABLE IF NOT EXISTS restrictions_premises_assoc (
  id_premises int(11) NOT NULL,
  id_restriction int(11) NOT NULL,
  deleted tinyint(1) DEFAULT 0,
  PRIMARY KEY (id_premises, id_restriction)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 16384,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `restrictions_premises_assoc_after_insert`
--
CREATE TRIGGER restrictions_premises_assoc_after_insert
AFTER INSERT
ON restrictions_premises_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_premises IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions_premises_assoc', NEW.id_restriction, 'id_premises', NULL, NEW.id_premises, 'INSERT', NOW(), USER());
  END IF;

/*
IF(EXISTS(SELECT * 
  FROM restrictions_premises_assoc rpa
    INNER JOIN restrictions r ON rpa.id_restriction = r.id_restriction
  WHERE rpa.deleted <> 1 AND rpa.id_premises = NEW.id_premises
    AND r.date_state_reg IS NOT NULL AND r.deleted <> 1)) THEN

  SET @date_state_reg_prop = (SELECT MIN(date_state_reg)
            FROM restrictions_premises_assoc rpa
              INNER JOIN restrictions r ON rpa.id_restriction = r.id_restriction
            WHERE rpa.deleted <> 1 AND rpa.id_premises = NEW.id_premises
              AND r.date_state_reg IS NOT NULL AND r.deleted <> 1);

  UPDATE tenancy_processes tp
  SET tp.annual_date = DATE_ADD(@date_state_reg_prop, INTERVAL -1 DAY),
    tp.registration_num = CONCAT(registration_num, 'н')
  WHERE tp.id_process IN (
  SELECT tpa.id_process 
  FROM tenancy_premises_assoc tpa 
  WHERE tpa.id_premises = NEW.id_premises AND tpa.deleted <> 1
  UNION ALL
  SELECT tspa.id_process 
  FROM tenancy_sub_premises_assoc tspa 
  JOIN sub_premises sp ON tspa.id_sub_premises = sp.id_sub_premises 
  WHERE sp.id_premises = NEW.id_premises AND tspa.deleted <> 1 AND sp.deleted <> 1)
  AND tp.annual_date IS NULL;

END IF;*/
END
$$

--
-- Создать триггер `restrictions_premises_assoc_after_update`
--
CREATE TRIGGER restrictions_premises_assoc_after_update
AFTER UPDATE
ON restrictions_premises_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions_premises_assoc', NEW.id_restriction, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `restrictions_buildings_assoc`
--
CREATE TABLE IF NOT EXISTS restrictions_buildings_assoc (
  id_building int(11) NOT NULL,
  id_restriction int(11) NOT NULL,
  deleted tinyint(1) DEFAULT 0,
  PRIMARY KEY (id_building, id_restriction)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 44,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `restrictions_buildings_assoc_after_insert`
--
CREATE TRIGGER restrictions_buildings_assoc_after_insert
AFTER INSERT
ON restrictions_buildings_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_building IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions_buildings_assoc', NEW.id_restriction, 'id_building', NULL, NEW.id_building, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `restrictions_buildings_assoc_after_update`
--
CREATE TRIGGER restrictions_buildings_assoc_after_update
AFTER UPDATE
ON restrictions_buildings_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions_buildings_assoc', NEW.id_restriction, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `restrictions`
--
CREATE TABLE IF NOT EXISTS restrictions (
  id_restriction int(11) NOT NULL AUTO_INCREMENT,
  id_restriction_type int(11) NOT NULL COMMENT 'Тип реквизита НПА: возникновение права собственности, прекращение права собственности',
  number varchar(10) DEFAULT NULL COMMENT 'Номер',
  date date NOT NULL COMMENT 'Дата документа',
  description varchar(255) DEFAULT NULL COMMENT 'Наименование',
  date_state_reg date DEFAULT NULL COMMENT 'Дата государственной регистрации в УЮ',
  file_origin_name varchar(255) DEFAULT NULL,
  file_display_name varchar(255) DEFAULT NULL,
  file_mime_type varchar(255) DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_restriction)
)
ENGINE = INNODB,
AUTO_INCREMENT = 24362,
AVG_ROW_LENGTH = 69,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Реквизиты НПА – оснований возникновения (прекращения) права муниципальной собственности';

DELIMITER $$

--
-- Создать триггер `restrictions_after_insert`
--
CREATE TRIGGER restrictions_after_insert
AFTER INSERT
ON restrictions
FOR EACH ROW
BEGIN
  IF (NEW.id_restriction_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions', NEW.id_restriction, 'id_restriction_type', NULL, NEW.id_restriction_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.number IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions', NEW.id_restriction, 'number', NULL, NEW.number, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions', NEW.id_restriction, 'date', NULL, NEW.date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions', NEW.id_restriction, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_state_reg IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions', NEW.id_restriction, 'date_state_reg', NULL, NEW.date_state_reg, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.file_origin_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions', NEW.id_restriction, 'file_origin_name', NULL, NEW.file_origin_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.file_display_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions', NEW.id_restriction, 'file_display_name', NULL, NEW.file_display_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.file_mime_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions', NEW.id_restriction, 'file_mime_type', NULL, NEW.file_mime_type, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `restrictions_after_update`
--
CREATE TRIGGER restrictions_after_update
AFTER UPDATE
ON restrictions
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restrictions', NEW.id_restriction, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_restriction_type <> OLD.id_restriction_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'restrictions', NEW.id_restriction, 'id_restriction_type', OLD.id_restriction_type, NEW.id_restriction_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.number IS NULL
      AND OLD.number IS NULL)
      AND ((NEW.number IS NULL
      AND OLD.number IS NOT NULL)
      OR (NEW.number IS NOT NULL
      AND OLD.number IS NULL)
      OR (NEW.number <> OLD.number))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'restrictions', NEW.id_restriction, 'number', OLD.number, NEW.number, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.date <> OLD.date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'restrictions', NEW.id_restriction, 'date', OLD.date, NEW.date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'restrictions', NEW.id_restriction, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_state_reg IS NULL
      AND OLD.date_state_reg IS NULL)
      AND ((NEW.date_state_reg IS NULL
      AND OLD.date_state_reg IS NOT NULL)
      OR (NEW.date_state_reg IS NOT NULL
      AND OLD.date_state_reg IS NULL)
      OR (NEW.date_state_reg <> OLD.date_state_reg))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'restrictions', NEW.id_restriction, 'date_state_reg', OLD.date_state_reg, NEW.date_state_reg, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.file_origin_name IS NULL
      AND OLD.file_origin_name IS NULL)
      AND ((NEW.file_origin_name IS NULL
      AND OLD.file_origin_name IS NOT NULL)
      OR (NEW.file_origin_name IS NOT NULL
      AND OLD.file_origin_name IS NULL)
      OR (NEW.file_origin_name <> OLD.file_origin_name))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'restrictions', NEW.id_restriction, 'file_origin_name', OLD.file_origin_name, NEW.file_origin_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.file_display_name IS NULL
      AND OLD.file_display_name IS NULL)
      AND ((NEW.file_display_name IS NULL
      AND OLD.file_display_name IS NOT NULL)
      OR (NEW.file_display_name IS NOT NULL
      AND OLD.file_display_name IS NULL)
      OR (NEW.file_display_name <> OLD.file_display_name))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'restrictions', NEW.id_restriction, 'file_display_name', OLD.file_display_name, NEW.file_display_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.file_mime_type IS NULL
      AND OLD.file_mime_type IS NULL)
      AND ((NEW.file_mime_type IS NULL
      AND OLD.file_mime_type IS NOT NULL)
      OR (NEW.file_mime_type IS NOT NULL
      AND OLD.file_mime_type IS NULL)
      OR (NEW.file_mime_type <> OLD.file_mime_type))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'restrictions', NEW.id_restriction, 'file_mime_type', OLD.file_mime_type, NEW.file_mime_type, 'UPDATE', NOW(), USER());
    END IF;
  /*
  IF(NEW.date_state_reg IS NOT NULL) THEN
      UPDATE tenancy_processes tp
      SET tp.annual_date = DATE_ADD(NEW.date_state_reg, INTERVAL -1 DAY),
        tp.registration_num = CONCAT(registration_num, 'н')
      WHERE tp.id_process IN (
      SELECT tpa.id_process 
      FROM tenancy_premises_assoc tpa 
      WHERE tpa.id_premises IN (SELECT rpa.id_premises FROM restrictions_premises_assoc rpa WHERE rpa.id_restriction = NEW.id_restriction)
        AND tpa.deleted <> 1
      UNION ALL
      SELECT tspa.id_process 
      FROM tenancy_sub_premises_assoc tspa 
      JOIN sub_premises sp ON tspa.id_sub_premises = sp.id_sub_premises 
      WHERE sp.id_premises IN (SELECT rpa.id_premises FROM restrictions_premises_assoc rpa WHERE rpa.id_restriction = NEW.id_restriction) 
        AND tspa.deleted <> 1 AND sp.deleted <> 1)
      AND tp.annual_date IS NULL;
  END IF;*/
  END IF;
END
$$

--
-- Создать триггер `restrictions_before_update`
--
CREATE TRIGGER restrictions_before_update
BEFORE UPDATE
ON restrictions
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    UPDATE restrictions_buildings_assoc
    SET deleted = 1
    WHERE id_restriction = NEW.id_restriction;
    UPDATE restrictions_premises_assoc
    SET deleted = 1
    WHERE id_restriction = NEW.id_restriction;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE restrictions_buildings_assoc
ADD CONSTRAINT FK_restrictions_buildings_assoc_restrictions_id_restriction FOREIGN KEY (id_restriction)
REFERENCES restrictions (id_restriction) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE restrictions_premises_assoc
ADD CONSTRAINT FK_restrictions_premises_assoc_restrictions_id_restriction FOREIGN KEY (id_restriction)
REFERENCES restrictions (id_restriction) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать представление `v_premises_state_reg`
--
CREATE
VIEW v_premises_state_reg
AS
SELECT
  `rpa`.`id_premises` AS `id_premises`,
  MAX(`r`.`date_state_reg`) AS `date_state_reg`
FROM (`restrictions` `r`
  JOIN `restrictions_premises_assoc` `rpa`
    ON ((`r`.`id_restriction` = `rpa`.`id_restriction`)))
WHERE ((`r`.`date_state_reg` IS NOT NULL)
AND (`r`.`deleted` <> 1)
AND (`rpa`.`deleted` <> 1))
GROUP BY `rpa`.`id_premises`;

--
-- Создать представление `v_premises_restrictions_max_date`
--
CREATE
VIEW v_premises_restrictions_max_date
AS
SELECT
  `rpa`.`id_premises` AS `id_premises`,
  MAX(`r`.`date`) AS `date`
FROM (`restrictions_premises_assoc` `rpa`
  JOIN `restrictions` `r`
    ON ((`rpa`.`id_restriction` = `r`.`id_restriction`)))
WHERE ((`rpa`.`deleted` <> 1)
AND (`r`.`deleted` <> 1)
AND (`r`.`id_restriction_type` IN (1, 2)))
GROUP BY `rpa`.`id_premises`;

--
-- Создать представление `v_premises_included_into_municipal`
--
CREATE
VIEW v_premises_included_into_municipal
AS
SELECT
  `rpa`.`id_premises` AS `id_premises`,
  `r`.`id_restriction` AS `id_restriction`
FROM ((`restrictions` `r`
  JOIN `restrictions_premises_assoc` `rpa`
    ON ((`r`.`id_restriction` = `rpa`.`id_restriction`)))
  JOIN `v_premises_restrictions_max_date` `v`
    ON (((`r`.`date` = `v`.`date`)
    AND (`rpa`.`id_premises` = `v`.`id_premises`))))
WHERE ((`r`.`id_restriction_type` = 1)
AND (`rpa`.`deleted` <> 1)
AND (`r`.`deleted` <> 1));

--
-- Создать представление `v_premises_excluded_from_municipal`
--
CREATE
VIEW v_premises_excluded_from_municipal
AS
SELECT
  `rpa`.`id_premises` AS `id_premises`,
  `r`.`id_restriction` AS `id_restriction`
FROM ((`restrictions` `r`
  JOIN `restrictions_premises_assoc` `rpa`
    ON ((`r`.`id_restriction` = `rpa`.`id_restriction`)))
  JOIN `v_premises_restrictions_max_date` `v`
    ON (((`r`.`date` = `v`.`date`)
    AND (`rpa`.`id_premises` = `v`.`id_premises`))))
WHERE ((`r`.`id_restriction_type` = 2)
AND (`rpa`.`deleted` <> 1)
AND (`r`.`deleted` <> 1));

--
-- Создать представление `v_premises_privatiz_max_date`
--
CREATE
VIEW v_premises_privatiz_max_date
AS
SELECT
  `rpa`.`id_premises` AS `id_premises`,
  MAX(`r`.`date`) AS `privatiz_date`
FROM (`restrictions` `r`
  JOIN `restrictions_premises_assoc` `rpa`
    ON ((`r`.`id_restriction` = `rpa`.`id_restriction`)))
WHERE ((`r`.`deleted` <> 1)
AND (`rpa`.`deleted` <> 1)
AND (TRIM(`r`.`description`) = 'приватизация'))
GROUP BY `rpa`.`id_premises`;

--
-- Создать представление `v_premises_privatiz`
--
CREATE
VIEW v_premises_privatiz
AS
SELECT
  `rpa`.`id_premises` AS `id_premises`,
  `r`.`number` AS `number`,
  `r`.`date` AS `date`,
  `r`.`date_state_reg` AS `date_state_reg`
FROM ((`restrictions` `r`
  JOIN `restrictions_premises_assoc` `rpa`
    ON ((`r`.`id_restriction` = `rpa`.`id_restriction`)))
  JOIN `v_premises_privatiz_max_date` `vppmd`
    ON (((`r`.`date` = `vppmd`.`privatiz_date`)
    AND (`rpa`.`id_premises` = `vppmd`.`id_premises`))))
WHERE ((`r`.`deleted` <> 1)
AND (`rpa`.`deleted` <> 1)
AND (TRIM(`r`.`description`) = 'приватизация'))
GROUP BY `rpa`.`id_premises`;

--
-- Создать представление `v_premises_municipal_include_max_date`
--
CREATE
VIEW v_premises_municipal_include_max_date
AS
SELECT
  `rpa`.`id_premises` AS `id_premises`,
  MAX(`r`.`date`) AS `date`
FROM (`restrictions` `r`
  JOIN `restrictions_premises_assoc` `rpa`
    ON ((`r`.`id_restriction` = `rpa`.`id_restriction`)))
WHERE ((`r`.`id_restriction_type` = 1)
AND (`r`.`deleted` <> 1)
AND (`rpa`.`deleted` <> 1))
GROUP BY `rpa`.`id_premises`;

--
-- Создать представление `v_premises_municipal_include_restrictions`
--
CREATE
VIEW v_premises_municipal_include_restrictions
AS
SELECT
  `r`.`id_restriction` AS `id_restriction`,
  `r`.`number` AS `number`,
  `r`.`date` AS `date`,
  `r`.`description` AS `description`,
  `r`.`deleted` AS `deleted`,
  `rpa`.`id_premises` AS `id_premises`
FROM ((`restrictions` `r`
  JOIN `restrictions_premises_assoc` `rpa`
    ON ((`r`.`id_restriction` = `rpa`.`id_restriction`)))
  JOIN `v_premises_municipal_include_max_date` `v`
    ON (((`v`.`id_premises` = `rpa`.`id_premises`)
    AND (`v`.`date` = `r`.`date`))))
WHERE ((`r`.`id_restriction_type` = 1)
AND (`r`.`deleted` <> 1)
AND (`rpa`.`deleted` <> 1))
GROUP BY `rpa`.`id_premises`;

--
-- Создать представление `v_premises_municipal_exclude_max_date`
--
CREATE
VIEW v_premises_municipal_exclude_max_date
AS
SELECT
  `rpa`.`id_premises` AS `id_premises`,
  MAX(`r`.`date`) AS `date`
FROM (`restrictions` `r`
  JOIN `restrictions_premises_assoc` `rpa`
    ON ((`r`.`id_restriction` = `rpa`.`id_restriction`)))
WHERE ((`r`.`id_restriction_type` = 2)
AND (`r`.`deleted` <> 1)
AND (`rpa`.`deleted` <> 1))
GROUP BY `rpa`.`id_premises`;

--
-- Создать представление `v_premises_municipal_exclude_restrictions`
--
CREATE
VIEW v_premises_municipal_exclude_restrictions
AS
SELECT
  `r`.`id_restriction` AS `id_restriction`,
  `r`.`number` AS `number`,
  `r`.`date` AS `date`,
  `r`.`description` AS `description`,
  `r`.`deleted` AS `deleted`,
  `rpa`.`id_premises` AS `id_premises`
FROM ((`restrictions` `r`
  JOIN `restrictions_premises_assoc` `rpa`
    ON ((`r`.`id_restriction` = `rpa`.`id_restriction`)))
  JOIN `v_premises_municipal_exclude_max_date` `v`
    ON (((`v`.`id_premises` = `rpa`.`id_premises`)
    AND (`v`.`date` = `r`.`date`))))
WHERE ((`r`.`id_restriction_type` = 2)
AND (`r`.`deleted` <> 1)
AND (`rpa`.`deleted` <> 1))
GROUP BY `rpa`.`id_premises`;

--
-- Создать представление `v_buildings_restrictions_max_date`
--
CREATE
VIEW v_buildings_restrictions_max_date
AS
SELECT
  `rba`.`id_building` AS `id_building`,
  MAX(`r`.`date`) AS `date`
FROM (`restrictions_buildings_assoc` `rba`
  JOIN `restrictions` `r`
    ON ((`rba`.`id_restriction` = `r`.`id_restriction`)))
WHERE ((`rba`.`deleted` <> 1)
AND (`r`.`deleted` <> 1)
AND (`r`.`id_restriction_type` IN (1, 2)))
GROUP BY `rba`.`id_building`;

--
-- Создать представление `v_buildings_included_into_municipal`
--
CREATE
VIEW v_buildings_included_into_municipal
AS
SELECT
  `rba`.`id_building` AS `id_building`,
  `r`.`id_restriction` AS `id_restriction`
FROM ((`restrictions` `r`
  JOIN `restrictions_buildings_assoc` `rba`
    ON ((`r`.`id_restriction` = `rba`.`id_restriction`)))
  JOIN `v_buildings_restrictions_max_date` `v`
    ON (((`r`.`date` = `v`.`date`)
    AND (`rba`.`id_building` = `v`.`id_building`))))
WHERE ((`r`.`id_restriction_type` = 1)
AND (`rba`.`deleted` <> 1)
AND (`r`.`deleted` <> 1));

--
-- Создать представление `v_buildings_excluded_from_municipal`
--
CREATE
VIEW v_buildings_excluded_from_municipal
AS
SELECT
  `rba`.`id_building` AS `id_building`,
  `r`.`id_restriction` AS `id_restriction`
FROM ((`restrictions` `r`
  JOIN `restrictions_buildings_assoc` `rba`
    ON ((`r`.`id_restriction` = `rba`.`id_restriction`)))
  JOIN `v_buildings_restrictions_max_date` `v`
    ON (((`r`.`date` = `v`.`date`)
    AND (`rba`.`id_building` = `v`.`id_building`))))
WHERE ((`r`.`id_restriction_type` = 2)
AND (`rba`.`deleted` <> 1)
AND (`r`.`deleted` <> 1));

--
-- Создать представление `v_buildings_municipal_include_max_date`
--
CREATE
VIEW v_buildings_municipal_include_max_date
AS
SELECT
  `rba`.`id_building` AS `id_building`,
  MAX(`r`.`date`) AS `date`
FROM (`restrictions` `r`
  JOIN `restrictions_buildings_assoc` `rba`
    ON ((`r`.`id_restriction` = `rba`.`id_restriction`)))
WHERE ((`r`.`id_restriction_type` = 1)
AND (`r`.`deleted` <> 1)
AND (`rba`.`deleted` <> 1))
GROUP BY `rba`.`id_building`;

--
-- Создать представление `v_buildings_municipal_include_restrictions`
--
CREATE
VIEW v_buildings_municipal_include_restrictions
AS
SELECT
  `r`.`id_restriction` AS `id_restriction`,
  `r`.`number` AS `number`,
  `r`.`date` AS `date`,
  `r`.`description` AS `description`,
  `r`.`deleted` AS `deleted`,
  `rba`.`id_building` AS `id_building`
FROM ((`restrictions` `r`
  JOIN `restrictions_buildings_assoc` `rba`
    ON ((`r`.`id_restriction` = `rba`.`id_restriction`)))
  JOIN `v_buildings_municipal_include_max_date` `v`
    ON (((`v`.`id_building` = `rba`.`id_building`)
    AND (`v`.`date` = `r`.`date`))))
WHERE ((`r`.`id_restriction_type` = 1)
AND (`r`.`deleted` <> 1)
AND (`rba`.`deleted` <> 1))
GROUP BY `rba`.`id_building`;

--
-- Создать представление `v_buildings_municipal_exclude_max_date`
--
CREATE
VIEW v_buildings_municipal_exclude_max_date
AS
SELECT
  `rba`.`id_building` AS `id_building`,
  MAX(`r`.`date`) AS `date`
FROM (`restrictions` `r`
  JOIN `restrictions_buildings_assoc` `rba`
    ON ((`r`.`id_restriction` = `rba`.`id_restriction`)))
WHERE ((`r`.`id_restriction_type` = 2)
AND (`r`.`deleted` <> 1)
AND (`rba`.`deleted` <> 1))
GROUP BY `rba`.`id_building`;

--
-- Создать представление `v_buildings_municipal_exclude_restrictions`
--
CREATE
VIEW v_buildings_municipal_exclude_restrictions
AS
SELECT
  `r`.`id_restriction` AS `id_restriction`,
  `r`.`number` AS `number`,
  `r`.`date` AS `date`,
  `r`.`description` AS `description`,
  `r`.`deleted` AS `deleted`,
  `rba`.`id_building` AS `id_building`
FROM ((`restrictions` `r`
  JOIN `restrictions_buildings_assoc` `rba`
    ON ((`r`.`id_restriction` = `rba`.`id_restriction`)))
  JOIN `v_buildings_municipal_exclude_max_date` `v`
    ON (((`v`.`id_building` = `rba`.`id_building`)
    AND (`v`.`date` = `r`.`date`))))
WHERE ((`r`.`id_restriction_type` = 2)
AND (`r`.`deleted` <> 1)
AND (`rba`.`deleted` <> 1))
GROUP BY `rba`.`id_building`;

--
-- Создать таблицу `restriction_types`
--
CREATE TABLE IF NOT EXISTS restriction_types (
  id_restriction_type int(11) NOT NULL AUTO_INCREMENT,
  restriction_type varchar(255) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_restriction_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 9,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `restriction_types_after_insert`
--
CREATE TRIGGER restriction_types_after_insert
AFTER INSERT
ON restriction_types
FOR EACH ROW
BEGIN
  IF (NEW.restriction_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restriction_types', NEW.id_restriction_type, 'restriction_type', NULL, NEW.restriction_type, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `restriction_types_after_update`
--
CREATE TRIGGER restriction_types_after_update
AFTER UPDATE
ON restriction_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'restriction_types', NEW.id_restriction_type, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.restriction_type <> OLD.restriction_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'restriction_types', NEW.id_restriction_type, 'restriction_type', OLD.restriction_type, NEW.restriction_type, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `restriction_types_before_update`
--
CREATE TRIGGER restriction_types_before_update
BEFORE UPDATE
ON restriction_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM restrictions
        WHERE deleted <> 1
        AND id_restriction_type = NEW.id_restriction_type) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить тип реквизита, т.к. существуют реквизиты данного типа';
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE restrictions
ADD CONSTRAINT FK_restrictions_restriction_types_id_restriction_type FOREIGN KEY (id_restriction_type)
REFERENCES restriction_types (id_restriction_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `resettle_sub_premises_to_assoc`
--
CREATE TABLE IF NOT EXISTS resettle_sub_premises_to_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_sub_premises int(11) NOT NULL,
  id_process int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 16384,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `resettle_sub_premises_to_assoc_after_insert`
--
CREATE TRIGGER resettle_sub_premises_to_assoc_after_insert
AFTER INSERT
ON resettle_sub_premises_to_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_sub_premises IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_sub_premises_to_assoc', NEW.id_assoc, 'id_sub_premises', NULL, NEW.id_sub_premises, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_sub_premises_to_assoc', NEW.id_assoc, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `resettle_sub_premises_to_assoc_after_update`
--
CREATE TRIGGER resettle_sub_premises_to_assoc_after_update
AFTER UPDATE
ON resettle_sub_premises_to_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_sub_premises_to_assoc', NEW.id_assoc, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_sub_premises <> OLD.id_sub_premises) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_sub_premises_to_assoc', NEW.id_assoc, 'id_sub_premises', OLD.id_sub_premises, NEW.id_sub_premises, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_sub_premises_to_assoc', NEW.id_assoc, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `resettle_sub_premises_from_assoc`
--
CREATE TABLE IF NOT EXISTS resettle_sub_premises_from_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_sub_premises int(11) NOT NULL,
  id_process int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 13,
AVG_ROW_LENGTH = 2340,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `resettle_sub_premises_from_assoc_after_insert`
--
CREATE TRIGGER resettle_sub_premises_from_assoc_after_insert
AFTER INSERT
ON resettle_sub_premises_from_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_sub_premises IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_sub_premises_from_assoc', NEW.id_assoc, 'id_sub_premises', NULL, NEW.id_sub_premises, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_sub_premises_from_assoc', NEW.id_assoc, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `resettle_sub_premises_from_assoc_after_update`
--
CREATE TRIGGER resettle_sub_premises_from_assoc_after_update
AFTER UPDATE
ON resettle_sub_premises_from_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_sub_premises_from_assoc', NEW.id_assoc, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_sub_premises <> OLD.id_sub_premises) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_sub_premises_from_assoc', NEW.id_assoc, 'id_sub_premises', OLD.id_sub_premises, NEW.id_sub_premises, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_sub_premises_from_assoc', NEW.id_assoc, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `resettle_premises_to_assoc`
--
CREATE TABLE IF NOT EXISTS resettle_premises_to_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_premises int(11) NOT NULL,
  id_process int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1226,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `resettle_premises_to_assoc_after_insert`
--
CREATE TRIGGER resettle_premises_to_assoc_after_insert
AFTER INSERT
ON resettle_premises_to_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_premises IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_premises_to_assoc', NEW.id_assoc, 'id_premises', NULL, NEW.id_premises, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_premises_to_assoc', NEW.id_assoc, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `resettle_premises_to_assoc_after_update`
--
CREATE TRIGGER resettle_premises_to_assoc_after_update
AFTER UPDATE
ON resettle_premises_to_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_premises_to_assoc', NEW.id_assoc, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_premises <> OLD.id_premises) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_premises_to_assoc', NEW.id_assoc, 'id_premises', OLD.id_premises, NEW.id_premises, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_premises_to_assoc', NEW.id_assoc, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `resettle_premises_from_assoc`
--
CREATE TABLE IF NOT EXISTS resettle_premises_from_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_premises int(11) NOT NULL,
  id_process int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1211,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `resettle_premises_from_assoc_after_insert`
--
CREATE TRIGGER resettle_premises_from_assoc_after_insert
AFTER INSERT
ON resettle_premises_from_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_premises IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_premises_from_assoc', NEW.id_assoc, 'id_premises', NULL, NEW.id_premises, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_premises_from_assoc', NEW.id_assoc, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `resettle_premises_from_assoc_after_update`
--
CREATE TRIGGER resettle_premises_from_assoc_after_update
AFTER UPDATE
ON resettle_premises_from_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_premises_from_assoc', NEW.id_assoc, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_premises <> OLD.id_premises) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_premises_from_assoc', NEW.id_assoc, 'id_premises', OLD.id_premises, NEW.id_premises, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_premises_from_assoc', NEW.id_assoc, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `resettle_persons`
--
CREATE TABLE IF NOT EXISTS resettle_persons (
  id_person int(11) NOT NULL AUTO_INCREMENT,
  id_process int(11) NOT NULL,
  surname varchar(50) NOT NULL,
  name varchar(50) NOT NULL,
  patronymic varchar(255) DEFAULT NULL,
  document_num varchar(8) DEFAULT NULL COMMENT 'Номер документа, удостоверяющего личность',
  document_seria varchar(8) DEFAULT NULL COMMENT 'Серия документа, удостоверяющего личность',
  founding_doc varchar(255) DEFAULT NULL COMMENT 'Правоустанавливающий документ',
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_person)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1889,
AVG_ROW_LENGTH = 2730,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Участники процесса переселения';

DELIMITER $$

--
-- Создать триггер `resettle_persons_after_insert`
--
CREATE TRIGGER resettle_persons_after_insert
AFTER INSERT
ON resettle_persons
FOR EACH ROW
BEGIN
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_persons', NEW.id_person, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.surname IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_persons', NEW.id_person, 'surname', NULL, NEW.surname, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_persons', NEW.id_person, 'name', NULL, NEW.name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.patronymic IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_persons', NEW.id_person, 'patronymic', NULL, NEW.patronymic, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.document_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_persons', NEW.id_person, 'document_num', NULL, NEW.document_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.document_seria IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_persons', NEW.id_person, 'document_seria', NULL, NEW.document_seria, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.founding_doc IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_persons', NEW.id_person, 'founding_doc', NULL, NEW.founding_doc, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `resettle_persons_after_update`
--
CREATE TRIGGER resettle_persons_after_update
AFTER UPDATE
ON resettle_persons
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_persons', NEW.id_person, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_persons', NEW.id_person, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.surname <> OLD.surname) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_persons', NEW.id_person, 'surname', OLD.surname, NEW.surname, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.name <> OLD.name) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_persons', NEW.id_person, 'name', OLD.name, NEW.name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.patronymic IS NULL
      AND OLD.patronymic IS NULL)
      AND ((NEW.patronymic IS NULL
      AND OLD.patronymic IS NOT NULL)
      OR (NEW.patronymic IS NOT NULL
      AND OLD.patronymic IS NULL)
      OR (NEW.patronymic <> OLD.patronymic))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_persons', NEW.id_person, 'patronymic', OLD.patronymic, NEW.patronymic, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.document_num IS NULL
      AND OLD.document_num IS NULL)
      AND ((NEW.document_num IS NULL
      AND OLD.document_num IS NOT NULL)
      OR (NEW.document_num IS NOT NULL
      AND OLD.document_num IS NULL)
      OR (NEW.document_num <> OLD.document_num))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_persons', NEW.id_person, 'document_num', OLD.document_num, NEW.document_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.document_seria IS NULL
      AND OLD.document_seria IS NULL)
      AND ((NEW.document_seria IS NULL
      AND OLD.document_seria IS NOT NULL)
      OR (NEW.document_seria IS NOT NULL
      AND OLD.document_seria IS NULL)
      OR (NEW.document_seria <> OLD.document_seria))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_persons', NEW.id_person, 'document_seria', OLD.document_seria, NEW.document_seria, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.founding_doc IS NULL
      AND OLD.founding_doc IS NULL)
      AND ((NEW.founding_doc IS NULL
      AND OLD.founding_doc IS NOT NULL)
      OR (NEW.founding_doc IS NOT NULL
      AND OLD.founding_doc IS NULL)
      OR (NEW.founding_doc <> OLD.founding_doc))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_persons', NEW.id_person, 'founding_doc', OLD.founding_doc, NEW.founding_doc, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `resettle_buildings_to_assoc`
--
CREATE TABLE IF NOT EXISTS resettle_buildings_to_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_building int(11) NOT NULL,
  id_process int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 45,
AVG_ROW_LENGTH = 16384,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `resettle_buildings_to_assoc_after_insert`
--
CREATE TRIGGER resettle_buildings_to_assoc_after_insert
AFTER INSERT
ON resettle_buildings_to_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_building IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_buildings_to_assoc', NEW.id_assoc, 'id_building', NULL, NEW.id_building, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_buildings_to_assoc', NEW.id_assoc, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `resettle_buildings_to_assoc_after_update`
--
CREATE TRIGGER resettle_buildings_to_assoc_after_update
AFTER UPDATE
ON resettle_buildings_to_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_buildings_to_assoc', NEW.id_assoc, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_building <> OLD.id_building) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_buildings_to_assoc', NEW.id_assoc, 'id_building', OLD.id_building, NEW.id_building, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_buildings_to_assoc', NEW.id_assoc, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `resettle_buildings_from_assoc`
--
CREATE TABLE IF NOT EXISTS resettle_buildings_from_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_building int(11) NOT NULL,
  id_process int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 11,
AVG_ROW_LENGTH = 16384,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `resettle_buildings_from_assoc_after_insert`
--
CREATE TRIGGER resettle_buildings_from_assoc_after_insert
AFTER INSERT
ON resettle_buildings_from_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_building IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_buildings_from_assoc', NEW.id_assoc, 'id_building', NULL, NEW.id_building, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_buildings_from_assoc', NEW.id_assoc, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `resettle_buildings_from_assoc_after_update`
--
CREATE TRIGGER resettle_buildings_from_assoc_after_update
AFTER UPDATE
ON resettle_buildings_from_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_buildings_from_assoc', NEW.id_assoc, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_building <> OLD.id_building) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_buildings_from_assoc', NEW.id_assoc, 'id_building', OLD.id_building, NEW.id_building, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_buildings_from_assoc', NEW.id_assoc, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `resettle_processes`
--
CREATE TABLE IF NOT EXISTS resettle_processes (
  id_process int(11) NOT NULL AUTO_INCREMENT,
  resettle_date date DEFAULT NULL,
  doc_number varchar(255) DEFAULT NULL COMMENT 'Номер постановления',
  id_document_residence int(11) NOT NULL COMMENT 'Документ-основание на проживание',
  debts decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Задолжность по квартплате',
  description text DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_process)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1261,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Процессы переселения';

DELIMITER $$

--
-- Создать триггер `resettle_processes_after_insert`
--
CREATE TRIGGER resettle_processes_after_insert
AFTER INSERT
ON resettle_processes
FOR EACH ROW
BEGIN
  IF (NEW.resettle_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_processes', NEW.id_process, 'resettle_date', NULL, NEW.resettle_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_document_residence IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_processes', NEW.id_process, 'id_document_residence', NULL, NEW.id_document_residence, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.debts IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_processes', NEW.id_process, 'debts', NULL, NEW.debts, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_processes', NEW.id_process, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.doc_number IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_processes', NEW.id_process, 'doc_number', NULL, NEW.doc_number, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `resettle_processes_after_update`
--
CREATE TRIGGER resettle_processes_after_update
AFTER UPDATE
ON resettle_processes
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'resettle_processes', NEW.id_process, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NOT (NEW.resettle_date IS NULL
      AND OLD.resettle_date IS NULL)
      AND ((NEW.resettle_date IS NULL
      AND OLD.resettle_date IS NOT NULL)
      OR (NEW.resettle_date IS NOT NULL
      AND OLD.resettle_date IS NULL)
      OR (NEW.resettle_date <> OLD.resettle_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_processes', NEW.id_process, 'resettle_date', OLD.resettle_date, NEW.resettle_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_document_residence <> OLD.id_document_residence) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_processes', NEW.id_process, 'id_document_residence', OLD.id_document_residence, NEW.id_document_residence, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.debts <> OLD.debts) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_processes', NEW.id_process, 'debts', OLD.debts, NEW.debts, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_processes', NEW.id_process, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.doc_number IS NULL
      AND OLD.doc_number IS NULL)
      AND ((NEW.doc_number IS NULL
      AND OLD.doc_number IS NOT NULL)
      OR (NEW.doc_number IS NOT NULL
      AND OLD.doc_number IS NULL)
      OR (NEW.doc_number <> OLD.doc_number))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'resettle_processes', NEW.id_process, 'doc_number', OLD.doc_number, NEW.doc_number, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `resettle_process_before_update`
--
CREATE TRIGGER resettle_process_before_update
BEFORE UPDATE
ON resettle_processes
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    UPDATE resettle_buildings_from_assoc
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE resettle_buildings_to_assoc
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE resettle_premises_from_assoc
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE resettle_premises_to_assoc
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE resettle_sub_premises_from_assoc
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE resettle_sub_premises_to_assoc
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE resettle_persons
    SET deleted = 1
    WHERE id_process = NEW.id_process;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_buildings_from_assoc
ADD CONSTRAINT FK_resettle_buildings_from_assoc_resettle_processes_id_process FOREIGN KEY (id_process)
REFERENCES resettle_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_buildings_to_assoc
ADD CONSTRAINT FK_resettle_buildings_to_assoc_resettle_processes_id_process FOREIGN KEY (id_process)
REFERENCES resettle_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_persons
ADD CONSTRAINT FK_resettle_persons_resettle_processes_id_process FOREIGN KEY (id_process)
REFERENCES resettle_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_premises_from_assoc
ADD CONSTRAINT FK_resettle_premises_from_assoc_resettle_processes_id_process FOREIGN KEY (id_process)
REFERENCES resettle_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_premises_to_assoc
ADD CONSTRAINT FK_resettle_premises_to_assoc_resettle_processes_id_process FOREIGN KEY (id_process)
REFERENCES resettle_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_sub_premises_from_assoc
ADD CONSTRAINT FK_resettle_sp_from_assoc_resettle_processes_id_process FOREIGN KEY (id_process)
REFERENCES resettle_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_sub_premises_to_assoc
ADD CONSTRAINT FK_resettle_sp_to_assoc_resettle_processes_id_process FOREIGN KEY (id_process)
REFERENCES resettle_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `documents_residence`
--
CREATE TABLE IF NOT EXISTS documents_residence (
  id_document_residence int(11) NOT NULL AUTO_INCREMENT,
  document_residence varchar(255) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_document_residence)
)
ENGINE = INNODB,
AUTO_INCREMENT = 11,
AVG_ROW_LENGTH = 1820,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Документы-основания на проживание';

DELIMITER $$

--
-- Создать триггер `documents_residence_after_insert`
--
CREATE TRIGGER documents_residence_after_insert
AFTER INSERT
ON documents_residence
FOR EACH ROW
BEGIN
  IF (NEW.document_residence IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'documents_residence', NEW.id_document_residence, 'document_residence', NULL, NEW.document_residence, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `documents_residence_after_update`
--
CREATE TRIGGER documents_residence_after_update
AFTER UPDATE
ON documents_residence
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'documents_residence', NEW.id_document_residence, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.document_residence <> OLD.document_residence) THEN
      INSERT INTO `log`
        VALUES (NULL, 'documents_residence', NEW.id_document_residence, 'document_residence', OLD.document_residence, NEW.document_residence, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `documents_residence_before_update`
--
CREATE TRIGGER documents_residence_before_update
BEFORE UPDATE
ON documents_residence
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM resettle_processes
        WHERE deleted <> 1
        AND id_document_residence = NEW.id_document_residence) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить документ-основание на проживание, т.к. необходимо сначала удалить все процессы переселения, в которых он используется';
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_processes
ADD CONSTRAINT FK_resettle_processes_documents_residence_id_document_residence FOREIGN KEY (id_document_residence)
REFERENCES documents_residence (id_document_residence) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `priv_realtors`
--
CREATE TABLE IF NOT EXISTS priv_realtors (
  id_realtor int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  passport varchar(2000) NOT NULL,
  date_birth date NOT NULL,
  place_of_registration varchar(2000) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_realtor)
)
ENGINE = INNODB,
AUTO_INCREMENT = 38,
AVG_ROW_LENGTH = 1638,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `priv_realtors_after_insert`
--
CREATE TRIGGER priv_realtors_after_insert
AFTER INSERT
ON priv_realtors
FOR EACH ROW
BEGIN
  INSERT INTO `log`
    VALUES (NULL, 'priv_realtors', NEW.id_realtor, 'name', NULL, NEW.name, 'INSERT', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'priv_realtors', NEW.id_realtor, 'passport', NULL, NEW.passport, 'INSERT', NOW(), USER());
  IF (NEW.date_birth IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_realtors', NEW.id_realtor, 'date_birth', NULL, NEW.date_birth, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.place_of_registration IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_realtors', NEW.id_realtor, 'place_of_registration', NULL, NEW.place_of_registration, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `priv_realtors_after_update`
--
CREATE TRIGGER priv_realtors_after_update
AFTER UPDATE
ON priv_realtors
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_realtors', NEW.id_realtor, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.name <> OLD.name) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_realtors', NEW.id_realtor, 'name', OLD.name, NEW.name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.passport <> OLD.passport) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_realtors', NEW.id_realtor, 'passport', OLD.passport, NEW.passport, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_birth IS NULL
      AND OLD.date_birth IS NULL)
      AND ((NEW.date_birth IS NULL
      AND OLD.date_birth IS NOT NULL)
      OR (NEW.date_birth IS NOT NULL
      AND OLD.date_birth IS NULL)
      OR (NEW.date_birth <> OLD.date_birth))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_realtors', NEW.id_realtor, 'date_birth', OLD.date_birth, NEW.date_birth, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.place_of_registration IS NULL
      AND OLD.place_of_registration IS NULL)
      AND ((NEW.place_of_registration IS NULL
      AND OLD.place_of_registration IS NOT NULL)
      OR (NEW.place_of_registration IS NOT NULL
      AND OLD.place_of_registration IS NULL)
      OR (NEW.place_of_registration <> OLD.place_of_registration))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_realtors', NEW.id_realtor, 'place_of_registration', OLD.place_of_registration, NEW.place_of_registration, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `ownership_premises_assoc`
--
CREATE TABLE IF NOT EXISTS ownership_premises_assoc (
  id_premises int(11) NOT NULL,
  id_ownership_right int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_premises, id_ownership_right)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 140,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `ownership_premises_assoc_after_insert`
--
CREATE TRIGGER ownership_premises_assoc_after_insert
AFTER INSERT
ON ownership_premises_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_premises IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_premises_assoc', NEW.id_ownership_right, 'id_premises', NULL, NEW.id_premises, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `ownership_premises_assoc_after_update`
--
CREATE TRIGGER ownership_premises_assoc_after_update
AFTER UPDATE
ON ownership_premises_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_premises_assoc', NEW.id_ownership_right, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `ownership_buildings_assoc`
--
CREATE TABLE IF NOT EXISTS ownership_buildings_assoc (
  id_building int(11) NOT NULL,
  id_ownership_right int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_building, id_ownership_right)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 63,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `ownership_buildings_assoc_after_insert`
--
CREATE TRIGGER ownership_buildings_assoc_after_insert
AFTER INSERT
ON ownership_buildings_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_building IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_buildings_assoc', NEW.id_ownership_right, 'id_building', NULL, NEW.id_building, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `ownership_buildings_assoc_after_update`
--
CREATE TRIGGER ownership_buildings_assoc_after_update
AFTER UPDATE
ON ownership_buildings_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_buildings_assoc', NEW.id_ownership_right, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `ownership_rights`
--
CREATE TABLE IF NOT EXISTS ownership_rights (
  id_ownership_right int(11) NOT NULL AUTO_INCREMENT,
  id_ownership_right_type int(11) NOT NULL COMMENT 'Тип сведений об установленных ограничениях',
  number varchar(20) DEFAULT NULL COMMENT 'Номер',
  date date NOT NULL COMMENT 'Дата',
  description varchar(255) DEFAULT NULL COMMENT 'Наименование',
  resettle_plan_date date DEFAULT NULL COMMENT '(Для аварийн)Планируемая дата переселения (по документам)',
  demolish_plan_date date DEFAULT NULL COMMENT '(Для аварийн)Планируемая дата сноса (по документам)',
  file_origin_name varchar(255) DEFAULT NULL,
  file_display_name varchar(255) DEFAULT NULL,
  file_mime_type varchar(255) DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_ownership_right)
)
ENGINE = INNODB,
AUTO_INCREMENT = 9998,
AVG_ROW_LENGTH = 109,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Сведения об установленных в отношении муниципального движимого имущества ограничениях ';

DELIMITER $$

--
-- Создать триггер `ownership_rights_after_insert`
--
CREATE TRIGGER ownership_rights_after_insert
AFTER INSERT
ON ownership_rights
FOR EACH ROW
BEGIN
  IF (NEW.id_ownership_right_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'id_ownership_right_type', NULL, NEW.id_ownership_right_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.number IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'number', NULL, NEW.number, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'date', NULL, NEW.date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.resettle_plan_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'resettle_plan_date', NULL, NEW.resettle_plan_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.demolish_plan_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'demolish_plan_date', NULL, NEW.demolish_plan_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.file_origin_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'file_origin_name', NULL, NEW.file_origin_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.file_display_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'file_display_name', NULL, NEW.file_display_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.file_mime_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'file_mime_type', NULL, NEW.file_mime_type, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `ownership_rights_after_update`
--
CREATE TRIGGER ownership_rights_after_update
AFTER UPDATE
ON ownership_rights
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_ownership_right_type <> OLD.id_ownership_right_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'id_ownership_right_type', OLD.id_ownership_right_type, NEW.id_ownership_right_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.number IS NULL
      AND OLD.number IS NULL)
      AND ((NEW.number IS NULL
      AND OLD.number IS NOT NULL)
      OR (NEW.number IS NOT NULL
      AND OLD.number IS NULL)
      OR (NEW.number <> OLD.number))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'number', OLD.number, NEW.number, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.date <> OLD.date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'date', OLD.date, NEW.date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.resettle_plan_date IS NULL
      AND OLD.resettle_plan_date IS NULL)
      AND ((NEW.resettle_plan_date IS NULL
      AND OLD.resettle_plan_date IS NOT NULL)
      OR (NEW.resettle_plan_date IS NOT NULL
      AND OLD.resettle_plan_date IS NULL)
      OR (NEW.resettle_plan_date <> OLD.resettle_plan_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'resettle_plan_date', OLD.resettle_plan_date, NEW.resettle_plan_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.demolish_plan_date IS NULL
      AND OLD.demolish_plan_date IS NULL)
      AND ((NEW.demolish_plan_date IS NULL
      AND OLD.demolish_plan_date IS NOT NULL)
      OR (NEW.demolish_plan_date IS NOT NULL
      AND OLD.demolish_plan_date IS NULL)
      OR (NEW.demolish_plan_date <> OLD.demolish_plan_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'demolish_plan_date', OLD.demolish_plan_date, NEW.demolish_plan_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.file_origin_name IS NULL
      AND OLD.file_origin_name IS NULL)
      AND ((NEW.file_origin_name IS NULL
      AND OLD.file_origin_name IS NOT NULL)
      OR (NEW.file_origin_name IS NOT NULL
      AND OLD.file_origin_name IS NULL)
      OR (NEW.file_origin_name <> OLD.file_origin_name))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'file_origin_name', OLD.file_origin_name, NEW.file_origin_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.file_display_name IS NULL
      AND OLD.file_display_name IS NULL)
      AND ((NEW.file_display_name IS NULL
      AND OLD.file_display_name IS NOT NULL)
      OR (NEW.file_display_name IS NOT NULL
      AND OLD.file_display_name IS NULL)
      OR (NEW.file_display_name <> OLD.file_display_name))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'file_display_name', OLD.file_display_name, NEW.file_display_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.file_mime_type IS NULL
      AND OLD.file_mime_type IS NULL)
      AND ((NEW.file_mime_type IS NULL
      AND OLD.file_mime_type IS NOT NULL)
      OR (NEW.file_mime_type IS NOT NULL
      AND OLD.file_mime_type IS NULL)
      OR (NEW.file_mime_type <> OLD.file_mime_type))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'ownership_rights', NEW.id_ownership_right, 'file_mime_type', OLD.file_mime_type, NEW.file_mime_type, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `ownership_rights_before_update`
--
CREATE TRIGGER ownership_rights_before_update
BEFORE UPDATE
ON ownership_rights
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    UPDATE ownership_buildings_assoc
    SET deleted = 1
    WHERE id_ownership_right = NEW.id_ownership_right;
    UPDATE ownership_premises_assoc
    SET deleted = 1
    WHERE id_ownership_right = NEW.id_ownership_right;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE ownership_buildings_assoc
ADD CONSTRAINT FK_ownership_buildings_assoc_ownership_rights_id_ownership_right FOREIGN KEY (id_ownership_right)
REFERENCES ownership_rights (id_ownership_right) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE ownership_premises_assoc
ADD CONSTRAINT FK_ownership_premises_assoc_ownership_rights_id_ownership_right FOREIGN KEY (id_ownership_right)
REFERENCES ownership_rights (id_ownership_right) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `ownership_right_types`
--
CREATE TABLE IF NOT EXISTS ownership_right_types (
  id_ownership_right_type int(11) NOT NULL AUTO_INCREMENT,
  ownership_right_type varchar(255) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_ownership_right_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 15,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `ownership_right_types_after_insert`
--
CREATE TRIGGER ownership_right_types_after_insert
AFTER INSERT
ON ownership_right_types
FOR EACH ROW
BEGIN
  IF (NEW.ownership_right_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_right_types', NEW.id_ownership_right_type, 'ownership_right_type', NULL, NEW.ownership_right_type, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `ownership_right_types_after_update`
--
CREATE TRIGGER ownership_right_types_after_update
AFTER UPDATE
ON ownership_right_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'ownership_right_types', NEW.id_ownership_right_type, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.ownership_right_type <> OLD.ownership_right_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'ownership_right_types', NEW.id_ownership_right_type, 'ownership_right_type', OLD.ownership_right_type, NEW.ownership_right_type, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `ownership_right_types_before_update`
--
CREATE TRIGGER ownership_right_types_before_update
BEFORE UPDATE
ON ownership_right_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM ownership_rights
        WHERE deleted <> 1
        AND id_ownership_right_type = NEW.id_ownership_right_type) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить тип ограничения, т.к. существуют ограничения данного типа';
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE ownership_rights
ADD CONSTRAINT FK__ort_id_ort FOREIGN KEY (id_ownership_right_type)
REFERENCES ownership_right_types (id_ownership_right_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать представление `v_owner_reestr_prepare1`
--
CREATE
VIEW v_owner_reestr_prepare1
AS
SELECT
  `oba`.`id_building` AS `id_building`,
  `ort`.`ownership_right_type` AS `ownership_right_type`,
  `owr`.`id_ownership_right` AS `id_ownership_right`,
  `owr`.`id_ownership_right_type` AS `id_ownership_right_type`,
  `owr`.`number` AS `number`,
  `owr`.`date` AS `date`,
  `owr`.`description` AS `description`,
  `owr`.`resettle_plan_date` AS `resettle_plan_date`,
  `owr`.`demolish_plan_date` AS `demolish_plan_date`,
  `owr`.`file_origin_name` AS `file_origin_name`,
  `owr`.`file_display_name` AS `file_display_name`,
  `owr`.`file_mime_type` AS `file_mime_type`,
  `owr`.`deleted` AS `deleted`
FROM ((`ownership_buildings_assoc` `oba`
  LEFT JOIN `ownership_rights` `owr`
    ON ((`oba`.`id_ownership_right` = `owr`.`id_ownership_right`)))
  LEFT JOIN `ownership_right_types` `ort`
    ON ((`owr`.`id_ownership_right_type` = `ort`.`id_ownership_right_type`)))
WHERE ((`owr`.`id_ownership_right_type` IN (1, 2, 6, 7))
AND (`oba`.`deleted` <> 1)
AND (`owr`.`deleted` <> 1)
AND (`ort`.`deleted` <> 1))
ORDER BY `oba`.`id_building`, `owr`.`date` DESC;

--
-- Создать представление `v_buildings_ownership_rights_3_all`
--
CREATE
VIEW v_buildings_ownership_rights_3_all
AS
SELECT
  `oba`.`id_building` AS `id_building`,
  `ort`.`ownership_right_type` AS `ownership_right_type`,
  `owr`.`id_ownership_right` AS `id_ownership_right`,
  `owr`.`id_ownership_right_type` AS `id_ownership_right_type`,
  `owr`.`number` AS `number`,
  `owr`.`date` AS `date`,
  `owr`.`description` AS `description`,
  `owr`.`resettle_plan_date` AS `resettle_plan_date`,
  `owr`.`demolish_plan_date` AS `demolish_plan_date`
FROM ((`ownership_buildings_assoc` `oba`
  LEFT JOIN `ownership_rights` `owr`
    ON ((`oba`.`id_ownership_right` = `owr`.`id_ownership_right`)))
  LEFT JOIN `ownership_right_types` `ort`
    ON ((`owr`.`id_ownership_right_type` = `ort`.`id_ownership_right_type`)))
WHERE ((`owr`.`id_ownership_right_type` IN (1, 2, 6, 7, 8))
AND (`oba`.`deleted` <> 1)
AND (`owr`.`deleted` <> 1)
AND (`ort`.`deleted` <> 1))
ORDER BY `oba`.`id_building`, `owr`.`date` DESC;

--
-- Создать представление `v_buildings_ownership_rights_2_max_date`
--
CREATE
VIEW v_buildings_ownership_rights_2_max_date
AS
SELECT
  `vbor3`.`id_building` AS `id_building`,
  MAX(`vbor3`.`date`) AS `max_date`
FROM `v_buildings_ownership_rights_3_all` `vbor3`
GROUP BY `vbor3`.`id_building`;

--
-- Создать представление `v_buildings_ownership_rights_1_current`
--
CREATE
VIEW v_buildings_ownership_rights_1_current
AS
SELECT
  `vbor3`.`id_building` AS `id_building`,
  `vbor3`.`ownership_right_type` AS `ownership_right_type`,
  `vbor3`.`id_ownership_right` AS `id_ownership_right`,
  `vbor3`.`id_ownership_right_type` AS `id_ownership_right_type`,
  `vbor3`.`number` AS `number`,
  `vbor3`.`date` AS `date`,
  `vbor3`.`description` AS `description`,
  `vbor3`.`resettle_plan_date` AS `resettle_plan_date`,
  `vbor3`.`demolish_plan_date` AS `demolish_plan_date`
FROM (`v_buildings_ownership_rights_3_all` `vbor3`
  JOIN `v_buildings_ownership_rights_2_max_date` `vbor2`
    ON (((`vbor3`.`id_building` = `vbor2`.`id_building`)
    AND (`vbor3`.`date` = `vbor2`.`max_date`))));

--
-- Создать таблицу `kumi_charges_gis_gmp`
--
CREATE TABLE IF NOT EXISTS kumi_charges_gis_gmp (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  id_charge int(11) NOT NULL,
  uin char(25) NOT NULL,
  upload_date datetime DEFAULT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 40596,
AVG_ROW_LENGTH = 79,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IDX_kumi_charges_gis_gmp_uploa` для объекта типа таблица `kumi_charges_gis_gmp`
--
ALTER TABLE kumi_charges_gis_gmp
ADD INDEX IDX_kumi_charges_gis_gmp_uploa (upload_date);

--
-- Создать индекс `UK_kumi_charges_gis_gmp_id_cha` для объекта типа таблица `kumi_charges_gis_gmp`
--
ALTER TABLE kumi_charges_gis_gmp
ADD UNIQUE INDEX UK_kumi_charges_gis_gmp_id_cha (id_charge);

--
-- Создать индекс `UK_kumi_charges_gis_gmp_uin` для объекта типа таблица `kumi_charges_gis_gmp`
--
ALTER TABLE kumi_charges_gis_gmp
ADD UNIQUE INDEX UK_kumi_charges_gis_gmp_uin (uin);

DELIMITER $$

--
-- Создать триггер `kumi_charges_gis_gmp_after_insert`
--
CREATE TRIGGER kumi_charges_gis_gmp_after_insert
AFTER INSERT
ON kumi_charges_gis_gmp
FOR EACH ROW
BEGIN
  IF (NEW.id_charge IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_gis_gmp', NEW.id_record, 'id_charge', NULL, NEW.id_charge, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.uin IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_gis_gmp', NEW.id_record, 'uin', NULL, NEW.uin, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.upload_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_gis_gmp', NEW.id_record, 'upload_date', NULL, NEW.upload_date, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `kumi_charges_gis_gmp_after_update`
--
CREATE TRIGGER kumi_charges_gis_gmp_after_update
AFTER UPDATE
ON kumi_charges_gis_gmp
FOR EACH ROW
BEGIN
  IF (NEW.id_charge <> OLD.id_charge) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_gis_gmp', NEW.id_record, 'id_charge', OLD.id_charge, NEW.id_charge, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.uin <> OLD.uin) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_gis_gmp', NEW.id_record, 'uin', OLD.uin, NEW.uin, 'UPDATE', NOW(), USER());
  END IF;
  IF (NOT (NEW.upload_date IS NULL
    AND OLD.upload_date IS NULL)
    AND ((NEW.upload_date IS NULL
    AND OLD.upload_date IS NOT NULL)
    OR (NEW.upload_date IS NOT NULL
    AND OLD.upload_date IS NULL)
    OR (NEW.upload_date <> OLD.upload_date))) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_gis_gmp', NEW.id_record, 'upload_date', OLD.upload_date, NEW.upload_date, 'UPDATE', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `kumi_charges`
--
CREATE TABLE IF NOT EXISTS kumi_charges (
  id_charge int(11) NOT NULL AUTO_INCREMENT,
  id_account int(11) NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  input_tenancy decimal(12, 2) NOT NULL DEFAULT 0.00,
  input_penalty decimal(12, 2) NOT NULL DEFAULT 0.00,
  charge_tenancy decimal(12, 2) NOT NULL DEFAULT 0.00,
  charge_penalty decimal(12, 2) NOT NULL DEFAULT 0.00,
  payment_tenancy decimal(12, 2) NOT NULL DEFAULT 0.00,
  payment_penalty decimal(12, 2) NOT NULL DEFAULT 0.00,
  recalc_tenancy decimal(12, 2) NOT NULL DEFAULT 0.00,
  recalc_penalty decimal(12, 2) NOT NULL DEFAULT 0.00,
  correction_tenancy decimal(12, 2) NOT NULL DEFAULT 0.00,
  correction_penalty decimal(12, 2) NOT NULL DEFAULT 0.00,
  output_tenancy decimal(12, 2) NOT NULL DEFAULT 0.00,
  output_penalty decimal(12, 2) NOT NULL DEFAULT 0.00,
  input_dgi decimal(12, 2) NOT NULL DEFAULT 0.00,
  charge_dgi decimal(12, 2) NOT NULL DEFAULT 0.00,
  payment_dgi decimal(12, 2) NOT NULL DEFAULT 0.00,
  recalc_dgi decimal(12, 2) NOT NULL DEFAULT 0.00,
  correction_dgi decimal(12, 2) NOT NULL DEFAULT 0.00,
  output_dgi decimal(12, 2) NOT NULL DEFAULT 0.00,
  input_pkk decimal(12, 2) NOT NULL DEFAULT 0.00,
  charge_pkk decimal(12, 2) NOT NULL DEFAULT 0.00,
  payment_pkk decimal(12, 2) NOT NULL DEFAULT 0.00,
  recalc_pkk decimal(12, 2) NOT NULL DEFAULT 0.00,
  correction_pkk decimal(12, 2) NOT NULL DEFAULT 0.00,
  output_pkk decimal(12, 2) NOT NULL DEFAULT 0.00,
  input_padun decimal(12, 2) NOT NULL DEFAULT 0.00,
  charge_padun decimal(12, 2) NOT NULL DEFAULT 0.00,
  payment_padun decimal(12, 2) NOT NULL DEFAULT 0.00,
  recalc_padun decimal(12, 2) NOT NULL DEFAULT 0.00,
  correction_padun decimal(12, 2) NOT NULL DEFAULT 0.00,
  output_padun decimal(12, 2) NOT NULL DEFAULT 0.00,
  hidden tinyint(1) NOT NULL DEFAULT 0,
  is_bks_charge tinyint(1) NOT NULL DEFAULT 0,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_charge)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4223358,
AVG_ROW_LENGTH = 104,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IDX_kumi_charges` для объекта типа таблица `kumi_charges`
--
ALTER TABLE kumi_charges
ADD INDEX IDX_kumi_charges (id_account, end_date);

--
-- Создать индекс `IDX_kumi_charges_end_date` для объекта типа таблица `kumi_charges`
--
ALTER TABLE kumi_charges
ADD INDEX IDX_kumi_charges_end_date (end_date);

DELIMITER $$

--
-- Создать триггер `kumi_charges_after_insert`
--
CREATE TRIGGER kumi_charges_after_insert
AFTER INSERT
ON kumi_charges
FOR EACH ROW
BEGIN
  IF (NEW.id_charge IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'id_charge', NULL, NEW.id_charge, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'id_account', NULL, NEW.id_account, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.start_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'start_date', NULL, NEW.start_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.end_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'end_date', NULL, NEW.end_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.input_tenancy IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'input_tenancy', NULL, NEW.input_tenancy, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.input_penalty IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'input_penalty', NULL, NEW.input_penalty, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.charge_tenancy IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'charge_tenancy', NULL, NEW.charge_tenancy, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.charge_penalty IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'charge_penalty', NULL, NEW.charge_penalty, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payment_tenancy IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'payment_tenancy', NULL, NEW.payment_tenancy, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payment_penalty IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'payment_penalty', NULL, NEW.payment_penalty, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recalc_tenancy IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'recalc_tenancy', NULL, NEW.recalc_tenancy, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recalc_penalty IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'recalc_penalty', NULL, NEW.recalc_penalty, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.output_tenancy IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'output_tenancy', NULL, NEW.output_tenancy, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.output_penalty IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'output_penalty', NULL, NEW.output_penalty, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.input_dgi IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'input_dgi', NULL, NEW.input_dgi, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.charge_dgi IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'charge_dgi', NULL, NEW.charge_dgi, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payment_dgi IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'payment_dgi', NULL, NEW.payment_dgi, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recalc_dgi IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'recalc_dgi', NULL, NEW.recalc_dgi, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.correction_dgi IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'correction_dgi', NULL, NEW.correction_dgi, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.output_dgi IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'output_dgi', NULL, NEW.output_dgi, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.input_pkk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'input_pkk', NULL, NEW.input_pkk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.charge_pkk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'charge_pkk', NULL, NEW.charge_pkk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payment_pkk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'payment_pkk', NULL, NEW.payment_pkk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recalc_pkk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'recalc_pkk', NULL, NEW.recalc_pkk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.correction_pkk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'correction_pkk', NULL, NEW.correction_pkk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.output_pkk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'output_pkk', NULL, NEW.output_pkk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.input_padun IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'input_padun', NULL, NEW.input_padun, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.charge_padun IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'charge_padun', NULL, NEW.charge_padun, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payment_padun IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'payment_padun', NULL, NEW.payment_padun, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recalc_padun IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'recalc_padun', NULL, NEW.recalc_padun, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.correction_padun IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'correction_padun', NULL, NEW.correction_padun, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.output_padun IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'output_padun', NULL, NEW.output_padun, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.hidden IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'hidden', NULL, NEW.hidden, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_bks_charge IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'is_bks_charge', NULL, NEW.is_bks_charge, 'INSERT', NOW(), USER());
  END IF;

  -- Генерируем УИН
  INSERT INTO kumi_charges_gis_gmp (id_charge, uin, upload_date)
    SELECT
      NEW.id_charge,
      CONCAT(v.uin, IF(v.cp1 % 11 < 10, v.cp1 % 11, IF(v.cp2 % 11 < 10, v.cp2 % 11, 0))) AS uin,
      NULL
    FROM (SELECT
        SUBSTRING(v.uin, 1, 1) * 1 +
        SUBSTRING(v.uin, 2, 1) * 2 +
        SUBSTRING(v.uin, 3, 1) * 3 +
        SUBSTRING(v.uin, 4, 1) * 4 +
        SUBSTRING(v.uin, 5, 1) * 5 +
        SUBSTRING(v.uin, 6, 1) * 6 +
        SUBSTRING(v.uin, 7, 1) * 7 +
        SUBSTRING(v.uin, 8, 1) * 8 +
        SUBSTRING(v.uin, 9, 1) * 9 +
        SUBSTRING(v.uin, 10, 1) * 10 +
        SUBSTRING(v.uin, 11, 1) * 1 +
        SUBSTRING(v.uin, 12, 1) * 2 +
        SUBSTRING(v.uin, 13, 1) * 3 +
        SUBSTRING(v.uin, 14, 1) * 4 +
        SUBSTRING(v.uin, 15, 1) * 5 +
        SUBSTRING(v.uin, 16, 1) * 6 +
        SUBSTRING(v.uin, 17, 1) * 7 +
        SUBSTRING(v.uin, 18, 1) * 8 +
        SUBSTRING(v.uin, 19, 1) * 9 +
        SUBSTRING(v.uin, 20, 1) * 10 +
        SUBSTRING(v.uin, 21, 1) * 1 +
        SUBSTRING(v.uin, 22, 1) * 2 +
        SUBSTRING(v.uin, 23, 1) * 3 +
        SUBSTRING(v.uin, 24, 1) * 4 AS cp1,
        SUBSTRING(v.uin, 1, 1) * 3 +
        SUBSTRING(v.uin, 2, 1) * 4 +
        SUBSTRING(v.uin, 3, 1) * 5 +
        SUBSTRING(v.uin, 4, 1) * 6 +
        SUBSTRING(v.uin, 5, 1) * 7 +
        SUBSTRING(v.uin, 6, 1) * 8 +
        SUBSTRING(v.uin, 7, 1) * 9 +
        SUBSTRING(v.uin, 8, 1) * 10 +
        SUBSTRING(v.uin, 9, 1) * 1 +
        SUBSTRING(v.uin, 10, 1) * 2 +
        SUBSTRING(v.uin, 11, 1) * 3 +
        SUBSTRING(v.uin, 12, 1) * 4 +
        SUBSTRING(v.uin, 13, 1) * 5 +
        SUBSTRING(v.uin, 14, 1) * 6 +
        SUBSTRING(v.uin, 15, 1) * 7 +
        SUBSTRING(v.uin, 16, 1) * 8 +
        SUBSTRING(v.uin, 17, 1) * 9 +
        SUBSTRING(v.uin, 18, 1) * 10 +
        SUBSTRING(v.uin, 19, 1) * 1 +
        SUBSTRING(v.uin, 20, 1) * 2 +
        SUBSTRING(v.uin, 21, 1) * 3 +
        SUBSTRING(v.uin, 22, 1) * 4 +
        SUBSTRING(v.uin, 23, 1) * 5 +
        SUBSTRING(v.uin, 24, 1) * 6 AS cp2,
        v.uin
      FROM (SELECT
          CONCAT(LPAD(CONV("0025e7", 16, 10), 8, "0"),
          LPAD(NEW.id_charge, 10, "0"),
          LPAD(UNIX_TIMESTAMP() % POW(10, 6), 6, "0")) AS uin) v) v;
END
$$

--
-- Создать триггер `kumi_charges_after_update`
--
CREATE TRIGGER kumi_charges_after_update
AFTER UPDATE
ON kumi_charges
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges', NEW.id_charge, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_account <> OLD.id_account) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'id_account', OLD.id_account, NEW.id_account, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.start_date <> OLD.start_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'start_date', OLD.start_date, NEW.start_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.end_date <> OLD.end_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'end_date', OLD.end_date, NEW.end_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.input_tenancy <> OLD.input_tenancy) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'input_tenancy', OLD.input_tenancy, NEW.input_tenancy, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.input_penalty <> OLD.input_penalty) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'input_penalty', OLD.input_penalty, NEW.input_penalty, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.charge_tenancy <> OLD.charge_tenancy) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'charge_tenancy', OLD.charge_tenancy, NEW.charge_tenancy, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.charge_penalty <> OLD.charge_penalty) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'charge_penalty', OLD.charge_penalty, NEW.charge_penalty, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.payment_tenancy <> OLD.payment_tenancy) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'payment_tenancy', OLD.payment_tenancy, NEW.payment_tenancy, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.payment_penalty <> OLD.payment_penalty) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'payment_penalty', OLD.payment_penalty, NEW.payment_penalty, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.recalc_tenancy <> OLD.recalc_tenancy) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'recalc_tenancy', OLD.recalc_tenancy, NEW.recalc_tenancy, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.recalc_penalty <> OLD.recalc_penalty) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'recalc_penalty', OLD.recalc_penalty, NEW.recalc_penalty, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.output_tenancy <> OLD.output_tenancy) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'output_tenancy', OLD.output_tenancy, NEW.output_tenancy, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.output_penalty <> OLD.output_penalty) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'output_penalty', OLD.output_penalty, NEW.output_penalty, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.input_dgi <> OLD.input_dgi) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'input_dgi', OLD.input_dgi, NEW.input_dgi, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.charge_dgi <> OLD.charge_dgi) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'charge_dgi', OLD.charge_dgi, NEW.charge_dgi, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.payment_dgi <> OLD.payment_dgi) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'payment_dgi', OLD.payment_dgi, NEW.payment_dgi, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.recalc_dgi <> OLD.recalc_dgi) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'recalc_dgi', OLD.recalc_dgi, NEW.recalc_dgi, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.correction_dgi <> OLD.correction_dgi) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'correction_dgi', OLD.correction_dgi, NEW.correction_dgi, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.output_dgi <> OLD.output_dgi) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'output_dgi', OLD.output_dgi, NEW.output_dgi, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.input_pkk <> OLD.input_pkk) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'input_pkk', OLD.input_pkk, NEW.input_pkk, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.charge_pkk <> OLD.charge_pkk) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'charge_pkk', OLD.charge_pkk, NEW.charge_pkk, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.payment_pkk <> OLD.payment_pkk) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'payment_pkk', OLD.payment_pkk, NEW.payment_pkk, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.recalc_pkk <> OLD.recalc_pkk) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'recalc_pkk', OLD.recalc_pkk, NEW.recalc_pkk, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.correction_pkk <> OLD.correction_pkk) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'correction_pkk', OLD.correction_pkk, NEW.correction_pkk, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.output_pkk <> OLD.output_pkk) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'output_pkk', OLD.output_pkk, NEW.output_pkk, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.input_padun <> OLD.input_padun) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'input_padun', OLD.input_padun, NEW.input_padun, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.charge_padun <> OLD.charge_padun) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'charge_padun', OLD.charge_padun, NEW.charge_padun, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.payment_padun <> OLD.payment_padun) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'payment_padun', OLD.payment_padun, NEW.payment_padun, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.recalc_padun <> OLD.recalc_padun) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'recalc_padun', OLD.recalc_padun, NEW.recalc_padun, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.correction_padun <> OLD.correction_padun) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'correction_padun', OLD.correction_padun, NEW.correction_padun, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.output_padun <> OLD.output_padun) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'output_padun', OLD.output_padun, NEW.output_padun, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.hidden <> OLD.hidden) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'hidden', OLD.hidden, NEW.hidden, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.is_bks_charge <> OLD.is_bks_charge) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_charges', NEW.id_charge, 'is_bks_charge', OLD.is_bks_charge, NEW.is_bks_charge, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_charges_gis_gmp
ADD CONSTRAINT FK_kumi_charges_gis_gmp_id_cha FOREIGN KEY (id_charge)
REFERENCES kumi_charges (id_charge) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `judges_buildings_assoc`
--
CREATE TABLE IF NOT EXISTS judges_buildings_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_judge int(11) NOT NULL,
  id_building int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3814,
AVG_ROW_LENGTH = 44,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'территориальная подсудность для судебных участков';

DELIMITER $$

--
-- Создать триггер `judges_buildings_assoc_after_insert`
--
CREATE TRIGGER judges_buildings_assoc_after_insert
AFTER INSERT
ON judges_buildings_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_judge IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'judges_buildings_assoc', NEW.id_assoc, 'id_judge', NULL, NEW.id_judge, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_building IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'judges_buildings_assoc', NEW.id_assoc, 'id_building', NULL, NEW.id_building, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `judges_buildings_assoc_after_update`
--
CREATE TRIGGER judges_buildings_assoc_after_update
AFTER UPDATE
ON judges_buildings_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'judges_buildings_assoc', NEW.id_assoc, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_judge <> OLD.id_judge) THEN
      INSERT INTO `log`
        VALUES (NULL, 'judges_buildings_assoc', NEW.id_assoc, 'id_judge', OLD.id_judge, NEW.id_judge, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_building <> OLD.id_building) THEN
      INSERT INTO `log`
        VALUES (NULL, 'judges_buildings_assoc', NEW.id_assoc, 'id_building', OLD.id_building, NEW.id_building, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `judges`
--
CREATE TABLE IF NOT EXISTS judges (
  id_judge int(11) NOT NULL AUTO_INCREMENT,
  num_district int(11) NOT NULL COMMENT 'номер судебного участка',
  snp varchar(512) DEFAULT NULL,
  addr_district varchar(255) DEFAULT NULL COMMENT 'адрес судебного участка',
  region varchar(255) DEFAULT NULL,
  phone_district varchar(255) DEFAULT NULL COMMENT 'номер телефона судебного участка',
  is_inactive tinyint(1) NOT NULL DEFAULT 1,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_judge)
)
ENGINE = INNODB,
AUTO_INCREMENT = 15,
AVG_ROW_LENGTH = 1170,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Список мировых судей для Исковой работы';

DELIMITER $$

--
-- Создать триггер `judges_after_insert`
--
CREATE TRIGGER judges_after_insert
AFTER INSERT
ON judges
FOR EACH ROW
BEGIN
  IF (NEW.num_district IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'judges', NEW.id_judge, 'num_district', NULL, NEW.num_district, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.snp IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'judges', NEW.id_judge, 'snp', NULL, NEW.snp, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.addr_district IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'judges', NEW.id_judge, 'addr_district', NULL, NEW.addr_district, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.region IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'judges', NEW.id_judge, 'region', NULL, NEW.region, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.phone_district IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'judges', NEW.id_judge, 'phone_district', NULL, NEW.phone_district, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_inactive IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'judges', NEW.id_judge, 'is_inactive', NULL, NEW.is_inactive, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `judges_after_update`
--
CREATE TRIGGER judges_after_update
AFTER UPDATE
ON judges
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'judges', NEW.id_judge, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.num_district <> OLD.num_district) THEN
      INSERT INTO `log`
        VALUES (NULL, 'judges', NEW.id_judge, 'num_district', OLD.num_district, NEW.num_district, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.snp <> OLD.snp) THEN
      INSERT INTO `log`
        VALUES (NULL, 'judges', NEW.id_judge, 'snp', OLD.snp, NEW.snp, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.addr_district IS NULL
      AND OLD.addr_district IS NULL)
      AND ((NEW.addr_district IS NULL
      AND OLD.addr_district IS NOT NULL)
      OR (NEW.addr_district IS NOT NULL
      AND OLD.addr_district IS NULL)
      OR (NEW.addr_district <> OLD.addr_district))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'judges', NEW.id_judge, 'addr_district', OLD.addr_district, NEW.addr_district, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.region IS NULL
      AND OLD.region IS NULL)
      AND ((NEW.region IS NULL
      AND OLD.region IS NOT NULL)
      OR (NEW.region IS NOT NULL
      AND OLD.region IS NULL)
      OR (NEW.region <> OLD.region))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'judges', NEW.id_judge, 'region', OLD.region, NEW.region, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.phone_district IS NULL
      AND OLD.phone_district IS NULL)
      AND ((NEW.phone_district IS NULL
      AND OLD.phone_district IS NOT NULL)
      OR (NEW.phone_district IS NOT NULL
      AND OLD.phone_district IS NULL)
      OR (NEW.phone_district <> OLD.phone_district))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'judges', NEW.id_judge, 'phone_district', OLD.phone_district, NEW.phone_district, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.is_inactive <> OLD.is_inactive) THEN
      INSERT INTO `log`
        VALUES (NULL, 'judges', NEW.id_judge, 'is_inactive', OLD.is_inactive, NEW.is_inactive, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `judges_before_update`
--
CREATE TRIGGER judges_before_update
BEFORE UPDATE
ON judges
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    UPDATE judges_buildings_assoc
    SET deleted = 1
    WHERE id_judge = NEW.id_judge;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE judges_buildings_assoc
ADD CONSTRAINT FK_judges_buildings_assoc_id_j FOREIGN KEY (id_judge)
REFERENCES judges (id_judge) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `history_sign_doc_snp_templates`
--
CREATE TABLE IF NOT EXISTS history_sign_doc_snp_templates (
  id_snp_template int(11) NOT NULL AUTO_INCREMENT,
  snp_template varchar(255) NOT NULL,
  start_date date NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_snp_template)
)
ENGINE = INNODB,
AUTO_INCREMENT = 9,
AVG_ROW_LENGTH = 2340,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Направление инициалов в подписываемых документах';

DELIMITER $$

--
-- Создать триггер `history_sign_doc_snp_templates_after_insert`
--
CREATE TRIGGER history_sign_doc_snp_templates_after_insert
AFTER INSERT
ON history_sign_doc_snp_templates
FOR EACH ROW
BEGIN
  IF (NEW.snp_template IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_sign_doc_snp_templates', NEW.id_snp_template, 'snp_template', NULL, NEW.snp_template, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.start_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_sign_doc_snp_templates', NEW.id_snp_template, 'start_date', NULL, NEW.start_date, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `history_sign_doc_snp_templates_after_update`
--
CREATE TRIGGER history_sign_doc_snp_templates_after_update
AFTER UPDATE
ON history_sign_doc_snp_templates
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_sign_doc_snp_templates', NEW.id_snp_template, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.snp_template <> OLD.snp_template) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_sign_doc_snp_templates', NEW.id_snp_template, 'snp_template', OLD.snp_template, NEW.snp_template, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.start_date <> OLD.start_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_sign_doc_snp_templates', NEW.id_snp_template, 'start_date', OLD.start_date, NEW.start_date, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `history_head_legal_dep`
--
CREATE TABLE IF NOT EXISTS history_head_legal_dep (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  surname varchar(50) NOT NULL,
  name varchar(50) NOT NULL,
  patronymic varchar(255) DEFAULT NULL,
  post varchar(255) NOT NULL,
  start_date date NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 16384,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `history_head_legal_dep_after_insert`
--
CREATE TRIGGER history_head_legal_dep_after_insert
AFTER INSERT
ON history_head_legal_dep
FOR EACH ROW
BEGIN
  IF (NEW.surname IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_head_legal_dep', NEW.id_record, 'surname', NULL, NEW.surname, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_head_legal_dep', NEW.id_record, 'name', NULL, NEW.name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.patronymic IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_head_legal_dep', NEW.id_record, 'patronymic', NULL, NEW.patronymic, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.post IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_head_legal_dep', NEW.id_record, 'post', NULL, NEW.post, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.start_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_head_legal_dep', NEW.id_record, 'start_date', NULL, NEW.start_date, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `history_head_legal_dep_after_update`
--
CREATE TRIGGER history_head_legal_dep_after_update
AFTER UPDATE
ON history_head_legal_dep
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_head_legal_dep', NEW.id_record, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.surname <> OLD.surname) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_head_legal_dep', NEW.id_record, 'surname', OLD.surname, NEW.surname, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.name <> OLD.name) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_head_legal_dep', NEW.id_record, 'name', OLD.name, NEW.name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.patronymic IS NULL
      AND OLD.patronymic IS NULL)
      AND ((NEW.patronymic IS NULL
      AND OLD.patronymic IS NOT NULL)
      OR (NEW.patronymic IS NOT NULL
      AND OLD.patronymic IS NULL)
      OR (NEW.patronymic <> OLD.patronymic))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_head_legal_dep', NEW.id_record, 'patronymic', OLD.patronymic, NEW.patronymic, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.post <> OLD.post) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_head_legal_dep', NEW.id_record, 'post', OLD.post, NEW.post, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.start_date <> OLD.start_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_head_legal_dep', NEW.id_record, 'start_date', OLD.start_date, NEW.start_date, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `history_head_housing_dep`
--
CREATE TABLE IF NOT EXISTS history_head_housing_dep (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  surname varchar(50) NOT NULL,
  name varchar(50) NOT NULL,
  patronymic varchar(255) DEFAULT NULL,
  post varchar(255) NOT NULL,
  start_date date NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 16384,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'deprecated table';

DELIMITER $$

--
-- Создать триггер `history_head_housing_dep_after_insert`
--
CREATE TRIGGER history_head_housing_dep_after_insert
AFTER INSERT
ON history_head_housing_dep
FOR EACH ROW
BEGIN
  IF (NEW.surname IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_head_housing_dep', NEW.id_record, 'surname', NULL, NEW.surname, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_head_housing_dep', NEW.id_record, 'name', NULL, NEW.name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.patronymic IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_head_housing_dep', NEW.id_record, 'patronymic', NULL, NEW.patronymic, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.post IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_head_housing_dep', NEW.id_record, 'post', NULL, NEW.post, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.start_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_head_housing_dep', NEW.id_record, 'start_date', NULL, NEW.start_date, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `history_head_housing_dep_after_update`
--
CREATE TRIGGER history_head_housing_dep_after_update
AFTER UPDATE
ON history_head_housing_dep
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_head_housing_dep', NEW.id_record, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.surname <> OLD.surname) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_head_housing_dep', NEW.id_record, 'surname', OLD.surname, NEW.surname, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.name <> OLD.name) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_head_housing_dep', NEW.id_record, 'name', OLD.name, NEW.name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.patronymic IS NULL
      AND OLD.patronymic IS NULL)
      AND ((NEW.patronymic IS NULL
      AND OLD.patronymic IS NOT NULL)
      OR (NEW.patronymic IS NOT NULL
      AND OLD.patronymic IS NULL)
      OR (NEW.patronymic <> OLD.patronymic))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_head_housing_dep', NEW.id_record, 'patronymic', OLD.patronymic, NEW.patronymic, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.post <> OLD.post) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_head_housing_dep', NEW.id_record, 'post', OLD.post, NEW.post, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.start_date <> OLD.start_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_head_housing_dep', NEW.id_record, 'start_date', OLD.start_date, NEW.start_date, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `history_committee_names`
--
CREATE TABLE IF NOT EXISTS history_committee_names (
  id_committee_name int(11) NOT NULL AUTO_INCREMENT,
  committee_name text NOT NULL,
  start_date date NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_committee_name)
)
ENGINE = INNODB,
AUTO_INCREMENT = 8,
AVG_ROW_LENGTH = 2730,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `history_committee_names_after_insert`
--
CREATE TRIGGER history_committee_names_after_insert
AFTER INSERT
ON history_committee_names
FOR EACH ROW
BEGIN
  IF (NEW.committee_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_committee_names', NEW.id_committee_name, 'committee_name', NULL, NEW.committee_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.start_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_committee_names', NEW.id_committee_name, 'start_date', NULL, NEW.start_date, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `history_committee_names_after_update`
--
CREATE TRIGGER history_committee_names_after_update
AFTER UPDATE
ON history_committee_names
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_committee_names', NEW.id_committee_name, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.committee_name <> OLD.committee_name) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_committee_names', NEW.id_committee_name, 'committee_name', OLD.committee_name, NEW.committee_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.start_date <> OLD.start_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_committee_names', NEW.id_committee_name, 'start_date', OLD.start_date, NEW.start_date, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `funds_sub_premises_assoc`
--
CREATE TABLE IF NOT EXISTS funds_sub_premises_assoc (
  id_sub_premises int(11) NOT NULL,
  id_fund int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_fund, id_sub_premises)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 81,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `funds_sub_premises_assoc`
--
CREATE TRIGGER funds_sub_premises_assoc
AFTER UPDATE
ON funds_sub_premises_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_sub_premises_assoc', NEW.id_fund, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `funds_sub_premises_assoc_after_insert`
--
CREATE TRIGGER funds_sub_premises_assoc_after_insert
AFTER INSERT
ON funds_sub_premises_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_sub_premises IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_sub_premises_assoc', NEW.id_fund, 'id_sub_premises', NULL, NEW.id_sub_premises, 'INSERT', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `funds_premises_assoc`
--
CREATE TABLE IF NOT EXISTS funds_premises_assoc (
  id_premises int(11) NOT NULL,
  id_fund int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_premises, id_fund)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 64,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `funds_premises_assoc_after_insert`
--
CREATE TRIGGER funds_premises_assoc_after_insert
AFTER INSERT
ON funds_premises_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_premises IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_premises_assoc', NEW.id_fund, 'id_premises', NULL, NEW.id_premises, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `funds_premises_assoc_after_update`
--
CREATE TRIGGER funds_premises_assoc_after_update
AFTER UPDATE
ON funds_premises_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_premises_assoc', NEW.id_fund, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `funds_buildings_assoc`
--
CREATE TABLE IF NOT EXISTS funds_buildings_assoc (
  id_building int(11) NOT NULL COMMENT 'Индекс объекта',
  id_fund int(11) NOT NULL COMMENT 'Индекс жилого фонда',
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_building, id_fund)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 2730,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `funds_buildings_assoc_after_insert`
--
CREATE TRIGGER funds_buildings_assoc_after_insert
AFTER INSERT
ON funds_buildings_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_building IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_buildings_assoc', NEW.id_fund, 'id_building', NULL, NEW.id_building, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `funds_buildings_assoc_after_update`
--
CREATE TRIGGER funds_buildings_assoc_after_update
AFTER UPDATE
ON funds_buildings_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_buildings_assoc', NEW.id_fund, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `claim_state_types_relations`
--
CREATE TABLE IF NOT EXISTS claim_state_types_relations (
  id_relation int(11) NOT NULL AUTO_INCREMENT,
  id_state_from int(11) NOT NULL,
  id_state_to int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_relation)
)
ENGINE = INNODB,
AUTO_INCREMENT = 23,
AVG_ROW_LENGTH = 1489,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `claim_state_types_relations_after_insert`
--
CREATE TRIGGER claim_state_types_relations_after_insert
AFTER INSERT
ON claim_state_types_relations
FOR EACH ROW
BEGIN
  IF (NEW.id_state_from IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_types_relations', NEW.id_relation, 'id_state_from', NULL, NEW.id_state_from, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_state_to IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_types_relations', NEW.id_relation, 'id_state_to', NULL, NEW.id_state_to, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `claim_state_types_relations_after_update`
--
CREATE TRIGGER claim_state_types_relations_after_update
AFTER UPDATE
ON claim_state_types_relations
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_types_relations', NEW.id_relation, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_state_from <> OLD.id_state_from) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_state_types_relations', NEW.id_relation, 'id_state_from', OLD.id_state_from, NEW.id_state_from, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_state_to <> OLD.id_state_to) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_state_types_relations', NEW.id_relation, 'id_state_to', OLD.id_state_to, NEW.id_state_to, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `claim_persons`
--
CREATE TABLE IF NOT EXISTS claim_persons (
  id_person int(11) NOT NULL AUTO_INCREMENT,
  id_claim int(11) NOT NULL,
  surname varchar(50) DEFAULT NULL,
  name varchar(50) DEFAULT NULL,
  patronymic varchar(255) DEFAULT NULL,
  date_of_birth date DEFAULT NULL,
  place_of_birth varchar(1024) DEFAULT NULL,
  passport varchar(1024) DEFAULT NULL,
  work_place varchar(1024) DEFAULT NULL,
  is_claimer tinyint(1) NOT NULL DEFAULT 0,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_person)
)
ENGINE = INNODB,
AUTO_INCREMENT = 15351,
AVG_ROW_LENGTH = 187,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `claim_persons_after_insert`
--
CREATE TRIGGER claim_persons_after_insert
AFTER INSERT
ON claim_persons
FOR EACH ROW
BEGIN
  IF (NEW.id_claim IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_persons', NEW.id_person, 'id_claim', NULL, NEW.id_claim, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.surname IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_persons', NEW.id_person, 'surname', NULL, NEW.surname, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_persons', NEW.id_person, 'name', NULL, NEW.name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.patronymic IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_persons', NEW.id_person, 'patronymic', NULL, NEW.patronymic, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_of_birth IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_persons', NEW.id_person, 'date_of_birth', NULL, NEW.date_of_birth, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.place_of_birth IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_persons', NEW.id_person, 'place_of_birth', NULL, NEW.place_of_birth, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.passport IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_persons', NEW.id_person, 'passport', NULL, NEW.passport, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.work_place IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_persons', NEW.id_person, 'work_place', NULL, NEW.work_place, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_claimer IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_persons', NEW.id_person, 'is_claimer', NULL, NEW.is_claimer, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `claim_persons_after_update`
--
CREATE TRIGGER claim_persons_after_update
AFTER UPDATE
ON claim_persons
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_persons', NEW.id_person, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_claim <> OLD.id_claim) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_persons', NEW.id_person, 'id_claim', OLD.id_claim, NEW.id_claim, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.surname IS NULL
      AND OLD.surname IS NULL)
      AND ((NEW.surname IS NULL
      AND OLD.surname IS NOT NULL)
      OR (NEW.surname IS NOT NULL
      AND OLD.surname IS NULL)
      OR (NEW.surname <> OLD.surname))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_persons', NEW.id_person, 'surname', OLD.surname, NEW.surname, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.name IS NULL
      AND OLD.name IS NULL)
      AND ((NEW.name IS NULL
      AND OLD.name IS NOT NULL)
      OR (NEW.name IS NOT NULL
      AND OLD.name IS NULL)
      OR (NEW.name <> OLD.name))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_persons', NEW.id_person, 'name', OLD.name, NEW.name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.patronymic IS NULL
      AND OLD.patronymic IS NULL)
      AND ((NEW.patronymic IS NULL
      AND OLD.patronymic IS NOT NULL)
      OR (NEW.patronymic IS NOT NULL
      AND OLD.patronymic IS NULL)
      OR (NEW.patronymic <> OLD.patronymic))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_persons', NEW.id_person, 'patronymic', OLD.patronymic, NEW.patronymic, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_of_birth IS NULL
      AND OLD.date_of_birth IS NULL)
      AND ((NEW.date_of_birth IS NULL
      AND OLD.date_of_birth IS NOT NULL)
      OR (NEW.date_of_birth IS NOT NULL
      AND OLD.date_of_birth IS NULL)
      OR (NEW.date_of_birth <> OLD.date_of_birth))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_persons', NEW.id_person, 'date_of_birth', OLD.date_of_birth, NEW.date_of_birth, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.place_of_birth IS NULL
      AND OLD.place_of_birth IS NULL)
      AND ((NEW.place_of_birth IS NULL
      AND OLD.place_of_birth IS NOT NULL)
      OR (NEW.place_of_birth IS NOT NULL
      AND OLD.place_of_birth IS NULL)
      OR (NEW.place_of_birth <> OLD.place_of_birth))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_persons', NEW.id_person, 'place_of_birth', OLD.place_of_birth, NEW.place_of_birth, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.passport IS NULL
      AND OLD.passport IS NULL)
      AND ((NEW.passport IS NULL
      AND OLD.passport IS NOT NULL)
      OR (NEW.passport IS NOT NULL
      AND OLD.passport IS NULL)
      OR (NEW.passport <> OLD.passport))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_persons', NEW.id_person, 'passport', OLD.passport, NEW.passport, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.work_place IS NULL
      AND OLD.work_place IS NULL)
      AND ((NEW.work_place IS NULL
      AND OLD.work_place IS NOT NULL)
      OR (NEW.work_place IS NOT NULL
      AND OLD.work_place IS NULL)
      OR (NEW.work_place <> OLD.work_place))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_persons', NEW.id_person, 'work_place', OLD.work_place, NEW.work_place, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.is_claimer IS NULL
      AND OLD.is_claimer IS NULL)
      AND ((NEW.is_claimer IS NULL
      AND OLD.is_claimer IS NOT NULL)
      OR (NEW.is_claimer IS NOT NULL
      AND OLD.is_claimer IS NULL)
      OR (NEW.is_claimer <> OLD.is_claimer))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_persons', NEW.id_person, 'is_claimer', OLD.is_claimer, NEW.is_claimer, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать представление `v_claim_claimers`
--
CREATE
VIEW v_claim_claimers
AS
SELECT
  `cp`.`id_claim` AS `id_claim`,
  TRIM(CONCAT(`cp`.`surname`, ' ', `cp`.`name`, ' ', IFNULL(`cp`.`patronymic`, ''))) AS `snp`
FROM `claim_persons` `cp`
WHERE (`cp`.`is_claimer` = 1)
GROUP BY `cp`.`id_claim`;

--
-- Создать таблицу `chairman_warrants`
--
CREATE TABLE IF NOT EXISTS chairman_warrants (
  id_chairman_warrant int(11) NOT NULL AUTO_INCREMENT,
  chairman_warrant text NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_chairman_warrant)
)
ENGINE = INNODB,
AUTO_INCREMENT = 83,
AVG_ROW_LENGTH = 399,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `chairman_warrants_after_insert`
--
CREATE TRIGGER chairman_warrants_after_insert
AFTER INSERT
ON chairman_warrants
FOR EACH ROW
BEGIN
  IF (NEW.chairman_warrant IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'chairman_warrants', NEW.id_chairman_warrant, 'chairman_warrant', NULL, NEW.chairman_warrant, 'INSERT', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `history_chairmans`
--
CREATE TABLE IF NOT EXISTS history_chairmans (
  id_chairman int(11) NOT NULL AUTO_INCREMENT,
  id_chairman_warrant int(11) DEFAULT NULL,
  surname varchar(50) NOT NULL,
  name varchar(50) NOT NULL,
  patronymic varchar(255) DEFAULT NULL,
  post varchar(50) NOT NULL,
  post_genetive varchar(255) DEFAULT NULL,
  start_date date NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_chairman)
)
ENGINE = INNODB,
AUTO_INCREMENT = 155,
AVG_ROW_LENGTH = 204,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `history_chairmans_after_insert`
--
CREATE TRIGGER history_chairmans_after_insert
AFTER INSERT
ON history_chairmans
FOR EACH ROW
BEGIN
  IF (NEW.id_chairman_warrant IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'id_chairman_warrant', NULL, NEW.id_chairman_warrant, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.surname IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'surname', NULL, NEW.surname, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'name', NULL, NEW.name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.patronymic IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'patronymic', NULL, NEW.patronymic, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.post IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'post', NULL, NEW.post, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.post_genetive IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'post_genetive', NULL, NEW.post_genetive, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.start_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'start_date', NULL, NEW.start_date, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `history_chairmans_after_update`
--
CREATE TRIGGER history_chairmans_after_update
AFTER UPDATE
ON history_chairmans
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NOT (NEW.id_chairman_warrant IS NULL
      AND OLD.id_chairman_warrant IS NULL)
      AND ((NEW.id_chairman_warrant IS NULL
      AND OLD.id_chairman_warrant IS NOT NULL)
      OR (NEW.id_chairman_warrant IS NOT NULL
      AND OLD.id_chairman_warrant IS NULL)
      OR (NEW.id_chairman_warrant <> OLD.id_chairman_warrant))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'id_chairman_warrant', OLD.id_chairman_warrant, NEW.id_chairman_warrant, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.surname <> OLD.surname) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'surname', OLD.surname, NEW.surname, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.name <> OLD.name) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'name', OLD.name, NEW.name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.patronymic IS NULL
      AND OLD.patronymic IS NULL)
      AND ((NEW.patronymic IS NULL
      AND OLD.patronymic IS NOT NULL)
      OR (NEW.patronymic IS NOT NULL
      AND OLD.patronymic IS NULL)
      OR (NEW.patronymic <> OLD.patronymic))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'patronymic', OLD.patronymic, NEW.patronymic, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.post <> OLD.post) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'post', OLD.post, NEW.post, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.post_genetive IS NULL
      AND OLD.post_genetive IS NULL)
      AND ((NEW.post_genetive IS NULL
      AND OLD.post_genetive IS NOT NULL)
      OR (NEW.post_genetive IS NOT NULL
      AND OLD.post_genetive IS NULL)
      OR (NEW.post_genetive <> OLD.post_genetive))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'post_genetive', OLD.post_genetive, NEW.post_genetive, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.start_date <> OLD.start_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'history_chairmans', NEW.id_chairman, 'start_date', OLD.start_date, NEW.start_date, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE history_chairmans
ADD CONSTRAINT FK_history_chairmans_chairman_warrants_id_chairman_warrant FOREIGN KEY (id_chairman_warrant)
REFERENCES chairman_warrants (id_chairman_warrant) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `building_demolition_act_files`
--
CREATE TABLE IF NOT EXISTS building_demolition_act_files (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_building int(11) NOT NULL,
  id_act_file int(11) DEFAULT NULL,
  id_act_type_document int(11) NOT NULL,
  number varchar(50) DEFAULT NULL,
  date date DEFAULT NULL,
  name varchar(50) DEFAULT NULL,
  deleted tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `building_demolition_act_files_after_insert`
--
CREATE TRIGGER building_demolition_act_files_after_insert
AFTER INSERT
ON building_demolition_act_files
FOR EACH ROW
BEGIN
  IF (NEW.id_building IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'building_demolition_act_files', NEW.id, 'id_building', NULL, NEW.id_building, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_act_file IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'building_demolition_act_files', NEW.id, 'id_act_file', NULL, NEW.id_act_file, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_act_type_document IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'building_demolition_act_files', NEW.id, 'id_act_type_document', NULL, NEW.id_act_type_document, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.`number` IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'building_demolition_act_files', NEW.id, 'number', NULL, NEW.`number`, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.`date` IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'building_demolition_act_files', NEW.id, 'date', NULL, NEW.`date`, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.`name` IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'building_demolition_act_files', NEW.id, 'name', NULL, NEW.`name`, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `building_demolition_act_files_after_update`
--
CREATE TRIGGER building_demolition_act_files_after_update
AFTER UPDATE
ON building_demolition_act_files
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'building_demolition_act_files', NEW.id, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_building <> OLD.id_building) THEN
      INSERT INTO `log`
        VALUES (NULL, 'building_demolition_act_files', NEW.id, 'id_building', OLD.id_building, NEW.id_building, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_act_file IS NULL
      AND OLD.id_act_file IS NULL)
      AND ((NEW.id_act_file IS NULL
      AND OLD.id_act_file IS NOT NULL)
      OR (NEW.id_act_file IS NOT NULL
      AND OLD.id_act_file IS NULL)
      OR (NEW.id_act_file <> OLD.id_act_file))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'building_demolition_act_files', NEW.id, 'id_act_file', OLD.id_act_file, NEW.id_act_file, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_act_type_document <> OLD.id_act_type_document) THEN
      INSERT INTO `log`
        VALUES (NULL, 'building_demolition_act_files', NEW.id, 'id_act_type_document', OLD.id_act_type_document, NEW.id_act_type_document, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.`number` IS NULL
      AND OLD.`number` IS NULL)
      AND ((NEW.`number` IS NULL
      AND OLD.`number` IS NOT NULL)
      OR (NEW.`number` IS NOT NULL
      AND OLD.`number` IS NULL)
      OR (NEW.`number` <> OLD.`number`))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'building_demolition_act_files', NEW.id, 'number', OLD.`number`, NEW.`number`, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.`date` <> OLD.`date`) THEN
      INSERT INTO `log`
        VALUES (NULL, 'building_demolition_act_files', NEW.id, 'date', OLD.`date`, NEW.`date`, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.`name` IS NULL
      AND OLD.`name` IS NULL)
      AND ((NEW.`name` IS NULL
      AND OLD.`name` IS NOT NULL)
      OR (NEW.`name` IS NOT NULL
      AND OLD.`name` IS NULL)
      OR (NEW.`name` <> OLD.`name`))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'building_demolition_act_files', NEW.id, 'name', OLD.`name`, NEW.`name`, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `building_attachment_files_assoc`
--
CREATE TABLE IF NOT EXISTS building_attachment_files_assoc (
  id_building int(11) NOT NULL,
  id_attachment int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_building, id_attachment)
)
ENGINE = INNODB,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `building_attachment_files_assoc_after_insert`
--
CREATE TRIGGER building_attachment_files_assoc_after_insert
AFTER INSERT
ON building_attachment_files_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_building IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'building_attachment_files_assoc', NEW.id_attachment, 'id_building', NULL, NEW.id_building, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_attachment IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'building_attachment_files_assoc', NEW.id_attachment, 'id_attachment', NULL, NEW.id_attachment, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `building_attachment_files_assoc_after_update`
--
CREATE TRIGGER building_attachment_files_assoc_after_update
AFTER UPDATE
ON building_attachment_files_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'building_attachment_files_assoc', NEW.id_attachment, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_building <> OLD.id_building) THEN
      INSERT INTO `log`
        VALUES (NULL, 'building_attachment_files_assoc', NEW.id_attachment, 'id_building', OLD.id_building, NEW.id_building, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_attachment <> OLD.id_attachment) THEN
      INSERT INTO `log`
        VALUES (NULL, 'building_attachment_files_assoc', NEW.id_attachment, 'id_attachment', OLD.id_attachment, NEW.id_attachment, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `object_attachment_files`
--
CREATE TABLE IF NOT EXISTS object_attachment_files (
  id_attachment int(11) NOT NULL AUTO_INCREMENT,
  description varchar(255) DEFAULT NULL,
  file_origin_name varchar(255) DEFAULT NULL,
  file_display_name varchar(255) DEFAULT NULL,
  file_mime_type varchar(255) DEFAULT NULL,
  deleted tinyint(1) DEFAULT 0,
  PRIMARY KEY (id_attachment)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `object_attachment_files_before_update`
--
CREATE TRIGGER object_attachment_files_before_update
BEFORE UPDATE
ON object_attachment_files
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    UPDATE building_attachment_files_assoc
    SET deleted = 1
    WHERE id_attachment = NEW.id_attachment;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE building_attachment_files_assoc
ADD CONSTRAINT FK_building_attachment_files_assoc_id_attachment FOREIGN KEY (id_attachment)
REFERENCES object_attachment_files (id_attachment) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `act_files`
--
CREATE TABLE IF NOT EXISTS act_files (
  id_file int(11) NOT NULL AUTO_INCREMENT,
  original_name varchar(255) DEFAULT NULL,
  file_name varchar(4096) NOT NULL,
  mime_type varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_file)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 16384,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `act_files_after_insert`
--
CREATE TRIGGER act_files_after_insert
AFTER INSERT
ON act_files
FOR EACH ROW
BEGIN
  IF (NEW.original_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'act_files', NEW.id_file, 'original_name', NULL, NEW.original_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.`file_name` IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'act_files', NEW.id_file, 'file_name', NULL, NEW.`file_name`, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.mime_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'act_files', NEW.id_file, 'mime_type', NULL, NEW.mime_type, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `act_files_after_update`
--
CREATE TRIGGER act_files_after_update
AFTER UPDATE
ON act_files
FOR EACH ROW
BEGIN
  IF (NOT (NEW.original_name IS NULL
    AND OLD.original_name IS NULL)
    AND ((NEW.original_name IS NULL
    AND OLD.original_name IS NOT NULL)
    OR (NEW.original_name IS NOT NULL
    AND OLD.original_name IS NULL)
    OR (NEW.original_name <> OLD.original_name))) THEN
    INSERT INTO `log`
      VALUES (NULL, 'act_files', NEW.id_file, 'original_name', OLD.original_name, NEW.original_name, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.`file_name` <> OLD.`file_name`) THEN
    INSERT INTO `log`
      VALUES (NULL, 'act_files', NEW.id_file, 'file_name', OLD.`file_name`, NEW.`file_name`, 'UPDATE', NOW(), USER());
  END IF;
  IF (NOT (NEW.mime_type IS NULL
    AND OLD.mime_type IS NULL)
    AND ((NEW.mime_type IS NULL
    AND OLD.mime_type IS NOT NULL)
    OR (NEW.mime_type IS NOT NULL
    AND OLD.mime_type IS NULL)
    OR (NEW.mime_type <> OLD.mime_type))) THEN
    INSERT INTO `log`
      VALUES (NULL, 'act_files', NEW.id_file, 'mime_type', OLD.mime_type, NEW.mime_type, 'UPDATE', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `act_files_before_delete`
--
CREATE TRIGGER act_files_before_delete
BEFORE DELETE
ON act_files
FOR EACH ROW
BEGIN
  IF (OLD.original_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'act_files', OLD.id_file, 'original_name', OLD.original_name, NULL, 'DELETED', NOW(), USER());
  END IF;
  IF (OLD.`file_name` IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'act_files', OLD.id_file, 'file_name', OLD.`file_name`, NULL, 'DELETED', NOW(), USER());
  END IF;
  IF (OLD.mime_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'act_files', OLD.id_file, 'mime_type', OLD.mime_type, NULL, 'DELETED', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `kumi_accounts_actual_tp_search_denorm`
--
CREATE TABLE IF NOT EXISTS kumi_accounts_actual_tp_search_denorm (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  id_account int(11) NOT NULL,
  id_process int(11) NOT NULL,
  tenant varchar(355) DEFAULT NULL,
  prescribed int(11) NOT NULL DEFAULT 0,
  emails varchar(2048) DEFAULT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 135508,
AVG_ROW_LENGTH = 140,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать процедуру `update_kumi_accounts_tp_search_by_id_process`
--
CREATE PROCEDURE update_kumi_accounts_tp_search_by_id_process (IN id_process_param int)
BEGIN
  DELETE
    FROM kumi_accounts_actual_tp_search_denorm
  WHERE id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process = id_process_param);

  INSERT INTO kumi_accounts_actual_tp_search_denorm (id_account, id_process, tenant, prescribed, emails)
    SELECT
      v.id_account,
      v.actual_id_process,
      MAX(IF(tp.id_kinship = 1, TRIM(CONCAT(tp.surname, ' ', tp.name, ' ', IFNULL(tp.patronymic, ''))), NULL)) AS tenant,
      COUNT(*) AS prescribed,
      GROUP_CONCAT(IF(v.owner IS NULL, tp.email,
      IF(REPLACE(TRIM(CONCAT(tp.surname, ' ', tp.name, ' ', IFNULL(tp.patronymic, ''))), 'ё', 'е') = REPLACE(v.owner, 'ё', 'е'), tp.email, NULL)) SEPARATOR ',') AS emails
    FROM (SELECT
        katpa.id_account,
        ka.account,
        ka.owner,
        ka.id_state,
        IFNULL(MAX(vtap.id_process), MAX(tp.id_process)) AS actual_id_process
      FROM kumi_accounts_t_processes_assoc katpa
        INNER JOIN kumi_accounts ka
          ON katpa.id_account = ka.id_account
        INNER JOIN tenancy_processes tp
          ON katpa.id_process = tp.id_process
        LEFT JOIN v_tenancy_active_processes vtap
          ON tp.id_process = vtap.id_process
      WHERE tp.deleted = 0
      AND katpa.id_account IN (SELECT
          k2.id_account
        FROM kumi_accounts_t_processes_assoc k2
        WHERE k2.deleted <> 1
        AND k2.id_process = id_process_param)
      GROUP BY katpa.id_account) v
      JOIN tenancy_persons tp
        ON v.actual_id_process = tp.id_process
    WHERE tp.deleted <> 1
    AND tp.exclude_date IS NULL
    AND v.id_state = 1
    GROUP BY v.id_account,
             v.actual_id_process;
END
$$

--
-- Создать процедуру `update_kumi_accounts_tp_search_by_id_account`
--
CREATE PROCEDURE update_kumi_accounts_tp_search_by_id_account (IN id_account_param int)
BEGIN
  DELETE
    FROM kumi_accounts_actual_tp_search_denorm
  WHERE id_account = id_account_param;

  INSERT INTO kumi_accounts_actual_tp_search_denorm (id_account, id_process, tenant, prescribed, emails)
    SELECT
      v.id_account,
      v.actual_id_process,
      MAX(IF(tp.id_kinship = 1, TRIM(CONCAT(tp.surname, ' ', tp.name, ' ', IFNULL(tp.patronymic, ''))), NULL)) AS tenant,
      COUNT(*) AS prescribed,
      GROUP_CONCAT(IF(v.owner IS NULL, tp.email,
      IF(REPLACE(TRIM(CONCAT(tp.surname, ' ', tp.name, ' ', IFNULL(tp.patronymic, ''))), 'ё', 'е') = REPLACE(v.owner, 'ё', 'е'), tp.email, NULL)) SEPARATOR ',') AS emails
    FROM (SELECT
        katpa.id_account,
        ka.account,
        ka.owner,
        ka.id_state,
        IFNULL(MAX(vtap.id_process), MAX(tp.id_process)) AS actual_id_process
      FROM kumi_accounts_t_processes_assoc katpa
        INNER JOIN kumi_accounts ka
          ON katpa.id_account = ka.id_account
        INNER JOIN tenancy_processes tp
          ON katpa.id_process = tp.id_process
        LEFT JOIN v_tenancy_active_processes vtap
          ON tp.id_process = vtap.id_process
      WHERE tp.deleted = 0
      AND katpa.id_account = id_account_param
      GROUP BY katpa.id_account) v
      JOIN tenancy_persons tp
        ON v.actual_id_process = tp.id_process
    WHERE tp.deleted <> 1
    AND tp.exclude_date IS NULL
    AND v.id_state = 1
    GROUP BY v.id_account,
             v.actual_id_process;
END
$$

DELIMITER ;

--
-- Создать таблицу `premises_types`
--
CREATE TABLE IF NOT EXISTS premises_types (
  id_premises_type int(11) NOT NULL AUTO_INCREMENT,
  premises_type varchar(255) NOT NULL,
  premises_type_as_num varchar(255) DEFAULT NULL,
  premises_type_short varchar(10) DEFAULT NULL,
  PRIMARY KEY (id_premises_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 6,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Типы помещений';

--
-- Создать представление `v_premises_types`
--
CREATE
VIEW v_premises_types
AS
SELECT
  `pt`.`id_premises_type` AS `id_premises_type`,
  IF((`pt`.`premises_type` = 'Квартира с подселением'), 'Квартира', `pt`.`premises_type`) AS `premises_type`
FROM `premises_types` `pt`;

--
-- Создать представление `v_kladr_streets`
--
CREATE
VIEW v_kladr_streets
AS
SELECT
  `sn`.`CODE` AS `id_street`,
  IF((`sn`.`CODE` = '38000005006000200'), 'жилрайон. Порожский, ул. XX Партсъезда', IF((`sn`.`CODE` LIKE '38000005%'), SUBSTR(`sn`.`street_name`, (CHAR_LENGTH('Иркутская обл., г. Братск, ') + 1)), `sn`.`street_name`)) AS `street_name`,
  IF((`sn`.`CODE` = '38000005006000200'), 'жилой район Порожский, улица XX Партсъезда', REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(IF((`sn`.`CODE` LIKE '38000005%'), SUBSTR(`sn`.`street_name`, (CHAR_LENGTH('Иркутская обл., г. Братск, ') + 1)), `sn`.`street_name`), 'пер.', 'переулок'), 'мкр.', 'микрорайон'), 'ул.', 'улица'), 'б-р.', 'бульвар'), 'пр-кт.', 'проспект'), 'проезд.', 'проезд'), 'обл.', 'область'), 'г.', 'город'), 'жилрайон.', 'жилой район'), 'кв-л.', 'квартал')) AS `street_long`,
  TRIM(SUBSTR(SUBSTRING_INDEX(`sn`.`street_name`, ',', -(1)), (CHAR_LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(`sn`.`street_name`, ',', -(1)), '.', 1)) + 2))) AS `only_street_name`
FROM `kladr`.`street_name` `sn`
WHERE ((`sn`.`CODE` LIKE '38000005%')
OR (`sn`.`CODE` IN ('38001002000020700', '38000015000001300', '38000015000012800', '38000015000012900', '38001002000006800')))
ORDER BY (NOT ((`sn`.`CODE` LIKE '38000005%'))), IF((`sn`.`CODE` = '38000005006000200'), 'жилрайон. Порожский, ул. XX Партсъезда', IF((`sn`.`CODE` LIKE '38000005%'), SUBSTR(`sn`.`street_name`, (CHAR_LENGTH('Иркутская обл., г. Братск, ') + 1)), `sn`.`street_name`));

DELIMITER $$

--
-- Создать процедуру `update_kumi_accounts_address_infix_by_id_sub_premise`
--
CREATE PROCEDURE update_kumi_accounts_address_infix_by_id_sub_premise (IN id_sub_premise_param int)
BEGIN
  DELETE
    FROM kumi_accounts_address_infix
  WHERE id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process IN (SELECT
          tspa.id_process
        FROM tenancy_sub_premises_assoc tspa
        WHERE tspa.deleted <> 1
        AND tspa.id_sub_premises = id_sub_premise_param));

  INSERT INTO kumi_accounts_address_infix (id_account, infix, address, total_area, post_index)
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', b.id_building) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house) AS address,
      b.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_buildings_assoc tba
        ON tp.id_process = tba.id_process
      JOIN buildings b
        ON tba.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process IN (SELECT
          tspa.id_process
        FROM tenancy_sub_premises_assoc tspa
        WHERE tspa.deleted <> 1
        AND tspa.id_sub_premises = id_sub_premise_param))
    AND tba.deleted <> 1
    AND tp.deleted <> 1
    AND b.deleted <> 1
    AND katpa.deleted <> 1
    UNION ALL
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', p.id_building, 'p', tpa.id_premises) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house, ', ', pt.premises_type_short, ' ', p.premises_num) AS address,
      p.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_premises_assoc tpa
        ON tpa.id_process = tp.id_process
      JOIN premises p
        ON tpa.id_premises = p.id_premises
      JOIN premises_types pt
        ON p.id_premises_type = pt.id_premises_type
      JOIN buildings b
        ON p.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process IN (SELECT
          tspa.id_process
        FROM tenancy_sub_premises_assoc tspa
        WHERE tspa.deleted <> 1
        AND tspa.id_sub_premises = id_sub_premise_param))
    AND tpa.deleted <> 1
    AND tp.deleted <> 1
    AND p.deleted <> 1
    AND katpa.deleted <> 1
    UNION ALL
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', p.id_building, 'p', p.id_premises, 'sp', tspa.id_sub_premises) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house, ', ', pt.premises_type_short, ' ', p.premises_num, ', к. ', sp.sub_premises_num) AS address,
      sp.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_sub_premises_assoc tspa
        ON tspa.id_process = tp.id_process
      JOIN sub_premises sp
        ON tspa.id_sub_premises = sp.id_sub_premises
      JOIN premises p
        ON sp.id_premises = p.id_premises
      JOIN premises_types pt
        ON p.id_premises_type = pt.id_premises_type
      JOIN buildings b
        ON p.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process IN (SELECT
          tspa.id_process
        FROM tenancy_sub_premises_assoc tspa
        WHERE tspa.deleted <> 1
        AND tspa.id_sub_premises = id_sub_premise_param))
    AND tspa.deleted <> 1
    AND tp.deleted <> 1
    AND p.deleted <> 1
    AND katpa.deleted <> 1;
END
$$

--
-- Создать процедуру `update_kumi_accounts_address_infix_by_id_process`
--
CREATE PROCEDURE update_kumi_accounts_address_infix_by_id_process (IN id_process_param int)
BEGIN
  DELETE
    FROM kumi_accounts_address_infix
  WHERE id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process = id_process_param);

  INSERT INTO kumi_accounts_address_infix (id_account, infix, address, total_area, post_index)
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', b.id_building) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house) AS address,
      b.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_buildings_assoc tba
        ON tp.id_process = tba.id_process
      JOIN buildings b
        ON tba.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process = id_process_param)
    AND tba.deleted <> 1
    AND tp.deleted <> 1
    AND b.deleted <> 1
    AND katpa.deleted <> 1
    UNION ALL
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', p.id_building, 'p', tpa.id_premises) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house, ', ', pt.premises_type_short, ' ', p.premises_num) AS address,
      p.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_premises_assoc tpa
        ON tpa.id_process = tp.id_process
      JOIN premises p
        ON tpa.id_premises = p.id_premises
      JOIN premises_types pt
        ON p.id_premises_type = pt.id_premises_type
      JOIN buildings b
        ON p.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process = id_process_param)
    AND tpa.deleted <> 1
    AND tp.deleted <> 1
    AND p.deleted <> 1
    AND katpa.deleted <> 1
    UNION ALL
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', p.id_building, 'p', p.id_premises, 'sp', tspa.id_sub_premises) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house, ', ', pt.premises_type_short, ' ', p.premises_num, ', к. ', sp.sub_premises_num) AS address,
      sp.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_sub_premises_assoc tspa
        ON tspa.id_process = tp.id_process
      JOIN sub_premises sp
        ON tspa.id_sub_premises = sp.id_sub_premises
      JOIN premises p
        ON sp.id_premises = p.id_premises
      JOIN premises_types pt
        ON p.id_premises_type = pt.id_premises_type
      JOIN buildings b
        ON p.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process = id_process_param)
    AND tspa.deleted <> 1
    AND tp.deleted <> 1
    AND p.deleted <> 1
    AND katpa.deleted <> 1;
END
$$

--
-- Создать процедуру `update_kumi_accounts_address_infix_by_id_premise`
--
CREATE PROCEDURE update_kumi_accounts_address_infix_by_id_premise (IN id_premise_param int)
BEGIN
  DELETE
    FROM kumi_accounts_address_infix
  WHERE id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process IN (SELECT
          tpa.id_process
        FROM tenancy_premises_assoc tpa
        WHERE tpa.deleted <> 1
        AND tpa.id_premises = id_premise_param
        UNION ALL
        SELECT
          tspa.id_process
        FROM tenancy_sub_premises_assoc tspa
          JOIN sub_premises sp
            ON tspa.id_sub_premises = sp.id_sub_premises
        WHERE tspa.deleted <> 1
        AND sp.deleted <> 1
        AND sp.id_premises = id_premise_param));

  INSERT INTO kumi_accounts_address_infix (id_account, infix, address, total_area, post_index)
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', b.id_building) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house) AS address,
      b.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_buildings_assoc tba
        ON tp.id_process = tba.id_process
      JOIN buildings b
        ON tba.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process IN (SELECT
          tpa.id_process
        FROM tenancy_premises_assoc tpa
        WHERE tpa.deleted <> 1
        AND tpa.id_premises = id_premise_param
        UNION ALL
        SELECT
          tspa.id_process
        FROM tenancy_sub_premises_assoc tspa
          JOIN sub_premises sp
            ON tspa.id_sub_premises = sp.id_sub_premises
        WHERE tspa.deleted <> 1
        AND sp.deleted <> 1
        AND sp.id_premises = id_premise_param))
    AND tba.deleted <> 1
    AND tp.deleted <> 1
    AND b.deleted <> 1
    AND katpa.deleted <> 1
    UNION ALL
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', p.id_building, 'p', tpa.id_premises) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house, ', ', pt.premises_type_short, ' ', p.premises_num) AS address,
      p.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_premises_assoc tpa
        ON tpa.id_process = tp.id_process
      JOIN premises p
        ON tpa.id_premises = p.id_premises
      JOIN premises_types pt
        ON p.id_premises_type = pt.id_premises_type
      JOIN buildings b
        ON p.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process IN (SELECT
          tpa.id_process
        FROM tenancy_premises_assoc tpa
        WHERE tpa.deleted <> 1
        AND tpa.id_premises = id_premise_param
        UNION ALL
        SELECT
          tspa.id_process
        FROM tenancy_sub_premises_assoc tspa
          JOIN sub_premises sp
            ON tspa.id_sub_premises = sp.id_sub_premises
        WHERE tspa.deleted <> 1
        AND sp.deleted <> 1
        AND sp.id_premises = id_premise_param))
    AND tpa.deleted <> 1
    AND tp.deleted <> 1
    AND p.deleted <> 1
    AND katpa.deleted <> 1
    UNION ALL
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', p.id_building, 'p', p.id_premises, 'sp', tspa.id_sub_premises) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house, ', ', pt.premises_type_short, ' ', p.premises_num, ', к. ', sp.sub_premises_num) AS address,
      sp.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_sub_premises_assoc tspa
        ON tspa.id_process = tp.id_process
      JOIN sub_premises sp
        ON tspa.id_sub_premises = sp.id_sub_premises
      JOIN premises p
        ON sp.id_premises = p.id_premises
      JOIN premises_types pt
        ON p.id_premises_type = pt.id_premises_type
      JOIN buildings b
        ON p.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process IN (SELECT
          tpa.id_process
        FROM tenancy_premises_assoc tpa
        WHERE tpa.deleted <> 1
        AND tpa.id_premises = id_premise_param
        UNION ALL
        SELECT
          tspa.id_process
        FROM tenancy_sub_premises_assoc tspa
          JOIN sub_premises sp
            ON tspa.id_sub_premises = sp.id_sub_premises
        WHERE tspa.deleted <> 1
        AND sp.deleted <> 1
        AND sp.id_premises = id_premise_param))
    AND tspa.deleted <> 1
    AND tp.deleted <> 1
    AND p.deleted <> 1
    AND katpa.deleted <> 1;
END
$$

--
-- Создать процедуру `update_kumi_accounts_address_infix_by_id_account`
--
CREATE PROCEDURE update_kumi_accounts_address_infix_by_id_account (IN id_account_param int)
BEGIN
  DELETE
    FROM kumi_accounts_address_infix
  WHERE id_account = id_account_param;

  INSERT INTO kumi_accounts_address_infix (id_account, infix, address, total_area, post_index)
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', b.id_building) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house) AS address,
      b.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_buildings_assoc tba
        ON tp.id_process = tba.id_process
      JOIN buildings b
        ON tba.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account = id_account_param
    AND tba.deleted <> 1
    AND tp.deleted <> 1
    AND b.deleted <> 1
    AND katpa.deleted <> 1
    UNION ALL
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', p.id_building, 'p', tpa.id_premises) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house, ', ', pt.premises_type_short, ' ', p.premises_num) AS address,
      p.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_premises_assoc tpa
        ON tpa.id_process = tp.id_process
      JOIN premises p
        ON tpa.id_premises = p.id_premises
      JOIN premises_types pt
        ON p.id_premises_type = pt.id_premises_type
      JOIN buildings b
        ON p.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account = id_account_param
    AND tpa.deleted <> 1
    AND tp.deleted <> 1
    AND p.deleted <> 1
    AND katpa.deleted <> 1
    UNION ALL
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', p.id_building, 'p', p.id_premises, 'sp', tspa.id_sub_premises) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house, ', ', pt.premises_type_short, ' ', p.premises_num, ', к. ', sp.sub_premises_num) AS address,
      sp.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_sub_premises_assoc tspa
        ON tspa.id_process = tp.id_process
      JOIN sub_premises sp
        ON tspa.id_sub_premises = sp.id_sub_premises
      JOIN premises p
        ON sp.id_premises = p.id_premises
      JOIN premises_types pt
        ON p.id_premises_type = pt.id_premises_type
      JOIN buildings b
        ON p.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account = id_account_param
    AND tspa.deleted <> 1
    AND tp.deleted <> 1
    AND p.deleted <> 1
    AND katpa.deleted <> 1;
END
$$

DELIMITER ;

--
-- Создать таблицу `kumi_accounts_t_processes_assoc`
--
CREATE TABLE IF NOT EXISTS kumi_accounts_t_processes_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_account int(11) NOT NULL,
  id_process int(11) NOT NULL,
  fraction decimal(10, 4) NOT NULL DEFAULT 1.0000,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 131704,
AVG_ROW_LENGTH = 108,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `kumi_accounts_t_processes_assoc_after_insert`
--
CREATE TRIGGER kumi_accounts_t_processes_assoc_after_insert
AFTER INSERT
ON kumi_accounts_t_processes_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts_t_processes_assoc', NEW.id_assoc, 'id_account', NULL, NEW.id_account, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts_t_processes_assoc', NEW.id_assoc, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.fraction IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts_t_processes_assoc', NEW.id_assoc, 'fraction', NULL, NEW.fraction, 'INSERT', NOW(), USER());
  END IF;
  IF (EXISTS (SELECT
        *
      FROM kumi_accounts ka
        INNER JOIN kumi_charges kc
          ON ka.id_account = kc.id_account
      WHERE ka.id_state <> 2
      AND ka.id_account = NEW.id_account
      AND ka.deleted <> 1)) THEN
    UPDATE kumi_accounts ka
    SET ka.recalc_marker = 1,
        ka.recalc_reason = 'Изменение перечня наймов в лицевом счете'
    WHERE ka.id_account = NEW.id_account;
  END IF;

  CALL update_kumi_accounts_address_infix_by_id_account(NEW.id_account);
  CALL update_kumi_accounts_tp_search_by_id_account(NEW.id_account);

END
$$

--
-- Создать триггер `kumi_accounts_t_processes_assoc_after_update`
--
CREATE TRIGGER kumi_accounts_t_processes_assoc_after_update
AFTER UPDATE
ON kumi_accounts_t_processes_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts_t_processes_assoc', NEW.id_assoc, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
    IF (@deleting_kumi_account IS NULL
      AND EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account = NEW.id_account
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = 'Изменение перечня наймов в лицевом счете'
      WHERE ka.id_account = NEW.id_account;
      CALL update_kumi_accounts_address_infix_by_id_account(NEW.id_account);
      CALL update_kumi_accounts_tp_search_by_id_account(NEW.id_account);
    END IF;


  ELSE
    IF (NEW.fraction <> OLD.fraction) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts_t_processes_assoc', NEW.id_assoc, 'fraction', OLD.fraction, NEW.fraction, 'UPDATE', NOW(), USER());
      IF (EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = NEW.id_account
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = CONCAT('Изменение размера доли по найму № ', NEW.id_process)
        WHERE ka.id_account = NEW.id_account;
      END IF;
    END IF;
    IF (NEW.id_account <> OLD.id_account) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts_t_processes_assoc', NEW.id_assoc, 'id_account', OLD.id_account, NEW.id_account, 'UPDATE', NOW(), USER());
      IF (EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = NEW.id_account
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = 'Изменение перечня наймов в лицевом счете'
        WHERE ka.id_account = NEW.id_account;
      END IF;
      IF (EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = OLD.id_account
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = 'Изменение перечня наймов в лицевом счете'
        WHERE ka.id_account = OLD.id_account;
      END IF;
    END IF;
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts_t_processes_assoc', NEW.id_assoc, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
      IF (EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = NEW.id_account
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = 'Изменение перечня наймов в лицевом счете'
        WHERE ka.id_account = NEW.id_account;
      END IF;
    END IF;
    CALL update_kumi_accounts_tp_search_by_id_account(NEW.id_account);
  END IF;
END
$$

--
-- Создать триггер `kumi_accounts_t_process_assoc_after_delete`
--
CREATE TRIGGER kumi_accounts_t_process_assoc_after_delete
AFTER DELETE
ON kumi_accounts_t_processes_assoc
FOR EACH ROW
BEGIN
  CALL update_kumi_accounts_address_infix_by_id_account(OLD.id_account);
  CALL update_kumi_accounts_tp_search_by_id_account(OLD.id_account);
END
$$

DELIMITER ;

--
-- Создать таблицу `kumi_accounts_states`
--
CREATE TABLE IF NOT EXISTS kumi_accounts_states (
  id_state int(11) NOT NULL AUTO_INCREMENT,
  state varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_state)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_accounts`
--
CREATE TABLE IF NOT EXISTS kumi_accounts (
  id_account int(11) NOT NULL AUTO_INCREMENT,
  account varchar(255) NOT NULL,
  account_gis_zkh varchar(255) DEFAULT NULL,
  id_state int(11) NOT NULL DEFAULT 1,
  create_date date NOT NULL,
  annual_date date DEFAULT NULL,
  recalc_marker tinyint(1) NOT NULL DEFAULT 0,
  recalc_reason varchar(255) DEFAULT NULL,
  last_charge_date date DEFAULT NULL,
  last_calc_date date DEFAULT NULL,
  current_balance_tenancy decimal(12, 2) DEFAULT 0.00,
  current_balance_penalty decimal(12, 2) DEFAULT 0.00,
  current_balance_dgi decimal(12, 2) DEFAULT 0.00,
  current_balance_pkk decimal(12, 2) DEFAULT 0.00,
  current_balance_padun decimal(12, 2) DEFAULT 0.00,
  owner varchar(355) DEFAULT NULL COMMENT 'Владелец ЛС, если пустой, то в квитанции берется владелец из найма',
  description varchar(1024) DEFAULT NULL,
  start_charge_date date DEFAULT NULL,
  stop_charge_date date DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_account)
)
ENGINE = INNODB,
AUTO_INCREMENT = 96100,
AVG_ROW_LENGTH = 67,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `kumi_accounts_after_insert`
--
CREATE TRIGGER kumi_accounts_after_insert
AFTER INSERT
ON kumi_accounts
FOR EACH ROW
BEGIN
  IF (NEW.id_account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'id_account', NULL, NEW.id_account, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'account', NULL, NEW.account, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.account_gis_zkh IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'account_gis_zkh', NULL, NEW.account_gis_zkh, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_state IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'id_state', NULL, NEW.id_state, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.create_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'create_date', NULL, NEW.create_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.annual_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'annual_date', NULL, NEW.annual_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recalc_marker IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'recalc_marker', NULL, NEW.recalc_marker, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recalc_reason IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'recalc_reason', NULL, NEW.recalc_reason, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.last_charge_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'last_charge_date', NULL, NEW.last_charge_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.last_calc_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'last_calc_date', NULL, NEW.last_calc_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.current_balance_tenancy IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'current_balance_tenancy', NULL, NEW.current_balance_tenancy, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.current_balance_penalty IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'current_balance_penalty', NULL, NEW.current_balance_penalty, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.current_balance_dgi IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'current_balance_dgi', NULL, NEW.current_balance_dgi, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.current_balance_pkk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'current_balance_pkk', NULL, NEW.current_balance_pkk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.current_balance_padun IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'current_balance_padun', NULL, NEW.current_balance_padun, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.owner IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'owner', NULL, NEW.owner, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.start_charge_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'start_charge_date', NULL, NEW.start_charge_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.stop_charge_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'stop_charge_date', NULL, NEW.stop_charge_date, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `kumi_accounts_after_update`
--
CREATE TRIGGER kumi_accounts_after_update
AFTER UPDATE
ON kumi_accounts
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_accounts', NEW.id_account, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.account <> OLD.account) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'account', OLD.account, NEW.account, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.account_gis_zkh IS NULL
      AND OLD.account_gis_zkh IS NULL)
      AND ((NEW.account_gis_zkh IS NULL
      AND OLD.account_gis_zkh IS NOT NULL)
      OR (NEW.account_gis_zkh IS NOT NULL
      AND OLD.account_gis_zkh IS NULL)
      OR (NEW.account_gis_zkh <> OLD.account_gis_zkh))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'account_gis_zkh', OLD.account_gis_zkh, NEW.account_gis_zkh, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_state <> OLD.id_state) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'id_state', OLD.id_state, NEW.id_state, 'UPDATE', NOW(), USER());
    END IF;

    IF (NEW.create_date <> OLD.create_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'create_date', OLD.create_date, NEW.create_date, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.annual_date IS NULL
      AND OLD.annual_date IS NULL)
      AND ((NEW.annual_date IS NULL
      AND OLD.annual_date IS NOT NULL)
      OR (NEW.annual_date IS NOT NULL
      AND OLD.annual_date IS NULL)
      OR (NEW.annual_date <> OLD.annual_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'annual_date', OLD.annual_date, NEW.annual_date, 'UPDATE', NOW(), USER());
    END IF;

    IF (NEW.recalc_marker <> OLD.recalc_marker) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'recalc_marker', OLD.recalc_marker, NEW.recalc_marker, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.recalc_reason IS NULL
      AND OLD.recalc_reason IS NULL)
      AND ((NEW.recalc_reason IS NULL
      AND OLD.recalc_reason IS NOT NULL)
      OR (NEW.recalc_reason IS NOT NULL
      AND OLD.recalc_reason IS NULL)
      OR (NEW.recalc_reason <> OLD.recalc_reason))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'recalc_reason', OLD.recalc_reason, NEW.recalc_reason, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.last_charge_date IS NULL
      AND OLD.last_charge_date IS NULL)
      AND ((NEW.last_charge_date IS NULL
      AND OLD.last_charge_date IS NOT NULL)
      OR (NEW.last_charge_date IS NOT NULL
      AND OLD.last_charge_date IS NULL)
      OR (NEW.last_charge_date <> OLD.last_charge_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'last_charge_date', OLD.last_charge_date, NEW.last_charge_date, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.last_calc_date IS NULL
      AND OLD.last_calc_date IS NULL)
      AND ((NEW.last_calc_date IS NULL
      AND OLD.last_calc_date IS NOT NULL)
      OR (NEW.last_calc_date IS NOT NULL
      AND OLD.last_calc_date IS NULL)
      OR (NEW.last_calc_date <> OLD.last_calc_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'last_calc_date', OLD.last_calc_date, NEW.last_calc_date, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.current_balance_tenancy IS NULL
      AND OLD.current_balance_tenancy IS NULL)
      AND ((NEW.current_balance_tenancy IS NULL
      AND OLD.current_balance_tenancy IS NOT NULL)
      OR (NEW.current_balance_tenancy IS NOT NULL
      AND OLD.current_balance_tenancy IS NULL)
      OR (NEW.current_balance_tenancy <> OLD.current_balance_tenancy))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'current_balance_tenancy', OLD.current_balance_tenancy, NEW.current_balance_tenancy, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.current_balance_penalty IS NULL
      AND OLD.current_balance_penalty IS NULL)
      AND ((NEW.current_balance_penalty IS NULL
      AND OLD.current_balance_penalty IS NOT NULL)
      OR (NEW.current_balance_penalty IS NOT NULL
      AND OLD.current_balance_penalty IS NULL)
      OR (NEW.current_balance_penalty <> OLD.current_balance_penalty))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'current_balance_penalty', OLD.current_balance_penalty, NEW.current_balance_penalty, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.current_balance_dgi IS NULL
      AND OLD.current_balance_dgi IS NULL)
      AND ((NEW.current_balance_dgi IS NULL
      AND OLD.current_balance_dgi IS NOT NULL)
      OR (NEW.current_balance_dgi IS NOT NULL
      AND OLD.current_balance_dgi IS NULL)
      OR (NEW.current_balance_dgi <> OLD.current_balance_dgi))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'current_balance_dgi', OLD.current_balance_dgi, NEW.current_balance_dgi, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.current_balance_pkk IS NULL
      AND OLD.current_balance_pkk IS NULL)
      AND ((NEW.current_balance_pkk IS NULL
      AND OLD.current_balance_pkk IS NOT NULL)
      OR (NEW.current_balance_pkk IS NOT NULL
      AND OLD.current_balance_pkk IS NULL)
      OR (NEW.current_balance_pkk <> OLD.current_balance_pkk))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'current_balance_pkk', OLD.current_balance_pkk, NEW.current_balance_pkk, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.current_balance_padun IS NULL
      AND OLD.current_balance_padun IS NULL)
      AND ((NEW.current_balance_padun IS NULL
      AND OLD.current_balance_padun IS NOT NULL)
      OR (NEW.current_balance_padun IS NOT NULL
      AND OLD.current_balance_padun IS NULL)
      OR (NEW.current_balance_padun <> OLD.current_balance_padun))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'current_balance_padun', OLD.current_balance_padun, NEW.current_balance_padun, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.owner IS NULL
      AND OLD.owner IS NULL)
      AND ((NEW.owner IS NULL
      AND OLD.owner IS NOT NULL)
      OR (NEW.owner IS NOT NULL
      AND OLD.owner IS NULL)
      OR (NEW.owner <> OLD.owner))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'owner', OLD.owner, NEW.owner, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.start_charge_date IS NULL
      AND OLD.start_charge_date IS NULL)
      AND ((NEW.start_charge_date IS NULL
      AND OLD.start_charge_date IS NOT NULL)
      OR (NEW.start_charge_date IS NOT NULL
      AND OLD.start_charge_date IS NULL)
      OR (NEW.start_charge_date <> OLD.start_charge_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'start_charge_date', OLD.start_charge_date, NEW.start_charge_date, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.stop_charge_date IS NULL
      AND OLD.stop_charge_date IS NULL)
      AND ((NEW.stop_charge_date IS NULL
      AND OLD.stop_charge_date IS NOT NULL)
      OR (NEW.stop_charge_date IS NOT NULL
      AND OLD.stop_charge_date IS NULL)
      OR (NEW.stop_charge_date <> OLD.stop_charge_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_accounts', NEW.id_account, 'stop_charge_date', OLD.stop_charge_date, NEW.stop_charge_date, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `kumi_accounts_before_update`
--
CREATE TRIGGER kumi_accounts_before_update
BEFORE UPDATE
ON kumi_accounts
FOR EACH ROW
BEGIN
  IF (OLD.id_state = 2
    AND NEW.id_state <> 2) THEN
    SET NEW.recalc_marker = 1;
    SET NEW.recalc_reason = 'Лицевой счет переведен из аннулированных в действующие';
  END IF;
  IF (NEW.deleted = 1) THEN
    SET @deleting_kumi_account = 1;
    UPDATE kumi_accounts_t_processes_assoc
    SET deleted = 1
    WHERE id_account = NEW.id_account;
    SET @deleting_kumi_account = NULL;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_accounts
ADD CONSTRAINT FK_kumi_accounts_id_state FOREIGN KEY (id_state)
REFERENCES kumi_accounts_states (id_state) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_accounts_actual_tp_search_denorm
ADD CONSTRAINT FK_kumi_accounts_actual_tp_sea FOREIGN KEY (id_account)
REFERENCES kumi_accounts (id_account) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_accounts_t_processes_assoc
ADD CONSTRAINT FK_kumi_accounts_t_processes_2 FOREIGN KEY (id_account)
REFERENCES kumi_accounts (id_account) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_charges
ADD CONSTRAINT FK_kumi_charges_id_account FOREIGN KEY (id_account)
REFERENCES kumi_accounts (id_account) ON UPDATE CASCADE;

--
-- Создать таблицу `tenancy_sub_premises_assoc`
--
CREATE TABLE IF NOT EXISTS tenancy_sub_premises_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_sub_premises int(11) NOT NULL,
  id_process int(11) NOT NULL,
  rent_total_area double DEFAULT NULL COMMENT 'Арендуемая площадь',
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1628,
AVG_ROW_LENGTH = 528,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `tenancy_sub_premises_assoc_after_insert`
--
CREATE TRIGGER tenancy_sub_premises_assoc_after_insert
AFTER INSERT
ON tenancy_sub_premises_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_sub_premises IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_sub_premises_assoc', NEW.id_assoc, 'id_sub_premises', NULL, NEW.id_sub_premises, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_sub_premises_assoc', NEW.id_assoc, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.rent_total_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_sub_premises_assoc', NEW.id_assoc, 'rent_total_area', NULL, NEW.rent_total_area, 'INSERT', NOW(), USER());
  END IF;
  IF (EXISTS (SELECT
        *
      FROM kumi_accounts ka
        INNER JOIN kumi_charges kc
          ON ka.id_account = kc.id_account
      WHERE ka.id_state <> 2
      AND ka.id_account IN (SELECT
          katpa.id_account
        FROM kumi_accounts_t_processes_assoc katpa
        WHERE katpa.deleted <> 1
        AND katpa.id_process = NEW.id_process)
      AND ka.deleted <> 1)) THEN
    UPDATE kumi_accounts ka
    SET ka.recalc_marker = 1,
        ka.recalc_reason = CONCAT('Изменение перечня нанимаемого жилья в найме № ', NEW.id_process)
    WHERE ka.id_account IN (SELECT
        katpa.id_account
      FROM kumi_accounts_t_processes_assoc katpa
      WHERE katpa.deleted <> 1
      AND katpa.id_process = NEW.id_process);
  END IF;

  CALL update_kumi_accounts_address_infix_by_id_process(NEW.id_process);
END
$$

--
-- Создать триггер `tenancy_sub_premises_assoc_after_update`
--
CREATE TRIGGER tenancy_sub_premises_assoc_after_update
AFTER UPDATE
ON tenancy_sub_premises_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_sub_premises_assoc', NEW.id_assoc, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
    IF (EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account = (SELECT
            katpa.id_account
          FROM kumi_accounts_t_processes_assoc katpa
          WHERE katpa.deleted <> 1
          AND katpa.id_process = NEW.id_process)
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = CONCAT('Изменение перечня нанимаемого жилья в найме № ', NEW.id_process)
      WHERE ka.id_account = (SELECT
          katpa.id_account
        FROM kumi_accounts_t_processes_assoc katpa
        WHERE katpa.deleted <> 1
        AND katpa.id_process = NEW.id_process);
    END IF;
    CALL update_kumi_accounts_address_infix_by_id_process(NEW.id_process);
  ELSE
    IF (NEW.id_sub_premises <> OLD.id_sub_premises) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_sub_premises_assoc', NEW.id_assoc, 'id_sub_premises', OLD.id_sub_premises, NEW.id_sub_premises, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_sub_premises_assoc', NEW.id_assoc, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.rent_total_area IS NULL
      AND OLD.rent_total_area IS NULL)
      AND ((NEW.rent_total_area IS NULL
      AND OLD.rent_total_area IS NOT NULL)
      OR (NEW.rent_total_area IS NOT NULL
      AND OLD.rent_total_area IS NULL)
      OR (NEW.rent_total_area <> OLD.rent_total_area))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_sub_premises_assoc', NEW.id_assoc, 'rent_total_area', OLD.rent_total_area, NEW.rent_total_area, 'UPDATE', NOW(), USER());
      IF (EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account IN (SELECT
              katpa.id_account
            FROM kumi_accounts_t_processes_assoc katpa
            WHERE katpa.deleted <> 1
            AND katpa.id_process = NEW.id_process)
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = CONCAT('Изменение арендуемой площади нанимаемого жилья в найме № ', NEW.id_process)
        WHERE ka.id_account IN (SELECT
            katpa.id_account
          FROM kumi_accounts_t_processes_assoc katpa
          WHERE katpa.deleted <> 1
          AND katpa.id_process = NEW.id_process);
      END IF;
    END IF;
  END IF;
END
$$

--
-- Создать триггер `tenancy_sub_premises_assoc_before_insert`
--
CREATE TRIGGER tenancy_sub_premises_assoc_before_insert
BEFORE INSERT
ON tenancy_sub_premises_assoc
FOR EACH ROW
BEGIN
  IF (NOT EXISTS (SELECT
        *
      FROM tenancy_processes tp
      WHERE tp.deleted = 0
      AND tp.id_process = NEW.id_process)) THEN
    SIGNAL SQLSTATE '45000' SET
    MESSAGE_TEXT = 'Невозможно добавить запись из-за нарушения ссылочной целостности';
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `tenancy_rent_periods_history`
--
CREATE TABLE IF NOT EXISTS tenancy_rent_periods_history (
  id_rent_period int(11) NOT NULL AUTO_INCREMENT,
  id_process int(11) NOT NULL,
  begin_date datetime DEFAULT NULL,
  end_date datetime DEFAULT NULL,
  until_dismissal tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Договор на период действия трудовых отношений',
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_rent_period)
)
ENGINE = INNODB,
AUTO_INCREMENT = 135,
AVG_ROW_LENGTH = 334,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `tenancy_rent_periods_history_after_insert`
--
CREATE TRIGGER tenancy_rent_periods_history_after_insert
AFTER INSERT
ON tenancy_rent_periods_history
FOR EACH ROW
BEGIN
  DECLARE updAccount tinyint;
  SET updAccount := 0;

  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_rent_periods_history', NEW.id_rent_period, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.begin_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_rent_periods_history', NEW.id_rent_period, 'begin_date', NULL, NEW.begin_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.end_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_rent_periods_history', NEW.id_rent_period, 'end_date', NULL, NEW.end_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.until_dismissal IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_rent_periods_history', NEW.id_rent_period, 'until_dismissal', NULL, NEW.until_dismissal, 'INSERT', NOW(), USER());
  END IF;
  -- Если добавляемый период не равен текущему периоду найма (перенос периода) и не равен ни одному из ранее добавленных периодов, то выполнять перерасчет
  IF (NOT EXISTS (SELECT
        *
      FROM tenancy_processes tp
      WHERE tp.id_process = NEW.id_process
      AND ((tp.begin_date IS NULL
      AND NEW.begin_date IS NULL)
      OR (tp.begin_date IS NOT NULL
      AND NEW.begin_date IS NOT NULL
      AND tp.begin_date = NEW.begin_date))
      AND ((tp.end_date IS NULL
      AND NEW.end_date IS NULL)
      OR (tp.end_date IS NOT NULL
      AND NEW.end_date IS NOT NULL
      AND tp.end_date = NEW.end_date)))
    AND NOT EXISTS (SELECT
        *
      FROM tenancy_rent_periods_history trph
      WHERE trph.id_process = NEW.id_process
      AND trph.id_rent_period <> NEW.id_rent_period
      AND ((trph.begin_date IS NULL
      AND NEW.begin_date IS NULL)
      OR (trph.begin_date IS NOT NULL
      AND NEW.begin_date IS NOT NULL
      AND trph.begin_date = NEW.begin_date))
      AND ((trph.end_date IS NULL
      AND NEW.end_date IS NULL)
      OR (trph.end_date IS NOT NULL
      AND NEW.end_date IS NOT NULL
      AND trph.end_date = NEW.end_date)))) THEN
    SET updAccount := 1;
  END IF;


  IF (updAccount = 1
    AND EXISTS (SELECT
        *
      FROM kumi_accounts ka
        INNER JOIN kumi_charges kc
          ON ka.id_account = kc.id_account
      WHERE ka.id_state <> 2
      AND ka.id_account IN (SELECT
          katpa.id_account
        FROM kumi_accounts_t_processes_assoc katpa
        WHERE katpa.id_process = NEW.id_process
        AND katpa.deleted <> 1)
      AND ka.deleted <> 1)) THEN
    UPDATE kumi_accounts ka
    SET ka.recalc_marker = 1,
        ka.recalc_reason = CONCAT('Изменение предыдущего периода действия найма № ', NEW.id_process)
    WHERE ka.deleted <> 1
    AND ka.id_account IN (SELECT
        katpa.id_account
      FROM kumi_accounts_t_processes_assoc katpa
      WHERE katpa.id_process = NEW.id_process
      AND katpa.deleted <> 1);
  END IF;
END
$$

--
-- Создать триггер `tenancy_rent_periods_history_after_update`
--
CREATE TRIGGER tenancy_rent_periods_history_after_update
AFTER UPDATE
ON tenancy_rent_periods_history
FOR EACH ROW
BEGIN
  DECLARE updAccount tinyint;
  SET updAccount := 0;

  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_rent_periods_history', NEW.id_rent_period, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());

    IF (EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account IN (SELECT
            katpa.id_account
          FROM kumi_accounts_t_processes_assoc katpa
          WHERE katpa.id_process = NEW.id_process
          AND katpa.deleted <> 1)
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = CONCAT('Удаление предыдущего периода действия найма № ', NEW.id_process)
      WHERE ka.deleted <> 1
      AND ka.id_account IN (SELECT
          katpa.id_account
        FROM kumi_accounts_t_processes_assoc katpa
        WHERE katpa.id_process = NEW.id_process
        AND katpa.deleted <> 1);
    END IF;
  ELSE
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_rent_periods_history', NEW.id_rent_period, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.begin_date IS NULL
      AND OLD.begin_date IS NULL)
      AND ((NEW.begin_date IS NULL
      AND OLD.begin_date IS NOT NULL)
      OR (NEW.begin_date IS NOT NULL
      AND OLD.begin_date IS NULL)
      OR (NEW.begin_date <> OLD.begin_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_rent_periods_history', NEW.id_rent_period, 'begin_date', OLD.begin_date, NEW.begin_date, 'UPDATE', NOW(), USER());

      SET updAccount := 1;
    END IF;
    IF (NOT (NEW.end_date IS NULL
      AND OLD.end_date IS NULL)
      AND ((NEW.end_date IS NULL
      AND OLD.end_date IS NOT NULL)
      OR (NEW.end_date IS NOT NULL
      AND OLD.end_date IS NULL)
      OR (NEW.end_date <> OLD.end_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_rent_periods_history', NEW.id_rent_period, 'end_date', OLD.end_date, NEW.end_date, 'UPDATE', NOW(), USER());

      SET updAccount := 1;
    END IF;
    IF (NEW.until_dismissal <> OLD.until_dismissal) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_rent_periods_history', NEW.id_rent_period, 'until_dismissal', OLD.until_dismissal, NEW.until_dismissal, 'UPDATE', NOW(), USER());
    END IF;

    IF (updAccount = 1
      AND EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account IN (SELECT
            katpa.id_account
          FROM kumi_accounts_t_processes_assoc katpa
          WHERE katpa.id_process = NEW.id_process
          AND katpa.deleted <> 1)
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = CONCAT('Изменение предыдущего периода действия найма № ', NEW.id_process)
      WHERE ka.deleted <> 1
      AND ka.id_account IN (SELECT
          katpa.id_account
        FROM kumi_accounts_t_processes_assoc katpa
        WHERE katpa.id_process = NEW.id_process
        AND katpa.deleted <> 1);
    END IF;
  END IF;
END
$$

--
-- Создать триггер `tenancy_rent_periods_history_before_insert`
--
CREATE TRIGGER tenancy_rent_periods_history_before_insert
BEFORE INSERT
ON tenancy_rent_periods_history
FOR EACH ROW
BEGIN
  IF (NOT EXISTS (SELECT
        *
      FROM tenancy_processes tp
      WHERE tp.deleted = 0
      AND tp.id_process = NEW.id_process)) THEN
    SIGNAL SQLSTATE '45000' SET
    MESSAGE_TEXT = 'Невозможно добавить запись из-за нарушения ссылочной целостности';
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `tenancy_premises_assoc`
--
CREATE TABLE IF NOT EXISTS tenancy_premises_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_premises int(11) NOT NULL,
  id_process int(11) NOT NULL,
  rent_total_area double DEFAULT NULL COMMENT 'Арендуемая общая площадь',
  rent_living_area double DEFAULT NULL COMMENT 'Арендуемая жилая площадь',
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 20221,
AVG_ROW_LENGTH = 744,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `tenancy_premises_assoc_after_insert`
--
CREATE TRIGGER tenancy_premises_assoc_after_insert
AFTER INSERT
ON tenancy_premises_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_premises IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_premises_assoc', NEW.id_assoc, 'id_premises', NULL, NEW.id_premises, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_premises_assoc', NEW.id_assoc, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.rent_total_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_premises_assoc', NEW.id_assoc, 'rent_total_area', NULL, NEW.rent_total_area, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.rent_living_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_premises_assoc', NEW.id_assoc, 'rent_living_area', NULL, NEW.rent_living_area, 'INSERT', NOW(), USER());
  END IF;
  IF (EXISTS (SELECT
        *
      FROM kumi_accounts ka
        INNER JOIN kumi_charges kc
          ON ka.id_account = kc.id_account
      WHERE ka.id_state <> 2
      AND ka.id_account IN (SELECT
          katpa.id_account
        FROM kumi_accounts_t_processes_assoc katpa
        WHERE katpa.deleted <> 1
        AND katpa.id_process = NEW.id_process)
      AND ka.deleted <> 1)) THEN
    UPDATE kumi_accounts ka
    SET ka.recalc_marker = 1,
        ka.recalc_reason = CONCAT('Изменение перечня нанимаемого жилья в найме № ', NEW.id_process)
    WHERE ka.id_account IN (SELECT
        katpa.id_account
      FROM kumi_accounts_t_processes_assoc katpa
      WHERE katpa.deleted <> 1
      AND katpa.id_process = NEW.id_process);
  END IF;

  CALL update_kumi_accounts_address_infix_by_id_process(NEW.id_process);
END
$$

--
-- Создать триггер `tenancy_premises_assoc_after_update`
--
CREATE TRIGGER tenancy_premises_assoc_after_update
AFTER UPDATE
ON tenancy_premises_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_premises_assoc', NEW.id_assoc, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
    IF (EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account IN (SELECT
            katpa.id_account
          FROM kumi_accounts_t_processes_assoc katpa
          WHERE katpa.deleted <> 1
          AND katpa.id_process = NEW.id_process)
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = CONCAT('Изменение перечня нанимаемого жилья в найме № ', NEW.id_process)
      WHERE ka.id_account IN (SELECT
          katpa.id_account
        FROM kumi_accounts_t_processes_assoc katpa
        WHERE katpa.deleted <> 1
        AND katpa.id_process = NEW.id_process);
    END IF;

    CALL update_kumi_accounts_address_infix_by_id_process(NEW.id_process);
  ELSE
    IF (NEW.id_premises <> OLD.id_premises) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_premises_assoc', NEW.id_assoc, 'id_premises', OLD.id_premises, NEW.id_premises, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_premises_assoc', NEW.id_assoc, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.rent_total_area IS NULL
      AND OLD.rent_total_area IS NULL)
      AND ((NEW.rent_total_area IS NULL
      AND OLD.rent_total_area IS NOT NULL)
      OR (NEW.rent_total_area IS NOT NULL
      AND OLD.rent_total_area IS NULL)
      OR (NEW.rent_total_area <> OLD.rent_total_area))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_premises_assoc', NEW.id_assoc, 'rent_total_area', OLD.rent_total_area, NEW.rent_total_area, 'UPDATE', NOW(), USER());
      IF (EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account IN (SELECT
              katpa.id_account
            FROM kumi_accounts_t_processes_assoc katpa
            WHERE katpa.deleted <> 1
            AND katpa.id_process = NEW.id_process)
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = CONCAT('Изменение арендуемой площади нанимаемого жилья в найме № ', NEW.id_process)
        WHERE ka.id_account IN (SELECT
            katpa.id_account
          FROM kumi_accounts_t_processes_assoc katpa
          WHERE katpa.deleted <> 1
          AND katpa.id_process = NEW.id_process);
      END IF;
    END IF;
    IF (NOT (NEW.rent_living_area IS NULL
      AND OLD.rent_living_area IS NULL)
      AND ((NEW.rent_living_area IS NULL
      AND OLD.rent_living_area IS NOT NULL)
      OR (NEW.rent_living_area IS NOT NULL
      AND OLD.rent_living_area IS NULL)
      OR (NEW.rent_living_area <> OLD.rent_living_area))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_premises_assoc', NEW.id_assoc, 'rent_living_area', OLD.rent_living_area, NEW.rent_living_area, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `tenancy_premises_assoc_before_insert`
--
CREATE TRIGGER tenancy_premises_assoc_before_insert
BEFORE INSERT
ON tenancy_premises_assoc
FOR EACH ROW
BEGIN
  IF (NOT EXISTS (SELECT
        *
      FROM tenancy_processes tp
      WHERE tp.deleted = 0
      AND tp.id_process = NEW.id_process)) THEN
    SIGNAL SQLSTATE '45000' SET
    MESSAGE_TEXT = 'Невозможно добавить запись из-за нарушения ссылочной целостности';
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `tenancy_buildings_assoc`
--
CREATE TABLE IF NOT EXISTS tenancy_buildings_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_building int(11) NOT NULL,
  id_process int(11) NOT NULL,
  rent_total_area double DEFAULT NULL COMMENT 'Арендуемая общая площадь',
  rent_living_area double DEFAULT NULL COMMENT 'Арендуемая жилая площадь',
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 28,
AVG_ROW_LENGTH = 1820,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `tenancy_buildings_assoc_after_insert`
--
CREATE TRIGGER tenancy_buildings_assoc_after_insert
AFTER INSERT
ON tenancy_buildings_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_building IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_buildings_assoc', NEW.id_assoc, 'id_building', NULL, NEW.id_building, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_buildings_assoc', NEW.id_assoc, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.rent_total_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_buildings_assoc', NEW.id_assoc, 'rent_total_area', NULL, NEW.rent_total_area, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.rent_living_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_buildings_assoc', NEW.id_assoc, 'rent_living_area', NULL, NEW.rent_living_area, 'INSERT', NOW(), USER());
  END IF;

  IF (EXISTS (SELECT
        *
      FROM kumi_accounts ka
        INNER JOIN kumi_charges kc
          ON ka.id_account = kc.id_account
      WHERE ka.id_state <> 2
      AND ka.id_account IN (SELECT
          katpa.id_account
        FROM kumi_accounts_t_processes_assoc katpa
        WHERE katpa.deleted <> 1
        AND katpa.id_process = NEW.id_process)
      AND ka.deleted <> 1)) THEN
    UPDATE kumi_accounts ka
    SET ka.recalc_marker = 1,
        ka.recalc_reason = CONCAT('Изменение перечня нанимаемого жилья в найме № ', NEW.id_process)
    WHERE ka.id_account IN (SELECT
        katpa.id_account
      FROM kumi_accounts_t_processes_assoc katpa
      WHERE katpa.deleted <> 1
      AND katpa.id_process = NEW.id_process);
  END IF;

  CALL update_kumi_accounts_address_infix_by_id_process(NEW.id_process);
END
$$

--
-- Создать триггер `tenancy_buildings_assoc_after_update`
--
CREATE TRIGGER tenancy_buildings_assoc_after_update
AFTER UPDATE
ON tenancy_buildings_assoc
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_buildings_assoc', NEW.id_assoc, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
    IF (EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account = (SELECT
            katpa.id_account
          FROM kumi_accounts_t_processes_assoc katpa
          WHERE katpa.deleted <> 1
          AND katpa.id_process = NEW.id_process)
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = CONCAT('Изменение перечня нанимаемого жилья в найме № ', NEW.id_process)
      WHERE ka.id_account IN (SELECT
          katpa.id_account
        FROM kumi_accounts_t_processes_assoc katpa
        WHERE katpa.deleted <> 1
        AND katpa.id_process = NEW.id_process);
    END IF;

    CALL update_kumi_accounts_address_infix_by_id_process(NEW.id_process);
  ELSE
    IF (NEW.id_building <> OLD.id_building) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_buildings_assoc', NEW.id_assoc, 'id_building', OLD.id_building, NEW.id_building, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_buildings_assoc', NEW.id_assoc, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.rent_total_area IS NULL
      AND OLD.rent_total_area IS NULL)
      AND ((NEW.rent_total_area IS NULL
      AND OLD.rent_total_area IS NOT NULL)
      OR (NEW.rent_total_area IS NOT NULL
      AND OLD.rent_total_area IS NULL)
      OR (NEW.rent_total_area <> OLD.rent_total_area))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_buildings_assoc', NEW.id_assoc, 'rent_total_area', OLD.rent_total_area, NEW.rent_total_area, 'UPDATE', NOW(), USER());
      IF (EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = (SELECT
              katpa.id_account
            FROM kumi_accounts_t_processes_assoc katpa
            WHERE katpa.deleted <> 1
            AND katpa.id_process = NEW.id_process)
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = CONCAT('Изменение арендуемой площади нанимаемого жилья в найме № ', NEW.id_process)
        WHERE ka.id_account IN (SELECT
            katpa.id_account
          FROM kumi_accounts_t_processes_assoc katpa
          WHERE katpa.deleted <> 1
          AND katpa.id_process = NEW.id_process);
      END IF;
    END IF;
    IF (NOT (NEW.rent_living_area IS NULL
      AND OLD.rent_living_area IS NULL)
      AND ((NEW.rent_living_area IS NULL
      AND OLD.rent_living_area IS NOT NULL)
      OR (NEW.rent_living_area IS NOT NULL
      AND OLD.rent_living_area IS NULL)
      OR (NEW.rent_living_area <> OLD.rent_living_area))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_buildings_assoc', NEW.id_assoc, 'rent_living_area', OLD.rent_living_area, NEW.rent_living_area, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `tenancy_buildings_assoc_before_insert`
--
CREATE TRIGGER tenancy_buildings_assoc_before_insert
BEFORE INSERT
ON tenancy_buildings_assoc
FOR EACH ROW
BEGIN
  IF (NOT EXISTS (SELECT
        *
      FROM tenancy_processes tp
      WHERE tp.deleted = 0
      AND tp.id_process = NEW.id_process)) THEN
    SIGNAL SQLSTATE '45000' SET
    MESSAGE_TEXT = 'Невозможно добавить запись из-за нарушения ссылочной целостности';
  END IF;
END
$$

--
-- Создать функцию `f_tenancy_buildings_count`
--
CREATE FUNCTION f_tenancy_buildings_count (id_process int)
RETURNS int(11)
BEGIN
  RETURN IFNULL((SELECT
      COUNT(*)
    FROM tenancy_buildings_assoc tba
    WHERE deleted <> 1
    AND tba.id_process = id_process
    AND tba.rent_total_area IS NULL
    AND tba.rent_living_area IS NULL
    GROUP BY tba.id_process), 0);
END
$$

--
-- Создать функцию `f_tenancy_beds_count`
--
CREATE FUNCTION f_tenancy_beds_count (id_process int)
RETURNS int(11)
BEGIN

  RETURN (SELECT
      SUM(beds_count)
    FROM (SELECT
        COUNT(*) AS beds_count
      FROM tenancy_buildings_assoc tba
      WHERE tba.deleted <> 1
      AND tba.id_process = id_process
      AND (tba.rent_total_area IS NOT NULL
      OR tba.rent_living_area IS NOT NULL)
      UNION ALL
      SELECT
        COUNT(*)
      FROM tenancy_premises_assoc tpa
      WHERE tpa.deleted <> 1
      AND tpa.id_process = id_process
      AND (tpa.rent_total_area IS NOT NULL
      OR tpa.rent_living_area IS NOT NULL)
      UNION ALL
      SELECT
        COUNT(*)
      FROM tenancy_sub_premises_assoc tspa
      WHERE tspa.deleted <> 1
      AND tspa.id_process = id_process
      AND tspa.rent_total_area IS NOT NULL) v);
END
$$

DELIMITER ;

--
-- Создать таблицу `kumi_charges_masscalcinfo`
--
CREATE TABLE IF NOT EXISTS kumi_charges_masscalcinfo (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  last_calc_date date NOT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `kumi_charges_masscalcinfo_after_update`
--
CREATE TRIGGER kumi_charges_masscalcinfo_after_update
AFTER UPDATE
ON kumi_charges_masscalcinfo
FOR EACH ROW
BEGIN
  INSERT INTO kumi_charges (id_account, start_date, end_date,
  input_tenancy, input_penalty, input_dgi, input_pkk, input_padun, output_tenancy, output_penalty, output_dgi, output_pkk, output_padun)
    SELECT
      ka.id_account,
      DATE_ADD(DATE_ADD(NEW.last_calc_date, INTERVAL 1 DAY), INTERVAL -1 MONTH) AS start_date,
      NEW.last_calc_date AS end_date,
      IFNULL(prev_kc.output_tenancy, 0) AS input_tenancy,
      IFNULL(prev_kc.output_penalty, 0) AS input_penalty,
      IFNULL(prev_kc.output_dgi, 0) AS input_dgi,
      IFNULL(prev_kc.output_pkk, 0) AS input_pkk,
      IFNULL(prev_kc.output_padun, 0) AS input_padun,
      IFNULL(prev_kc.output_tenancy, 0) AS output_tenancy,
      IFNULL(prev_kc.output_penalty, 0) AS output_penalty,
      IFNULL(prev_kc.output_dgi, 0) AS output_dgi,
      IFNULL(prev_kc.output_pkk, 0) AS output_pkk,
      IFNULL(prev_kc.output_padun, 0) AS output_padun
    FROM kumi_accounts ka
      LEFT JOIN (SELECT
          kc.*
        FROM kumi_charges kc
          INNER JOIN (SELECT
              kc.id_account,
              MAX(kc.end_date) AS end_date
            FROM kumi_charges kc
            WHERE kc.end_date < NEW.last_calc_date
            AND kc.deleted <> 1
            GROUP BY kc.id_account) mkc
            ON kc.id_account = mkc.id_account
            AND kc.end_date = mkc.end_date) prev_kc
        ON ka.id_account = prev_kc.id_account
      LEFT JOIN (SELECT
          *
        FROM kumi_charges kc
        WHERE kc.end_date = NEW.last_calc_date
        AND kc.deleted <> 1) curr_kc
        ON ka.id_account = curr_kc.id_account
    WHERE ka.id_state = 4
    AND curr_kc.id_account IS NULL;
END
$$

DELIMITER ;

--
-- Создать таблицу `kumi_charges_corrections`
--
CREATE TABLE IF NOT EXISTS kumi_charges_corrections (
  id_correction int(11) NOT NULL AUTO_INCREMENT,
  id_account int(11) NOT NULL,
  date date NOT NULL,
  description varchar(1024) DEFAULT NULL,
  tenancy_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  penalty_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  payment_tenancy_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  payment_penalty_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  dgi_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  payment_dgi_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  pkk_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  payment_pkk_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  padun_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  payment_padun_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  user varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_correction)
)
ENGINE = INNODB,
AUTO_INCREMENT = 179,
AVG_ROW_LENGTH = 552,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `kumi_charges_corrections_after_delete`
--
CREATE TRIGGER kumi_charges_corrections_after_delete
AFTER DELETE
ON kumi_charges_corrections
FOR EACH ROW
BEGIN
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'id_correction', OLD.id_correction, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'id_account', OLD.id_account, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'date', OLD.date, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'description', OLD.description, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'tenancy_value', OLD.tenancy_value, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'penalty_value', OLD.penalty_value, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'payment_tenancy_value', OLD.payment_tenancy_value, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'payment_penalty_value', OLD.payment_penalty_value, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'dgi_value', OLD.dgi_value, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'payment_dgi_value', OLD.payment_dgi_value, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'pkk_value', OLD.pkk_value, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'payment_pkk_value', OLD.payment_pkk_value, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'padun_value', OLD.padun_value, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'payment_padun_value', OLD.payment_padun_value, NULL, 'DELETE', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'kumi_charges_corrections', OLD.id_correction, 'user', OLD.`user`, NULL, 'DELETE', NOW(), USER());
END
$$

--
-- Создать триггер `kumi_charges_corrections_after_insert`
--
CREATE TRIGGER kumi_charges_corrections_after_insert
AFTER INSERT
ON kumi_charges_corrections
FOR EACH ROW
BEGIN
  IF (NEW.id_correction IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'id_correction', NULL, NEW.id_correction, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'id_account', NULL, NEW.id_account, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'date', NULL, NEW.date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.tenancy_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'tenancy_value', NULL, NEW.tenancy_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.penalty_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'penalty_value', NULL, NEW.penalty_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payment_tenancy_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'payment_tenancy_value', NULL, NEW.payment_tenancy_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payment_penalty_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'payment_penalty_value', NULL, NEW.payment_penalty_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.dgi_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'dgi_value', NULL, NEW.dgi_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payment_dgi_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'payment_dgi_value', NULL, NEW.payment_dgi_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.pkk_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'pkk_value', NULL, NEW.pkk_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payment_pkk_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'payment_pkk_value', NULL, NEW.payment_pkk_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.padun_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'padun_value', NULL, NEW.padun_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payment_padun_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'payment_padun_value', NULL, NEW.payment_padun_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.user IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_charges_corrections', NEW.id_correction, 'user', NULL, NEW.user, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `kumi_charges_corrections_before_insert`
--
CREATE TRIGGER kumi_charges_corrections_before_insert
BEFORE INSERT
ON kumi_charges_corrections
FOR EACH ROW
BEGIN
  SET NEW.USER = SUBSTRING_INDEX(USER(), '@', 1);
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_charges_corrections
ADD CONSTRAINT FK_kumi_charges_corrections_id FOREIGN KEY (id_account)
REFERENCES kumi_accounts (id_account) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `claims_kumi_accounts_history`
--
CREATE TABLE IF NOT EXISTS claims_kumi_accounts_history (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  id_claim int(11) NOT NULL,
  id_account int(11) NOT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 65,
AVG_ROW_LENGTH = 862,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE claims_kumi_accounts_history
ADD CONSTRAINT FK_claims_kumi_accounts_histo2 FOREIGN KEY (id_account)
REFERENCES kumi_accounts (id_account) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `claim_states`
--
CREATE TABLE IF NOT EXISTS claim_states (
  id_state int(11) NOT NULL AUTO_INCREMENT,
  id_claim int(11) NOT NULL COMMENT 'Индекс иска',
  id_state_type int(11) NOT NULL COMMENT 'Индекс типа состояния',
  date_start_state date DEFAULT NULL COMMENT 'Дата установки состояния',
  executor varchar(255) DEFAULT NULL,
  description text DEFAULT NULL COMMENT 'Примечание',
  bks_requester varchar(255) DEFAULT NULL COMMENT 'Кто сделал запрос в бкс',
  transfert_to_legal_department_date datetime DEFAULT NULL COMMENT 'Дата передачи в юр. отдел',
  transfer_to_legal_department_who varchar(255) DEFAULT NULL COMMENT 'Кем передано в юр. отдел',
  accepted_by_legal_department_date datetime DEFAULT NULL COMMENT 'Дата принятия в юр. отдел',
  accepted_by_legal_department_who varchar(255) DEFAULT NULL COMMENT 'Кем принято в юр. отдел',
  claim_direction_date datetime DEFAULT NULL COMMENT 'Дата направления искового заявления в суд',
  claim_direction_description varchar(255) DEFAULT NULL COMMENT 'Примечание к направлению искового заявления в суд',
  court_order_date datetime DEFAULT NULL COMMENT 'Дата вынесения судебного приказа',
  court_order_num varchar(255) DEFAULT NULL COMMENT 'Номер судебного приказа',
  obtaining_court_order_date datetime DEFAULT NULL COMMENT 'Дата получения судебного приказа',
  obtaining_court_order_description varchar(255) DEFAULT NULL COMMENT 'Примечание к получению судебного приказа',
  direction_court_order_bailiffs_date datetime DEFAULT NULL COMMENT 'Дата направелния судебного приказа приставам',
  direction_court_order_bailiffs_description varchar(255) DEFAULT NULL COMMENT 'Примечание к направлению судебного приказа приставам',
  enforcement_proceeding_start_date datetime DEFAULT NULL COMMENT 'Дата возбуждения исполнительного производства',
  enforcement_proceeding_start_description varchar(255) DEFAULT NULL COMMENT 'Примечание к возбуждению исполнительного производства',
  enforcement_proceeding_end_date datetime DEFAULT NULL COMMENT 'Дата окончания исполнительного производства',
  enforcement_proceeding_end_description varchar(255) DEFAULT NULL COMMENT 'Примечание к окончанию исполнительного производства',
  enforcement_proceeding_terminate_date datetime DEFAULT NULL COMMENT 'Дата прекращения исполнительного производства',
  enforcement_proceeding_terminate_description varchar(255) DEFAULT NULL COMMENT 'Примечание к прекращению исполнительного производства',
  repeated_direction_court_order_bailiffs_date datetime DEFAULT NULL COMMENT 'Дата повторного направления с/п приставам',
  repeated_direction_court_order_bailiffs_description varchar(255) DEFAULT NULL COMMENT 'Примечание к повторному направлению с/п к приставам',
  repeated_enforcement_proceeding_start_date datetime DEFAULT NULL COMMENT 'Дата повторного возбуждения исполнительного производства',
  repeated_enforcement_proceeding_start_description varchar(255) DEFAULT NULL COMMENT 'Примечание к повторному возбуждению исполнительного производства',
  repeated_enforcement_proceeding_end_date datetime DEFAULT NULL COMMENT 'Дата повторного окончания исполнительного производства',
  repeated_enforcement_proceeding_end_description varchar(255) DEFAULT NULL COMMENT 'Примечание к повторному окончанию исполнительного производства',
  court_order_cancel_date datetime DEFAULT NULL COMMENT 'Дата отмены судебного приказа',
  court_order_cancel_description varchar(255) DEFAULT NULL COMMENT 'Примечание к отмене судебного приказа',
  claim_complete_date datetime DEFAULT NULL COMMENT 'Дата завершения претензионно-исковой работы',
  claim_complete_description varchar(255) DEFAULT NULL COMMENT 'Примечание к завершению претензионно-исковой работы',
  claim_complete_reason varchar(255) DEFAULT NULL COMMENT 'Причина завершения претензионно-исковой работы',
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_state)
)
ENGINE = INNODB,
AUTO_INCREMENT = 62295,
AVG_ROW_LENGTH = 3276,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Состояния исковой работы';

--
-- Создать индекс `IDX_claim_states_court_order_num` для объекта типа таблица `claim_states`
--
ALTER TABLE claim_states
ADD INDEX IDX_claim_states_court_order_num (court_order_num);

DELIMITER $$

--
-- Создать триггер `claim_states_after_insert`
--
CREATE TRIGGER claim_states_after_insert
AFTER INSERT
ON claim_states
FOR EACH ROW
BEGIN
  IF (NEW.id_claim IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'id_claim', NULL, NEW.id_claim, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_state_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'id_state_type', NULL, NEW.id_state_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_start_state IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'date_start_state', NULL, NEW.date_start_state, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.executor IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'executor', NULL, NEW.executor, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.bks_requester IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'bks_requester', NULL, NEW.bks_requester, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.transfert_to_legal_department_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'transfert_to_legal_department_date', NULL, NEW.transfert_to_legal_department_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.transfer_to_legal_department_who IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'transfer_to_legal_department_who', NULL, NEW.transfer_to_legal_department_who, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.accepted_by_legal_department_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'accepted_by_legal_department_date', NULL, NEW.accepted_by_legal_department_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.accepted_by_legal_department_who IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'accepted_by_legal_department_who', NULL, NEW.accepted_by_legal_department_who, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.claim_direction_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'claim_direction_date', NULL, NEW.claim_direction_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.claim_direction_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'claim_direction_description', NULL, NEW.claim_direction_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.court_order_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'court_order_date', NULL, NEW.court_order_date, 'INSERT', NOW(), USER());
    IF (EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account = (SELECT
            c.id_account_kumi
          FROM claims c
          WHERE c.id_claim = NEW.id_claim)
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = CONCAT('По исковой работе № ', NEW.id_claim, ' вынесен судебный приказ')
      WHERE ka.id_account = (SELECT
          c.id_account_kumi
        FROM claims c
        WHERE c.id_claim = NEW.id_claim);
    END IF;
  END IF;
  IF (NEW.court_order_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'court_order_num', NULL, NEW.court_order_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.obtaining_court_order_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'obtaining_court_order_date', NULL, NEW.obtaining_court_order_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.obtaining_court_order_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'obtaining_court_order_description', NULL, NEW.obtaining_court_order_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.direction_court_order_bailiffs_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'direction_court_order_bailiffs_date', NULL, NEW.direction_court_order_bailiffs_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.direction_court_order_bailiffs_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'direction_court_order_bailiffs_description', NULL, NEW.direction_court_order_bailiffs_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.enforcement_proceeding_start_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'enforcement_proceeding_start_date', NULL, NEW.enforcement_proceeding_start_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.enforcement_proceeding_start_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'enforcement_proceeding_start_description', NULL, NEW.enforcement_proceeding_start_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.enforcement_proceeding_end_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'enforcement_proceeding_end_date', NULL, NEW.enforcement_proceeding_end_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.enforcement_proceeding_end_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'enforcement_proceeding_end_description', NULL, NEW.enforcement_proceeding_end_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.enforcement_proceeding_terminate_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'enforcement_proceeding_terminate_date', NULL, NEW.enforcement_proceeding_terminate_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.enforcement_proceeding_terminate_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'enforcement_proceeding_terminate_description', NULL, NEW.enforcement_proceeding_terminate_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.repeated_direction_court_order_bailiffs_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'repeated_direction_court_order_bailiffs_date', NULL, NEW.repeated_direction_court_order_bailiffs_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.repeated_direction_court_order_bailiffs_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'repeated_direction_court_order_bailiffs_description', NULL, NEW.repeated_direction_court_order_bailiffs_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.repeated_enforcement_proceeding_start_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'repeated_enforcement_proceeding_start_date', NULL, NEW.repeated_enforcement_proceeding_start_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.repeated_enforcement_proceeding_start_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'repeated_enforcement_proceeding_start_description', NULL, NEW.repeated_enforcement_proceeding_start_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.repeated_enforcement_proceeding_end_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'repeated_enforcement_proceeding_end_date', NULL, NEW.repeated_enforcement_proceeding_end_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.repeated_enforcement_proceeding_end_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'repeated_enforcement_proceeding_end_description', NULL, NEW.repeated_enforcement_proceeding_end_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.court_order_cancel_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'court_order_cancel_date', NULL, NEW.court_order_cancel_date, 'INSERT', NOW(), USER());
    IF (EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account = (SELECT
            c.id_account_kumi
          FROM claims c
          WHERE c.id_claim = NEW.id_claim)
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = CONCAT('По исковой работе № ', NEW.id_claim, ' отменен судебный приказ')
      WHERE ka.id_account = (SELECT
          c.id_account_kumi
        FROM claims c
        WHERE c.id_claim = NEW.id_claim);
    END IF;
  END IF;
  IF (NEW.court_order_cancel_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'court_order_cancel_description', NULL, NEW.court_order_cancel_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.claim_complete_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'claim_complete_date', NULL, NEW.claim_complete_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.claim_complete_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'claim_complete_description', NULL, NEW.claim_complete_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.claim_complete_reason IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'claim_complete_reason', NULL, NEW.claim_complete_reason, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `claim_states_after_update`
--
CREATE TRIGGER claim_states_after_update
AFTER UPDATE
ON claim_states
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_states', NEW.id_state, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
    IF (NEW.court_order_cancel_date IS NOT NULL
      AND NEW.id_state_type = 6
      AND EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account = (SELECT
            c.id_account_kumi
          FROM claims c
          WHERE c.id_claim = NEW.id_claim)
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = CONCAT('По исковой работе № ', NEW.id_claim, ' удалена стадия с отменой судебного приказа')
      WHERE ka.id_account = (SELECT
          c.id_account_kumi
        FROM claims c
        WHERE c.id_claim = NEW.id_claim);
    END IF;
    IF (NEW.court_order_date IS NOT NULL
      AND NEW.id_state_type = 4
      AND EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account = (SELECT
            c.id_account_kumi
          FROM claims c
          WHERE c.id_claim = NEW.id_claim)
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = CONCAT('По исковой работе № ', NEW.id_claim, ' удалена стадия с вынесением судебного приказа')
      WHERE ka.id_account = (SELECT
          c.id_account_kumi
        FROM claims c
        WHERE c.id_claim = NEW.id_claim);
    END IF;
  ELSE
    IF (NEW.id_claim <> OLD.id_claim) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'id_claim', OLD.id_claim, NEW.id_claim, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_state_type <> OLD.id_state_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'id_state_type', OLD.id_state_type, NEW.id_state_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_start_state IS NULL
      AND OLD.date_start_state IS NULL)
      AND ((NEW.date_start_state IS NULL
      AND OLD.date_start_state IS NOT NULL)
      OR (NEW.date_start_state IS NOT NULL
      AND OLD.date_start_state IS NULL)
      OR (NEW.date_start_state <> OLD.date_start_state))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'date_start_state', OLD.date_start_state, NEW.date_start_state, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.executor IS NULL
      AND OLD.executor IS NULL)
      AND ((NEW.executor IS NULL
      AND OLD.executor IS NOT NULL)
      OR (NEW.executor IS NOT NULL
      AND OLD.executor IS NULL)
      OR (NEW.executor <> OLD.executor))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'executor', OLD.executor, NEW.executor, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.bks_requester IS NULL
      AND OLD.bks_requester IS NULL)
      AND ((NEW.bks_requester IS NULL
      AND OLD.bks_requester IS NOT NULL)
      OR (NEW.bks_requester IS NOT NULL
      AND OLD.bks_requester IS NULL)
      OR (NEW.bks_requester <> OLD.bks_requester))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'bks_requester', OLD.bks_requester, NEW.bks_requester, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.transfert_to_legal_department_date IS NULL
      AND OLD.transfert_to_legal_department_date IS NULL)
      AND ((NEW.transfert_to_legal_department_date IS NULL
      AND OLD.transfert_to_legal_department_date IS NOT NULL)
      OR (NEW.transfert_to_legal_department_date IS NOT NULL
      AND OLD.transfert_to_legal_department_date IS NULL)
      OR (NEW.transfert_to_legal_department_date <> OLD.transfert_to_legal_department_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'transfert_to_legal_department_date', OLD.transfert_to_legal_department_date, NEW.transfert_to_legal_department_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.transfer_to_legal_department_who IS NULL
      AND OLD.transfer_to_legal_department_who IS NULL)
      AND ((NEW.transfer_to_legal_department_who IS NULL
      AND OLD.transfer_to_legal_department_who IS NOT NULL)
      OR (NEW.transfer_to_legal_department_who IS NOT NULL
      AND OLD.transfer_to_legal_department_who IS NULL)
      OR (NEW.transfer_to_legal_department_who <> OLD.transfer_to_legal_department_who))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'transfer_to_legal_department_who', OLD.transfer_to_legal_department_who, NEW.transfer_to_legal_department_who, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.accepted_by_legal_department_date IS NULL
      AND OLD.accepted_by_legal_department_date IS NULL)
      AND ((NEW.accepted_by_legal_department_date IS NULL
      AND OLD.accepted_by_legal_department_date IS NOT NULL)
      OR (NEW.accepted_by_legal_department_date IS NOT NULL
      AND OLD.accepted_by_legal_department_date IS NULL)
      OR (NEW.accepted_by_legal_department_date <> OLD.accepted_by_legal_department_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'accepted_by_legal_department_date', OLD.accepted_by_legal_department_date, NEW.accepted_by_legal_department_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.accepted_by_legal_department_who IS NULL
      AND OLD.accepted_by_legal_department_who IS NULL)
      AND ((NEW.accepted_by_legal_department_who IS NULL
      AND OLD.accepted_by_legal_department_who IS NOT NULL)
      OR (NEW.accepted_by_legal_department_who IS NOT NULL
      AND OLD.accepted_by_legal_department_who IS NULL)
      OR (NEW.accepted_by_legal_department_who <> OLD.accepted_by_legal_department_who))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'accepted_by_legal_department_who', OLD.accepted_by_legal_department_who, NEW.accepted_by_legal_department_who, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.claim_direction_date IS NULL
      AND OLD.claim_direction_date IS NULL)
      AND ((NEW.claim_direction_date IS NULL
      AND OLD.claim_direction_date IS NOT NULL)
      OR (NEW.claim_direction_date IS NOT NULL
      AND OLD.claim_direction_date IS NULL)
      OR (NEW.claim_direction_date <> OLD.claim_direction_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'claim_direction_date', OLD.claim_direction_date, NEW.claim_direction_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.claim_direction_description IS NULL
      AND OLD.claim_direction_description IS NULL)
      AND ((NEW.claim_direction_description IS NULL
      AND OLD.claim_direction_description IS NOT NULL)
      OR (NEW.claim_direction_description IS NOT NULL
      AND OLD.claim_direction_description IS NULL)
      OR (NEW.claim_direction_description <> OLD.claim_direction_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'claim_direction_description', OLD.claim_direction_description, NEW.claim_direction_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.court_order_date IS NULL
      AND OLD.court_order_date IS NULL)
      AND ((NEW.court_order_date IS NULL
      AND OLD.court_order_date IS NOT NULL)
      OR (NEW.court_order_date IS NOT NULL
      AND OLD.court_order_date IS NULL)
      OR (NEW.court_order_date <> OLD.court_order_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'court_order_date', OLD.court_order_date, NEW.court_order_date, 'UPDATE', NOW(), USER());
      IF (NEW.court_order_date IS NOT NULL
        AND EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = (SELECT
              c.id_account_kumi
            FROM claims c
            WHERE c.id_claim = NEW.id_claim)
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = CONCAT('По исковой работе № ', NEW.id_claim, ' вынесен судебный приказ')
        WHERE ka.id_account = (SELECT
            c.id_account_kumi
          FROM claims c
          WHERE c.id_claim = NEW.id_claim);
      END IF;
      IF (NEW.court_order_date IS NULL
        AND EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = (SELECT
              c.id_account_kumi
            FROM claims c
            WHERE c.id_claim = NEW.id_claim)
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = CONCAT('По исковой работе № ', NEW.id_claim, ' удален судебный приказ')
        WHERE ka.id_account = (SELECT
            c.id_account_kumi
          FROM claims c
          WHERE c.id_claim = NEW.id_claim);
      END IF;
    END IF;
    IF (NOT (NEW.court_order_num IS NULL
      AND OLD.court_order_num IS NULL)
      AND ((NEW.court_order_num IS NULL
      AND OLD.court_order_num IS NOT NULL)
      OR (NEW.court_order_num IS NOT NULL
      AND OLD.court_order_num IS NULL)
      OR (NEW.court_order_num <> OLD.court_order_num))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'court_order_num', OLD.court_order_num, NEW.court_order_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.obtaining_court_order_date IS NULL
      AND OLD.obtaining_court_order_date IS NULL)
      AND ((NEW.obtaining_court_order_date IS NULL
      AND OLD.obtaining_court_order_date IS NOT NULL)
      OR (NEW.obtaining_court_order_date IS NOT NULL
      AND OLD.obtaining_court_order_date IS NULL)
      OR (NEW.obtaining_court_order_date <> OLD.obtaining_court_order_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'obtaining_court_order_date', OLD.obtaining_court_order_date, NEW.obtaining_court_order_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.obtaining_court_order_description IS NULL
      AND OLD.obtaining_court_order_description IS NULL)
      AND ((NEW.obtaining_court_order_description IS NULL
      AND OLD.obtaining_court_order_description IS NOT NULL)
      OR (NEW.obtaining_court_order_description IS NOT NULL
      AND OLD.obtaining_court_order_description IS NULL)
      OR (NEW.obtaining_court_order_description <> OLD.obtaining_court_order_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'obtaining_court_order_description', OLD.obtaining_court_order_description, NEW.obtaining_court_order_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.direction_court_order_bailiffs_date IS NULL
      AND OLD.direction_court_order_bailiffs_date IS NULL)
      AND ((NEW.direction_court_order_bailiffs_date IS NULL
      AND OLD.direction_court_order_bailiffs_date IS NOT NULL)
      OR (NEW.direction_court_order_bailiffs_date IS NOT NULL
      AND OLD.direction_court_order_bailiffs_date IS NULL)
      OR (NEW.direction_court_order_bailiffs_date <> OLD.direction_court_order_bailiffs_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'direction_court_order_bailiffs_date', OLD.direction_court_order_bailiffs_date, NEW.direction_court_order_bailiffs_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.direction_court_order_bailiffs_description IS NULL
      AND OLD.direction_court_order_bailiffs_description IS NULL)
      AND ((NEW.direction_court_order_bailiffs_description IS NULL
      AND OLD.direction_court_order_bailiffs_description IS NOT NULL)
      OR (NEW.direction_court_order_bailiffs_description IS NOT NULL
      AND OLD.direction_court_order_bailiffs_description IS NULL)
      OR (NEW.direction_court_order_bailiffs_description <> OLD.direction_court_order_bailiffs_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'direction_court_order_bailiffs_description', OLD.direction_court_order_bailiffs_description, NEW.direction_court_order_bailiffs_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.enforcement_proceeding_start_date IS NULL
      AND OLD.enforcement_proceeding_start_date IS NULL)
      AND ((NEW.enforcement_proceeding_start_date IS NULL
      AND OLD.enforcement_proceeding_start_date IS NOT NULL)
      OR (NEW.enforcement_proceeding_start_date IS NOT NULL
      AND OLD.enforcement_proceeding_start_date IS NULL)
      OR (NEW.enforcement_proceeding_start_date <> OLD.enforcement_proceeding_start_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'enforcement_proceeding_start_date', OLD.enforcement_proceeding_start_date, NEW.enforcement_proceeding_start_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.enforcement_proceeding_start_description IS NULL
      AND OLD.enforcement_proceeding_start_description IS NULL)
      AND ((NEW.enforcement_proceeding_start_description IS NULL
      AND OLD.enforcement_proceeding_start_description IS NOT NULL)
      OR (NEW.enforcement_proceeding_start_description IS NOT NULL
      AND OLD.enforcement_proceeding_start_description IS NULL)
      OR (NEW.enforcement_proceeding_start_description <> OLD.enforcement_proceeding_start_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'enforcement_proceeding_start_description', OLD.enforcement_proceeding_start_description, NEW.enforcement_proceeding_start_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.enforcement_proceeding_end_date IS NULL
      AND OLD.enforcement_proceeding_end_date IS NULL)
      AND ((NEW.enforcement_proceeding_end_date IS NULL
      AND OLD.enforcement_proceeding_end_date IS NOT NULL)
      OR (NEW.enforcement_proceeding_end_date IS NOT NULL
      AND OLD.enforcement_proceeding_end_date IS NULL)
      OR (NEW.enforcement_proceeding_end_date <> OLD.enforcement_proceeding_end_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'enforcement_proceeding_end_date', OLD.enforcement_proceeding_end_date, NEW.enforcement_proceeding_end_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.enforcement_proceeding_end_description IS NULL
      AND OLD.enforcement_proceeding_end_description IS NULL)
      AND ((NEW.enforcement_proceeding_end_description IS NULL
      AND OLD.enforcement_proceeding_end_description IS NOT NULL)
      OR (NEW.enforcement_proceeding_end_description IS NOT NULL
      AND OLD.enforcement_proceeding_end_description IS NULL)
      OR (NEW.enforcement_proceeding_end_description <> OLD.enforcement_proceeding_end_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'enforcement_proceeding_end_description', OLD.enforcement_proceeding_end_description, NEW.enforcement_proceeding_end_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.enforcement_proceeding_terminate_date IS NULL
      AND OLD.enforcement_proceeding_terminate_date IS NULL)
      AND ((NEW.enforcement_proceeding_terminate_date IS NULL
      AND OLD.enforcement_proceeding_terminate_date IS NOT NULL)
      OR (NEW.enforcement_proceeding_terminate_date IS NOT NULL
      AND OLD.enforcement_proceeding_terminate_date IS NULL)
      OR (NEW.enforcement_proceeding_terminate_date <> OLD.enforcement_proceeding_terminate_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'enforcement_proceeding_terminate_date', OLD.enforcement_proceeding_terminate_date, NEW.enforcement_proceeding_terminate_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.enforcement_proceeding_terminate_description IS NULL
      AND OLD.enforcement_proceeding_terminate_description IS NULL)
      AND ((NEW.enforcement_proceeding_terminate_description IS NULL
      AND OLD.enforcement_proceeding_terminate_description IS NOT NULL)
      OR (NEW.enforcement_proceeding_terminate_description IS NOT NULL
      AND OLD.enforcement_proceeding_terminate_description IS NULL)
      OR (NEW.enforcement_proceeding_terminate_description <> OLD.enforcement_proceeding_terminate_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'enforcement_proceeding_terminate_description', OLD.enforcement_proceeding_terminate_description, NEW.enforcement_proceeding_terminate_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.repeated_direction_court_order_bailiffs_date IS NULL
      AND OLD.repeated_direction_court_order_bailiffs_date IS NULL)
      AND ((NEW.repeated_direction_court_order_bailiffs_date IS NULL
      AND OLD.repeated_direction_court_order_bailiffs_date IS NOT NULL)
      OR (NEW.repeated_direction_court_order_bailiffs_date IS NOT NULL
      AND OLD.repeated_direction_court_order_bailiffs_date IS NULL)
      OR (NEW.repeated_direction_court_order_bailiffs_date <> OLD.repeated_direction_court_order_bailiffs_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'repeated_direction_court_order_bailiffs_date', OLD.repeated_direction_court_order_bailiffs_date, NEW.repeated_direction_court_order_bailiffs_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.repeated_direction_court_order_bailiffs_description IS NULL
      AND OLD.repeated_direction_court_order_bailiffs_description IS NULL)
      AND ((NEW.repeated_direction_court_order_bailiffs_description IS NULL
      AND OLD.repeated_direction_court_order_bailiffs_description IS NOT NULL)
      OR (NEW.repeated_direction_court_order_bailiffs_description IS NOT NULL
      AND OLD.repeated_direction_court_order_bailiffs_description IS NULL)
      OR (NEW.repeated_direction_court_order_bailiffs_description <> OLD.repeated_direction_court_order_bailiffs_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'repeated_direction_court_order_bailiffs_description', OLD.repeated_direction_court_order_bailiffs_description, NEW.repeated_direction_court_order_bailiffs_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.repeated_enforcement_proceeding_start_date IS NULL
      AND OLD.repeated_enforcement_proceeding_start_date IS NULL)
      AND ((NEW.repeated_enforcement_proceeding_start_date IS NULL
      AND OLD.repeated_enforcement_proceeding_start_date IS NOT NULL)
      OR (NEW.repeated_enforcement_proceeding_start_date IS NOT NULL
      AND OLD.repeated_enforcement_proceeding_start_date IS NULL)
      OR (NEW.repeated_enforcement_proceeding_start_date <> OLD.repeated_enforcement_proceeding_start_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'repeated_enforcement_proceeding_start_date', OLD.repeated_enforcement_proceeding_start_date, NEW.repeated_enforcement_proceeding_start_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.repeated_enforcement_proceeding_start_description IS NULL
      AND OLD.repeated_enforcement_proceeding_start_description IS NULL)
      AND ((NEW.repeated_enforcement_proceeding_start_description IS NULL
      AND OLD.repeated_enforcement_proceeding_start_description IS NOT NULL)
      OR (NEW.repeated_enforcement_proceeding_start_description IS NOT NULL
      AND OLD.repeated_enforcement_proceeding_start_description IS NULL)
      OR (NEW.repeated_enforcement_proceeding_start_description <> OLD.repeated_enforcement_proceeding_start_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'repeated_enforcement_proceeding_start_description', OLD.repeated_enforcement_proceeding_start_description, NEW.repeated_enforcement_proceeding_start_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.repeated_enforcement_proceeding_end_date IS NULL
      AND OLD.repeated_enforcement_proceeding_end_date IS NULL)
      AND ((NEW.repeated_enforcement_proceeding_end_date IS NULL
      AND OLD.repeated_enforcement_proceeding_end_date IS NOT NULL)
      OR (NEW.repeated_enforcement_proceeding_end_date IS NOT NULL
      AND OLD.repeated_enforcement_proceeding_end_date IS NULL)
      OR (NEW.repeated_enforcement_proceeding_end_date <> OLD.repeated_enforcement_proceeding_end_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'repeated_enforcement_proceeding_end_date', OLD.repeated_enforcement_proceeding_end_date, NEW.repeated_enforcement_proceeding_end_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.repeated_enforcement_proceeding_end_description IS NULL
      AND OLD.repeated_enforcement_proceeding_end_description IS NULL)
      AND ((NEW.repeated_enforcement_proceeding_end_description IS NULL
      AND OLD.repeated_enforcement_proceeding_end_description IS NOT NULL)
      OR (NEW.repeated_enforcement_proceeding_end_description IS NOT NULL
      AND OLD.repeated_enforcement_proceeding_end_description IS NULL)
      OR (NEW.repeated_enforcement_proceeding_end_description <> OLD.repeated_enforcement_proceeding_end_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'repeated_enforcement_proceeding_end_description', OLD.repeated_enforcement_proceeding_end_description, NEW.repeated_enforcement_proceeding_end_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.court_order_cancel_date IS NULL
      AND OLD.court_order_cancel_date IS NULL)
      AND ((NEW.court_order_cancel_date IS NULL
      AND OLD.court_order_cancel_date IS NOT NULL)
      OR (NEW.court_order_cancel_date IS NOT NULL
      AND OLD.court_order_cancel_date IS NULL)
      OR (NEW.court_order_cancel_date <> OLD.court_order_cancel_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'court_order_cancel_date', OLD.court_order_cancel_date, NEW.court_order_cancel_date, 'UPDATE', NOW(), USER());

      IF (NEW.court_order_cancel_date IS NOT NULL
        AND EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = (SELECT
              c.id_account_kumi
            FROM claims c
            WHERE c.id_claim = NEW.id_claim)
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = CONCAT('По исковой работе № ', NEW.id_claim, ' отменен судебный приказ')
        WHERE ka.id_account = (SELECT
            c.id_account_kumi
          FROM claims c
          WHERE c.id_claim = NEW.id_claim);
      END IF;
      IF (NEW.court_order_cancel_date IS NULL
        AND EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = (SELECT
              c.id_account_kumi
            FROM claims c
            WHERE c.id_claim = NEW.id_claim)
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = CONCAT('По исковой работе № ', NEW.id_claim, ' убрана отмена судебного приказа')
        WHERE ka.id_account = (SELECT
            c.id_account_kumi
          FROM claims c
          WHERE c.id_claim = NEW.id_claim);
      END IF;
    END IF;
    IF (NOT (NEW.court_order_cancel_description IS NULL
      AND OLD.court_order_cancel_description IS NULL)
      AND ((NEW.court_order_cancel_description IS NULL
      AND OLD.court_order_cancel_description IS NOT NULL)
      OR (NEW.court_order_cancel_description IS NOT NULL
      AND OLD.court_order_cancel_description IS NULL)
      OR (NEW.court_order_cancel_description <> OLD.court_order_cancel_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'court_order_cancel_description', OLD.court_order_cancel_description, NEW.court_order_cancel_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.claim_complete_date IS NULL
      AND OLD.claim_complete_date IS NULL)
      AND ((NEW.claim_complete_date IS NULL
      AND OLD.claim_complete_date IS NOT NULL)
      OR (NEW.claim_complete_date IS NOT NULL
      AND OLD.claim_complete_date IS NULL)
      OR (NEW.claim_complete_date <> OLD.claim_complete_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'claim_complete_date', OLD.claim_complete_date, NEW.claim_complete_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.claim_complete_description IS NULL
      AND OLD.claim_complete_description IS NULL)
      AND ((NEW.claim_complete_description IS NULL
      AND OLD.claim_complete_description IS NOT NULL)
      OR (NEW.claim_complete_description IS NOT NULL
      AND OLD.claim_complete_description IS NULL)
      OR (NEW.claim_complete_description <> OLD.claim_complete_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'claim_complete_description', OLD.claim_complete_description, NEW.claim_complete_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.claim_complete_reason IS NULL
      AND OLD.claim_complete_reason IS NULL)
      AND ((NEW.claim_complete_reason IS NULL
      AND OLD.claim_complete_reason IS NOT NULL)
      OR (NEW.claim_complete_reason IS NOT NULL
      AND OLD.claim_complete_reason IS NULL)
      OR (NEW.claim_complete_reason <> OLD.claim_complete_reason))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_states', NEW.id_state, 'claim_complete_reason', OLD.claim_complete_reason, NEW.claim_complete_reason, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать представление `v_payments_claims_last_state_ids`
--
CREATE
VIEW v_payments_claims_last_state_ids
AS
SELECT
  `cs`.`id_claim` AS `id_claim`,
  MAX(`cs`.`id_state`) AS `max_id_state`
FROM `claim_states` `cs`
WHERE (`cs`.`deleted` <> 1)
GROUP BY `cs`.`id_claim`;

--
-- Создать представление `v_payments_claims_last_state`
--
CREATE
VIEW v_payments_claims_last_state
AS
SELECT
  `cs`.`id_claim` AS `id_claim`,
  `cs`.`id_state_type` AS `id_state_type`
FROM (`v_payments_claims_last_state_ids` `v`
  LEFT JOIN `claim_states` `cs`
    ON ((`v`.`max_id_state` = `cs`.`id_state`)))
WHERE (`cs`.`deleted` <> 1);

--
-- Создать представление `v_claim_court_order_nums`
--
CREATE
VIEW v_claim_court_order_nums
AS
SELECT
  `css`.`id_claim` AS `id_claim`,
  GROUP_CONCAT(`css`.`court_order_num` SEPARATOR ', ') AS `court_order_num`
FROM `claim_states` `css`
WHERE ((`css`.`id_state_type` = 4)
AND (`css`.`court_order_num` IS NOT NULL))
GROUP BY `css`.`id_claim`;

--
-- Создать таблицу `claim_state_types`
--
CREATE TABLE IF NOT EXISTS claim_state_types (
  id_state_type int(11) NOT NULL AUTO_INCREMENT,
  state_type varchar(255) NOT NULL,
  is_start_state_type tinyint(1) NOT NULL DEFAULT 0,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_state_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 9,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Типы состояний';

DELIMITER $$

--
-- Создать триггер `claim_state_types_after_insert`
--
CREATE TRIGGER claim_state_types_after_insert
AFTER INSERT
ON claim_state_types
FOR EACH ROW
BEGIN
  IF (NEW.state_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_types', NEW.id_state_type, 'state_type', NULL, NEW.state_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_start_state_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_types', NEW.id_state_type, 'is_start_state_type', NULL, NEW.is_start_state_type, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `claim_state_types_after_update`
--
CREATE TRIGGER claim_state_types_after_update
AFTER UPDATE
ON claim_state_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_types', NEW.id_state_type, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.state_type <> OLD.state_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_state_types', NEW.id_state_type, 'state_type', OLD.state_type, NEW.state_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.is_start_state_type <> OLD.is_start_state_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_state_types', NEW.id_state_type, 'is_start_state_type', OLD.is_start_state_type, NEW.is_start_state_type, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `claim_state_types_before_update`
--
CREATE TRIGGER claim_state_types_before_update
BEFORE UPDATE
ON claim_state_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM claim_states
        WHERE deleted <> 1
        AND id_state_type = NEW.id_state_type) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить состояние, т.к. существуют претензионно-исковые работы, использующие это состояние';
    END IF;
    UPDATE claim_state_types_relations
    SET deleted = 1
    WHERE id_state_from = NEW.id_state_type;
    UPDATE claim_state_types_relations
    SET deleted = 1
    WHERE id_state_to = NEW.id_state_type;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE claim_state_types_relations
ADD CONSTRAINT FK_claim_state_types_relations_claim_state_types_id_state_type FOREIGN KEY (id_state_from)
REFERENCES claim_state_types (id_state_type) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE claim_state_types_relations
ADD CONSTRAINT FK_claim_state_types_relations_claim_state_types_id_state_type2 FOREIGN KEY (id_state_to)
REFERENCES claim_state_types (id_state_type) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE claim_states
ADD CONSTRAINT FK_claim_states_state_types_id_state_type FOREIGN KEY (id_state_type)
REFERENCES claim_state_types (id_state_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `claim_state_files`
--
CREATE TABLE IF NOT EXISTS claim_state_files (
  id_file int(11) NOT NULL AUTO_INCREMENT,
  id_state int(11) NOT NULL,
  file_name varchar(4096) DEFAULT NULL,
  display_name varchar(255) DEFAULT NULL,
  mime_type varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_file)
)
ENGINE = INNODB,
AUTO_INCREMENT = 472,
AVG_ROW_LENGTH = 264,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `claim_state_files_after_insert`
--
CREATE TRIGGER claim_state_files_after_insert
AFTER INSERT
ON claim_state_files
FOR EACH ROW
BEGIN
  IF (NEW.id_state IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_files', NEW.id_file, 'id_state', NULL, NEW.id_state, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.`file_name` IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_files', NEW.id_file, 'file_name', NULL, NEW.`file_name`, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.display_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_files', NEW.id_file, 'display_name', NULL, NEW.display_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.mime_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_files', NEW.id_file, 'mime_type', NULL, NEW.mime_type, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `claim_state_files_after_update`
--
CREATE TRIGGER claim_state_files_after_update
AFTER UPDATE
ON claim_state_files
FOR EACH ROW
BEGIN
  IF (NEW.id_state <> OLD.id_state) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_files', NEW.id_file, 'id_state', OLD.id_state, NEW.id_state, 'UPDATE', NOW(), USER());
  END IF;
  IF (NOT (NEW.file_name IS NULL
    AND OLD.file_name IS NULL)
    AND ((NEW.file_name IS NULL
    AND OLD.file_name IS NOT NULL)
    OR (NEW.file_name IS NOT NULL
    AND OLD.file_name IS NULL)
    OR (NEW.file_name <> OLD.file_name))) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_files', NEW.id_file, 'file_name', OLD.file_name, NEW.file_name, 'UPDATE', NOW(), USER());
  END IF;
  IF (NOT (NEW.display_name IS NULL
    AND OLD.display_name IS NULL)
    AND ((NEW.display_name IS NULL
    AND OLD.display_name IS NOT NULL)
    OR (NEW.display_name IS NOT NULL
    AND OLD.display_name IS NULL)
    OR (NEW.display_name <> OLD.display_name))) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_files', NEW.id_file, 'display_name', OLD.display_name, NEW.display_name, 'UPDATE', NOW(), USER());
  END IF;
  IF (NOT (NEW.mime_type IS NULL
    AND OLD.mime_type IS NULL)
    AND ((NEW.mime_type IS NULL
    AND OLD.mime_type IS NOT NULL)
    OR (NEW.mime_type IS NOT NULL
    AND OLD.mime_type IS NULL)
    OR (NEW.mime_type <> OLD.mime_type))) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_state_files', NEW.id_file, 'mime_type', OLD.mime_type, NEW.mime_type, 'UPDATE', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE claim_state_files
ADD CONSTRAINT FK_claim_state_files_id_state FOREIGN KEY (id_state)
REFERENCES claim_states (id_state) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `rent_types`
--
CREATE TABLE IF NOT EXISTS rent_types (
  id_rent_type int(11) NOT NULL AUTO_INCREMENT,
  rent_type varchar(50) NOT NULL,
  rent_type_short varchar(10) NOT NULL,
  rent_type_genetive varchar(50) NOT NULL,
  PRIMARY KEY (id_rent_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 6,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `rent_type_categories`
--
CREATE TABLE IF NOT EXISTS rent_type_categories (
  id_rent_type_category int(11) NOT NULL AUTO_INCREMENT,
  id_rent_type int(11) NOT NULL COMMENT 'Тип найма',
  rent_type_category varchar(255) NOT NULL COMMENT 'Категория прав на предоставление ЖП',
  PRIMARY KEY (id_rent_type_category)
)
ENGINE = INNODB,
AUTO_INCREMENT = 25,
AVG_ROW_LENGTH = 862,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE rent_type_categories
ADD CONSTRAINT FK_rent_type_categories_id_rent_type FOREIGN KEY (id_rent_type)
REFERENCES rent_types (id_rent_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `tenancy_processes`
--
CREATE TABLE IF NOT EXISTS tenancy_processes (
  id_process int(11) NOT NULL AUTO_INCREMENT,
  id_executor int(11) DEFAULT NULL COMMENT 'Исполнитель',
  id_rent_type int(11) DEFAULT NULL COMMENT 'Тип найма',
  id_rent_type_category int(11) DEFAULT NULL,
  id_employer int(11) NOT NULL DEFAULT 1,
  id_warrant int(11) DEFAULT NULL COMMENT 'Доверенность',
  registration_num varchar(255) DEFAULT NULL COMMENT 'Номер договора найма',
  registration_date date DEFAULT NULL COMMENT 'Дата регистрации договора найма',
  issue_date date DEFAULT NULL COMMENT 'Дата выдачи договора',
  annual_date date DEFAULT NULL,
  begin_date date DEFAULT NULL COMMENT 'Дата начала действия договора',
  end_date date DEFAULT NULL COMMENT 'Дата окончания действия договора',
  until_dismissal tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Договор на период действия трудовых отношений',
  until_calculations_completed tinyint(1) NOT NULL DEFAULT 0 COMMENT 'До завершения расчетов',
  residence_warrant_num varchar(50) DEFAULT NULL COMMENT 'Номер распоряжения КУМИ',
  residence_warrant_date date DEFAULT NULL COMMENT 'Дата распоряжения КУМИ',
  protocol_num varchar(50) DEFAULT NULL COMMENT 'Номер ордера на проживание',
  protocol_date date DEFAULT NULL COMMENT 'Дата ордера на проживание',
  description text DEFAULT NULL COMMENT 'Примечание',
  sub_tenancy_date date DEFAULT NULL COMMENT 'Дата реквизита поднайма',
  sub_tenancy_num varchar(255) DEFAULT NULL COMMENT 'Номер реквизита поднайма',
  id_street_mv_emergency varchar(17) DEFAULT NULL,
  house_mv_emergency varchar(10) DEFAULT NULL,
  premise_num_mv_emergency varchar(15) DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_process)
)
ENGINE = INNODB,
AUTO_INCREMENT = 21950,
AVG_ROW_LENGTH = 147,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `FK_tenancy_processes_id_employ` для объекта типа таблица `tenancy_processes`
--
ALTER TABLE tenancy_processes
ADD INDEX FK_tenancy_processes_id_employ (id_employer);

DELIMITER $$

--
-- Создать триггер `tenancy_processes_after_insert`
--
CREATE TRIGGER tenancy_processes_after_insert
AFTER INSERT
ON tenancy_processes
FOR EACH ROW
BEGIN
  IF (NEW.id_rent_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'id_rent_type', NULL, NEW.id_rent_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_rent_type_category IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'id_rent_type_category', NULL, NEW.id_rent_type_category, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_employer IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'id_employer', NULL, NEW.id_employer, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_warrant IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'id_warrant', NULL, NEW.id_warrant, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.registration_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'registration_num', NULL, NEW.registration_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.registration_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'registration_date', NULL, NEW.registration_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.issue_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'issue_date', NULL, NEW.issue_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.annual_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'annual_date', NULL, NEW.annual_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.begin_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'begin_date', NULL, NEW.begin_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.end_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'end_date', NULL, NEW.end_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.until_dismissal IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'until_dismissal', NULL, NEW.until_dismissal, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.until_calculations_completed IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'until_calculations_completed', NULL, NEW.until_calculations_completed, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.residence_warrant_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'residence_warrant_num', NULL, NEW.residence_warrant_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.residence_warrant_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'residence_warrant_date', NULL, NEW.residence_warrant_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.protocol_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'protocol_num', NULL, NEW.protocol_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.protocol_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'protocol_date', NULL, NEW.protocol_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_executor IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'id_executor', NULL, NEW.id_executor, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.sub_tenancy_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'sub_tenancy_date', NULL, NEW.sub_tenancy_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.sub_tenancy_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'sub_tenancy_num', NULL, NEW.sub_tenancy_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_street_mv_emergency IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'id_street_mv_emergency', NULL, NEW.id_street_mv_emergency, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.house_mv_emergency IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'house_mv_emergency', NULL, NEW.house_mv_emergency, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.premise_num_mv_emergency IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'premise_num_mv_emergency', NULL, NEW.premise_num_mv_emergency, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `tenancy_processes_after_update`
--
CREATE TRIGGER tenancy_processes_after_update
AFTER UPDATE
ON tenancy_processes
FOR EACH ROW
BEGIN
  DECLARE updAccount tinyint;
  SET updAccount := 0;
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_processes', NEW.id_process, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
    CALL update_kumi_accounts_address_infix_by_id_process(NEW.id_process);
    IF (EXISTS (SELECT
          *
        FROM kumi_accounts_actual_tp_search_denorm kaatsd
        WHERE kaatsd.id_process = NEW.id_process)) THEN
      CALL update_kumi_accounts_tp_search_by_id_process(NEW.id_process);
    END IF;
  ELSE
    IF (NEW.id_rent_type <> OLD.id_rent_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'id_rent_type', OLD.id_rent_type, NEW.id_rent_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_rent_type_category IS NULL
      AND OLD.id_rent_type_category IS NULL)
      AND ((NEW.id_rent_type_category IS NULL
      AND OLD.id_rent_type_category IS NOT NULL)
      OR (NEW.id_rent_type_category IS NOT NULL
      AND OLD.id_rent_type_category IS NULL)
      OR (NEW.id_rent_type_category <> OLD.id_rent_type_category))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'id_rent_type_category', OLD.id_rent_type_category, NEW.id_rent_type_category, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_employer <> OLD.id_employer) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'id_employer', OLD.id_employer, NEW.id_employer, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_warrant IS NULL
      AND OLD.id_warrant IS NULL)
      AND ((NEW.id_warrant IS NULL
      AND OLD.id_warrant IS NOT NULL)
      OR (NEW.id_warrant IS NOT NULL
      AND OLD.id_warrant IS NULL)
      OR (NEW.id_warrant <> OLD.id_warrant))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'id_warrant', OLD.id_warrant, NEW.id_warrant, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.registration_num IS NULL
      AND OLD.registration_num IS NULL)
      AND ((NEW.registration_num IS NULL
      AND OLD.registration_num IS NOT NULL)
      OR (NEW.registration_num IS NOT NULL
      AND OLD.registration_num IS NULL)
      OR (NEW.registration_num <> OLD.registration_num))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'registration_num', OLD.registration_num, NEW.registration_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.registration_date IS NULL
      AND OLD.registration_date IS NULL)
      AND ((NEW.registration_date IS NULL
      AND OLD.registration_date IS NOT NULL)
      OR (NEW.registration_date IS NOT NULL
      AND OLD.registration_date IS NULL)
      OR (NEW.registration_date <> OLD.registration_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'registration_date', OLD.registration_date, NEW.registration_date, 'UPDATE', NOW(), USER());

      IF (NEW.begin_date IS NULL) THEN
        SET updAccount := 1;
      END IF;
    END IF;
    IF (NOT (NEW.issue_date IS NULL
      AND OLD.issue_date IS NULL)
      AND ((NEW.issue_date IS NULL
      AND OLD.issue_date IS NOT NULL)
      OR (NEW.issue_date IS NOT NULL
      AND OLD.issue_date IS NULL)
      OR (NEW.issue_date <> OLD.issue_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'issue_date', OLD.issue_date, NEW.issue_date, 'UPDATE', NOW(), USER());

      IF (NEW.begin_date IS NULL
        AND NEW.registration_date IS NULL) THEN
        SET updAccount := 1;
      END IF;
    END IF;
    IF (NOT (NEW.begin_date IS NULL
      AND OLD.begin_date IS NULL)
      AND ((NEW.begin_date IS NULL
      AND OLD.begin_date IS NOT NULL)
      OR (NEW.begin_date IS NOT NULL
      AND OLD.begin_date IS NULL)
      OR (NEW.begin_date <> OLD.begin_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'begin_date', OLD.begin_date, NEW.begin_date, 'UPDATE', NOW(), USER());

      SET updAccount := 1;
    END IF;
    IF (NOT (NEW.end_date IS NULL
      AND OLD.end_date IS NULL)
      AND ((NEW.end_date IS NULL
      AND OLD.end_date IS NOT NULL)
      OR (NEW.end_date IS NOT NULL
      AND OLD.end_date IS NULL)
      OR (NEW.end_date <> OLD.end_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'end_date', OLD.end_date, NEW.end_date, 'UPDATE', NOW(), USER());

      -- Если меняется дата окончания в прошедшем периоде, то надо делать перерасчет
      IF ((OLD.end_date IS NOT NULL
        AND MONTH(OLD.end_date) < MONTH(NOW()))
        OR (NEW.end_date IS NOT NULL
        AND MONTH(NEW.end_date) < MONTH(NOW()))) THEN
        SET updAccount := 1;
      END IF;
    END IF;

    IF (NOT (NEW.annual_date IS NULL
      AND OLD.annual_date IS NULL)
      AND ((NEW.annual_date IS NULL
      AND OLD.annual_date IS NOT NULL)
      OR (NEW.annual_date IS NOT NULL
      AND OLD.annual_date IS NULL)
      OR (NEW.annual_date <> OLD.annual_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'annual_date', OLD.annual_date, NEW.annual_date, 'UPDATE', NOW(), USER());

      SET updAccount := 1;
    END IF;

    IF (NEW.until_dismissal <> OLD.until_dismissal) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'until_dismissal', OLD.until_dismissal, NEW.until_dismissal, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.until_calculations_completed <> OLD.until_calculations_completed) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'until_calculations_completed', OLD.until_calculations_completed, NEW.until_calculations_completed, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.residence_warrant_num IS NULL
      AND OLD.residence_warrant_num IS NULL)
      AND ((NEW.residence_warrant_num IS NULL
      AND OLD.residence_warrant_num IS NOT NULL)
      OR (NEW.residence_warrant_num IS NOT NULL
      AND OLD.residence_warrant_num IS NULL)
      OR (NEW.residence_warrant_num <> OLD.residence_warrant_num))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'residence_warrant_num', OLD.residence_warrant_num, NEW.residence_warrant_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.residence_warrant_date IS NULL
      AND OLD.residence_warrant_date IS NULL)
      AND ((NEW.residence_warrant_date IS NULL
      AND OLD.residence_warrant_date IS NOT NULL)
      OR (NEW.residence_warrant_date IS NOT NULL
      AND OLD.residence_warrant_date IS NULL)
      OR (NEW.residence_warrant_date <> OLD.residence_warrant_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'residence_warrant_date', OLD.residence_warrant_date, NEW.residence_warrant_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.protocol_num IS NULL
      AND OLD.protocol_num IS NULL)
      AND ((NEW.protocol_num IS NULL
      AND OLD.protocol_num IS NOT NULL)
      OR (NEW.protocol_num IS NOT NULL
      AND OLD.protocol_num IS NULL)
      OR (NEW.protocol_num <> OLD.protocol_num))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'protocol_num', OLD.protocol_num, NEW.protocol_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.protocol_date IS NULL
      AND OLD.protocol_date IS NULL)
      AND ((NEW.protocol_date IS NULL
      AND OLD.protocol_date IS NOT NULL)
      OR (NEW.protocol_date IS NOT NULL
      AND OLD.protocol_date IS NULL)
      OR (NEW.protocol_date <> OLD.protocol_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'protocol_date', OLD.protocol_date, NEW.protocol_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_executor IS NULL
      AND OLD.id_executor IS NULL)
      AND ((NEW.id_executor IS NULL
      AND OLD.id_executor IS NOT NULL)
      OR (NEW.id_executor IS NOT NULL
      AND OLD.id_executor IS NULL)
      OR (NEW.id_executor <> OLD.id_executor))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'id_executor', OLD.id_executor, NEW.id_executor, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.sub_tenancy_date IS NULL
      AND OLD.sub_tenancy_date IS NULL)
      AND ((NEW.sub_tenancy_date IS NULL
      AND OLD.sub_tenancy_date IS NOT NULL)
      OR (NEW.sub_tenancy_date IS NOT NULL
      AND OLD.sub_tenancy_date IS NULL)
      OR (NEW.sub_tenancy_date <> OLD.sub_tenancy_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'sub_tenancy_date', OLD.sub_tenancy_date, NEW.sub_tenancy_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.sub_tenancy_num IS NULL
      AND OLD.sub_tenancy_num IS NULL)
      AND ((NEW.sub_tenancy_num IS NULL
      AND OLD.sub_tenancy_num IS NOT NULL)
      OR (NEW.sub_tenancy_num IS NOT NULL
      AND OLD.sub_tenancy_num IS NULL)
      OR (NEW.sub_tenancy_num <> OLD.sub_tenancy_num))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'sub_tenancy_num', OLD.sub_tenancy_num, NEW.sub_tenancy_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_street_mv_emergency IS NULL
      AND OLD.id_street_mv_emergency IS NULL)
      AND ((NEW.id_street_mv_emergency IS NULL
      AND OLD.id_street_mv_emergency IS NOT NULL)
      OR (NEW.id_street_mv_emergency IS NOT NULL
      AND OLD.id_street_mv_emergency IS NULL)
      OR (NEW.id_street_mv_emergency <> OLD.id_street_mv_emergency))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'id_street_mv_emergency', OLD.id_street_mv_emergency, NEW.id_street_mv_emergency, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.house_mv_emergency IS NULL
      AND OLD.house_mv_emergency IS NULL)
      AND ((NEW.house_mv_emergency IS NULL
      AND OLD.house_mv_emergency IS NOT NULL)
      OR (NEW.house_mv_emergency IS NOT NULL
      AND OLD.house_mv_emergency IS NULL)
      OR (NEW.house_mv_emergency <> OLD.house_mv_emergency))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'house_mv_emergency', OLD.house_mv_emergency, NEW.house_mv_emergency, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.premise_num_mv_emergency IS NULL
      AND OLD.premise_num_mv_emergency IS NULL)
      AND ((NEW.premise_num_mv_emergency IS NULL
      AND OLD.premise_num_mv_emergency IS NOT NULL)
      OR (NEW.premise_num_mv_emergency IS NOT NULL
      AND OLD.premise_num_mv_emergency IS NULL)
      OR (NEW.premise_num_mv_emergency <> OLD.premise_num_mv_emergency))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_processes', NEW.id_process, 'premise_num_mv_emergency', OLD.premise_num_mv_emergency, NEW.premise_num_mv_emergency, 'UPDATE', NOW(), USER());
    END IF;

    IF (updAccount = 1
      AND EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account IN (SELECT
            katpa.id_account
          FROM kumi_accounts_t_processes_assoc katpa
          WHERE katpa.id_process = NEW.id_process
          AND katpa.deleted <> 1)
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = CONCAT('Изменение периода действия найма № ', NEW.id_process)
      WHERE ka.deleted <> 1
      AND ka.id_account IN (SELECT
          katpa.id_account
        FROM kumi_accounts_t_processes_assoc katpa
        WHERE katpa.id_process = NEW.id_process
        AND katpa.deleted <> 1);
    END IF;
    CALL update_kumi_accounts_tp_search_by_id_process(NEW.id_process);
  END IF;
END
$$

--
-- Создать триггер `tenancy_processes_before_update`
--
CREATE TRIGGER tenancy_processes_before_update
BEFORE UPDATE
ON tenancy_processes
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    SET @deleting_tenancy_process = 1;
    UPDATE tenancy_buildings_assoc
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE tenancy_premises_assoc
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE tenancy_sub_premises_assoc
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE tenancy_reasons
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE tenancy_agreements
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE tenancy_persons
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE tenancy_notifies
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    UPDATE tenancy_rent_periods_history
    SET deleted = 1
    WHERE id_process = NEW.id_process;
    SET @deleting_tenancy_process = NULL;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_processes
ADD CONSTRAINT FK_tenancy_contracts_rent_types_id_rent_type FOREIGN KEY (id_rent_type)
REFERENCES rent_types (id_rent_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_processes
ADD CONSTRAINT FK_tenancy_processes_id_rent_type_category FOREIGN KEY (id_rent_type_category)
REFERENCES rent_type_categories (id_rent_type_category) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_accounts_actual_tp_search_denorm
ADD CONSTRAINT FK_kumi_accounts_actual_tp_se2 FOREIGN KEY (id_process)
REFERENCES tenancy_processes (id_process) ON DELETE NO ACTION;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_accounts_t_processes_assoc
ADD CONSTRAINT FK_kumi_accounts_t_processes_a FOREIGN KEY (id_process)
REFERENCES tenancy_processes (id_process) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_agreements
ADD CONSTRAINT FK_agreements_tenancy_contracts_id_contract FOREIGN KEY (id_process)
REFERENCES tenancy_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_buildings_assoc
ADD CONSTRAINT FK_tenancy_buildings_assoc_tenancy_contracts_id_contract FOREIGN KEY (id_process)
REFERENCES tenancy_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_notifies
ADD CONSTRAINT FK_tenancy_notifies_history_tenancy_processes_id_process FOREIGN KEY (id_process)
REFERENCES tenancy_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_premises_assoc
ADD CONSTRAINT FK_tenancy_premises_assoc_tenancy_contracts_id_contract FOREIGN KEY (id_process)
REFERENCES tenancy_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_reasons
ADD CONSTRAINT FK_contract_reasons_tenancy_contracts_id_contract FOREIGN KEY (id_process)
REFERENCES tenancy_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_rent_periods_history
ADD CONSTRAINT FK_tenancy_rent_periods_history_tenancy_processes_id_process FOREIGN KEY (id_process)
REFERENCES tenancy_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_sub_premises_assoc
ADD CONSTRAINT FK_tenancy_sub_premises_assoc_tenancy_contracts_id_contract FOREIGN KEY (id_process)
REFERENCES tenancy_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `tenancy_files`
--
CREATE TABLE IF NOT EXISTS tenancy_files (
  id_file int(11) NOT NULL AUTO_INCREMENT,
  id_process int(11) NOT NULL,
  description varchar(255) DEFAULT NULL,
  file_name varchar(255) NOT NULL,
  display_name varchar(255) DEFAULT NULL,
  mime_type varchar(255) DEFAULT 'application/octet-stream',
  PRIMARY KEY (id_file)
)
ENGINE = INNODB,
AUTO_INCREMENT = 8,
AVG_ROW_LENGTH = 264,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_files
ADD CONSTRAINT FK_tenancy_files_id_process FOREIGN KEY (id_process)
REFERENCES tenancy_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `executors`
--
CREATE TABLE IF NOT EXISTS executors (
  id_executor int(11) NOT NULL AUTO_INCREMENT,
  executor_post varchar(100) DEFAULT NULL,
  executor_name varchar(255) NOT NULL,
  executor_login varchar(255) DEFAULT NULL,
  phone varchar(255) DEFAULT NULL,
  email varchar(255) DEFAULT NULL,
  is_inactive tinyint(1) NOT NULL DEFAULT 0,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  id_specialist int(11) DEFAULT NULL,
  PRIMARY KEY (id_executor)
)
ENGINE = INNODB,
AUTO_INCREMENT = 65538,
AVG_ROW_LENGTH = 2340,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `executors_after_insert`
--
CREATE TRIGGER executors_after_insert
AFTER INSERT
ON executors
FOR EACH ROW
BEGIN
  IF (NEW.executor_post IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'executors', NEW.id_executor, 'executor_post', NULL, NEW.executor_post, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.executor_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'executors', NEW.id_executor, 'executor_name', NULL, NEW.executor_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.executor_login IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'executors', NEW.id_executor, 'executor_login', NULL, NEW.executor_login, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.phone IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'executors', NEW.id_executor, 'phone', NULL, NEW.phone, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.email IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'executors', NEW.id_executor, 'email', NULL, NEW.email, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_inactive IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'executors', NEW.id_executor, 'is_inactive', NULL, NEW.is_inactive, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_specialist IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'executors', NEW.id_executor, 'id_specialist', NULL, NEW.id_specialist, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `executors_after_update`
--
CREATE TRIGGER executors_after_update
AFTER UPDATE
ON executors
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'executors', NEW.id_executor, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NOT (NEW.executor_post IS NULL
      AND OLD.executor_post IS NULL)
      AND ((NEW.executor_post IS NULL
      AND OLD.executor_post IS NOT NULL)
      OR (NEW.executor_post IS NOT NULL
      AND OLD.executor_post IS NULL)
      OR (NEW.executor_post <> OLD.executor_post))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'executors', NEW.id_executor, 'executor_post', OLD.executor_post, NEW.executor_post, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.executor_name <> OLD.executor_name) THEN
      INSERT INTO `log`
        VALUES (NULL, 'executors', NEW.id_executor, 'executor_name', OLD.executor_name, NEW.executor_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.executor_login IS NULL
      AND OLD.executor_login IS NULL)
      AND ((NEW.executor_login IS NULL
      AND OLD.executor_login IS NOT NULL)
      OR (NEW.executor_login IS NOT NULL
      AND OLD.executor_login IS NULL)
      OR (NEW.executor_login <> OLD.executor_login))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'executors', NEW.id_executor, 'executor_login', OLD.executor_login, NEW.executor_login, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.phone IS NULL
      AND OLD.phone IS NULL)
      AND ((NEW.phone IS NULL
      AND OLD.phone IS NOT NULL)
      OR (NEW.phone IS NOT NULL
      AND OLD.phone IS NULL)
      OR (NEW.phone <> OLD.phone))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'executors', NEW.id_executor, 'phone', OLD.phone, NEW.phone, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.email IS NULL
      AND OLD.email IS NULL)
      AND ((NEW.email IS NULL
      AND OLD.email IS NOT NULL)
      OR (NEW.email IS NOT NULL
      AND OLD.email IS NULL)
      OR (NEW.email <> OLD.email))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'executors', NEW.id_executor, 'email', OLD.email, NEW.email, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.is_inactive <> OLD.is_inactive) THEN
      INSERT INTO `log`
        VALUES (NULL, 'executors', NEW.id_executor, 'is_inactive', OLD.is_inactive, NEW.is_inactive, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_specialist IS NULL
      AND OLD.id_specialist IS NULL)
      AND ((NEW.id_specialist IS NULL
      AND OLD.id_specialist IS NOT NULL)
      OR (NEW.id_specialist IS NOT NULL
      AND OLD.id_specialist IS NULL)
      OR (NEW.id_specialist <> OLD.id_specialist))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'executors', NEW.id_executor, 'id_specialist', OLD.id_specialist, NEW.id_specialist, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `executors_before_update`
--
CREATE TRIGGER executors_before_update
BEFORE UPDATE
ON executors
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM tenancy_processes
        WHERE deleted <> 1
        AND id_executor = NEW.id_executor) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить исполнителя, т.к. существуют заведеные им договоры';
    END IF;
    IF ((SELECT
          COUNT(*)
        FROM tenancy_agreements
        WHERE deleted <> 1
        AND id_executor = NEW.id_executor) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить исполнителя, т.к. существуют заведеные им соглашения';
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_agreements
ADD CONSTRAINT FK_agreements_executors_id_executor FOREIGN KEY (id_executor)
REFERENCES executors (id_executor) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_processes
ADD CONSTRAINT FK_tenancy_contracts_executors_id_executor FOREIGN KEY (id_executor)
REFERENCES executors (id_executor) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `resettle_info_sub_premises_from`
--
CREATE TABLE IF NOT EXISTS resettle_info_sub_premises_from (
  id_key int(11) NOT NULL AUTO_INCREMENT,
  id_sub_premises int(11) NOT NULL,
  id_resettle_info int(11) NOT NULL,
  deleted tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_key)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `tenancy_payments_history`
--
CREATE TABLE IF NOT EXISTS tenancy_payments_history (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_building int(11) DEFAULT NULL,
  id_premises int(11) DEFAULT NULL,
  id_sub_premises int(11) DEFAULT NULL,
  rent_area double DEFAULT NULL,
  k1 decimal(7, 5) DEFAULT NULL,
  k2 decimal(2, 1) DEFAULT NULL,
  k3 decimal(2, 1) DEFAULT NULL,
  kc decimal(3, 2) DEFAULT NULL,
  Hb decimal(23, 5) DEFAULT NULL,
  date datetime DEFAULT NULL,
  reason varchar(255) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 230461,
AVG_ROW_LENGTH = 168,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IDX_tenancy_payments_history` для объекта типа таблица `tenancy_payments_history`
--
ALTER TABLE tenancy_payments_history
ADD INDEX IDX_tenancy_payments_history (id_premises, id_sub_premises);

--
-- Создать индекс `IDX_tenancy_payments_history_id_sub_premises` для объекта типа таблица `tenancy_payments_history`
--
ALTER TABLE tenancy_payments_history
ADD INDEX IDX_tenancy_payments_history_id_sub_premises (id_sub_premises);

--
-- Создать таблицу `total_area_avg_cost`
--
CREATE TABLE IF NOT EXISTS total_area_avg_cost (
  id int(11) NOT NULL AUTO_INCREMENT,
  cost decimal(19, 2) NOT NULL,
  date date NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `total_area_avg_cost_after_insert`
--
CREATE TRIGGER total_area_avg_cost_after_insert
AFTER INSERT
ON total_area_avg_cost
FOR EACH ROW
BEGIN
  IF (NEW.id IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'total_area_avg_cost', NEW.id, 'id', NULL, NEW.id, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.cost IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'total_area_avg_cost', NEW.cost, 'cost', NULL, NEW.cost, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'total_area_avg_cost', NEW.date, 'date', NULL, NEW.date, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `total_area_avg_cost_after_update`
--
CREATE TRIGGER total_area_avg_cost_after_update
AFTER UPDATE
ON total_area_avg_cost
FOR EACH ROW
BEGIN
  IF (NEW.cost <> OLD.cost) THEN
    INSERT INTO `log`
      VALUES (NULL, 'total_area_avg_cost', NEW.id, 'cost', OLD.cost, NEW.cost, 'UPDATE', NOW(), USER());
    INSERT INTO tenancy_payments_history (id_building, id_premises, id_sub_premises,
    rent_area, k1, k2, k3, kc, Hb, date, reason)
      SELECT
        vpca.id_building,
        vpca.id_premises,
        vpca.id_sub_premises,
        vpca.rent_area,
        vpca.k1,
        vpca.k2,
        vpca.k3,
        vpca.kc,
        vpca.Hb,
        NEW.date,
        'Изменение цены 1 кв.м жилья на вторичном рынке'
      FROM v_payments_coefficients_all vpca;
    IF (MONTH(NEW.date) < MONTH(NOW())) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = 'Изменение цены 1 кв. м жилья на вторичном рынке'
      WHERE ka.id_state <> 2;
    END IF;
  END IF;
  IF (NEW.date <> OLD.date) THEN
    INSERT INTO `log`
      VALUES (NULL, 'total_area_avg_cost', NEW.id, 'date', OLD.date, NEW.date, 'UPDATE', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `total_area_avg_cost_before_update`
--
CREATE TRIGGER total_area_avg_cost_before_update
BEFORE UPDATE
ON total_area_avg_cost
FOR EACH ROW
BEGIN
  IF (NEW.date <= OLD.date) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Дата должна быть больше ранее внесенной';
  END IF;
  IF (NEW.cost = OLD.cost) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Стоимость квадратного метра не изменена';
  END IF;
END
$$

DELIMITER ;

--
-- Создать представление `v_payments_coefficients_all`
--
CREATE
VIEW v_payments_coefficients_all
AS
SELECT
  CONCAT(`vpp`.`id_building`, IFNULL(CONCAT('/', `vpp`.`id_premises`), ''), IFNULL(CONCAT('/', `vpp`.`id_sub_premises`), '')) AS `key`,
  `vpp`.`id_building` AS `id_building`,
  `vpp`.`id_premises` AS `id_premises`,
  `vpp`.`id_sub_premises` AS `id_sub_premises`,
  IFNULL(`vpp`.`rent_total_area`, `vpp`.`total_area`) AS `rent_area`,
  ((IF((`vpp`.`id_premises_type` = 1), 1.3, 0.8) + IF((`b`.`id_structure_type` IN (4, 9)), 1, IF((`b`.`id_structure_type` = 3), 0.9, IF((`b`.`id_structure_type` IN (2, 5, 6, 8)), 0.8, 0)))) / 2) AS `k1`,
  IF(((`b`.`hot_water_supply` = 1) AND (`b`.`plumbing` = 1) AND (`b`.`canalization` = 1) AND (`vpp`.`id_premises_type` = 1)), 1.3, IF(((`b`.`plumbing` = 1) AND (`b`.`canalization` = 1) AND (`vpp`.`id_premises_type` = 1)), 1, 0.8)) AS `k2`,
  IF((`b`.`id_street` REGEXP '^380000050410'), 1, IF((`b`.`id_street` REGEXP '^380000050230'), 1, IF((`b`.`id_street` REGEXP '^380000050180'), 1, IF((`b`.`id_street` REGEXP '^380000050130'), 0.9, 0.8)))) AS `k3`,
  0.18 AS `kc`,
  ((SELECT
      `total_area_avg_cost`.`cost`
    FROM `total_area_avg_cost`
    ORDER BY `total_area_avg_cost`.`id` DESC LIMIT 1) * 0.001) AS `Hb`
FROM (`v_payments_premises_and_sub_premises` `vpp`
  JOIN `buildings` `b`
    ON ((`vpp`.`id_building` = `b`.`id_building`)));

--
-- Создать таблицу `object_states`
--
CREATE TABLE IF NOT EXISTS object_states (
  id_state int(11) NOT NULL AUTO_INCREMENT,
  state_female varchar(255) NOT NULL,
  state_neutral varchar(255) NOT NULL,
  PRIMARY KEY (id_state)
)
ENGINE = INNODB,
AUTO_INCREMENT = 16,
AVG_ROW_LENGTH = 3276,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Состояния объектов';

--
-- Создать таблицу `sub_premises`
--
CREATE TABLE IF NOT EXISTS sub_premises (
  id_sub_premises int(11) NOT NULL AUTO_INCREMENT,
  id_premises int(11) NOT NULL COMMENT 'Индекс помещения, в котором находится комната',
  id_state int(11) NOT NULL DEFAULT 1 COMMENT 'Текущее состояние объекта',
  sub_premises_num varchar(20) DEFAULT NULL COMMENT 'Номер комнаты',
  total_area double NOT NULL DEFAULT 0 COMMENT 'Общая площадь комнаты',
  living_area double NOT NULL DEFAULT 0 COMMENT 'Жилая площадь комнаты',
  description text DEFAULT NULL COMMENT 'Описание',
  state_date datetime DEFAULT NULL COMMENT 'Дата установки состояния',
  cadastral_num varchar(20) DEFAULT NULL COMMENT 'Кадастровый номер',
  cadastral_cost decimal(19, 2) NOT NULL DEFAULT 0.00 COMMENT 'Кадастровая стоимость',
  balance_cost decimal(19, 2) NOT NULL DEFAULT 0.00 COMMENT 'Балансовая стоимость',
  account varchar(255) DEFAULT NULL COMMENT 'Лицевой счет комнаты',
  deleted tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Запись удалена',
  PRIMARY KEY (id_sub_premises)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1486,
AVG_ROW_LENGTH = 122,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Комнаты в помещении';

DELIMITER $$

--
-- Создать триггер `sub_premises_after_insert`
--
CREATE TRIGGER sub_premises_after_insert
AFTER INSERT
ON sub_premises
FOR EACH ROW
BEGIN
  IF (NEW.id_premises IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'id_premises', NULL, NEW.id_premises, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_state IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'id_state', NULL, NEW.id_state, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.sub_premises_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'sub_premises_num', NULL, NEW.sub_premises_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.total_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'total_area', NULL, NEW.total_area, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.living_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'living_area', NULL, NEW.living_area, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.state_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'state_date', NULL, NEW.state_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.cadastral_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'sub_premises', NEW.id_premises, 'cadastral_num', NULL, NEW.cadastral_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.cadastral_cost IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'sub_premises', NEW.id_premises, 'cadastral_cost', NULL, NEW.cadastral_cost, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.balance_cost IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'sub_premises', NEW.id_premises, 'balance_cost', NULL, NEW.balance_cost, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'sub_premises', NEW.id_premises, 'account', NULL, NEW.account, 'INSERT', NOW(), USER());
  END IF;

  -- Обновление коэффициентов платы за найм
  INSERT INTO tenancy_payments_history (id_building, id_premises, id_sub_premises, rent_area, k1, k2, k3, kc, Hb,
  date, reason)
    SELECT
      vpca.id_building,
      vpca.id_premises,
      vpca.id_sub_premises,
      vpca.rent_area,
      vpca.k1,
      vpca.k2,
      vpca.k3,
      vpca.kc,
      vpca.Hb,
      NOW(),
      'Новая комната'
    FROM v_payments_coefficients_all vpca
    WHERE vpca.id_sub_premises = NEW.id_sub_premises;
END
$$

--
-- Создать триггер `sub_premises_after_update`
--
CREATE TRIGGER sub_premises_after_update
AFTER UPDATE
ON sub_premises
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
    CALL update_kumi_accounts_address_infix_by_id_sub_premise(NEW.id_sub_premises);
  ELSE
    IF (NEW.id_premises <> OLD.id_premises) THEN
      INSERT INTO `log`
        VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'id_premises', OLD.id_premises, NEW.id_premises, 'UPDATE', NOW(), USER());
      CALL update_kumi_accounts_address_infix_by_id_sub_premise(NEW.id_sub_premises);
    END IF;
    IF (NEW.id_state <> OLD.id_state) THEN
      INSERT INTO `log`
        VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'id_state', OLD.id_state, NEW.id_state, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.sub_premises_num IS NULL
      AND OLD.sub_premises_num IS NULL)
      AND ((NEW.sub_premises_num IS NULL
      AND OLD.sub_premises_num IS NOT NULL)
      OR (NEW.sub_premises_num IS NOT NULL
      AND OLD.sub_premises_num IS NULL)
      OR (NEW.sub_premises_num <> OLD.sub_premises_num))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'sub_premises_num', OLD.sub_premises_num, NEW.sub_premises_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.total_area <> OLD.total_area) THEN
      INSERT INTO `log`
        VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'total_area', OLD.total_area, NEW.total_area, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.living_area <> OLD.living_area) THEN
      INSERT INTO `log`
        VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'living_area', OLD.living_area, NEW.living_area, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.state_date IS NULL
      AND OLD.state_date IS NULL)
      AND ((NEW.state_date IS NULL
      AND OLD.state_date IS NOT NULL)
      OR (NEW.state_date IS NOT NULL
      AND OLD.state_date IS NULL)
      OR (NEW.state_date <> OLD.state_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'sub_premises', NEW.id_sub_premises, 'state_date', OLD.state_date, NEW.state_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.cadastral_num IS NULL
      AND OLD.cadastral_num IS NULL)
      AND ((NEW.cadastral_num IS NULL
      AND OLD.cadastral_num IS NOT NULL)
      OR (NEW.cadastral_num IS NOT NULL
      AND OLD.cadastral_num IS NULL)
      OR (NEW.cadastral_num <> OLD.cadastral_num))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'sub_premises', NEW.id_premises, 'cadastral_num', OLD.cadastral_num, NEW.cadastral_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.cadastral_cost <> OLD.cadastral_cost) THEN
      INSERT INTO `log`
        VALUES (NULL, 'sub_premises', NEW.id_premises, 'cadastral_cost', OLD.cadastral_cost, NEW.cadastral_cost, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.balance_cost <> OLD.balance_cost) THEN
      INSERT INTO `log`
        VALUES (NULL, 'sub_premises', NEW.id_premises, 'balance_cost', OLD.balance_cost, NEW.balance_cost, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.account IS NULL
      AND OLD.account IS NULL)
      AND ((NEW.account IS NULL
      AND OLD.account IS NOT NULL)
      OR (NEW.account IS NOT NULL
      AND OLD.account IS NULL)
      OR (NEW.account <> OLD.account))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'sub_premises', NEW.id_premises, 'account', OLD.account, NEW.account, 'UPDATE', NOW(), USER());
    END IF;

    -- Обновление коэффициентов платы за найм
    IF (NEW.total_area <> OLD.total_area) THEN
      INSERT INTO tenancy_payments_history (id_building, id_premises, id_sub_premises, rent_area, k1, k2, k3, kc, Hb,
      date, reason)
        SELECT
          vpca.id_building,
          vpca.id_premises,
          vpca.id_sub_premises,
          vpca.rent_area,
          vpca.k1,
          vpca.k2,
          vpca.k3,
          vpca.kc,
          vpca.Hb,
          NOW(),
          'Изменение характеристик комнаты'
        FROM v_payments_coefficients_all vpca
        WHERE vpca.id_sub_premises = NEW.id_sub_premises;
    END IF;

  END IF;
END
$$

--
-- Создать триггер `sub_premises_before_update`
--
CREATE TRIGGER sub_premises_before_update
BEFORE UPDATE
ON sub_premises
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    UPDATE funds_sub_premises_assoc
    SET deleted = 1
    WHERE id_sub_premises = NEW.id_sub_premises;
    UPDATE tenancy_sub_premises_assoc
    SET deleted = 1
    WHERE id_sub_premises = NEW.id_sub_premises;
    UPDATE resettle_sub_premises_from_assoc
    SET deleted = 1
    WHERE id_sub_premises = NEW.id_sub_premises;
    UPDATE resettle_sub_premises_to_assoc
    SET deleted = 1
    WHERE id_sub_premises = NEW.id_sub_premises;
    UPDATE resettle_info_sub_premises_from
    SET deleted = 1
    WHERE id_sub_premises = NEW.id_sub_premises;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE sub_premises
ADD CONSTRAINT FK_sub_premises_states_id_state FOREIGN KEY (id_state)
REFERENCES object_states (id_state);

--
-- Создать внешний ключ
--
ALTER TABLE funds_sub_premises_assoc
ADD CONSTRAINT FK_funds_sub_premises_assoc_sub_premises_id_sub_premises FOREIGN KEY (id_sub_premises)
REFERENCES sub_premises (id_sub_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_info_sub_premises_from
ADD CONSTRAINT FK_resettle_info_sub_premises_from_id_sub_premises FOREIGN KEY (id_sub_premises)
REFERENCES sub_premises (id_sub_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_sub_premises_from_assoc
ADD CONSTRAINT FK_resettle_sp_from_assoc_sub_premises_id_sub_premises FOREIGN KEY (id_sub_premises)
REFERENCES sub_premises (id_sub_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_sub_premises_to_assoc
ADD CONSTRAINT FK_resettle_sp_to_assoc_sub_premises_id_sub_premises FOREIGN KEY (id_sub_premises)
REFERENCES sub_premises (id_sub_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_payments_history
ADD CONSTRAINT FK_tenancy_payments_history_id_sub_premises FOREIGN KEY (id_sub_premises)
REFERENCES sub_premises (id_sub_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_sub_premises_assoc
ADD CONSTRAINT FK_tenancy_sub_premises_assoc_sub_premises_id_sub_premises FOREIGN KEY (id_sub_premises)
REFERENCES sub_premises (id_sub_premises) ON DELETE CASCADE ON UPDATE CASCADE;

DELIMITER $$

--
-- Создать процедуру `update_kumi_accounts_address_infix_by_id_building`
--
CREATE PROCEDURE update_kumi_accounts_address_infix_by_id_building (IN id_building_param int)
BEGIN
  DELETE
    FROM kumi_accounts_address_infix
  WHERE id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process IN (SELECT
          tba.id_process
        FROM tenancy_buildings_assoc tba
        WHERE tba.deleted <> 1
        AND tba.id_building = id_building_param
        UNION ALL
        SELECT
          tpa.id_process
        FROM tenancy_premises_assoc tpa
          JOIN premises p
            ON tpa.id_premises = p.id_premises
        WHERE tpa.deleted <> 1
        AND p.deleted <> 1
        AND p.id_building = id_building_param
        UNION ALL
        SELECT
          tspa.id_process
        FROM tenancy_sub_premises_assoc tspa
          JOIN sub_premises sp
            ON tspa.id_sub_premises = sp.id_sub_premises
          JOIN premises p
            ON sp.id_premises = p.id_premises
        WHERE tspa.deleted <> 1
        AND sp.deleted <> 1
        AND p.deleted <> 1
        AND p.id_building = id_building_param));

  INSERT INTO kumi_accounts_address_infix (id_account, infix, address, total_area, post_index)
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', b.id_building) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house) AS address,
      b.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_buildings_assoc tba
        ON tp.id_process = tba.id_process
      JOIN buildings b
        ON tba.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process IN (SELECT
          tba.id_process
        FROM tenancy_buildings_assoc tba
        WHERE tba.deleted <> 1
        AND tba.id_building = id_building_param
        UNION ALL
        SELECT
          tpa.id_process
        FROM tenancy_premises_assoc tpa
          JOIN premises p
            ON tpa.id_premises = p.id_premises
        WHERE tpa.deleted <> 1
        AND p.deleted <> 1
        AND p.id_building = id_building_param
        UNION ALL
        SELECT
          tspa.id_process
        FROM tenancy_sub_premises_assoc tspa
          JOIN sub_premises sp
            ON tspa.id_sub_premises = sp.id_sub_premises
          JOIN premises p
            ON sp.id_premises = p.id_premises
        WHERE tspa.deleted <> 1
        AND sp.deleted <> 1
        AND p.deleted <> 1
        AND p.id_building = id_building_param))
    AND tba.deleted <> 1
    AND tp.deleted <> 1
    AND b.deleted <> 1
    AND katpa.deleted <> 1
    UNION ALL
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', p.id_building, 'p', tpa.id_premises) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house, ', ', pt.premises_type_short, ' ', p.premises_num) AS address,
      p.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_premises_assoc tpa
        ON tpa.id_process = tp.id_process
      JOIN premises p
        ON tpa.id_premises = p.id_premises
      JOIN premises_types pt
        ON p.id_premises_type = pt.id_premises_type
      JOIN buildings b
        ON p.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process IN (SELECT
          tba.id_process
        FROM tenancy_buildings_assoc tba
        WHERE tba.deleted <> 1
        AND tba.id_building = id_building_param
        UNION ALL
        SELECT
          tpa.id_process
        FROM tenancy_premises_assoc tpa
          JOIN premises p
            ON tpa.id_premises = p.id_premises
        WHERE tpa.deleted <> 1
        AND p.deleted <> 1
        AND p.id_building = id_building_param
        UNION ALL
        SELECT
          tspa.id_process
        FROM tenancy_sub_premises_assoc tspa
          JOIN sub_premises sp
            ON tspa.id_sub_premises = sp.id_sub_premises
          JOIN premises p
            ON sp.id_premises = p.id_premises
        WHERE tspa.deleted <> 1
        AND sp.deleted <> 1
        AND p.deleted <> 1
        AND p.id_building = id_building_param))
    AND tpa.deleted <> 1
    AND tp.deleted <> 1
    AND p.deleted <> 1
    AND katpa.deleted <> 1
    UNION ALL
    SELECT DISTINCT
      katpa.id_account,
      CONCAT('s', b.id_street, 'b', p.id_building, 'p', p.id_premises, 'sp', tspa.id_sub_premises) AS infix,
      CONCAT(vks.street_name, ', д. ', b.house, ', ', pt.premises_type_short, ' ', p.premises_num, ', к. ', sp.sub_premises_num) AS address,
      sp.total_area,
      b.post_index
    FROM kumi_accounts_t_processes_assoc katpa
      JOIN tenancy_processes tp
        ON katpa.id_process = tp.id_process
      JOIN tenancy_sub_premises_assoc tspa
        ON tspa.id_process = tp.id_process
      JOIN sub_premises sp
        ON tspa.id_sub_premises = sp.id_sub_premises
      JOIN premises p
        ON sp.id_premises = p.id_premises
      JOIN premises_types pt
        ON p.id_premises_type = pt.id_premises_type
      JOIN buildings b
        ON p.id_building = b.id_building
      JOIN v_kladr_streets vks
        ON b.id_street = vks.id_street
    WHERE katpa.id_account IN (SELECT
        k2.id_account
      FROM kumi_accounts_t_processes_assoc k2
      WHERE k2.deleted <> 1
      AND k2.id_process IN (SELECT
          tba.id_process
        FROM tenancy_buildings_assoc tba
        WHERE tba.deleted <> 1
        AND tba.id_building = id_building_param
        UNION ALL
        SELECT
          tpa.id_process
        FROM tenancy_premises_assoc tpa
          JOIN premises p
            ON tpa.id_premises = p.id_premises
        WHERE tpa.deleted <> 1
        AND p.deleted <> 1
        AND p.id_building = id_building_param
        UNION ALL
        SELECT
          tspa.id_process
        FROM tenancy_sub_premises_assoc tspa
          JOIN sub_premises sp
            ON tspa.id_sub_premises = sp.id_sub_premises
          JOIN premises p
            ON sp.id_premises = p.id_premises
        WHERE tspa.deleted <> 1
        AND sp.deleted <> 1
        AND p.deleted <> 1
        AND p.id_building = id_building_param))
    AND tspa.deleted <> 1
    AND tp.deleted <> 1
    AND p.deleted <> 1
    AND katpa.deleted <> 1;

END
$$

DELIMITER ;

--
-- Создать представление `v_registry_full_stat_concated_municipal_sub_premises`
--
CREATE
VIEW v_registry_full_stat_concated_municipal_sub_premises
AS
SELECT
  `sp`.`id_premises` AS `id_premises`,
  GROUP_CONCAT(`sp`.`sub_premises_num` SEPARATOR ',') AS `sub_premises`
FROM `sub_premises` `sp`
WHERE ((`sp`.`id_state` IN (4, 5))
AND (`sp`.`deleted` <> 1))
GROUP BY `sp`.`id_premises`;

--
-- Создать таблицу `priv_estate_owners`
--
CREATE TABLE IF NOT EXISTS priv_estate_owners (
  id_owner int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_owner)
)
ENGINE = INNODB,
AUTO_INCREMENT = 13,
AVG_ROW_LENGTH = 1365,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `selectable_signers`
--
CREATE TABLE IF NOT EXISTS selectable_signers (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  id_signer_group int(11) DEFAULT 1 COMMENT 'Группа подписывающего (для фильтрации)',
  id_owner int(11) DEFAULT NULL,
  surname varchar(50) NOT NULL,
  name varchar(50) NOT NULL,
  patronymic varchar(255) DEFAULT NULL,
  post varchar(255) NOT NULL,
  phone varchar(255) DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 25,
AVG_ROW_LENGTH = 2048,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE selectable_signers
ADD CONSTRAINT FK_selectable_signers_id_owner FOREIGN KEY (id_owner)
REFERENCES priv_estate_owners (id_owner) ON DELETE NO ACTION;

--
-- Создать таблицу `claim_court_orders`
--
CREATE TABLE IF NOT EXISTS claim_court_orders (
  id_order int(11) NOT NULL AUTO_INCREMENT,
  id_claim int(11) NOT NULL,
  id_executor int(11) DEFAULT 18,
  create_date date DEFAULT NULL,
  id_signer int(11) NOT NULL,
  id_judge int(11) NOT NULL,
  order_date date NOT NULL,
  open_account_date date NOT NULL,
  amount_tenancy decimal(12, 2) DEFAULT NULL,
  amount_dgi decimal(12, 2) DEFAULT NULL,
  amount_padun decimal(12, 2) DEFAULT NULL,
  amount_pkk decimal(12, 2) DEFAULT NULL,
  amount_penalties decimal(12, 2) DEFAULT NULL,
  start_dept_period date DEFAULT NULL,
  end_dept_period date DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_order)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4296,
AVG_ROW_LENGTH = 116,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `claim_court_orders_after_insert`
--
CREATE TRIGGER claim_court_orders_after_insert
AFTER INSERT
ON claim_court_orders
FOR EACH ROW
BEGIN
  IF (NEW.id_claim IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'id_claim', NULL, NEW.id_claim, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_executor IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'id_executor', NULL, NEW.id_executor, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.create_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'create_date', NULL, NEW.create_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_signer IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'id_signer', NULL, NEW.id_signer, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_judge IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'id_judge', NULL, NEW.id_judge, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.order_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'order_date', NULL, NEW.order_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.open_account_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'open_account_date', NULL, NEW.open_account_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_tenancy IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'amount_tenancy', NULL, NEW.amount_tenancy, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_dgi IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'amount_dgi', NULL, NEW.amount_dgi, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_padun IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'amount_padun', NULL, NEW.amount_padun, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_pkk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'amount_pkk', NULL, NEW.amount_pkk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_penalties IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'amount_penalties', NULL, NEW.amount_penalties, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.start_dept_period IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'start_dept_period', NULL, NEW.start_dept_period, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.end_dept_period IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'end_dept_period', NULL, NEW.end_dept_period, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `claim_court_orders_after_update`
--
CREATE TRIGGER claim_court_orders_after_update
AFTER UPDATE
ON claim_court_orders
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_court_orders', NEW.id_order, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_claim <> OLD.id_claim) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'id_claim', OLD.id_claim, NEW.id_claim, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_executor <> OLD.id_executor) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'id_executor', OLD.id_executor, NEW.id_executor, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.create_date <> OLD.create_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'create_date', OLD.create_date, NEW.create_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_signer <> OLD.id_signer) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'id_signer', OLD.id_signer, NEW.id_signer, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_judge <> OLD.id_judge) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'id_judge', OLD.id_judge, NEW.id_judge, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.order_date <> OLD.order_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'order_date', OLD.order_date, NEW.order_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.open_account_date <> OLD.open_account_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'open_account_date', OLD.open_account_date, NEW.open_account_date, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.amount_tenancy IS NULL
      AND OLD.amount_tenancy IS NULL)
      AND ((NEW.amount_tenancy IS NULL
      AND OLD.amount_tenancy IS NOT NULL)
      OR (NEW.amount_tenancy IS NOT NULL
      AND OLD.amount_tenancy IS NULL)
      OR (NEW.amount_tenancy <> OLD.amount_tenancy))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'amount_tenancy', OLD.amount_tenancy, NEW.amount_tenancy, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.amount_dgi IS NULL
      AND OLD.amount_dgi IS NULL)
      AND ((NEW.amount_dgi IS NULL
      AND OLD.amount_dgi IS NOT NULL)
      OR (NEW.amount_dgi IS NOT NULL
      AND OLD.amount_dgi IS NULL)
      OR (NEW.amount_dgi <> OLD.amount_dgi))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'amount_dgi', OLD.amount_dgi, NEW.amount_dgi, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.amount_padun IS NULL
      AND OLD.amount_padun IS NULL)
      AND ((NEW.amount_padun IS NULL
      AND OLD.amount_padun IS NOT NULL)
      OR (NEW.amount_padun IS NOT NULL
      AND OLD.amount_padun IS NULL)
      OR (NEW.amount_padun <> OLD.amount_padun))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'amount_padun', OLD.amount_padun, NEW.amount_padun, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.amount_pkk IS NULL
      AND OLD.amount_pkk IS NULL)
      AND ((NEW.amount_pkk IS NULL
      AND OLD.amount_pkk IS NOT NULL)
      OR (NEW.amount_pkk IS NOT NULL
      AND OLD.amount_pkk IS NULL)
      OR (NEW.amount_pkk <> OLD.amount_pkk))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'amount_pkk', OLD.amount_pkk, NEW.amount_pkk, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.amount_penalties IS NULL
      AND OLD.amount_penalties IS NULL)
      AND ((NEW.amount_penalties IS NULL
      AND OLD.amount_penalties IS NOT NULL)
      OR (NEW.amount_penalties IS NOT NULL
      AND OLD.amount_penalties IS NULL)
      OR (NEW.amount_penalties <> OLD.amount_penalties))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'amount_penalties', OLD.amount_penalties, NEW.amount_penalties, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.start_dept_period IS NULL
      AND OLD.start_dept_period IS NULL)
      AND ((NEW.start_dept_period IS NULL
      AND OLD.start_dept_period IS NOT NULL)
      OR (NEW.start_dept_period IS NOT NULL
      AND OLD.start_dept_period IS NULL)
      OR (NEW.start_dept_period <> OLD.start_dept_period))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'start_dept_period', OLD.start_dept_period, NEW.start_dept_period, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.end_dept_period IS NULL
      AND OLD.end_dept_period IS NULL)
      AND ((NEW.end_dept_period IS NULL
      AND OLD.end_dept_period IS NOT NULL)
      OR (NEW.end_dept_period IS NOT NULL
      AND OLD.end_dept_period IS NULL)
      OR (NEW.end_dept_period <> OLD.end_dept_period))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claim_court_orders', NEW.id_order, 'end_dept_period', OLD.end_dept_period, NEW.end_dept_period, 'UPDATE', NOW(), USER());
    END IF;

  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE claim_court_orders
ADD CONSTRAINT FK_claim_court_orders_id_executor FOREIGN KEY (id_executor)
REFERENCES executors (id_executor) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE claim_court_orders
ADD CONSTRAINT FK_claim_court_orders_id_judge FOREIGN KEY (id_judge)
REFERENCES judges (id_judge) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE claim_court_orders
ADD CONSTRAINT FK_claim_court_orders_id_signer FOREIGN KEY (id_signer)
REFERENCES selectable_signers (id_record) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `litigation_premise_assoc`
--
CREATE TABLE IF NOT EXISTS litigation_premise_assoc (
  id_premises int(11) NOT NULL,
  id_litigation int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_premises, id_litigation)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 1170,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `litigation_info`
--
CREATE TABLE IF NOT EXISTS litigation_info (
  id_litigation int(11) NOT NULL AUTO_INCREMENT,
  id_litigation_type int(11) NOT NULL,
  number varchar(50) DEFAULT NULL,
  date date NOT NULL,
  description varchar(255) DEFAULT NULL,
  file_origin_name varchar(255) DEFAULT NULL,
  file_display_name varchar(255) DEFAULT NULL,
  file_mime_type varchar(255) DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_litigation)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `litigation_info_before_update`
--
CREATE TRIGGER litigation_info_before_update
BEFORE UPDATE
ON litigation_info
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    UPDATE litigation_premise_assoc lpa
    SET deleted = 1
    WHERE lpa.id_litigation = NEW.id_litigation;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE litigation_premise_assoc
ADD CONSTRAINT FK_litigation_premise_assoc_id_litigation FOREIGN KEY (id_litigation)
REFERENCES litigation_info (id_litigation) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `litigation_types`
--
CREATE TABLE IF NOT EXISTS litigation_types (
  id_litigation_type int(11) NOT NULL AUTO_INCREMENT,
  litigation_type varchar(255) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_litigation_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 16384,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `litigation_types_before_update`
--
CREATE TRIGGER litigation_types_before_update
BEFORE UPDATE
ON litigation_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM litigation_info
        WHERE deleted <> 1
        AND id_litigation_type = NEW.id_litigation_type) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить тип документа, т.к. существуют судебное разбирательство данного типа';
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE litigation_info
ADD CONSTRAINT FK_litigation_info_id_litigation_type FOREIGN KEY (id_litigation_type)
REFERENCES litigation_types (id_litigation_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `resettle_premise_assoc`
--
CREATE TABLE IF NOT EXISTS resettle_premise_assoc (
  id_premises int(11) NOT NULL,
  id_resettle_info int(11) NOT NULL,
  deleted tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_premises, id_resettle_info)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 50,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `premises_kinds`
--
CREATE TABLE IF NOT EXISTS premises_kinds (
  id_premises_kind int(11) NOT NULL AUTO_INCREMENT,
  premises_kind varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_premises_kind)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Разновидности помещений специализированного жилого фонда';

--
-- Создать таблицу `premises_door_keys`
--
CREATE TABLE IF NOT EXISTS premises_door_keys (
  id_premises_door_keys int(11) NOT NULL AUTO_INCREMENT,
  location_of_keys varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_premises_door_keys)
)
ENGINE = INNODB,
AUTO_INCREMENT = 6,
AVG_ROW_LENGTH = 3276,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Местонахождение ключей';

--
-- Создать таблицу `premises_comments`
--
CREATE TABLE IF NOT EXISTS premises_comments (
  id_premises_comment int(11) NOT NULL AUTO_INCREMENT,
  premises_comment_text varchar(255) NOT NULL,
  PRIMARY KEY (id_premises_comment)
)
ENGINE = INNODB,
AUTO_INCREMENT = 14,
AVG_ROW_LENGTH = 2048,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `premises`
--
CREATE TABLE IF NOT EXISTS premises (
  id_premises int(11) NOT NULL AUTO_INCREMENT,
  id_building int(11) NOT NULL COMMENT 'Индекс здания',
  id_state int(11) NOT NULL DEFAULT 1 COMMENT 'Текущее состояние объекта',
  id_premises_kind int(11) NOT NULL DEFAULT 1 COMMENT 'Вид помещения специализированного жилого фонда: служебное, по типу общежитие',
  id_premises_type int(11) NOT NULL DEFAULT 1 COMMENT 'Тип помещения: квартира, комната, квартира с подселением',
  id_premises_comment int(11) NOT NULL DEFAULT 1 COMMENT 'Примечание (справочник)',
  id_premises_door_keys int(11) NOT NULL DEFAULT 1 COMMENT 'Местонахождение ключей (справочник)',
  premises_num varchar(255) NOT NULL DEFAULT '' COMMENT 'Номер помещения или группы объединенных помещений',
  floor smallint(6) NOT NULL DEFAULT 0 COMMENT 'Этаж',
  num_rooms smallint(6) NOT NULL DEFAULT 0 COMMENT 'Число комнат',
  num_beds smallint(6) NOT NULL DEFAULT 0 COMMENT 'Число койко-мест',
  total_area double NOT NULL DEFAULT 0 COMMENT 'Общая площадь',
  living_area double NOT NULL DEFAULT 0 COMMENT 'Жилая площадь',
  height double NOT NULL DEFAULT 0,
  cadastral_num varchar(20) DEFAULT NULL COMMENT 'Кадастровый номер',
  cadastral_cost decimal(19, 2) NOT NULL DEFAULT 0.00 COMMENT 'Кадастровая стоимость',
  balance_cost decimal(19, 2) NOT NULL DEFAULT 0.00 COMMENT 'Балансовая стоимость',
  description text DEFAULT NULL COMMENT 'Другие сведения',
  reg_date date NOT NULL COMMENT 'Дата внесения в реестр',
  is_memorial tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Является памятником культуры',
  account varchar(255) DEFAULT NULL COMMENT 'Лицевой счет помещения',
  state_date datetime DEFAULT NULL COMMENT 'Дата установки состояния',
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_premises)
)
ENGINE = INNODB,
AUTO_INCREMENT = 31393,
AVG_ROW_LENGTH = 141,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Помещения';

--
-- Создать индекс `cadastral_num` для объекта типа таблица `premises`
--
ALTER TABLE premises
ADD INDEX cadastral_num (cadastral_num);

DELIMITER $$

--
-- Создать триггер `premises_after_insert`
--
CREATE TRIGGER premises_after_insert
AFTER INSERT
ON premises
FOR EACH ROW
BEGIN
  IF (NEW.id_building IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'id_building', NULL, NEW.id_building, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_state IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'id_state', NULL, NEW.id_state, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_premises_kind IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'id_premises_kind', NULL, NEW.id_premises_kind, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_premises_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'id_premises_type', NULL, NEW.id_premises_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_premises_comment IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'id_premises_comment', NULL, NEW.id_premises_comment, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_premises_door_keys IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'id_premises_door_keys', NULL, NEW.id_premises_door_keys, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.premises_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'premises_num', NULL, NEW.premises_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.floor IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'floor', NULL, NEW.floor, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.num_rooms IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'num_rooms', NULL, NEW.num_rooms, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.num_beds IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'num_beds', NULL, NEW.num_beds, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.total_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'total_area', NULL, NEW.total_area, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.living_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'living_area', NULL, NEW.living_area, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.height IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'height', NULL, NEW.height, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.cadastral_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'cadastral_num', NULL, NEW.cadastral_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.cadastral_cost IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'cadastral_cost', NULL, NEW.cadastral_cost, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.balance_cost IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'balance_cost', NULL, NEW.balance_cost, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.reg_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'reg_date', NULL, NEW.reg_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_memorial IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'is_memorial', NULL, NEW.is_memorial, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'account', NULL, NEW.account, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.state_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'state_date', NULL, NEW.state_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_premises_comment IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'id_premises_comment', NULL, NEW.id_premises_comment, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_premises_door_keys IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'id_premises_door_keys', NULL, NEW.id_premises_door_keys, 'INSERT', NOW(), USER());
  END IF;

  -- Обновление коэффициентов платы за найм
  INSERT INTO tenancy_payments_history (id_building, id_premises, id_sub_premises, rent_area, k1, k2, k3, kc, Hb,
  date, reason)
    SELECT
      vpca.id_building,
      vpca.id_premises,
      vpca.id_sub_premises,
      vpca.rent_area,
      vpca.k1,
      vpca.k2,
      vpca.k3,
      vpca.kc,
      vpca.Hb,
      NOW(),
      'Новое помещение'
    FROM v_payments_coefficients_all vpca
    WHERE vpca.id_premises = NEW.id_premises;
END
$$

--
-- Создать триггер `premises_after_update`
--
CREATE TRIGGER premises_after_update
AFTER UPDATE
ON premises
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'premises', NEW.id_premises, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
    CALL update_kumi_accounts_address_infix_by_id_premise(NEW.id_premises);
  ELSE
    IF (NEW.id_building <> OLD.id_building) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'id_building', OLD.id_building, NEW.id_building, 'UPDATE', NOW(), USER());
      CALL update_kumi_accounts_address_infix_by_id_premise(NEW.id_premises);
    END IF;
    IF (NEW.id_state <> OLD.id_state) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'id_state', OLD.id_state, NEW.id_state, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_premises_kind <> OLD.id_premises_kind) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'id_premises_kind', OLD.id_premises_kind, NEW.id_premises_kind, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_premises_type <> OLD.id_premises_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'id_premises_type', OLD.id_premises_type, NEW.id_premises_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_premises_comment <> OLD.id_premises_comment) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'id_premises_comment', OLD.id_premises_comment, NEW.id_premises_comment, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_premises_door_keys <> OLD.id_premises_door_keys) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'id_premises_door_keys', OLD.id_premises_door_keys, NEW.id_premises_door_keys, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.premises_num <> OLD.premises_num) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'premises_num', OLD.premises_num, NEW.premises_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.floor <> OLD.floor) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'floor', OLD.floor, NEW.floor, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.num_rooms <> OLD.num_rooms) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'num_rooms', OLD.num_rooms, NEW.num_rooms, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.num_beds <> OLD.num_beds) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'num_beds', OLD.num_beds, NEW.num_beds, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.total_area <> OLD.total_area) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'total_area', OLD.total_area, NEW.total_area, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.living_area <> OLD.living_area) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'living_area', OLD.living_area, NEW.living_area, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.height <> OLD.height) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'height', OLD.height, NEW.height, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.cadastral_num IS NULL
      AND OLD.cadastral_num IS NULL)
      AND ((NEW.cadastral_num IS NULL
      AND OLD.cadastral_num IS NOT NULL)
      OR (NEW.cadastral_num IS NOT NULL
      AND OLD.cadastral_num IS NULL)
      OR (NEW.cadastral_num <> OLD.cadastral_num))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'cadastral_num', OLD.cadastral_num, NEW.cadastral_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.cadastral_cost <> OLD.cadastral_cost) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'cadastral_cost', OLD.cadastral_cost, NEW.cadastral_cost, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.balance_cost <> OLD.balance_cost) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'balance_cost', OLD.balance_cost, NEW.balance_cost, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.reg_date <> OLD.reg_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'reg_date', OLD.reg_date, NEW.reg_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.is_memorial <> OLD.is_memorial) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'is_memorial', OLD.is_memorial, NEW.is_memorial, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.account IS NULL
      AND OLD.account IS NULL)
      AND ((NEW.account IS NULL
      AND OLD.account IS NOT NULL)
      OR (NEW.account IS NOT NULL
      AND OLD.account IS NULL)
      OR (NEW.account <> OLD.account))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'account', OLD.account, NEW.account, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.state_date IS NULL
      AND OLD.state_date IS NULL)
      AND ((NEW.state_date IS NULL
      AND OLD.state_date IS NOT NULL)
      OR (NEW.state_date IS NOT NULL
      AND OLD.state_date IS NULL)
      OR (NEW.state_date <> OLD.state_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'state_date', OLD.state_date, NEW.state_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_premises_comment <> OLD.id_premises_comment) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'id_premises_comment', OLD.id_premises_comment, NEW.id_premises_comment, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_premises_door_keys <> OLD.id_premises_door_keys) THEN
      INSERT INTO `log`
        VALUES (NULL, 'premises', NEW.id_premises, 'id_premises_door_keys', OLD.id_premises_door_keys, NEW.id_premises_door_keys, 'UPDATE', NOW(), USER());
    END IF;

    -- Обновление коэффициентов платы за найм
    IF ((NEW.id_premises_type <> OLD.id_premises_type)
      OR (NEW.total_area <> OLD.total_area)) THEN
      INSERT INTO tenancy_payments_history (id_building, id_premises, id_sub_premises, rent_area, k1, k2, k3, kc, Hb,
      date, reason)
        SELECT
          vpca.id_building,
          vpca.id_premises,
          vpca.id_sub_premises,
          vpca.rent_area,
          vpca.k1,
          vpca.k2,
          vpca.k3,
          vpca.kc,
          vpca.Hb,
          NOW(),
          'Изменение характеристик помещения'
        FROM v_payments_coefficients_all vpca
        WHERE vpca.id_premises = NEW.id_premises;
    END IF;
  END IF;
END
$$

--
-- Создать триггер `premises_before_update`
--
CREATE TRIGGER premises_before_update
BEFORE UPDATE
ON premises
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    UPDATE sub_premises
    SET deleted = 1
    WHERE id_premises = NEW.id_premises;
    UPDATE funds_premises_assoc
    SET deleted = 1
    WHERE id_premises = NEW.id_premises;
    UPDATE ownership_premises_assoc
    SET deleted = 1
    WHERE id_premises = NEW.id_premises;
    UPDATE restrictions_premises_assoc
    SET deleted = 1
    WHERE id_premises = NEW.id_premises;
    UPDATE tenancy_premises_assoc
    SET deleted = 1
    WHERE id_premises = NEW.id_premises;
    UPDATE resettle_premises_from_assoc
    SET deleted = 1
    WHERE id_premises = NEW.id_premises;
    UPDATE resettle_premises_to_assoc
    SET deleted = 1
    WHERE id_premises = NEW.id_premises;
    UPDATE resettle_premise_assoc
    SET deleted = 1
    WHERE id_premises = NEW.id_premises;
    UPDATE litigation_premise_assoc lpa
    SET deleted = 1
    WHERE id_premises = NEW.id_premises;
  END IF;
--   IF (NEW.id_state <> OLD.id_state AND NEW.id_state <> 1) THEN
--     UPDATE sub_premises
--     SET id_state = NEW.id_state
--     WHERE id_premises = NEW.id_premises AND deleted <> 1;
--   END IF;
--   IF (NOT(NEW.state_date IS NULL AND OLD.state_date IS NULL) AND 
--       ((NEW.state_date IS NULL AND OLD.state_date IS NOT NULL) OR
--        (NEW.state_date IS NOT NULL AND OLD.state_date IS NULL) OR
--        (NEW.state_date <> OLD.state_date)) AND NEW.id_state <> 1) THEN
--     UPDATE sub_premises
--     SET state_date = NEW.state_date
--     WHERE id_premises = NEW.id_premises AND deleted <> 1;
--   END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE premises
ADD CONSTRAINT FK_premises_id_premises_comment FOREIGN KEY (id_premises_comment)
REFERENCES premises_comments (id_premises_comment) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE premises
ADD CONSTRAINT FK_premises_id_premises_door_keys FOREIGN KEY (id_premises_door_keys)
REFERENCES premises_door_keys (id_premises_door_keys) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE premises
ADD CONSTRAINT FK_premises_premises_kinds_id_premises_kind FOREIGN KEY (id_premises_kind)
REFERENCES premises_kinds (id_premises_kind) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE premises
ADD CONSTRAINT FK_premises_premises_types_id_premises_type FOREIGN KEY (id_premises_type)
REFERENCES premises_types (id_premises_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE premises
ADD CONSTRAINT FK_premises_states_id_state FOREIGN KEY (id_state)
REFERENCES object_states (id_state) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE funds_premises_assoc
ADD CONSTRAINT FK_funds_premises_assoc_premises_id_premises FOREIGN KEY (id_premises)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE litigation_premise_assoc
ADD CONSTRAINT FK_litigation_premise_assoc_id_premises FOREIGN KEY (id_premises)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE ownership_premises_assoc
ADD CONSTRAINT FK_ownership_premises_assoc_premises_id_premises FOREIGN KEY (id_premises)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_premise_assoc
ADD CONSTRAINT FK_resettle_premise_assoc_id_premises FOREIGN KEY (id_premises)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_premises_from_assoc
ADD CONSTRAINT FK_resettle_premises_from_assoc_premises_id_premises FOREIGN KEY (id_premises)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_premises_to_assoc
ADD CONSTRAINT FK_resettle_premises_to_assoc_premises_id_premises FOREIGN KEY (id_premises)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE restrictions_premises_assoc
ADD CONSTRAINT FK_restrictions_premises_assoc_premises_id_premises FOREIGN KEY (id_premises)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE sub_premises
ADD CONSTRAINT FK_sub_premises_premises_id_premises FOREIGN KEY (id_premises)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_payments_history
ADD CONSTRAINT FK_tenancy_payments_history_id_premises FOREIGN KEY (id_premises)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_premises_assoc
ADD CONSTRAINT FK_tenancy_premises_assoc_premises_id_premises FOREIGN KEY (id_premises)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE CASCADE;

DELIMITER $$

--
-- Создать функцию `f_tenancy_sub_premises_count`
--
CREATE FUNCTION f_tenancy_sub_premises_count (id_process int)
RETURNS int(11)
BEGIN
  RETURN IFNULL((SELECT
      SUM(sub_premises_count)
    FROM (SELECT
        COUNT(*) AS sub_premises_count
      FROM tenancy_sub_premises_assoc tspa
      WHERE deleted <> 1
      AND tspa.id_process = id_process
      UNION
      SELECT
        COUNT(*) AS sub_premises_count
      FROM tenancy_premises_assoc tpa
        INNER JOIN premises p
          ON tpa.id_premises = p.id_premises
      WHERE tpa.deleted <> 1
      AND p.deleted <> 1
      AND p.id_premises_type = 2
      AND tpa.id_process = id_process) v), 0);
END
$$

--
-- Создать функцию `f_tenancy_share_sub_premises_count`
--
CREATE FUNCTION f_tenancy_share_sub_premises_count (id_process int)
RETURNS int(11)
BEGIN
  RETURN IFNULL((SELECT
      COUNT(*)
    FROM tenancy_sub_premises_assoc tspa
      INNER JOIN sub_premises sp
        ON tspa.id_sub_premises = sp.id_sub_premises
      INNER JOIN premises p
        ON sp.id_premises = p.id_premises
    WHERE tspa.deleted <> 1
    AND sp.deleted <> 1
    AND p.deleted <> 1
    AND p.id_premises_type = 3
    AND tspa.id_process = id_process), 0);
END
$$

--
-- Создать функцию `f_tenancy_share_flats_count`
--
CREATE FUNCTION f_tenancy_share_flats_count (id_process int)
RETURNS int(11)
BEGIN
  RETURN IFNULL((SELECT
      COUNT(*)
    FROM premises p
    WHERE p.deleted <> 1
    AND p.id_premises_type = 3
    AND p.id_premises IN (SELECT
        sp.id_premises
      FROM tenancy_sub_premises_assoc tspa
        INNER JOIN sub_premises sp
          ON tspa.id_sub_premises = sp.id_sub_premises
      WHERE tspa.rent_total_area IS NULL
      AND tspa.deleted <> 1
      AND tspa.id_process = id_process)), 0);
END
$$

--
-- Создать функцию `f_tenancy_rooms_count`
--
CREATE FUNCTION f_tenancy_rooms_count (id_process int)
RETURNS int(11)
BEGIN
  RETURN IFNULL((SELECT
      SUM(flats_count)
    FROM (SELECT
        COUNT(*) AS flats_count
      FROM tenancy_sub_premises_assoc tspa
        INNER JOIN sub_premises sp
          ON tspa.id_sub_premises = sp.id_sub_premises
        INNER JOIN premises p
          ON sp.id_premises = p.id_premises
      WHERE tspa.deleted <> 1
      AND tspa.id_process = id_process
      AND tspa.rent_total_area IS NULL
      AND p.id_premises_type <> 3
      UNION ALL
      SELECT
        COUNT(*) AS flats_count
      FROM tenancy_premises_assoc tpa
        INNER JOIN premises p
          ON tpa.id_premises = p.id_premises
      WHERE tpa.deleted <> 1
      AND p.deleted <> 1
      AND tpa.rent_total_area IS NULL
      AND tpa.rent_living_area IS NULL
      AND p.id_premises_type = 2
      AND tpa.id_process = id_process) v), 0);
END
$$

--
-- Создать функцию `f_tenancy_premises_count`
--
CREATE FUNCTION f_tenancy_premises_count (id_process int)
RETURNS int(11)
BEGIN
  RETURN IFNULL((SELECT
      COUNT(*)
    FROM tenancy_premises_assoc tpa
      INNER JOIN premises p
        ON tpa.id_premises = p.id_premises
    WHERE tpa.deleted <> 1
    AND p.deleted <> 1
    AND p.id_premises_type = 4
    AND tpa.id_process = id_process
    AND tpa.rent_total_area IS NULL
    AND tpa.rent_living_area IS NULL), 0);
END
$$

--
-- Создать функцию `f_tenancy_incorrect_count`
--
CREATE FUNCTION f_tenancy_incorrect_count (id_process int)
RETURNS int(11)
BEGIN
  RETURN IFNULL((SELECT
      COUNT(*)
    FROM tenancy_premises_assoc tpa
      INNER JOIN premises p
        ON tpa.id_premises = p.id_premises
    WHERE tpa.deleted <> 1
    AND p.deleted <> 1
    AND p.id_premises_type = 3
    AND tpa.id_process = id_process
    AND tpa.rent_total_area IS NULL
    AND tpa.rent_living_area IS NULL), 0);
END
$$

--
-- Создать функцию `f_tenancy_flats_count`
--
CREATE FUNCTION f_tenancy_flats_count (id_process int)
RETURNS int(11)
BEGIN
  RETURN IFNULL((SELECT
      COUNT(*)
    FROM tenancy_premises_assoc tpa
      INNER JOIN premises p
        ON tpa.id_premises = p.id_premises
    WHERE tpa.deleted <> 1
    AND p.deleted <> 1
    AND p.id_premises_type = 1
    AND tpa.id_process = id_process
    AND tpa.rent_total_area IS NULL
    AND tpa.rent_living_area IS NULL), 0);
END
$$

--
-- Создать функцию `f_tenancy_contract_type`
--
CREATE FUNCTION f_tenancy_contract_type (id_process int)
RETURNS int(11)
BEGIN
  -- -1 - отсутствуют нанимаемые помещения
  -- 0 - неизвестный тип договора
  -- 1 - одна комната
  -- 2 - несколько комнат
  -- 3 - одна квартира
  -- 4 - несколько квартир
  -- 5 - один дом
  -- 6 - несколько домов
  -- 7 - одна квартира с подселением
  -- 8 - несколько квартир с подселением
  -- 9 - одно койко-место
  -- 10 - несколько койко-мест
  -- 11 - одно помещение (нежилое)
  SET @buildings_count = f_tenancy_buildings_count(id_process);
  SET @flats_count = f_tenancy_flats_count(id_process);
  SET @premises_count = f_tenancy_premises_count(id_process);
  SET @share_flats_count = f_tenancy_share_flats_count(id_process);
  SET @rooms_count = f_tenancy_rooms_count(id_process);
  SET @beds_count = f_tenancy_beds_count(id_process);
  SET @incorrect_count = f_tenancy_incorrect_count(id_process);
  RETURN
  IF((@buildings_count = 0 AND
  @flats_count = 0 AND
  @share_flats_count = 0 AND
  @rooms_count = 0 AND
  @beds_count = 0 AND
  @incorrect_count = 0 AND
  @premises_count = 0), -1,
  IF((@buildings_count = 0 AND
  @flats_count = 0 AND
  @share_flats_count = 0 AND
  @rooms_count = 1 AND
  @beds_count = 0 AND
  @incorrect_count = 0 AND
  @premises_count = 0), 1,
  IF((@buildings_count = 0 AND
  @flats_count = 0 AND
  @share_flats_count = 0 AND
  @rooms_count > 1 AND
  @beds_count = 0 AND
  @incorrect_count = 0 AND
  @premises_count = 0), 2,
  IF((@buildings_count = 0 AND
  @flats_count = 1 AND
  @share_flats_count = 0 AND
  @rooms_count = 0 AND
  @beds_count = 0 AND
  @incorrect_count = 0 AND
  @premises_count = 0), 3,
  IF((@buildings_count = 0 AND
  @flats_count > 1 AND
  @share_flats_count = 0 AND
  @rooms_count = 0 AND
  @beds_count = 0 AND
  @incorrect_count = 0 AND
  @premises_count = 0), 4,
  IF((@buildings_count = 1 AND
  @flats_count = 0 AND
  @share_flats_count = 0 AND
  @rooms_count = 0 AND
  @beds_count = 0 AND
  @incorrect_count = 0 AND
  @premises_count = 0), 5,
  IF((@buildings_count > 1 AND
  @flats_count = 0 AND
  @share_flats_count = 0 AND
  @rooms_count = 0 AND
  @beds_count = 0 AND
  @incorrect_count = 0 AND
  @premises_count = 0), 6,
  IF((@buildings_count = 0 AND
  @flats_count = 0 AND
  @share_flats_count = 1 AND
  @rooms_count = 0 AND
  @beds_count = 0 AND
  @incorrect_count = 0 AND
  @premises_count = 0), 7,
  IF((@buildings_count = 0 AND
  @flats_count = 0 AND
  @share_flats_count > 1 AND
  @rooms_count = 0 AND
  @beds_count = 0 AND
  @incorrect_count = 0 AND
  @premises_count = 0), 8,
  IF((@buildings_count = 0 AND
  @flats_count = 0 AND
  @share_flats_count = 0 AND
  @rooms_count = 0 AND
  @beds_count = 1 AND
  @incorrect_count = 0 AND
  @premises_count = 0), 9,
  IF((@buildings_count = 0 AND
  @flats_count = 0 AND
  @share_flats_count = 0 AND
  @rooms_count = 0 AND
  @beds_count > 1 AND
  @incorrect_count = 0 AND
  @premises_count = 0), 10,
  IF((@buildings_count = 0 AND
  @flats_count = 0 AND
  @share_flats_count = 0 AND
  @rooms_count = 0 AND
  @beds_count = 0 AND
  @incorrect_count = 0 AND
  @premises_count = 1), 11, 0))))))))))));
END
$$

DELIMITER ;

--
-- Создать представление `v_tenancy_address_sub_premises`
--
CREATE
VIEW v_tenancy_address_sub_premises
AS
SELECT
  `tspa`.`id_process` AS `id_process`,
  `sp`.`id_premises` AS `id_premises`,
  CONCAT(`p`.`premises_num`, ', ком. ', GROUP_CONCAT(`sp`.`sub_premises_num` SEPARATOR ',')) AS `premises_num`,
  SUM(`sp`.`total_area`) AS `total_area`
FROM ((`tenancy_sub_premises_assoc` `tspa`
  JOIN `sub_premises` `sp`
    ON ((`tspa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
WHERE ((`tspa`.`deleted` <> 1)
AND (`sp`.`deleted` <> 1)
AND (`tspa`.`deleted` <> 1))
GROUP BY `tspa`.`id_process`,
         `sp`.`id_premises`;

--
-- Создать представление `v_tenancy_address_premises_prepare1`
--
CREATE
VIEW v_tenancy_address_premises_prepare1
AS
SELECT
  `v_tenancy_address_sub_premises`.`id_process` AS `id_process`,
  `v_tenancy_address_sub_premises`.`id_premises` AS `id_premises`,
  `v_tenancy_address_sub_premises`.`premises_num` AS `premises_num`,
  `v_tenancy_address_sub_premises`.`total_area` AS `total_area`
FROM `v_tenancy_address_sub_premises`
UNION ALL
SELECT
  `tpa`.`id_process` AS `id_process`,
  `tpa`.`id_premises` AS `id_premises`,
  `p`.`premises_num` AS `premises_num`,
  `p`.`total_area` AS `total_area`
FROM (`tenancy_premises_assoc` `tpa`
  JOIN `premises` `p`
    ON ((`tpa`.`id_premises` = `p`.`id_premises`)))
WHERE (`tpa`.`deleted` <> 1);

--
-- Создать представление `v_tenancy_address_premises_prepare2`
--
CREATE
VIEW v_tenancy_address_premises_prepare2
AS
SELECT
  `v`.`id_process` AS `id_process`,
  `v`.`id_premises` AS `id_premises`,
  GROUP_CONCAT(`v`.`premises_num` SEPARATOR ',') AS `premises_num`,
  SUM(`v`.`total_area`) AS `total_area`
FROM `v_tenancy_address_premises_prepare1` `v`
GROUP BY `v`.`id_process`,
         `v`.`id_premises`;

--
-- Создать представление `v_premises_last_municipal_restrictions`
--
CREATE
VIEW v_premises_last_municipal_restrictions
AS
SELECT
  `p`.`id_premises` AS `id_premises`,
  `include_restrictions`.`number` AS `in_number`,
  `include_restrictions`.`date` AS `in_date`,
  `include_restrictions`.`description` AS `in_description`,
  IF(ISNULL(`include_restrictions`.`date`), `exclude_restrictions`.`number`, IF((`include_restrictions`.`date` > `exclude_restrictions`.`date`), NULL, `exclude_restrictions`.`number`)) AS `ex_number`,
  IF(ISNULL(`include_restrictions`.`date`), `exclude_restrictions`.`date`, IF((`include_restrictions`.`date` > `exclude_restrictions`.`date`), NULL, `exclude_restrictions`.`date`)) AS `ex_date`,
  IF(ISNULL(`include_restrictions`.`date`), `exclude_restrictions`.`description`, IF((`include_restrictions`.`date` > `exclude_restrictions`.`date`), NULL, `exclude_restrictions`.`description`)) AS `ex_description`
FROM ((`premises` `p`
  LEFT JOIN `v_premises_municipal_exclude_restrictions` `exclude_restrictions`
    ON ((`exclude_restrictions`.`id_premises` = `p`.`id_premises`)))
  LEFT JOIN `v_premises_municipal_include_restrictions` `include_restrictions`
    ON ((`include_restrictions`.`id_premises` = `p`.`id_premises`)))
WHERE (((`include_restrictions`.`id_premises` IS NOT NULL)
OR (`exclude_restrictions`.`id_premises` IS NOT NULL))
AND (`p`.`deleted` <> 1));

--
-- Создать представление `v_registry_full_stat_municipal_rest`
--
CREATE
VIEW v_registry_full_stat_municipal_rest
AS
SELECT
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  CONCAT(`p`.`premises_num`, IF(ISNULL(`spn`.`sub_premises`), '', CONCAT('(', `spn`.`sub_premises`, ')'))) AS `premises_num`,
  CONCAT(IF((`vplmr`.`in_number` IS NOT NULL), CONCAT('№ ', `vplmr`.`in_number`, ' - '), ''), DATE_FORMAT(`vplmr`.`in_date`, '%d.%m.%Y')) AS `municipal_include_restriction`,
  CONCAT(IF((`vplmr`.`ex_number` IS NOT NULL), CONCAT('№ ', `vplmr`.`ex_number`, ' - '), ''), DATE_FORMAT(`vplmr`.`ex_date`, '%d.%m.%Y')) AS `municipal_exclude_restriction`
FROM ((`premises` `p`
  JOIN `v_premises_last_municipal_restrictions` `vplmr`
    ON ((`p`.`id_premises` = `vplmr`.`id_premises`)))
  LEFT JOIN `v_registry_full_stat_concated_municipal_sub_premises` `spn`
    ON ((`p`.`id_premises` = `spn`.`id_premises`)))
WHERE (`p`.`deleted` <> 1)
ORDER BY `p`.`id_building`, `p`.`premises_num`;

--
-- Создать представление `v_premises_excluded_from_emergency`
--
CREATE
VIEW v_premises_excluded_from_emergency
AS
SELECT
  `p`.`id_premises` AS `id_premises`,
  `p`.`id_building` AS `id_building`,
  `p`.`id_state` AS `id_state`,
  `p`.`premises_num` AS `premises_num`,
  `p`.`total_area` AS `total_area`,
  `p`.`living_area` AS `living_area`,
  `p`.`num_beds` AS `num_beds`,
  `p`.`id_premises_type` AS `id_premises_type`,
  `p`.`id_premises_kind` AS `id_premises_kind`,
  `p`.`floor` AS `floor`,
  `p`.`cadastral_num` AS `cadastral_num`,
  `p`.`cadastral_cost` AS `cadastral_cost`,
  `p`.`balance_cost` AS `balance_cost`,
  `p`.`description` AS `description`,
  `p`.`deleted` AS `deleted`,
  `or1`.`number` AS `or_number`,
  `or1`.`date` AS `or_date`,
  `or1`.`description` AS `or_description`
FROM ((`premises` `p`
  JOIN `ownership_premises_assoc` `opa`
    ON ((`p`.`id_premises` = `opa`.`id_premises`)))
  JOIN `ownership_rights` `or1`
    ON ((`opa`.`id_ownership_right` = `or1`.`id_ownership_right`)))
WHERE ((`or1`.`id_ownership_right_type` = 6)
AND (`opa`.`deleted` <> 1)
AND (`or1`.`deleted` <> 1)
AND (`p`.`deleted` <> 1));

--
-- Создать представление `v_premises_emergency_current_max_date`
--
CREATE
VIEW v_premises_emergency_current_max_date
AS
SELECT
  `oba`.`id_premises` AS `id_premises`,
  MAX(`or1`.`date`) AS `date`
FROM ((`ownership_rights` `or1`
  JOIN `ownership_premises_assoc` `oba`
    ON ((`or1`.`id_ownership_right` = `oba`.`id_ownership_right`)))
  LEFT JOIN `v_premises_excluded_from_emergency` `vpefe`
    ON ((`oba`.`id_premises` = `vpefe`.`id_premises`)))
WHERE ((`or1`.`deleted` <> 1)
AND (`oba`.`deleted` <> 1)
AND (`or1`.`id_ownership_right_type` = 2)
AND (ISNULL(`vpefe`.`or_date`)
OR (`or1`.`date` > `vpefe`.`or_date`)))
GROUP BY `oba`.`id_premises`;

--
-- Создать представление `v_premises_emergency_all_max_date`
--
CREATE
VIEW v_premises_emergency_all_max_date
AS
SELECT
  `oba`.`id_premises` AS `id_premises`,
  MAX(`or1`.`date`) AS `date`
FROM ((`ownership_rights` `or1`
  JOIN `ownership_premises_assoc` `oba`
    ON ((`or1`.`id_ownership_right` = `oba`.`id_ownership_right`)))
  LEFT JOIN `v_premises_excluded_from_emergency` `vpefe`
    ON ((`oba`.`id_premises` = `vpefe`.`id_premises`)))
WHERE ((`or1`.`deleted` <> 1)
AND (`oba`.`deleted` <> 1)
AND (`or1`.`id_ownership_right_type` IN (2, 7))
AND (ISNULL(`vpefe`.`or_date`)
OR (`or1`.`date` > `vpefe`.`or_date`)))
GROUP BY `oba`.`id_premises`;

--
-- Создать представление `v_premises_demolished`
--
CREATE
VIEW v_premises_demolished
AS
SELECT
  `p`.`id_premises` AS `id_premises`,
  `p`.`id_building` AS `id_building`,
  `p`.`id_state` AS `id_state`,
  `p`.`premises_num` AS `premises_num`,
  `p`.`total_area` AS `total_area`,
  `p`.`living_area` AS `living_area`,
  `p`.`num_beds` AS `num_beds`,
  `p`.`id_premises_type` AS `id_premises_type`,
  `p`.`id_premises_kind` AS `id_premises_kind`,
  `p`.`floor` AS `floor`,
  `p`.`cadastral_num` AS `cadastral_num`,
  `p`.`cadastral_cost` AS `cadastral_cost`,
  `p`.`balance_cost` AS `balance_cost`,
  `p`.`description` AS `description`,
  `p`.`deleted` AS `deleted`,
  `or1`.`number` AS `or_number`,
  `or1`.`date` AS `or_date`,
  `or1`.`description` AS `or_description`
FROM ((`premises` `p`
  JOIN `ownership_premises_assoc` `opa`
    ON ((`p`.`id_premises` = `opa`.`id_premises`)))
  JOIN `ownership_rights` `or1`
    ON ((`opa`.`id_ownership_right` = `or1`.`id_ownership_right`)))
WHERE ((`or1`.`id_ownership_right_type` = 1)
AND (`opa`.`deleted` <> 1)
AND (`or1`.`deleted` <> 1)
AND (`p`.`deleted` <> 1));

--
-- Создать представление `v_premises_emergency_current`
--
CREATE
VIEW v_premises_emergency_current
AS
SELECT
  `v`.`id_premises` AS `id_premises`,
  `or1`.`number` AS `number`,
  `or1`.`date` AS `date`,
  `or1`.`description` AS `description`
FROM ((`ownership_rights` `or1`
  JOIN `ownership_premises_assoc` `oba`
    ON ((`or1`.`id_ownership_right` = `oba`.`id_ownership_right`)))
  JOIN `v_premises_emergency_current_max_date` `v`
    ON (((`oba`.`id_premises` = `v`.`id_premises`)
    AND (`or1`.`date` = `v`.`date`))))
WHERE ((`or1`.`deleted` <> 1)
AND (`oba`.`deleted` <> 1)
AND (`or1`.`id_ownership_right_type` = 2)
AND (NOT (`oba`.`id_premises` IN (SELECT
    `vbd`.`id_premises`
  FROM `v_premises_demolished` `vbd`))))
GROUP BY `oba`.`id_premises`;

--
-- Создать представление `v_premises_emergency_all`
--
CREATE
VIEW v_premises_emergency_all
AS
SELECT
  `v`.`id_premises` AS `id_premises`,
  `or1`.`number` AS `number`,
  `or1`.`date` AS `date`,
  `or1`.`description` AS `description`,
  `or1`.`id_ownership_right_type` AS `id_ownership_right_type`
FROM ((`ownership_rights` `or1`
  JOIN `ownership_premises_assoc` `oba`
    ON ((`or1`.`id_ownership_right` = `oba`.`id_ownership_right`)))
  JOIN `v_premises_emergency_all_max_date` `v`
    ON (((`oba`.`id_premises` = `v`.`id_premises`)
    AND (`or1`.`date` = `v`.`date`))))
WHERE ((`or1`.`deleted` <> 1)
AND (`oba`.`deleted` <> 1)
AND (`or1`.`id_ownership_right_type` IN (2, 7))
AND (NOT (`oba`.`id_premises` IN (SELECT
    `vbd`.`id_premises`
  FROM `v_premises_demolished` `vbd`))))
GROUP BY `oba`.`id_premises`;

--
-- Создать представление `v_payments_premises_and_sub_premises`
--
CREATE
VIEW v_payments_premises_and_sub_premises
AS
SELECT
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  NULL AS `id_sub_premises`,
  `p`.`total_area` AS `rent_total_area`,
  `p`.`total_area` AS `total_area`,
  `p`.`id_premises_type` AS `id_premises_type`
FROM `premises` `p`
WHERE (`p`.`deleted` <> 1)
UNION ALL
SELECT
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  `sp`.`id_sub_premises` AS `id_sub_premises`,
  `sp`.`total_area` AS `total_area`,
  `p`.`total_area` AS `total_area`,
  2 AS `id_premises_type`
FROM (`sub_premises` `sp`
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
WHERE (`sp`.`deleted` <> 1);

--
-- Создать представление `v_building_sp_living_area`
--
CREATE
VIEW v_building_sp_living_area
AS
SELECT
  SUM(`sp`.`total_area`) AS `mp_area`,
  `p`.`id_building` AS `id_building`
FROM (`sub_premises` `sp`
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
WHERE ((`p`.`id_state` IN (1, 4, 5, 9, 11, 12, 14))
AND (`sp`.`id_state` IN (4, 5, 9, 11, 12, 14))
AND (`sp`.`deleted` <> 1))
GROUP BY `p`.`id_building`;

--
-- Создать представление `v_building_p_living_area`
--
CREATE
VIEW v_building_p_living_area
AS
SELECT
  SUM(`p`.`total_area`) AS `mp_area`,
  `p`.`id_building` AS `id_building`
FROM `premises` `p`
WHERE ((`p`.`deleted` <> 1)
AND (`p`.`id_state` IN (4, 5, 9, 11, 12, 14))
AND (NOT (`p`.`id_premises` IN (SELECT
    `sp`.`id_premises`
  FROM (`sub_premises` `sp`
    JOIN `premises` `p`
      ON ((`sp`.`id_premises` = `p`.`id_premises`)))
  WHERE ((`sp`.`id_state` IN (4, 5, 9, 11, 12, 14))
  AND (`sp`.`deleted` <> 1))))))
GROUP BY `p`.`id_building`;

--
-- Создать таблицу `payments_address_exceptions`
--
CREATE TABLE IF NOT EXISTS payments_address_exceptions (
  id_premise int(11) DEFAULT NULL,
  id_sub_premise int(11) DEFAULT NULL,
  raw_address varchar(255) DEFAULT NULL COMMENT 'Адрес по БКС'
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 1638,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `UK_payments_address_exceptions` для объекта типа таблица `payments_address_exceptions`
--
ALTER TABLE payments_address_exceptions
ADD UNIQUE INDEX UK_payments_address_exceptions (id_premise, id_sub_premise);

DELIMITER $$

--
-- Создать триггер `payments_address_exceptions_before_insert`
--
CREATE TRIGGER payments_address_exceptions_before_insert
BEFORE INSERT
ON payments_address_exceptions
FOR EACH ROW
BEGIN
  IF ((NEW.id_premise IS NOT NULL
    AND NEW.id_sub_premise IS NOT NULL)
    OR (NEW.id_premise IS NULL
    AND NEW.id_sub_premise IS NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Необходимо задать один из идентификаторов (комнаты или помещения)';
  END IF;
END
$$

--
-- Создать триггер `payments_address_exceptions_before_update`
--
CREATE TRIGGER payments_address_exceptions_before_update
BEFORE UPDATE
ON payments_address_exceptions
FOR EACH ROW
BEGIN
  IF ((NEW.id_premise IS NOT NULL
    AND NEW.id_sub_premise IS NOT NULL)
    OR (NEW.id_premise IS NULL
    AND NEW.id_sub_premise IS NULL)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Необходимо задать один из идентификаторов (комнаты или помещения)';
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE payments_address_exceptions
ADD CONSTRAINT FK_payments_address_exceptions_premises_id_premises FOREIGN KEY (id_premise)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE payments_address_exceptions
ADD CONSTRAINT FK_payments_address_exceptions_sub_premises_id_sub_premises FOREIGN KEY (id_sub_premise)
REFERENCES sub_premises (id_sub_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `structure_type_overlap`
--
CREATE TABLE IF NOT EXISTS structure_type_overlap (
  id_structure_type_overlap int(11) NOT NULL,
  structure_type_overlap varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_structure_type_overlap)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `heating_type`
--
CREATE TABLE IF NOT EXISTS heating_type (
  id_heating_type int(11) NOT NULL AUTO_INCREMENT,
  heating_type varchar(255) DEFAULT NULL,
  deleted tinyint(1) DEFAULT 0,
  PRIMARY KEY (id_heating_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `government_decree`
--
CREATE TABLE IF NOT EXISTS government_decree (
  id_decree int(11) NOT NULL AUTO_INCREMENT,
  number varchar(255) NOT NULL,
  cost decimal(19, 2) DEFAULT NULL COMMENT 'Стоимость 1 кв.м.',
  PRIMARY KEY (id_decree)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `foundation_types`
--
CREATE TABLE IF NOT EXISTS foundation_types (
  id_foundation_type int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  PRIMARY KEY (id_foundation_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 6,
AVG_ROW_LENGTH = 3276,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `buildings_managment_orgs`
--
CREATE TABLE IF NOT EXISTS buildings_managment_orgs (
  id_organization int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  PRIMARY KEY (id_organization)
)
ENGINE = INNODB,
AUTO_INCREMENT = 129,
AVG_ROW_LENGTH = 341,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `buildings`
--
CREATE TABLE IF NOT EXISTS buildings (
  id_building int(11) NOT NULL AUTO_INCREMENT,
  id_state int(11) NOT NULL DEFAULT 1 COMMENT 'Текущее состояние объекта',
  id_structure_type int(11) NOT NULL COMMENT 'Тип строения (материал)',
  id_structure_type_overlap int(11) NOT NULL DEFAULT 1 COMMENT 'Тип перекрытий',
  id_foundation_type int(11) NOT NULL DEFAULT 1,
  id_street varchar(17) NOT NULL COMMENT 'Индекс улицы из kladr',
  house varchar(20) NOT NULL DEFAULT '' COMMENT 'Номер дома',
  floors smallint(6) NOT NULL DEFAULT 5 COMMENT 'Этажность',
  entrances smallint(6) DEFAULT NULL COMMENT 'Количество подъездов',
  num_premises int(11) NOT NULL DEFAULT 0 COMMENT 'Число помеещний (всего)',
  num_rooms int(11) NOT NULL DEFAULT 0 COMMENT 'Число комнат',
  num_apartments int(11) NOT NULL DEFAULT 0 COMMENT 'Число квартир',
  num_shared_apartments int(11) NOT NULL DEFAULT 0 COMMENT 'Число квартир с подселением',
  total_area double NOT NULL DEFAULT 0 COMMENT 'Общая площадь',
  living_area double NOT NULL DEFAULT 0 COMMENT 'Жилая площадь',
  unliving_area double NOT NULL DEFAULT 0 COMMENT 'Нежилая площадь',
  common_property_area double NOT NULL DEFAULT 0 COMMENT 'Общая площадь помещений, входящих в состав общего имущества',
  cadastral_num varchar(20) DEFAULT NULL COMMENT 'Кадастровый номер',
  cadastral_cost decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Кадастровая стоимость',
  balance_cost decimal(12, 2) NOT NULL DEFAULT 0.00 COMMENT 'Балансовая стоимость',
  startup_year int(11) NOT NULL DEFAULT 1900 COMMENT 'Дата ввода в эксплуатацию',
  series varchar(255) DEFAULT NULL COMMENT 'Серия, тип постройки',
  improvement tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Благоустроенность',
  elevator tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Наличие в доме лифта',
  rubbish_chute tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Наличие в доме мусоропровода',
  wear double DEFAULT 0 COMMENT 'Техническое состояние (Износ), %',
  description text DEFAULT NULL COMMENT 'Другие сведения',
  state_date datetime DEFAULT NULL COMMENT 'Дата установки состояния',
  plumbing tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Водопровод',
  hot_water_supply tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Горячее водоснабжение',
  canalization tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Канализация',
  electricity tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Электроосвещение',
  radio_network tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Радиотрансляционная сеть',
  id_heating_type int(11) DEFAULT NULL COMMENT 'Отопление',
  id_decree int(11) NOT NULL DEFAULT 1 COMMENT 'Постановление правительства',
  BTI_rooms varchar(1512) DEFAULT NULL COMMENT 'Приватиз. квартиры согласно БТИ',
  housing_cooperative varchar(255) DEFAULT NULL COMMENT 'Управляющая компания / ТСЖ',
  reg_date date NOT NULL DEFAULT '1999-10-29' COMMENT 'Дата включения в РМИ',
  rent_coefficient decimal(19, 2) NOT NULL DEFAULT 0.00 COMMENT 'Коэффициент оплаты',
  is_memorial tinyint(4) NOT NULL DEFAULT 0 COMMENT 'Памятник культуры или нет',
  memorial_date date DEFAULT NULL COMMENT 'Дата документа о присвоении статуса - памятник культуры',
  memorial_number varchar(255) DEFAULT NULL COMMENT 'Номер документа о присвоении статуса - памятник культуры',
  memorial_name_org varchar(255) DEFAULT NULL COMMENT 'Наименование органа, выдавшего документ о присвоении статуса - памятник культуры',
  date_owner_emergency date DEFAULT NULL COMMENT 'Срок для принятия собственниками помещений в многоквартирном доме, признанном аварийным, решения о сносе или реконструкции такого дома',
  demolished_fact_date datetime DEFAULT NULL COMMENT 'Фактическая дата сноса или реконструкции',
  demolished_plan_date date DEFAULT NULL COMMENT 'Плановая дата сноса или реконструкции',
  demand_for_demolishing_delivery_date date DEFAULT NULL,
  land_cadastral_num varchar(20) DEFAULT NULL COMMENT 'Кадастровый номер земельного участка, на котором расположено здание',
  land_cadastral_date datetime DEFAULT NULL COMMENT 'Дата  постановки на кадастровый учет',
  land_area double NOT NULL DEFAULT 0 COMMENT 'Площадь земельного участка',
  id_organization int(11) DEFAULT NULL,
  post_index varchar(6) DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Запись удалена',
  PRIMARY KEY (id_building)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4048,
AVG_ROW_LENGTH = 144,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Здания';

DELIMITER $$

--
-- Создать триггер `buildings_after_insert`
--
CREATE TRIGGER buildings_after_insert
AFTER INSERT
ON buildings
FOR EACH ROW
BEGIN
  IF (NEW.id_state IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'id_state', NULL, NEW.id_state, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_structure_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'id_structure_type', NULL, NEW.id_structure_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_structure_type_overlap IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'id_structure_type_overlap', NULL, NEW.id_structure_type_overlap, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_foundation_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'id_foundation_type', NULL, NEW.id_foundation_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_street IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'id_street', NULL, NEW.id_street, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.house IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'house', NULL, NEW.house, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.floors IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'floors', NULL, NEW.floors, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.entrances IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'entrances', NULL, NEW.entrances, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.num_premises IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'num_premises', NULL, NEW.num_premises, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.num_rooms IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'num_rooms', NULL, NEW.num_rooms, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.num_apartments IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'num_apartments', NULL, NEW.num_apartments, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.num_shared_apartments IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'num_shared_apartments', NULL, NEW.num_shared_apartments, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.total_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'total_area', NULL, NEW.total_area, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.living_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'living_area', NULL, NEW.living_area, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.unliving_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'unliving_area', NULL, NEW.unliving_area, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.common_property_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'common_property_area', NULL, NEW.common_property_area, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.cadastral_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'cadastral_num', NULL, NEW.cadastral_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.cadastral_cost IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'cadastral_cost', NULL, NEW.cadastral_cost, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.balance_cost IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'balance_cost', NULL, NEW.balance_cost, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.startup_year IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'startup_year', NULL, NEW.startup_year, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.series IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'series', NULL, NEW.series, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.improvement IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'improvement', NULL, NEW.improvement, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.elevator IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'elevator', NULL, NEW.elevator, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.rubbish_chute IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'rubbish_chute', NULL, NEW.rubbish_chute, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.wear IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'wear', NULL, NEW.wear, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.state_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'state_date', NULL, NEW.state_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.plumbing IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'plumbing', NULL, NEW.plumbing, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.hot_water_supply IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'hot_water_supply', NULL, NEW.hot_water_supply, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.canalization IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'canalization', NULL, NEW.canalization, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.electricity IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'electricity', NULL, NEW.electricity, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.radio_network IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'radio_network', NULL, NEW.radio_network, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_heating_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'id_heating_type', NULL, NEW.id_heating_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_decree IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'id_decree', NULL, NEW.id_decree, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.BTI_rooms IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'BTI_rooms', NULL, NEW.BTI_rooms, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.housing_cooperative IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'housing_cooperative', NULL, NEW.housing_cooperative, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.reg_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'reg_date', NULL, NEW.reg_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.rent_coefficient IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'rent_coefficient', NULL, NEW.rent_coefficient, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_memorial IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'is_memorial', NULL, NEW.is_memorial, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.memorial_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'memorial_date', NULL, NEW.memorial_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.memorial_number IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'memorial_number', NULL, NEW.memorial_number, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.memorial_name_org IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'memorial_name_org', NULL, NEW.memorial_name_org, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_owner_emergency IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'date_owner_emergency', NULL, NEW.date_owner_emergency, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.demolished_fact_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'demolished_fact_date', NULL, NEW.demolished_fact_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.demolished_plan_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'demolished_plan_date', NULL, NEW.demolished_plan_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.demand_for_demolishing_delivery_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'demand_for_demolishing_delivery_date', NULL, NEW.demand_for_demolishing_delivery_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.land_cadastral_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'land_cadastral_num', NULL, NEW.land_cadastral_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.land_cadastral_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'land_cadastral_date', NULL, NEW.land_cadastral_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.land_area IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'land_area', NULL, NEW.land_area, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_organization IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'id_organization', NULL, NEW.id_organization, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.post_index IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'post_index', NULL, NEW.post_index, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `buildings_after_update`
--
CREATE TRIGGER buildings_after_update
AFTER UPDATE
ON buildings
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'buildings', NEW.id_building, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
    CALL update_kumi_accounts_address_infix_by_id_building(NEW.id_building);
  ELSE
    IF (NEW.id_state <> OLD.id_state) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'id_state', OLD.id_state, NEW.id_state, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_structure_type <> OLD.id_structure_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'id_structure_type', OLD.id_structure_type, NEW.id_structure_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_structure_type_overlap <> OLD.id_structure_type_overlap) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'id_structure_type_overlap', OLD.id_structure_type_overlap, NEW.id_structure_type_overlap, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_foundation_type <> OLD.id_foundation_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'id_foundation_type', OLD.id_foundation_type, NEW.id_foundation_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_street <> OLD.id_street) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'id_street', OLD.id_street, NEW.id_street, 'UPDATE', NOW(), USER());
      CALL update_kumi_accounts_address_infix_by_id_building(NEW.id_building);
    END IF;
    IF (NEW.house <> OLD.house) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'house', OLD.house, NEW.house, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.floors <> OLD.floors) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'floors', OLD.floors, NEW.floors, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.entrances IS NULL
      AND OLD.entrances IS NULL)
      AND ((NEW.entrances IS NULL
      AND OLD.entrances IS NOT NULL)
      OR (NEW.entrances IS NOT NULL
      AND OLD.entrances IS NULL)
      OR (NEW.entrances <> OLD.entrances))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'entrances', OLD.entrances, NEW.entrances, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.num_premises <> OLD.num_premises) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'num_premises', OLD.num_premises, NEW.num_premises, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.num_rooms <> OLD.num_rooms) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'num_rooms', OLD.num_rooms, NEW.num_rooms, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.num_apartments <> OLD.num_apartments) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'num_apartments', OLD.num_apartments, NEW.num_apartments, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.num_shared_apartments <> OLD.num_shared_apartments) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'num_shared_apartments', OLD.num_shared_apartments, NEW.num_shared_apartments, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.total_area <> OLD.total_area) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'total_area', OLD.total_area, NEW.total_area, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.living_area <> OLD.living_area) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'living_area', OLD.living_area, NEW.living_area, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.unliving_area <> OLD.unliving_area) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'unliving_area', OLD.unliving_area, NEW.unliving_area, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.common_property_area <> OLD.common_property_area) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'common_property_area', OLD.common_property_area, NEW.common_property_area, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.cadastral_num IS NULL
      AND OLD.cadastral_num IS NULL)
      AND ((NEW.cadastral_num IS NULL
      AND OLD.cadastral_num IS NOT NULL)
      OR (NEW.cadastral_num IS NOT NULL
      AND OLD.cadastral_num IS NULL)
      OR (NEW.cadastral_num <> OLD.cadastral_num))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'cadastral_num', OLD.cadastral_num, NEW.cadastral_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.cadastral_cost <> OLD.cadastral_cost) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'cadastral_cost', OLD.cadastral_cost, NEW.cadastral_cost, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.balance_cost <> OLD.balance_cost) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'balance_cost', OLD.balance_cost, NEW.balance_cost, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.startup_year <> OLD.startup_year) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'startup_year', OLD.startup_year, NEW.startup_year, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.series IS NULL
      AND OLD.series IS NULL)
      AND ((NEW.series IS NULL
      AND OLD.series IS NOT NULL)
      OR (NEW.series IS NOT NULL
      AND OLD.series IS NULL)
      OR (NEW.series <> OLD.series))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'series', OLD.series, NEW.series, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.improvement <> OLD.improvement) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'improvement', OLD.improvement, NEW.improvement, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.elevator <> OLD.elevator) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'elevator', OLD.elevator, NEW.elevator, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.rubbish_chute <> OLD.rubbish_chute) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'rubbish_chute', OLD.rubbish_chute, NEW.rubbish_chute, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.wear <> OLD.wear) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'wear', OLD.wear, NEW.wear, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.state_date IS NULL
      AND OLD.state_date IS NULL)
      AND ((NEW.state_date IS NULL
      AND OLD.state_date IS NOT NULL)
      OR (NEW.state_date IS NOT NULL
      AND OLD.state_date IS NULL)
      OR (NEW.state_date <> OLD.state_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'state_date', OLD.state_date, NEW.state_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.plumbing <> OLD.plumbing) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'plumbing', OLD.plumbing, NEW.plumbing, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.hot_water_supply <> OLD.hot_water_supply) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'hot_water_supply', OLD.hot_water_supply, NEW.hot_water_supply, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.canalization <> OLD.canalization) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'canalization', OLD.canalization, NEW.canalization, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.electricity <> OLD.electricity) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'electricity', OLD.electricity, NEW.electricity, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.radio_network <> OLD.radio_network) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'radio_network', OLD.radio_network, NEW.radio_network, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_heating_type IS NULL
      AND OLD.id_heating_type IS NULL)
      AND ((NEW.id_heating_type IS NULL
      AND OLD.id_heating_type IS NOT NULL)
      OR (NEW.id_heating_type IS NOT NULL
      AND OLD.id_heating_type IS NULL)
      OR (NEW.id_heating_type <> OLD.id_heating_type))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'id_heating_type', OLD.id_heating_type, NEW.id_heating_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_decree IS NULL
      AND OLD.id_decree IS NULL)
      AND ((NEW.id_decree IS NULL
      AND OLD.id_decree IS NOT NULL)
      OR (NEW.id_decree IS NOT NULL
      AND OLD.id_decree IS NULL)
      OR (NEW.id_decree <> OLD.id_decree))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'id_decree', OLD.id_decree, NEW.id_decree, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.BTI_rooms IS NULL
      AND OLD.BTI_rooms IS NULL)
      AND ((NEW.BTI_rooms IS NULL
      AND OLD.BTI_rooms IS NOT NULL)
      OR (NEW.BTI_rooms IS NOT NULL
      AND OLD.BTI_rooms IS NULL)
      OR (NEW.BTI_rooms <> OLD.BTI_rooms))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'BTI_rooms', OLD.BTI_rooms, NEW.BTI_rooms, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.housing_cooperative IS NULL
      AND OLD.housing_cooperative IS NULL)
      AND ((NEW.housing_cooperative IS NULL
      AND OLD.housing_cooperative IS NOT NULL)
      OR (NEW.housing_cooperative IS NOT NULL
      AND OLD.housing_cooperative IS NULL)
      OR (NEW.housing_cooperative <> OLD.housing_cooperative))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'housing_cooperative', OLD.housing_cooperative, NEW.housing_cooperative, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.reg_date <> OLD.reg_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'reg_date', OLD.reg_date, NEW.reg_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.rent_coefficient <> OLD.rent_coefficient) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'rent_coefficient', OLD.rent_coefficient, NEW.rent_coefficient, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.is_memorial <> OLD.is_memorial) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'is_memorial', OLD.is_memorial, NEW.is_memorial, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.memorial_date IS NULL
      AND OLD.memorial_date IS NULL)
      AND ((NEW.memorial_date IS NULL
      AND OLD.memorial_date IS NOT NULL)
      OR (NEW.memorial_date IS NOT NULL
      AND OLD.memorial_date IS NULL)
      OR (NEW.memorial_date <> OLD.memorial_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'memorial_date', OLD.memorial_date, NEW.memorial_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.memorial_number IS NULL
      AND OLD.memorial_number IS NULL)
      AND ((NEW.memorial_number IS NULL
      AND OLD.memorial_number IS NOT NULL)
      OR (NEW.memorial_number IS NOT NULL
      AND OLD.memorial_number IS NULL)
      OR (NEW.memorial_number <> OLD.memorial_number))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'memorial_number', OLD.memorial_number, NEW.memorial_number, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.memorial_name_org IS NULL
      AND OLD.memorial_name_org IS NULL)
      AND ((NEW.memorial_name_org IS NULL
      AND OLD.memorial_name_org IS NOT NULL)
      OR (NEW.memorial_name_org IS NOT NULL
      AND OLD.memorial_name_org IS NULL)
      OR (NEW.memorial_name_org <> OLD.memorial_name_org))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'memorial_name_org', OLD.memorial_name_org, NEW.memorial_name_org, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.memorial_name_org IS NULL
      AND OLD.memorial_name_org IS NULL)
      AND ((NEW.memorial_name_org IS NULL
      AND OLD.memorial_name_org IS NOT NULL)
      OR (NEW.memorial_name_org IS NOT NULL
      AND OLD.memorial_name_org IS NULL)
      OR (NEW.memorial_name_org <> OLD.memorial_name_org))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'memorial_name_org', OLD.memorial_name_org, NEW.memorial_name_org, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_owner_emergency IS NULL
      AND OLD.date_owner_emergency IS NULL)
      AND ((NEW.date_owner_emergency IS NULL
      AND OLD.date_owner_emergency IS NOT NULL)
      OR (NEW.date_owner_emergency IS NOT NULL
      AND OLD.date_owner_emergency IS NULL)
      OR (NEW.date_owner_emergency <> OLD.date_owner_emergency))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'date_owner_emergency', OLD.date_owner_emergency, NEW.date_owner_emergency, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.demolished_fact_date IS NULL
      AND OLD.demolished_fact_date IS NULL)
      AND ((NEW.demolished_fact_date IS NULL
      AND OLD.demolished_fact_date IS NOT NULL)
      OR (NEW.demolished_fact_date IS NOT NULL
      AND OLD.demolished_fact_date IS NULL)
      OR (NEW.demolished_fact_date <> OLD.demolished_fact_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'demolished_fact_date', OLD.demolished_fact_date, NEW.demolished_fact_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.demolished_plan_date IS NULL
      AND OLD.demolished_plan_date IS NULL)
      AND ((NEW.demolished_plan_date IS NULL
      AND OLD.demolished_plan_date IS NOT NULL)
      OR (NEW.demolished_plan_date IS NOT NULL
      AND OLD.demolished_plan_date IS NULL)
      OR (NEW.demolished_plan_date <> OLD.demolished_plan_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'demolished_plan_date', OLD.demolished_plan_date, NEW.demolished_plan_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.demand_for_demolishing_delivery_date IS NULL
      AND OLD.demand_for_demolishing_delivery_date IS NULL)
      AND ((NEW.demand_for_demolishing_delivery_date IS NULL
      AND OLD.demand_for_demolishing_delivery_date IS NOT NULL)
      OR (NEW.demand_for_demolishing_delivery_date IS NOT NULL
      AND OLD.demand_for_demolishing_delivery_date IS NULL)
      OR (NEW.demand_for_demolishing_delivery_date <> OLD.demand_for_demolishing_delivery_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'demand_for_demolishing_delivery_date', OLD.demand_for_demolishing_delivery_date, NEW.demand_for_demolishing_delivery_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.land_cadastral_num IS NULL
      AND OLD.land_cadastral_num IS NULL)
      AND ((NEW.land_cadastral_num IS NULL
      AND OLD.land_cadastral_num IS NOT NULL)
      OR (NEW.land_cadastral_num IS NOT NULL
      AND OLD.land_cadastral_num IS NULL)
      OR (NEW.land_cadastral_num <> OLD.land_cadastral_num))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'land_cadastral_num', OLD.land_cadastral_num, NEW.land_cadastral_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.land_cadastral_date IS NULL
      AND OLD.land_cadastral_date IS NULL)
      AND ((NEW.land_cadastral_date IS NULL
      AND OLD.land_cadastral_date IS NOT NULL)
      OR (NEW.land_cadastral_date IS NOT NULL
      AND OLD.land_cadastral_date IS NULL)
      OR (NEW.land_cadastral_date <> OLD.land_cadastral_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'land_cadastral_date', OLD.land_cadastral_date, NEW.land_cadastral_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.land_area <> OLD.land_area) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'land_area', OLD.land_area, NEW.land_area, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_organization IS NULL
      AND OLD.id_organization IS NULL)
      AND ((NEW.id_organization IS NULL
      AND OLD.id_organization IS NOT NULL)
      OR (NEW.id_organization IS NOT NULL
      AND OLD.id_organization IS NULL)
      OR (NEW.id_organization <> OLD.id_organization))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'id_organization', OLD.id_organization, NEW.id_organization, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.post_index IS NULL
      AND OLD.post_index IS NULL)
      AND ((NEW.post_index IS NULL
      AND OLD.post_index IS NOT NULL)
      OR (NEW.post_index IS NOT NULL
      AND OLD.post_index IS NULL)
      OR (NEW.post_index <> OLD.post_index))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'buildings', NEW.id_building, 'post_index', OLD.post_index, NEW.post_index, 'UPDATE', NOW(), USER());
    END IF;

    -- Обновление коэффициентов платы за найм
    IF ((NEW.id_structure_type <> OLD.id_structure_type)
      OR (NEW.canalization <> OLD.canalization)
      OR (NEW.plumbing <> OLD.plumbing)
      OR (NEW.hot_water_supply <> OLD.hot_water_supply)
      OR (NEW.id_street <> OLD.id_street)) THEN
      INSERT INTO tenancy_payments_history (id_building, id_premises, id_sub_premises, rent_area, k1, k2, k3, kc, Hb,
      date, reason)
        SELECT
          vpca.id_building,
          vpca.id_premises,
          vpca.id_sub_premises,
          vpca.rent_area,
          vpca.k1,
          vpca.k2,
          vpca.k3,
          vpca.kc,
          vpca.Hb,
          NOW(),
          'Изменение характеристик здания'
        FROM v_payments_coefficients_all vpca
        WHERE vpca.id_building = NEW.id_building;
    END IF;
  END IF;
END
$$

--
-- Создать триггер `buildings_before_update`
--
CREATE TRIGGER buildings_before_update
BEFORE UPDATE
ON buildings
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    UPDATE premises
    SET deleted = 1
    WHERE id_building = NEW.id_building;
    UPDATE funds_buildings_assoc
    SET deleted = 1
    WHERE id_building = NEW.id_building;
    UPDATE ownership_buildings_assoc
    SET deleted = 1
    WHERE id_building = NEW.id_building;
    UPDATE restrictions_buildings_assoc
    SET deleted = 1
    WHERE id_building = NEW.id_building;
    UPDATE tenancy_buildings_assoc
    SET deleted = 1
    WHERE id_building = NEW.id_building;
    UPDATE resettle_buildings_from_assoc
    SET deleted = 1
    WHERE id_building = NEW.id_building;
    UPDATE resettle_buildings_to_assoc
    SET deleted = 1
    WHERE id_building = NEW.id_building;
    UPDATE judges_buildings_assoc
    SET deleted = 1
    WHERE id_building = NEW.id_building;
    UPDATE building_attachment_files_assoc
    SET deleted = 1
    WHERE id_building = NEW.id_building;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE buildings
ADD CONSTRAINT FK_buildings_id_organization FOREIGN KEY (id_organization)
REFERENCES buildings_managment_orgs (id_organization) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE buildings
ADD CONSTRAINT FK_buildings_heating_type_id_heating_type FOREIGN KEY (id_heating_type)
REFERENCES heating_type (id_heating_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE buildings
ADD CONSTRAINT FK_buildings_id_decree FOREIGN KEY (id_decree)
REFERENCES government_decree (id_decree) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE buildings
ADD CONSTRAINT FK_buildings_id_foundation_type FOREIGN KEY (id_foundation_type)
REFERENCES foundation_types (id_foundation_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE buildings
ADD CONSTRAINT FK_buildings_id_structure_type_overlap FOREIGN KEY (id_structure_type_overlap)
REFERENCES structure_type_overlap (id_structure_type_overlap) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE buildings
ADD CONSTRAINT FK_buildings_states_id_state FOREIGN KEY (id_state)
REFERENCES object_states (id_state) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE building_attachment_files_assoc
ADD CONSTRAINT FK_building_attachment_files_assoc_id_building FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE funds_buildings_assoc
ADD CONSTRAINT FK_fund_buildings_assoc_buildings_id_building FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE judges_buildings_assoc
ADD CONSTRAINT FK_judges_buildings_assoc_id_b FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE ownership_buildings_assoc
ADD CONSTRAINT FK_ownership_buildings_assoc_buildings_id_building FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Создать внешний ключ
--
ALTER TABLE premises
ADD CONSTRAINT FK_premises_buildings_id_building FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_buildings_from_assoc
ADD CONSTRAINT FK_resettle_buildings_from_assoc_buildings_id_building FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_buildings_to_assoc
ADD CONSTRAINT FK_resettle_buildings_to_assoc_buildings_id_building FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE restrictions_buildings_assoc
ADD CONSTRAINT FK_restrictions_buildings_assoc_buildings_id_building FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_buildings_assoc
ADD CONSTRAINT FK_tenancy_buildings_assoc_buildings_id_building FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_payments_history
ADD CONSTRAINT FK_tenancy_payments_history_id_building FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать представление `v_tenancy_rent_ids_prepare`
--
CREATE
VIEW v_tenancy_rent_ids_prepare
AS
SELECT
  `tpa`.`id_process` AS `id_process`,
  GROUP_CONCAT(CONCAT('p', `tpa`.`id_premises`) ORDER BY `tpa`.`id_premises` ASC SEPARATOR '') AS `rent_ids`
FROM (`tenancy_premises_assoc` `tpa`
  JOIN `premises` `p`
    ON ((`tpa`.`id_premises` = `p`.`id_premises`)))
WHERE ((`tpa`.`deleted` <> 1)
AND (`p`.`id_state` IN (4, 5, 9, 11, 12, 14)))
GROUP BY `tpa`.`id_process`
UNION ALL
SELECT
  `tspa`.`id_process` AS `id_process`,
  GROUP_CONCAT(CONCAT('sp', `tspa`.`id_sub_premises`) ORDER BY `tspa`.`id_sub_premises` ASC SEPARATOR '') AS `rent_ids`
FROM (`tenancy_sub_premises_assoc` `tspa`
  JOIN `sub_premises` `sp`
    ON ((`tspa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
WHERE ((`tspa`.`deleted` <> 1)
AND (`sp`.`id_state` IN (4, 5, 9, 11, 12, 14)))
GROUP BY `tspa`.`id_process`
UNION ALL
SELECT
  `tba`.`id_process` AS `id_process`,
  GROUP_CONCAT(CONCAT('b', `tba`.`id_building`) ORDER BY `tba`.`id_building` ASC SEPARATOR '') AS `rent_ids`
FROM (`tenancy_buildings_assoc` `tba`
  JOIN `buildings` `b`
    ON ((`tba`.`id_building` = `b`.`id_building`)))
WHERE ((`tba`.`deleted` <> 1)
AND (`b`.`id_state` IN (4, 5, 9, 11, 12, 14)))
GROUP BY `tba`.`id_process`;

--
-- Создать представление `v_tenancy_rent_ids`
--
CREATE
VIEW v_tenancy_rent_ids
AS
SELECT
  `ta`.`id_process` AS `id_process`,
  GROUP_CONCAT(`ta`.`rent_ids` ORDER BY `ta`.`rent_ids` ASC SEPARATOR '') AS `rent_ids`
FROM `v_tenancy_rent_ids_prepare` `ta`
GROUP BY `ta`.`id_process`;

--
-- Создать представление `v_tenancy_rent_ids_max_date`
--
CREATE
VIEW v_tenancy_rent_ids_max_date
AS
SELECT
  `vtri`.`rent_ids` AS `rent_ids`,
  MAX(`tp`.`registration_date`) AS `max_registration_date`
FROM (`v_tenancy_rent_ids` `vtri`
  JOIN `tenancy_processes` `tp`
    ON ((`vtri`.`id_process` = `tp`.`id_process`)))
WHERE ((`tp`.`deleted` <> 1)
AND (ISNULL(`tp`.`registration_num`)
OR (NOT ((`tp`.`registration_num` LIKE '%н%')))))
GROUP BY `vtri`.`rent_ids`;

--
-- Создать представление `v_tenancy_active_contracts`
--
CREATE
VIEW v_tenancy_active_contracts
AS
SELECT
  MAX(`tp`.`id_process`) AS `id_process`
FROM ((`v_tenancy_rent_ids` `vtri`
  JOIN `tenancy_processes` `tp`
    ON ((`vtri`.`id_process` = `tp`.`id_process`)))
  JOIN `v_tenancy_rent_ids_max_date` `vtrimd`
    ON (((`vtri`.`rent_ids` = `vtrimd`.`rent_ids`)
    AND ((`tp`.`registration_date` = `vtrimd`.`max_registration_date`)
    OR (ISNULL(`tp`.`registration_date`)
    AND ISNULL(`vtrimd`.`max_registration_date`))))))
GROUP BY `vtri`.`rent_ids`;

--
-- Создать представление `v_payments_prepare`
--
CREATE
VIEW v_payments_prepare
AS
SELECT
  `vtac`.`id_process` AS `id_process`,
  `p`.`id_building` AS `id_building`,
  `sp`.`id_premises` AS `id_premises`,
  `tspa`.`id_sub_premises` AS `id_sub_premises`,
  2 AS `id_premises_type`,
  `sp`.`total_area` AS `total_area`,
  `tspa`.`rent_total_area` AS `rent_total_area`
FROM (((`v_tenancy_active_contracts` `vtac`
  JOIN `tenancy_sub_premises_assoc` `tspa`
    ON ((`vtac`.`id_process` = `tspa`.`id_process`)))
  JOIN `sub_premises` `sp`
    ON ((`tspa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
WHERE ((`tspa`.`deleted` = 0)
AND (`sp`.`deleted` = 0)
AND (`p`.`deleted` = 0))
UNION ALL
SELECT
  `vtac`.`id_process` AS `id_process`,
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  NULL AS `NULL`,
  IF((`p`.`id_premises_type` = 1), 1, 2) AS `id_premises_type`,
  `p`.`total_area` AS `total_area`,
  `tpa`.`rent_total_area` AS `rent_total_area`
FROM ((`v_tenancy_active_contracts` `vtac`
  JOIN `tenancy_premises_assoc` `tpa`
    ON ((`vtac`.`id_process` = `tpa`.`id_process`)))
  JOIN `premises` `p`
    ON ((`tpa`.`id_premises` = `p`.`id_premises`)))
WHERE ((`tpa`.`deleted` = 0)
AND (`p`.`deleted` = 0))
UNION ALL
SELECT
  `vtac`.`id_process` AS `id_process`,
  `b`.`id_building` AS `id_building`,
  NULL AS `NULL`,
  NULL AS `NULL`,
  1 AS `id_premises_type`,
  `b`.`total_area` AS `total_area`,
  `tba`.`rent_total_area` AS `rent_total_area`
FROM ((`v_tenancy_active_contracts` `vtac`
  JOIN `tenancy_buildings_assoc` `tba`
    ON ((`vtac`.`id_process` = `tba`.`id_process`)))
  JOIN `buildings` `b`
    ON ((`tba`.`id_building` = `b`.`id_building`)))
WHERE ((`tba`.`deleted` = 0)
AND (`b`.`deleted` = 0));

--
-- Создать представление `v_payments_coefficients`
--
CREATE
VIEW v_payments_coefficients
AS
SELECT
  `vpp`.`id_process` AS `id_process`,
  `vpp`.`id_building` AS `id_building`,
  `vpp`.`id_premises` AS `id_premises`,
  `vpp`.`id_sub_premises` AS `id_sub_premises`,
  IFNULL(`vpp`.`rent_total_area`, `vpp`.`total_area`) AS `rent_area`,
  ((IF((`vpp`.`id_premises_type` = 1), 1.3, 0.8) + IF((`b`.`id_structure_type` IN (4, 9)), 1, IF((`b`.`id_structure_type` = 3), 0.9, IF((`b`.`id_structure_type` IN (2, 5, 6, 8)), 0.8, 0)))) / 2) AS `k1`,
  IF(((`b`.`hot_water_supply` = 1) AND (`b`.`plumbing` = 1) AND (`b`.`canalization` = 1) AND (`vpp`.`id_premises_type` = 1)), 1.3, IF(((`b`.`plumbing` = 1) AND (`b`.`canalization` = 1) AND (`vpp`.`id_premises_type` = 1)), 1, 0.8)) AS `k2`,
  IF((`b`.`id_street` REGEXP '^380000050410'), 1, IF((`b`.`id_street` REGEXP '^380000050230'), 1, IF((`b`.`id_street` REGEXP '^380000050180'), 1, IF((`b`.`id_street` REGEXP '^380000050130'), 0.9, 0.8)))) AS `k3`,
  0.18 AS `kc`,
  ((SELECT
      `total_area_avg_cost`.`cost`
    FROM `total_area_avg_cost`
    ORDER BY `total_area_avg_cost`.`id` DESC LIMIT 1) * 0.001) AS `Hb`
FROM (`v_payments_prepare` `vpp`
  JOIN `buildings` `b`
    ON ((`vpp`.`id_building` = `b`.`id_building`)));

--
-- Создать представление `v_tenancy_address_building_prepare1`
--
CREATE
VIEW v_tenancy_address_building_prepare1
AS
SELECT
  `v`.`id_process` AS `id_process`,
  `p`.`id_building` AS `id_building`,
  `b`.`post_index` AS `post_index`,
  `b`.`house` AS `house_only`,
  CONCAT(`b`.`house`, ', ', GROUP_CONCAT(CONCAT('кв. ', `v`.`premises_num`) SEPARATOR ', ')) AS `house`,
  SUM(`v`.`total_area`) AS `total_area`
FROM ((`v_tenancy_address_premises_prepare2` `v`
  JOIN `premises` `p`
    ON ((`v`.`id_premises` = `p`.`id_premises`)))
  JOIN `buildings` `b`
    ON ((`p`.`id_building` = `b`.`id_building`)))
GROUP BY `v`.`id_process`,
         `p`.`id_building`
UNION ALL
SELECT
  `tba`.`id_process` AS `id_process`,
  `tba`.`id_building` AS `id_building`,
  `b`.`post_index` AS `post_index`,
  `b`.`house` AS `house_only`,
  `b`.`house` AS `house`,
  `b`.`total_area` AS `total_area`
FROM (`tenancy_buildings_assoc` `tba`
  JOIN `buildings` `b`
    ON ((`tba`.`id_building` = `b`.`id_building`)))
WHERE ((`tba`.`deleted` <> 1)
AND (`b`.`deleted` <> 1));

--
-- Создать представление `v_tenancy_address_building_prepare2`
--
CREATE
VIEW v_tenancy_address_building_prepare2
AS
SELECT
  `v`.`id_process` AS `id_process`,
  `v`.`id_building` AS `id_building`,
  `v`.`post_index` AS `post_index`,
  GROUP_CONCAT(CONCAT('д. ', `v`.`house_only`) SEPARATOR ', ') AS `house_only`,
  GROUP_CONCAT(CONCAT('д. ', `v`.`house`) SEPARATOR ', ') AS `house`,
  SUM(`v`.`total_area`) AS `total_area`
FROM `v_tenancy_address_building_prepare1` `v`
GROUP BY `v`.`id_process`,
         `v`.`id_building`;

--
-- Создать представление `v_tenancy_address`
--
CREATE
VIEW v_tenancy_address
AS
SELECT
  `v`.`id_process` AS `id_process`,
  `v`.`post_index` AS `post_index`,
  CONCAT(`vks`.`street_name`, ', ', `v`.`house_only`) AS `address_house`,
  GROUP_CONCAT(CONCAT(`vks`.`street_name`, ', ', `v`.`house`) SEPARATOR ', ') AS `address`,
  SUM(`v`.`total_area`) AS `total_area`
FROM ((`registry`.`v_tenancy_address_building_prepare2` `v`
  JOIN `registry`.`buildings` `b`
    ON ((`b`.`id_building` = `v`.`id_building`)))
  JOIN `registry`.`v_kladr_streets` `vks`
    ON ((`b`.`id_street` = `vks`.`id_street`)))
GROUP BY `v`.`id_process`;

--
-- Создать представление `v_kumi_account_address_prepare1`
--
CREATE
VIEW v_kumi_account_address_prepare1
AS
SELECT
  `katpa`.`id_account` AS `id_account`,
  `vta`.`post_index` AS `post_index`,
  `vta`.`address_house` AS `address_house`,
  `vta`.`address` AS `address`,
  `katpa`.`id_process` AS `id_process`,
  IFNULL(`tp`.`registration_date`, `tp`.`issue_date`) AS `date`
FROM ((`registry`.`tenancy_processes` `tp`
  JOIN `registry`.`kumi_accounts_t_processes_assoc` `katpa`
    ON ((`tp`.`id_process` = `katpa`.`id_process`)))
  LEFT JOIN `registry`.`v_tenancy_address` `vta`
    ON ((`vta`.`id_process` = `katpa`.`id_process`)))
WHERE ((`katpa`.`deleted` <> 1)
AND (`tp`.`deleted` <> 1));

--
-- Создать представление `v_kumi_account_address`
--
CREATE
VIEW v_kumi_account_address
AS
SELECT
  `v`.`id_account` AS `id_account`,
  SUBSTRING_INDEX(GROUP_CONCAT(`v`.`post_index` ORDER BY `v`.`date` DESC SEPARATOR '||'), '||', 1) AS `post_index`,
  SUBSTRING_INDEX(GROUP_CONCAT(`v`.`address_house` ORDER BY `v`.`date` DESC SEPARATOR '||'), '||', 1) AS `address_house`,
  SUBSTRING_INDEX(GROUP_CONCAT(`v`.`address` ORDER BY `v`.`date` DESC SEPARATOR '||'), '||', 1) AS `address`,
  CAST(SUBSTRING_INDEX(GROUP_CONCAT(`v`.`id_process` ORDER BY `v`.`date` DESC SEPARATOR '||'), '||', 1) AS UNSIGNED) AS `id_process`
FROM `registry`.`v_kumi_account_address_prepare1` `v`
GROUP BY `v`.`id_account`;

DELIMITER $$

--
-- Создать процедуру `get_charges_for_sberbank`
--
CREATE PROCEDURE get_charges_for_sberbank (IN on_date date)
BEGIN
  SELECT
    @i := @i + 1 AS id,
    v.*
  FROM (SELECT
           ka.account,
           CASE WHEN ka.owner IS NULL THEN kn.tenant ELSE ka.owner END AS tenant,
           kadr.address,
           '90111109044041000120' AS kbk,
           '25714000' AS okato,
           REPLACE(CAST(IFNULL(kc.output_tenancy, lkc.output_tenancy) +
           IFNULL(kc.output_penalty, lkc.output_penalty) +
           IFNULL(kc.output_dgi, lkc.output_dgi) +
           IFNULL(kc.output_pkk, lkc.output_pkk) +
           IFNULL(kc.output_padun, lkc.output_padun) AS char), '.', ',') AS `sum`
         FROM kumi_accounts ka
           LEFT JOIN v_kumi_account_address kadr
             ON ka.id_account = kadr.id_account
           LEFT JOIN kumi_accounts_actual_tp_search_denorm kn
             ON ka.id_account = kn.id_account
           INNER JOIN (SELECT
               kc.*
             FROM (SELECT
                 kc.id_account,
                 MAX(kc.end_date) AS end_date
               FROM kumi_charges kc
               WHERE kc.deleted <> 1
               AND kc.hidden <> 1
               GROUP BY kc.id_account) v
               JOIN kumi_charges kc
                 ON v.id_account = kc.id_account
                 AND v.end_date = kc.end_date
             WHERE kc.deleted <> 1
             AND kc.hidden <> 1) lkc
             ON ka.id_account = lkc.id_account
           LEFT JOIN (SELECT
               *
             FROM kumi_charges kc
             WHERE kc.end_date = on_date
             AND kc.deleted = 0
             AND kc.hidden = 0) kc
             ON ka.id_account = kc.id_account
         WHERE IFNULL(kc.output_tenancy, lkc.output_tenancy) +
         IFNULL(kc.output_penalty, lkc.output_penalty) +
         IFNULL(kc.output_dgi, lkc.output_dgi) +
         IFNULL(kc.output_pkk, lkc.output_pkk) +
         IFNULL(kc.output_padun, lkc.output_padun) <> 0) v,
       (SELECT
           @i := 0) n;
END
$$

DELIMITER ;

--
-- Создать представление `v_rent_objects`
--
CREATE
VIEW v_rent_objects
AS
SELECT
  `tspa`.`id_process` AS `id_process`,
  `b`.`id_building` AS `id_building`,
  `b`.`id_structure_type` AS `id_structure_type`,
  `b`.`improvement` AS `improvement`,
  `b`.`floors` AS `floors`,
  `b`.`rent_coefficient` AS `rent_coefficient`,
  `p`.`id_premises` AS `id_premises`,
  `sp`.`id_sub_premises` AS `id_sub_premises`,
  `sp`.`total_area` AS `total_area`,
  `sp`.`living_area` AS `living_area`,
  `tspa`.`rent_total_area` AS `rent_total_area`
FROM (((`tenancy_sub_premises_assoc` `tspa`
  JOIN `sub_premises` `sp`
    ON ((`tspa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
  JOIN `buildings` `b`
    ON ((`p`.`id_building` = `b`.`id_building`)))
WHERE (`tspa`.`deleted` <> 1)
UNION ALL
SELECT
  `tpa`.`id_process` AS `id_process`,
  `b`.`id_building` AS `id_building`,
  `b`.`id_structure_type` AS `id_structure_type`,
  `b`.`improvement` AS `improvement`,
  `b`.`floors` AS `floors`,
  `b`.`rent_coefficient` AS `rent_coefficient`,
  `p`.`id_premises` AS `id_premises`,
  NULL AS `NULL`,
  `p`.`total_area` AS `total_area`,
  `p`.`living_area` AS `living_area`,
  `tpa`.`rent_total_area` AS `rent_total_area`
FROM ((`tenancy_premises_assoc` `tpa`
  JOIN `premises` `p`
    ON ((`tpa`.`id_premises` = `p`.`id_premises`)))
  JOIN `buildings` `b`
    ON ((`p`.`id_building` = `b`.`id_building`)))
WHERE (`tpa`.`deleted` <> 1)
UNION ALL
SELECT
  `tba`.`id_process` AS `id_process`,
  `b`.`id_building` AS `id_building`,
  `b`.`id_structure_type` AS `id_structure_type`,
  `b`.`improvement` AS `improvement`,
  `b`.`floors` AS `floors`,
  `b`.`rent_coefficient` AS `rent_coefficient`,
  NULL AS `NULL`,
  NULL AS `NULL`,
  `b`.`total_area` AS `total_area`,
  `b`.`living_area` AS `living_area`,
  `tba`.`rent_total_area` AS `rent_total_area`
FROM (`tenancy_buildings_assoc` `tba`
  JOIN `buildings` `b`
    ON ((`tba`.`id_building` = `b`.`id_building`)))
WHERE (`tba`.`deleted` <> 1);

--
-- Создать представление `v_premises_ownership_rights_3_all`
--
CREATE
VIEW v_premises_ownership_rights_3_all
AS
SELECT
  `opa`.`id_premises` AS `id_premises`,
  `ort`.`ownership_right_type` AS `ownership_right_type`,
  `owr`.`id_ownership_right` AS `id_ownership_right`,
  `owr`.`id_ownership_right_type` AS `id_ownership_right_type`,
  `owr`.`number` AS `number`,
  `owr`.`date` AS `date`,
  `owr`.`description` AS `description`,
  `owr`.`resettle_plan_date` AS `resettle_plan_date`,
  `owr`.`demolish_plan_date` AS `demolish_plan_date`
FROM ((`ownership_premises_assoc` `opa`
  JOIN `ownership_rights` `owr`
    ON (((`opa`.`id_ownership_right` = `owr`.`id_ownership_right`)
    AND (`owr`.`deleted` = 0)
    AND (`owr`.`id_ownership_right_type` IN (1, 2, 6, 7, 8)))))
  JOIN `ownership_right_types` `ort`
    ON (((`owr`.`id_ownership_right_type` = `ort`.`id_ownership_right_type`)
    AND (`ort`.`deleted` = 0))))
WHERE (`opa`.`deleted` = 0)
UNION
SELECT
  `p`.`id_premises` AS `id_premises`,
  `vbora`.`ownership_right_type` AS `ownership_right_type`,
  `vbora`.`id_ownership_right` AS `id_ownership_right`,
  `vbora`.`id_ownership_right_type` AS `id_ownership_right_type`,
  `vbora`.`number` AS `number`,
  `vbora`.`date` AS `date`,
  `vbora`.`description` AS `description`,
  `vbora`.`resettle_plan_date` AS `resettle_plan_date`,
  `vbora`.`demolish_plan_date` AS `demolish_plan_date`
FROM ((`v_buildings_ownership_rights_3_all` `vbora`
  JOIN `buildings` `b`
    ON (((`vbora`.`id_building` = `b`.`id_building`)
    AND (`b`.`deleted` = 0))))
  JOIN `premises` `p`
    ON (((`b`.`id_building` = `p`.`id_building`)
    AND (`p`.`deleted` = 0))));

--
-- Создать представление `v_premises_ownership_rights_2_max_date`
--
CREATE
VIEW v_premises_ownership_rights_2_max_date
AS
SELECT
  `vpora`.`id_premises` AS `id_premises`,
  MAX(`vpora`.`date`) AS `max_date`
FROM `v_premises_ownership_rights_3_all` `vpora`
GROUP BY `vpora`.`id_premises`;

--
-- Создать представление `v_premises_ownership_rights_2_max_id_ownership_right`
--
CREATE
VIEW v_premises_ownership_rights_2_max_id_ownership_right
AS
SELECT
  `vpor3`.`id_premises` AS `id_premises`,
  MAX(`vpor3`.`id_ownership_right`) AS `max_id_ownership_right`
FROM (`v_premises_ownership_rights_3_all` `vpor3`
  JOIN `v_premises_ownership_rights_2_max_date` `vpor2`
    ON (((`vpor3`.`id_premises` = `vpor2`.`id_premises`)
    AND (`vpor3`.`date` = `vpor2`.`max_date`))))
GROUP BY `vpor3`.`id_premises`;

--
-- Создать представление `v_premises_ownership_rights_1_current`
--
CREATE
VIEW v_premises_ownership_rights_1_current
AS
SELECT
  `vpora`.`id_premises` AS `id_premises`,
  `vpora`.`ownership_right_type` AS `ownership_right_type`,
  `vpora`.`id_ownership_right` AS `id_ownership_right`,
  `vpora`.`id_ownership_right_type` AS `id_ownership_right_type`,
  `vpora`.`number` AS `number`,
  `vpora`.`date` AS `date`,
  `vpora`.`description` AS `description`,
  `vpora`.`resettle_plan_date` AS `resettle_plan_date`,
  `vpora`.`demolish_plan_date` AS `demolish_plan_date`
FROM (`v_premises_ownership_rights_3_all` `vpora`
  JOIN `v_premises_ownership_rights_2_max_id_ownership_right` `vpormior`
    ON (((`vpora`.`id_premises` = `vpormior`.`id_premises`)
    AND (`vpora`.`id_ownership_right` = `vpormior`.`max_id_ownership_right`))))
ORDER BY `vpora`.`id_premises`;

--
-- Создать представление `v_premises_overhaul_aggregate_info`
--
CREATE
VIEW v_premises_overhaul_aggregate_info
AS
SELECT
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  IF((`b`.`floors` < 6), 6.07, 8.39) AS `payment_for_overhaul`,
  `r`.`number` AS `include_number`,
  `r`.`date` AS `include_date`,
  `vpp`.`number` AS `privatiz_number`,
  `vpp`.`date` AS `privatiz_date`,
  `vpsr`.`date_state_reg` AS `date_state_reg`
FROM (((((`premises` `p`
  JOIN `buildings` `b`
    ON ((`p`.`id_building` = `b`.`id_building`)))
  LEFT JOIN `v_premises_included_into_municipal` `vpiim`
    ON ((`p`.`id_premises` = `vpiim`.`id_premises`)))
  LEFT JOIN `restrictions` `r`
    ON ((`vpiim`.`id_restriction` = `r`.`id_restriction`)))
  LEFT JOIN `v_premises_privatiz` `vpp`
    ON ((`p`.`id_premises` = `vpp`.`id_premises`)))
  LEFT JOIN `v_premises_state_reg` `vpsr`
    ON ((`p`.`id_premises` = `vpsr`.`id_premises`)))
WHERE (`p`.`deleted` <> 1);

--
-- Создать представление `v_fias_house_guid`
--
CREATE
VIEW v_fias_house_guid
AS
SELECT
  `b`.`id_building` AS `id_building`,
  `sn`.`FIAS_CODE` AS `AOGUID`,
  `h`.`HOUSEGUID` AS `HOUSEGUID`
FROM ((`registry`.`buildings` `b`
  JOIN `kladr`.`street_name` `sn`
    ON ((`b`.`id_street` = `sn`.`CODE`)))
  LEFT JOIN `fias`.`house38` `h`
    ON (((`sn`.`FIAS_CODE` = `h`.`AOGUID`)
    AND (TRIM(`b`.`house`) = CONCAT(`h`.`HOUSENUM`, IF((`h`.`BUILDNUM` <> ''), CONCAT(' корп. ', `h`.`BUILDNUM`), ''), IF((`h`.`STRUCNUM` <> ''), CONCAT(' стр. ', `h`.`STRUCNUM`), '')))
    AND (`h`.`ENDDATE` >= NOW()))))
WHERE (`b`.`deleted` <> 1);

--
-- Создать представление `v_buildings_premises_count`
--
CREATE
VIEW v_buildings_premises_count
AS
SELECT
  `b`.`id_building` AS `id_building`,
  IF((COUNT(0) > `b`.`num_premises`), COUNT(0), `b`.`num_premises`) AS `premises_count`
FROM (`premises` `p`
  JOIN `buildings` `b`
    ON ((`p`.`id_building` = `b`.`id_building`)))
WHERE (`p`.`deleted` <> 1)
GROUP BY `b`.`id_building`,
         `b`.`num_premises`;

--
-- Создать представление `v_buildings_last_municipal_restrictions`
--
CREATE
VIEW v_buildings_last_municipal_restrictions
AS
SELECT
  `b`.`id_building` AS `id_building`,
  `include_restrictions`.`number` AS `in_number`,
  `include_restrictions`.`date` AS `in_date`,
  `include_restrictions`.`description` AS `in_description`,
  IF(ISNULL(`include_restrictions`.`date`), `exclude_restrictions`.`number`, IF((`include_restrictions`.`date` > `exclude_restrictions`.`date`), NULL, `exclude_restrictions`.`number`)) AS `ex_number`,
  IF(ISNULL(`include_restrictions`.`date`), `exclude_restrictions`.`date`, IF((`include_restrictions`.`date` > `exclude_restrictions`.`date`), NULL, `exclude_restrictions`.`date`)) AS `ex_date`,
  IF(ISNULL(`include_restrictions`.`date`), `exclude_restrictions`.`description`, IF((`include_restrictions`.`date` > `exclude_restrictions`.`date`), NULL, `exclude_restrictions`.`description`)) AS `ex_description`
FROM ((`buildings` `b`
  LEFT JOIN `v_buildings_municipal_exclude_restrictions` `exclude_restrictions`
    ON ((`exclude_restrictions`.`id_building` = `b`.`id_building`)))
  LEFT JOIN `v_buildings_municipal_include_restrictions` `include_restrictions`
    ON ((`include_restrictions`.`id_building` = `b`.`id_building`)))
WHERE (((`include_restrictions`.`id_building` IS NOT NULL)
OR (`exclude_restrictions`.`id_building` IS NOT NULL))
AND (`b`.`deleted` <> 1));

--
-- Создать представление `v_buildings_excluded_from_emergency`
--
CREATE
VIEW v_buildings_excluded_from_emergency
AS
SELECT
  `b`.`id_building` AS `id_building`,
  `b`.`id_state` AS `id_state`,
  `b`.`id_structure_type` AS `id_structure_type`,
  `b`.`id_street` AS `id_street`,
  `b`.`house` AS `house`,
  `b`.`floors` AS `floors`,
  `b`.`num_premises` AS `num_premises`,
  `b`.`num_rooms` AS `num_rooms`,
  `b`.`num_apartments` AS `num_apartments`,
  `b`.`num_shared_apartments` AS `num_shared_apartments`,
  `b`.`living_area` AS `living_area`,
  `b`.`cadastral_num` AS `cadastral_num`,
  `b`.`cadastral_cost` AS `cadastral_cost`,
  `b`.`balance_cost` AS `balance_cost`,
  `b`.`description` AS `description`,
  `b`.`startup_year` AS `startup_year`,
  `b`.`improvement` AS `improvement`,
  `b`.`elevator` AS `elevator`,
  `b`.`deleted` AS `deleted`,
  `or1`.`number` AS `or_number`,
  `or1`.`date` AS `or_date`,
  `or1`.`description` AS `or_description`
FROM ((`buildings` `b`
  JOIN `ownership_buildings_assoc` `opa`
    ON ((`b`.`id_building` = `opa`.`id_building`)))
  JOIN `ownership_rights` `or1`
    ON ((`opa`.`id_ownership_right` = `or1`.`id_ownership_right`)))
WHERE ((`or1`.`id_ownership_right_type` = 6)
AND (`opa`.`deleted` <> 1)
AND (`or1`.`deleted` <> 1)
AND (`b`.`deleted` <> 1));

--
-- Создать представление `v_buildings_emergency_current_max_date`
--
CREATE
VIEW v_buildings_emergency_current_max_date
AS
SELECT
  `oba`.`id_building` AS `id_building`,
  MAX(`or1`.`date`) AS `date`
FROM ((`ownership_rights` `or1`
  JOIN `ownership_buildings_assoc` `oba`
    ON ((`or1`.`id_ownership_right` = `oba`.`id_ownership_right`)))
  LEFT JOIN `v_buildings_excluded_from_emergency` `vbefe`
    ON ((`oba`.`id_building` = `vbefe`.`id_building`)))
WHERE ((`or1`.`deleted` <> 1)
AND (`oba`.`deleted` <> 1)
AND (`or1`.`id_ownership_right_type` = 2)
AND (ISNULL(`vbefe`.`or_date`)
OR (`or1`.`date` > `vbefe`.`or_date`)))
GROUP BY `oba`.`id_building`;

--
-- Создать представление `v_buildings_emergency_all_max_date`
--
CREATE
VIEW v_buildings_emergency_all_max_date
AS
SELECT
  `oba`.`id_building` AS `id_building`,
  MAX(`or1`.`date`) AS `date`
FROM ((`ownership_rights` `or1`
  JOIN `ownership_buildings_assoc` `oba`
    ON ((`or1`.`id_ownership_right` = `oba`.`id_ownership_right`)))
  LEFT JOIN `v_buildings_excluded_from_emergency` `vbefe`
    ON ((`oba`.`id_building` = `vbefe`.`id_building`)))
WHERE ((`or1`.`deleted` <> 1)
AND (`oba`.`deleted` <> 1)
AND (`or1`.`id_ownership_right_type` IN (2, 7))
AND (ISNULL(`vbefe`.`or_date`)
OR (`or1`.`date` > `vbefe`.`or_date`)))
GROUP BY `oba`.`id_building`;

--
-- Создать представление `v_buildings_demolished`
--
CREATE
VIEW v_buildings_demolished
AS
SELECT
  `b`.`id_building` AS `id_building`,
  `b`.`id_state` AS `id_state`,
  `b`.`id_structure_type` AS `id_structure_type`,
  `b`.`id_street` AS `id_street`,
  `b`.`house` AS `house`,
  `b`.`floors` AS `floors`,
  `b`.`num_premises` AS `num_premises`,
  `b`.`num_rooms` AS `num_rooms`,
  `b`.`num_apartments` AS `num_apartments`,
  `b`.`num_shared_apartments` AS `num_shared_apartments`,
  `b`.`living_area` AS `living_area`,
  `b`.`cadastral_num` AS `cadastral_num`,
  `b`.`cadastral_cost` AS `cadastral_cost`,
  `b`.`balance_cost` AS `balance_cost`,
  `b`.`description` AS `description`,
  `b`.`startup_year` AS `startup_year`,
  `b`.`improvement` AS `improvement`,
  `b`.`elevator` AS `elevator`,
  `b`.`deleted` AS `deleted`,
  `or1`.`number` AS `or_number`,
  `or1`.`date` AS `or_date`,
  `or1`.`description` AS `or_description`
FROM ((`buildings` `b`
  JOIN `ownership_buildings_assoc` `opa`
    ON ((`b`.`id_building` = `opa`.`id_building`)))
  JOIN `ownership_rights` `or1`
    ON ((`opa`.`id_ownership_right` = `or1`.`id_ownership_right`)))
WHERE ((`or1`.`id_ownership_right_type` = 1)
AND (`opa`.`deleted` <> 1)
AND (`or1`.`deleted` <> 1)
AND (`b`.`deleted` <> 1));

--
-- Создать представление `v_sub_premises_non_municipal`
--
CREATE
VIEW v_sub_premises_non_municipal
AS
SELECT
  `sp`.`id_sub_premises` AS `id_sub_premises`,
  `sp`.`id_premises` AS `id_premises`,
  `sp`.`id_state` AS `id_state`,
  `sp`.`sub_premises_num` AS `sub_premises_num`,
  `sp`.`total_area` AS `total_area`,
  `sp`.`living_area` AS `living_area`,
  `sp`.`description` AS `description`,
  `sp`.`state_date` AS `state_date`,
  `sp`.`cadastral_num` AS `cadastral_num`,
  `sp`.`cadastral_cost` AS `cadastral_cost`,
  `sp`.`balance_cost` AS `balance_cost`,
  `sp`.`account` AS `account`
FROM (`sub_premises` `sp`
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
WHERE ((`sp`.`deleted` <> 1)
AND (`sp`.`id_state` NOT IN (4, 5, 9, 11, 12, 14))
AND (NOT (`p`.`id_premises` IN (SELECT
    `vpd`.`id_premises`
  FROM `v_premises_demolished` `vpd`)))
AND (NOT (`p`.`id_building` IN (SELECT
    `vbd`.`id_building`
  FROM `v_buildings_demolished` `vbd`))));

--
-- Создать представление `v_sub_premises_municipal`
--
CREATE
VIEW v_sub_premises_municipal
AS
SELECT
  `sp`.`id_sub_premises` AS `id_sub_premises`,
  `sp`.`id_premises` AS `id_premises`,
  `sp`.`id_state` AS `id_state`,
  `sp`.`sub_premises_num` AS `sub_premises_num`,
  `sp`.`total_area` AS `total_area`,
  `sp`.`living_area` AS `living_area`,
  `sp`.`description` AS `description`,
  `sp`.`state_date` AS `state_date`,
  `sp`.`cadastral_num` AS `cadastral_num`,
  `sp`.`cadastral_cost` AS `cadastral_cost`,
  `sp`.`balance_cost` AS `balance_cost`,
  `sp`.`account` AS `account`
FROM (`sub_premises` `sp`
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
WHERE ((`sp`.`deleted` <> 1)
AND (`sp`.`id_state` IN (4, 5, 9, 11, 12, 14))
AND (NOT (`p`.`id_premises` IN (SELECT
    `vpd`.`id_premises`
  FROM `v_premises_demolished` `vpd`)))
AND (NOT (`p`.`id_building` IN (SELECT
    `vbd`.`id_building`
  FROM `v_buildings_demolished` `vbd`))));

--
-- Создать представление `v_premises_non_municipal`
--
CREATE
VIEW v_premises_non_municipal
AS
SELECT
  `premises`.`id_premises` AS `id_premises`,
  `premises`.`id_building` AS `id_building`,
  `premises`.`id_state` AS `id_state`,
  `premises`.`premises_num` AS `premises_num`,
  `premises`.`total_area` AS `total_area`,
  `premises`.`living_area` AS `living_area`,
  `premises`.`num_beds` AS `num_beds`,
  `premises`.`id_premises_type` AS `id_premises_type`,
  `premises`.`id_premises_kind` AS `id_premises_kind`,
  `premises`.`floor` AS `floor`,
  `premises`.`cadastral_num` AS `cadastral_num`,
  `premises`.`cadastral_cost` AS `cadastral_cost`,
  `premises`.`balance_cost` AS `balance_cost`,
  `premises`.`description` AS `description`,
  `premises`.`account` AS `account`,
  `premises`.`deleted` AS `deleted`
FROM `premises`
WHERE ((`premises`.`id_state` NOT IN (4, 5, 9, 11, 12, 14))
AND (`premises`.`deleted` <> 1)
AND (NOT (`premises`.`id_premises` IN (SELECT
    `vpd`.`id_premises`
  FROM `v_premises_demolished` `vpd`)))
AND (NOT (`premises`.`id_building` IN (SELECT
    `vbd`.`id_building`
  FROM `v_buildings_demolished` `vbd`))));

--
-- Создать представление `v_premises_municipal`
--
CREATE
VIEW v_premises_municipal
AS
SELECT
  `premises`.`id_premises` AS `id_premises`,
  `premises`.`id_building` AS `id_building`,
  `premises`.`id_state` AS `id_state`,
  `premises`.`premises_num` AS `premises_num`,
  `premises`.`total_area` AS `total_area`,
  `premises`.`living_area` AS `living_area`,
  `premises`.`num_beds` AS `num_beds`,
  `premises`.`id_premises_type` AS `id_premises_type`,
  `premises`.`id_premises_kind` AS `id_premises_kind`,
  `premises`.`floor` AS `floor`,
  `premises`.`cadastral_num` AS `cadastral_num`,
  `premises`.`cadastral_cost` AS `cadastral_cost`,
  `premises`.`balance_cost` AS `balance_cost`,
  `premises`.`description` AS `description`,
  `premises`.`account` AS `account`,
  `premises`.`deleted` AS `deleted`
FROM `premises`
WHERE ((`premises`.`id_state` IN (4, 5, 9, 11, 12, 14))
AND (`premises`.`deleted` <> 1)
AND (NOT (`premises`.`id_premises` IN (SELECT
    `vpd`.`id_premises`
  FROM `v_premises_demolished` `vpd`)))
AND (NOT (`premises`.`id_building` IN (SELECT
    `vbd`.`id_building`
  FROM `v_buildings_demolished` `vbd`))));

--
-- Создать представление `v_premises_emergency`
--
CREATE
VIEW v_premises_emergency
AS
SELECT
  `p`.`id_premises` AS `id_premises`,
  `p`.`id_building` AS `id_building`,
  `p`.`id_state` AS `id_state`,
  `p`.`premises_num` AS `premises_num`,
  `p`.`total_area` AS `total_area`,
  `p`.`living_area` AS `living_area`,
  `p`.`num_beds` AS `num_beds`,
  `p`.`id_premises_type` AS `id_premises_type`,
  `p`.`id_premises_kind` AS `id_premises_kind`,
  `p`.`floor` AS `floor`,
  `p`.`cadastral_num` AS `cadastral_num`,
  `p`.`cadastral_cost` AS `cadastral_cost`,
  `p`.`balance_cost` AS `balance_cost`,
  `p`.`description` AS `description`,
  `p`.`deleted` AS `deleted`,
  `or1`.`number` AS `or_number`,
  `or1`.`date` AS `or_date`,
  `or1`.`description` AS `or_description`
FROM ((`premises` `p`
  JOIN `ownership_premises_assoc` `opa`
    ON ((`p`.`id_premises` = `opa`.`id_premises`)))
  JOIN `ownership_rights` `or1`
    ON ((`opa`.`id_ownership_right` = `or1`.`id_ownership_right`)))
WHERE ((`or1`.`id_ownership_right_type` IN (2, 7))
AND (`opa`.`deleted` <> 1)
AND (`or1`.`deleted` <> 1)
AND (`p`.`deleted` <> 1)
AND (NOT (`p`.`id_premises` IN (SELECT
    `v`.`id_premises`
  FROM `v_premises_demolished` `v`)))
AND (NOT (`p`.`id_building` IN (SELECT
    `v`.`id_building`
  FROM `v_buildings_demolished` `v`)))
AND (NOT (`p`.`id_premises` IN (SELECT
    `v`.`id_premises`
  FROM `v_premises_excluded_from_emergency` `v`)))
AND (NOT (`p`.`id_building` IN (SELECT
    `v`.`id_building`
  FROM `v_buildings_excluded_from_emergency` `v`))));

--
-- Создать представление `v_buildings_emergency_current`
--
CREATE
VIEW v_buildings_emergency_current
AS
SELECT
  `v`.`id_building` AS `id_building`,
  `or1`.`number` AS `number`,
  `or1`.`date` AS `date`,
  `or1`.`description` AS `description`
FROM ((`ownership_rights` `or1`
  JOIN `ownership_buildings_assoc` `oba`
    ON ((`or1`.`id_ownership_right` = `oba`.`id_ownership_right`)))
  JOIN `v_buildings_emergency_current_max_date` `v`
    ON (((`oba`.`id_building` = `v`.`id_building`)
    AND (`or1`.`date` = `v`.`date`))))
WHERE ((`or1`.`deleted` <> 1)
AND (`oba`.`deleted` <> 1)
AND (`or1`.`id_ownership_right_type` = 2)
AND (NOT (`oba`.`id_building` IN (SELECT
    `vbd`.`id_building`
  FROM `v_buildings_demolished` `vbd`))))
GROUP BY `oba`.`id_building`;

--
-- Создать представление `v_buildings_emergency_all`
--
CREATE
VIEW v_buildings_emergency_all
AS
SELECT
  `v`.`id_building` AS `id_building`,
  `or1`.`number` AS `number`,
  `or1`.`date` AS `date`,
  `or1`.`description` AS `description`,
  `or1`.`id_ownership_right_type` AS `id_ownership_right_type`
FROM ((`ownership_rights` `or1`
  JOIN `ownership_buildings_assoc` `oba`
    ON ((`or1`.`id_ownership_right` = `oba`.`id_ownership_right`)))
  JOIN `v_buildings_emergency_all_max_date` `v`
    ON (((`oba`.`id_building` = `v`.`id_building`)
    AND (`or1`.`date` = `v`.`date`))))
WHERE ((`or1`.`deleted` <> 1)
AND (`oba`.`deleted` <> 1)
AND (`or1`.`id_ownership_right_type` IN (2, 7))
AND (NOT (`oba`.`id_building` IN (SELECT
    `vbd`.`id_building`
  FROM `v_buildings_demolished` `vbd`))))
GROUP BY `oba`.`id_building`;

--
-- Создать представление `v_buildings_emergency`
--
CREATE
VIEW v_buildings_emergency
AS
SELECT
  `b`.`id_building` AS `id_building`,
  `b`.`id_state` AS `id_state`,
  `b`.`id_structure_type` AS `id_structure_type`,
  `b`.`id_street` AS `id_street`,
  `b`.`house` AS `house`,
  `b`.`floors` AS `floors`,
  `b`.`num_premises` AS `num_premises`,
  `b`.`num_rooms` AS `num_rooms`,
  `b`.`num_apartments` AS `num_apartments`,
  `b`.`num_shared_apartments` AS `num_shared_apartments`,
  `b`.`living_area` AS `living_area`,
  `b`.`cadastral_num` AS `cadastral_num`,
  `b`.`cadastral_cost` AS `cadastral_cost`,
  `b`.`balance_cost` AS `balance_cost`,
  `b`.`description` AS `description`,
  `b`.`startup_year` AS `startup_year`,
  `b`.`improvement` AS `improvement`,
  `b`.`elevator` AS `elevator`,
  `b`.`deleted` AS `deleted`,
  `or1`.`number` AS `or_number`,
  `or1`.`date` AS `or_date`,
  `or1`.`description` AS `or_description`
FROM ((`buildings` `b`
  JOIN `ownership_buildings_assoc` `oba`
    ON ((`b`.`id_building` = `oba`.`id_building`)))
  JOIN `ownership_rights` `or1`
    ON ((`oba`.`id_ownership_right` = `or1`.`id_ownership_right`)))
WHERE ((`or1`.`id_ownership_right_type` IN (2, 7))
AND (`oba`.`deleted` <> 1)
AND (`or1`.`deleted` <> 1)
AND (`b`.`deleted` <> 1)
AND (NOT (`b`.`id_building` IN (SELECT
    `v`.`id_building`
  FROM `v_buildings_demolished` `v`)))
AND (NOT (`b`.`id_building` IN (SELECT
    `v`.`id_building`
  FROM `v_buildings_excluded_from_emergency` `v`))));

--
-- Создать таблицу `structure_types`
--
CREATE TABLE IF NOT EXISTS structure_types (
  id_structure_type int(11) NOT NULL AUTO_INCREMENT,
  structure_type varchar(255) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_structure_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 10,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `structure_types_after_insert`
--
CREATE TRIGGER structure_types_after_insert
AFTER INSERT
ON structure_types
FOR EACH ROW
BEGIN
  IF (NEW.structure_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'structure_types', NEW.id_structure_type, 'structure_type', NULL, NEW.structure_type, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `structure_types_after_update`
--
CREATE TRIGGER structure_types_after_update
AFTER UPDATE
ON structure_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'structure_types', NEW.id_structure_type, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.structure_type <> OLD.structure_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'structure_types', NEW.id_structure_type, 'structure_type', OLD.structure_type, NEW.structure_type, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `structure_types_before_update`
--
CREATE TRIGGER structure_types_before_update
BEFORE UPDATE
ON structure_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM buildings
        WHERE deleted <> 1
        AND id_structure_type = NEW.id_structure_type) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить вид материала здания, т.к. существуют здания из данного материала';
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE buildings
ADD CONSTRAINT FK_buildings_types_of_structure_id_type_of_structure FOREIGN KEY (id_structure_type)
REFERENCES structure_types (id_structure_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `personal_settings`
--
CREATE TABLE IF NOT EXISTS personal_settings (
  id_user int(11) NOT NULL AUTO_INCREMENT,
  sql_driver varchar(255) DEFAULT NULL,
  payment_accaunt_table_json text DEFAULT NULL,
  PRIMARY KEY (id_user)
)
ENGINE = INNODB,
AUTO_INCREMENT = 115,
AVG_ROW_LENGTH = 1412,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `acl_users`
--
CREATE TABLE IF NOT EXISTS acl_users (
  id_user int(11) NOT NULL AUTO_INCREMENT,
  user_name varchar(255) NOT NULL,
  user_description varchar(255) DEFAULT NULL,
  password varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_user)
)
ENGINE = INNODB,
AUTO_INCREMENT = 115,
AVG_ROW_LENGTH = 16384,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `acl_users_after_insert`
--
CREATE TRIGGER acl_users_after_insert
AFTER INSERT
ON acl_users
FOR EACH ROW
BEGIN
  IF (NEW.id_user IS NOT NULL) THEN
    INSERT INTO personal_settings
      VALUES (id_user, NULL, '{"HasTenant":true,"HasTotalArea":false,"HasLivingArea":false,"HasPrescribed":false,"HasBalanceInput":true,"HasBalanceTenancy":false,"HasBalanceInputPenalties":false,"HasBalanceDgi":false,"HasBalancePadun":false,"HasBalancePkk":false,"HasChargingTotal":true,"HasChargingTenancy":false,"HasChargingPenalties":false,"HasChargingDgi":false,"HasChargingPadun":false,"HasChargingPkk":false,"HasTransferBalance":false,"HasRecalcTenancy":false,"HasRecalcPenalties":false,"HasRecalcDgi":false,"HasRecalcPadun":false,"HasRecalcPkk":false,"HasPaymentTenancy":true,"HasPaymentPenalties":false,"HasPaymentDgi":false,"HasPaymentPadun":false,"HasPaymentPkk":false,"HasBalanceOutputTotal":true,"HasBalanceOutputTenancy":false,"HasBalanceOutputPenalties":false,"HasBalanceOutputDgi":false,"HasBalanceOutputPadun":false,"HasBalanceOutputPkk":false}');
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE personal_settings
ADD CONSTRAINT FK_personal_settings_id_user FOREIGN KEY (id_user)
REFERENCES acl_users (id_user) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `priv_types_of_property`
--
CREATE TABLE IF NOT EXISTS priv_types_of_property (
  id_type_of_property int(11) NOT NULL AUTO_INCREMENT,
  name varchar(50) NOT NULL,
  PRIMARY KEY (id_type_of_property)
)
ENGINE = INNODB,
AUTO_INCREMENT = 6,
AVG_ROW_LENGTH = 3276,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `priv_contracts`
--
CREATE TABLE IF NOT EXISTS priv_contracts (
  id_contract int(11) NOT NULL COMMENT 'Ключ',
  reg_number varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'Регистрационный номер договора',
  priv_address varchar(255) DEFAULT NULL,
  priv_floor varchar(255) DEFAULT NULL COMMENT 'Этаж',
  priv_rooms int(11) DEFAULT NULL COMMENT 'Количество комнат',
  priv_total_space decimal(10, 2) DEFAULT NULL COMMENT 'Общая площадь',
  priv_living_space decimal(10, 2) DEFAULT NULL COMMENT 'Жилая площадь',
  priv_apartment_space decimal(10, 2) DEFAULT NULL COMMENT 'Площадь квартиры (жилая + подсобная)',
  priv_loggia_space decimal(10, 2) DEFAULT NULL COMMENT 'Площадь лоджий и балконов',
  priv_ancillary_space decimal(10, 2) DEFAULT NULL COMMENT 'Подсобная площадь',
  priv_ceiling_height decimal(10, 2) DEFAULT NULL COMMENT 'Высота помещения',
  priv_cadastre_number varchar(100) DEFAULT NULL COMMENT 'Кадастровый номер',
  id_street varchar(17) DEFAULT NULL,
  id_building int(11) DEFAULT NULL,
  id_premise int(11) DEFAULT NULL,
  id_sub_premise int(11) DEFAULT NULL,
  id_executor int(11) NOT NULL DEFAULT 65536,
  application_date datetime DEFAULT NULL COMMENT 'Дата подачи заявления',
  date_issue date DEFAULT NULL COMMENT 'Дата выдачи',
  registration_date datetime DEFAULT NULL COMMENT 'Дата регистрации',
  date_issue_civil date DEFAULT NULL COMMENT 'Дата выдачи договора гражданам',
  socrent_reg_number varchar(50) DEFAULT NULL,
  socrent_date datetime DEFAULT NULL,
  id_type_property int(11) DEFAULT NULL COMMENT 'Тип собственности',
  is_refusenik tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Отказник',
  is_rasprivatization tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Расприватизация',
  is_relocation tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Переселение',
  is_refuse tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Отказ со стороны муниципалитета',
  additional_info text DEFAULT NULL,
  description varchar(767) DEFAULT NULL COMMENT 'Основание расприватизации или отказа',
  deleted tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Удален',
  insert_date datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата ввода данных о договоре',
  _id_street int(11) DEFAULT NULL COMMENT 'Улица',
  _house varchar(10) DEFAULT NULL COMMENT 'Номер дома',
  _apartment varchar(10) DEFAULT NULL COMMENT 'Номер квартиры',
  _user varchar(255) DEFAULT NULL,
  _id_specialist int(11) DEFAULT NULL COMMENT 'Специалист, подготовивший договор',
  _id_road_type int(11) DEFAULT NULL COMMENT 'Тип дороги',
  _id_type int(11) DEFAULT NULL COMMENT 'Тип жилого помещения',
  _register_mfc_number varchar(255) DEFAULT NULL COMMENT 'Регистрационный МФЦ №',
  _is_shares tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Подселение',
  _is_hostel tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Общежитие',
  PRIMARY KEY (id_contract)
)
ENGINE = INNODB,
AUTO_INCREMENT = 136000,
AVG_ROW_LENGTH = 140,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_general_ci;

--
-- Создать индекс `FK_priv_contracts_id_street` для объекта типа таблица `priv_contracts`
--
ALTER TABLE priv_contracts
ADD INDEX FK_priv_contracts_id_street (id_street);

--
-- Создать индекс `IDX_contracts` для объекта типа таблица `priv_contracts`
--
ALTER TABLE priv_contracts
ADD INDEX IDX_contracts (_house, _apartment, application_date);

--
-- Создать индекс `IDX_contracts_InsertDate` для объекта типа таблица `priv_contracts`
--
ALTER TABLE priv_contracts
ADD INDEX IDX_contracts_InsertDate (id_contract, insert_date);

--
-- Создать индекс `IDX_priv_contracts` для объекта типа таблица `priv_contracts`
--
ALTER TABLE priv_contracts
ADD INDEX IDX_priv_contracts (id_contract, deleted);

--
-- Создать индекс `IDX_priv_contracts_date_issue` для объекта типа таблица `priv_contracts`
--
ALTER TABLE priv_contracts
ADD INDEX IDX_priv_contracts_date_issue (date_issue);

--
-- Создать индекс `IDX_priv_contracts_deleted` для объекта типа таблица `priv_contracts`
--
ALTER TABLE priv_contracts
ADD INDEX IDX_priv_contracts_deleted (deleted);

--
-- Создать индекс `IDX_priv_contracts2` для объекта типа таблица `priv_contracts`
--
ALTER TABLE priv_contracts
ADD INDEX IDX_priv_contracts2 (id_contract, date_issue);

DELIMITER $$

--
-- Создать триггер `priv_contracts_after_insert`
--
CREATE TRIGGER priv_contracts_after_insert
AFTER INSERT
ON priv_contracts
FOR EACH ROW
BEGIN
  INSERT INTO `log`
    VALUES (NULL, 'priv_contracts', NEW.id_contract, 'reg_number', NULL, NEW.reg_number, 'INSERT', NOW(), USER());
  IF (NEW.id_street IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'id_street', NULL, NEW.id_street, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_building IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'id_building', NULL, NEW.id_building, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_premise IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'id_premise', NULL, NEW.id_premise, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_sub_premise IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'id_sub_premise', NULL, NEW.id_sub_premise, 'INSERT', NOW(), USER());
  END IF;
  INSERT INTO `log`
    VALUES (NULL, 'priv_contracts', NEW.id_contract, 'id_executor', NULL, NEW.id_executor, 'INSERT', NOW(), USER());
  IF (NEW.application_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'application_date', NULL, NEW.application_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_issue IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'date_issue', NULL, NEW.date_issue, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.registration_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'registration_date', NULL, NEW.registration_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_issue_civil IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'date_issue_civil', NULL, NEW.date_issue_civil, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.socrent_reg_number IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'socrent_reg_number', NULL, NEW.socrent_reg_number, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.socrent_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'socrent_date', NULL, NEW.socrent_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_type_property IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'id_type_property', NULL, NEW.id_type_property, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_refusenik IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'is_refusenik', NULL, NEW.is_refusenik, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_rasprivatization IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'is_rasprivatization', NULL, NEW.is_rasprivatization, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_relocation IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'is_relocation', NULL, NEW.is_relocation, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_refuse IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'is_refuse', NULL, NEW.is_refuse, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.additional_info IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'additional_info', NULL, NEW.additional_info, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `priv_contracts_after_update`
--
CREATE TRIGGER priv_contracts_after_update
AFTER UPDATE
ON priv_contracts
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contracts', NEW.id_contract, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.reg_number <> OLD.reg_number) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'reg_number', OLD.reg_number, NEW.reg_number, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_street IS NULL
      AND OLD.id_street IS NULL)
      AND ((NEW.id_street IS NULL
      AND OLD.id_street IS NOT NULL)
      OR (NEW.id_street IS NOT NULL
      AND OLD.id_street IS NULL)
      OR (NEW.id_street <> OLD.id_street))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'id_street', OLD.id_street, NEW.id_street, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_building IS NULL
      AND OLD.id_building IS NULL)
      AND ((NEW.id_building IS NULL
      AND OLD.id_building IS NOT NULL)
      OR (NEW.id_building IS NOT NULL
      AND OLD.id_building IS NULL)
      OR (NEW.id_building <> OLD.id_building))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'id_building', OLD.id_building, NEW.id_building, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_premise IS NULL
      AND OLD.id_premise IS NULL)
      AND ((NEW.id_premise IS NULL
      AND OLD.id_premise IS NOT NULL)
      OR (NEW.id_premise IS NOT NULL
      AND OLD.id_premise IS NULL)
      OR (NEW.id_premise <> OLD.id_premise))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'id_premise', OLD.id_premise, NEW.id_premise, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_sub_premise IS NULL
      AND OLD.id_sub_premise IS NULL)
      AND ((NEW.id_sub_premise IS NULL
      AND OLD.id_sub_premise IS NOT NULL)
      OR (NEW.id_sub_premise IS NOT NULL
      AND OLD.id_sub_premise IS NULL)
      OR (NEW.id_sub_premise <> OLD.id_sub_premise))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'id_sub_premise', OLD.id_sub_premise, NEW.id_sub_premise, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_executor <> OLD.id_executor) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'id_executor', OLD.id_executor, NEW.id_executor, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.application_date IS NULL
      AND OLD.application_date IS NULL)
      AND ((NEW.application_date IS NULL
      AND OLD.application_date IS NOT NULL)
      OR (NEW.application_date IS NOT NULL
      AND OLD.application_date IS NULL)
      OR (NEW.application_date <> OLD.application_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'application_date', OLD.application_date, NEW.application_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_issue IS NULL
      AND OLD.date_issue IS NULL)
      AND ((NEW.date_issue IS NULL
      AND OLD.date_issue IS NOT NULL)
      OR (NEW.date_issue IS NOT NULL
      AND OLD.date_issue IS NULL)
      OR (NEW.date_issue <> OLD.date_issue))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'date_issue', OLD.date_issue, NEW.date_issue, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.registration_date IS NULL
      AND OLD.registration_date IS NULL)
      AND ((NEW.registration_date IS NULL
      AND OLD.registration_date IS NOT NULL)
      OR (NEW.registration_date IS NOT NULL
      AND OLD.registration_date IS NULL)
      OR (NEW.registration_date <> OLD.registration_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'registration_date', OLD.registration_date, NEW.registration_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_issue_civil IS NULL
      AND OLD.date_issue_civil IS NULL)
      AND ((NEW.date_issue_civil IS NULL
      AND OLD.date_issue_civil IS NOT NULL)
      OR (NEW.date_issue_civil IS NOT NULL
      AND OLD.date_issue_civil IS NULL)
      OR (NEW.date_issue_civil <> OLD.date_issue_civil))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'date_issue_civil', OLD.date_issue_civil, NEW.date_issue_civil, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.socrent_reg_number IS NULL
      AND OLD.socrent_reg_number IS NULL)
      AND ((NEW.socrent_reg_number IS NULL
      AND OLD.socrent_reg_number IS NOT NULL)
      OR (NEW.socrent_reg_number IS NOT NULL
      AND OLD.socrent_reg_number IS NULL)
      OR (NEW.socrent_reg_number <> OLD.socrent_reg_number))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'socrent_reg_number', OLD.socrent_reg_number, NEW.socrent_reg_number, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.socrent_date IS NULL
      AND OLD.socrent_date IS NULL)
      AND ((NEW.socrent_date IS NULL
      AND OLD.socrent_date IS NOT NULL)
      OR (NEW.socrent_date IS NOT NULL
      AND OLD.socrent_date IS NULL)
      OR (NEW.socrent_date <> OLD.socrent_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'socrent_date', OLD.socrent_date, NEW.socrent_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_type_property IS NULL
      AND OLD.id_type_property IS NULL)
      AND ((NEW.id_type_property IS NULL
      AND OLD.id_type_property IS NOT NULL)
      OR (NEW.id_type_property IS NOT NULL
      AND OLD.id_type_property IS NULL)
      OR (NEW.id_type_property <> OLD.id_type_property))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'id_type_property', OLD.id_type_property, NEW.id_type_property, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.is_refusenik <> OLD.is_refusenik) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'is_refusenik', OLD.is_refusenik, NEW.is_refusenik, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.is_rasprivatization <> OLD.is_rasprivatization) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'is_rasprivatization', OLD.is_rasprivatization, NEW.is_rasprivatization, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.is_relocation <> OLD.is_relocation) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'is_relocation', OLD.is_relocation, NEW.is_relocation, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.is_refuse <> OLD.is_refuse) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'is_refuse', OLD.is_refuse, NEW.is_refuse, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.additional_info IS NULL
      AND OLD.additional_info IS NULL)
      AND ((NEW.additional_info IS NULL
      AND OLD.additional_info IS NOT NULL)
      OR (NEW.additional_info IS NOT NULL
      AND OLD.additional_info IS NULL)
      OR (NEW.additional_info <> OLD.additional_info))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'additional_info', OLD.additional_info, NEW.additional_info, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contracts', NEW.id_contract, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE priv_contracts
ADD CONSTRAINT FK_priv_contracts_id_building FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Создать внешний ключ
--
ALTER TABLE priv_contracts
ADD CONSTRAINT FK_priv_contracts_id_executor FOREIGN KEY (id_executor)
REFERENCES executors (id_executor) ON DELETE NO ACTION;

--
-- Создать внешний ключ
--
ALTER TABLE priv_contracts
ADD CONSTRAINT FK_priv_contracts_id_premise FOREIGN KEY (id_premise)
REFERENCES premises (id_premises) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Создать внешний ключ
--
ALTER TABLE priv_contracts
ADD CONSTRAINT FK_priv_contracts_id_sub_premise FOREIGN KEY (id_sub_premise)
REFERENCES sub_premises (id_sub_premises) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Создать внешний ключ
--
ALTER TABLE priv_contracts
ADD CONSTRAINT FK_priv_contracts_id_type_property FOREIGN KEY (id_type_property)
REFERENCES priv_types_of_property (id_type_of_property) ON DELETE NO ACTION;

--
-- Создать таблицу `priv_contractors`
--
CREATE TABLE IF NOT EXISTS priv_contractors (
  id_contractor int(11) NOT NULL AUTO_INCREMENT,
  is_noncontractor tinyint(4) NOT NULL DEFAULT 0,
  id_contract int(11) NOT NULL,
  surname varchar(255) DEFAULT NULL,
  name varchar(50) DEFAULT NULL,
  patronymic varchar(255) DEFAULT NULL,
  id_kinship int(11) DEFAULT NULL,
  date_birth date DEFAULT NULL,
  description varchar(2000) DEFAULT NULL,
  passport varchar(2000) DEFAULT NULL,
  part varchar(50) DEFAULT NULL,
  has_dover tinyint(1) DEFAULT 0,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  _insert_date datetime DEFAULT NULL,
  _user varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_contractor)
)
ENGINE = INNODB,
AUTO_INCREMENT = 810985,
AVG_ROW_LENGTH = 254,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `priv_contractors_after_insert`
--
CREATE TRIGGER priv_contractors_after_insert
AFTER INSERT
ON priv_contractors
FOR EACH ROW
BEGIN
  INSERT INTO `log`
    VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'is_noncontractor', NULL, NEW.is_noncontractor, 'INSERT', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'id_contract', NULL, NEW.id_contract, 'INSERT', NOW(), USER());
  IF (NEW.surname IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'surname', NULL, NEW.surname, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'name', NULL, NEW.name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.patronymic IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'patronymic', NULL, NEW.patronymic, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_kinship IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'id_kinship', NULL, NEW.id_kinship, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_birth IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'date_birth', NULL, NEW.date_birth, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.passport IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'passport', NULL, NEW.passport, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.part IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'part', NULL, NEW.part, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.has_dover IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'has_dover', NULL, NEW.has_dover, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `priv_contractors_after_update`
--
CREATE TRIGGER priv_contractors_after_update
AFTER UPDATE
ON priv_contractors
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.is_noncontractor <> OLD.is_noncontractor) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'is_noncontractor', OLD.is_noncontractor, NEW.is_noncontractor, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_contract <> OLD.id_contract) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'id_contract', OLD.id_contract, NEW.id_contract, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.surname IS NULL
      AND OLD.surname IS NULL)
      AND ((NEW.surname IS NULL
      AND OLD.surname IS NOT NULL)
      OR (NEW.surname IS NOT NULL
      AND OLD.surname IS NULL)
      OR (NEW.surname <> OLD.surname))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'surname', OLD.surname, NEW.surname, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.name IS NULL
      AND OLD.name IS NULL)
      AND ((NEW.name IS NULL
      AND OLD.name IS NOT NULL)
      OR (NEW.name IS NOT NULL
      AND OLD.name IS NULL)
      OR (NEW.name <> OLD.name))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'name', OLD.name, NEW.name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.patronymic IS NULL
      AND OLD.patronymic IS NULL)
      AND ((NEW.patronymic IS NULL
      AND OLD.patronymic IS NOT NULL)
      OR (NEW.patronymic IS NOT NULL
      AND OLD.patronymic IS NULL)
      OR (NEW.patronymic <> OLD.patronymic))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'patronymic', OLD.patronymic, NEW.patronymic, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_kinship IS NULL
      AND OLD.id_kinship IS NULL)
      AND ((NEW.id_kinship IS NULL
      AND OLD.id_kinship IS NOT NULL)
      OR (NEW.id_kinship IS NOT NULL
      AND OLD.id_kinship IS NULL)
      OR (NEW.id_kinship <> OLD.id_kinship))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'id_kinship', OLD.id_kinship, NEW.id_kinship, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_birth IS NULL
      AND OLD.date_birth IS NULL)
      AND ((NEW.date_birth IS NULL
      AND OLD.date_birth IS NOT NULL)
      OR (NEW.date_birth IS NOT NULL
      AND OLD.date_birth IS NULL)
      OR (NEW.date_birth <> OLD.date_birth))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'date_birth', OLD.date_birth, NEW.date_birth, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.passport IS NULL
      AND OLD.passport IS NULL)
      AND ((NEW.passport IS NULL
      AND OLD.passport IS NOT NULL)
      OR (NEW.passport IS NOT NULL
      AND OLD.passport IS NULL)
      OR (NEW.passport <> OLD.passport))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'passport', OLD.passport, NEW.passport, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.part IS NULL
      AND OLD.part IS NULL)
      AND ((NEW.part IS NULL
      AND OLD.part IS NOT NULL)
      OR (NEW.part IS NOT NULL
      AND OLD.part IS NULL)
      OR (NEW.part <> OLD.part))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'part', OLD.part, NEW.part, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.has_dover IS NULL
      AND OLD.has_dover IS NULL)
      AND ((NEW.has_dover IS NULL
      AND OLD.has_dover IS NOT NULL)
      OR (NEW.has_dover IS NOT NULL
      AND OLD.has_dover IS NULL)
      OR (NEW.has_dover <> OLD.has_dover))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_contractors', NEW.id_contractor, 'has_dover', OLD.has_dover, NEW.has_dover, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE priv_contractors
ADD CONSTRAINT FK_priv_contractors_id_contract FOREIGN KEY (id_contract)
REFERENCES priv_contracts (id_contract) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `priv_agreements`
--
CREATE TABLE IF NOT EXISTS priv_agreements (
  id_agreement int(11) NOT NULL AUTO_INCREMENT,
  id_contract int(11) NOT NULL,
  agreement_date date DEFAULT NULL,
  agreement_content text DEFAULT NULL,
  user varchar(255) DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_agreement)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 1820,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `priv_agreements_after_insert`
--
CREATE TRIGGER priv_agreements_after_insert
AFTER INSERT
ON priv_agreements
FOR EACH ROW
BEGIN
  INSERT INTO `log`
    VALUES (NULL, 'priv_agreements', NEW.id_agreement, 'id_contract', NULL, NEW.id_contract, 'INSERT', NOW(), USER());
  IF (NEW.agreement_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_agreements', NEW.id_agreement, 'agreement_date', NULL, NEW.agreement_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.agreement_content IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_agreements', NEW.id_agreement, 'agreement_content', NULL, NEW.agreement_content, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.user IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_agreements', NEW.id_agreement, 'user', NULL, NEW.user, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `priv_agreements_after_update`
--
CREATE TRIGGER priv_agreements_after_update
AFTER UPDATE
ON priv_agreements
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_agreements', NEW.id_agreement, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_contract <> OLD.id_contract) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_agreements', NEW.id_agreement, 'id_contract', OLD.id_contract, NEW.id_contract, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.agreement_date IS NULL
      AND OLD.agreement_date IS NULL)
      AND ((NEW.agreement_date IS NULL
      AND OLD.agreement_date IS NOT NULL)
      OR (NEW.agreement_date IS NOT NULL
      AND OLD.agreement_date IS NULL)
      OR (NEW.agreement_date <> OLD.agreement_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_agreements', NEW.id_agreement, 'agreement_date', OLD.agreement_date, NEW.agreement_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.agreement_content IS NULL
      AND OLD.agreement_content IS NULL)
      AND ((NEW.agreement_content IS NULL
      AND OLD.agreement_content IS NOT NULL)
      OR (NEW.agreement_content IS NOT NULL
      AND OLD.agreement_content IS NULL)
      OR (NEW.agreement_content <> OLD.agreement_content))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_agreements', NEW.id_agreement, 'agreement_content', OLD.agreement_content, NEW.agreement_content, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.user IS NULL
      AND OLD.user IS NULL)
      AND ((NEW.user IS NULL
      AND OLD.user IS NOT NULL)
      OR (NEW.user IS NOT NULL
      AND OLD.user IS NULL)
      OR (NEW.user <> OLD.user))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_agreements', NEW.id_agreement, 'user', OLD.user, NEW.user, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE priv_agreements
ADD CONSTRAINT FK_priv_agreements_id_contract FOREIGN KEY (id_contract)
REFERENCES priv_contracts (id_contract) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `priv_additional_estates`
--
CREATE TABLE IF NOT EXISTS priv_additional_estates (
  id_estate int(11) NOT NULL AUTO_INCREMENT,
  id_contract int(11) DEFAULT NULL,
  id_street varchar(17) NOT NULL,
  id_building int(11) NOT NULL,
  id_premise int(11) DEFAULT NULL,
  id_sub_premise int(11) DEFAULT NULL,
  deleted tinyint(1) DEFAULT 0,
  PRIMARY KEY (id_estate)
)
ENGINE = INNODB,
AUTO_INCREMENT = 14,
AVG_ROW_LENGTH = 1820,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `priv_additional_estates_after_insert`
--
CREATE TRIGGER priv_additional_estates_after_insert
AFTER INSERT
ON priv_additional_estates
FOR EACH ROW
BEGIN
  INSERT INTO `log`
    VALUES (NULL, 'priv_additional_estates', NEW.id_estate, 'id_contract', NULL, NEW.id_contract, 'INSERT', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'priv_additional_estates', NEW.id_estate, 'id_street', NULL, NEW.id_street, 'INSERT', NOW(), USER());
  INSERT INTO `log`
    VALUES (NULL, 'priv_additional_estates', NEW.id_estate, 'id_building', NULL, NEW.id_building, 'INSERT', NOW(), USER());
  IF (NEW.id_premise IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_additional_estates', NEW.id_estate, 'id_premise', NULL, NEW.id_premise, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_sub_premise IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_additional_estates', NEW.id_estate, 'id_sub_premise', NULL, NEW.id_sub_premise, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `priv_additional_estates_after_update`
--
CREATE TRIGGER priv_additional_estates_after_update
AFTER UPDATE
ON priv_additional_estates
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'priv_additional_estates', NEW.id_estate, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_contract <> OLD.id_contract) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_additional_estates', NEW.id_estate, 'id_contract', OLD.id_contract, NEW.id_contract, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_street <> OLD.id_street) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_additional_estates', NEW.id_estate, 'id_street', OLD.id_street, NEW.id_street, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_building <> OLD.id_building) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_additional_estates', NEW.id_estate, 'id_building', OLD.id_building, NEW.id_building, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_premise IS NULL
      AND OLD.id_premise IS NULL)
      AND ((NEW.id_premise IS NULL
      AND OLD.id_premise IS NOT NULL)
      OR (NEW.id_premise IS NOT NULL
      AND OLD.id_premise IS NULL)
      OR (NEW.id_premise <> OLD.id_premise))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_additional_estates', NEW.id_estate, 'id_premise', OLD.id_premise, NEW.id_premise, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_sub_premise IS NULL
      AND OLD.id_sub_premise IS NULL)
      AND ((NEW.id_sub_premise IS NULL
      AND OLD.id_sub_premise IS NOT NULL)
      OR (NEW.id_sub_premise IS NOT NULL
      AND OLD.id_sub_premise IS NULL)
      OR (NEW.id_sub_premise <> OLD.id_sub_premise))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'priv_additional_estates', NEW.id_estate, 'id_sub_premise', OLD.id_sub_premise, NEW.id_sub_premise, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE priv_additional_estates
ADD CONSTRAINT FK_priv_additional_estates_id_building FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE priv_additional_estates
ADD CONSTRAINT FK_priv_additional_estates_id_contract FOREIGN KEY (id_contract)
REFERENCES priv_contracts (id_contract) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE priv_additional_estates
ADD CONSTRAINT FK_priv_additional_estates_id_premise FOREIGN KEY (id_premise)
REFERENCES premises (id_premises) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE priv_additional_estates
ADD CONSTRAINT FK_priv_additional_estates_id_sub_premise FOREIGN KEY (id_sub_premise)
REFERENCES sub_premises (id_sub_premises) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать представление `v_priv_estate_ids`
--
CREATE
VIEW v_priv_estate_ids
AS
SELECT
  `pc`.`id_contract` AS `id_contract`,
  `pc`.`id_street` AS `id_street`,
  `pc`.`id_building` AS `id_building`,
  `pc`.`id_premise` AS `id_premise`,
  `pc`.`id_sub_premise` AS `id_sub_premise`,
  `pc`.`is_refusenik` AS `is_refusenik`,
  `pc`.`is_rasprivatization` AS `is_rasprivatization`,
  `pc`.`is_refuse` AS `is_refuse`
FROM `priv_contracts` `pc`
WHERE (`pc`.`deleted` = 0)
UNION ALL
SELECT
  `pae`.`id_contract` AS `id_contract`,
  `pae`.`id_street` AS `id_street`,
  `pae`.`id_building` AS `id_building`,
  `pae`.`id_premise` AS `id_premise`,
  `pae`.`id_sub_premise` AS `id_sub_premise`,
  `pc`.`is_refusenik` AS `is_refusenik`,
  `pc`.`is_rasprivatization` AS `is_rasprivatization`,
  `pc`.`is_refuse` AS `is_refuse`
FROM (`priv_additional_estates` `pae`
  JOIN `priv_contracts` `pc`
    ON ((`pae`.`id_contract` = `pc`.`id_contract`)))
WHERE ((`pc`.`deleted` = 0)
AND (`pae`.`deleted` = 0));

--
-- Создать представление `v_priv_estate_info`
--
CREATE
VIEW v_priv_estate_info
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  `c`.`id_street` AS `id_street`,
  SUBSTR(`c`.`id_street`, 1, 12) AS `id_region`,
  `c`.`id_building` AS `id_building`,
  `c`.`id_premise` AS `id_premise`,
  `c`.`id_sub_premise` AS `id_sub_premise`,
  `vks`.`street_name` AS `street_name`,
  `b`.`house` AS `house`,
  `p`.`premises_num` AS `premises_num`,
  `p`.`id_premises_type` AS `id_premises_type`,
  `sp`.`sub_premises_num` AS `sub_premises_num`,
  IF((`c`.`id_sub_premise` IS NOT NULL), `sp`.`total_area`, IF((`c`.`id_premise` IS NOT NULL), `p`.`total_area`, IF((`c`.`id_building` IS NOT NULL), `b`.`total_area`, 0))) AS `total_area`,
  IF((`c`.`id_sub_premise` IS NOT NULL), `sp`.`living_area`, IF((`c`.`id_premise` IS NOT NULL), `p`.`living_area`, IF((`c`.`id_building` IS NOT NULL), `b`.`living_area`, 0))) AS `living_area`,
  IF((`c`.`id_sub_premise` IS NOT NULL), IF((`p`.`id_premises_type` = 3), 2, 1), IF((`c`.`id_premise` IS NOT NULL), IF((`p`.`id_premises_type` = 3), 2, IF((`p`.`id_premises_type` = 2), 1, 0)), IF((`c`.`id_building` IS NOT NULL), 3, -(1)))) AS `estate_type`,
  CONCAT(`vks`.`street_name`, IF((`b`.`id_building` IS NOT NULL), CONCAT(', д. ', `b`.`house`), ''), IF((`p`.`id_premises` IS NOT NULL), CONCAT(', ', `pt`.`premises_type_short`, ' ', `p`.`premises_num`), ''), IF((`sp`.`id_sub_premises` IS NOT NULL), CONCAT(', ком. ', `sp`.`sub_premises_num`), '')) AS `full_address`,
  `c`.`is_refuse` AS `is_refuse`,
  `c`.`is_refusenik` AS `is_refusenik`,
  `c`.`is_rasprivatization` AS `is_rasprivatization`
FROM (((((`registry`.`v_priv_estate_ids` `c`
  JOIN `registry`.`v_kladr_streets` `vks`
    ON ((`c`.`id_street` = CONVERT(`vks`.`id_street` USING utf8mb4))))
  JOIN `registry`.`buildings` `b`
    ON ((`c`.`id_building` = `b`.`id_building`)))
  LEFT JOIN `registry`.`premises` `p`
    ON ((`c`.`id_premise` = `p`.`id_premises`)))
  LEFT JOIN `registry`.`sub_premises` `sp`
    ON ((`c`.`id_sub_premise` = `sp`.`id_sub_premises`)))
  LEFT JOIN `registry`.`premises_types` `pt`
    ON ((`p`.`id_premises_type` = `pt`.`id_premises_type`)));

--
-- Создать представление `v_priv_estate_gp1`
--
CREATE
VIEW v_priv_estate_gp1
AS
SELECT
  `v`.`id_contract` AS `id_contract`,
  `v`.`id_region` AS `id_region`,
  `v`.`id_street` AS `id_street`,
  `v`.`id_building` AS `id_building`,
  `v`.`id_premise` AS `id_premise`,
  `v`.`id_premises_type` AS `id_premises_type`,
  `v`.`street_name` AS `street_name`,
  `v`.`house` AS `house`,
  `v`.`premises_num` AS `premises_num`,
  GROUP_CONCAT(`v`.`sub_premises_num` ORDER BY `v`.`sub_premises_num` ASC SEPARATOR ', ') AS `sub_premises_num`,
  SUM(`v`.`total_area`) AS `total_area`,
  SUM(`v`.`living_area`) AS `living_area`,
  GROUP_CONCAT(DISTINCT `v`.`estate_type` SEPARATOR ', ') AS `estate_type`,
  COUNT(0) AS `sub_premises_count`
FROM `registry`.`v_priv_estate_info` `v`
GROUP BY `v`.`id_contract`,
         `v`.`id_street`,
         `v`.`id_building`,
         `v`.`id_premise`;

--
-- Создать представление `v_priv_estate_gp2`
--
CREATE
VIEW v_priv_estate_gp2
AS
SELECT
  `v`.`id_contract` AS `id_contract`,
  `v`.`id_region` AS `id_region`,
  `v`.`id_street` AS `id_street`,
  `v`.`id_building` AS `id_building`,
  `v`.`street_name` AS `street_name`,
  `v`.`house` AS `house`,
  GROUP_CONCAT(CONCAT(`pt`.`premises_type_short`, ' ', `v`.`premises_num`, IF(ISNULL(`v`.`sub_premises_num`), '', CONCAT(', к. ', `v`.`sub_premises_num`))) ORDER BY `v`.`premises_num` ASC SEPARATOR ', ') AS `premises_num`,
  SUM(`v`.`total_area`) AS `total_area`,
  SUM(`v`.`living_area`) AS `living_area`,
  GROUP_CONCAT(DISTINCT `v`.`estate_type` SEPARATOR ', ') AS `estate_type`,
  SUM(`v`.`sub_premises_count`) AS `priv_estates_count`
FROM (`registry`.`v_priv_estate_gp1` `v`
  LEFT JOIN `registry`.`premises_types` `pt`
    ON ((`v`.`id_premises_type` = `pt`.`id_premises_type`)))
GROUP BY `v`.`id_contract`,
         `v`.`id_street`,
         `v`.`id_building`;

--
-- Создать представление `v_priv_estate_gp3`
--
CREATE
VIEW v_priv_estate_gp3
AS
SELECT
  `v`.`id_contract` AS `id_contract`,
  `v`.`id_region` AS `id_region`,
  `v`.`id_street` AS `id_street`,
  `v`.`street_name` AS `street_name`,
  GROUP_CONCAT(CONCAT('д. ', `v`.`house`, IF(ISNULL(`v`.`premises_num`), '', CONCAT(', ', `v`.`premises_num`))) ORDER BY `v`.`house` ASC SEPARATOR ', ') AS `house`,
  SUM(`v`.`total_area`) AS `total_area`,
  SUM(`v`.`living_area`) AS `living_area`,
  GROUP_CONCAT(DISTINCT `v`.`estate_type` SEPARATOR ', ') AS `estate_type`,
  SUM(`v`.`priv_estates_count`) AS `priv_estates_count`
FROM `registry`.`v_priv_estate_gp2` `v`
GROUP BY `v`.`id_contract`,
         `v`.`id_street`;

--
-- Создать представление `v_priv_estate_grouped`
--
CREATE
VIEW v_priv_estate_grouped
AS
SELECT
  `v`.`id_contract` AS `id_contract`,
  GROUP_CONCAT(DISTINCT `v`.`id_region` SEPARATOR ', ') AS `id_region`,
  GROUP_CONCAT(DISTINCT `v`.`id_street` SEPARATOR ', ') AS `id_street`,
  GROUP_CONCAT(CONCAT(`v`.`street_name`, IF(ISNULL(`v`.`house`), '', CONCAT(', ', `v`.`house`))) ORDER BY `v`.`street_name` ASC SEPARATOR ', ') AS `street_name`,
  SUM(`v`.`total_area`) AS `total_area`,
  SUM(`v`.`living_area`) AS `living_area`,
  GROUP_CONCAT(DISTINCT `v`.`estate_type` SEPARATOR ', ') AS `estate_type`,
  SUM(`v`.`priv_estates_count`) AS `priv_estates_count`
FROM `registry`.`v_priv_estate_gp3` `v`
GROUP BY `v`.`id_contract`;

--
-- Создать таблицу `log_types`
--
CREATE TABLE IF NOT EXISTS log_types (
  id_log_type int(11) NOT NULL AUTO_INCREMENT,
  log_type varchar(255) NOT NULL,
  PRIMARY KEY (id_log_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 7,
AVG_ROW_LENGTH = 2730,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `log_objects`
--
CREATE TABLE IF NOT EXISTS log_objects (
  id_log_object int(11) NOT NULL AUTO_INCREMENT,
  log_object varchar(255) NOT NULL,
  PRIMARY KEY (id_log_object)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `log_owner_processes`
--
CREATE TABLE IF NOT EXISTS log_owner_processes (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_process int(11) NOT NULL,
  date datetime NOT NULL,
  id_user int(11) NOT NULL,
  id_log_object int(11) NOT NULL,
  id_log_type int(11) NOT NULL,
  `table` varchar(50) NOT NULL,
  id_key int(11) NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 11366,
AVG_ROW_LENGTH = 156,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE log_owner_processes
ADD CONSTRAINT FK_log_owner_processes_id_log_object FOREIGN KEY (id_log_object)
REFERENCES log_objects (id_log_object) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE log_owner_processes
ADD CONSTRAINT FK_log_owner_processes_id_log_type FOREIGN KEY (id_log_type)
REFERENCES log_types (id_log_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE log_owner_processes
ADD CONSTRAINT FK_owner_processes_log_id_user FOREIGN KEY (id_user)
REFERENCES acl_users (id_user) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `log_owner_processes_value`
--
CREATE TABLE IF NOT EXISTS log_owner_processes_value (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_log int(11) NOT NULL,
  field varchar(50) NOT NULL,
  value varchar(255) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 40693,
AVG_ROW_LENGTH = 77,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE log_owner_processes_value
ADD CONSTRAINT FK_log_owner_processes_value_id_log FOREIGN KEY (id_log)
REFERENCES log_owner_processes (id) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `owner_processes`
--
CREATE TABLE IF NOT EXISTS owner_processes (
  id_process int(11) NOT NULL AUTO_INCREMENT,
  annul_date datetime DEFAULT NULL COMMENT 'Дата аннулирования процесса',
  annul_comment varchar(255) DEFAULT NULL COMMENT 'Причина аннулирования процесса',
  comment text DEFAULT NULL COMMENT 'Комментарии',
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_process)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1198,
AVG_ROW_LENGTH = 75,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `owner_processes_after_insert`
--
CREATE TRIGGER owner_processes_after_insert
AFTER INSERT
ON owner_processes
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  DECLARE id_log int(11);
  SET id_user = (SELECT
      au.id_user
    FROM acl_users au
    WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
  INSERT INTO log_owner_processes
    VALUES (NULL, NEW.id_process, NOW(), id_user, 1, 1, 'owner_processes', NEW.id_process);
  SET id_log = (SELECT
      LAST_INSERT_ID());
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'annul_date', NEW.annul_date);
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'annul_comment', NEW.annul_comment);
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'comment', NEW.comment);
END
$$

--
-- Создать триггер `owner_processes_after_update`
--
CREATE TRIGGER owner_processes_after_update
AFTER UPDATE
ON owner_processes
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  DECLARE id_log int(11);
  SET id_user = (SELECT
      au.id_user
    FROM acl_users au
    WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO log_owner_processes
      VALUES (NULL, NEW.id_process, NOW(), id_user, 1, 6, 'owner_processes', NEW.id_process);
  ELSE
    -- аннулирование
    IF (NEW.annul_date IS NOT NULL
      AND OLD.annul_date IS NULL) THEN
      INSERT INTO log_owner_processes
        VALUES (NULL, NEW.id_process, NOW(), id_user, 1, 4, 'owner_processes', NEW.id_process);
      SET id_log = (SELECT
          LAST_INSERT_ID());
      INSERT INTO log_owner_processes_value
        VALUES (NULL, id_log, 'annul_date', NEW.annul_date);
      INSERT INTO log_owner_processes_value
        VALUES (NULL, id_log, 'annul_comment', NEW.annul_comment);
    END IF;
    -- активирование
    IF (NEW.annul_date IS NULL
      AND OLD.annul_date IS NOT NULL) THEN
      INSERT INTO log_owner_processes
        VALUES (NULL, NEW.id_process, NOW(), id_user, 1, 5, 'owner_processes', NEW.id_process);
    END IF;
    -- редактирование
    SET id_log = -1;
    IF ((OLD.annul_date IS NOT NULL)
      AND (NEW.annul_date <> OLD.annul_date)) THEN
      INSERT INTO log_owner_processes
        VALUES (NULL, NEW.id_process, NOW(), id_user, 1, 3, 'owner_processes', NEW.id_process);
      SET id_log = (SELECT
          LAST_INSERT_ID());
      INSERT INTO log_owner_processes_value
        VALUES (NULL, id_log, 'annul_date', NEW.annul_date);
    END IF;
    IF ((OLD.annul_comment IS NOT NULL)
      AND (NEW.annul_comment <> OLD.annul_comment)) THEN
      IF (id_log = -1) THEN
        INSERT INTO log_owner_processes
          VALUES (NULL, NEW.id_process, NOW(), id_user, 1, 3, 'owner_processes', NEW.id_process);
        SET id_log = (SELECT
            LAST_INSERT_ID());
      END IF;
      INSERT INTO log_owner_processes_value
        VALUES (NULL, id_log, 'annul_comment', NEW.annul_comment);
    END IF;
    IF ((NEW.comment IS NULL
      AND OLD.comment IS NOT NULL)
      OR (NEW.comment IS NOT NULL
      AND OLD.comment IS NULL)
      OR (NEW.comment <> OLD.comment)) THEN
      IF (id_log = -1) THEN
        INSERT INTO log_owner_processes
          VALUES (NULL, NEW.id_process, NOW(), id_user, 1, 3, 'owner_processes', NEW.id_process);
        SET id_log = (SELECT
            LAST_INSERT_ID());
      END IF;
      INSERT INTO log_owner_processes_value
        VALUES (NULL, id_log, 'comment', NEW.comment);
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать таблицу `owner_sub_premises_assoc`
--
CREATE TABLE IF NOT EXISTS owner_sub_premises_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_sub_premise int(11) NOT NULL,
  id_process int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 9,
AVG_ROW_LENGTH = 2340,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `owner_sub_premises_assoc_after_insert`
--
CREATE TRIGGER owner_sub_premises_assoc_after_insert
AFTER INSERT
ON owner_sub_premises_assoc
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  DECLARE id_log int(11);
  SET id_user = (SELECT
      au.id_user
    FROM acl_users au
    WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
  INSERT INTO log_owner_processes
    VALUES (NULL, NEW.id_process, NOW(), id_user, 2, 2, 'owner_sub_premises_assoc', NEW.id_assoc);
  SET id_log = (SELECT
      LAST_INSERT_ID());
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'id_sub_premise', NEW.id_sub_premise);
END
$$

--
-- Создать триггер `owner_sub_premises_assoc_after_update`
--
CREATE TRIGGER owner_sub_premises_assoc_after_update
AFTER UPDATE
ON owner_sub_premises_assoc
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    SET id_user = (SELECT
        au.id_user
      FROM acl_users au
      WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
    INSERT INTO log_owner_processes
      VALUES (NULL, NEW.id_process, NOW(), id_user, 2, 6, 'owner_sub_premises_assoc', NEW.id_assoc);
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE owner_sub_premises_assoc
ADD CONSTRAINT FK_owner_sub_premises_assoc_id_process FOREIGN KEY (id_process)
REFERENCES owner_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE owner_sub_premises_assoc
ADD CONSTRAINT FK_owner_sub_premises_assoc_id_sub_premise FOREIGN KEY (id_sub_premise)
REFERENCES sub_premises (id_sub_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `owner_premises_assoc`
--
CREATE TABLE IF NOT EXISTS owner_premises_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_premise int(11) NOT NULL,
  id_process int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1187,
AVG_ROW_LENGTH = 76,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `owner_premises_assoc_after_insert`
--
CREATE TRIGGER owner_premises_assoc_after_insert
AFTER INSERT
ON owner_premises_assoc
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  DECLARE id_log int(11);
  SET id_user = (SELECT
      au.id_user
    FROM acl_users au
    WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
  INSERT INTO log_owner_processes
    VALUES (NULL, NEW.id_process, NOW(), id_user, 2, 2, 'owner_premises_assoc', NEW.id_assoc);
  SET id_log = (SELECT
      LAST_INSERT_ID());
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'id_premise', NEW.id_premise);
END
$$

--
-- Создать триггер `owner_premises_assoc_after_update`
--
CREATE TRIGGER owner_premises_assoc_after_update
AFTER UPDATE
ON owner_premises_assoc
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    SET id_user = (SELECT
        au.id_user
      FROM acl_users au
      WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
    INSERT INTO log_owner_processes
      VALUES (NULL, NEW.id_process, NOW(), id_user, 2, 6, 'owner_premises_assoc', NEW.id_assoc);
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE owner_premises_assoc
ADD CONSTRAINT FK_owner_premises_assoc_id_premise FOREIGN KEY (id_premise)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE owner_premises_assoc
ADD CONSTRAINT FK_owner_premises_assoc_id_process FOREIGN KEY (id_process)
REFERENCES owner_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `owner_files`
--
CREATE TABLE IF NOT EXISTS owner_files (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_process int(11) NOT NULL,
  date_download date NOT NULL,
  file_origin_name varchar(255) DEFAULT NULL,
  file_display_name varchar(255) DEFAULT NULL,
  file_mime_type varchar(255) DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2692,
AVG_ROW_LENGTH = 64,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `owner_files_after_insert`
--
CREATE TRIGGER owner_files_after_insert
AFTER INSERT
ON owner_files
FOR EACH ROW
BEGIN
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'owner_files', NEW.id, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_download IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'owner_files', NEW.id, 'date_download', NULL, NEW.date_download, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.file_origin_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'owner_files', NEW.id, 'file_origin_name', NULL, NEW.file_origin_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.file_display_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'owner_files', NEW.id, 'file_display_name', NULL, NEW.file_display_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.file_mime_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'owner_files', NEW.id, 'file_mime_type', NULL, NEW.file_mime_type, 'INSERT', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE owner_files
ADD CONSTRAINT FK_owner_files_id_process FOREIGN KEY (id_process)
REFERENCES owner_processes (id_process) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `owner_buildings_assoc`
--
CREATE TABLE IF NOT EXISTS owner_buildings_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_building int(11) NOT NULL,
  id_process int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `owner_buildings_assoc_after_insert`
--
CREATE TRIGGER owner_buildings_assoc_after_insert
AFTER INSERT
ON owner_buildings_assoc
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  DECLARE id_log int(11);
  SET id_user = (SELECT
      au.id_user
    FROM acl_users au
    WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
  INSERT INTO log_owner_processes
    VALUES (NULL, NEW.id_process, NOW(), id_user, 2, 2, 'owner_buildings_assoc', NEW.id_assoc);
  SET id_log = (SELECT
      LAST_INSERT_ID());
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'id_building', NEW.id_building);
END
$$

--
-- Создать триггер `owner_buildings_assoc_after_update`
--
CREATE TRIGGER owner_buildings_assoc_after_update
AFTER UPDATE
ON owner_buildings_assoc
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    SET id_user = (SELECT
        au.id_user
      FROM acl_users au
      WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
    INSERT INTO log_owner_processes
      VALUES (NULL, NEW.id_process, NOW(), id_user, 2, 6, 'owner_buildings_assoc', NEW.id_assoc);
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE owner_buildings_assoc
ADD CONSTRAINT FK_owner_buildings_assoc_id_building FOREIGN KEY (id_building)
REFERENCES buildings (id_building) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE owner_buildings_assoc
ADD CONSTRAINT FK_owner_buildings_assoc_id_process FOREIGN KEY (id_process)
REFERENCES owner_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `kumi_payment_reasons`
--
CREATE TABLE IF NOT EXISTS kumi_payment_reasons (
  id_payment_reason int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  code varchar(2) NOT NULL,
  PRIMARY KEY (id_payment_reason)
)
ENGINE = INNODB,
AUTO_INCREMENT = 22,
AVG_ROW_LENGTH = 910,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_payment_kinds`
--
CREATE TABLE IF NOT EXISTS kumi_payment_kinds (
  id_payment_kind int(11) NOT NULL AUTO_INCREMENT,
  name varchar(50) NOT NULL,
  code varchar(1) NOT NULL,
  PRIMARY KEY (id_payment_kind)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_payment_info_sources`
--
CREATE TABLE IF NOT EXISTS kumi_payment_info_sources (
  id_source int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  code varchar(10) NOT NULL,
  PRIMARY KEY (id_source)
)
ENGINE = INNODB,
AUTO_INCREMENT = 9,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_payment_groups`
--
CREATE TABLE IF NOT EXISTS kumi_payment_groups (
  id_group int(11) NOT NULL AUTO_INCREMENT,
  date date NOT NULL,
  user varchar(255) NOT NULL,
  PRIMARY KEY (id_group)
)
ENGINE = INNODB,
AUTO_INCREMENT = 330,
AVG_ROW_LENGTH = 468,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_payment_groups_log`
--
CREATE TABLE IF NOT EXISTS kumi_payment_groups_log (
  id_log int(11) NOT NULL AUTO_INCREMENT,
  id_group int(11) DEFAULT NULL,
  log longtext DEFAULT NULL,
  PRIMARY KEY (id_log)
)
ENGINE = INNODB,
AUTO_INCREMENT = 266,
AVG_ROW_LENGTH = 397312,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payment_groups_log
ADD CONSTRAINT FK_kumi_payment_groups_log_id_ FOREIGN KEY (id_group)
REFERENCES kumi_payment_groups (id_group) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `kumi_payment_group_files`
--
CREATE TABLE IF NOT EXISTS kumi_payment_group_files (
  id_file int(11) NOT NULL AUTO_INCREMENT,
  id_group int(11) NOT NULL,
  file_name varchar(255) NOT NULL,
  file_version varchar(10) NOT NULL,
  notice_date date DEFAULT NULL,
  PRIMARY KEY (id_file)
)
ENGINE = INNODB,
AUTO_INCREMENT = 758,
AVG_ROW_LENGTH = 169,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payment_group_files
ADD CONSTRAINT FK_kumi_payment_group_files_id FOREIGN KEY (id_group)
REFERENCES kumi_payment_groups (id_group) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `kumi_payment_doc_codes`
--
CREATE TABLE IF NOT EXISTS kumi_payment_doc_codes (
  id_payment_doc_code int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  code varchar(2) NOT NULL,
  PRIMARY KEY (id_payment_doc_code)
)
ENGINE = INNODB,
AUTO_INCREMENT = 11,
AVG_ROW_LENGTH = 2048,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_payer_status`
--
CREATE TABLE IF NOT EXISTS kumi_payer_status (
  id_payer_status int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  code varchar(2) NOT NULL,
  PRIMARY KEY (id_payer_status)
)
ENGINE = INNODB,
AUTO_INCREMENT = 27,
AVG_ROW_LENGTH = 655,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_operation_types`
--
CREATE TABLE IF NOT EXISTS kumi_operation_types (
  id_operation_type int(11) NOT NULL AUTO_INCREMENT,
  name varchar(50) NOT NULL,
  code varchar(2) NOT NULL,
  PRIMARY KEY (id_operation_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_kbk_types`
--
CREATE TABLE IF NOT EXISTS kumi_kbk_types (
  id_kbk_type int(11) NOT NULL AUTO_INCREMENT,
  name varchar(50) NOT NULL,
  code varchar(2) NOT NULL,
  PRIMARY KEY (id_kbk_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_payments`
--
CREATE TABLE IF NOT EXISTS kumi_payments (
  id_payment int(11) NOT NULL AUTO_INCREMENT,
  id_parent_payment int(11) DEFAULT NULL,
  id_group int(11) DEFAULT NULL COMMENT 'Идентификатор группы платежей',
  id_source int(11) NOT NULL COMMENT 'Источник информации',
  guid varchar(36) DEFAULT NULL COMMENT 'GUID платежа',
  id_payment_doc_code int(11) DEFAULT NULL,
  num_d varchar(255) DEFAULT NULL COMMENT '№ платежного документа / № распоряжения',
  date_d date DEFAULT NULL COMMENT 'Дата платежного документа / Дата распоряжения',
  date_in date DEFAULT NULL COMMENT 'Дата поступления в банк плательщика',
  date_e date DEFAULT NULL COMMENT 'Дата списания со счета плательщика / Дата исполнения распоряжения',
  date_pay date DEFAULT NULL COMMENT 'Срок платежа',
  id_payment_kind int(11) DEFAULT NULL COMMENT 'Вид платежа',
  order_pay int(11) DEFAULT NULL COMMENT 'Очередность платежа',
  id_operation_type int(11) DEFAULT NULL COMMENT 'Вид операции',
  sum decimal(12, 2) NOT NULL COMMENT 'Сумма платежа',
  uin varchar(25) DEFAULT NULL COMMENT 'УИН',
  id_purpose int(11) DEFAULT NULL COMMENT 'Назначение платежа кодовое',
  purpose varchar(500) DEFAULT NULL COMMENT 'Назначение платежа',
  kbk varchar(20) DEFAULT NULL COMMENT 'КБК',
  id_kbk_type int(11) DEFAULT NULL COMMENT 'Тип КБК',
  target_code varchar(25) DEFAULT NULL COMMENT 'Код цели',
  okato varchar(20) DEFAULT NULL COMMENT 'Код ОКТМО',
  id_payment_reason int(11) DEFAULT NULL COMMENT 'Показатель основания платежа',
  num_d_indicator varchar(15) DEFAULT NULL COMMENT 'Показатель номера документа',
  date_d_indicator date DEFAULT NULL COMMENT 'Показатель даты документа',
  id_payer_status int(11) DEFAULT NULL COMMENT 'Статус составителя расчетного документа',
  payer_inn varchar(12) DEFAULT NULL COMMENT 'ИНН плательщика',
  payer_kpp varchar(12) DEFAULT NULL COMMENT 'КПП плательщика',
  payer_name varchar(2000) DEFAULT NULL COMMENT 'Наименование плательщика',
  payer_account varchar(20) DEFAULT NULL COMMENT 'Счет плательщика',
  payer_bank_bik varchar(9) DEFAULT NULL COMMENT 'БИК банка плательщика',
  payer_bank_name varchar(160) DEFAULT NULL COMMENT 'Наименование банка плательщика',
  payer_bank_account varchar(20) DEFAULT NULL COMMENT 'Коррсчет банк плательщика',
  recipient_inn varchar(12) DEFAULT NULL COMMENT 'ИНН получателя',
  recipient_kpp varchar(12) DEFAULT NULL COMMENT 'КПП получателя',
  recipient_name varchar(2000) DEFAULT NULL COMMENT 'Наименование получателя',
  recipient_account varchar(20) DEFAULT NULL COMMENT 'Счет получателя',
  recipient_bank_bik varchar(9) DEFAULT NULL COMMENT 'БИК банка получателя',
  recipient_bank_name varchar(160) DEFAULT NULL COMMENT 'Наименование банка получателя',
  recipient_bank_account varchar(20) DEFAULT NULL COMMENT 'Коррсчет банк получателя',
  description varchar(1024) DEFAULT NULL COMMENT 'Описание платежа (с указанием ЛС/ПИР/Адреса)',
  date_enroll_ufk date DEFAULT NULL COMMENT 'Дата зачисления на счет УФК',
  is_posted tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Признак разноски',
  is_consolidated tinyint(1) NOT NULL DEFAULT 0,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  _estatebratsk_oid varchar(12) DEFAULT NULL,
  PRIMARY KEY (id_payment)
)
ENGINE = INNODB,
AUTO_INCREMENT = 124365,
AVG_ROW_LENGTH = 348,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IDX_kumi_payments_guid` для объекта типа таблица `kumi_payments`
--
ALTER TABLE kumi_payments
ADD INDEX IDX_kumi_payments_guid (guid);

DELIMITER $$

--
-- Создать триггер `kumi_payments_after_insert`
--
CREATE TRIGGER kumi_payments_after_insert
AFTER INSERT
ON kumi_payments
FOR EACH ROW
BEGIN
  IF (NEW.id_payment IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_payment', NULL, NEW.id_payment, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_parent_payment IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_parent_payment', NULL, NEW.id_parent_payment, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_group IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_group', NULL, NEW.id_group, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_source IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_source', NULL, NEW.id_source, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.guid IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'guid', NULL, NEW.guid, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_payment_doc_code IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_payment_doc_code', NULL, NEW.id_payment_doc_code, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.num_d IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'num_d', NULL, NEW.num_d, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_d IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'date_d', NULL, NEW.date_d, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_in IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'date_in', NULL, NEW.date_in, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_e IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'date_e', NULL, NEW.date_e, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_pay IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'date_pay', NULL, NEW.date_pay, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_payment_kind IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_payment_kind', NULL, NEW.id_payment_kind, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.order_pay IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'order_pay', NULL, NEW.order_pay, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_operation_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_operation_type', NULL, NEW.id_operation_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.`sum` IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'sum', NULL, NEW.`sum`, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.uin IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'uin', NULL, NEW.uin, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_purpose IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_purpose', NULL, NEW.id_purpose, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.purpose IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'purpose', NULL, NEW.purpose, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.kbk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'kbk', NULL, NEW.kbk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_kbk_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_kbk_type', NULL, NEW.id_kbk_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.target_code IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'target_code', NULL, NEW.target_code, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.okato IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'okato', NULL, NEW.okato, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_payment_reason IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_payment_reason', NULL, NEW.id_payment_reason, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.num_d_indicator IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'num_d_indicator', NULL, NEW.num_d_indicator, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_d_indicator IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'date_d_indicator', NULL, NEW.date_d_indicator, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_payer_status IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_payer_status', NULL, NEW.id_payer_status, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payer_inn IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_inn', NULL, NEW.payer_inn, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payer_kpp IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_kpp', NULL, NEW.payer_kpp, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payer_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_name', NULL, NEW.payer_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payer_account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_account', NULL, NEW.payer_account, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payer_bank_bik IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_bank_bik', NULL, NEW.payer_bank_bik, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payer_bank_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_bank_name', NULL, NEW.payer_bank_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.payer_bank_account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_bank_account', NULL, NEW.payer_bank_account, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recipient_inn IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_inn', NULL, NEW.recipient_inn, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recipient_kpp IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_kpp', NULL, NEW.recipient_kpp, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recipient_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_name', NULL, NEW.recipient_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recipient_account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_account', NULL, NEW.recipient_account, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recipient_bank_bik IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_bank_bik', NULL, NEW.recipient_bank_bik, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recipient_bank_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_bank_name', NULL, NEW.recipient_bank_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recipient_bank_account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_bank_account', NULL, NEW.recipient_bank_account, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_enroll_ufk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'date_enroll_ufk', NULL, NEW.date_enroll_ufk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_posted IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'is_posted', NULL, NEW.is_posted, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.is_consolidated IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'is_consolidated', NULL, NEW.is_consolidated, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `kumi_payments_after_update`
--
CREATE TRIGGER kumi_payments_after_update
AFTER UPDATE
ON kumi_payments
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments', NEW.id_payment, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NOT (NEW.id_parent_payment IS NULL
      AND OLD.id_parent_payment IS NULL)
      AND ((NEW.id_parent_payment IS NULL
      AND OLD.id_parent_payment IS NOT NULL)
      OR (NEW.id_parent_payment IS NOT NULL
      AND OLD.id_parent_payment IS NULL)
      OR (NEW.id_parent_payment <> OLD.id_parent_payment))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_parent_payment', OLD.id_parent_payment, NEW.id_parent_payment, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_group IS NULL
      AND OLD.id_group IS NULL)
      AND ((NEW.id_group IS NULL
      AND OLD.id_group IS NOT NULL)
      OR (NEW.id_group IS NOT NULL
      AND OLD.id_group IS NULL)
      OR (NEW.id_group <> OLD.id_group))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_group', OLD.id_group, NEW.id_group, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_source <> OLD.id_source) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_source', OLD.id_source, NEW.id_source, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.guid IS NULL
      AND OLD.guid IS NULL)
      AND ((NEW.guid IS NULL
      AND OLD.guid IS NOT NULL)
      OR (NEW.guid IS NOT NULL
      AND OLD.guid IS NULL)
      OR (NEW.guid <> OLD.guid))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'guid', OLD.guid, NEW.guid, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_payment_doc_code IS NULL
      AND OLD.id_payment_doc_code IS NULL)
      AND ((NEW.id_payment_doc_code IS NULL
      AND OLD.id_payment_doc_code IS NOT NULL)
      OR (NEW.id_payment_doc_code IS NOT NULL
      AND OLD.id_payment_doc_code IS NULL)
      OR (NEW.id_payment_doc_code <> OLD.id_payment_doc_code))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_payment_doc_code', OLD.id_payment_doc_code, NEW.id_payment_doc_code, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.num_d IS NULL
      AND OLD.num_d IS NULL)
      AND ((NEW.num_d IS NULL
      AND OLD.num_d IS NOT NULL)
      OR (NEW.num_d IS NOT NULL
      AND OLD.num_d IS NULL)
      OR (NEW.num_d <> OLD.num_d))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'num_d', OLD.num_d, NEW.num_d, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_d IS NULL
      AND OLD.date_d IS NULL)
      AND ((NEW.date_d IS NULL
      AND OLD.date_d IS NOT NULL)
      OR (NEW.date_d IS NOT NULL
      AND OLD.date_d IS NULL)
      OR (NEW.date_d <> OLD.date_d))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'date_d', OLD.date_d, NEW.date_d, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_in IS NULL
      AND OLD.date_in IS NULL)
      AND ((NEW.date_in IS NULL
      AND OLD.date_in IS NOT NULL)
      OR (NEW.date_in IS NOT NULL
      AND OLD.date_in IS NULL)
      OR (NEW.date_in <> OLD.date_in))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'date_in', OLD.date_in, NEW.date_in, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_e IS NULL
      AND OLD.date_e IS NULL)
      AND ((NEW.date_e IS NULL
      AND OLD.date_e IS NOT NULL)
      OR (NEW.date_e IS NOT NULL
      AND OLD.date_e IS NULL)
      OR (NEW.date_e <> OLD.date_e))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'date_e', OLD.date_e, NEW.date_e, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_pay IS NULL
      AND OLD.date_pay IS NULL)
      AND ((NEW.date_pay IS NULL
      AND OLD.date_pay IS NOT NULL)
      OR (NEW.date_pay IS NOT NULL
      AND OLD.date_pay IS NULL)
      OR (NEW.date_pay <> OLD.date_pay))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'date_pay', OLD.date_pay, NEW.date_pay, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_payment_kind IS NULL
      AND OLD.id_payment_kind IS NULL)
      AND ((NEW.id_payment_kind IS NULL
      AND OLD.id_payment_kind IS NOT NULL)
      OR (NEW.id_payment_kind IS NOT NULL
      AND OLD.id_payment_kind IS NULL)
      OR (NEW.id_payment_kind <> OLD.id_payment_kind))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_payment_kind', OLD.id_payment_kind, NEW.id_payment_kind, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.order_pay IS NULL
      AND OLD.order_pay IS NULL)
      AND ((NEW.order_pay IS NULL
      AND OLD.order_pay IS NOT NULL)
      OR (NEW.order_pay IS NOT NULL
      AND OLD.order_pay IS NULL)
      OR (NEW.order_pay <> OLD.order_pay))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'order_pay', OLD.order_pay, NEW.order_pay, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_operation_type IS NULL
      AND OLD.id_operation_type IS NULL)
      AND ((NEW.id_operation_type IS NULL
      AND OLD.id_operation_type IS NOT NULL)
      OR (NEW.id_operation_type IS NOT NULL
      AND OLD.id_operation_type IS NULL)
      OR (NEW.id_operation_type <> OLD.id_operation_type))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_operation_type', OLD.id_operation_type, NEW.id_operation_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.`sum` <> OLD.`sum`) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'sum', OLD.`sum`, NEW.`sum`, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.uin IS NULL
      AND OLD.uin IS NULL)
      AND ((NEW.uin IS NULL
      AND OLD.uin IS NOT NULL)
      OR (NEW.uin IS NOT NULL
      AND OLD.uin IS NULL)
      OR (NEW.uin <> OLD.uin))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'uin', OLD.uin, NEW.uin, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_purpose IS NULL
      AND OLD.id_purpose IS NULL)
      AND ((NEW.id_purpose IS NULL
      AND OLD.id_purpose IS NOT NULL)
      OR (NEW.id_purpose IS NOT NULL
      AND OLD.id_purpose IS NULL)
      OR (NEW.id_purpose <> OLD.id_purpose))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_purpose', OLD.id_purpose, NEW.id_purpose, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.purpose IS NULL
      AND OLD.purpose IS NULL)
      AND ((NEW.purpose IS NULL
      AND OLD.purpose IS NOT NULL)
      OR (NEW.purpose IS NOT NULL
      AND OLD.purpose IS NULL)
      OR (NEW.purpose <> OLD.purpose))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'purpose', OLD.purpose, NEW.purpose, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.kbk IS NULL
      AND OLD.kbk IS NULL)
      AND ((NEW.kbk IS NULL
      AND OLD.kbk IS NOT NULL)
      OR (NEW.kbk IS NOT NULL
      AND OLD.kbk IS NULL)
      OR (NEW.kbk <> OLD.kbk))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'kbk', OLD.kbk, NEW.kbk, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_kbk_type IS NULL
      AND OLD.id_kbk_type IS NULL)
      AND ((NEW.id_kbk_type IS NULL
      AND OLD.id_kbk_type IS NOT NULL)
      OR (NEW.id_kbk_type IS NOT NULL
      AND OLD.id_kbk_type IS NULL)
      OR (NEW.id_kbk_type <> OLD.id_kbk_type))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_kbk_type', OLD.id_kbk_type, NEW.id_kbk_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.target_code IS NULL
      AND OLD.target_code IS NULL)
      AND ((NEW.target_code IS NULL
      AND OLD.target_code IS NOT NULL)
      OR (NEW.target_code IS NOT NULL
      AND OLD.target_code IS NULL)
      OR (NEW.target_code <> OLD.target_code))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'target_code', OLD.target_code, NEW.target_code, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.okato IS NULL
      AND OLD.okato IS NULL)
      AND ((NEW.okato IS NULL
      AND OLD.okato IS NOT NULL)
      OR (NEW.okato IS NOT NULL
      AND OLD.okato IS NULL)
      OR (NEW.okato <> OLD.okato))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'okato', OLD.okato, NEW.okato, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_payment_reason IS NULL
      AND OLD.id_payment_reason IS NULL)
      AND ((NEW.id_payment_reason IS NULL
      AND OLD.id_payment_reason IS NOT NULL)
      OR (NEW.id_payment_reason IS NOT NULL
      AND OLD.id_payment_reason IS NULL)
      OR (NEW.id_payment_reason <> OLD.id_payment_reason))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_payment_reason', OLD.id_payment_reason, NEW.id_payment_reason, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.num_d_indicator IS NULL
      AND OLD.num_d_indicator IS NULL)
      AND ((NEW.num_d_indicator IS NULL
      AND OLD.num_d_indicator IS NOT NULL)
      OR (NEW.num_d_indicator IS NOT NULL
      AND OLD.num_d_indicator IS NULL)
      OR (NEW.num_d_indicator <> OLD.num_d_indicator))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'num_d_indicator', OLD.num_d_indicator, NEW.num_d_indicator, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_d_indicator IS NULL
      AND OLD.date_d_indicator IS NULL)
      AND ((NEW.date_d_indicator IS NULL
      AND OLD.date_d_indicator IS NOT NULL)
      OR (NEW.date_d_indicator IS NOT NULL
      AND OLD.date_d_indicator IS NULL)
      OR (NEW.date_d_indicator <> OLD.date_d_indicator))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'date_d_indicator', OLD.date_d_indicator, NEW.date_d_indicator, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_payer_status IS NULL
      AND OLD.id_payer_status IS NULL)
      AND ((NEW.id_payer_status IS NULL
      AND OLD.id_payer_status IS NOT NULL)
      OR (NEW.id_payer_status IS NOT NULL
      AND OLD.id_payer_status IS NULL)
      OR (NEW.id_payer_status <> OLD.id_payer_status))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'id_payer_status', OLD.id_payer_status, NEW.id_payer_status, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.payer_inn IS NULL
      AND OLD.payer_inn IS NULL)
      AND ((NEW.payer_inn IS NULL
      AND OLD.payer_inn IS NOT NULL)
      OR (NEW.payer_inn IS NOT NULL
      AND OLD.payer_inn IS NULL)
      OR (NEW.payer_inn <> OLD.payer_inn))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_inn', OLD.payer_inn, NEW.payer_inn, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.payer_kpp IS NULL
      AND OLD.payer_kpp IS NULL)
      AND ((NEW.payer_kpp IS NULL
      AND OLD.payer_kpp IS NOT NULL)
      OR (NEW.payer_kpp IS NOT NULL
      AND OLD.payer_kpp IS NULL)
      OR (NEW.payer_kpp <> OLD.payer_kpp))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_kpp', OLD.payer_kpp, NEW.payer_kpp, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.payer_name IS NULL
      AND OLD.payer_name IS NULL)
      AND ((NEW.payer_name IS NULL
      AND OLD.payer_name IS NOT NULL)
      OR (NEW.payer_name IS NOT NULL
      AND OLD.payer_name IS NULL)
      OR (NEW.payer_name <> OLD.payer_name))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_name', OLD.payer_name, NEW.payer_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.payer_account IS NULL
      AND OLD.payer_account IS NULL)
      AND ((NEW.payer_account IS NULL
      AND OLD.payer_account IS NOT NULL)
      OR (NEW.payer_account IS NOT NULL
      AND OLD.payer_account IS NULL)
      OR (NEW.payer_account <> OLD.payer_account))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_account', OLD.payer_account, NEW.payer_account, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.payer_bank_bik IS NULL
      AND OLD.payer_bank_bik IS NULL)
      AND ((NEW.payer_bank_bik IS NULL
      AND OLD.payer_bank_bik IS NOT NULL)
      OR (NEW.payer_bank_bik IS NOT NULL
      AND OLD.payer_bank_bik IS NULL)
      OR (NEW.payer_bank_bik <> OLD.payer_bank_bik))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_bank_bik', OLD.payer_bank_bik, NEW.payer_bank_bik, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.payer_bank_name IS NULL
      AND OLD.payer_bank_name IS NULL)
      AND ((NEW.payer_bank_name IS NULL
      AND OLD.payer_bank_name IS NOT NULL)
      OR (NEW.payer_bank_name IS NOT NULL
      AND OLD.payer_bank_name IS NULL)
      OR (NEW.payer_bank_name <> OLD.payer_bank_name))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_bank_name', OLD.payer_bank_name, NEW.payer_bank_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.payer_bank_account IS NULL
      AND OLD.payer_bank_account IS NULL)
      AND ((NEW.payer_bank_account IS NULL
      AND OLD.payer_bank_account IS NOT NULL)
      OR (NEW.payer_bank_account IS NOT NULL
      AND OLD.payer_bank_account IS NULL)
      OR (NEW.payer_bank_account <> OLD.payer_bank_account))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'payer_bank_account', OLD.payer_bank_account, NEW.payer_bank_account, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.recipient_inn IS NULL
      AND OLD.recipient_inn IS NULL)
      AND ((NEW.recipient_inn IS NULL
      AND OLD.recipient_inn IS NOT NULL)
      OR (NEW.recipient_inn IS NOT NULL
      AND OLD.recipient_inn IS NULL)
      OR (NEW.recipient_inn <> OLD.recipient_inn))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_inn', OLD.recipient_inn, NEW.recipient_inn, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.recipient_kpp IS NULL
      AND OLD.recipient_kpp IS NULL)
      AND ((NEW.recipient_kpp IS NULL
      AND OLD.recipient_kpp IS NOT NULL)
      OR (NEW.recipient_kpp IS NOT NULL
      AND OLD.recipient_kpp IS NULL)
      OR (NEW.recipient_kpp <> OLD.recipient_kpp))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_kpp', OLD.recipient_kpp, NEW.recipient_kpp, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.recipient_name IS NULL
      AND OLD.recipient_name IS NULL)
      AND ((NEW.recipient_name IS NULL
      AND OLD.recipient_name IS NOT NULL)
      OR (NEW.recipient_name IS NOT NULL
      AND OLD.recipient_name IS NULL)
      OR (NEW.recipient_name <> OLD.recipient_name))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_name', OLD.recipient_name, NEW.recipient_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.recipient_account IS NULL
      AND OLD.recipient_account IS NULL)
      AND ((NEW.recipient_account IS NULL
      AND OLD.recipient_account IS NOT NULL)
      OR (NEW.recipient_account IS NOT NULL
      AND OLD.recipient_account IS NULL)
      OR (NEW.recipient_account <> OLD.recipient_account))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_account', OLD.recipient_account, NEW.recipient_account, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.recipient_bank_bik IS NULL
      AND OLD.recipient_bank_bik IS NULL)
      AND ((NEW.recipient_bank_bik IS NULL
      AND OLD.recipient_bank_bik IS NOT NULL)
      OR (NEW.recipient_bank_bik IS NOT NULL
      AND OLD.recipient_bank_bik IS NULL)
      OR (NEW.recipient_bank_bik <> OLD.recipient_bank_bik))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_bank_bik', OLD.recipient_bank_bik, NEW.recipient_bank_bik, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.recipient_bank_name IS NULL
      AND OLD.recipient_bank_name IS NULL)
      AND ((NEW.recipient_bank_name IS NULL
      AND OLD.recipient_bank_name IS NOT NULL)
      OR (NEW.recipient_bank_name IS NOT NULL
      AND OLD.recipient_bank_name IS NULL)
      OR (NEW.recipient_bank_name <> OLD.recipient_bank_name))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_bank_name', OLD.recipient_bank_name, NEW.recipient_bank_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.recipient_bank_account IS NULL
      AND OLD.recipient_bank_account IS NULL)
      AND ((NEW.recipient_bank_account IS NULL
      AND OLD.recipient_bank_account IS NOT NULL)
      OR (NEW.recipient_bank_account IS NOT NULL
      AND OLD.recipient_bank_account IS NULL)
      OR (NEW.recipient_bank_account <> OLD.recipient_bank_account))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'recipient_bank_account', OLD.recipient_bank_account, NEW.recipient_bank_account, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_enroll_ufk IS NULL
      AND OLD.date_enroll_ufk IS NULL)
      AND ((NEW.date_enroll_ufk IS NULL
      AND OLD.date_enroll_ufk IS NOT NULL)
      OR (NEW.date_enroll_ufk IS NOT NULL
      AND OLD.date_enroll_ufk IS NULL)
      OR (NEW.date_enroll_ufk <> OLD.date_enroll_ufk))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'date_enroll_ufk', OLD.date_enroll_ufk, NEW.date_enroll_ufk, 'UPDATE', NOW(), USER());
    END IF;

    IF (NEW.is_posted <> OLD.is_posted) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'is_posted', OLD.is_posted, NEW.is_posted, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.is_consolidated <> OLD.is_consolidated) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments', NEW.id_payment, 'is_consolidated', OLD.is_consolidated, NEW.is_consolidated, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments
ADD CONSTRAINT FK_kumi_payments_id_group FOREIGN KEY (id_group)
REFERENCES kumi_payment_groups (id_group) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments
ADD CONSTRAINT FK_kumi_payments_id_kbk_type FOREIGN KEY (id_kbk_type)
REFERENCES kumi_kbk_types (id_kbk_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments
ADD CONSTRAINT FK_kumi_payments_id_operation_ FOREIGN KEY (id_operation_type)
REFERENCES kumi_operation_types (id_operation_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments
ADD CONSTRAINT FK_kumi_payments_id_parent_pay FOREIGN KEY (id_parent_payment)
REFERENCES kumi_payments (id_payment) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments
ADD CONSTRAINT FK_kumi_payments_id_payer_stat FOREIGN KEY (id_payer_status)
REFERENCES kumi_payer_status (id_payer_status) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments
ADD CONSTRAINT FK_kumi_payments_id_payment_do FOREIGN KEY (id_payment_doc_code)
REFERENCES kumi_payment_doc_codes (id_payment_doc_code) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments
ADD CONSTRAINT FK_kumi_payments_id_payment_ki FOREIGN KEY (id_payment_kind)
REFERENCES kumi_payment_kinds (id_payment_kind) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments
ADD CONSTRAINT FK_kumi_payments_id_payment_re FOREIGN KEY (id_payment_reason)
REFERENCES kumi_payment_reasons (id_payment_reason) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments
ADD CONSTRAINT FK_kumi_payments_id_source FOREIGN KEY (id_source)
REFERENCES kumi_payment_info_sources (id_source) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `kumi_payments_uf`
--
CREATE TABLE IF NOT EXISTS kumi_payments_uf (
  id_payment_uf int(11) NOT NULL AUTO_INCREMENT,
  id_payment int(11) NOT NULL,
  num_uf varchar(15) NOT NULL COMMENT 'Номер Уведомления',
  date_uf date NOT NULL COMMENT 'Дата Уведомления',
  sum decimal(12, 2) DEFAULT NULL COMMENT 'Сумма',
  purpose varchar(500) DEFAULT NULL COMMENT 'Назначение платежа',
  kbk varchar(20) DEFAULT NULL COMMENT 'КБК',
  id_kbk_type int(11) DEFAULT NULL COMMENT 'Тип КБК',
  target_code varchar(25) DEFAULT NULL COMMENT 'Код цели',
  okato varchar(20) DEFAULT NULL COMMENT 'Код ОКТМО',
  recipient_inn varchar(12) DEFAULT NULL COMMENT 'ИНН получателя',
  recipient_kpp varchar(12) DEFAULT NULL COMMENT 'КПП получателя',
  recipient_name varchar(160) DEFAULT NULL COMMENT 'Наименование получателя',
  recipient_account varchar(20) DEFAULT NULL COMMENT 'Счет получателя',
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_payment_uf)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2088,
AVG_ROW_LENGTH = 1820,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `kumi_payments_uf_after_insert`
--
CREATE TRIGGER kumi_payments_uf_after_insert
AFTER INSERT
ON kumi_payments_uf
FOR EACH ROW
BEGIN
  IF (NEW.id_payment_uf IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'id_payment_uf', NULL, NEW.id_payment_uf, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_payment IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'id_payment', NULL, NEW.id_payment, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.num_uf IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'num_uf', NULL, NEW.num_uf, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_uf IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'date_uf', NULL, NEW.date_uf, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.`sum` IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'sum', NULL, NEW.`sum`, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.purpose IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'purpose', NULL, NEW.purpose, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.kbk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'kbk', NULL, NEW.kbk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_kbk_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'id_kbk_type', NULL, NEW.id_kbk_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.target_code IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'target_code', NULL, NEW.target_code, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.okato IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'okato', NULL, NEW.okato, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recipient_inn IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'recipient_inn', NULL, NEW.recipient_inn, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recipient_kpp IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'recipient_kpp', NULL, NEW.recipient_kpp, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recipient_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'recipient_name', NULL, NEW.recipient_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.recipient_account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'recipient_account', NULL, NEW.recipient_account, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `kumi_payments_uf_after_update`
--
CREATE TRIGGER kumi_payments_uf_after_update
AFTER UPDATE
ON kumi_payments_uf
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_payment <> OLD.id_payment) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'id_payment', OLD.id_payment, NEW.id_payment, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.num_uf <> OLD.num_uf) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'num_uf', OLD.num_uf, NEW.num_uf, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.date_uf <> OLD.date_uf) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'date_uf', OLD.date_uf, NEW.date_uf, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.`sum` IS NULL
      AND OLD.`sum` IS NULL)
      AND ((NEW.`sum` IS NULL
      AND OLD.`sum` IS NOT NULL)
      OR (NEW.`sum` IS NOT NULL
      AND OLD.`sum` IS NULL)
      OR (NEW.`sum` <> OLD.`sum`))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'sum', OLD.`sum`, NEW.`sum`, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.purpose IS NULL
      AND OLD.purpose IS NULL)
      AND ((NEW.purpose IS NULL
      AND OLD.purpose IS NOT NULL)
      OR (NEW.purpose IS NOT NULL
      AND OLD.purpose IS NULL)
      OR (NEW.purpose <> OLD.purpose))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'purpose', OLD.purpose, NEW.purpose, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.kbk IS NULL
      AND OLD.kbk IS NULL)
      AND ((NEW.kbk IS NULL
      AND OLD.kbk IS NOT NULL)
      OR (NEW.kbk IS NOT NULL
      AND OLD.kbk IS NULL)
      OR (NEW.kbk <> OLD.kbk))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'kbk', OLD.kbk, NEW.kbk, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_kbk_type IS NULL
      AND OLD.id_kbk_type IS NULL)
      AND ((NEW.id_kbk_type IS NULL
      AND OLD.id_kbk_type IS NOT NULL)
      OR (NEW.id_kbk_type IS NOT NULL
      AND OLD.id_kbk_type IS NULL)
      OR (NEW.id_kbk_type <> OLD.id_kbk_type))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'id_kbk_type', OLD.id_kbk_type, NEW.id_kbk_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.target_code IS NULL
      AND OLD.target_code IS NULL)
      AND ((NEW.target_code IS NULL
      AND OLD.target_code IS NOT NULL)
      OR (NEW.target_code IS NOT NULL
      AND OLD.target_code IS NULL)
      OR (NEW.target_code <> OLD.target_code))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'target_code', OLD.target_code, NEW.target_code, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.okato IS NULL
      AND OLD.okato IS NULL)
      AND ((NEW.okato IS NULL
      AND OLD.okato IS NOT NULL)
      OR (NEW.okato IS NOT NULL
      AND OLD.okato IS NULL)
      OR (NEW.okato <> OLD.okato))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'okato', OLD.okato, NEW.okato, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.recipient_inn IS NULL
      AND OLD.recipient_inn IS NULL)
      AND ((NEW.recipient_inn IS NULL
      AND OLD.recipient_inn IS NOT NULL)
      OR (NEW.recipient_inn IS NOT NULL
      AND OLD.recipient_inn IS NULL)
      OR (NEW.recipient_inn <> OLD.recipient_inn))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'recipient_inn', OLD.recipient_inn, NEW.recipient_inn, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.recipient_kpp IS NULL
      AND OLD.recipient_kpp IS NULL)
      AND ((NEW.recipient_kpp IS NULL
      AND OLD.recipient_kpp IS NOT NULL)
      OR (NEW.recipient_kpp IS NOT NULL
      AND OLD.recipient_kpp IS NULL)
      OR (NEW.recipient_kpp <> OLD.recipient_kpp))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'recipient_kpp', OLD.recipient_kpp, NEW.recipient_kpp, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.recipient_name IS NULL
      AND OLD.recipient_name IS NULL)
      AND ((NEW.recipient_name IS NULL
      AND OLD.recipient_name IS NOT NULL)
      OR (NEW.recipient_name IS NOT NULL
      AND OLD.recipient_name IS NULL)
      OR (NEW.recipient_name <> OLD.recipient_name))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'recipient_name', OLD.recipient_name, NEW.recipient_name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.recipient_account IS NULL
      AND OLD.recipient_account IS NULL)
      AND ((NEW.recipient_account IS NULL
      AND OLD.recipient_account IS NOT NULL)
      OR (NEW.recipient_account IS NOT NULL
      AND OLD.recipient_account IS NULL)
      OR (NEW.recipient_account <> OLD.recipient_account))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_payments_uf', NEW.id_payment_uf, 'recipient_account', OLD.recipient_account, NEW.recipient_account, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments_uf
ADD CONSTRAINT FK_kumi_payments_uf_id_payment FOREIGN KEY (id_payment)
REFERENCES kumi_payments (id_payment) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments_uf
ADD CONSTRAINT FK_kumi_payments_uf_id_kbk_typ FOREIGN KEY (id_kbk_type)
REFERENCES kumi_kbk_types (id_kbk_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `kumi_payments_corrections`
--
CREATE TABLE IF NOT EXISTS kumi_payments_corrections (
  id_correction int(11) NOT NULL AUTO_INCREMENT,
  id_payment int(11) NOT NULL,
  field_name varchar(50) NOT NULL,
  field_value varchar(500) DEFAULT NULL,
  date datetime NOT NULL,
  PRIMARY KEY (id_correction)
)
ENGINE = INNODB,
AUTO_INCREMENT = 7591,
AVG_ROW_LENGTH = 2048,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `kumi_payments_corrections_after_insert`
--
CREATE TRIGGER kumi_payments_corrections_after_insert
AFTER INSERT
ON kumi_payments_corrections
FOR EACH ROW
BEGIN
  IF (NEW.id_correction IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_corrections', NEW.id_correction, 'id_correction', NULL, NEW.id_correction, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_payment IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_corrections', NEW.id_correction, 'id_payment', NULL, NEW.id_payment, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.field_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_corrections', NEW.id_correction, 'field_name', NULL, NEW.field_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.field_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_corrections', NEW.id_correction, 'field_value', NULL, NEW.field_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_corrections', NEW.id_correction, 'date', NULL, NEW.date, 'INSERT', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments_corrections
ADD CONSTRAINT FK_kumi_payments_corrections_i FOREIGN KEY (id_payment)
REFERENCES kumi_payments (id_payment) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `kumi_memorial_orders`
--
CREATE TABLE IF NOT EXISTS kumi_memorial_orders (
  id_order int(11) NOT NULL AUTO_INCREMENT,
  id_group int(11) NOT NULL,
  guid varchar(36) NOT NULL COMMENT 'GUID платежа',
  num_d varchar(15) NOT NULL COMMENT 'Номер документа, подтверждающего проведение операции',
  doc_d date NOT NULL COMMENT 'Дата документа, подтверждающего проведение операции',
  sum_in decimal(12, 2) NOT NULL COMMENT 'Сумма поступлений',
  sum_zach decimal(12, 2) NOT NULL COMMENT 'Сумма зачетов',
  kbk varchar(20) NOT NULL COMMENT 'КБК',
  id_kbk_type int(11) DEFAULT NULL COMMENT 'Тип КБК',
  target_code varchar(25) DEFAULT NULL COMMENT 'Код цели',
  okato varchar(20) NOT NULL COMMENT 'Код ОКТМО',
  inn_adb varchar(12) NOT NULL COMMENT 'ИНН АДБ',
  kpp_adb varchar(12) NOT NULL COMMENT 'КПП АДБ',
  date_enroll_ufk date DEFAULT NULL,
  deleted tinyint(1) DEFAULT 0,
  _estatebratsk_oid varchar(12) DEFAULT NULL,
  PRIMARY KEY (id_order)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4830,
AVG_ROW_LENGTH = 442,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IDX_kumi_memorial_orders_guid` для объекта типа таблица `kumi_memorial_orders`
--
ALTER TABLE kumi_memorial_orders
ADD INDEX IDX_kumi_memorial_orders_guid (guid);

DELIMITER $$

--
-- Создать триггер `kumi_memorial_orders_after_insert`
--
CREATE TRIGGER kumi_memorial_orders_after_insert
AFTER INSERT
ON kumi_memorial_orders
FOR EACH ROW
BEGIN
  IF (NEW.id_order IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'id_order', NULL, NEW.id_order, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_group IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'id_group', NULL, NEW.id_group, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.guid IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'guid', NULL, NEW.guid, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.num_d IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'num_d', NULL, NEW.num_d, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.doc_d IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'doc_d', NULL, NEW.doc_d, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.sum_in IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'sum_in', NULL, NEW.sum_in, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.sum_zach IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'sum_zach', NULL, NEW.sum_zach, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.kbk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'kbk', NULL, NEW.kbk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_kbk_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'id_kbk_type', NULL, NEW.id_kbk_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.target_code IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'target_code', NULL, NEW.target_code, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.okato IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'okato', NULL, NEW.okato, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.inn_adb IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'inn_adb', NULL, NEW.inn_adb, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.kpp_adb IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'kpp_adb', NULL, NEW.kpp_adb, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_enroll_ufk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'date_enroll_ufk', NULL, NEW.date_enroll_ufk, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `kumi_memorial_orders_after_update`
--
CREATE TRIGGER kumi_memorial_orders_after_update
AFTER UPDATE
ON kumi_memorial_orders
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_group <> OLD.id_group) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'id_group', OLD.id_group, NEW.id_group, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.guid <> OLD.guid) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'guid', OLD.guid, NEW.guid, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.num_d <> OLD.num_d) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'num_d', OLD.num_d, NEW.num_d, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.doc_d <> OLD.doc_d) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'doc_d', OLD.doc_d, NEW.doc_d, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.sum_in <> OLD.sum_in) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'sum_in', OLD.sum_in, NEW.sum_in, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.sum_zach <> OLD.sum_zach) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'sum_zach', OLD.sum_zach, NEW.sum_zach, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.kbk <> OLD.kbk) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'kbk', OLD.kbk, NEW.kbk, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_kbk_type IS NULL
      AND OLD.id_kbk_type IS NULL)
      AND ((NEW.id_kbk_type IS NULL
      AND OLD.id_kbk_type IS NOT NULL)
      OR (NEW.id_kbk_type IS NOT NULL
      AND OLD.id_kbk_type IS NULL)
      OR (NEW.id_kbk_type <> OLD.id_kbk_type))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'id_kbk_type', OLD.id_kbk_type, NEW.id_kbk_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.target_code IS NULL
      AND OLD.target_code IS NULL)
      AND ((NEW.target_code IS NULL
      AND OLD.target_code IS NOT NULL)
      OR (NEW.target_code IS NOT NULL
      AND OLD.target_code IS NULL)
      OR (NEW.target_code <> OLD.target_code))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'target_code', OLD.target_code, NEW.target_code, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.okato <> OLD.okato) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'okato', OLD.okato, NEW.okato, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.inn_adb <> OLD.inn_adb) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'inn_adb', OLD.inn_adb, NEW.inn_adb, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.kpp_adb <> OLD.kpp_adb) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'kpp_adb', OLD.kpp_adb, NEW.kpp_adb, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_enroll_ufk IS NULL
      AND OLD.date_enroll_ufk IS NULL)
      AND ((NEW.date_enroll_ufk IS NULL
      AND OLD.date_enroll_ufk IS NOT NULL)
      OR (NEW.date_enroll_ufk IS NOT NULL
      AND OLD.date_enroll_ufk IS NULL)
      OR (NEW.date_enroll_ufk <> OLD.date_enroll_ufk))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'kumi_memorial_orders', NEW.id_order, 'date_enroll_ufk', OLD.date_enroll_ufk, NEW.date_enroll_ufk, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_memorial_orders
ADD CONSTRAINT FK_kumi_memorial_orders_id_gro FOREIGN KEY (id_group)
REFERENCES kumi_payment_groups (id_group) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_memorial_orders
ADD CONSTRAINT FK_kumi_memorial_orders_id_kbk FOREIGN KEY (id_kbk_type)
REFERENCES kumi_kbk_types (id_kbk_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `kumi_memorial_order_payment_assoc`
--
CREATE TABLE IF NOT EXISTS kumi_memorial_order_payment_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_payment int(11) NOT NULL,
  id_order int(11) NOT NULL,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2677,
AVG_ROW_LENGTH = 40,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `UK_kumi_memorial_order_payment` для объекта типа таблица `kumi_memorial_order_payment_assoc`
--
ALTER TABLE kumi_memorial_order_payment_assoc
ADD UNIQUE INDEX UK_kumi_memorial_order_payment (id_payment, id_order);

DELIMITER $$

--
-- Создать триггер `kumi_memorial_order_payment_assoc_after_insert`
--
CREATE TRIGGER kumi_memorial_order_payment_assoc_after_insert
AFTER INSERT
ON kumi_memorial_order_payment_assoc
FOR EACH ROW
BEGIN
  IF (NEW.id_assoc IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_order_payment_assoc', NEW.id_assoc, 'id_assoc', NULL, NEW.id_assoc, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_payment IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_order_payment_assoc', NEW.id_assoc, 'id_payment', NULL, NEW.id_payment, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_order IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_memorial_order_payment_assoc', NEW.id_assoc, 'id_order', NULL, NEW.id_order, 'INSERT', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_memorial_order_payment_assoc
ADD CONSTRAINT FK_kumi_memorial_order_paymen2 FOREIGN KEY (id_payment)
REFERENCES kumi_payments (id_payment) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_memorial_order_payment_assoc
ADD CONSTRAINT FK_kumi_memorial_order_payment FOREIGN KEY (id_order)
REFERENCES kumi_memorial_orders (id_order) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `payments_accounts`
--
CREATE TABLE IF NOT EXISTS payments_accounts (
  id_account int(11) NOT NULL AUTO_INCREMENT,
  account varchar(255) DEFAULT NULL COMMENT 'Лицевой счет',
  crn varchar(255) DEFAULT NULL COMMENT 'СРН',
  raw_address varchar(255) DEFAULT NULL COMMENT 'Исходный адрес',
  account_gis_zkh varchar(255) DEFAULT NULL,
  prescribed int(11) DEFAULT NULL,
  tenant varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_account)
)
ENGINE = INNODB,
AUTO_INCREMENT = 69959,
AVG_ROW_LENGTH = 192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IDX_payments_accounts_account` для объекта типа таблица `payments_accounts`
--
ALTER TABLE payments_accounts
ADD INDEX IDX_payments_accounts_account (account);

--
-- Создать индекс `IDX_payments_accounts_raw_address` для объекта типа таблица `payments_accounts`
--
ALTER TABLE payments_accounts
ADD INDEX IDX_payments_accounts_raw_address (raw_address);

--
-- Создать таблицу `payments_account_sub_premises_assoc`
--
CREATE TABLE IF NOT EXISTS payments_account_sub_premises_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_sub_premises int(11) NOT NULL,
  id_account int(11) NOT NULL,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 109058,
AVG_ROW_LENGTH = 81,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IDX_payments_account_sub_premises_id_account_id_sub_premises` для объекта типа таблица `payments_account_sub_premises_assoc`
--
ALTER TABLE payments_account_sub_premises_assoc
ADD INDEX IDX_payments_account_sub_premises_id_account_id_sub_premises (id_account, id_sub_premises);

--
-- Создать внешний ключ
--
ALTER TABLE payments_account_sub_premises_assoc
ADD CONSTRAINT FK_payments_account_sub_premises_assoc_id_sub_premises FOREIGN KEY (id_sub_premises)
REFERENCES sub_premises (id_sub_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE payments_account_sub_premises_assoc
ADD CONSTRAINT FK_payments_account_sub_premises_assoc_payments FOREIGN KEY (id_account)
REFERENCES payments_accounts (id_account) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать представление `v_payments_sub_premises_pre_address`
--
CREATE
VIEW v_payments_sub_premises_pre_address
AS
SELECT
  `tspa`.`id_account` AS `id_account`,
  `b`.`id_building` AS `id_building`,
  `vks`.`street_name` AS `street_name`,
  `vks`.`id_street` AS `id_street`,
  `b`.`house` AS `house`,
  `p`.`premises_num` AS `premises_num`,
  `sp`.`sub_premises_num` AS `sub_premises_num`,
  CONCAT(IF(ISNULL(`p`.`premises_num`), '', CONCAT(`pt`.`premises_type_short`, ' ', `p`.`premises_num`)), ', ', GROUP_CONCAT(IF(ISNULL(`sp`.`sub_premises_num`), NULL, CONCAT('ком. ', `sp`.`sub_premises_num`)) SEPARATOR ', ')) AS `premises_num_gc`
FROM (((((`registry`.`payments_account_sub_premises_assoc` `tspa`
  JOIN `registry`.`sub_premises` `sp`
    ON ((`tspa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  JOIN `registry`.`premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
  JOIN `registry`.`buildings` `b`
    ON ((`p`.`id_building` = `b`.`id_building`)))
  JOIN `registry`.`v_kladr_streets` `vks`
    ON ((`b`.`id_street` = `vks`.`id_street`)))
  JOIN `registry`.`premises_types` `pt`
    ON ((`p`.`id_premises_type` = `pt`.`id_premises_type`)))
GROUP BY `tspa`.`id_account`,
         `p`.`id_premises`;

--
-- Создать таблицу `payments_account_premises_assoc`
--
CREATE TABLE IF NOT EXISTS payments_account_premises_assoc (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_premises int(11) NOT NULL,
  id_account int(11) NOT NULL,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1409144,
AVG_ROW_LENGTH = 82,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IDX_payments_account_premises_id_account_id_premises` для объекта типа таблица `payments_account_premises_assoc`
--
ALTER TABLE payments_account_premises_assoc
ADD INDEX IDX_payments_account_premises_id_account_id_premises (id_account, id_premises);

--
-- Создать внешний ключ
--
ALTER TABLE payments_account_premises_assoc
ADD CONSTRAINT FK_payments_account_premises_assoc_id_premises FOREIGN KEY (id_premises)
REFERENCES premises (id_premises) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE payments_account_premises_assoc
ADD CONSTRAINT FK_payments_account_premises_assoc_payments_accounts_id_account FOREIGN KEY (id_account)
REFERENCES payments_accounts (id_account) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать представление `v_payments_claims_parsed_address_stage1`
--
CREATE
VIEW v_payments_claims_parsed_address_stage1
AS
SELECT
  `papa`.`id_account` AS `id_account`,
  GROUP_CONCAT(`papa`.`id_premises` ORDER BY `papa`.`id_premises` ASC SEPARATOR 'p') AS `addr`
FROM `payments_account_premises_assoc` `papa`
GROUP BY `papa`.`id_account`
UNION ALL
SELECT
  `paspa`.`id_account` AS `id_account`,
  GROUP_CONCAT(`paspa`.`id_sub_premises` ORDER BY `paspa`.`id_sub_premises` ASC SEPARATOR 'sp') AS `addr`
FROM `payments_account_sub_premises_assoc` `paspa`
GROUP BY `paspa`.`id_account`;

--
-- Создать представление `v_payments_claims_parsed_address_stage2`
--
CREATE
VIEW v_payments_claims_parsed_address_stage2
AS
SELECT
  `v`.`id_account` AS `id_account`,
  GROUP_CONCAT(`v`.`addr` ORDER BY `v`.`addr` ASC SEPARATOR 'x') AS `address`
FROM `v_payments_claims_parsed_address_stage1` `v`
GROUP BY `v`.`id_account`;

--
-- Создать представление `v_payments_buildings_address`
--
CREATE
VIEW v_payments_buildings_address
AS
SELECT
  `tpa`.`id_account` AS `id_account`,
  `b`.`id_building` AS `id_building`,
  `vks`.`id_street` AS `id_street`,
  `b`.`house` AS `house`,
  `p`.`premises_num` AS `premises_num`,
  NULL AS `sub_premises_num`,
  CONCAT(REPLACE(`vks`.`street_name`, 'жилрайон.', 'жилрайон.'), ', д. ', `b`.`house`, ', ', GROUP_CONCAT(IF(ISNULL(`p`.`premises_num`), NULL, CONCAT(`pt`.`premises_type_short`, ' ', `p`.`premises_num`)) SEPARATOR ', ')) AS `db_address`
FROM ((((`registry`.`payments_account_premises_assoc` `tpa`
  JOIN `registry`.`premises` `p`
    ON ((`tpa`.`id_premises` = `p`.`id_premises`)))
  JOIN `registry`.`buildings` `b`
    ON ((`p`.`id_building` = `b`.`id_building`)))
  JOIN `registry`.`v_kladr_streets` `vks`
    ON ((`b`.`id_street` = `vks`.`id_street`)))
  JOIN `registry`.`premises_types` `pt`
    ON ((`p`.`id_premises_type` = `pt`.`id_premises_type`)))
GROUP BY `tpa`.`id_account`,
         `b`.`id_building`
UNION ALL
SELECT
  `v`.`id_account` AS `id_account`,
  `v`.`id_building` AS `id_building`,
  `v`.`id_street` AS `id_street`,
  `v`.`house` AS `house`,
  `v`.`premises_num` AS `premises_num`,
  `v`.`sub_premises_num` AS `sub_premises_num`,
  CONCAT(REPLACE(`v`.`street_name`, 'жилрайон.', 'жилрайон.'), ', д. ', `v`.`house`, ', ', GROUP_CONCAT(IF(ISNULL(`v`.`premises_num_gc`), NULL, `v`.`premises_num_gc`) SEPARATOR ', ')) AS `db_address`
FROM `registry`.`v_payments_sub_premises_pre_address` `v`
GROUP BY `v`.`id_account`,
         `v`.`id_building`;

--
-- Создать представление `v_payments_address`
--
CREATE
VIEW v_payments_address
AS
SELECT
  `v`.`id_account` AS `id_account`,
  GROUP_CONCAT(`v`.`db_address` SEPARATOR ', ') AS `db_address`
FROM `registry`.`v_payments_buildings_address` `v`
GROUP BY `v`.`id_account`;

--
-- Создать таблицу `payments`
--
CREATE TABLE IF NOT EXISTS payments (
  id_payment int(11) NOT NULL AUTO_INCREMENT,
  id_account int(11) NOT NULL,
  date datetime NOT NULL COMMENT 'Дата, на которую заносятся данные о платежах',
  tenant varchar(255) DEFAULT NULL COMMENT 'Наниматель',
  total_area double NOT NULL COMMENT 'Общая площадь',
  living_area double NOT NULL COMMENT 'Жилая площадь',
  prescribed int(11) NOT NULL COMMENT 'Прописано',
  balance_input decimal(12, 2) NOT NULL COMMENT 'Сальдо вх',
  balance_tenancy decimal(12, 2) NOT NULL,
  balance_dgi decimal(12, 2) NOT NULL,
  balance_padun decimal(12, 2) DEFAULT 0.00,
  balance_pkk decimal(12, 2) DEFAULT 0.00,
  balance_input_penalties decimal(12, 2) DEFAULT 0.00,
  charging_tenancy decimal(12, 2) NOT NULL,
  charging_total decimal(12, 2) NOT NULL,
  charging_dgi decimal(12, 2) NOT NULL,
  charging_padun decimal(12, 2) DEFAULT 0.00,
  charging_pkk decimal(12, 2) DEFAULT 0.00,
  charging_penalties decimal(12, 2) DEFAULT 0.00,
  recalc_tenancy decimal(12, 2) NOT NULL,
  recalc_dgi decimal(12, 2) NOT NULL,
  recalc_padun decimal(12, 2) DEFAULT 0.00,
  recalc_pkk decimal(12, 2) DEFAULT 0.00,
  recalc_penalties decimal(12, 2) DEFAULT 0.00,
  payment_tenancy decimal(12, 2) NOT NULL,
  payment_dgi decimal(12, 2) NOT NULL,
  payment_padun decimal(12, 2) DEFAULT 0.00,
  payment_pkk decimal(12, 2) DEFAULT 0.00,
  payment_penalties decimal(12, 2) DEFAULT 0.00,
  transfer_balance decimal(12, 2) NOT NULL,
  balance_output_total decimal(12, 2) NOT NULL COMMENT 'Сальдо исх',
  balance_output_tenancy decimal(12, 2) NOT NULL,
  balance_output_dgi decimal(12, 2) NOT NULL,
  balance_output_padun decimal(12, 2) DEFAULT 0.00,
  balance_output_pkk decimal(12, 2) DEFAULT 0.00,
  balance_output_penalties decimal(12, 2) DEFAULT 0.00,
  PRIMARY KEY (id_payment)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1798425,
AVG_ROW_LENGTH = 153,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IDX_payments_date` для объекта типа таблица `payments`
--
ALTER TABLE payments
ADD INDEX IDX_payments_date (id_account, date);

--
-- Создать индекс `IX_payments_tenant` для объекта типа таблица `payments`
--
ALTER TABLE payments
ADD INDEX IX_payments_tenant (tenant);

--
-- Создать внешний ключ
--
ALTER TABLE payments
ADD CONSTRAINT FK_payments_payments_accounts_id_account FOREIGN KEY (id_account)
REFERENCES payments_accounts (id_account) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать представление `v_payments_max_date`
--
CREATE
VIEW v_payments_max_date
AS
SELECT
  `p`.`id_account` AS `id_account`,
  MAX(`p`.`date`) AS `date`
FROM `payments` `p`
GROUP BY `p`.`id_account`;

--
-- Создать представление `v_payments_last`
--
CREATE
VIEW v_payments_last
AS
SELECT
  `p`.`id_payment` AS `id_payment`,
  `p`.`id_account` AS `id_account`,
  `p`.`date` AS `date`,
  `p`.`tenant` AS `tenant`,
  `p`.`total_area` AS `total_area`,
  `p`.`living_area` AS `living_area`,
  `p`.`prescribed` AS `prescribed`,
  `p`.`balance_input` AS `balance_input`,
  `p`.`balance_tenancy` AS `balance_tenancy`,
  `p`.`balance_dgi` AS `balance_dgi`,
  `p`.`balance_padun` AS `balance_padun`,
  `p`.`balance_pkk` AS `balance_pkk`,
  `p`.`balance_input_penalties` AS `balance_input_penalties`,
  `p`.`charging_tenancy` AS `charging_tenancy`,
  `p`.`charging_total` AS `charging_total`,
  `p`.`charging_dgi` AS `charging_dgi`,
  `p`.`charging_padun` AS `charging_padun`,
  `p`.`charging_pkk` AS `charging_pkk`,
  `p`.`charging_penalties` AS `charging_penalties`,
  `p`.`recalc_tenancy` AS `recalc_tenancy`,
  `p`.`recalc_dgi` AS `recalc_dgi`,
  `p`.`recalc_padun` AS `recalc_padun`,
  `p`.`recalc_pkk` AS `recalc_pkk`,
  `p`.`recalc_penalties` AS `recalc_penalties`,
  `p`.`payment_tenancy` AS `payment_tenancy`,
  `p`.`payment_dgi` AS `payment_dgi`,
  `p`.`payment_padun` AS `payment_padun`,
  `p`.`payment_pkk` AS `payment_pkk`,
  `p`.`payment_penalties` AS `payment_penalties`,
  `p`.`transfer_balance` AS `transfer_balance`,
  `p`.`balance_output_total` AS `balance_output_total`,
  `p`.`balance_output_tenancy` AS `balance_output_tenancy`,
  `p`.`balance_output_dgi` AS `balance_output_dgi`,
  `p`.`balance_output_padun` AS `balance_output_padun`,
  `p`.`balance_output_pkk` AS `balance_output_pkk`,
  `p`.`balance_output_penalties` AS `balance_output_penalties`
FROM (`payments` `p`
  JOIN `v_payments_max_date` `v`
    ON (((`p`.`id_account` = `v`.`id_account`)
    AND (`p`.`date` = `v`.`date`))));

--
-- Создать представление `v_payments_account_last_fulll_info`
--
CREATE
VIEW v_payments_account_last_fulll_info
AS
SELECT
  `v`.`id_payment` AS `id_payment`,
  `v`.`id_account` AS `id_account`,
  `v`.`date` AS `date`,
  `v`.`tenant` AS `tenant`,
  `v`.`total_area` AS `total_area`,
  `v`.`living_area` AS `living_area`,
  `v`.`prescribed` AS `prescribed`,
  `v`.`balance_input` AS `balance_input`,
  `v`.`balance_tenancy` AS `balance_tenancy`,
  `v`.`balance_dgi` AS `balance_dgi`,
  `v`.`balance_input_penalties` AS `balance_input_penalties`,
  `v`.`charging_tenancy` AS `charging_tenancy`,
  `v`.`charging_total` AS `charging_total`,
  `v`.`charging_dgi` AS `charging_dgi`,
  `v`.`charging_penalties` AS `charging_penalties`,
  `v`.`recalc_tenancy` AS `recalc_tenancy`,
  `v`.`recalc_dgi` AS `recalc_dgi`,
  `v`.`recalc_penalties` AS `recalc_penalties`,
  `v`.`payment_tenancy` AS `payment_tenancy`,
  `v`.`payment_dgi` AS `payment_dgi`,
  `v`.`payment_penalties` AS `payment_penalties`,
  `v`.`transfer_balance` AS `transfer_balance`,
  `v`.`balance_output_total` AS `balance_output_total`,
  `v`.`balance_output_tenancy` AS `balance_output_tenancy`,
  `v`.`balance_output_dgi` AS `balance_output_dgi`,
  `v`.`balance_output_penalties` AS `balance_output_penalties`,
  `pa`.`crn` AS `crn`,
  `pa`.`raw_address` AS `raw_address`,
  `pa`.`account` AS `account`
FROM (`payments_accounts` `pa`
  JOIN `v_payments_last` `v`
    ON ((`pa`.`id_account` = `v`.`id_account`)));

--
-- Создать представление `v_payments_last_charging_date`
--
CREATE
VIEW v_payments_last_charging_date
AS
SELECT
  `p`.`id_account` AS `id_account`,
  MAX(`p`.`date`) AS `charging_date`
FROM `payments` `p`
WHERE (`p`.`charging_tenancy` > 0)
GROUP BY `p`.`id_account`;

--
-- Создать таблицу `payment_account_comment`
--
CREATE TABLE IF NOT EXISTS payment_account_comment (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_account int(11) DEFAULT NULL,
  comment varchar(255) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 29,
AVG_ROW_LENGTH = 1820,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE payment_account_comment
ADD CONSTRAINT FK_payment_account_comment_id_ FOREIGN KEY (id_account)
REFERENCES payments_accounts (id_account) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `claims`
--
CREATE TABLE IF NOT EXISTS claims (
  id_claim int(11) NOT NULL AUTO_INCREMENT,
  id_account int(11) DEFAULT NULL COMMENT 'Идентификатор лицевого счета',
  id_account_additional int(11) DEFAULT NULL,
  id_account_kumi int(11) DEFAULT NULL,
  at_date date DEFAULT NULL COMMENT 'Дата формирования претензии',
  start_dept_period date DEFAULT NULL COMMENT 'Началь периода задолжности',
  end_dept_period date DEFAULT NULL COMMENT 'Окончание периода задолжности',
  amount_tenancy decimal(12, 2) DEFAULT NULL COMMENT 'Сумма к взысканию найм',
  amount_dgi decimal(12, 2) DEFAULT NULL COMMENT 'Сумма к взысканию ДГИ',
  amount_padun decimal(12, 2) DEFAULT NULL COMMENT 'Сумма к взысканию Падун',
  amount_pkk decimal(12, 2) DEFAULT NULL COMMENT 'Сумма к взысканию ПКК',
  amount_penalties decimal(12, 2) DEFAULT NULL COMMENT 'Сумма к взысканию пени',
  amount_tenancy_recovered decimal(12, 2) DEFAULT NULL,
  amount_penalties_recovered decimal(12, 2) DEFAULT NULL,
  amount_dgi_recovered decimal(12, 2) DEFAULT NULL,
  amount_pkk_recovered decimal(12, 2) DEFAULT NULL,
  amount_padun_recovered decimal(12, 2) DEFAULT NULL,
  fact_amount_tenancy decimal(12, 2) DEFAULT NULL COMMENT 'Фактически высужено найм',
  fact_amount_penalties decimal(12, 2) DEFAULT NULL COMMENT 'Фактически высужено пени',
  fact_amount_dgi decimal(12, 2) DEFAULT NULL COMMENT 'Фактически высужено ДГИ',
  fact_amount_padun decimal(12, 2) DEFAULT NULL COMMENT 'Фактически высжуено Падун',
  fact_amount_pkk decimal(12, 2) DEFAULT NULL COMMENT 'Фактически высужено ПКК',
  description text DEFAULT NULL COMMENT 'Примечание',
  last_account_balance_output decimal(12, 2) DEFAULT 0.00,
  ended_for_filter tinyint(1) DEFAULT 0,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_claim)
)
ENGINE = INNODB,
AUTO_INCREMENT = 11744,
AVG_ROW_LENGTH = 1365,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Претензии и иски';

DELIMITER $$

--
-- Создать триггер `claims_after_insert`
--
CREATE TRIGGER claims_after_insert
AFTER INSERT
ON claims
FOR EACH ROW
BEGIN
  IF (NEW.id_account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'id_account', NULL, NEW.id_account, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_account_additional IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'id_account_additional', NULL, NEW.id_account_additional, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_account_kumi IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'id_account_kumi', NULL, NEW.id_account_kumi, 'INSERT', NOW(), USER());

    IF (EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account = NEW.id_account_kumi
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = CONCAT('К лицевому счету привязана исковая работа № ', NEW.id_claim)
      WHERE ka.id_account = NEW.id_account_kumi;
    END IF;

  END IF;
  IF (NEW.amount_tenancy IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'amount_tenancy', NULL, NEW.amount_tenancy, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_penalties IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'amount_penalties', NULL, NEW.amount_penalties, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_dgi IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'amount_dgi', NULL, NEW.amount_dgi, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_pkk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'amount_pkk', NULL, NEW.amount_pkk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_padun IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'amount_padun', NULL, NEW.amount_padun, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_tenancy_recovered IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'amount_tenancy_recovered', NULL, NEW.amount_tenancy_recovered, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_penalties_recovered IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'amount_penalties_recovered', NULL, NEW.amount_penalties_recovered, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_dgi_recovered IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'amount_dgi_recovered', NULL, NEW.amount_dgi_recovered, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_pkk_recovered IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'amount_pkk_recovered', NULL, NEW.amount_pkk_recovered, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.amount_padun_recovered IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'amount_padun_recovered', NULL, NEW.amount_padun_recovered, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.fact_amount_tenancy IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'fact_amount_tenancy', NULL, NEW.fact_amount_tenancy, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.fact_amount_penalties IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'fact_amount_penalties', NULL, NEW.fact_amount_penalties, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.fact_amount_dgi IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'fact_amount_dgi', NULL, NEW.fact_amount_dgi, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.fact_amount_padun IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'fact_amount_padun', NULL, NEW.fact_amount_padun, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.fact_amount_pkk IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'fact_amount_pkk', NULL, NEW.fact_amount_pkk, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.at_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'at_date', NULL, NEW.at_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.start_dept_period IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'start_dept_period', NULL, NEW.start_dept_period, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.end_dept_period IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'end_dept_period', NULL, NEW.end_dept_period, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.ended_for_filter IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'ended_for_filter', NULL, NEW.ended_for_filter, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.last_account_balance_output IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'last_account_balance_output', NULL, NEW.last_account_balance_output, 'INSERT', NOW(), USER());
  END IF;


END
$$

--
-- Создать триггер `claims_after_update`
--
CREATE TRIGGER claims_after_update
AFTER UPDATE
ON claims
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claims', NEW.id_claim, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());

    IF (NEW.id_account_kumi IS NOT NULL
      AND EXISTS (SELECT
          *
        FROM kumi_accounts ka
          INNER JOIN kumi_charges kc
            ON ka.id_account = kc.id_account
        WHERE ka.id_state <> 2
        AND ka.id_account = NEW.id_account_kumi
        AND ka.deleted <> 1)) THEN
      UPDATE kumi_accounts ka
      SET ka.recalc_marker = 1,
          ka.recalc_reason = CONCAT('Удаление исковой работы № ', NEW.id_claim)
      WHERE ka.id_account = NEW.id_account_kumi;
    END IF;
  ELSE
    IF (NOT (NEW.id_account IS NULL
      AND OLD.id_account IS NULL)
      AND ((NEW.id_account IS NULL
      AND OLD.id_account IS NOT NULL)
      OR (NEW.id_account IS NOT NULL
      AND OLD.id_account IS NULL)
      OR (NEW.id_account <> OLD.id_account))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'id_account', OLD.id_account, NEW.id_account, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_account_additional IS NULL
      AND OLD.id_account_additional IS NULL)
      AND ((NEW.id_account_additional IS NULL
      AND OLD.id_account_additional IS NOT NULL)
      OR (NEW.id_account_additional IS NOT NULL
      AND OLD.id_account_additional IS NULL)
      OR (NEW.id_account_additional <> OLD.id_account_additional))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'id_account_additional', OLD.id_account_additional, NEW.id_account_additional, 'UPDATE', NOW(), USER());
    END IF;

    IF (NOT (NEW.start_dept_period IS NULL
      AND OLD.start_dept_period IS NULL)
      AND ((NEW.start_dept_period IS NULL
      AND OLD.start_dept_period IS NOT NULL)
      OR (NEW.start_dept_period IS NOT NULL
      AND OLD.start_dept_period IS NULL)
      OR (NEW.start_dept_period <> OLD.start_dept_period))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'start_dept_period', OLD.start_dept_period, NEW.start_dept_period, 'UPDATE', NOW(), USER());

      IF (EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = NEW.id_account_kumi
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = CONCAT('В исковой работе № ', NEW.id_claim, ' изменен предъявленный период')
        WHERE ka.id_account = NEW.id_account_kumi;
      END IF;

    END IF;
    IF (NOT (NEW.end_dept_period IS NULL
      AND OLD.end_dept_period IS NULL)
      AND ((NEW.end_dept_period IS NULL
      AND OLD.end_dept_period IS NOT NULL)
      OR (NEW.end_dept_period IS NOT NULL
      AND OLD.end_dept_period IS NULL)
      OR (NEW.end_dept_period <> OLD.end_dept_period))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'end_dept_period', OLD.end_dept_period, NEW.end_dept_period, 'UPDATE', NOW(), USER());

      IF (EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = NEW.id_account_kumi
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = CONCAT('В исковой работе № ', NEW.id_claim, ' изменен предъявленный период')
        WHERE ka.id_account = NEW.id_account_kumi;
      END IF;
    END IF;

    IF (NOT (NEW.id_account_kumi IS NULL
      AND OLD.id_account_kumi IS NULL)
      AND ((NEW.id_account_kumi IS NULL
      AND OLD.id_account_kumi IS NOT NULL)
      OR (NEW.id_account_kumi IS NOT NULL
      AND OLD.id_account_kumi IS NULL)
      OR (NEW.id_account_kumi <> OLD.id_account_kumi))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'id_account_kumi', OLD.id_account_kumi, NEW.id_account_kumi, 'UPDATE', NOW(), USER());

      INSERT INTO claims_kumi_accounts_history (id_claim, id_account)
        VALUES (NEW.id_claim, NEW.id_account_kumi);

      IF (OLD.id_account_kumi IS NOT NULL
        AND EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = OLD.id_account_kumi
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = CONCAT('От лицевого счета отвязана исковая работа № ', OLD.id_claim)
        WHERE ka.id_account = OLD.id_account_kumi;
      END IF;

      IF (NEW.id_account_kumi IS NOT NULL
        AND EXISTS (SELECT
            *
          FROM kumi_accounts ka
            INNER JOIN kumi_charges kc
              ON ka.id_account = kc.id_account
          WHERE ka.id_state <> 2
          AND ka.id_account = NEW.id_account_kumi
          AND ka.deleted <> 1)) THEN
        UPDATE kumi_accounts ka
        SET ka.recalc_marker = 1,
            ka.recalc_reason = CONCAT('К лицевому счету привязана исковая работа № ', NEW.id_claim)
        WHERE ka.id_account = NEW.id_account_kumi;
      END IF;

    END IF;

    IF (NOT (NEW.amount_tenancy IS NULL
      AND OLD.amount_tenancy IS NULL)
      AND ((NEW.amount_tenancy IS NULL
      AND OLD.amount_tenancy IS NOT NULL)
      OR (NEW.amount_tenancy IS NOT NULL
      AND OLD.amount_tenancy IS NULL)
      OR (NEW.amount_tenancy <> OLD.amount_tenancy))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'amount_tenancy', OLD.amount_tenancy, NEW.amount_tenancy, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.amount_penalties IS NULL
      AND OLD.amount_penalties IS NULL)
      AND ((NEW.amount_penalties IS NULL
      AND OLD.amount_penalties IS NOT NULL)
      OR (NEW.amount_penalties IS NOT NULL
      AND OLD.amount_penalties IS NULL)
      OR (NEW.amount_penalties <> OLD.amount_penalties))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'amount_penalties', OLD.amount_penalties, NEW.amount_penalties, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.amount_dgi IS NULL
      AND OLD.amount_dgi IS NULL)
      AND ((NEW.amount_dgi IS NULL
      AND OLD.amount_dgi IS NOT NULL)
      OR (NEW.amount_dgi IS NOT NULL
      AND OLD.amount_dgi IS NULL)
      OR (NEW.amount_dgi <> OLD.amount_dgi))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'amount_dgi', OLD.amount_dgi, NEW.amount_dgi, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.amount_pkk IS NULL
      AND OLD.amount_pkk IS NULL)
      AND ((NEW.amount_pkk IS NULL
      AND OLD.amount_pkk IS NOT NULL)
      OR (NEW.amount_pkk IS NOT NULL
      AND OLD.amount_pkk IS NULL)
      OR (NEW.amount_pkk <> OLD.amount_pkk))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'amount_pkk', OLD.amount_pkk, NEW.amount_pkk, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.amount_padun IS NULL
      AND OLD.amount_padun IS NULL)
      AND ((NEW.amount_padun IS NULL
      AND OLD.amount_padun IS NOT NULL)
      OR (NEW.amount_padun IS NOT NULL
      AND OLD.amount_padun IS NULL)
      OR (NEW.amount_padun <> OLD.amount_padun))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'amount_padun', OLD.amount_padun, NEW.amount_padun, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.amount_tenancy_recovered IS NULL
      AND OLD.amount_tenancy_recovered IS NULL)
      AND ((NEW.amount_tenancy_recovered IS NULL
      AND OLD.amount_tenancy_recovered IS NOT NULL)
      OR (NEW.amount_tenancy_recovered IS NOT NULL
      AND OLD.amount_tenancy_recovered IS NULL)
      OR (NEW.amount_tenancy_recovered <> OLD.amount_tenancy_recovered))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'amount_tenancy_recovered', OLD.amount_tenancy_recovered, NEW.amount_tenancy_recovered, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.amount_penalties_recovered IS NULL
      AND OLD.amount_penalties_recovered IS NULL)
      AND ((NEW.amount_penalties_recovered IS NULL
      AND OLD.amount_penalties_recovered IS NOT NULL)
      OR (NEW.amount_penalties_recovered IS NOT NULL
      AND OLD.amount_penalties_recovered IS NULL)
      OR (NEW.amount_penalties_recovered <> OLD.amount_penalties_recovered))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'amount_penalties_recovered', OLD.amount_penalties_recovered, NEW.amount_penalties_recovered, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.amount_dgi_recovered IS NULL
      AND OLD.amount_dgi_recovered IS NULL)
      AND ((NEW.amount_dgi_recovered IS NULL
      AND OLD.amount_dgi_recovered IS NOT NULL)
      OR (NEW.amount_dgi_recovered IS NOT NULL
      AND OLD.amount_dgi_recovered IS NULL)
      OR (NEW.amount_dgi_recovered <> OLD.amount_dgi_recovered))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'amount_dgi_recovered', OLD.amount_dgi_recovered, NEW.amount_dgi_recovered, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.amount_pkk_recovered IS NULL
      AND OLD.amount_pkk_recovered IS NULL)
      AND ((NEW.amount_pkk_recovered IS NULL
      AND OLD.amount_pkk_recovered IS NOT NULL)
      OR (NEW.amount_pkk_recovered IS NOT NULL
      AND OLD.amount_pkk_recovered IS NULL)
      OR (NEW.amount_pkk_recovered <> OLD.amount_pkk_recovered))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'amount_pkk_recovered', OLD.amount_pkk_recovered, NEW.amount_pkk_recovered, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.amount_padun_recovered IS NULL
      AND OLD.amount_padun_recovered IS NULL)
      AND ((NEW.amount_padun_recovered IS NULL
      AND OLD.amount_padun_recovered IS NOT NULL)
      OR (NEW.amount_padun_recovered IS NOT NULL
      AND OLD.amount_padun_recovered IS NULL)
      OR (NEW.amount_padun_recovered <> OLD.amount_padun_recovered))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'amount_padun_recovered', OLD.amount_padun_recovered, NEW.amount_padun_recovered, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.fact_amount_tenancy IS NULL
      AND OLD.fact_amount_tenancy IS NULL)
      AND ((NEW.fact_amount_tenancy IS NULL
      AND OLD.fact_amount_tenancy IS NOT NULL)
      OR (NEW.fact_amount_tenancy IS NOT NULL
      AND OLD.fact_amount_tenancy IS NULL)
      OR (NEW.fact_amount_tenancy <> OLD.fact_amount_tenancy))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'fact_amount_tenancy', OLD.fact_amount_tenancy, NEW.fact_amount_tenancy, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.fact_amount_penalties IS NULL
      AND OLD.fact_amount_penalties IS NULL)
      AND ((NEW.fact_amount_penalties IS NULL
      AND OLD.fact_amount_penalties IS NOT NULL)
      OR (NEW.fact_amount_penalties IS NOT NULL
      AND OLD.fact_amount_penalties IS NULL)
      OR (NEW.fact_amount_penalties <> OLD.fact_amount_penalties))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'fact_amount_penalties', OLD.fact_amount_penalties, NEW.fact_amount_penalties, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.fact_amount_dgi IS NULL
      AND OLD.fact_amount_dgi IS NULL)
      AND ((NEW.fact_amount_dgi IS NULL
      AND OLD.fact_amount_dgi IS NOT NULL)
      OR (NEW.fact_amount_dgi IS NOT NULL
      AND OLD.fact_amount_dgi IS NULL)
      OR (NEW.fact_amount_dgi <> OLD.fact_amount_dgi))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'fact_amount_dgi', OLD.fact_amount_dgi, NEW.fact_amount_dgi, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.fact_amount_padun IS NULL
      AND OLD.fact_amount_padun IS NULL)
      AND ((NEW.fact_amount_padun IS NULL
      AND OLD.fact_amount_padun IS NOT NULL)
      OR (NEW.fact_amount_padun IS NOT NULL
      AND OLD.fact_amount_padun IS NULL)
      OR (NEW.fact_amount_padun <> OLD.fact_amount_padun))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'fact_amount_padun', OLD.fact_amount_padun, NEW.fact_amount_padun, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.fact_amount_pkk IS NULL
      AND OLD.fact_amount_pkk IS NULL)
      AND ((NEW.fact_amount_pkk IS NULL
      AND OLD.fact_amount_pkk IS NOT NULL)
      OR (NEW.fact_amount_pkk IS NOT NULL
      AND OLD.fact_amount_pkk IS NULL)
      OR (NEW.fact_amount_pkk <> OLD.fact_amount_pkk))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'fact_amount_pkk', OLD.fact_amount_pkk, NEW.fact_amount_pkk, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.at_date IS NULL
      AND OLD.at_date IS NULL)
      AND ((NEW.at_date IS NULL
      AND OLD.at_date IS NOT NULL)
      OR (NEW.at_date IS NOT NULL
      AND OLD.at_date IS NULL)
      OR (NEW.at_date <> OLD.at_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'at_date', OLD.at_date, NEW.at_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.ended_for_filter IS NULL
      AND OLD.ended_for_filter IS NULL)
      AND ((NEW.ended_for_filter IS NULL
      AND OLD.ended_for_filter IS NOT NULL)
      OR (NEW.ended_for_filter IS NOT NULL
      AND OLD.ended_for_filter IS NULL)
      OR (NEW.ended_for_filter <> OLD.ended_for_filter))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'ended_for_filter', OLD.ended_for_filter, NEW.ended_for_filter, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.last_account_balance_output IS NULL
      AND OLD.last_account_balance_output IS NULL)
      AND ((NEW.last_account_balance_output IS NULL
      AND OLD.last_account_balance_output IS NOT NULL)
      OR (NEW.last_account_balance_output IS NOT NULL
      AND OLD.last_account_balance_output IS NULL)
      OR (NEW.last_account_balance_output <> OLD.last_account_balance_output))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'claims', NEW.id_claim, 'last_account_balance_output', OLD.last_account_balance_output, NEW.last_account_balance_output, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `claims_before_insert`
--
CREATE TRIGGER claims_before_insert
BEFORE INSERT
ON claims
FOR EACH ROW
BEGIN
END
$$

--
-- Создать триггер `claims_before_update`
--
CREATE TRIGGER claims_before_update
BEFORE UPDATE
ON claims
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    UPDATE claim_states
    SET deleted = 1
    WHERE id_claim = NEW.id_claim;
    UPDATE claim_persons
    SET deleted = 1
    WHERE id_claim = NEW.id_claim;
    UPDATE claim_court_orders
    SET deleted = 1
    WHERE id_claim = NEW.id_claim;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE claims
ADD CONSTRAINT FK_claims_id_account_additional FOREIGN KEY (id_account_additional)
REFERENCES payments_accounts (id_account) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE claims
ADD CONSTRAINT FK_claims_id_account_kumi FOREIGN KEY (id_account_kumi)
REFERENCES kumi_accounts (id_account) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE claims
ADD CONSTRAINT FK_claims_payments_accounts_id_account FOREIGN KEY (id_account)
REFERENCES payments_accounts (id_account) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE claim_court_orders
ADD CONSTRAINT FK_claim_court_orders_id_claim FOREIGN KEY (id_claim)
REFERENCES claims (id_claim) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE claim_persons
ADD CONSTRAINT FK_claims_persons_id_claim FOREIGN KEY (id_claim)
REFERENCES claims (id_claim) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE claim_states
ADD CONSTRAINT FK_claim_states_claims_id_claim FOREIGN KEY (id_claim)
REFERENCES claims (id_claim) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE claims_kumi_accounts_history
ADD CONSTRAINT FK_claims_kumi_accounts_histor FOREIGN KEY (id_claim)
REFERENCES claims (id_claim) ON DELETE NO ACTION ON UPDATE CASCADE;

DELIMITER $$

--
-- Создать процедуру `recalc_claims_last_account_balance_output`
--
CREATE PROCEDURE recalc_claims_last_account_balance_output ()
BEGIN
  CREATE TEMPORARY TABLE p_address_tmp_1 (
    id_account int PRIMARY KEY,
    db_address varchar(1024)
  );
  INSERT INTO p_address_tmp_1
    SELECT
      vpa.id_account,
      CAST(vpa.db_address AS char(1024)) AS db_address
    FROM v_payments_address vpa;
  CREATE INDEX p_address_tmp_idx_1_1 ON p_address_tmp_1 (db_address);
  CREATE INDEX p_address_tmp_idx_1_2 ON p_address_tmp_1 (id_account);

  CREATE TEMPORARY TABLE p_address_tmp_2 (
    id_account int PRIMARY KEY,
    db_address varchar(1024)
  );
  INSERT INTO p_address_tmp_2
    SELECT
      vpa.id_account,
      CAST(vpa.db_address AS char(1024)) AS db_address
    FROM v_payments_address vpa;
  CREATE INDEX p_address_tmp_idx_2_1 ON p_address_tmp_2 (db_address);
  CREATE INDEX p_address_tmp_idx_2_2 ON p_address_tmp_2 (id_account);

  CREATE TEMPORARY TABLE p_balance_tmp
  AS
  SELECT
    v.id_claim,
    IFNULL(v.balance_output_total, v.balance_output_total_self) AS balance_output_total
  FROM (SELECT
      c.id_claim,
      (SELECT
          p.balance_output_total
        FROM p_address_tmp_2 vpa1
          JOIN payments p
            ON vpa1.id_account = p.id_account
        WHERE vpa1.db_address = vpa.db_address
        ORDER BY p.date DESC, p.id_account DESC
        LIMIT 1) AS balance_output_total,
      (SELECT
          p.balance_output_total
        FROM payments p
        WHERE p.id_account = c.id_account
        ORDER BY p.date DESC, p.id_account DESC
        LIMIT 1) AS balance_output_total_self
    FROM claims c
      LEFT JOIN p_address_tmp_1 vpa
        ON c.id_account = vpa.id_account
    WHERE c.deleted = 0) v;

  UPDATE claims c
  SET c.last_account_balance_output = (SELECT
      pbt.balance_output_total
    FROM p_balance_tmp pbt
    WHERE c.id_claim = pbt.id_claim)
  WHERE c.deleted = 0;

  DROP TABLE p_balance_tmp;
  DROP TABLE p_address_tmp_1;
  DROP TABLE p_address_tmp_2;
END
$$

--
-- Создать процедуру `payments_processing`
--
CREATE PROCEDURE payments_processing (IN payments_date timestamp)
BEGIN
  DECLARE account_prop varchar(255);
  DECLARE account_gis_zkh_prop varchar(255);
  DECLARE crn_prop varchar(255);
  DECLARE raw_address_prop varchar(255);
  DECLARE id_account_prop int;
  DECLARE id_sub_premises_list varchar(255);
  DECLARE id_sub_premises_current varchar(255);
  DECLARE id_premises_list varchar(255);
  DECLARE id_premises_current varchar(255);
  DECLARE done integer DEFAULT 0;
  DECLARE cursor_accounts_valid CURSOR FOR
  SELECT DISTINCT
    v.account,
    v.account_gis_zkh,
    v.crn,
    v.raw_address
  FROM _valid v;
  DECLARE cursor_accounts_invalid CURSOR FOR
  SELECT DISTINCT
    v.account,
    v.account_gis_zkh,
    v.crn,
    v.raw_address
  FROM _invalid v;
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
  START TRANSACTION;
    DELETE
      FROM payments
    WHERE `date` = payments_date;
    OPEN cursor_accounts_valid;
  circle1:
    WHILE done = 0 DO
      FETCH cursor_accounts_valid INTO account_prop, account_gis_zkh_prop, crn_prop, raw_address_prop;
      IF (done = 1) THEN
        LEAVE circle1;
      END IF;
      SET id_account_prop = NULL;
      SET id_account_prop = (SELECT
          pa.id_account
        FROM payments_accounts pa
        WHERE pa.account = account_prop);
      IF (id_account_prop IS NULL) THEN
        INSERT INTO payments_accounts (account, crn, raw_address, account_gis_zkh)
          VALUES (account_prop, crn_prop, raw_address_prop, account_gis_zkh_prop);
        SET id_account_prop = LAST_INSERT_ID();
      ELSE
        UPDATE payments_accounts pa
        SET pa.crn = crn_prop,
            pa.raw_address = raw_address_prop,
            pa.account_gis_zkh = account_gis_zkh_prop
        WHERE pa.id_account = id_account_prop;
        IF (id_account_prop NOT IN (68509)) THEN
          DELETE
            FROM payments_account_premises_assoc
          WHERE id_account = id_account_prop;
          DELETE
            FROM payments_account_sub_premises_assoc
          WHERE id_account = id_account_prop;
        END IF;
      END IF;
      -- insert sub_premises from _valid
      IF (id_account_prop NOT IN (68509)
        AND EXISTS (SELECT
            v.id_sub_premises
          FROM _valid v
          WHERE v.account = account_prop
          AND v.id_sub_premises IS NOT NULL
          AND v.id_sub_premises <> '')) THEN
      BEGIN
        DECLARE cursor_sub_premises CURSOR FOR
        SELECT
          v.id_sub_premises
        FROM _valid v
        WHERE v.account = account_prop
        AND v.id_sub_premises IS NOT NULL
        AND v.id_sub_premises <> '';
        OPEN cursor_sub_premises;
      circle_sub_premises:
        WHILE done = 0 DO
          FETCH cursor_sub_premises INTO id_sub_premises_list;
          IF (done = 1) THEN
            LEAVE circle_sub_premises;
          END IF;
          WHILE id_sub_premises_list <> '' DO
            SET id_sub_premises_current =
            SUBSTRING(id_sub_premises_list, 1, LOCATE(',', id_sub_premises_list) - 1);
            IF (id_sub_premises_current = '') THEN
              SET id_sub_premises_current = id_sub_premises_list;
              SET id_sub_premises_list = '';
            ELSE
              SET id_sub_premises_list =
              SUBSTRING(id_sub_premises_list, LOCATE(',', id_sub_premises_list) + 1);
            END IF;
            INSERT INTO payments_account_sub_premises_assoc (id_sub_premises, id_account)
              VALUES (id_sub_premises_current, id_account_prop);
          END WHILE;
        END WHILE;
        CLOSE cursor_sub_premises;
        SET done = 0;
      END;
      END IF;
      -- insert premises from _valid
      IF (id_account_prop NOT IN (68509)
        AND EXISTS (SELECT
            v.id_premises_valid
          FROM _valid v
          WHERE v.account = account_prop
          AND (v.id_sub_premises IS NULL
          OR v.id_sub_premises = '')
          AND v.id_premises_valid IS NOT NULL
          AND v.id_premises_valid <> '')) THEN
      BEGIN
        DECLARE cursor_premises CURSOR FOR
        SELECT
          v.id_premises_valid
        FROM _valid v
        WHERE v.account = account_prop
        AND (v.id_sub_premises IS NULL
        OR v.id_sub_premises = '')
        AND v.id_premises_valid IS NOT NULL
        AND v.id_premises_valid <> '';
        OPEN cursor_premises;
      circle_premises:
        WHILE done = 0 DO
          FETCH cursor_premises INTO id_premises_list;
          IF (done = 1) THEN
            LEAVE circle_premises;
          END IF;
          WHILE id_premises_list <> '' DO
            SET id_premises_current =
            SUBSTRING(id_premises_list, 1, LOCATE(',', id_premises_list) - 1);
            IF (id_premises_current = '') THEN
              SET id_premises_current = id_premises_list;
              SET id_premises_list = '';
            ELSE
              SET id_premises_list =
              SUBSTRING(id_premises_list, LOCATE(',', id_premises_list) + 1);
            END IF;
            INSERT INTO payments_account_premises_assoc (id_premises, id_account)
              VALUES (id_premises_current, id_account_prop);
          END WHILE;
        END WHILE;
        CLOSE cursor_premises;
        SET done = 0;
      END;
      END IF;
      -- insert payments from _valid
      INSERT INTO payments (id_account, date, tenant, total_area, living_area, prescribed,
      balance_input, balance_tenancy, balance_dgi, balance_padun, balance_pkk, balance_input_penalties,
      charging_tenancy, charging_total, charging_dgi, charging_padun, charging_pkk, charging_penalties,
      recalc_tenancy, recalc_dgi, recalc_padun, recalc_pkk, recalc_penalties,
      payment_tenancy, payment_dgi, payment_padun, payment_pkk, payment_penalties,
      transfer_balance,
      balance_output_total, balance_output_tenancy, balance_output_dgi,
      balance_output_padun, balance_output_pkk,
      balance_output_penalties)
        SELECT
          id_account_prop,
          payments_date,
          v.tenant,
          REPLACE(v.total_area, ',', '.'),
          REPLACE(v.living_area, ',', '.'),
          v.prescribed,
          REPLACE(v.balance_input, ',', '.'),
          REPLACE(v.balance_tenancy, ',', '.'),
          REPLACE(v.balance_dgi, ',', '.'),
          REPLACE(v.balance_padun, ',', '.'),
          REPLACE(v.balance_pkk, ',', '.'),
          REPLACE(v.balance_input_penalties, ',', '.'),
          REPLACE(v.charging_tenancy, ',', '.'),
          REPLACE(v.charging_total, ',', '.'),
          REPLACE(v.charging_dgi, ',', '.'),
          REPLACE(v.charging_padun, ',', '.'),
          REPLACE(v.charging_pkk, ',', '.'),
          REPLACE(v.charging_penalties, ',', '.'),
          REPLACE(v.recalc_tenancy, ',', '.'),
          REPLACE(v.recalc_dgi, ',', '.'),
          REPLACE(v.recalc_padun, ',', '.'),
          REPLACE(v.recalc_pkk, ',', '.'),
          REPLACE(v.recalc_penalties, ',', '.'),
          REPLACE(v.payment_tenancy, ',', '.'),
          REPLACE(v.payment_dgi, ',', '.'),
          REPLACE(v.payment_padun, ',', '.'),
          REPLACE(v.payment_pkk, ',', '.'),
          REPLACE(v.payment_penalties, ',', '.'),
          REPLACE(v.transfer_balance, ',', '.'),
          REPLACE(v.balance_output_total, ',', '.'),
          REPLACE(v.balance_output_tenancy, ',', '.'),
          REPLACE(v.balance_output_dgi, ',', '.'),
          REPLACE(v.balance_output_padun, ',', '.'),
          REPLACE(v.balance_output_pkk, ',', '.'),
          REPLACE(v.balance_output_penalties, ',', '.')
        FROM _valid v
        WHERE v.account = account_prop
        LIMIT 1;
    END WHILE;
    CLOSE cursor_accounts_valid;
    SET done = 0;
    OPEN cursor_accounts_invalid;
  circle2:
    WHILE done = 0 DO
      FETCH cursor_accounts_invalid INTO account_prop, account_gis_zkh_prop, crn_prop, raw_address_prop;
      IF (done = 1) THEN
        LEAVE circle2;
      END IF;
      SET id_account_prop = NULL;
      SET id_account_prop = (SELECT
          pa.id_account
        FROM payments_accounts pa
        WHERE pa.account = account_prop);
      IF (id_account_prop IS NULL) THEN
        INSERT INTO payments_accounts (account, crn, raw_address, account_gis_zkh)
          VALUES (account_prop, crn_prop, raw_address_prop, account_gis_zkh_prop);
        SET id_account_prop = LAST_INSERT_ID();
      ELSE
        UPDATE payments_accounts pa
        SET pa.crn = crn_prop,
            pa.raw_address = raw_address_prop,
            pa.account_gis_zkh = account_gis_zkh_prop
        WHERE pa.id_account = id_account_prop;
      END IF;
      -- insert payments from _invalid
      INSERT INTO payments (id_account, date, tenant, total_area, living_area, prescribed,
      balance_input, balance_tenancy, balance_dgi, balance_padun, balance_pkk, balance_input_penalties,
      charging_tenancy, charging_total, charging_dgi, charging_padun, charging_pkk, charging_penalties,
      recalc_tenancy, recalc_dgi, recalc_padun, recalc_pkk, recalc_penalties,
      payment_tenancy, payment_dgi, payment_padun, payment_pkk, payment_penalties,
      transfer_balance,
      balance_output_total, balance_output_tenancy, balance_output_dgi,
      balance_output_padun, balance_output_pkk,
      balance_output_penalties)
        SELECT
          id_account_prop,
          payments_date,
          v.tenant,
          REPLACE(v.total_area, ',', '.'),
          REPLACE(v.living_area, ',', '.'),
          v.prescribed,
          REPLACE(v.balance_input, ',', '.'),
          REPLACE(v.balance_tenancy, ',', '.'),
          REPLACE(v.balance_dgi, ',', '.'),
          REPLACE(v.balance_padun, ',', '.'),
          REPLACE(v.balance_pkk, ',', '.'),
          REPLACE(v.balance_input_penalties, ',', '.'),
          REPLACE(v.charging_tenancy, ',', '.'),
          REPLACE(v.charging_total, ',', '.'),
          REPLACE(v.charging_dgi, ',', '.'),
          REPLACE(v.charging_padun, ',', '.'),
          REPLACE(v.charging_pkk, ',', '.'),
          REPLACE(v.charging_penalties, ',', '.'),
          REPLACE(v.recalc_tenancy, ',', '.'),
          REPLACE(v.recalc_dgi, ',', '.'),
          REPLACE(v.recalc_padun, ',', '.'),
          REPLACE(v.recalc_pkk, ',', '.'),
          REPLACE(v.recalc_penalties, ',', '.'),
          REPLACE(v.payment_tenancy, ',', '.'),
          REPLACE(v.payment_dgi, ',', '.'),
          REPLACE(v.payment_padun, ',', '.'),
          REPLACE(v.payment_pkk, ',', '.'),
          REPLACE(v.payment_penalties, ',', '.'),
          REPLACE(v.transfer_balance, ',', '.'),
          REPLACE(v.balance_output_total, ',', '.'),
          REPLACE(v.balance_output_tenancy, ',', '.'),
          REPLACE(v.balance_output_dgi, ',', '.'),
          REPLACE(v.balance_output_padun, ',', '.'),
          REPLACE(v.balance_output_pkk, ',', '.'),
          REPLACE(v.balance_output_penalties, ',', '.')
        FROM _invalid v
        WHERE v.account = account_prop
        LIMIT 1;
    END WHILE;
    CLOSE cursor_accounts_invalid;

    INSERT INTO payments_account_premises_assoc (id_premises, id_account)
      SELECT
        pae.id_premise,
        pa.id_account
      FROM payments_accounts pa
        INNER JOIN payments_address_exceptions pae
          ON pa.raw_address = pae.raw_address
      WHERE NOT EXISTS (SELECT
          *
        FROM payments_account_premises_assoc papa
        WHERE papa.id_account = pa.id_account)
      AND NOT EXISTS (SELECT
          *
        FROM payments_account_sub_premises_assoc paspa
        WHERE paspa.id_account = pa.id_account)
      AND pae.id_sub_premise IS NULL;

    INSERT INTO payments_account_sub_premises_assoc (id_sub_premises, id_account)
      SELECT
        pae.id_sub_premise,
        pa.id_account
      FROM payments_accounts pa
        INNER JOIN payments_address_exceptions pae
          ON pa.raw_address = pae.raw_address
      WHERE NOT EXISTS (SELECT
          *
        FROM payments_account_premises_assoc papa
        WHERE papa.id_account = pa.id_account)
      AND NOT EXISTS (SELECT
          *
        FROM payments_account_sub_premises_assoc paspa
        WHERE paspa.id_account = pa.id_account)
      AND pae.id_premise IS NULL;

  COMMIT;
  CALL recalc_claims_last_account_balance_output();
END
$$

DELIMITER ;

--
-- Создать представление `v_payments_claims_info`
--
CREATE
VIEW v_payments_claims_info
AS
SELECT
  `c`.`id_claim` AS `id_claim`,
  `c`.`id_account` AS `id_account`,
  `cs`.`id_state_type` AS `id_state_type`,
  `pa`.`account` AS `account`,
  `pa`.`raw_address` AS `raw_address`
FROM ((`claims` `c`
  LEFT JOIN `v_payments_claims_last_state` `cs`
    ON ((`c`.`id_claim` = `cs`.`id_claim`)))
  JOIN `payments_accounts` `pa`
    ON ((`c`.`id_account` = `pa`.`id_account`)))
WHERE (`c`.`deleted` <> 1);

--
-- Создать таблицу `uin_for_claim_statement_in_ssp`
--
CREATE TABLE IF NOT EXISTS uin_for_claim_statement_in_ssp (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_claim int(11) NOT NULL,
  id_person int(11) DEFAULT NULL,
  uin varchar(25) NOT NULL,
  status_sending tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1772,
AVG_ROW_LENGTH = 83,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'хранение УИН по ПИР';

--
-- Создать внешний ключ
--
ALTER TABLE uin_for_claim_statement_in_ssp
ADD CONSTRAINT FK_uin_for_claim_statement_in2 FOREIGN KEY (id_person)
REFERENCES claim_persons (id_person) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE uin_for_claim_statement_in_ssp
ADD CONSTRAINT FK_uin_for_claim_statement_in_ FOREIGN KEY (id_claim)
REFERENCES claims (id_claim) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `log_claim_statement_in_ssp`
--
CREATE TABLE IF NOT EXISTS log_claim_statement_in_ssp (
  id int(11) NOT NULL AUTO_INCREMENT,
  executor_login varchar(255) DEFAULT NULL,
  create_date date NOT NULL,
  id_claim int(11) NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1381,
AVG_ROW_LENGTH = 78,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'хранение факта формирования заявления в ССП';

--
-- Создать внешний ключ
--
ALTER TABLE log_claim_statement_in_ssp
ADD CONSTRAINT FK_log_claim_statement_in_ssp_ FOREIGN KEY (id_claim)
REFERENCES claims (id_claim) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `kumi_payments_untied`
--
CREATE TABLE IF NOT EXISTS kumi_payments_untied (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  id_payment int(11) NOT NULL,
  id_charge int(11) NOT NULL,
  id_claim int(11) DEFAULT NULL,
  tied_date date NOT NULL,
  untied_date date NOT NULL,
  tenancy_value decimal(12, 2) NOT NULL,
  penalty_value decimal(12, 2) NOT NULL,
  dgi_value decimal(12, 2) NOT NULL,
  pkk_value decimal(12, 2) NOT NULL,
  padun_value decimal(12, 2) NOT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 87,
AVG_ROW_LENGTH = 481,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments_untied
ADD CONSTRAINT FK_kumi_payments_untied_id_cla FOREIGN KEY (id_claim)
REFERENCES claims (id_claim) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments_untied
ADD CONSTRAINT FK_kumi_payments_untied_id_cha FOREIGN KEY (id_charge)
REFERENCES kumi_charges (id_charge) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments_untied
ADD CONSTRAINT FK_kumi_payments_untied_id_pay FOREIGN KEY (id_payment)
REFERENCES kumi_payments (id_payment) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `kumi_payments_claims`
--
CREATE TABLE IF NOT EXISTS kumi_payments_claims (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_payment int(11) NOT NULL,
  id_claim int(11) NOT NULL,
  date date NOT NULL,
  tenancy_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  penalty_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  dgi_value decimal(12, 2) DEFAULT 0.00,
  pkk_value decimal(12, 2) DEFAULT 0.00,
  padun_value decimal(12, 2) DEFAULT 0.00,
  id_display_charge int(11) DEFAULT NULL,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1118,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `kumi_payments_claims_after_delete`
--
CREATE TRIGGER kumi_payments_claims_after_delete
AFTER DELETE
ON kumi_payments_claims
FOR EACH ROW
BEGIN
  INSERT INTO `log`
    VALUES (NULL, 'kumi_payments_claims', OLD.id_assoc, 'deleted', '0', '1', 'DELETE', NOW(), USER());
  IF (OLD.id_display_charge IS NOT NULL) THEN
    INSERT INTO kumi_payments_untied (id_payment, id_charge, id_claim,
    tied_date, untied_date, tenancy_value, penalty_value, dgi_value, pkk_value, padun_value)
      VALUES (OLD.id_payment, OLD.id_display_charge, OLD.id_claim, OLD.date, NOW(), OLD.tenancy_value, OLD.penalty_value, OLD.dgi_value, OLD.pkk_value, OLD.padun_value);
  END IF;
END
$$

--
-- Создать триггер `kumi_payments_claims_after_insert`
--
CREATE TRIGGER kumi_payments_claims_after_insert
AFTER INSERT
ON kumi_payments_claims
FOR EACH ROW
BEGIN
  IF (NEW.id_assoc IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'id_assoc', NULL, NEW.id_assoc, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_payment IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'id_payment', NULL, NEW.id_payment, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_claim IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'id_claim', NULL, NEW.id_claim, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'date', NULL, NEW.date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.tenancy_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'tenancy_value', NULL, NEW.tenancy_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.penalty_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'penalty_value', NULL, NEW.penalty_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.dgi_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'dgi_value', NULL, NEW.dgi_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.pkk_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'pkk_value', NULL, NEW.pkk_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.padun_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'padun_value', NULL, NEW.padun_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_display_charge IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'id_display_charge', NULL, NEW.id_display_charge, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `kumi_payments_claims_after_update`
--
CREATE TRIGGER kumi_payments_claims_after_update
AFTER UPDATE
ON kumi_payments_claims
FOR EACH ROW
BEGIN
  IF (NEW.id_payment <> OLD.id_payment) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'id_payment', OLD.id_payment, NEW.id_payment, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.id_claim <> OLD.id_claim) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'id_claim', OLD.id_claim, NEW.id_claim, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.date <> OLD.date) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'date', OLD.date, NEW.date, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.tenancy_value <> OLD.tenancy_value) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'tenancy_value', OLD.tenancy_value, NEW.tenancy_value, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.penalty_value <> OLD.penalty_value) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'penalty_value', OLD.penalty_value, NEW.penalty_value, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.dgi_value <> OLD.dgi_value) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'dgi_value', OLD.dgi_value, NEW.dgi_value, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.pkk_value <> OLD.pkk_value) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'pkk_value', OLD.pkk_value, NEW.pkk_value, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.padun_value <> OLD.padun_value) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'padun_value', OLD.padun_value, NEW.padun_value, 'UPDATE', NOW(), USER());
  END IF;
  IF (NOT (NEW.id_display_charge IS NULL
    AND OLD.id_display_charge IS NULL)
    AND ((NEW.id_display_charge IS NULL
    AND OLD.id_display_charge IS NOT NULL)
    OR (NEW.id_display_charge IS NOT NULL
    AND OLD.id_display_charge IS NULL)
    OR (NEW.id_display_charge <> OLD.id_display_charge))) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_claims', NEW.id_assoc, 'id_display_charge', OLD.id_display_charge, NEW.id_display_charge, 'UPDATE', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments_claims
ADD CONSTRAINT FK_kumi_payments_claims_id_cla FOREIGN KEY (id_claim)
REFERENCES claims (id_claim) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments_claims
ADD CONSTRAINT FK_kumi_payments_claims_id_dis FOREIGN KEY (id_display_charge)
REFERENCES kumi_charges (id_charge) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments_claims
ADD CONSTRAINT FK_kumi_payments_claims_id_pay FOREIGN KEY (id_payment)
REFERENCES kumi_payments (id_payment) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать представление `v_payments_claims_stage_0`
--
CREATE
VIEW v_payments_claims_stage_0
AS
SELECT
  `kc`.`id_claim` AS `id_claim`,
  `cs`.`court_order_num` AS `court_order_num`,
  `p`.`snp` AS `snp`,
  `ka`.`id_account` AS `id_account`,
  `ka`.`account` AS `account`,
  `kp`.`id_payment` AS `id_payment`,
  `kp`.`sum` AS `sum`,
  `kpc`.`tenancy_value` AS `tenancy_value`,
  `kpc`.`penalty_value` AS `penalty_value`,
  `kpc`.`dgi_value` AS `dgi_value`,
  `kpc`.`pkk_value` AS `pkk_value`,
  `kpc`.`padun_value` AS `padun_value`
FROM (((((`kumi_payments` `kp`
  JOIN `kumi_payments_claims` `kpc`
    ON ((`kp`.`id_payment` = `kpc`.`id_payment`)))
  JOIN `claims` `kc`
    ON ((`kpc`.`id_claim` = `kc`.`id_claim`)))
  LEFT JOIN `v_claim_court_order_nums` `cs`
    ON ((`kc`.`id_claim` = `cs`.`id_claim`)))
  LEFT JOIN `v_claim_claimers` `p`
    ON ((`kc`.`id_claim` = `p`.`id_claim`)))
  JOIN `kumi_accounts` `ka`
    ON ((`kc`.`id_account_kumi` = `ka`.`id_account`)))
UNION ALL
SELECT
  `kc`.`id_claim` AS `id_claim`,
  `cs`.`court_order_num` AS `court_order_num`,
  `p`.`snp` AS `snp`,
  `ka`.`id_account` AS `id_account`,
  `ka`.`account` AS `account`,
  `kp`.`id_payment` AS `id_payment`,
  `kp`.`sum` AS `sum`,
  `kpc`.`tenancy_value` AS `tenancy_value`,
  `kpc`.`penalty_value` AS `penalty_value`,
  `kpc`.`dgi_value` AS `dgi_value`,
  `kpc`.`pkk_value` AS `pkk_value`,
  `kpc`.`padun_value` AS `padun_value`
FROM ((((((`kumi_payments` `kp`
  JOIN `kumi_payments` `kp_child`
    ON ((`kp`.`id_payment` = `kp_child`.`id_parent_payment`)))
  JOIN `kumi_payments_claims` `kpc`
    ON ((`kp`.`id_payment` = `kpc`.`id_payment`)))
  JOIN `claims` `kc`
    ON ((`kpc`.`id_claim` = `kc`.`id_claim`)))
  LEFT JOIN `v_claim_court_order_nums` `cs`
    ON ((`kc`.`id_claim` = `cs`.`id_claim`)))
  LEFT JOIN `v_claim_claimers` `p`
    ON ((`kc`.`id_claim` = `p`.`id_claim`)))
  JOIN `kumi_accounts` `ka`
    ON ((`kc`.`id_account_kumi` = `ka`.`id_account`)))
WHERE (`kp`.`is_consolidated` = 1);

--
-- Создать представление `v_payments_claims_stage_1`
--
CREATE
VIEW v_payments_claims_stage_1
AS
SELECT
  `v`.`id_claim` AS `id_claim`,
  `v`.`court_order_num` AS `court_order_num`,
  `v`.`snp` AS `snp`,
  `v`.`id_account` AS `id_account`,
  `v`.`account` AS `account`,
  `v`.`id_payment` AS `id_payment`,
  `v`.`sum` AS `sum`,
  SUM(`v`.`tenancy_value`) AS `tenancy_value`,
  SUM(`v`.`penalty_value`) AS `penalty_value`,
  SUM(`v`.`dgi_value`) AS `dgi_value`,
  SUM(`v`.`pkk_value`) AS `pkk_value`,
  SUM(`v`.`padun_value`) AS `padun_value`
FROM `v_payments_claims_stage_0` `v`
GROUP BY `v`.`id_claim`,
         `v`.`id_account`,
         `v`.`account`,
         `v`.`id_payment`,
         `v`.`sum`;

--
-- Создать таблицу `kumi_payments_charges`
--
CREATE TABLE IF NOT EXISTS kumi_payments_charges (
  id_assoc int(11) NOT NULL AUTO_INCREMENT,
  id_payment int(11) NOT NULL,
  id_charge int(11) NOT NULL,
  date date NOT NULL,
  tenancy_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  penalty_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  dgi_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  pkk_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  padun_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  id_display_charge int(11) DEFAULT NULL,
  PRIMARY KEY (id_assoc)
)
ENGINE = INNODB,
AUTO_INCREMENT = 8663,
AVG_ROW_LENGTH = 963,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `UK_kumi_payments_charges_id_payment` для объекта типа таблица `kumi_payments_charges`
--
ALTER TABLE kumi_payments_charges
ADD INDEX UK_kumi_payments_charges_id_payment (id_payment);

DELIMITER $$

--
-- Создать триггер `kumi_payments_charges_after_delete`
--
CREATE TRIGGER kumi_payments_charges_after_delete
AFTER DELETE
ON kumi_payments_charges
FOR EACH ROW
BEGIN
  INSERT INTO `log`
    VALUES (NULL, 'kumi_payments_charges', OLD.id_assoc, 'deleted', '0', '1', 'DELETE', NOW(), USER());
  IF (OLD.id_display_charge IS NOT NULL) THEN
    INSERT INTO kumi_payments_untied (id_payment, id_charge, id_claim,
    tied_date, untied_date, tenancy_value, penalty_value, dgi_value, pkk_value, padun_value)
      VALUES (OLD.id_payment, OLD.id_display_charge, NULL, OLD.date, NOW(), OLD.tenancy_value, OLD.penalty_value, OLD.dgi_value, OLD.pkk_value, OLD.padun_value);
  END IF;
END
$$

--
-- Создать триггер `kumi_payments_charges_after_insert`
--
CREATE TRIGGER kumi_payments_charges_after_insert
AFTER INSERT
ON kumi_payments_charges
FOR EACH ROW
BEGIN
  IF (NEW.id_assoc IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'id_assoc', NULL, NEW.id_assoc, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_payment IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'id_payment', NULL, NEW.id_payment, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_charge IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'id_charge', NULL, NEW.id_charge, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'date', NULL, NEW.date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.tenancy_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'tenancy_value', NULL, NEW.tenancy_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.penalty_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'penalty_value', NULL, NEW.penalty_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.dgi_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'dgi_value', NULL, NEW.dgi_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.pkk_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'pkk_value', NULL, NEW.pkk_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.padun_value IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'padun_value', NULL, NEW.padun_value, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_display_charge IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'id_display_charge', NULL, NEW.id_display_charge, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `kumi_payments_charges_after_update`
--
CREATE TRIGGER kumi_payments_charges_after_update
AFTER UPDATE
ON kumi_payments_charges
FOR EACH ROW
BEGIN
  IF (NEW.id_payment <> OLD.id_payment) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'id_payment', OLD.id_payment, NEW.id_payment, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.id_charge <> OLD.id_charge) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'id_charge', OLD.id_charge, NEW.id_charge, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.date <> OLD.date) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'date', OLD.date, NEW.date, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.tenancy_value <> OLD.tenancy_value) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'tenancy_value', OLD.tenancy_value, NEW.tenancy_value, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.penalty_value <> OLD.penalty_value) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'penalty_value', OLD.penalty_value, NEW.penalty_value, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.dgi_value <> OLD.dgi_value) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'dgi_value', OLD.dgi_value, NEW.dgi_value, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.pkk_value <> OLD.pkk_value) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'pkk_value', OLD.pkk_value, NEW.pkk_value, 'UPDATE', NOW(), USER());
  END IF;
  IF (NEW.padun_value <> OLD.padun_value) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'padun_value', OLD.padun_value, NEW.padun_value, 'UPDATE', NOW(), USER());
  END IF;

  IF (NOT (NEW.id_display_charge IS NULL
    AND OLD.id_display_charge IS NULL)
    AND ((NEW.id_display_charge IS NULL
    AND OLD.id_display_charge IS NOT NULL)
    OR (NEW.id_display_charge IS NOT NULL
    AND OLD.id_display_charge IS NULL)
    OR (NEW.id_display_charge <> OLD.id_display_charge))) THEN
    INSERT INTO `log`
      VALUES (NULL, 'kumi_payments_charges', NEW.id_assoc, 'id_display_charge', OLD.id_display_charge, NEW.id_display_charge, 'UPDATE', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments_charges
ADD CONSTRAINT FK_kumi_payments_charges_id_ch FOREIGN KEY (id_charge)
REFERENCES kumi_charges (id_charge) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments_charges
ADD CONSTRAINT FK_kumi_payments_charges_id_di FOREIGN KEY (id_display_charge)
REFERENCES kumi_charges (id_charge) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE kumi_payments_charges
ADD CONSTRAINT FK_kumi_payments_charges_id_pa FOREIGN KEY (id_payment)
REFERENCES kumi_payments (id_payment) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать представление `v_payments_charges_stage_0`
--
CREATE
VIEW v_payments_charges_stage_0
AS
SELECT
  `ka`.`id_account` AS `id_account`,
  `ka`.`account` AS `account`,
  `kaatsd`.`tenant` AS `tenant`,
  `kp`.`id_payment` AS `id_payment`,
  `kp`.`sum` AS `sum`,
  `kpc`.`tenancy_value` AS `tenancy_value`,
  `kpc`.`penalty_value` AS `penalty_value`,
  `kpc`.`dgi_value` AS `dgi_value`,
  `kpc`.`pkk_value` AS `pkk_value`,
  `kpc`.`padun_value` AS `padun_value`
FROM ((((`kumi_payments` `kp`
  JOIN `kumi_payments_charges` `kpc`
    ON ((`kp`.`id_payment` = `kpc`.`id_payment`)))
  JOIN `kumi_charges` `kc`
    ON ((`kpc`.`id_charge` = `kc`.`id_charge`)))
  JOIN `kumi_accounts` `ka`
    ON ((`kc`.`id_account` = `ka`.`id_account`)))
  LEFT JOIN `kumi_accounts_actual_tp_search_denorm` `kaatsd`
    ON ((`ka`.`id_account` = `kaatsd`.`id_account`)))
UNION ALL
SELECT
  `ka`.`id_account` AS `id_account`,
  `ka`.`account` AS `account`,
  `kaatsd`.`tenant` AS `tenant`,
  `kp`.`id_payment` AS `id_payment`,
  `kp`.`sum` AS `sum`,
  `kpc`.`tenancy_value` AS `tenancy_value`,
  `kpc`.`penalty_value` AS `penalty_value`,
  `kpc`.`dgi_value` AS `dgi_value`,
  `kpc`.`pkk_value` AS `pkk_value`,
  `kpc`.`padun_value` AS `padun_value`
FROM (((((`kumi_payments` `kp`
  JOIN `kumi_payments` `kp_child`
    ON ((`kp`.`id_payment` = `kp_child`.`id_parent_payment`)))
  JOIN `kumi_payments_charges` `kpc`
    ON ((`kp_child`.`id_payment` = `kpc`.`id_payment`)))
  JOIN `kumi_charges` `kc`
    ON ((`kpc`.`id_charge` = `kc`.`id_charge`)))
  JOIN `kumi_accounts` `ka`
    ON ((`kc`.`id_account` = `ka`.`id_account`)))
  LEFT JOIN `kumi_accounts_actual_tp_search_denorm` `kaatsd`
    ON ((`ka`.`id_account` = `kaatsd`.`id_account`)))
WHERE (`kp`.`is_consolidated` = 1);

--
-- Создать представление `v_payments_charges_stage_1`
--
CREATE
VIEW v_payments_charges_stage_1
AS
SELECT
  `v`.`id_account` AS `id_account`,
  `v`.`account` AS `account`,
  `v`.`tenant` AS `tenant`,
  `v`.`id_payment` AS `id_payment`,
  `v`.`sum` AS `sum`,
  SUM(`v`.`tenancy_value`) AS `tenancy_value`,
  SUM(`v`.`penalty_value`) AS `penalty_value`,
  SUM(`v`.`dgi_value`) AS `dgi_value`,
  SUM(`v`.`pkk_value`) AS `pkk_value`,
  SUM(`v`.`padun_value`) AS `padun_value`
FROM `v_payments_charges_stage_0` `v`
GROUP BY `v`.`id_account`,
         `v`.`account`,
         `v`.`id_payment`,
         `v`.`sum`;

--
-- Создать представление `v_payments_distirbute_info_prepared`
--
CREATE
VIEW v_payments_distirbute_info_prepared
AS
SELECT
  `v`.`id_payment` AS `id_payment`,
  GROUP_CONCAT(CONCAT('ЛС ', `v`.`account`, IF(ISNULL(`v`.`tenant`), '', CONCAT('\n', `v`.`tenant`)), '\nнайм ', `v`.`tenancy_value`, ' руб.', '\nпени ', `v`.`penalty_value`, ' руб.', IF((`v`.`dgi_value` <> 0), CONCAT('\nДГИ ', `v`.`dgi_value`, ' руб.'), ''), IF((`v`.`pkk_value` <> 0), CONCAT('\nПКК ', `v`.`pkk_value`, ' руб.'), ''), IF((`v`.`padun_value` <> 0), CONCAT('\nПадун ', `v`.`padun_value`, ' руб.'), '')) SEPARATOR '

') AS `account_info`,
  SUM(`v`.`tenancy_value`) AS `tenancy_value`,
  SUM(`v`.`penalty_value`) AS `penalty_value`,
  SUM(`v`.`dgi_value`) AS `dgi_value`,
  SUM(`v`.`pkk_value`) AS `pkk_value`,
  SUM(`v`.`padun_value`) AS `padun_value`
FROM `v_payments_charges_stage_1` `v`
GROUP BY `v`.`id_payment`
UNION ALL
SELECT
  `v`.`id_payment` AS `id_payment`,
  GROUP_CONCAT(CONCAT('ИР ', `v`.`id_claim`, IF(ISNULL(`v`.`court_order_num`), '', CONCAT(' (', `v`.`court_order_num`, ')')), '\nЛС ', `v`.`account`, IF(ISNULL(`v`.`snp`), '', CONCAT('\n', `v`.`snp`)), '\nнайм ', `v`.`tenancy_value`, ' руб.', '\nпени ', `v`.`penalty_value`, ' руб.', IF((`v`.`dgi_value` <> 0), CONCAT('\nДГИ ', `v`.`dgi_value`, ' руб.'), ''), IF((`v`.`pkk_value` <> 0), CONCAT('\nПКК ', `v`.`pkk_value`, ' руб.'), ''), IF((`v`.`padun_value` <> 0), CONCAT('\nПадун ', `v`.`padun_value`, ' руб.'), '')) SEPARATOR '
			
			') AS `account_info`,
  SUM(`v`.`tenancy_value`) AS `tenancy_value`,
  SUM(`v`.`penalty_value`) AS `penalty_value`,
  SUM(`v`.`dgi_value`) AS `dgi_value`,
  SUM(`v`.`pkk_value`) AS `pkk_value`,
  SUM(`v`.`padun_value`) AS `padun_value`
FROM `v_payments_claims_stage_1` `v`
GROUP BY `v`.`id_payment`;

--
-- Создать представление `v_payments_distribute_info`
--
CREATE
VIEW v_payments_distribute_info
AS
SELECT
  `v`.`id_payment` AS `id_payment`,
  GROUP_CONCAT(`v`.`account_info` SEPARATOR '

') AS `account_info`,
  ((((SUM(`v`.`tenancy_value`) + SUM(`v`.`penalty_value`)) + SUM(`v`.`dgi_value`)) + SUM(`v`.`pkk_value`)) + SUM(`v`.`padun_value`)) AS `sum_posted`
FROM `v_payments_distirbute_info_prepared` `v`
GROUP BY `v`.`id_payment`;

DELIMITER $$

--
-- Создать процедуру `get_payments_for_period`
--
CREATE PROCEDURE get_payments_for_period (IN from_date date, IN to_date date, IN kbk varchar(255))
BEGIN
  SET SESSION group_concat_max_len = 1000000;

  SELECT
    @i := @i + 1 AS id,
    v.*
  FROM (SELECT
           v.num_d,
           DATE_FORMAT(v.date_d, '%d.%m.%Y') AS date_d_str,
           v.payer_name,
           v.sum,
           v.purpose,
           v.note,
           v.account_info,
           v.group_index
         FROM (SELECT DISTINCT
             v.num_d,
             v.date_d,
             v.payer_name,
             CASE WHEN v.current_kbk <> kbk AND
                 v.prev_kbk = kbk AND
                 v.mo_date BETWEEN from_date AND to_date THEN 0 - v.sum WHEN v.current_kbk <> kbk AND
                 v.prev_kbk <> kbk AND
                 v.doc_kbk = kbk AND
                 v.mo_date BETWEEN from_date AND to_date THEN 0 - v.doc_sum WHEN v.sum = 0 AND
                 v.current_kbk = kbk AND
                 NOT EXISTS (SELECT
                     *
                   FROM kumi_payments_corrections kpc
                   WHERE kpc.field_name = 'Kbk'
                   AND kpc.field_value <> kbk
                   AND kpc.id_payment = v.id_payment) AND
                 v.date_enroll_ufk BETWEEN from_date AND to_date THEN v.doc_sum WHEN v.sum <> 0 AND
                 v.current_kbk = kbk AND
                 (v.mo_date IS NULL OR
                 v.mo_date > to_date) THEN v.doc_sum ELSE v.sum END AS sum,
             v.purpose,
             v.note,
             v.account_info,
             v.sum_posted,
             v.group_index
           FROM (SELECT
               kp.id_payment,
               kp.num_d,
               kp.date_d,
               kp.date_enroll_ufk,
               kp.payer_name,
               kp.payer_inn,
               kp.sum,
               IFNULL((SELECT
                   CAST(REPLACE(kpc.field_value, ',', '.') AS decimal(12, 2))
                 FROM kumi_payments_corrections kpc
                 WHERE kpc.id_payment = kp.id_payment
                 AND kpc.field_name = 'Sum'
                 ORDER BY kpc.date LIMIT 1), kp.sum) AS doc_sum,
               IFNULL((SELECT
                   CAST(REPLACE(kpc.field_value, ',', '.') AS decimal(12, 2))
                 FROM kumi_payments_corrections kpc
                 WHERE kpc.id_payment = kp.id_payment
                 AND kpc.field_name = 'Sum'
                 ORDER BY kpc.date DESC LIMIT 1), kp.sum) AS prev_sum,
               kp.description,
               kp.kbk AS current_kbk,
               IFNULL((SELECT
                   kpc.field_value
                 FROM kumi_payments_corrections kpc
                 WHERE kpc.id_payment = kp.id_payment
                 AND kpc.field_name = 'Kbk'
                 ORDER BY kpc.date LIMIT 1), kp.kbk) AS doc_kbk,
               IFNULL(IFNULL((SELECT
                   kpc.field_value
                 FROM kumi_payments_corrections kpc
                 WHERE kpc.id_payment = kp.id_payment
                 AND kpc.field_name = 'Kbk'
                 ORDER BY kpc.date DESC LIMIT 1), kp.kbk), kp.kbk) AS prev_kbk,
               kp.purpose,
               CONCAT('№ ', kmo.num_d, ' от ', DATE_FORMAT(kmo.date_enroll_ufk, '%d.%m.%Y')) AS note,
               kmo.date_enroll_ufk AS mo_date,
               (CASE WHEN kp.payer_name LIKE '%"Почта России"%' THEN 1 WHEN (kp.payer_name LIKE '%ООО "Братский коммунальный сервис"%' OR
                   (kp.payer_name LIKE '%ООО "БКС"%' OR
                   kp.id_source = 6)) THEN 2 WHEN kp.payer_name LIKE 'ПАО СБЕРБАНК%' THEN 3 WHEN kp.payer_name LIKE '%УФССП%' THEN 4 WHEN kp.payer_name LIKE '%УФПС ИРКУТСКОЙ ОБЛАСТИ%' THEN 5 WHEN kp.payer_name LIKE '%ВТБ (ПАО)%' THEN 6 ELSE 7 END) AS group_index,
               vpdi.account_info,
               vpdi.sum_posted
             FROM kumi_payments kp
               LEFT JOIN v_payments_distribute_info vpdi
                 ON kp.id_payment = vpdi.id_payment
               LEFT JOIN (SELECT
                   kmo.*,
                   MIN(kmopa.id_payment) AS id_payment
                 FROM kumi_memorial_order_payment_assoc kmopa
                   JOIN kumi_memorial_orders kmo
                     ON kmopa.id_order = kmo.id_order
                 WHERE kmo.sum_zach > 0
                 GROUP BY kmo.id_order) kmo
                 ON kp.id_payment = kmo.id_payment
             -- LEFT JOIN kumi_memorial_order_payment_assoc kmopa ON kp.id_payment = kmopa.id_payment
             -- LEFT JOIN kumi_memorial_orders kmo ON kmopa.id_order = kmo.id_order
             WHERE ((kp.date_enroll_ufk BETWEEN from_date AND to_date
             AND kp.id_source <> 1)
             OR kmo.date_enroll_ufk BETWEEN from_date AND to_date)
             AND (kp.id_source <> 6
             AND kp.id_source <> 7)
             -- Платеж без уточнения КБК
             AND ((kp.kbk = kbk
             AND NOT EXISTS (SELECT
                 *
               FROM kumi_payments_corrections kpc
               WHERE kpc.id_payment = kp.id_payment
               AND kpc.field_name = 'Kbk'))
             OR
             -- Платежи, уточненные на КБК найма
             (kp.kbk = kbk
             AND kmo.date_enroll_ufk BETWEEN from_date AND to_date
             AND EXISTS (SELECT
                 *
               FROM kumi_payments_corrections kpc
               WHERE kpc.id_payment = kp.id_payment
               AND kpc.field_name = 'Kbk'
               AND kpc.field_value <> kbk))
             OR
             -- Платежи, уточненные с КБК найма
             (kp.kbk <> kbk
             AND kmo.date_enroll_ufk BETWEEN from_date AND to_date
             AND EXISTS (SELECT
                 *
               FROM kumi_payments_corrections kpc
               WHERE kpc.id_payment = kp.id_payment
               AND kpc.field_name = 'Kbk'
               AND kpc.field_value = kbk))
             )) v) v
         WHERE v.sum <> 0
         ORDER BY v.group_index, v.date_d) v,
       (SELECT
           @i := 0) n;
END
$$

DELIMITER ;

--
-- Создать таблицу `claim_files`
--
CREATE TABLE IF NOT EXISTS claim_files (
  id_file int(11) NOT NULL AUTO_INCREMENT,
  id_claim int(11) NOT NULL,
  description varchar(255) DEFAULT NULL,
  file_name varchar(4096) DEFAULT NULL,
  display_name varchar(255) DEFAULT NULL,
  mime_type varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_file)
)
ENGINE = INNODB,
AUTO_INCREMENT = 291,
AVG_ROW_LENGTH = 264,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `claim_files_after_insert`
--
CREATE TRIGGER claim_files_after_insert
AFTER INSERT
ON claim_files
FOR EACH ROW
BEGIN
  IF (NEW.id_claim IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_files', NEW.id_file, 'id_claim', NULL, NEW.id_claim, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_files', NEW.id_file, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.`file_name` IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_files', NEW.id_file, 'file_name', NULL, NEW.`file_name`, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.display_name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_files', NEW.id_file, 'display_name', NULL, NEW.display_name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.mime_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_files', NEW.id_file, 'mime_type', NULL, NEW.mime_type, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `claim_files_after_update`
--
CREATE TRIGGER claim_files_after_update
AFTER UPDATE
ON claim_files
FOR EACH ROW
BEGIN
  IF (NEW.id_claim <> OLD.id_claim) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_files', NEW.id_file, 'id_claim', OLD.id_claim, NEW.id_claim, 'UPDATE', NOW(), USER());
  END IF;
  IF (NOT (NEW.description IS NULL
    AND OLD.description IS NULL)
    AND ((NEW.description IS NULL
    AND OLD.description IS NOT NULL)
    OR (NEW.description IS NOT NULL
    AND OLD.description IS NULL)
    OR (NEW.description <> OLD.description))) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_files', NEW.id_file, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
  END IF;
  IF (NOT (NEW.file_name IS NULL
    AND OLD.file_name IS NULL)
    AND ((NEW.file_name IS NULL
    AND OLD.file_name IS NOT NULL)
    OR (NEW.file_name IS NOT NULL
    AND OLD.file_name IS NULL)
    OR (NEW.file_name <> OLD.file_name))) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_files', NEW.id_file, 'file_name', OLD.file_name, NEW.file_name, 'UPDATE', NOW(), USER());
  END IF;
  IF (NOT (NEW.display_name IS NULL
    AND OLD.display_name IS NULL)
    AND ((NEW.display_name IS NULL
    AND OLD.display_name IS NOT NULL)
    OR (NEW.display_name IS NOT NULL
    AND OLD.display_name IS NULL)
    OR (NEW.display_name <> OLD.display_name))) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_files', NEW.id_file, 'display_name', OLD.display_name, NEW.display_name, 'UPDATE', NOW(), USER());
  END IF;
  IF (NOT (NEW.mime_type IS NULL
    AND OLD.mime_type IS NULL)
    AND ((NEW.mime_type IS NULL
    AND OLD.mime_type IS NOT NULL)
    OR (NEW.mime_type IS NOT NULL
    AND OLD.mime_type IS NULL)
    OR (NEW.mime_type <> OLD.mime_type))) THEN
    INSERT INTO `log`
      VALUES (NULL, 'claim_files', NEW.id_file, 'mime_type', OLD.mime_type, NEW.mime_type, 'UPDATE', NOW(), USER());
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE claim_files
ADD CONSTRAINT FK_claim_files_claims_id_claim FOREIGN KEY (id_claim)
REFERENCES claims (id_claim) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `owner_type`
--
CREATE TABLE IF NOT EXISTS owner_type (
  id_owner_type int(11) NOT NULL AUTO_INCREMENT,
  owner_type varchar(255) NOT NULL COMMENT 'Тип собственника (физ. лицо, юр. лицо или ип)',
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_owner_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `owners`
--
CREATE TABLE IF NOT EXISTS owners (
  id_owner int(11) NOT NULL AUTO_INCREMENT,
  id_process int(11) NOT NULL,
  id_owner_type int(11) NOT NULL,
  deleted tinyint(1) NOT NULL,
  PRIMARY KEY (id_owner)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2037,
AVG_ROW_LENGTH = 58,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `owners_after_insert`
--
CREATE TRIGGER owners_after_insert
AFTER INSERT
ON owners
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  DECLARE id_log int(11);
  DECLARE tables_param varchar(255);
  SET id_user = (SELECT
      au.id_user
    FROM acl_users au
    WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
  SET tables_param = 'owners;owner_orginfo';
  IF (NEW.id_owner_type = 1) THEN
    SET tables_param = 'owners;owner_persons';
  END IF;
  INSERT INTO log_owner_processes
    VALUES (NULL, NEW.id_process, NOW(), id_user, 3, 1, tables_param, NEW.id_owner);
  SET id_log = (SELECT
      LAST_INSERT_ID());
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'id_owner_type', NEW.id_owner_type);
  IF (NEW.id_owner_type = 1) THEN
    INSERT INTO log_owner_processes_value
      VALUES (NULL, id_log, 'surname', '');
    INSERT INTO log_owner_processes_value
      VALUES (NULL, id_log, 'name', '');
    INSERT INTO log_owner_processes_value
      VALUES (NULL, id_log, 'patronymic', '');
  ELSE
    INSERT INTO log_owner_processes_value
      VALUES (NULL, id_log, 'org_name', '');
  END IF;
END
$$

--
-- Создать триггер `owners_after_update`
--
CREATE TRIGGER owners_after_update
AFTER UPDATE
ON owners
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  DECLARE tables_param varchar(255);
  SET id_user = (SELECT
      au.id_user
    FROM acl_users au
    WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    SET tables_param = 'owners;owner_orginfo';
    IF (NEW.id_owner_type = 1) THEN
      SET tables_param = 'owners;owner_persons';
    END IF;
    INSERT INTO log_owner_processes
      VALUES (NULL, NEW.id_process, NOW(), id_user, 3, 6, tables_param, NEW.id_owner);
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE owners
ADD CONSTRAINT FK_owners_id_owner_type FOREIGN KEY (id_owner_type)
REFERENCES owner_type (id_owner_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE owners
ADD CONSTRAINT FK_owners_id_process FOREIGN KEY (id_process)
REFERENCES owner_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать представление `v_owner_share`
--
CREATE
VIEW v_owner_share
AS
SELECT
  `ow`.`id_owner` AS `id_owner`,
  `ow`.`id_process` AS `id_process`,
  `ow`.`id_owner_type` AS `id_owner_type`,
  `ow`.`deleted` AS `deleted`
FROM `owners` `ow`
WHERE (`ow`.`deleted` = 0);

--
-- Создать таблицу `owner_persons`
--
CREATE TABLE IF NOT EXISTS owner_persons (
  id_owner int(11) NOT NULL,
  surname varchar(255) NOT NULL COMMENT 'Фамилия',
  name varchar(255) NOT NULL COMMENT 'Имя',
  patronymic varchar(255) DEFAULT NULL COMMENT 'Отчество',
  PRIMARY KEY (id_owner)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 104,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `owner_persons_after_insert`
--
CREATE TRIGGER owner_persons_after_insert
AFTER INSERT
ON owner_persons
FOR EACH ROW
BEGIN
  DECLARE id_log int(11);
  SET id_log = (SELECT
      lop.id
    FROM log_owner_processes lop
    WHERE lop.`table` = 'owners;owner_persons'
    AND lop.id_key = NEW.id_owner);
  UPDATE log_owner_processes_value lopv
  SET lopv.value = NEW.surname
  WHERE lopv.field = 'surname'
  AND lopv.id_log = id_log;
  UPDATE log_owner_processes_value lopv
  SET lopv.value = NEW.name
  WHERE lopv.field = 'name'
  AND lopv.id_log = id_log;
  UPDATE log_owner_processes_value lopv
  SET lopv.value = NEW.patronymic
  WHERE lopv.field = 'patronymic'
  AND lopv.id_log = id_log;
END
$$

--
-- Создать триггер `owner_persons_after_update`
--
CREATE TRIGGER owner_persons_after_update
AFTER UPDATE
ON owner_persons
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  DECLARE id_log int(11);
  DECLARE id_process int(11);
  SET id_process = (SELECT
      o.id_process
    FROM owners o
    WHERE o.id_owner = NEW.id_owner);
  SET id_user = (SELECT
      au.id_user
    FROM acl_users au
    WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));

  SET id_log = -1;
  IF ((NEW.surname IS NULL
    AND OLD.surname IS NOT NULL)
    OR (NEW.surname IS NOT NULL
    AND OLD.surname IS NULL)
    OR (NEW.surname <> OLD.surname)) THEN
    INSERT INTO log_owner_processes
      VALUES (NULL, id_process, NOW(), id_user, 3, 3, 'owners;owner_persons', NEW.id_owner);
    SET id_log = (SELECT
        LAST_INSERT_ID());
    INSERT INTO log_owner_processes_value
      VALUES (NULL, id_log, 'surname', NEW.surname);
  END IF;
  IF ((NEW.name IS NULL
    AND OLD.name IS NOT NULL)
    OR (NEW.name IS NOT NULL
    AND OLD.name IS NULL)
    OR (NEW.name <> OLD.name)) THEN
    IF (id_log = -1) THEN
      INSERT INTO log_owner_processes
        VALUES (NULL, id_process, NOW(), id_user, 3, 3, 'owners;owner_persons', NEW.id_owner);
      SET id_log = (SELECT
          LAST_INSERT_ID());
    END IF;
    INSERT INTO log_owner_processes_value
      VALUES (NULL, id_log, 'name', NEW.name);
  END IF;
  IF ((NEW.patronymic IS NULL
    AND OLD.patronymic IS NOT NULL)
    OR (NEW.patronymic IS NOT NULL
    AND OLD.patronymic IS NULL)
    OR (NEW.patronymic <> OLD.patronymic)) THEN
    IF (id_log = -1) THEN
      INSERT INTO log_owner_processes
        VALUES (NULL, id_process, NOW(), id_user, 3, 3, 'owners;owner_persons', NEW.id_owner);
      SET id_log = (SELECT
          LAST_INSERT_ID());
    END IF;
    INSERT INTO log_owner_processes_value
      VALUES (NULL, id_log, 'patronymic', NEW.patronymic);
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE owner_persons
ADD CONSTRAINT FK_owner_persons_owners_id_owner FOREIGN KEY (id_owner)
REFERENCES owners (id_owner);

--
-- Создать таблицу `owner_orginfo`
--
CREATE TABLE IF NOT EXISTS owner_orginfo (
  id_owner int(11) NOT NULL,
  org_name varchar(255) NOT NULL COMMENT 'Наименование юридического лица или ИП',
  PRIMARY KEY (id_owner)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `owner_orginfo_after_insert`
--
CREATE TRIGGER owner_orginfo_after_insert
AFTER INSERT
ON owner_orginfo
FOR EACH ROW
BEGIN
  DECLARE id_log int(11);
  SET id_log = (SELECT
      lop.id
    FROM log_owner_processes lop
    WHERE lop.`table` = 'owners;owner_orginfo'
    AND lop.id_key = NEW.id_owner);
  UPDATE log_owner_processes_value lopv
  SET lopv.value = NEW.org_name
  WHERE lopv.field = 'org_name'
  AND lopv.id_log = id_log;
END
$$

--
-- Создать триггер `owner_orginfo_after_update`
--
CREATE TRIGGER owner_orginfo_after_update
AFTER UPDATE
ON owner_orginfo
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  DECLARE id_log int(11);
  DECLARE id_process int(11);
  IF ((NEW.org_name IS NULL
    AND OLD.org_name IS NOT NULL)
    OR (NEW.org_name IS NOT NULL
    AND OLD.org_name IS NULL)
    OR (NEW.org_name <> OLD.org_name)) THEN
    SET id_process = (SELECT
        o.id_process
      FROM owners o
      WHERE o.id_owner = NEW.id_owner);
    SET id_user = (SELECT
        au.id_user
      FROM acl_users au
      WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
    INSERT INTO log_owner_processes
      VALUES (NULL, id_process, NOW(), id_user, 3, 3, 'owners;owner_orginfo', NEW.id_owner);
    SET id_log = (SELECT
        LAST_INSERT_ID());
    INSERT INTO log_owner_processes_value
      VALUES (NULL, id_log, 'org_name', NEW.org_name);
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE owner_orginfo
ADD CONSTRAINT FK_owner_orginfo_owners_id_owner FOREIGN KEY (id_owner)
REFERENCES owners (id_owner);

--
-- Создать представление `v_owner_active_processes`
--
CREATE
VIEW v_owner_active_processes
AS
SELECT
  `op`.`id_process` AS `id_process`,
  `oba`.`id_building` AS `id_building`,
  `opa`.`id_premise` AS `id_premises`,
  `ospa`.`id_sub_premise` AS `id_sub_premises`,
  GROUP_CONCAT(CONCAT(IF(ISNULL(`oper`.`surname`), '', CONCAT(`oper`.`surname`, ' ', `oper`.`name`, ' ', `oper`.`patronymic`)), IFNULL(`oorg`.`org_name`, '')) SEPARATOR ',') AS `owners`,
  COUNT(0) AS `count_owners`
FROM ((((((`owner_processes` `op`
  LEFT JOIN `owners` `ow`
    ON (((`op`.`id_process` = `ow`.`id_process`)
    AND (`ow`.`deleted` <> 1))))
  LEFT JOIN `owner_persons` `oper`
    ON ((`ow`.`id_owner` = `oper`.`id_owner`)))
  LEFT JOIN `owner_orginfo` `oorg`
    ON ((`ow`.`id_owner` = `oorg`.`id_owner`)))
  LEFT JOIN `owner_buildings_assoc` `oba`
    ON (((`op`.`id_process` = `oba`.`id_process`)
    AND (`oba`.`deleted` = 0))))
  LEFT JOIN `owner_premises_assoc` `opa`
    ON (((`op`.`id_process` = `opa`.`id_process`)
    AND (`opa`.`deleted` = 0))))
  LEFT JOIN `owner_sub_premises_assoc` `ospa`
    ON (((`op`.`id_process` = `ospa`.`id_process`)
    AND (`ospa`.`deleted` = 0))))
WHERE ((`op`.`deleted` <> 1)
AND ISNULL(`op`.`annul_date`))
GROUP BY `op`.`id_process`;

--
-- Создать представление `v_premises_count_owners`
--
CREATE
VIEW v_premises_count_owners
AS
SELECT
  IF((`voap`.`id_premises` IS NOT NULL), `voap`.`id_premises`, IF((`voap`.`id_sub_premises` IS NOT NULL), `p1`.`id_premises`, NULL)) AS `id_premise`,
  IF((`voap`.`id_premises` IS NOT NULL), `p`.`id_building`, IF((`voap`.`id_sub_premises` IS NOT NULL), `p1`.`id_building`, NULL)) AS `id_building`,
  SUM(`voap`.`count_owners`) AS `count_persons`
FROM (((`v_owner_active_processes` `voap`
  LEFT JOIN `premises` `p`
    ON ((`voap`.`id_premises` = `p`.`id_premises`)))
  LEFT JOIN `sub_premises` `sp`
    ON ((`voap`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  LEFT JOIN `premises` `p1`
    ON ((`sp`.`id_premises` = `p1`.`id_premises`)))
GROUP BY `id_premise`;

--
-- Создать представление `v_buildings_count_owners`
--
CREATE
VIEW v_buildings_count_owners
AS
SELECT
  `vpco`.`id_building` AS `id_building`,
  SUM(`vpco`.`count_persons`) AS `count_persons`
FROM `v_premises_count_owners` `vpco`
GROUP BY `vpco`.`id_building`;

--
-- Создать таблицу `owner_files_assoc`
--
CREATE TABLE IF NOT EXISTS owner_files_assoc (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_owner int(11) NOT NULL,
  id_file int(11) NOT NULL,
  numerator_share int(11) NOT NULL,
  denominator_share int(11) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2072,
AVG_ROW_LENGTH = 66,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE owner_files_assoc
ADD CONSTRAINT FK_owner_files_assoc_id_file FOREIGN KEY (id_file)
REFERENCES owner_files (id) ON DELETE NO ACTION;

--
-- Создать внешний ключ
--
ALTER TABLE owner_files_assoc
ADD CONSTRAINT FK_owner_files_assoc_id_owner FOREIGN KEY (id_owner)
REFERENCES owners (id_owner) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `fund_types`
--
CREATE TABLE IF NOT EXISTS fund_types (
  id_fund_type int(11) NOT NULL AUTO_INCREMENT,
  fund_type varchar(255) NOT NULL COMMENT 'Тип жилого фонда',
  PRIMARY KEY (id_fund_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 6,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `funds_history`
--
CREATE TABLE IF NOT EXISTS funds_history (
  id_fund int(11) NOT NULL AUTO_INCREMENT,
  id_fund_type int(11) NOT NULL DEFAULT 1 COMMENT 'Индекс типа фонда',
  protocol_number varchar(50) DEFAULT NULL COMMENT 'Номер протокола жилищной комиссии',
  protocol_date date DEFAULT NULL COMMENT 'Дата протокола жилищной комиссии',
  include_restriction_number varchar(30) DEFAULT NULL COMMENT 'Номер реквизита НПА по включению в фонд',
  include_restriction_date datetime DEFAULT NULL COMMENT 'Дата реквизита НПА по включению в фонд',
  include_restriction_description varchar(255) DEFAULT NULL COMMENT 'Наименование реквизита НПА по включению в фонд',
  exclude_restriction_number varchar(30) DEFAULT NULL COMMENT 'Номер реквизита НПА по исключению из фонда',
  exclude_restriction_date datetime DEFAULT NULL COMMENT 'Дата реквизита НПА по исключению из фонда',
  exclude_restriction_description varchar(255) DEFAULT NULL COMMENT 'Наименование реквизита НПА по исключению из фонда',
  description text DEFAULT NULL COMMENT 'Дополнительные сведения',
  deleted tinyint(1) DEFAULT 0,
  PRIMARY KEY (id_fund)
)
ENGINE = INNODB,
AUTO_INCREMENT = 24620,
AVG_ROW_LENGTH = 123,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `funds_history_after_insert`
--
CREATE TRIGGER funds_history_after_insert
AFTER INSERT
ON funds_history
FOR EACH ROW
BEGIN
  IF (NEW.id_fund_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_history', NEW.id_fund, 'id_fund_type', NULL, NEW.id_fund_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.protocol_number IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_history', NEW.id_fund, 'protocol_number', NULL, NEW.protocol_number, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.protocol_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_history', NEW.id_fund, 'protocol_date', NULL, NEW.protocol_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.include_restriction_number IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_history', NEW.id_fund, 'include_restriction_number', NULL, NEW.include_restriction_number, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.include_restriction_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_history', NEW.id_fund, 'include_restriction_date', NULL, NEW.include_restriction_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.include_restriction_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_history', NEW.id_fund, 'include_restriction_description', NULL, NEW.include_restriction_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.exclude_restriction_number IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_history', NEW.id_fund, 'exclude_restriction_number', NULL, NEW.exclude_restriction_number, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.exclude_restriction_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_history', NEW.id_fund, 'exclude_restriction_date', NULL, NEW.exclude_restriction_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.exclude_restriction_description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_history', NEW.id_fund, 'exclude_restriction_description', NULL, NEW.exclude_restriction_description, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_history', NEW.id_fund, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `funds_history_after_update`
--
CREATE TRIGGER funds_history_after_update
AFTER UPDATE
ON funds_history
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'funds_history', NEW.id_fund, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_fund_type <> OLD.id_fund_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'funds_history', NEW.id_fund, 'id_fund_type', OLD.id_fund_type, NEW.id_fund_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.protocol_number IS NULL
      AND OLD.protocol_number IS NULL)
      AND ((NEW.protocol_number IS NULL
      AND OLD.protocol_number IS NOT NULL)
      OR (NEW.protocol_number IS NOT NULL
      AND OLD.protocol_number IS NULL)
      OR (NEW.protocol_number <> OLD.protocol_number))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'funds_history', NEW.id_fund, 'protocol_number', OLD.protocol_number, NEW.protocol_number, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.protocol_date IS NULL
      AND OLD.protocol_date IS NULL)
      AND ((NEW.protocol_date IS NULL
      AND OLD.protocol_date IS NOT NULL)
      OR (NEW.protocol_date IS NOT NULL
      AND OLD.protocol_date IS NULL)
      OR (NEW.protocol_date <> OLD.protocol_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'funds_history', NEW.id_fund, 'protocol_date', OLD.protocol_date, NEW.protocol_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.include_restriction_number IS NULL
      AND OLD.include_restriction_number IS NULL)
      AND ((NEW.include_restriction_number IS NULL
      AND OLD.include_restriction_number IS NOT NULL)
      OR (NEW.include_restriction_number IS NOT NULL
      AND OLD.include_restriction_number IS NULL)
      OR (NEW.include_restriction_number <> OLD.include_restriction_number))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'funds_history', NEW.id_fund, 'include_restriction_number', OLD.include_restriction_number, NEW.include_restriction_number, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.include_restriction_date IS NULL
      AND OLD.include_restriction_date IS NULL)
      AND ((NEW.include_restriction_date IS NULL
      AND OLD.include_restriction_date IS NOT NULL)
      OR (NEW.include_restriction_date IS NOT NULL
      AND OLD.include_restriction_date IS NULL)
      OR (NEW.include_restriction_date <> OLD.include_restriction_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'funds_history', NEW.id_fund, 'include_restriction_date', OLD.include_restriction_date, NEW.include_restriction_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.include_restriction_description IS NULL
      AND OLD.include_restriction_description IS NULL)
      AND ((NEW.include_restriction_description IS NULL
      AND OLD.include_restriction_description IS NOT NULL)
      OR (NEW.include_restriction_description IS NOT NULL
      AND OLD.include_restriction_description IS NULL)
      OR (NEW.include_restriction_description <> OLD.include_restriction_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'funds_history', NEW.id_fund, 'include_restriction_description', OLD.include_restriction_description, NEW.include_restriction_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.exclude_restriction_number IS NULL
      AND OLD.exclude_restriction_number IS NULL)
      AND ((NEW.exclude_restriction_number IS NULL
      AND OLD.exclude_restriction_number IS NOT NULL)
      OR (NEW.exclude_restriction_number IS NOT NULL
      AND OLD.exclude_restriction_number IS NULL)
      OR (NEW.exclude_restriction_number <> OLD.exclude_restriction_number))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'funds_history', NEW.id_fund, 'exclude_restriction_number', OLD.exclude_restriction_number, NEW.exclude_restriction_number, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.exclude_restriction_date IS NULL
      AND OLD.exclude_restriction_date IS NULL)
      AND ((NEW.exclude_restriction_date IS NULL
      AND OLD.exclude_restriction_date IS NOT NULL)
      OR (NEW.exclude_restriction_date IS NOT NULL
      AND OLD.exclude_restriction_date IS NULL)
      OR (NEW.exclude_restriction_date <> OLD.exclude_restriction_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'funds_history', NEW.id_fund, 'exclude_restriction_date', OLD.exclude_restriction_date, NEW.exclude_restriction_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.exclude_restriction_description IS NULL
      AND OLD.exclude_restriction_description IS NULL)
      AND ((NEW.exclude_restriction_description IS NULL
      AND OLD.exclude_restriction_description IS NOT NULL)
      OR (NEW.exclude_restriction_description IS NOT NULL
      AND OLD.exclude_restriction_description IS NULL)
      OR (NEW.exclude_restriction_description <> OLD.exclude_restriction_description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'funds_history', NEW.id_fund, 'exclude_restriction_description', OLD.exclude_restriction_description, NEW.exclude_restriction_description, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'funds_history', NEW.id_fund, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `funds_history_before_update`
--
CREATE TRIGGER funds_history_before_update
BEFORE UPDATE
ON funds_history
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    UPDATE funds_buildings_assoc
    SET deleted = 1
    WHERE id_fund = NEW.id_fund;
    UPDATE funds_premises_assoc
    SET deleted = 1
    WHERE id_fund = NEW.id_fund;
    UPDATE funds_sub_premises_assoc
    SET deleted = 1
    WHERE id_fund = NEW.id_fund;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE funds_history
ADD CONSTRAINT FK_funds_history_fund_types_id_fund_type FOREIGN KEY (id_fund_type)
REFERENCES fund_types (id_fund_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE funds_buildings_assoc
ADD CONSTRAINT FK_funds_buildings_assoc_funds_history_id_fund FOREIGN KEY (id_fund)
REFERENCES funds_history (id_fund) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE funds_premises_assoc
ADD CONSTRAINT FK_ownership_premises_assoc_funds_history_id_fund FOREIGN KEY (id_fund)
REFERENCES funds_history (id_fund) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE funds_sub_premises_assoc
ADD CONSTRAINT FK_funds_sub_premises_assoc_funds_history_id_fund FOREIGN KEY (id_fund)
REFERENCES funds_history (id_fund) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать представление `v_sub_premises_current_fund`
--
CREATE
VIEW v_sub_premises_current_fund
AS
SELECT
  `fspa`.`id_sub_premises` AS `id_sub_premises`,
  MAX(`fh`.`id_fund`) AS `id_fund`
FROM (`funds_sub_premises_assoc` `fspa`
  JOIN `funds_history` `fh`
    ON ((`fspa`.`id_fund` = `fh`.`id_fund`)))
WHERE (ISNULL(`fh`.`exclude_restriction_date`)
AND (`fh`.`deleted` <> 1)
AND (`fspa`.`deleted` <> 1))
GROUP BY `fspa`.`id_sub_premises`;

--
-- Создать представление `v_sub_premises_special_fund`
--
CREATE
VIEW v_sub_premises_special_fund
AS
SELECT
  `sp`.`id_sub_premises` AS `id_sub_premises`,
  `sp`.`id_premises` AS `id_premises`,
  `sp`.`id_state` AS `id_state`,
  `sp`.`sub_premises_num` AS `sub_premises_num`,
  `sp`.`total_area` AS `total_area`,
  `sp`.`description` AS `description`,
  `sp`.`deleted` AS `deleted`,
  `fh`.`id_fund` AS `id_fund`
FROM (((`funds_history` `fh`
  JOIN `v_sub_premises_current_fund` `cf`
    ON ((`cf`.`id_fund` = `fh`.`id_fund`)))
  JOIN `sub_premises` `sp`
    ON ((`sp`.`id_sub_premises` = `cf`.`id_sub_premises`)))
  JOIN `v_premises_municipal` `p`
    ON ((`p`.`id_premises` = `sp`.`id_premises`)))
WHERE ((`fh`.`id_fund_type` = 3)
AND (`sp`.`deleted` <> 1)
AND (`sp`.`id_state` NOT IN (3, 6, 7, 8, 10)));

--
-- Создать представление `v_sub_premises_social_fund`
--
CREATE
VIEW v_sub_premises_social_fund
AS
SELECT
  `sp`.`id_sub_premises` AS `id_sub_premises`,
  `sp`.`id_premises` AS `id_premises`,
  `sp`.`id_state` AS `id_state`,
  `sp`.`sub_premises_num` AS `sub_premises_num`,
  `sp`.`total_area` AS `total_area`,
  `sp`.`description` AS `description`,
  `sp`.`deleted` AS `deleted`,
  `fh`.`id_fund` AS `id_fund`,
  `fh`.`id_fund_type` AS `id_fund_type`
FROM (((`funds_history` `fh`
  JOIN `v_sub_premises_current_fund` `cf`
    ON ((`cf`.`id_fund` = `fh`.`id_fund`)))
  JOIN `sub_premises` `sp`
    ON ((`sp`.`id_sub_premises` = `cf`.`id_sub_premises`)))
  JOIN `v_premises_municipal` `p`
    ON ((`p`.`id_premises` = `sp`.`id_premises`)))
WHERE ((`fh`.`id_fund_type` = 1)
AND (`sp`.`deleted` <> 1)
AND (`sp`.`id_state` NOT IN (3, 6, 7, 8, 10)));

--
-- Создать представление `v_sub_premises_other_fund`
--
CREATE
VIEW v_sub_premises_other_fund
AS
SELECT
  `sp`.`id_sub_premises` AS `id_sub_premises`,
  `sp`.`id_premises` AS `id_premises`,
  `sp`.`id_state` AS `id_state`,
  `sp`.`sub_premises_num` AS `sub_premises_num`,
  `sp`.`total_area` AS `total_area`,
  `sp`.`description` AS `description`,
  `sp`.`deleted` AS `deleted`,
  `fh`.`id_fund` AS `id_fund`
FROM (((`funds_history` `fh`
  JOIN `v_sub_premises_current_fund` `cf`
    ON ((`cf`.`id_fund` = `fh`.`id_fund`)))
  JOIN `sub_premises` `sp`
    ON ((`sp`.`id_sub_premises` = `cf`.`id_sub_premises`)))
  JOIN `v_premises_municipal` `p`
    ON ((`p`.`id_premises` = `sp`.`id_premises`)))
WHERE ((`fh`.`id_fund_type` NOT IN (1, 2, 3))
AND (`sp`.`deleted` <> 1)
AND (`sp`.`id_state` NOT IN (3, 6, 7, 8, 10)));

--
-- Создать представление `v_sub_premises_commercial_fund`
--
CREATE
VIEW v_sub_premises_commercial_fund
AS
SELECT
  `sp`.`id_sub_premises` AS `id_sub_premises`,
  `sp`.`id_premises` AS `id_premises`,
  `sp`.`id_state` AS `id_state`,
  `sp`.`sub_premises_num` AS `sub_premises_num`,
  `sp`.`total_area` AS `total_area`,
  `sp`.`description` AS `description`,
  `sp`.`deleted` AS `deleted`,
  `fh`.`id_fund` AS `id_fund`
FROM (((`funds_history` `fh`
  JOIN `v_sub_premises_current_fund` `cf`
    ON ((`cf`.`id_fund` = `fh`.`id_fund`)))
  JOIN `sub_premises` `sp`
    ON ((`sp`.`id_sub_premises` = `cf`.`id_sub_premises`)))
  JOIN `v_premises_municipal` `p`
    ON ((`p`.`id_premises` = `sp`.`id_premises`)))
WHERE ((`fh`.`id_fund_type` = 2)
AND (`sp`.`deleted` <> 1)
AND (`sp`.`id_state` NOT IN (3, 6, 7, 8, 10)));

--
-- Создать представление `v_registry_full_stat_special_sub_premises_max`
--
CREATE
VIEW v_registry_full_stat_special_sub_premises_max
AS
SELECT
  `fspa`.`id_sub_premises` AS `id_sub_premises`,
  MAX(`fh`.`id_fund`) AS `id_fund`
FROM (`funds_sub_premises_assoc` `fspa`
  JOIN `funds_history` `fh`
    ON ((`fspa`.`id_fund` = `fh`.`id_fund`)))
WHERE (ISNULL(`fh`.`exclude_restriction_date`)
AND (`fh`.`deleted` <> 1)
AND (`fspa`.`deleted` <> 1)
AND (`fh`.`id_fund_type` = 3))
GROUP BY `fspa`.`id_sub_premises`;

--
-- Создать представление `v_registry_full_stat_special_premises_max`
--
CREATE
VIEW v_registry_full_stat_special_premises_max
AS
SELECT
  `fspa`.`id_premises` AS `id_premises`,
  MAX(`fh`.`id_fund`) AS `id_fund`
FROM (`funds_premises_assoc` `fspa`
  JOIN `funds_history` `fh`
    ON ((`fspa`.`id_fund` = `fh`.`id_fund`)))
WHERE (ISNULL(`fh`.`exclude_restriction_date`)
AND (`fh`.`deleted` <> 1)
AND (`fspa`.`deleted` <> 1)
AND (`fh`.`id_fund_type` = 3))
GROUP BY `fspa`.`id_premises`;

--
-- Создать представление `v_registry_full_stat_special_rest`
--
CREATE
VIEW v_registry_full_stat_special_rest
AS
SELECT
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  CONCAT(`p`.`premises_num`, IF(ISNULL(`spn`.`sub_premises`), '', CONCAT('(', `spn`.`sub_premises`, ')'))) AS `premises_num`,
  CONCAT('№', `fh`.`include_restriction_number`, ' - ', DATE_FORMAT(`fh`.`include_restriction_date`, '%d.%m.%Y')) AS `include_restriction`,
  CONCAT('№', `fh`.`exclude_restriction_number`, ' - ', DATE_FORMAT(`fh`.`exclude_restriction_date`, '%d.%m.%Y')) AS `exclude_restriction`
FROM (((`premises` `p`
  JOIN `v_registry_full_stat_special_premises_max` `fpa`
    ON ((`p`.`id_premises` = `fpa`.`id_premises`)))
  JOIN `funds_history` `fh`
    ON ((`fpa`.`id_fund` = `fh`.`id_fund`)))
  LEFT JOIN `v_registry_full_stat_concated_municipal_sub_premises` `spn`
    ON ((`p`.`id_premises` = `spn`.`id_premises`)))
WHERE (`p`.`deleted` <> 1)
UNION ALL
SELECT
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  CONCAT(`p`.`premises_num`, '(', `sp`.`sub_premises_num`, ')') AS `CONCAT(p.premises_num, '(', sp.sub_premises_num, ')')`,
  CONCAT('№', `fh`.`include_restriction_number`, ' - ', DATE_FORMAT(`fh`.`include_restriction_date`, '%d.%m.%Y')) AS `include_restriction`,
  CONCAT('№', `fh`.`exclude_restriction_number`, ' - ', DATE_FORMAT(`fh`.`exclude_restriction_date`, '%d.%m.%Y')) AS `exclude_restriction`
FROM (((`v_registry_full_stat_special_sub_premises_max` `spa`
  JOIN `sub_premises` `sp`
    ON ((`spa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
  JOIN `funds_history` `fh`
    ON ((`spa`.`id_fund` = `fh`.`id_fund`)))
WHERE (`sp`.`deleted` <> 1);

--
-- Создать представление `v_registry_full_stat_special_rest_ordered`
--
CREATE
VIEW v_registry_full_stat_special_rest_ordered
AS
SELECT
  `v`.`id_building` AS `id_building`,
  `v`.`id_premises` AS `id_premises`,
  `v`.`premises_num` AS `premises_num`,
  `v`.`include_restriction` AS `include_restriction`,
  `v`.`exclude_restriction` AS `exclude_restriction`
FROM `v_registry_full_stat_special_rest` `v`
ORDER BY `v`.`id_building`, `v`.`premises_num`;

--
-- Создать представление `v_registry_full_stat_social_sub_premises_max`
--
CREATE
VIEW v_registry_full_stat_social_sub_premises_max
AS
SELECT
  `fspa`.`id_sub_premises` AS `id_sub_premises`,
  MAX(`fh`.`id_fund`) AS `id_fund`
FROM (`funds_sub_premises_assoc` `fspa`
  JOIN `funds_history` `fh`
    ON ((`fspa`.`id_fund` = `fh`.`id_fund`)))
WHERE (ISNULL(`fh`.`exclude_restriction_date`)
AND (`fh`.`deleted` <> 1)
AND (`fspa`.`deleted` <> 1)
AND (`fh`.`id_fund_type` = 1))
GROUP BY `fspa`.`id_sub_premises`;

--
-- Создать представление `v_registry_full_stat_social_premises_max`
--
CREATE
VIEW v_registry_full_stat_social_premises_max
AS
SELECT
  `fspa`.`id_premises` AS `id_premises`,
  MAX(`fh`.`id_fund`) AS `id_fund`
FROM (`funds_premises_assoc` `fspa`
  JOIN `funds_history` `fh`
    ON ((`fspa`.`id_fund` = `fh`.`id_fund`)))
WHERE (ISNULL(`fh`.`exclude_restriction_date`)
AND (`fh`.`deleted` <> 1)
AND (`fspa`.`deleted` <> 1)
AND (`fh`.`id_fund_type` = 1))
GROUP BY `fspa`.`id_premises`;

--
-- Создать представление `v_registry_full_stat_social_rest`
--
CREATE
VIEW v_registry_full_stat_social_rest
AS
SELECT
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  CONCAT(`p`.`premises_num`, IF(ISNULL(`spn`.`sub_premises`), '', CONCAT('(', `spn`.`sub_premises`, ')'))) AS `premises_num`,
  CONCAT('№', `fh`.`include_restriction_number`, ' - ', DATE_FORMAT(`fh`.`include_restriction_date`, '%d.%m.%Y')) AS `include_restriction`,
  CONCAT('№', `fh`.`exclude_restriction_number`, ' - ', DATE_FORMAT(`fh`.`exclude_restriction_date`, '%d.%m.%Y')) AS `exclude_restriction`
FROM (((`premises` `p`
  JOIN `v_registry_full_stat_social_premises_max` `fpa`
    ON ((`p`.`id_premises` = `fpa`.`id_premises`)))
  JOIN `funds_history` `fh`
    ON ((`fpa`.`id_fund` = `fh`.`id_fund`)))
  LEFT JOIN `v_registry_full_stat_concated_municipal_sub_premises` `spn`
    ON ((`p`.`id_premises` = `spn`.`id_premises`)))
WHERE (`p`.`deleted` <> 1)
UNION ALL
SELECT
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  CONCAT(`p`.`premises_num`, '(', `sp`.`sub_premises_num`, ')') AS `CONCAT(p.premises_num, '(', sp.sub_premises_num, ')')`,
  CONCAT('№', `fh`.`include_restriction_number`, ' - ', DATE_FORMAT(`fh`.`include_restriction_date`, '%d.%m.%Y')) AS `include_restriction`,
  CONCAT('№', `fh`.`exclude_restriction_number`, ' - ', DATE_FORMAT(`fh`.`exclude_restriction_date`, '%d.%m.%Y')) AS `exclude_restriction`
FROM (((`v_registry_full_stat_social_sub_premises_max` `spa`
  JOIN `sub_premises` `sp`
    ON ((`spa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
  JOIN `funds_history` `fh`
    ON ((`spa`.`id_fund` = `fh`.`id_fund`)))
WHERE (`sp`.`deleted` <> 1);

--
-- Создать представление `v_registry_full_stat_social_rest_ordered`
--
CREATE
VIEW v_registry_full_stat_social_rest_ordered
AS
SELECT
  `v`.`id_building` AS `id_building`,
  `v`.`id_premises` AS `id_premises`,
  `v`.`premises_num` AS `premises_num`,
  `v`.`include_restriction` AS `include_restriction`,
  `v`.`exclude_restriction` AS `exclude_restriction`
FROM `v_registry_full_stat_social_rest` `v`
ORDER BY `v`.`id_building`, `v`.`premises_num`;

--
-- Создать представление `v_registry_full_stat_other_sub_premises_max`
--
CREATE
VIEW v_registry_full_stat_other_sub_premises_max
AS
SELECT
  `fspa`.`id_sub_premises` AS `id_sub_premises`,
  MAX(`fh`.`id_fund`) AS `id_fund`
FROM (`funds_sub_premises_assoc` `fspa`
  JOIN `funds_history` `fh`
    ON ((`fspa`.`id_fund` = `fh`.`id_fund`)))
WHERE (ISNULL(`fh`.`exclude_restriction_date`)
AND (`fh`.`deleted` <> 1)
AND (`fspa`.`deleted` <> 1)
AND (`fh`.`id_fund_type` NOT IN (1, 2, 3)))
GROUP BY `fspa`.`id_sub_premises`;

--
-- Создать представление `v_registry_full_stat_other_premises_max`
--
CREATE
VIEW v_registry_full_stat_other_premises_max
AS
SELECT
  `fspa`.`id_premises` AS `id_premises`,
  MAX(`fh`.`id_fund`) AS `id_fund`
FROM (`funds_premises_assoc` `fspa`
  JOIN `funds_history` `fh`
    ON ((`fspa`.`id_fund` = `fh`.`id_fund`)))
WHERE (ISNULL(`fh`.`exclude_restriction_date`)
AND (`fh`.`deleted` <> 1)
AND (`fspa`.`deleted` <> 1)
AND (`fh`.`id_fund_type` NOT IN (1, 2, 3)))
GROUP BY `fspa`.`id_premises`;

--
-- Создать представление `v_registry_full_stat_other_rest`
--
CREATE
VIEW v_registry_full_stat_other_rest
AS
SELECT
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  CONCAT(`p`.`premises_num`, IF(ISNULL(`spn`.`sub_premises`), '', CONCAT('(', `spn`.`sub_premises`, ')'))) AS `premises_num`,
  CONCAT('№', `fh`.`include_restriction_number`, ' - ', DATE_FORMAT(`fh`.`include_restriction_date`, '%d.%m.%Y')) AS `include_restriction`,
  CONCAT('№', `fh`.`exclude_restriction_number`, ' - ', DATE_FORMAT(`fh`.`exclude_restriction_date`, '%d.%m.%Y')) AS `exclude_restriction`
FROM (((`premises` `p`
  JOIN `v_registry_full_stat_other_premises_max` `fpa`
    ON ((`p`.`id_premises` = `fpa`.`id_premises`)))
  JOIN `funds_history` `fh`
    ON ((`fpa`.`id_fund` = `fh`.`id_fund`)))
  LEFT JOIN `v_registry_full_stat_concated_municipal_sub_premises` `spn`
    ON ((`p`.`id_premises` = `spn`.`id_premises`)))
WHERE (`p`.`deleted` <> 1)
UNION ALL
SELECT
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  CONCAT(`p`.`premises_num`, '(', `sp`.`sub_premises_num`, ')') AS `CONCAT(p.premises_num, '(', sp.sub_premises_num, ')')`,
  CONCAT('№', `fh`.`include_restriction_number`, ' - ', DATE_FORMAT(`fh`.`include_restriction_date`, '%d.%m.%Y')) AS `include_restriction`,
  CONCAT('№', `fh`.`exclude_restriction_number`, ' - ', DATE_FORMAT(`fh`.`exclude_restriction_date`, '%d.%m.%Y')) AS `exclude_restriction`
FROM (((`v_registry_full_stat_other_sub_premises_max` `spa`
  JOIN `sub_premises` `sp`
    ON ((`spa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
  JOIN `funds_history` `fh`
    ON ((`spa`.`id_fund` = `fh`.`id_fund`)))
WHERE (`sp`.`deleted` <> 1);

--
-- Создать представление `v_registry_full_stat_other_rest_ordered`
--
CREATE
VIEW v_registry_full_stat_other_rest_ordered
AS
SELECT
  `v`.`id_building` AS `id_building`,
  `v`.`id_premises` AS `id_premises`,
  `v`.`premises_num` AS `premises_num`,
  `v`.`include_restriction` AS `include_restriction`,
  `v`.`exclude_restriction` AS `exclude_restriction`
FROM `v_registry_full_stat_other_rest` `v`
ORDER BY `v`.`id_building`, `v`.`premises_num`;

--
-- Создать представление `v_registry_full_stat_commercial_sub_premises_max`
--
CREATE
VIEW v_registry_full_stat_commercial_sub_premises_max
AS
SELECT
  `fspa`.`id_sub_premises` AS `id_sub_premises`,
  MAX(`fh`.`id_fund`) AS `id_fund`
FROM (`funds_sub_premises_assoc` `fspa`
  JOIN `funds_history` `fh`
    ON ((`fspa`.`id_fund` = `fh`.`id_fund`)))
WHERE (ISNULL(`fh`.`exclude_restriction_date`)
AND (`fh`.`deleted` <> 1)
AND (`fspa`.`deleted` <> 1)
AND (`fh`.`id_fund_type` = 2))
GROUP BY `fspa`.`id_sub_premises`;

--
-- Создать представление `v_registry_full_stat_commercial_premises_max`
--
CREATE
VIEW v_registry_full_stat_commercial_premises_max
AS
SELECT
  `fspa`.`id_premises` AS `id_premises`,
  MAX(`fh`.`id_fund`) AS `id_fund`
FROM (`funds_premises_assoc` `fspa`
  JOIN `funds_history` `fh`
    ON ((`fspa`.`id_fund` = `fh`.`id_fund`)))
WHERE (ISNULL(`fh`.`exclude_restriction_date`)
AND (`fh`.`deleted` <> 1)
AND (`fspa`.`deleted` <> 1)
AND (`fh`.`id_fund_type` = 2))
GROUP BY `fspa`.`id_premises`;

--
-- Создать представление `v_registry_full_stat_commercial_rest`
--
CREATE
VIEW v_registry_full_stat_commercial_rest
AS
SELECT
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  CONCAT(`p`.`premises_num`, IF(ISNULL(`spn`.`sub_premises`), '', CONCAT('(', `spn`.`sub_premises`, ')'))) AS `premises_num`,
  CONCAT('№', `fh`.`include_restriction_number`, ' - ', DATE_FORMAT(`fh`.`include_restriction_date`, '%d.%m.%Y')) AS `include_restriction`,
  CONCAT('№', `fh`.`exclude_restriction_number`, ' - ', DATE_FORMAT(`fh`.`exclude_restriction_date`, '%d.%m.%Y')) AS `exclude_restriction`
FROM (((`premises` `p`
  JOIN `v_registry_full_stat_commercial_premises_max` `fpa`
    ON ((`p`.`id_premises` = `fpa`.`id_premises`)))
  JOIN `funds_history` `fh`
    ON ((`fpa`.`id_fund` = `fh`.`id_fund`)))
  LEFT JOIN `v_registry_full_stat_concated_municipal_sub_premises` `spn`
    ON ((`p`.`id_premises` = `spn`.`id_premises`)))
WHERE (`p`.`deleted` <> 1)
UNION ALL
SELECT
  `p`.`id_building` AS `id_building`,
  `p`.`id_premises` AS `id_premises`,
  CONCAT(`p`.`premises_num`, '(', `sp`.`sub_premises_num`, ')') AS `CONCAT(p.premises_num, '(', sp.sub_premises_num, ')')`,
  CONCAT('№', `fh`.`include_restriction_number`, ' - ', DATE_FORMAT(`fh`.`include_restriction_date`, '%d.%m.%Y')) AS `include_restriction`,
  CONCAT('№', `fh`.`exclude_restriction_number`, ' - ', DATE_FORMAT(`fh`.`exclude_restriction_date`, '%d.%m.%Y')) AS `exclude_restriction`
FROM (((`v_registry_full_stat_commercial_sub_premises_max` `spa`
  JOIN `sub_premises` `sp`
    ON ((`spa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
  JOIN `funds_history` `fh`
    ON ((`spa`.`id_fund` = `fh`.`id_fund`)))
WHERE (`sp`.`deleted` <> 1);

--
-- Создать представление `v_registry_full_stat_commercial_rest_ordered`
--
CREATE
VIEW v_registry_full_stat_commercial_rest_ordered
AS
SELECT
  `v`.`id_building` AS `id_building`,
  `v`.`id_premises` AS `id_premises`,
  `v`.`premises_num` AS `premises_num`,
  `v`.`include_restriction` AS `include_restriction`,
  `v`.`exclude_restriction` AS `exclude_restriction`
FROM `v_registry_full_stat_commercial_rest` `v`
ORDER BY `v`.`id_building`, `v`.`premises_num`;

--
-- Создать представление `v_premises_current_fund`
--
CREATE
VIEW v_premises_current_fund
AS
SELECT
  `fspa`.`id_premises` AS `id_premises`,
  MAX(`fh`.`id_fund`) AS `id_fund`
FROM (`funds_premises_assoc` `fspa`
  JOIN `funds_history` `fh`
    ON ((`fspa`.`id_fund` = `fh`.`id_fund`)))
WHERE (ISNULL(`fh`.`exclude_restriction_date`)
AND (`fh`.`deleted` <> 1)
AND (`fspa`.`deleted` <> 1))
GROUP BY `fspa`.`id_premises`;

--
-- Создать представление `v_premises_special_fund`
--
CREATE
VIEW v_premises_special_fund
AS
SELECT
  `p`.`id_premises` AS `id_premises`,
  `p`.`id_building` AS `id_building`,
  `p`.`id_state` AS `id_state`,
  `p`.`premises_num` AS `premises_num`,
  `p`.`total_area` AS `total_area`,
  `p`.`living_area` AS `living_area`,
  `p`.`num_beds` AS `num_beds`,
  `p`.`id_premises_type` AS `id_premises_type`,
  `p`.`id_premises_kind` AS `id_premises_kind`,
  `p`.`floor` AS `floor`,
  `p`.`cadastral_num` AS `cadastral_num`,
  `p`.`cadastral_cost` AS `cadastral_cost`,
  `p`.`balance_cost` AS `balance_cost`,
  `p`.`description` AS `description`,
  `p`.`deleted` AS `deleted`,
  `fh`.`id_fund` AS `id_fund`
FROM ((`funds_history` `fh`
  JOIN `v_premises_current_fund` `cf`
    ON ((`cf`.`id_fund` = `fh`.`id_fund`)))
  JOIN `v_premises_municipal` `p`
    ON ((`p`.`id_premises` = `cf`.`id_premises`)))
WHERE ((`fh`.`id_fund_type` = 3)
AND (`p`.`deleted` <> 1));

--
-- Создать представление `v_premises_social_fund`
--
CREATE
VIEW v_premises_social_fund
AS
SELECT
  `p`.`id_premises` AS `id_premises`,
  `p`.`id_building` AS `id_building`,
  `p`.`id_state` AS `id_state`,
  `p`.`premises_num` AS `premises_num`,
  `p`.`total_area` AS `total_area`,
  `p`.`living_area` AS `living_area`,
  `p`.`num_beds` AS `num_beds`,
  `p`.`id_premises_type` AS `id_premises_type`,
  `p`.`id_premises_kind` AS `id_premises_kind`,
  `p`.`floor` AS `floor`,
  `p`.`cadastral_num` AS `cadastral_num`,
  `p`.`cadastral_cost` AS `cadastral_cost`,
  `p`.`balance_cost` AS `balance_cost`,
  `p`.`description` AS `description`,
  `p`.`deleted` AS `deleted`,
  `fh`.`id_fund` AS `id_fund`,
  `fh`.`id_fund_type` AS `id_fund_type`
FROM ((`funds_history` `fh`
  JOIN `v_premises_current_fund` `cf`
    ON ((`cf`.`id_fund` = `fh`.`id_fund`)))
  JOIN `v_premises_municipal` `p`
    ON ((`p`.`id_premises` = `cf`.`id_premises`)))
WHERE ((`fh`.`id_fund_type` = 1)
AND (`p`.`deleted` <> 1));

--
-- Создать представление `v_premises_other_fund`
--
CREATE
VIEW v_premises_other_fund
AS
SELECT
  `p`.`id_premises` AS `id_premises`,
  `p`.`id_building` AS `id_building`,
  `p`.`id_state` AS `id_state`,
  `p`.`premises_num` AS `premises_num`,
  `p`.`total_area` AS `total_area`,
  `p`.`living_area` AS `living_area`,
  `p`.`num_beds` AS `num_beds`,
  `p`.`id_premises_type` AS `id_premises_type`,
  `p`.`id_premises_kind` AS `id_premises_kind`,
  `p`.`floor` AS `floor`,
  `p`.`cadastral_num` AS `cadastral_num`,
  `p`.`cadastral_cost` AS `cadastral_cost`,
  `p`.`balance_cost` AS `balance_cost`,
  `p`.`description` AS `description`,
  `p`.`deleted` AS `deleted`,
  `fh`.`id_fund` AS `id_fund`
FROM ((`funds_history` `fh`
  JOIN `v_premises_current_fund` `cf`
    ON ((`cf`.`id_fund` = `fh`.`id_fund`)))
  JOIN `v_premises_municipal` `p`
    ON ((`p`.`id_premises` = `cf`.`id_premises`)))
WHERE ((`fh`.`id_fund_type` NOT IN (1, 2, 3))
AND (`p`.`deleted` <> 1));

--
-- Создать представление `v_premises_commercial_fund`
--
CREATE
VIEW v_premises_commercial_fund
AS
SELECT
  `p`.`id_premises` AS `id_premises`,
  `p`.`id_building` AS `id_building`,
  `p`.`id_state` AS `id_state`,
  `p`.`premises_num` AS `premises_num`,
  `p`.`total_area` AS `total_area`,
  `p`.`living_area` AS `living_area`,
  `p`.`num_beds` AS `num_beds`,
  `p`.`id_premises_type` AS `id_premises_type`,
  `p`.`id_premises_kind` AS `id_premises_kind`,
  `p`.`floor` AS `floor`,
  `p`.`cadastral_num` AS `cadastral_num`,
  `p`.`cadastral_cost` AS `cadastral_cost`,
  `p`.`balance_cost` AS `balance_cost`,
  `p`.`description` AS `description`,
  `p`.`deleted` AS `deleted`,
  `fh`.`id_fund` AS `id_fund`
FROM ((`funds_history` `fh`
  JOIN `v_premises_current_fund` `cf`
    ON ((`cf`.`id_fund` = `fh`.`id_fund`)))
  JOIN `v_premises_municipal` `p`
    ON ((`p`.`id_premises` = `cf`.`id_premises`)))
WHERE ((`fh`.`id_fund_type` = 2)
AND (`p`.`deleted` <> 1));

--
-- Создать представление `v_funds_history_not_exclude`
--
CREATE
VIEW v_funds_history_not_exclude
AS
SELECT
  `fpa`.`id_building` AS `id_building`,
  NULL AS `id_premises`,
  NULL AS `id_sub_premises`,
  `fh`.`id_fund` AS `id_fund`,
  `fh`.`id_fund_type` AS `id_fund_type`,
  `fh`.`protocol_number` AS `protocol_number`,
  `fh`.`protocol_date` AS `protocol_date`,
  `fh`.`include_restriction_number` AS `include_restriction_number`,
  `fh`.`include_restriction_date` AS `include_restriction_date`,
  `fh`.`include_restriction_description` AS `include_restriction_description`,
  `fh`.`exclude_restriction_number` AS `exclude_restriction_number`,
  `fh`.`exclude_restriction_date` AS `exclude_restriction_date`,
  `fh`.`exclude_restriction_description` AS `exclude_restriction_description`,
  `fh`.`description` AS `description`,
  `fh`.`deleted` AS `deleted`
FROM (`funds_history` `fh`
  JOIN `funds_buildings_assoc` `fpa`
    ON ((`fh`.`id_fund` = `fpa`.`id_fund`)))
WHERE ((`fh`.`deleted` = 0)
AND (`fpa`.`deleted` = 0)
AND ISNULL(`fh`.`exclude_restriction_date`))
UNION ALL
SELECT
  `p`.`id_building` AS `id_building`,
  `fpa`.`id_premises` AS `id_premises`,
  NULL AS `id_sub_premises`,
  `fh`.`id_fund` AS `id_fund`,
  `fh`.`id_fund_type` AS `id_fund_type`,
  `fh`.`protocol_number` AS `protocol_number`,
  `fh`.`protocol_date` AS `protocol_date`,
  `fh`.`include_restriction_number` AS `include_restriction_number`,
  `fh`.`include_restriction_date` AS `include_restriction_date`,
  `fh`.`include_restriction_description` AS `include_restriction_description`,
  `fh`.`exclude_restriction_number` AS `exclude_restriction_number`,
  `fh`.`exclude_restriction_date` AS `exclude_restriction_date`,
  `fh`.`exclude_restriction_description` AS `exclude_restriction_description`,
  `fh`.`description` AS `description`,
  `fh`.`deleted` AS `deleted`
FROM ((`funds_history` `fh`
  JOIN `funds_premises_assoc` `fpa`
    ON ((`fh`.`id_fund` = `fpa`.`id_fund`)))
  JOIN `premises` `p`
    ON ((`fpa`.`id_premises` = `p`.`id_premises`)))
WHERE ((`fh`.`deleted` = 0)
AND (`fpa`.`deleted` = 0)
AND ISNULL(`fh`.`exclude_restriction_date`))
UNION ALL
SELECT
  `p`.`id_building` AS `id_building`,
  `sp`.`id_premises` AS `id_premises`,
  `fpa`.`id_sub_premises` AS `id_sub_premises`,
  `fh`.`id_fund` AS `id_fund`,
  `fh`.`id_fund_type` AS `id_fund_type`,
  `fh`.`protocol_number` AS `protocol_number`,
  `fh`.`protocol_date` AS `protocol_date`,
  `fh`.`include_restriction_number` AS `include_restriction_number`,
  `fh`.`include_restriction_date` AS `include_restriction_date`,
  `fh`.`include_restriction_description` AS `include_restriction_description`,
  `fh`.`exclude_restriction_number` AS `exclude_restriction_number`,
  `fh`.`exclude_restriction_date` AS `exclude_restriction_date`,
  `fh`.`exclude_restriction_description` AS `exclude_restriction_description`,
  `fh`.`description` AS `description`,
  `fh`.`deleted` AS `deleted`
FROM (((`funds_history` `fh`
  JOIN `funds_sub_premises_assoc` `fpa`
    ON ((`fh`.`id_fund` = `fpa`.`id_fund`)))
  JOIN `sub_premises` `sp`
    ON ((`fpa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
WHERE ((`fh`.`deleted` = 0)
AND (`fpa`.`deleted` = 0)
AND ISNULL(`fh`.`exclude_restriction_date`));

--
-- Создать представление `v_funds_history_not_exclude_max_date`
--
CREATE
VIEW v_funds_history_not_exclude_max_date
AS
SELECT
  `vfhe`.`id_building` AS `id_building`,
  `vfhe`.`id_premises` AS `id_premises`,
  `vfhe`.`id_sub_premises` AS `id_sub_premises`,
  MAX(`vfhe`.`include_restriction_date`) AS `include_restriction_date`
FROM `v_funds_history_not_exclude` `vfhe`
GROUP BY `vfhe`.`id_building`,
         `vfhe`.`id_premises`,
         `vfhe`.`id_sub_premises`;

--
-- Создать представление `v_funds_history_not_exclude_last_fund`
--
CREATE
VIEW v_funds_history_not_exclude_last_fund
AS
SELECT
  `vfhe`.`id_building` AS `id_building`,
  `vfhe`.`id_premises` AS `id_premises`,
  `vfhe`.`id_sub_premises` AS `id_sub_premises`,
  MAX(`vfhe`.`id_fund`) AS `id_fund`
FROM (`v_funds_history_not_exclude` `vfhe`
  JOIN `v_funds_history_not_exclude_max_date` `vfhemd`
    ON (((IFNULL(`vfhe`.`id_building`, '') = IFNULL(`vfhemd`.`id_building`, ''))
    AND (IFNULL(`vfhe`.`id_premises`, '') = IFNULL(`vfhemd`.`id_premises`, ''))
    AND (IFNULL(`vfhe`.`id_sub_premises`, '') = IFNULL(`vfhemd`.`id_sub_premises`, ''))
    AND (IFNULL(`vfhe`.`include_restriction_date`, '') = IFNULL(`vfhemd`.`include_restriction_date`, '')))))
GROUP BY `vfhe`.`id_building`,
         `vfhe`.`id_premises`,
         `vfhe`.`id_sub_premises`;

--
-- Создать представление `v_funds_history_exclude`
--
CREATE
VIEW v_funds_history_exclude
AS
SELECT
  `fpa`.`id_building` AS `id_building`,
  NULL AS `id_premises`,
  NULL AS `id_sub_premises`,
  `fh`.`id_fund` AS `id_fund`,
  `fh`.`id_fund_type` AS `id_fund_type`,
  `fh`.`protocol_number` AS `protocol_number`,
  `fh`.`protocol_date` AS `protocol_date`,
  `fh`.`include_restriction_number` AS `include_restriction_number`,
  `fh`.`include_restriction_date` AS `include_restriction_date`,
  `fh`.`include_restriction_description` AS `include_restriction_description`,
  `fh`.`exclude_restriction_number` AS `exclude_restriction_number`,
  `fh`.`exclude_restriction_date` AS `exclude_restriction_date`,
  `fh`.`exclude_restriction_description` AS `exclude_restriction_description`,
  `fh`.`description` AS `description`,
  `fh`.`deleted` AS `deleted`
FROM (`funds_history` `fh`
  JOIN `funds_buildings_assoc` `fpa`
    ON ((`fh`.`id_fund` = `fpa`.`id_fund`)))
WHERE ((`fh`.`deleted` = 0)
AND (`fpa`.`deleted` = 0)
AND (`fh`.`exclude_restriction_date` IS NOT NULL))
UNION ALL
SELECT
  `p`.`id_building` AS `id_building`,
  `fpa`.`id_premises` AS `id_premises`,
  NULL AS `id_sub_premises`,
  `fh`.`id_fund` AS `id_fund`,
  `fh`.`id_fund_type` AS `id_fund_type`,
  `fh`.`protocol_number` AS `protocol_number`,
  `fh`.`protocol_date` AS `protocol_date`,
  `fh`.`include_restriction_number` AS `include_restriction_number`,
  `fh`.`include_restriction_date` AS `include_restriction_date`,
  `fh`.`include_restriction_description` AS `include_restriction_description`,
  `fh`.`exclude_restriction_number` AS `exclude_restriction_number`,
  `fh`.`exclude_restriction_date` AS `exclude_restriction_date`,
  `fh`.`exclude_restriction_description` AS `exclude_restriction_description`,
  `fh`.`description` AS `description`,
  `fh`.`deleted` AS `deleted`
FROM ((`funds_history` `fh`
  JOIN `funds_premises_assoc` `fpa`
    ON ((`fh`.`id_fund` = `fpa`.`id_fund`)))
  JOIN `premises` `p`
    ON ((`fpa`.`id_premises` = `p`.`id_premises`)))
WHERE ((`fh`.`deleted` = 0)
AND (`fpa`.`deleted` = 0)
AND (`fh`.`exclude_restriction_date` IS NOT NULL))
UNION ALL
SELECT
  `p`.`id_building` AS `id_building`,
  `sp`.`id_premises` AS `id_premises`,
  `fpa`.`id_sub_premises` AS `id_sub_premises`,
  `fh`.`id_fund` AS `id_fund`,
  `fh`.`id_fund_type` AS `id_fund_type`,
  `fh`.`protocol_number` AS `protocol_number`,
  `fh`.`protocol_date` AS `protocol_date`,
  `fh`.`include_restriction_number` AS `include_restriction_number`,
  `fh`.`include_restriction_date` AS `include_restriction_date`,
  `fh`.`include_restriction_description` AS `include_restriction_description`,
  `fh`.`exclude_restriction_number` AS `exclude_restriction_number`,
  `fh`.`exclude_restriction_date` AS `exclude_restriction_date`,
  `fh`.`exclude_restriction_description` AS `exclude_restriction_description`,
  `fh`.`description` AS `description`,
  `fh`.`deleted` AS `deleted`
FROM (((`funds_history` `fh`
  JOIN `funds_sub_premises_assoc` `fpa`
    ON ((`fh`.`id_fund` = `fpa`.`id_fund`)))
  JOIN `sub_premises` `sp`
    ON ((`fpa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  JOIN `premises` `p`
    ON ((`sp`.`id_premises` = `p`.`id_premises`)))
WHERE ((`fh`.`deleted` = 0)
AND (`fpa`.`deleted` = 0)
AND (`fh`.`exclude_restriction_date` IS NOT NULL));

--
-- Создать представление `v_funds_history_exclude_max_date`
--
CREATE
VIEW v_funds_history_exclude_max_date
AS
SELECT
  `vfhe`.`id_building` AS `id_building`,
  `vfhe`.`id_premises` AS `id_premises`,
  `vfhe`.`id_sub_premises` AS `id_sub_premises`,
  MAX(`vfhe`.`exclude_restriction_date`) AS `exclude_restriction_date`
FROM `v_funds_history_exclude` `vfhe`
GROUP BY `vfhe`.`id_building`,
         `vfhe`.`id_premises`,
         `vfhe`.`id_sub_premises`;

--
-- Создать представление `v_funds_history_exclude_last_fund`
--
CREATE
VIEW v_funds_history_exclude_last_fund
AS
SELECT
  `vfhe`.`id_building` AS `id_building`,
  `vfhe`.`id_premises` AS `id_premises`,
  `vfhe`.`id_sub_premises` AS `id_sub_premises`,
  MAX(`vfhe`.`id_fund`) AS `id_fund`
FROM (`v_funds_history_exclude` `vfhe`
  JOIN `v_funds_history_exclude_max_date` `vfhemd`
    ON (((IFNULL(`vfhe`.`id_building`, '') = IFNULL(`vfhemd`.`id_building`, ''))
    AND (IFNULL(`vfhe`.`id_premises`, '') = IFNULL(`vfhemd`.`id_premises`, ''))
    AND (IFNULL(`vfhe`.`id_sub_premises`, '') = IFNULL(`vfhemd`.`id_sub_premises`, ''))
    AND (IFNULL(`vfhe`.`exclude_restriction_date`, '') = IFNULL(`vfhemd`.`exclude_restriction_date`, '')))))
GROUP BY `vfhe`.`id_building`,
         `vfhe`.`id_premises`,
         `vfhe`.`id_sub_premises`;

--
-- Создать представление `v_building_current_fund`
--
CREATE
VIEW v_building_current_fund
AS
SELECT
  `fba`.`id_building` AS `id_building`,
  MAX(`fh`.`id_fund`) AS `id_fund`
FROM (`funds_buildings_assoc` `fba`
  JOIN `funds_history` `fh`
    ON ((`fba`.`id_fund` = `fh`.`id_fund`)))
WHERE (ISNULL(`fh`.`exclude_restriction_date`)
AND (`fh`.`deleted` <> 1)
AND (`fba`.`deleted` <> 1))
GROUP BY `fba`.`id_building`;

--
-- Создать таблицу `kinships`
--
CREATE TABLE IF NOT EXISTS kinships (
  id_kinship int(11) NOT NULL AUTO_INCREMENT,
  kinship varchar(255) NOT NULL COMMENT 'Родственная связь',
  PRIMARY KEY (id_kinship)
)
ENGINE = INNODB,
AUTO_INCREMENT = 66,
AVG_ROW_LENGTH = 256,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `document_types`
--
CREATE TABLE IF NOT EXISTS document_types (
  id_document_type int(11) NOT NULL AUTO_INCREMENT,
  document_type varchar(50) NOT NULL,
  PRIMARY KEY (id_document_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 256,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `tenancy_persons`
--
CREATE TABLE IF NOT EXISTS tenancy_persons (
  id_person int(11) NOT NULL AUTO_INCREMENT,
  id_process int(11) NOT NULL,
  id_kinship int(11) NOT NULL COMMENT 'Родственная связь',
  surname varchar(50) NOT NULL COMMENT 'Фамилия',
  name varchar(50) NOT NULL COMMENT 'Имя',
  patronymic varchar(255) DEFAULT NULL COMMENT 'Отчество',
  date_of_birth date DEFAULT NULL COMMENT 'Дата рождения',
  id_document_type int(11) NOT NULL COMMENT 'Тип документа удостоверяющего личность',
  date_of_document_issue date DEFAULT NULL COMMENT 'Дата выдачи документа',
  document_num varchar(8) DEFAULT NULL COMMENT 'Номер документа',
  document_seria varchar(8) DEFAULT NULL COMMENT 'Серия документа',
  id_document_issued_by int(11) DEFAULT NULL COMMENT 'Документ выдан кем',
  snils varchar(14) DEFAULT NULL COMMENT 'СНИЛС',
  registration_id_street varchar(17) DEFAULT NULL COMMENT 'Улица регистрации',
  registration_house varchar(10) DEFAULT NULL COMMENT 'Дом регистрации',
  registration_flat varchar(15) DEFAULT NULL COMMENT 'Квартира регистрации',
  registration_room varchar(15) DEFAULT NULL,
  registration_date date DEFAULT NULL COMMENT 'Дата регистрации',
  residence_id_street varchar(17) DEFAULT NULL COMMENT 'Улица проживания',
  residence_house varchar(10) DEFAULT NULL COMMENT 'Дом проживания',
  residence_flat varchar(15) DEFAULT NULL COMMENT 'Квартира проживания',
  residence_room varchar(15) DEFAULT NULL COMMENT 'Комната проживания',
  personal_account varchar(255) DEFAULT NULL COMMENT 'Ранее было неиспользуемое поле банковского счета, адаптировано под номер телефона',
  email varchar(255) DEFAULT NULL COMMENT 'электронная почта',
  payment_account int(11) DEFAULT NULL,
  comment varchar(512) DEFAULT NULL COMMENT 'Комментарий',
  include_date date DEFAULT NULL COMMENT 'Дата включения участника в договор',
  exclude_date date DEFAULT NULL COMMENT 'Дата исключения участника из договора',
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_person)
)
ENGINE = INNODB,
AUTO_INCREMENT = 59315,
AVG_ROW_LENGTH = 130,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `tenancy_persons_after_insert`
--
CREATE TRIGGER tenancy_persons_after_insert
AFTER INSERT
ON tenancy_persons
FOR EACH ROW
BEGIN
  IF (NEW.id_process IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'id_process', NULL, NEW.id_process, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_kinship IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'id_kinship', NULL, NEW.id_kinship, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.surname IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'surname', NULL, NEW.surname, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.name IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'name', NULL, NEW.name, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.patronymic IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'patronymic', NULL, NEW.patronymic, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_of_birth IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'date_of_birth', NULL, NEW.date_of_birth, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_document_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'id_document_type', NULL, NEW.id_document_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.date_of_document_issue IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'date_of_document_issue', NULL, NEW.date_of_document_issue, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.document_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'document_num', NULL, NEW.document_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.document_seria IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'document_seria', NULL, NEW.document_seria, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_document_issued_by IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'id_document_issued_by', NULL, NEW.id_document_issued_by, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.snils IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'snils', NULL, NEW.snils, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.registration_id_street IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'registration_id_street', NULL, NEW.registration_id_street, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.registration_house IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'registration_house', NULL, NEW.registration_house, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.registration_flat IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'registration_flat', NULL, NEW.registration_flat, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.registration_room IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'registration_room', NULL, NEW.registration_room, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.registration_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'registration_date', NULL, NEW.registration_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.residence_id_street IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'residence_id_street', NULL, NEW.residence_id_street, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.residence_house IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'residence_house', NULL, NEW.residence_house, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.residence_flat IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'residence_flat', NULL, NEW.residence_flat, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.residence_room IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'residence_room', NULL, NEW.residence_room, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.personal_account IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'personal_account', NULL, NEW.personal_account, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.include_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'include_date', NULL, NEW.include_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.exclude_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'exclude_date', NULL, NEW.exclude_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.email IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'email', NULL, NEW.email, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.comment IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'comment', NULL, NEW.comment, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.id_kinship = 1
    OR NEW.email IS NOT NULL) THEN
    CALL update_kumi_accounts_tp_search_by_id_process(NEW.id_process);
  END IF;
END
$$

--
-- Создать триггер `tenancy_persons_after_update`
--
CREATE TRIGGER tenancy_persons_after_update
AFTER UPDATE
ON tenancy_persons
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'tenancy_persons', NEW.id_person, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_process <> OLD.id_process) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'id_process', OLD.id_process, NEW.id_process, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_kinship <> OLD.id_kinship) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'id_kinship', OLD.id_kinship, NEW.id_kinship, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.surname <> OLD.surname) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'surname', OLD.surname, NEW.surname, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.name <> OLD.name) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'name', OLD.name, NEW.name, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.patronymic IS NULL
      AND OLD.patronymic IS NULL)
      AND ((NEW.patronymic IS NULL
      AND OLD.patronymic IS NOT NULL)
      OR (NEW.patronymic IS NOT NULL
      AND OLD.patronymic IS NULL)
      OR (NEW.patronymic <> OLD.patronymic))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'patronymic', OLD.patronymic, NEW.patronymic, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_of_birth IS NULL
      AND OLD.date_of_birth IS NULL)
      AND ((NEW.date_of_birth IS NULL
      AND OLD.date_of_birth IS NOT NULL)
      OR (NEW.date_of_birth IS NOT NULL
      AND OLD.date_of_birth IS NULL)
      OR (NEW.date_of_birth <> OLD.date_of_birth))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'date_of_birth', OLD.date_of_birth, NEW.date_of_birth, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.id_document_type <> OLD.id_document_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'id_document_type', OLD.id_document_type, NEW.id_document_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.date_of_document_issue IS NULL
      AND OLD.date_of_document_issue IS NULL)
      AND ((NEW.date_of_document_issue IS NULL
      AND OLD.date_of_document_issue IS NOT NULL)
      OR (NEW.date_of_document_issue IS NOT NULL
      AND OLD.date_of_document_issue IS NULL)
      OR (NEW.date_of_document_issue <> OLD.date_of_document_issue))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'date_of_document_issue', OLD.date_of_document_issue, NEW.date_of_document_issue, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.document_num IS NULL
      AND OLD.document_num IS NULL)
      AND ((NEW.document_num IS NULL
      AND OLD.document_num IS NOT NULL)
      OR (NEW.document_num IS NOT NULL
      AND OLD.document_num IS NULL)
      OR (NEW.document_num <> OLD.document_num))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'document_num', OLD.document_num, NEW.document_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.document_seria IS NULL
      AND OLD.document_seria IS NULL)
      AND ((NEW.document_seria IS NULL
      AND OLD.document_seria IS NOT NULL)
      OR (NEW.document_seria IS NOT NULL
      AND OLD.document_seria IS NULL)
      OR (NEW.document_seria <> OLD.document_seria))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'document_seria', OLD.document_seria, NEW.document_seria, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.id_document_issued_by IS NULL
      AND OLD.id_document_issued_by IS NULL)
      AND ((NEW.id_document_issued_by IS NULL
      AND OLD.id_document_issued_by IS NOT NULL)
      OR (NEW.id_document_issued_by IS NOT NULL
      AND OLD.id_document_issued_by IS NULL)
      OR (NEW.id_document_issued_by <> OLD.id_document_issued_by))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'id_document_issued_by', OLD.id_document_issued_by, NEW.id_document_issued_by, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.snils IS NULL
      AND OLD.snils IS NULL)
      AND ((NEW.snils IS NULL
      AND OLD.snils IS NOT NULL)
      OR (NEW.snils IS NOT NULL
      AND OLD.snils IS NULL)
      OR (NEW.snils <> OLD.snils))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'snils', OLD.snils, NEW.snils, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.registration_id_street IS NULL
      AND OLD.registration_id_street IS NULL)
      AND ((NEW.registration_id_street IS NULL
      AND OLD.registration_id_street IS NOT NULL)
      OR (NEW.registration_id_street IS NOT NULL
      AND OLD.registration_id_street IS NULL)
      OR (NEW.registration_id_street <> OLD.registration_id_street))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'registration_id_street', OLD.registration_id_street, NEW.registration_id_street, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.registration_house IS NULL
      AND OLD.registration_house IS NULL)
      AND ((NEW.registration_house IS NULL
      AND OLD.registration_house IS NOT NULL)
      OR (NEW.registration_house IS NOT NULL
      AND OLD.registration_house IS NULL)
      OR (NEW.registration_house <> OLD.registration_house))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'registration_house', OLD.registration_house, NEW.registration_house, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.registration_flat IS NULL
      AND OLD.registration_flat IS NULL)
      AND ((NEW.registration_flat IS NULL
      AND OLD.registration_flat IS NOT NULL)
      OR (NEW.registration_flat IS NOT NULL
      AND OLD.registration_flat IS NULL)
      OR (NEW.registration_flat <> OLD.registration_flat))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'registration_flat', OLD.registration_flat, NEW.registration_flat, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.registration_room IS NULL
      AND OLD.registration_room IS NULL)
      AND ((NEW.registration_room IS NULL
      AND OLD.registration_room IS NOT NULL)
      OR (NEW.registration_room IS NOT NULL
      AND OLD.registration_room IS NULL)
      OR (NEW.registration_room <> OLD.registration_room))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'registration_room', OLD.registration_room, NEW.registration_room, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.registration_date IS NULL
      AND OLD.registration_date IS NULL)
      AND ((NEW.registration_date IS NULL
      AND OLD.registration_date IS NOT NULL)
      OR (NEW.registration_date IS NOT NULL
      AND OLD.registration_date IS NULL)
      OR (NEW.registration_date <> OLD.registration_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'registration_date', OLD.registration_date, NEW.registration_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.residence_id_street IS NULL
      AND OLD.residence_id_street IS NULL)
      AND ((NEW.residence_id_street IS NULL
      AND OLD.residence_id_street IS NOT NULL)
      OR (NEW.residence_id_street IS NOT NULL
      AND OLD.residence_id_street IS NULL)
      OR (NEW.residence_id_street <> OLD.residence_id_street))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'residence_id_street', OLD.residence_id_street, NEW.residence_id_street, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.residence_house IS NULL
      AND OLD.residence_house IS NULL)
      AND ((NEW.residence_house IS NULL
      AND OLD.residence_house IS NOT NULL)
      OR (NEW.residence_house IS NOT NULL
      AND OLD.residence_house IS NULL)
      OR (NEW.residence_house <> OLD.residence_house))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'residence_house', OLD.residence_house, NEW.residence_house, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.residence_flat IS NULL
      AND OLD.residence_flat IS NULL)
      AND ((NEW.residence_flat IS NULL
      AND OLD.residence_flat IS NOT NULL)
      OR (NEW.residence_flat IS NOT NULL
      AND OLD.residence_flat IS NULL)
      OR (NEW.residence_flat <> OLD.residence_flat))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'residence_flat', OLD.residence_flat, NEW.residence_flat, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.residence_room IS NULL
      AND OLD.residence_room IS NULL)
      AND ((NEW.residence_room IS NULL
      AND OLD.residence_room IS NOT NULL)
      OR (NEW.residence_room IS NOT NULL
      AND OLD.residence_room IS NULL)
      OR (NEW.residence_room <> OLD.residence_room))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'residence_room', OLD.residence_room, NEW.residence_room, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.personal_account IS NULL
      AND OLD.personal_account IS NULL)
      AND ((NEW.personal_account IS NULL
      AND OLD.personal_account IS NOT NULL)
      OR (NEW.personal_account IS NOT NULL
      AND OLD.personal_account IS NULL)
      OR (NEW.personal_account <> OLD.personal_account))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'personal_account', OLD.personal_account, NEW.personal_account, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.include_date IS NULL
      AND OLD.include_date IS NULL)
      AND ((NEW.include_date IS NULL
      AND OLD.include_date IS NOT NULL)
      OR (NEW.include_date IS NOT NULL
      AND OLD.include_date IS NULL)
      OR (NEW.include_date <> OLD.include_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'include_date', OLD.include_date, NEW.include_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.exclude_date IS NULL
      AND OLD.exclude_date IS NULL)
      AND ((NEW.exclude_date IS NULL
      AND OLD.exclude_date IS NOT NULL)
      OR (NEW.exclude_date IS NOT NULL
      AND OLD.exclude_date IS NULL)
      OR (NEW.exclude_date <> OLD.exclude_date))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'exclude_date', OLD.exclude_date, NEW.exclude_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.email IS NULL
      AND OLD.email IS NULL)
      AND ((NEW.email IS NULL
      AND OLD.email IS NOT NULL)
      OR (NEW.email IS NOT NULL
      AND OLD.email IS NULL)
      OR (NEW.email <> OLD.email))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'email', OLD.email, NEW.email, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.comment IS NULL
      AND OLD.comment IS NULL)
      AND ((NEW.comment IS NULL
      AND OLD.comment IS NOT NULL)
      OR (NEW.comment IS NOT NULL
      AND OLD.comment IS NULL)
      OR (NEW.comment <> OLD.comment))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'tenancy_persons', NEW.id_person, 'comment', OLD.comment, NEW.comment, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
  IF (NEW.id_kinship = 1
    OR OLD.id_kinship = 1
    OR (NOT (NEW.email IS NULL
    AND OLD.email IS NULL)
    AND ((NEW.email IS NULL
    AND OLD.email IS NOT NULL)
    OR (NEW.email IS NOT NULL
    AND OLD.email IS NULL)
    OR (NEW.email <> OLD.email)))) THEN
    CALL update_kumi_accounts_tp_search_by_id_process(NEW.id_process);
  END IF;
END
$$

--
-- Создать триггер `tenancy_persons_before_insert`
--
CREATE TRIGGER tenancy_persons_before_insert
BEFORE INSERT
ON tenancy_persons
FOR EACH ROW
BEGIN
  IF (NOT EXISTS (SELECT
        *
      FROM tenancy_processes tp
      WHERE tp.deleted = 0
      AND tp.id_process = NEW.id_process)) THEN
    SIGNAL SQLSTATE '45000' SET
    MESSAGE_TEXT = 'Невозможно добавить запись из-за нарушения ссылочной целостности';
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_persons
ADD CONSTRAINT FK_tenancy_persons_payment_acc FOREIGN KEY (payment_account)
REFERENCES payments_accounts (id_account) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_persons
ADD CONSTRAINT FK_persons_document_types_id_document_type FOREIGN KEY (id_document_type)
REFERENCES document_types (id_document_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_persons
ADD CONSTRAINT FK_persons_kinships_id_kinship FOREIGN KEY (id_kinship)
REFERENCES kinships (id_kinship) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_persons
ADD CONSTRAINT FK_tsta_id_agreement FOREIGN KEY (id_process)
REFERENCES tenancy_processes (id_process) ON DELETE CASCADE ON UPDATE CASCADE;

DELIMITER $$

--
-- Создать функцию `f_get_historical_tenancy_processes_sub_premises`
--
CREATE FUNCTION f_get_historical_tenancy_processes_sub_premises (id_current_process int, id_current_sub_premise int)
RETURNS varchar(4096) CHARSET utf8
BEGIN
  DECLARE result varchar(4096);
  SELECT
    GROUP_CONCAT(
    CONCAT(
    IF(tp.registration_num IS NULL AND tp.registration_date IS NULL, CONCAT('реестровый № ', tp.id_process), ''),
    IF(tp.registration_num IS NOT NULL, CONCAT('№ ', tp.registration_num), ''),
    IF(tp.registration_num IS NOT NULL AND tp.registration_date IS NOT NULL, ' ', ''),
    IF(tp.registration_date IS NOT NULL, CONCAT('от ', DATE_FORMAT(tp.registration_date, '%d.%m.%Y')), ''))
    ORDER BY tp.registration_date, tp.id_process
    SEPARATOR '$br$'
    ) INTO result
  FROM tenancy_processes tp,
       (SELECT
           tp1.surname,
           tp1.name,
           tp1.patronymic
         FROM tenancy_processes tp
           INNER JOIN tenancy_persons tp1
             ON tp.id_process = tp1.id_process
         WHERE tp1.deleted <> 1
         AND tp.id_process = id_current_process
         AND tp1.id_kinship = 1
         AND tp1.exclude_date IS NULL) tpc
  WHERE tp.deleted <> 1
  AND tp.id_process <> id_current_process
  AND EXISTS (SELECT
      *
    FROM tenancy_sub_premises_assoc tspa
    WHERE tspa.deleted <> 1
    AND tspa.id_process = tp.id_process
    AND tspa.id_sub_premises = id_current_sub_premise)
  AND EXISTS (SELECT
      *
    FROM tenancy_persons tp1
    WHERE tp1.id_kinship = 1
    AND tp1.exclude_date IS NULL
    AND tp1.deleted <> 1
    AND tp1.id_process = tp.id_process
    AND tp1.surname = tpc.surname
    AND tp1.name = tpc.name
    AND tp1.patronymic = tpc.patronymic);
  RETURN result;
END
$$

--
-- Создать функцию `f_get_historical_tenancy_processes_premises`
--
CREATE FUNCTION f_get_historical_tenancy_processes_premises (id_current_process int, id_current_premise int)
RETURNS varchar(4096) CHARSET utf8
BEGIN
  DECLARE result varchar(4096);
  SELECT
    GROUP_CONCAT(
    CONCAT(
    IF(tp.registration_num IS NULL AND tp.registration_date IS NULL, CONCAT('реестровый № ', tp.id_process), ''),
    IF(tp.registration_num IS NOT NULL, CONCAT('№ ', tp.registration_num), ''),
    IF(tp.registration_num IS NOT NULL AND tp.registration_date IS NOT NULL, ' ', ''),
    IF(tp.registration_date IS NOT NULL, CONCAT('от ', DATE_FORMAT(tp.registration_date, '%d.%m.%Y')), ''))
    ORDER BY tp.registration_date, tp.id_process
    SEPARATOR '$br$'
    ) INTO result
  FROM tenancy_processes tp,
       (SELECT
           tp1.surname,
           tp1.name,
           tp1.patronymic
         FROM tenancy_processes tp
           INNER JOIN tenancy_persons tp1
             ON tp.id_process = tp1.id_process
         WHERE tp1.deleted <> 1
         AND tp.id_process = id_current_process
         AND tp1.id_kinship = 1
         AND tp1.exclude_date IS NULL) tpc
  WHERE tp.deleted <> 1
  AND tp.id_process <> id_current_process
  AND EXISTS (SELECT
      *
    FROM tenancy_premises_assoc tpa
    WHERE tpa.deleted <> 1
    AND tpa.id_process = tp.id_process
    AND tpa.id_premises = id_current_premise)
  AND EXISTS (SELECT
      *
    FROM tenancy_persons tp1
    WHERE tp1.id_kinship = 1
    AND tp1.exclude_date IS NULL
    AND tp1.deleted <> 1
    AND tp1.id_process = tp.id_process
    AND tp1.surname = tpc.surname
    AND tp1.name = tpc.name
    AND tp1.patronymic = tpc.patronymic);
  RETURN result;
END
$$

--
-- Создать процедуру `kumi_accounts_import_2`
--
CREATE PROCEDURE kumi_accounts_import_2 ()
BEGIN
  DECLARE id_account_prop int;
  DECLARE account_prop varchar(255);
  DECLARE account_gis_zkh_prop varchar(255);
  DECLARE done integer DEFAULT 0;
  DECLARE cur CURSOR FOR
  SELECT
    pa.id_account,
    pa.account,
    pa.account_gis_zkh
  FROM payments_accounts pa;
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
  DROP TABLE IF EXISTS _accounts_prepared_info;
  CREATE TEMPORARY TABLE _accounts_prepared_info
  AS
  SELECT
    pa1.id_account AS id_account,
    GROUP_CONCAT(pa.`rent_ids` ORDER BY pa.`rent_ids` ASC SEPARATOR '') AS `rent_ids`,
    pa1.account,
    pa1.account_gis_zkh,
    p.tenant AS current_tenant,
    p.min_date AS start_date,
    p.date AS last_date,
    p.balance_output_tenancy,
    p.balance_output_penalties,
    p.balance_output_dgi,
    p.balance_output_padun,
    p.balance_pkk
  FROM payments_accounts pa1
    LEFT JOIN (SELECT
        papa.id_account AS id_account,
        GROUP_CONCAT(CONCAT('p', papa.`id_premises`) ORDER BY papa.`id_premises` ASC SEPARATOR '') AS `rent_ids`
      FROM (payments_account_premises_assoc papa
        JOIN `premises` `p`
          ON ((papa.`id_premises` = `p`.`id_premises`)))
      GROUP BY papa.id_account
      UNION ALL
      SELECT
        paspa.id_account AS id_account,
        GROUP_CONCAT(CONCAT('sp', paspa.`id_sub_premises`) ORDER BY paspa.`id_sub_premises` ASC SEPARATOR '') AS `rent_ids`
      FROM (payments_account_sub_premises_assoc paspa
        JOIN `sub_premises` `sp`
          ON ((paspa.`id_sub_premises` = `sp`.`id_sub_premises`)))
      GROUP BY paspa.id_account) pa
      ON pa1.id_account = pa.id_account
    LEFT JOIN (SELECT
        p.*,
        p_max.min_date
      FROM (SELECT
          p.id_account,
          MAX(p.date) AS date,
          MIN(p.date) AS min_date
        FROM payments p
        GROUP BY p.id_account) p_max
        JOIN payments p
          ON p_max.id_account = p.id_account
          AND p_max.date = p.date
      GROUP BY p.id_account) p
      ON pa.id_account = p.id_account
  GROUP BY pa1.id_account;

  CREATE INDEX _accounts_prepared_info_id_account ON _accounts_prepared_info (id_account);

  DROP TABLE IF EXISTS _tenancy_prepared_info;
  CREATE TEMPORARY TABLE _tenancy_prepared_info
  AS
  SELECT
    `ta`.`id_process` AS `id_process`,
    GROUP_CONCAT(`ta`.`rent_ids` ORDER BY `ta`.`rent_ids` ASC SEPARATOR '') AS `rent_ids`
  FROM (SELECT
      `tpa`.`id_process` AS `id_process`,
      GROUP_CONCAT(CONCAT('p', `tpa`.`id_premises`) ORDER BY `tpa`.`id_premises` ASC SEPARATOR '') AS `rent_ids`
    FROM (`tenancy_premises_assoc` `tpa`
      JOIN `premises` `p`
        ON ((`tpa`.`id_premises` = `p`.`id_premises`)))
    WHERE ((`tpa`.`deleted` <> 1))
    GROUP BY `tpa`.`id_process`
    UNION ALL
    SELECT
      `tspa`.`id_process` AS `id_process`,
      GROUP_CONCAT(CONCAT('sp', `tspa`.`id_sub_premises`) ORDER BY `tspa`.`id_sub_premises` ASC SEPARATOR '') AS `rent_ids`
    FROM (`tenancy_sub_premises_assoc` `tspa`
      JOIN `sub_premises` `sp`
        ON ((`tspa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
    WHERE ((`tspa`.`deleted` <> 1))
    GROUP BY `tspa`.`id_process`
    UNION ALL
    SELECT
      `tba`.`id_process` AS `id_process`,
      GROUP_CONCAT(CONCAT('b', `tba`.`id_building`) ORDER BY `tba`.`id_building` ASC SEPARATOR '') AS `rent_ids`
    FROM (`tenancy_buildings_assoc` `tba`
      JOIN `buildings` `b`
        ON ((`tba`.`id_building` = `b`.`id_building`)))
    WHERE ((`tba`.`deleted` <> 1))
    GROUP BY `tba`.`id_process`) `ta`
    JOIN tenancy_processes tp
      ON ta.id_process = tp.id_process
  WHERE tp.deleted <> 1
  GROUP BY `ta`.`id_process`;

  CREATE INDEX _tenancy_prepared_info_rent_ids ON _tenancy_prepared_info (rent_ids (255));

  OPEN cur;
circle1:
  WHILE done = 0 DO
    FETCH cur INTO id_account_prop, account_prop, account_gis_zkh_prop;
    IF (done = 1) THEN
      LEAVE circle1;
    END IF;

    INSERT INTO kumi_accounts (id_account, account, account_gis_zkh)
      VALUES (id_account_prop, account_prop, account_gis_zkh_prop);

    -- Ищем адресный идентификатор в _accounts_prepared_info
    SET @account_rent_ids_prop := (SELECT
        api.rent_ids
      FROM _accounts_prepared_info api
      WHERE api.id_account = id_account_prop);

    INSERT INTO kumi_accounts_t_processes_assoc (id_account, id_process, fraction)
      SELECT DISTINCT
        p.id_account,
        tp.id_process,
        1
      FROM tenancy_persons tp
        JOIN payments p
          ON TRIM(REPLACE(p.tenant, '  ', ' ')) = REPLACE(TRIM(CONCAT(tp.surname, ' ', tp.name, ' ', COALESCE(tp.patronymic, ''))), '  ', ' ')
      WHERE tp.deleted <> 1
      AND p.id_account = id_account_prop
      AND tp.id_process IN (SELECT
          tpi.id_process
        FROM _tenancy_prepared_info tpi
        WHERE tpi.rent_ids = @account_rent_ids_prop);
  END WHILE;
END
$$

--
-- Создать процедуру `kumi_accounts_import`
--
CREATE PROCEDURE kumi_accounts_import ()
BEGIN
  -- Определяем курсор прохода по всем наймам
  DECLARE id_process_prop int;
  DECLARE tenancy_rent_ids_prop varchar(255);
  DECLARE done integer DEFAULT 0;
  DECLARE cur CURSOR FOR
  SELECT
    `ta`.`id_process` AS `id_process`,
    GROUP_CONCAT(`ta`.`rent_ids` ORDER BY `ta`.`rent_ids` ASC SEPARATOR '') AS `rent_ids`
  FROM (SELECT
      `tpa`.`id_process` AS `id_process`,
      GROUP_CONCAT(CONCAT('p', `tpa`.`id_premises`) ORDER BY `tpa`.`id_premises` ASC SEPARATOR '') AS `rent_ids`
    FROM (`tenancy_premises_assoc` `tpa`
      JOIN `premises` `p`
        ON ((`tpa`.`id_premises` = `p`.`id_premises`)))
    WHERE ((`tpa`.`deleted` <> 1))
    GROUP BY `tpa`.`id_process`
    UNION ALL
    SELECT
      `tspa`.`id_process` AS `id_process`,
      GROUP_CONCAT(CONCAT('sp', `tspa`.`id_sub_premises`) ORDER BY `tspa`.`id_sub_premises` ASC SEPARATOR '') AS `rent_ids`
    FROM (`tenancy_sub_premises_assoc` `tspa`
      JOIN `sub_premises` `sp`
        ON ((`tspa`.`id_sub_premises` = `sp`.`id_sub_premises`)))
    WHERE ((`tspa`.`deleted` <> 1))
    GROUP BY `tspa`.`id_process`
    UNION ALL
    SELECT
      `tba`.`id_process` AS `id_process`,
      GROUP_CONCAT(CONCAT('b', `tba`.`id_building`) ORDER BY `tba`.`id_building` ASC SEPARATOR '') AS `rent_ids`
    FROM (`tenancy_buildings_assoc` `tba`
      JOIN `buildings` `b`
        ON ((`tba`.`id_building` = `b`.`id_building`)))
    WHERE ((`tba`.`deleted` <> 1))
    GROUP BY `tba`.`id_process`) `ta`
    JOIN tenancy_processes tp
      ON ta.id_process = tp.id_process
  WHERE tp.deleted <> 1
  GROUP BY `ta`.`id_process`;
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

  -- Подготавливаем таблицу адресов и базовой информации по лицевым счетам БКС 
  DROP TABLE IF EXISTS _accounts_prepared_info;
  CREATE TEMPORARY TABLE _accounts_prepared_info
  AS
  SELECT
    pa.id_account AS id_account,
    GROUP_CONCAT(pa.`rent_ids` ORDER BY pa.`rent_ids` ASC SEPARATOR '') AS `rent_ids`,
    pa1.account,
    pa1.account_gis_zkh,
    p.tenant AS current_tenant,
    p.min_date AS start_date,
    p.date AS last_date,
    p.balance_output_tenancy,
    p.balance_output_penalties,
    p.balance_output_dgi,
    p.balance_output_padun,
    p.balance_pkk
  FROM (SELECT
      papa.id_account AS id_account,
      GROUP_CONCAT(CONCAT('p', papa.`id_premises`) ORDER BY papa.`id_premises` ASC SEPARATOR '') AS `rent_ids`
    FROM (payments_account_premises_assoc papa
      JOIN `premises` `p`
        ON ((papa.`id_premises` = `p`.`id_premises`)))
    GROUP BY papa.id_account
    UNION ALL
    SELECT
      paspa.id_account AS id_account,
      GROUP_CONCAT(CONCAT('sp', paspa.`id_sub_premises`) ORDER BY paspa.`id_sub_premises` ASC SEPARATOR '') AS `rent_ids`
    FROM (payments_account_sub_premises_assoc paspa
      JOIN `sub_premises` `sp`
        ON ((paspa.`id_sub_premises` = `sp`.`id_sub_premises`)))
    GROUP BY paspa.id_account) pa
    JOIN payments_accounts pa1
      ON pa.id_account = pa1.id_account
    JOIN (SELECT
        p.*,
        p_max.min_date
      FROM (SELECT
          p.id_account,
          MAX(p.date) AS date,
          MIN(p.date) AS min_date
        FROM payments p
        GROUP BY p.id_account) p_max
        JOIN payments p
          ON p_max.id_account = p.id_account
          AND p_max.date = p.date
      GROUP BY p.id_account) p
      ON pa.id_account = p.id_account
  GROUP BY pa.id_account;

  CREATE INDEX _accounts_prepared_info_rent_ids ON _accounts_prepared_info (rent_ids (255));
  CREATE INDEX _accounts_prepared_info_id_account ON _accounts_prepared_info (id_account);

  -- Создаем таблицу ассоциации между ЛС БКС и ЛС КУМИ
  CREATE TABLE IF NOT EXISTS _accounts_bks_kumi_assoc (
    id_key int PRIMARY KEY AUTO_INCREMENT,
    id_account_kumi int,
    id_account_bks int
  );
  TRUNCATE _accounts_bks_kumi_assoc;
  -- Создаем таблицу с неоднозначной ассоциацией между наймом и лицевым счетом БКС
  CREATE TABLE IF NOT EXISTS _accounts_bks_tenancy_assoc_duplicates (
    id_key int PRIMARY KEY AUTO_INCREMENT,
    id_process int,
    id_account int
  );
  TRUNCATE _accounts_bks_tenancy_assoc_duplicates;
  -- Создаем таблицу с однозначной ассоциацией между наймом и лицевым счетом БКС
  CREATE TABLE IF NOT EXISTS _accounts_bks_tenancy_assoc_uni (
    id_key int PRIMARY KEY AUTO_INCREMENT,
    id_process int,
    id_account int
  );
  TRUNCATE _accounts_bks_tenancy_assoc_uni;
  -- Создаем таблицу для наймов, по которым не удалось найти ассоциацию с лицевым счетом
  CREATE TABLE IF NOT EXISTS _accounts_bks_tenancy_assoc_not_found (
    id_key int PRIMARY KEY AUTO_INCREMENT,
    id_process int,
    rent_ids varchar(255)
  );
  TRUNCATE _accounts_bks_tenancy_assoc_not_found;
  -- Проходим по курсору с наймами
  OPEN cur;
circle1:
  WHILE done = 0 DO
    FETCH cur INTO id_process_prop, tenancy_rent_ids_prop;
    IF (done = 1) THEN
      LEAVE circle1;
    END IF;
    -- Находим лицевой счет БКС из _accounts_prepared_info, в котором адресный идентификатор равен адресному идентификатору 
    -- из _tenancy_prepared_info и tenant в любой из строк payments равен любому из tenant в таблице tenancy_persons

    SET @id_account_bks_prop := NULL;

    -- Если лицевой счет найден и только один, запоминаем идентификатор
    IF ((SELECT
          COUNT(*)
        FROM (SELECT
            *
          FROM (SELECT
              *
            FROM tenancy_persons tp
            WHERE tp.id_process = id_process_prop
            AND tp.deleted <> 1
            AND tp.id_kinship = 1) tp
            JOIN (SELECT
                api.id_account,
                api.account,
                api.account_gis_zkh,
                api.balance_output_tenancy,
                api.balance_output_penalties,
                api.balance_output_dgi,
                api.balance_output_padun,
                api.balance_pkk,
                tenant
              FROM payments p
                JOIN (SELECT
                    *
                  FROM _accounts_prepared_info api
                  WHERE api.rent_ids = tenancy_rent_ids_prop) api
                  ON p.id_account = api.id_account
              GROUP BY api.id_account,
                       tenant) p
              ON TRIM(p.tenant) = TRIM(CONCAT(tp.surname, ' ', tp.name, ' ', IFNULL(tp.patronymic, '')))
          GROUP BY p.id_account) v) = 1) THEN
      SET @id_account_bks_prop := (SELECT
          p.id_account
        FROM (SELECT
            *
          FROM tenancy_persons tp
          WHERE tp.id_process = id_process_prop
          AND tp.deleted <> 1
          AND tp.id_kinship = 1) tp
          JOIN (SELECT
              api.id_account,
              api.account,
              api.account_gis_zkh,
              api.balance_output_tenancy,
              api.balance_output_penalties,
              api.balance_output_dgi,
              api.balance_output_padun,
              api.balance_pkk,
              tenant
            FROM payments p
              JOIN (SELECT
                  *
                FROM _accounts_prepared_info api
                WHERE api.rent_ids = tenancy_rent_ids_prop) api
                ON p.id_account = api.id_account
            GROUP BY api.id_account,
                     tenant) p
            ON TRIM(p.tenant) = TRIM(CONCAT(tp.surname, ' ', tp.name, ' ', IFNULL(tp.patronymic, '')))
        GROUP BY p.id_account);
      INSERT INTO _accounts_bks_tenancy_assoc_uni (id_process, id_account)
        VALUES (id_process_prop, @id_account_bks_prop);

    -- Если лицевых счетов больше одного, то выводим в таблицу дублей список и берем самый актуальный по дате идентификатор
    -- Больше одного лицевого счета может быть, если было разделение счетов. 
    -- В теории могут быть полные тески по одному адресу, но считаем такую вероятность незначительной
    -- Информация из таблицы дублей в будущем понадобится для объединения начислений
    ELSEIF ((SELECT
          COUNT(*)
        FROM (SELECT
            *
          FROM (SELECT
              *
            FROM tenancy_persons tp
            WHERE tp.id_process = id_process_prop
            AND tp.deleted <> 1
            AND tp.id_kinship = 1) tp
            JOIN (SELECT
                api.id_account,
                api.account,
                api.account_gis_zkh,
                api.balance_output_tenancy,
                api.balance_output_penalties,
                api.balance_output_dgi,
                api.balance_output_padun,
                api.balance_pkk,
                tenant
              FROM payments p
                JOIN (SELECT
                    *
                  FROM _accounts_prepared_info api
                  WHERE api.rent_ids = tenancy_rent_ids_prop) api
                  ON p.id_account = api.id_account
              GROUP BY api.id_account,
                       tenant) p
              ON TRIM(p.tenant) = TRIM(CONCAT(tp.surname, ' ', tp.name, ' ', IFNULL(tp.patronymic, '')))
          GROUP BY p.id_account) v) > 1) THEN
      INSERT INTO _accounts_bks_tenancy_assoc_duplicates (id_process, id_account)
        SELECT
          tp.id_process,
          p.id_account
        FROM (SELECT
            *
          FROM tenancy_persons tp
          WHERE tp.id_process = id_process_prop
          AND tp.deleted <> 1
          AND tp.id_kinship = 1) tp
          JOIN (SELECT
              api.id_account,
              api.account,
              api.account_gis_zkh,
              api.balance_output_tenancy,
              api.balance_output_penalties,
              api.balance_output_dgi,
              api.balance_output_padun,
              api.balance_pkk,
              tenant
            FROM payments p
              JOIN (SELECT
                  *
                FROM _accounts_prepared_info api
                WHERE api.rent_ids = tenancy_rent_ids_prop) api
                ON p.id_account = api.id_account
            GROUP BY api.id_account,
                     tenant) p
            ON TRIM(p.tenant) = TRIM(CONCAT(tp.surname, ' ', tp.name, ' ', IFNULL(tp.patronymic, '')))
        GROUP BY p.id_account;

      SET @id_account_bks_prop := (SELECT
          d.id_account
        FROM _accounts_bks_tenancy_assoc_duplicates d
          JOIN payments_accounts pa
            ON d.id_account = pa.id_account
          JOIN (SELECT
              p.id_account,
              MAX(p.date) AS max_date
            FROM payments p
            GROUP BY p.id_account) p
            ON pa.id_account = p.id_account
        WHERE id_process = id_process_prop
        ORDER BY p.max_date DESC, d.id_key DESC
        LIMIT 1);

    -- Если не удалось найти лицевой счет БКС, логируем ошибку
    ELSE
      INSERT INTO _accounts_bks_tenancy_assoc_not_found (id_process, rent_ids)
        VALUES (id_process_prop, tenancy_rent_ids_prop);
    END IF;

    -- Ищем лицевой счет в kumi_accounts по ассоциации id_account_kumi, id_account_bks
    SET @id_account_kumi_prop := (SELECT
        abka.id_account_kumi
      FROM _accounts_bks_kumi_assoc abka
      WHERE abka.id_account_bks = @id_account_bks_prop);

    -- Если лицеовй счет найден, привязываем к нему найденный найм
    IF (@id_account_kumi_prop IS NOT NULL) THEN
      INSERT INTO kumi_accounts_t_processes_assoc (id_account, id_process, fraction)
        VALUES (@id_account_kumi_prop, id_process_prop, 1);

    -- Если лицевой счет не найден, создаем новый и добавляем ассоциативную связь id_account_kumi, id_account_bks в _accounts_bks_kumi_assoc
    ELSE
      SET @account := 'н/а';
      SET @account_gis_zkh := NULL;

      IF (@id_account_bks_prop IS NOT NULL) THEN
        SELECT
          api.account,
          api.account_gis_zkh
        FROM _accounts_prepared_info api
        WHERE api.id_account = @id_account_bks_prop INTO @account, @account_gis_zkh;
      END IF;

      INSERT INTO kumi_accounts (account, account_gis_zkh, create_date)
        VALUES (@account, @account_gis_zkh, NOW());
      SET @id_account_kumi_prop := (SELECT
          LAST_INSERT_ID());

      INSERT INTO kumi_accounts_t_processes_assoc (id_account, id_process, fraction)
        VALUES (@id_account_kumi_prop, id_process_prop, 1);

      IF (@id_account_bks_prop IS NOT NULL) THEN
        INSERT INTO _accounts_bks_kumi_assoc (id_account_kumi, id_account_bks)
          VALUES (@id_account_kumi_prop, @id_account_bks_prop);
      END IF;
    END IF;
  END WHILE;

  -- Удаляем временные таблицы
  DROP TABLE _accounts_prepared_info;
END
$$

--
-- Создать процедуру `claims_import`
--
CREATE PROCEDURE claims_import ()
BEGIN
  DECLARE id_claim_prop int;
  DECLARE id_account_kumi_prop int;
  DECLARE id_account_bks_prop int;
  DECLARE done integer DEFAULT 0;
  DECLARE cur CURSOR FOR
  SELECT
    c.id_claim,
    c.id_account
  FROM claims c
  WHERE c.id_account_kumi IS NULL;

  -- обновляем однозначную ассоциацию
  UPDATE claims c
  SET c.id_account_kumi = (SELECT
      abka.id_account_kumi
    FROM _accounts_bks_kumi_assoc abka
    WHERE abka.id_account_bks = c.id_account);

  -- работаем с дублями
  OPEN cur;
circle1:
  WHILE done = 0 DO
    FETCH cur INTO id_claim_prop, id_account_bks_prop;
    IF (done = 1) THEN
      LEAVE circle1;
    END IF;

    -- Если только один ЛС КУМИ соответсвует ЛС БКС, то просто обновляем его
    IF ((SELECT
          COUNT(*)
        FROM (SELECT DISTINCT
            katpa.id_account AS id_account_kumi
          FROM _accounts_bks_tenancy_assoc_duplicates abtad
            JOIN payments_accounts pa
              ON abtad.id_account = pa.id_account
            LEFT JOIN kumi_accounts_t_processes_assoc katpa
              ON abtad.id_process = katpa.id_process
            LEFT JOIN kumi_accounts ka
              ON katpa.id_account = ka.id_account
          WHERE abtad.id_account = id_account_bks_prop) v) = 1) THEN

      UPDATE claims c
      SET c.id_account_kumi = (SELECT DISTINCT
          katpa.id_account AS id_account_kumi
        FROM _accounts_bks_tenancy_assoc_duplicates abtad
          JOIN payments_accounts pa
            ON abtad.id_account = pa.id_account
          LEFT JOIN kumi_accounts_t_processes_assoc katpa
            ON abtad.id_process = katpa.id_process
          LEFT JOIN kumi_accounts ka
            ON katpa.id_account = ka.id_account
        WHERE abtad.id_account = id_account_bks_prop)
      WHERE c.id_claim = id_claim_prop;
    ELSEIF ((SELECT
          COUNT(*)
        FROM (SELECT DISTINCT
            katpa.id_account AS id_account_kumi
          FROM _accounts_bks_tenancy_assoc_duplicates abtad
            JOIN payments_accounts pa
              ON abtad.id_account = pa.id_account
            LEFT JOIN kumi_accounts_t_processes_assoc katpa
              ON abtad.id_process = katpa.id_process
            LEFT JOIN kumi_accounts ka
              ON katpa.id_account = ka.id_account
          WHERE abtad.id_account = id_account_bks_prop) v) > 1) THEN

      SET @snp := (SELECT
          a.tenant
        FROM (SELECT
            c.id_account,
            TRIM(CONCAT(cp.surname, ' ', cp.name, ' ', IFNULL(cp.patronymic, ''))) AS tenant
          FROM claim_persons cp
            JOIN claims c
              ON cp.id_claim = c.id_claim
          WHERE cp.deleted <> 1
          AND c.deleted <> 1
          AND cp.id_claim = id_claim_prop) c
          JOIN (SELECT DISTINCT
              p.id_account,
              p.tenant
            FROM payments p
            WHERE p.id_account = id_account_bks_prop) a
            ON c.id_account = a.id_account
            AND c.tenant = a.tenant);

      SET @id_account_kumi := (SELECT DISTINCT
          katpa.id_account AS id_account_kumi
        FROM _accounts_bks_tenancy_assoc_duplicates abtad
          JOIN payments_accounts pa
            ON abtad.id_account = pa.id_account
          LEFT JOIN kumi_accounts_t_processes_assoc katpa
            ON abtad.id_process = katpa.id_process
          LEFT JOIN kumi_accounts ka
            ON katpa.id_account = ka.id_account
          LEFT JOIN tenancy_persons tp
            ON katpa.id_process = tp.id_process
        WHERE abtad.id_account = id_account_bks_prop
        AND tp.deleted <> 1
        AND TRIM(CONCAT(tp.surname, ' ', tp.name, ' ', IFNULL(tp.patronymic, ''))) = @snp);

      UPDATE claims c
      SET c.id_account_kumi = @id_account_kumi
      WHERE c.id_claim = id_claim_prop;

    END IF;
  END WHILE;

END
$$

DELIMITER ;

--
-- Создать представление `v_tenancy_active_processes`
--
CREATE
VIEW v_tenancy_active_processes
AS
SELECT
  `tp`.`id_process` AS `id_process`,
  `tba`.`id_building` AS `id_building`,
  `tpa`.`id_premises` AS `id_premises`,
  `tspa`.`id_sub_premises` AS `id_sub_premises`,
  GROUP_CONCAT(CONCAT(`tper`.`surname`, ' ', `tper`.`name`, ' ', IFNULL(`tper`.`patronymic`, '')) SEPARATOR ',') AS `tenants`,
  COUNT(0) AS `count_tenants`
FROM (((((`tenancy_processes` `tp`
  JOIN `tenancy_persons` `tper`
    ON ((`tp`.`id_process` = `tper`.`id_process`)))
  LEFT JOIN `tenancy_reasons` `treas`
    ON (((`tp`.`id_process` = `treas`.`id_process`)
    AND (`treas`.`deleted` = 0))))
  LEFT JOIN `tenancy_buildings_assoc` `tba`
    ON (((`tp`.`id_process` = `tba`.`id_process`)
    AND (`tba`.`deleted` = 0))))
  LEFT JOIN `tenancy_premises_assoc` `tpa`
    ON (((`tp`.`id_process` = `tpa`.`id_process`)
    AND (`tpa`.`deleted` = 0))))
  LEFT JOIN `tenancy_sub_premises_assoc` `tspa`
    ON (((`tp`.`id_process` = `tspa`.`id_process`)
    AND (`tspa`.`deleted` = 0))))
WHERE ((`tp`.`deleted` = 0)
AND (`tper`.`deleted` = 0)
AND ISNULL(`tper`.`exclude_date`)
AND (((RIGHT(TRIM(`tp`.`registration_num`), 1) <> 'н')
AND (ISNULL(`tp`.`end_date`)
OR ((`tp`.`end_date` IS NOT NULL)
AND (`tp`.`end_date` > NOW()))))
OR (ISNULL(`tp`.`registration_num`)
AND (`treas`.`id_reason` IS NOT NULL))
OR (ISNULL(`tp`.`registration_num`)
AND (`tper`.`id_person` IS NOT NULL))))
GROUP BY `tp`.`id_process`,
         `tba`.`id_building`,
         `tpa`.`id_premises`,
         `tspa`.`id_sub_premises`;

--
-- Создать представление `v_ressetle_info_sub_premises_from`
--
CREATE
VIEW v_ressetle_info_sub_premises_from
AS
SELECT
  `rispf`.`id_resettle_info` AS `id_resettle_info`,
  GROUP_CONCAT(`sp`.`sub_premises_num` SEPARATOR ', ') AS `sub_premises_num`,
  COUNT(0) AS `cnt`,
  SUM(`sp`.`total_area`) AS `total_area`,
  SUM(`sp`.`living_area`) AS `living_area`,
  `tp1`.`count_tenants` AS `count_tenants`,
  `tp2`.`count_owners` AS `count_owners`,
  `sp`.`id_state` AS `id_state`
FROM (((`resettle_info_sub_premises_from` `rispf`
  JOIN `sub_premises` `sp`
    ON ((`rispf`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  LEFT JOIN `v_tenancy_active_processes` `tp1`
    ON ((`sp`.`id_sub_premises` = `tp1`.`id_sub_premises`)))
  LEFT JOIN `v_owner_active_processes` `tp2`
    ON ((`sp`.`id_sub_premises` = `tp2`.`id_sub_premises`)))
WHERE (`rispf`.`deleted` = 0)
GROUP BY `rispf`.`id_resettle_info`;

--
-- Создать представление `v_premises_count_tenants`
--
CREATE
VIEW v_premises_count_tenants
AS
SELECT
  IF((`vtap`.`id_premises` IS NOT NULL), `vtap`.`id_premises`, IF((`vtap`.`id_sub_premises` IS NOT NULL), `p1`.`id_premises`, NULL)) AS `id_premise`,
  IF((`vtap`.`id_premises` IS NOT NULL), `p`.`id_building`, IF((`vtap`.`id_sub_premises` IS NOT NULL), `p1`.`id_building`, NULL)) AS `id_building`,
  SUM(`vtap`.`count_tenants`) AS `count_persons`
FROM (((`v_tenancy_active_processes` `vtap`
  LEFT JOIN `premises` `p`
    ON ((`vtap`.`id_premises` = `p`.`id_premises`)))
  LEFT JOIN `sub_premises` `sp`
    ON ((`vtap`.`id_sub_premises` = `sp`.`id_sub_premises`)))
  LEFT JOIN `premises` `p1`
    ON ((`sp`.`id_premises` = `p1`.`id_premises`)))
WHERE ((NOT ((UCASE(TRIM(`vtap`.`tenants`)) LIKE '%НИКТО НЕ ПРОПИСАН%')))
AND (NOT ((UCASE(TRIM(`vtap`.`tenants`)) LIKE '%НЕТ ПРОПИСАННЫХ%')))
AND (IF((`vtap`.`id_premises` IS NOT NULL), `vtap`.`id_premises`, IF((`vtap`.`id_sub_premises` IS NOT NULL), `p1`.`id_premises`, NULL)) IS NOT NULL))
GROUP BY `id_premise`;

--
-- Создать представление `v_premises_count_persons`
--
CREATE
VIEW v_premises_count_persons
AS
SELECT
  `p`.`id_premises` AS `id_premises`,
  `p`.`id_building` AS `id_building`,
  (IFNULL(`vpct`.`count_persons`, 0) + IFNULL(`vpco`.`count_persons`, 0)) AS `count_persons`
FROM ((`premises` `p`
  LEFT JOIN `v_premises_count_tenants` `vpct`
    ON ((`p`.`id_premises` = `vpct`.`id_premise`)))
  LEFT JOIN `v_premises_count_owners` `vpco`
    ON ((`p`.`id_premises` = `vpco`.`id_premise`)))
WHERE ((`vpct`.`id_premise` IS NOT NULL)
OR (`vpco`.`id_premise` IS NOT NULL));

--
-- Создать представление `v_buildings_count_persons`
--
CREATE
VIEW v_buildings_count_persons
AS
SELECT
  `vpcp`.`id_building` AS `id_building`,
  SUM(`vpcp`.`count_persons`) AS `count_persons`
FROM `v_premises_count_persons` `vpcp`
GROUP BY `vpcp`.`id_building`;

--
-- Создать представление `v_buildings_count_tenants`
--
CREATE
VIEW v_buildings_count_tenants
AS
SELECT
  `vpct`.`id_building` AS `id_building`,
  SUM(`vpct`.`count_persons`) AS `count_persons`
FROM `v_premises_count_tenants` `vpct`
GROUP BY `vpct`.`id_building`;

--
-- Создать таблицу `documents_issued_by`
--
CREATE TABLE IF NOT EXISTS documents_issued_by (
  id_document_issued_by int(11) NOT NULL AUTO_INCREMENT,
  document_issued_by varchar(255) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_document_issued_by)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1016,
AVG_ROW_LENGTH = 186,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Справочник ГОМ''''ов и т.д., выдающих документ, удостоверяющий личность';

DELIMITER $$

--
-- Создать триггер `documents_issued_by_after_insert`
--
CREATE TRIGGER documents_issued_by_after_insert
AFTER INSERT
ON documents_issued_by
FOR EACH ROW
BEGIN
  IF (NEW.document_issued_by IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'documents_issued_by', NEW.id_document_issued_by, 'document_issued_by', NULL, NEW.document_issued_by, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `documents_issued_by_after_update`
--
CREATE TRIGGER documents_issued_by_after_update
AFTER UPDATE
ON documents_issued_by
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'documents_issued_by', NEW.id_document_issued_by, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.document_issued_by <> OLD.document_issued_by) THEN
      INSERT INTO `log`
        VALUES (NULL, 'documents_issued_by', NEW.id_document_issued_by, 'document_issued_by', OLD.document_issued_by, NEW.document_issued_by, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `documents_issued_by_before_update`
--
CREATE TRIGGER documents_issued_by_before_update
BEFORE UPDATE
ON documents_issued_by
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM tenancy_persons
        WHERE deleted <> 1
        AND id_document_issued_by = NEW.id_document_issued_by) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить орган, выдающий документы, удостоверяющие личность, т.к. необходимо сначала удалить все зависимые записи';
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_persons
ADD CONSTRAINT FK_persons_document_issued_by_id_document_issued_by FOREIGN KEY (id_document_issued_by)
REFERENCES documents_issued_by (id_document_issued_by) ON DELETE NO ACTION ON UPDATE CASCADE;

DELIMITER $$

--
-- Создать функцию `f_rent_category`
--
CREATE FUNCTION f_rent_category (improvement bit, floors smallint, id_structure_type int, is_emergency bit)
RETURNS int(11)
BEGIN
  IF (is_emergency) THEN
    RETURN 4;
  ELSEIF (improvement
    AND floors <= 6) THEN
    RETURN 1;
  ELSEIF (improvement
    AND floors > 6) THEN
    RETURN 2;
  ELSEIF (NOT improvement
    AND id_structure_type = 5) THEN
    RETURN 3;
  END IF;
  RETURN -1;
END
$$

DELIMITER ;

--
-- Создать представление `v_rent_objects_area_and_categories`
--
CREATE
VIEW v_rent_objects_area_and_categories
AS
SELECT DISTINCT
  `v`.`id_process` AS `id_process`,
  `v`.`id_building` AS `id_building`,
  `v`.`id_premises` AS `id_premises`,
  `v`.`id_sub_premises` AS `id_sub_premises`,
  IFNULL(`v`.`rent_total_area`, `v`.`total_area`) AS `rent_area`,
  `v`.`rent_coefficient` AS `rent_coefficient`,
  `f_rent_category`(`v`.`improvement`, `v`.`floors`, `v`.`id_structure_type`, IF(((`vpe`.`id_premises` IS NOT NULL) OR (`vbe`.`id_building` IS NOT NULL)), 1, 0)) AS `id_rent_category`
FROM ((`v_rent_objects` `v`
  LEFT JOIN `v_premises_emergency` `vpe`
    ON ((`vpe`.`id_premises` = `v`.`id_premises`)))
  LEFT JOIN `v_buildings_emergency` `vbe`
    ON ((`v`.`id_building` = `vbe`.`id_building`)));

DELIMITER $$

--
-- Создать функцию `f_rent_payment`
--
CREATE FUNCTION f_rent_payment (id_rent_category int, rent_area float)
RETURNS decimal(10, 2)
BEGIN
  RETURN CASE id_rent_category WHEN 1 THEN rent_area * 6.07 WHEN 2 THEN rent_area * 8.39 WHEN 3 THEN rent_area * 0.69 WHEN 4 THEN rent_area * 0.36 ELSE 0 END;
  RETURN 0;
END
$$

DELIMITER ;

--
-- Создать представление `v_rent_objects_payment`
--
CREATE
VIEW v_rent_objects_payment
AS
SELECT
  CONCAT(`vroaac`.`id_process`, '/', `vroaac`.`id_building`, IFNULL(CONCAT('/', `vroaac`.`id_premises`), ''), IFNULL(CONCAT('/', `vroaac`.`id_sub_premises`), '')) AS `key`,
  `vroaac`.`id_process` AS `id_process`,
  `vroaac`.`id_building` AS `id_building`,
  `vroaac`.`id_premises` AS `id_premises`,
  `vroaac`.`id_sub_premises` AS `id_sub_premises`,
  `vroaac`.`rent_area` AS `rent_area`,
  `vroaac`.`id_rent_category` AS `id_rent_category`,
  IF((`vroaac`.`rent_coefficient` = 0), `f_rent_payment`(`vroaac`.`id_rent_category`, `vroaac`.`rent_area`), (`vroaac`.`rent_coefficient` * `vroaac`.`rent_area`)) AS `payment`
FROM `v_rent_objects_area_and_categories` `vroaac`;

--
-- Создать представление `v_rent_sub_premises`
--
CREATE
VIEW v_rent_sub_premises
AS
SELECT
  `vrop`.`id_sub_premises` AS `id_sub_premises`,
  `vrop`.`payment` AS `payment`
FROM (`v_rent_objects_payment` `vrop`
  JOIN `tenancy_processes` `tp`
    ON ((`vrop`.`id_process` = `tp`.`id_process`)))
WHERE ((`vrop`.`id_sub_premises` IS NOT NULL)
AND (`tp`.`deleted` = 0)
AND (ISNULL(`tp`.`registration_num`)
OR (NOT ((`tp`.`registration_num` LIKE '%н')))))
GROUP BY `vrop`.`id_sub_premises`;

--
-- Создать представление `v_rent_premises`
--
CREATE
VIEW v_rent_premises
AS
SELECT
  `vrop`.`id_premises` AS `id_premises`,
  `vrop`.`payment` AS `payment`
FROM (`v_rent_objects_payment` `vrop`
  JOIN `tenancy_processes` `tp`
    ON ((`vrop`.`id_process` = `tp`.`id_process`)))
WHERE (ISNULL(`vrop`.`id_sub_premises`)
AND (ISNULL(`tp`.`registration_num`)
OR (NOT ((`tp`.`registration_num` LIKE '%н'))))
AND (`vrop`.`id_premises` IS NOT NULL)
AND (`tp`.`deleted` = 0))
GROUP BY `vrop`.`id_premises`;

--
-- Создать представление `v_rent_objects_payment_grouped`
--
CREATE
VIEW v_rent_objects_payment_grouped
AS
SELECT
  `v`.`id_process` AS `id_process`,
  SUM(`v`.`payment`) AS `payment`
FROM `v_rent_objects_payment` `v`
GROUP BY `v`.`id_process`;

--
-- Создать таблицу `acl_privileges`
--
CREATE TABLE IF NOT EXISTS acl_privileges (
  id_privilege int(11) NOT NULL AUTO_INCREMENT,
  privilege_name varchar(50) DEFAULT NULL,
  privilege_mask bigint(20) NOT NULL DEFAULT 0,
  privilege_description varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_privilege)
)
ENGINE = INNODB,
AUTO_INCREMENT = 46,
AVG_ROW_LENGTH = 682,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `acl_roles`
--
CREATE TABLE IF NOT EXISTS acl_roles (
  id_role int(11) NOT NULL AUTO_INCREMENT,
  role_name varchar(255) NOT NULL,
  PRIMARY KEY (id_role)
)
ENGINE = INNODB,
AUTO_INCREMENT = 15,
AVG_ROW_LENGTH = 2340,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `acl_user_roles`
--
CREATE TABLE IF NOT EXISTS acl_user_roles (
  id_user int(11) NOT NULL,
  id_role int(11) NOT NULL,
  PRIMARY KEY (id_role, id_user)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE acl_user_roles
ADD CONSTRAINT FK_acl_user_roles_acl_roles_id_role FOREIGN KEY (id_role)
REFERENCES acl_roles (id_role) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE acl_user_roles
ADD CONSTRAINT FK_acl_user_roles_acl_users_id_user FOREIGN KEY (id_user)
REFERENCES acl_users (id_user) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `acl_privilege_type`
--
CREATE TABLE IF NOT EXISTS acl_privilege_type (
  id_privilege_type int(11) NOT NULL AUTO_INCREMENT,
  privilege_type varchar(255) NOT NULL,
  PRIMARY KEY (id_privilege_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `acl_user_privileges`
--
CREATE TABLE IF NOT EXISTS acl_user_privileges (
  id_user int(11) NOT NULL,
  id_privilege int(11) NOT NULL,
  id_privilege_type int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_user, id_privilege)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE acl_user_privileges
ADD CONSTRAINT FK_acl_user_privileges_acl_privileges_id_privilege FOREIGN KEY (id_privilege)
REFERENCES acl_privileges (id_privilege) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE acl_user_privileges
ADD CONSTRAINT FK_acl_user_privileges_acl_privilege_type_id_privilege_type FOREIGN KEY (id_privilege_type)
REFERENCES acl_privilege_type (id_privilege_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE acl_user_privileges
ADD CONSTRAINT FK_acl_user_privileges_acl_users_id_user FOREIGN KEY (id_user)
REFERENCES acl_users (id_user) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `acl_role_privileges`
--
CREATE TABLE IF NOT EXISTS acl_role_privileges (
  id_role int(11) NOT NULL,
  id_privilege int(11) NOT NULL,
  id_privilege_type int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_role, id_privilege)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 341,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать внешний ключ
--
ALTER TABLE acl_role_privileges
ADD CONSTRAINT FK_acl_role_privileges_acl_privileges_id_privilege FOREIGN KEY (id_privilege)
REFERENCES acl_privileges (id_privilege) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE acl_role_privileges
ADD CONSTRAINT FK_acl_role_privileges_acl_privilege_type_id_privilege_type FOREIGN KEY (id_privilege_type)
REFERENCES acl_privilege_type (id_privilege_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE acl_role_privileges
ADD CONSTRAINT FK_acl_role_privileges_acl_roles_id_role FOREIGN KEY (id_role)
REFERENCES acl_roles (id_role) ON DELETE CASCADE ON UPDATE CASCADE;

DELIMITER $$

--
-- Создать функцию `f_user_privileges`
--
CREATE FUNCTION f_user_privileges ()
RETURNS bigint(20)
BEGIN
  RETURN (SELECT
      CAST(v1.privilege_mask & ~v2.privilege_mask AS decimal) AS privilege_mask
    FROM (SELECT
        BIT_OR(v.privilege_mask) AS privilege_mask
      FROM (SELECT
          BIT_OR(ap.privilege_mask) AS privilege_mask
        FROM acl_users au
          LEFT JOIN acl_user_roles aur
            ON au.id_user = aur.id_user
          LEFT JOIN acl_roles ar
            ON aur.id_role = ar.id_role
          LEFT JOIN acl_role_privileges arp
            ON ar.id_role = arp.id_role
          LEFT JOIN acl_privileges ap
            ON arp.id_privilege = ap.id_privilege
        WHERE au.user_name = SUBSTRING(USER(), 1, LOCATE('@', USER()) - 1)
        AND arp.id_privilege_type = 1
        UNION ALL
        SELECT
          BIT_OR(ap.privilege_mask) AS privilege_mask
        FROM acl_users au
          LEFT JOIN acl_user_privileges aup
            ON au.id_user = aup.id_user
          LEFT JOIN acl_privileges ap
            ON aup.id_privilege = ap.id_privilege
        WHERE au.user_name = SUBSTRING(USER(), 1, LOCATE('@', USER()) - 1)
        AND aup.id_privilege_type = 1) v) v1
      JOIN (SELECT
          BIT_OR(v.privilege_mask) AS privilege_mask
        FROM (SELECT
            BIT_OR(ap.privilege_mask) AS privilege_mask
          FROM acl_users au
            LEFT JOIN acl_user_roles aur
              ON au.id_user = aur.id_user
            LEFT JOIN acl_roles ar
              ON aur.id_role = ar.id_role
            LEFT JOIN acl_role_privileges arp
              ON ar.id_role = arp.id_role
            LEFT JOIN acl_privileges ap
              ON arp.id_privilege = ap.id_privilege
          WHERE au.user_name = SUBSTRING(USER(), 1, LOCATE('@', USER()) - 1)
          AND arp.id_privilege_type = 2
          UNION ALL
          SELECT
            BIT_OR(ap.privilege_mask) AS privilege_mask
          FROM acl_users au
            LEFT JOIN acl_user_privileges aup
              ON au.id_user = aup.id_user
            LEFT JOIN acl_privileges ap
              ON aup.id_privilege = ap.id_privilege
          WHERE au.user_name = SUBSTRING(USER(), 1, LOCATE('@', USER()) - 1)
          AND aup.id_privilege_type = 2) v) v2
    LIMIT 1);
END
$$

DELIMITER ;

--
-- Создать таблицу `resettle_info_to`
--
CREATE TABLE IF NOT EXISTS resettle_info_to (
  id_key int(11) NOT NULL AUTO_INCREMENT,
  id_resettle_info int(11) NOT NULL,
  id_object int(11) NOT NULL,
  object_type varchar(255) NOT NULL,
  deleted tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_key)
)
ENGINE = INNODB,
AUTO_INCREMENT = 355,
AVG_ROW_LENGTH = 49,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `FK_resettle_info_sub_premises_to_id_sub_premises` для объекта типа таблица `resettle_info_to`
--
ALTER TABLE resettle_info_to
ADD INDEX FK_resettle_info_sub_premises_to_id_sub_premises (id_object);

--
-- Создать представление `v_resettle_info_to`
--
CREATE
VIEW v_resettle_info_to
AS
SELECT
  `rit`.`id_resettle_info` AS `id_resettle_info`,
  `vks`.`street_name` AS `street_name`,
  `b`.`house` AS `house`,
  NULL AS `premises_num`,
  0 AS `room_count`,
  `b`.`total_area` AS `total_area`,
  `b`.`living_area` AS `living_area`
FROM ((`registry`.`resettle_info_to` `rit`
  JOIN `registry`.`buildings` `b`
    ON ((`rit`.`id_object` = `b`.`id_building`)))
  JOIN `registry`.`v_kladr_streets` `vks`
    ON ((`vks`.`id_street` = `b`.`id_street`)))
WHERE ((`rit`.`deleted` = 0)
AND (`rit`.`object_type` = 'Building'))
UNION ALL
SELECT
  `rit`.`id_resettle_info` AS `id_resettle_info`,
  `vks`.`street_name` AS `street_name`,
  `b`.`house` AS `house`,
  `p`.`premises_num` AS `premises_num`,
  `p`.`num_rooms` AS `num_rooms`,
  `p`.`total_area` AS `total_area`,
  `p`.`living_area` AS `living_area`
FROM (((`registry`.`resettle_info_to` `rit`
  JOIN `registry`.`premises` `p`
    ON ((`p`.`id_premises` = `rit`.`id_object`)))
  JOIN `registry`.`buildings` `b`
    ON ((`p`.`id_building` = `b`.`id_building`)))
  JOIN `registry`.`v_kladr_streets` `vks`
    ON ((`vks`.`id_street` = `b`.`id_street`)))
WHERE ((`rit`.`deleted` = 0)
AND (`rit`.`object_type` = 'Premise'))
UNION ALL
SELECT
  `rit`.`id_resettle_info` AS `id_resettle_info`,
  `vks`.`street_name` AS `street_name`,
  `b`.`house` AS `house`,
  CONCAT(`p`.`premises_num`, ' ком. ', GROUP_CONCAT(`sp`.`sub_premises_num` ORDER BY `sp`.`sub_premises_num` ASC SEPARATOR ', ')) AS `premises_num`,
  COUNT(0) AS `num_rooms`,
  SUM(`sp`.`total_area`) AS `total_area`,
  SUM(`sp`.`living_area`) AS `living_area`
FROM ((((`registry`.`resettle_info_to` `rit`
  JOIN `registry`.`sub_premises` `sp`
    ON ((`sp`.`id_sub_premises` = `rit`.`id_object`)))
  JOIN `registry`.`premises` `p`
    ON ((`p`.`id_premises` = `sp`.`id_premises`)))
  JOIN `registry`.`buildings` `b`
    ON ((`p`.`id_building` = `b`.`id_building`)))
  JOIN `registry`.`v_kladr_streets` `vks`
    ON ((`vks`.`id_street` = `b`.`id_street`)))
WHERE ((`rit`.`deleted` = 0)
AND (`rit`.`object_type` = 'SubPremise'))
GROUP BY `rit`.`id_resettle_info`;

--
-- Создать таблицу `warrant_doc_types`
--
CREATE TABLE IF NOT EXISTS warrant_doc_types (
  id_warrant_doc_type int(11) NOT NULL AUTO_INCREMENT,
  warrant_doc_type varchar(50) NOT NULL,
  warrant_doc_type_genetive varchar(50) DEFAULT NULL,
  PRIMARY KEY (id_warrant_doc_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `warrants`
--
CREATE TABLE IF NOT EXISTS warrants (
  id_warrant int(11) NOT NULL AUTO_INCREMENT,
  id_warrant_doc_type int(11) NOT NULL,
  registration_num varchar(10) NOT NULL,
  registration_date date NOT NULL,
  on_behalf_of varchar(100) DEFAULT NULL,
  notary varchar(100) DEFAULT NULL,
  notary_district varchar(100) DEFAULT NULL,
  description text DEFAULT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_warrant)
)
ENGINE = INNODB,
AUTO_INCREMENT = 523,
AVG_ROW_LENGTH = 194,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `warrants_after_insert`
--
CREATE TRIGGER warrants_after_insert
AFTER INSERT
ON warrants
FOR EACH ROW
BEGIN
  IF (NEW.id_warrant_doc_type IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'warrants', NEW.id_warrant, 'id_warrant_doc_type', NULL, NEW.id_warrant_doc_type, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.registration_num IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'warrants', NEW.id_warrant, 'registration_num', NULL, NEW.registration_num, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.registration_date IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'warrants', NEW.id_warrant, 'registration_date', NULL, NEW.registration_date, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.on_behalf_of IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'warrants', NEW.id_warrant, 'on_behalf_of', NULL, NEW.on_behalf_of, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.notary IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'warrants', NEW.id_warrant, 'notary', NULL, NEW.notary, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.notary_district IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'warrants', NEW.id_warrant, 'notary_district', NULL, NEW.notary_district, 'INSERT', NOW(), USER());
  END IF;
  IF (NEW.description IS NOT NULL) THEN
    INSERT INTO `log`
      VALUES (NULL, 'warrants', NEW.id_warrant, 'description', NULL, NEW.description, 'INSERT', NOW(), USER());
  END IF;
END
$$

--
-- Создать триггер `warrants_after_update`
--
CREATE TRIGGER warrants_after_update
AFTER UPDATE
ON warrants
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO `log`
      VALUES (NULL, 'warrants', NEW.id_warrant, 'deleted', OLD.deleted, NEW.deleted, 'DELETE', NOW(), USER());
  ELSE
    IF (NEW.id_warrant_doc_type <> OLD.id_warrant_doc_type) THEN
      INSERT INTO `log`
        VALUES (NULL, 'warrants', NEW.id_warrant, 'id_warrant_doc_type', OLD.id_warrant_doc_type, NEW.id_warrant_doc_type, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.registration_num <> OLD.registration_num) THEN
      INSERT INTO `log`
        VALUES (NULL, 'warrants', NEW.id_warrant, 'registration_num', OLD.registration_num, NEW.registration_num, 'UPDATE', NOW(), USER());
    END IF;
    IF (NEW.registration_date <> OLD.registration_date) THEN
      INSERT INTO `log`
        VALUES (NULL, 'warrants', NEW.id_warrant, 'registration_date', OLD.registration_date, NEW.registration_date, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.on_behalf_of IS NULL
      AND OLD.on_behalf_of IS NULL)
      AND ((NEW.on_behalf_of IS NULL
      AND OLD.on_behalf_of IS NOT NULL)
      OR (NEW.on_behalf_of IS NOT NULL
      AND OLD.on_behalf_of IS NULL)
      OR (NEW.on_behalf_of <> OLD.on_behalf_of))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'warrants', NEW.id_warrant, 'on_behalf_of', OLD.on_behalf_of, NEW.on_behalf_of, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.notary IS NULL
      AND OLD.notary IS NULL)
      AND ((NEW.notary IS NULL
      AND OLD.notary IS NOT NULL)
      OR (NEW.notary IS NOT NULL
      AND OLD.notary IS NULL)
      OR (NEW.notary <> OLD.notary))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'warrants', NEW.id_warrant, 'notary', OLD.notary, NEW.notary, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.notary_district IS NULL
      AND OLD.notary_district IS NULL)
      AND ((NEW.notary_district IS NULL
      AND OLD.notary_district IS NOT NULL)
      OR (NEW.notary_district IS NOT NULL
      AND OLD.notary_district IS NULL)
      OR (NEW.notary_district <> OLD.notary_district))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'warrants', NEW.id_warrant, 'notary_district', OLD.notary_district, NEW.notary_district, 'UPDATE', NOW(), USER());
    END IF;
    IF (NOT (NEW.description IS NULL
      AND OLD.description IS NULL)
      AND ((NEW.description IS NULL
      AND OLD.description IS NOT NULL)
      OR (NEW.description IS NOT NULL
      AND OLD.description IS NULL)
      OR (NEW.description <> OLD.description))) THEN
      INSERT INTO `log`
        VALUES (NULL, 'warrants', NEW.id_warrant, 'description', OLD.description, NEW.description, 'UPDATE', NOW(), USER());
    END IF;
  END IF;
END
$$

--
-- Создать триггер `warrants_before_update`
--
CREATE TRIGGER warrants_before_update
BEFORE UPDATE
ON warrants
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM tenancy_processes
        WHERE deleted <> 1
        AND id_warrant = NEW.id_warrant) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить доверенность, т.к. существуют договоры, использующие ее';
    END IF;
    IF ((SELECT
          COUNT(*)
        FROM tenancy_agreements
        WHERE deleted <> 1
        AND id_warrant = NEW.id_warrant) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить доверенность, т.к. существуют соглашения, использующие ее';
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE warrants
ADD CONSTRAINT FK_warrants_warrant_doc_types_id_warrant_doc_type FOREIGN KEY (id_warrant_doc_type)
REFERENCES warrant_doc_types (id_warrant_doc_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_agreements
ADD CONSTRAINT FK_agreements_warrants_id_warrant FOREIGN KEY (id_warrant)
REFERENCES warrants (id_warrant) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE tenancy_processes
ADD CONSTRAINT FK_tenancy_contracts_warrants_id_warrant FOREIGN KEY (id_warrant)
REFERENCES warrants (id_warrant) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `resettle_documents`
--
CREATE TABLE IF NOT EXISTS resettle_documents (
  id_document int(11) NOT NULL AUTO_INCREMENT,
  id_document_type int(11) NOT NULL,
  id_resettle_info int(11) NOT NULL,
  number varchar(20) DEFAULT NULL,
  date date NOT NULL,
  description varchar(255) DEFAULT NULL,
  file_origin_name varchar(255) DEFAULT NULL,
  file_display_name varchar(255) DEFAULT NULL,
  file_mime_type varchar(255) DEFAULT NULL,
  deleted tinyint(4) NOT NULL,
  PRIMARY KEY (id_document)
)
ENGINE = INNODB,
AUTO_INCREMENT = 9,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `resettle_info`
--
CREATE TABLE IF NOT EXISTS resettle_info (
  id_resettle_info int(11) NOT NULL AUTO_INCREMENT,
  resettle_date date DEFAULT NULL,
  id_ressetle_kind int(11) DEFAULT NULL,
  id_resettle_kind_fact int(11) DEFAULT NULL,
  id_resettle_stage int(11) DEFAULT NULL,
  finance_source_1 decimal(18, 2) NOT NULL DEFAULT 0.00,
  finance_source_2 decimal(18, 2) NOT NULL DEFAULT 0.00,
  finance_source_3 decimal(18, 2) NOT NULL DEFAULT 0.00,
  finance_source_4 decimal(18, 2) NOT NULL DEFAULT 0.00,
  description varchar(2048) DEFAULT NULL,
  deleted tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_resettle_info)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5609,
AVG_ROW_LENGTH = 96,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `resettle_info_before_update`
--
CREATE TRIGGER resettle_info_before_update
BEFORE UPDATE
ON resettle_info
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    UPDATE resettle_info_sub_premises_from
    SET deleted = 1
    WHERE id_resettle_info = NEW.id_resettle_info;
    UPDATE resettle_info_to
    SET deleted = 1
    WHERE id_resettle_info = NEW.id_resettle_info;
    UPDATE resettle_documents
    SET deleted = 1
    WHERE id_resettle_info = NEW.id_resettle_info;
    UPDATE resettle_premise_assoc
    SET deleted = 1
    WHERE id_resettle_info = NEW.id_resettle_info;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_documents
ADD CONSTRAINT FK_resettle_documents_id_resettle_info FOREIGN KEY (id_resettle_info)
REFERENCES resettle_info (id_resettle_info) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_info_sub_premises_from
ADD CONSTRAINT FK_resettle_info_sub_premises_from_id_resettle_info FOREIGN KEY (id_resettle_info)
REFERENCES resettle_info (id_resettle_info) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_info_to
ADD CONSTRAINT FK_resettle_info_sub_premises_to_id_resettle_info FOREIGN KEY (id_resettle_info)
REFERENCES resettle_info (id_resettle_info) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_premise_assoc
ADD CONSTRAINT FK_resettle_premise_assoc_id_resettle_info FOREIGN KEY (id_resettle_info)
REFERENCES resettle_info (id_resettle_info) ON DELETE CASCADE ON UPDATE CASCADE;

DELIMITER $$

--
-- Создать процедуру `resettle_transfer`
--
CREATE PROCEDURE resettle_transfer ()
BEGIN
  DECLARE resettle_plan_date_prop date;
  DECLARE id_premises_prop int;
  DECLARE id_resettle_info_prop int;
  DECLARE done integer DEFAULT 0;
  DECLARE cursor_resettle CURSOR FOR
  SELECT
    MIN(`or`.resettle_plan_date) AS resettle_plan_date,
    p.id_premises
  FROM ownership_rights `or`
    JOIN ownership_buildings_assoc oba
      ON `or`.id_ownership_right = oba.id_ownership_right
    JOIN premises p
      ON oba.id_building = p.id_building
  WHERE `or`.resettle_plan_date IS NOT NULL
  AND p.deleted <> 1
  AND `or`.deleted <> 1
  GROUP BY p.id_premises;
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

  OPEN cursor_resettle;

circle1:
  WHILE done = 0 DO
    FETCH cursor_resettle INTO resettle_plan_date_prop, id_premises_prop;
    IF (done = 1) THEN
      LEAVE circle1;
    END IF;

    SET id_resettle_info_prop = NULL;
    SET id_resettle_info_prop = (SELECT
        rpa.id_resettle_info
      FROM resettle_premise_assoc rpa
      WHERE rpa.id_premises = id_premises_prop);
    IF (id_resettle_info_prop IS NULL) THEN
      INSERT INTO resettle_info (resettle_date)
        VALUES (resettle_plan_date_prop);
      SET id_resettle_info_prop = LAST_INSERT_ID();
      INSERT INTO resettle_premise_assoc (id_premises, id_resettle_info)
        VALUES (id_premises_prop, id_resettle_info_prop);
    ELSE
      UPDATE resettle_info ri
      SET ri.resettle_date = resettle_plan_date_prop
      WHERE ri.id_resettle_info = id_resettle_info_prop;
    END IF;
  END WHILE;
  CLOSE cursor_resettle;

  UPDATE buildings b
  SET b.demolished_plan_date = (SELECT
      `or`.demolish_plan_date
    FROM ownership_rights `or`
      JOIN ownership_buildings_assoc oba
        ON `or`.id_ownership_right = oba.id_ownership_right
    WHERE `or`.demolish_plan_date IS NOT NULL
    AND oba.deleted <> 1
    AND oba.id_building = b.id_building)
  WHERE b.deleted <> 1;
END
$$

DELIMITER ;

--
-- Создать таблицу `resettle_stages`
--
CREATE TABLE IF NOT EXISTS resettle_stages (
  id_resettle_stage int(11) NOT NULL AUTO_INCREMENT,
  stage_name varchar(255) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_resettle_stage)
)
ENGINE = INNODB,
AUTO_INCREMENT = 6,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `resettle_stages_before_update`
--
CREATE TRIGGER resettle_stages_before_update
BEFORE UPDATE
ON resettle_stages
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM resettle_info
        WHERE deleted <> 1
        AND id_resettle_stage = NEW.id_resettle_stage) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить этап переселения, т.к. существуют переселения, завязанные на данный этап';
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_info
ADD CONSTRAINT FK_resettle_info_id_resettle_stage FOREIGN KEY (id_resettle_stage)
REFERENCES resettle_stages (id_resettle_stage) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `resettle_kinds`
--
CREATE TABLE IF NOT EXISTS resettle_kinds (
  id_resettle_kind int(11) NOT NULL AUTO_INCREMENT,
  resettle_kind varchar(255) DEFAULT NULL,
  deleted tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_resettle_kind)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `resettle_kinds_before_update`
--
CREATE TRIGGER resettle_kinds_before_update
BEFORE UPDATE
ON resettle_kinds
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM resettle_info
        WHERE deleted <> 1
        AND id_ressetle_kind = NEW.id_resettle_kind) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить способ переселения, т.к. существуют переселение, завязанное на данный способ';
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_info
ADD CONSTRAINT FK_resettle_premises_info_id_ressetle_kind FOREIGN KEY (id_ressetle_kind)
REFERENCES resettle_kinds (id_resettle_kind) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `resettle_info_to_fact`
--
CREATE TABLE IF NOT EXISTS resettle_info_to_fact (
  id_key int(11) NOT NULL AUTO_INCREMENT,
  id_resettle_info int(11) NOT NULL,
  id_object int(11) NOT NULL,
  object_type varchar(255) NOT NULL,
  deleted tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_key)
)
ENGINE = INNODB,
AUTO_INCREMENT = 11,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `FK_resettle_info_sub_premises_to_id_sub_premises` для объекта типа таблица `resettle_info_to_fact`
--
ALTER TABLE resettle_info_to_fact
ADD INDEX FK_resettle_info_sub_premises_to_id_sub_premises (id_object);

--
-- Создать внешний ключ
--
ALTER TABLE resettle_info_to_fact
ADD CONSTRAINT FK_resettle_info_to_fact_id_resettle_info FOREIGN KEY (id_resettle_info)
REFERENCES resettle_info (id_resettle_info) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `resettle_document_types`
--
CREATE TABLE IF NOT EXISTS resettle_document_types (
  id_document_type int(11) NOT NULL AUTO_INCREMENT,
  document_type varchar(255) NOT NULL,
  deleted tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_document_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 8,
AVG_ROW_LENGTH = 3276,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `resettle_document_types_before_update`
--
CREATE TRIGGER resettle_document_types_before_update
BEFORE UPDATE
ON resettle_document_types
FOR EACH ROW
BEGIN
  IF (NEW.deleted = 1) THEN
    IF ((SELECT
          COUNT(*)
        FROM resettle_documents
        WHERE deleted <> 1
        AND id_document_type = NEW.id_document_type) > 0) THEN
      SIGNAL SQLSTATE 'ERR0R' SET MESSAGE_TEXT = 'Нельзя удалить тип документа, т.к. существуют документы данного типа';
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE resettle_documents
ADD CONSTRAINT FK_resettle_documents_id_document_type FOREIGN KEY (id_document_type)
REFERENCES resettle_document_types (id_document_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать таблицу `owner_reason_types`
--
CREATE TABLE IF NOT EXISTS owner_reason_types (
  id_reason_type int(11) NOT NULL AUTO_INCREMENT,
  reason_name varchar(255) NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_reason_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 10,
AVG_ROW_LENGTH = 1820,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `owner_reasons`
--
CREATE TABLE IF NOT EXISTS owner_reasons (
  id_reason int(11) NOT NULL AUTO_INCREMENT,
  id_owner int(11) NOT NULL,
  numerator_share int(11) NOT NULL COMMENT 'Числитель доли собственности',
  denominator_share int(11) NOT NULL COMMENT 'Знаменатель доли собственности',
  id_reason_type int(11) NOT NULL,
  reason_number varchar(255) NOT NULL,
  reason_date date NOT NULL,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_reason)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2581,
AVG_ROW_LENGTH = 87,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `owner_reasons_after_insert`
--
CREATE TRIGGER owner_reasons_after_insert
AFTER INSERT
ON owner_reasons
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  DECLARE id_log int(11);
  DECLARE id_process int(11);
  SET id_process = (SELECT
      o.id_process
    FROM owners o
    WHERE o.id_owner = NEW.id_owner);
  SET id_user = (SELECT
      au.id_user
    FROM acl_users au
    WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
  INSERT INTO log_owner_processes
    VALUES (NULL, id_process, NOW(), id_user, 4, 1, 'owner_reasons', NEW.id_reason);
  SET id_log = (SELECT
      LAST_INSERT_ID());
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'id_owner', NEW.id_owner);
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'numerator_share', NEW.numerator_share);
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'denominator_share', NEW.denominator_share);
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'id_reason_type', NEW.id_reason_type);
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'reason_number', NEW.reason_number);
  INSERT INTO log_owner_processes_value
    VALUES (NULL, id_log, 'reason_date', NEW.reason_date);
END
$$

--
-- Создать триггер `owner_reasons_after_update`
--
CREATE TRIGGER owner_reasons_after_update
AFTER UPDATE
ON owner_reasons
FOR EACH ROW
BEGIN
  DECLARE id_user int(11);
  DECLARE id_log int(11);
  DECLARE tables_param varchar(255);
  DECLARE id_process int(11);
  SET id_process = (SELECT
      o.id_process
    FROM owners o
    WHERE o.id_owner = NEW.id_owner);
  SET id_user = (SELECT
      au.id_user
    FROM acl_users au
    WHERE UPPER(au.user_name) = SUBSTRING_INDEX(USER(), '@', 1));
  IF (NEW.deleted = 1
    AND OLD.deleted = 0) THEN
    INSERT INTO log_owner_processes
      VALUES (NULL, id_process, NOW(), id_user, 4, 6, 'owner_reasons', NEW.id_reason);
  ELSE
    SET id_log = -1;
    IF ((OLD.numerator_share IS NOT NULL)
      AND (NEW.numerator_share <> OLD.numerator_share)) THEN
      INSERT INTO log_owner_processes
        VALUES (NULL, id_process, NOW(), id_user, 4, 3, 'owner_reasons', NEW.id_reason);
      SET id_log = (SELECT
          LAST_INSERT_ID());
      INSERT INTO log_owner_processes_value
        VALUES (NULL, id_log, 'numerator_share', NEW.numerator_share);
    END IF;
    IF ((OLD.denominator_share IS NOT NULL)
      AND (NEW.denominator_share <> OLD.denominator_share)) THEN
      IF (id_log = -1) THEN
        INSERT INTO log_owner_processes
          VALUES (NULL, id_process, NOW(), id_user, 4, 3, 'owner_reasons', NEW.id_reason);
        SET id_log = (SELECT
            LAST_INSERT_ID());
      END IF;
      INSERT INTO log_owner_processes_value
        VALUES (NULL, id_log, 'denominator_share', NEW.denominator_share);
    END IF;
    IF ((OLD.id_reason_type IS NOT NULL)
      AND (NEW.id_reason_type <> OLD.id_reason_type)) THEN
      IF (id_log = -1) THEN
        INSERT INTO log_owner_processes
          VALUES (NULL, id_process, NOW(), id_user, 4, 3, 'owner_reasons', NEW.id_reason);
        SET id_log = (SELECT
            LAST_INSERT_ID());
      END IF;
      INSERT INTO log_owner_processes_value
        VALUES (NULL, id_log, 'id_reason_type', NEW.id_reason_type);
    END IF;
    IF ((OLD.reason_number IS NOT NULL)
      AND (NEW.reason_number <> OLD.reason_number)) THEN
      IF (id_log = -1) THEN
        INSERT INTO log_owner_processes
          VALUES (NULL, id_process, NOW(), id_user, 4, 3, 'owner_reasons', NEW.reason_number);
        SET id_log = (SELECT
            LAST_INSERT_ID());
      END IF;
      INSERT INTO log_owner_processes_value
        VALUES (NULL, id_log, 'reason_number', NEW.reason_number);
    END IF;
    IF ((OLD.reason_date IS NOT NULL)
      AND (NEW.reason_date <> OLD.reason_date)) THEN
      IF (id_log = -1) THEN
        INSERT INTO log_owner_processes
          VALUES (NULL, id_process, NOW(), id_user, 4, 3, 'owner_reasons', NEW.reason_date);
        SET id_log = (SELECT
            LAST_INSERT_ID());
      END IF;
      INSERT INTO log_owner_processes_value
        VALUES (NULL, id_log, 'reason_date', NEW.reason_date);
    END IF;
  END IF;
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE owner_reasons
ADD CONSTRAINT FK_owner_reasons_id_reason_type FOREIGN KEY (id_reason_type)
REFERENCES owner_reason_types (id_reason_type) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Создать внешний ключ
--
ALTER TABLE owner_reasons
ADD CONSTRAINT FK_owner_reasons_owners_id_owner FOREIGN KEY (id_owner)
REFERENCES owners (id_owner) ON DELETE CASCADE ON UPDATE CASCADE;

DELIMITER $$

--
-- Создать функцию `f_address_from_purpose`
--
CREATE FUNCTION f_address_from_purpose (purpose varchar(500))
RETURNS varchar(500) CHARSET utf8
BEGIN
  DECLARE result varchar(500);
  DECLARE reverseStr varchar(500);
  DECLARE city varchar(100);
  DECLARE street varchar(300);
  DECLARE house varchar(50);
  DECLARE apart varchar(50);

  IF (LOCATE('реестр', purpose)) THEN
    SET reverseStr = REVERSE(purpose);
    SET result = (SELECT
        SUBSTR(v.res, 1, LOCATE('//', v.res) - 1)
      FROM (SELECT
          SUBSTR(reverseStr, LOCATE('//', reverseStr) + 2, LENGTH(reverseStr) - LOCATE('//', reverseStr) + 2) AS res) v);
    /*
    SET apart = REVERSE(SUBSTR(result, 1, LOCATE('.', result)-1));
    SET result = SUBSTR(result, LOCATE('.', result)+1);
    SET house = REVERSE(SUBSTR(result, 1, LOCATE('.', result)-1)); 
    SET result = REVERSE(SUBSTR(result, LOCATE('.', result)+1));
    SET city = SUBSTR(result, 1, LOCATE('.', result)-1);
    SET city = CONCAT(LEFT(city, 1), LCASE(SUBSTR(city, 2)));
    SET street = SUBSTR(result, LOCATE('.', result)+1);
    SET street = REPLACE(REPLACE(REPLACE(REPLACE(street, 'ПАРТСЪЕЗДА 20', 'XX ПАРТСЪЕЗДА'), 'ПАРТСЪЕЗДА ХХ', 'XX ПАРТСЪЕЗДА'), '20 ПАРТСЪЕЗДА', 'XX ПАРТСЪЕЗДА'), 'ХХ ПАРТСЪЕЗДА', 'XX ПАРТСЪЕЗДА');
    SET street = CONCAT(LEFT(street, 1), lcase(SUBSTR(street, 2)));
    
    RETURN CONCAT_WS(', ', city, street, house, apart);
    */
    SET result = REVERSE(result);
    SET result = REPLACE(REPLACE(REPLACE(REPLACE(result, 'ПАРТСЪЕЗДА 20', 'XX ПАРТСЪЕЗДА'), 'ПАРТСЪЕЗДА ХХ', 'XX ПАРТСЪЕЗДА'), '20 ПАРТСЪЕЗДА', 'XX ПАРТСЪЕЗДА'), 'ХХ ПАРТСЪЕЗДА', 'XX ПАРТСЪЕЗДА');
    -- SET result = REPLACE(result, '.', ', ');
    RETURN result;

  ELSE
    RETURN NULL;
  END IF;
END
$$

--
-- Создать функцию `f_order_from_purpose`
--
CREATE FUNCTION f_order_from_purpose (purpose varchar(500))
RETURNS varchar(255) CHARSET utf8
BEGIN
  DECLARE result varchar(255);
  DECLARE firstIndex int;
  DECLARE slashIndex int;

  SET firstIndex = LOCATE(' ИД ', purpose);
  IF firstIndex <> 0 THEN
    SET result = (SELECT
        SUBSTRING(v.res, 1, LOCATE(' ', v.res) - 1)
      FROM (SELECT
          SUBSTRING(purpose, firstIndex + 4, LENGTH(purpose) - firstIndex + 4) AS res) v);
  END IF;

  IF LOCATE('-', result, 3) <> 0 THEN
    SET result = CONCAT(LEFT(result, 3), REPLACE(SUBSTR(result, 4), '-', '/'));
  END IF;
  IF result <> '' THEN
    SET slashIndex = LOCATE('/', result);
    IF slashIndex <> 0 THEN
      IF LENGTH(SUBSTR(result, slashIndex + 1, 4)) = 2 THEN
        SET result = CONCAT(SUBSTR(result, 1, slashIndex), '20', SUBSTR(result, slashIndex + 1, 4));
      END IF;
    END IF;
    RETURN TRIM(result);
  ELSE
    RETURN NULL;
  END IF;
END
$$

--
-- Создать процедуру `payments_by_period_kbk`
--
CREATE PROCEDURE payments_by_period_kbk (IN _startDate date, IN _finishDate date, IN _kbk varchar(20))
BEGIN
  DROP TEMPORARY TABLE IF EXISTS _accounts_info;

  CREATE TEMPORARY TABLE _accounts_info AS
  SELECT
    pa.account,
    a.premiss_num AS parsed_address,
    UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pa.raw_address,
    ' ул.', ''), ' бул.', ''), ' пер.', ''), ' просп.', ''), ' тупик', ''), 'д.', ''), 'кв.', ''),
    '-а', 'А'), '-б', 'Б'), '-в', 'В'), ', ', '.')) AS prepared_addrees,
    pa.raw_address,
    p.last_payment_date,
    p.last_charging_date,
    p.tenant,
    p.balance_input_total,
    p.balance_output_total,
    c.court_orders
  FROM payments_accounts pa
    LEFT JOIN (SELECT
        p.id_account,
        pd.last_payment_date,
        lpd.last_charging_date,
        p.tenant,
        p.balance_input AS balance_input_total,
        p.balance_output_total
      FROM (SELECT
          `p`.`id_account` AS `id_account`,
          MAX(`p`.`date`) AS last_payment_date
        FROM `payments` `p`
        WHERE p.date <= _finishDate
        GROUP BY `p`.`id_account`) pd
        JOIN payments p
          ON pd.id_account = p.id_account
          AND p.date = pd.last_payment_date
        LEFT JOIN (SELECT
            `p`.`id_account` AS `id_account`,
            MAX(`p`.`date`) AS last_charging_date
          FROM `payments` `p`
          WHERE p.charging_total > 0
          AND p.date <= _finishDate
          GROUP BY `p`.`id_account`) lpd
          ON pd.id_account = lpd.id_account
      GROUP BY p.id_account) p
      ON pa.id_account = p.id_account
    LEFT JOIN (SELECT
        v.id_account,
        GROUP_CONCAT(TRIM(TRAILING '.' FROM CONCAT(vks.street, '.', UPPER(b.house), '.', UPPER(p.premises_num), '.',
        IFNULL(v.sub_premises, ''))) SEPARATOR ',') AS premiss_num
      FROM (SELECT
          papa.id_account,
          papa.id_premises,
          NULL AS sub_premises
        FROM payments_account_premises_assoc papa
        UNION ALL
        SELECT
          paspa.id_account,
          sp.id_premises,
          CONCAT('', GROUP_CONCAT(sp.sub_premises_num SEPARATOR '.')) AS sub_premises
        FROM payments_account_sub_premises_assoc paspa
          JOIN sub_premises sp
            ON paspa.id_sub_premises = sp.id_sub_premises
        GROUP BY paspa.id_account,
                 sp.id_premises) v
        JOIN premises p
          ON v.id_premises = p.id_premises
        JOIN buildings b
          ON p.id_building = b.id_building
        JOIN (SELECT
            *
          FROM (SELECT
              vks.id_street,
              UPPER(REPLACE(TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
              REPLACE(REPLACE(REPLACE(REPLACE(vks.street_name,
              'пер.', ''), 'мкр.', ''), 'ул.', ''), 'б-р.', ''), 'пр-кт.', ''),
              'проезд.', ''), 'кв-л.', ''), 'гск.', ''), 'тер.', ''), 'туп.', ''), 'п/р..', ''), 'пл-ка.', ''), 'рзд.', ''), 'ст.', ''), 'жилрайон.', '')), ',  ', '.')) AS street
            FROM v_kladr_streets vks
            WHERE vks.id_street NOT IN ('38000005000000200', '38000005000000100', '38000005000000300',
            '38000005000000400', '38000015000001300', '38000015000012800',
            '38000015000012900', '38001002000020700', '38001002000006800',
            '38000005008000800', '38000005041015900', '38000005041015700', '38000005041010800')) v) vks
          ON b.id_street = vks.id_street
      GROUP BY v.id_account) a
      ON pa.id_account = a.id_account
    LEFT JOIN (SELECT DISTINCT
        pa.id_account,
        GROUP_CONCAT(cs.court_order_num SEPARATOR ', ') AS court_orders
      FROM claims c
        JOIN claim_states cs
          ON c.id_claim = cs.id_claim
          AND cs.id_state_type = 4
        JOIN payments_accounts pa
          ON pa.id_account = c.id_account
        LEFT JOIN payments_accounts pa1
          ON pa1.id_account = c.id_account_additional
      WHERE cs.court_order_num IS NOT NULL
      GROUP BY pa.id_account) c
      ON pa.id_account = c.id_account;

  CREATE INDEX accounts_info_account_idx ON _accounts_info (account);
  CREATE INDEX accounts_info_address_idx ON _accounts_info (parsed_address (255));
  CREATE INDEX accounts_info_prepared_address_idx ON _accounts_info (prepared_addrees (255));

  DROP TABLE IF EXISTS _result_info;

  CREATE TABLE _result_info AS
  SELECT
    p.id_payment,
    p.num_d,
    p.date_d,
    p.payer_name,
    p.payer_inn,
    CASE
      -- Если текущий КБК не найм, то надо взять сумму с минусом (т.к. ранее был КБК найм)
      WHEN p.kbk <> _kbk THEN 0 - p.sum ELSE
        -- Если были уточнения по сумме, то взять самую первую, т.к. это та, что пришла в платежном поручении
        -- Это значит, что сумма частично уточнялась на другой КБК, что будет отражено другой строкой с минусом
        -- Если уточнений по сумме не было, то взять текущую с карточки платежа
        IFNULL((SELECT
            kpc.field_value
          FROM kumi_payments_corrections kpc
          WHERE kpc.id_payment = p.id_payment
          AND kpc.field_name = 'Sum'
          ORDER BY kpc.date ASC LIMIT 1), p.sum) END AS sum_corrected,
    p.sum AS sum_original,
    p.purpose,
    p.kbk,
    (SELECT
        kpc.field_value
      FROM kumi_payments_corrections kpc
      WHERE kpc.id_payment = p.id_payment
      AND kpc.field_name = 'Kbk'
      ORDER BY kpc.date DESC LIMIT 1) AS prev_kbk,
    (SELECT
        GROUP_CONCAT(CONCAT('№ ', kmo.num_d, ' от ', DATE_FORMAT(kmo.doc_d, '%d.%m.%Y')) SEPARATOR ', ')
      FROM kumi_memorial_orders kmo
        JOIN kumi_memorial_order_payment_assoc kmopa
          ON kmo.id_order = kmopa.id_order
      WHERE kmopa.id_payment = p.id_payment
      AND kmo.sum_in = p.sum) AS note,
    CAST(NULL AS char(255)) AS account,
    CAST(NULL AS char(500)) AS address,
    CAST(NULL AS char(255)) AS court_order,
    p._estatebratsk_oid
  FROM kumi_payments p
  WHERE
  -- Платежи за указанный период по дате списания/зачисления на счет/платежного поручения 
  -- Или наличию изменений КБК в указанном периоде --
  ((IFNULL(p.date_e, IFNULL(p.date_in, p.date_d)) BETWEEN _startDate AND _finishDate)
  OR EXISTS (SELECT
      *
    FROM kumi_payments_corrections kpc
    WHERE kpc.id_payment = p.id_payment
    AND kpc.field_name = 'Kbk'
    AND kpc.date BETWEEN _startDate AND _finishDate))
  AND
  -- Платежи без уточнения КБК --
  ((p.kbk = _kbk
  AND NOT EXISTS (SELECT
      *
    FROM kumi_payments_corrections kpc
    WHERE kpc.id_payment = p.id_payment
    AND kpc.field_name = 'Kbk'))
  OR
  -- Платежи, уточненные на КБК найма в указанном периоде --
  (p.kbk = _kbk
  AND EXISTS (SELECT
      *
    FROM kumi_payments_corrections kpc
    WHERE kpc.id_payment = p.id_payment
    AND kpc.field_name = 'Kbk'
    AND kpc.field_value <> _kbk
    AND kpc.date BETWEEN _startDate AND _finishDate))
  OR
  -- Платежи, уточненные с КБК найма в указанном периоде --
  (p.kbk <> _kbk
  AND EXISTS (SELECT
      *
    FROM kumi_payments_corrections kpc
    WHERE kpc.id_payment = p.id_payment
    AND kpc.field_name = 'Kbk'
    AND kpc.field_value = _kbk
    AND kpc.date BETWEEN _startDate AND _finishDate)));

  UPDATE _result_info ri
  SET ri.account = f_account_from_purpose(ri.purpose),
      ri.court_order = f_order_from_purpose(ri.purpose),
      ri.address = f_address_from_purpose(ri.purpose);

  SELECT
    ri.*,
    IF(COUNT(*) > 1, GROUP_CONCAT(CONCAT(ai.account, ' (', IFNULL(DATE_FORMAT(ai.last_charging_date, '%d.%m.%Y'), '-'), ')') SEPARATOR ', '), ai.account) AS account,
    IF(COUNT(*) > 1, GROUP_CONCAT(ai.balance_output_total SEPARATOR ', '), ai.balance_output_total) AS balance_output_total,
    IF(COUNT(*) > 1, GROUP_CONCAT(ai.tenant SEPARATOR ', '), ai.tenant) AS tenant
  FROM _result_info ri
    LEFT JOIN _accounts_info ai
      ON ((ri.account IS NOT NULL
      AND ri.account = ai.account)
      OR (ri.court_order IS NOT NULL
      AND (ai.court_orders LIKE CONCAT('%', ri.court_order, '%')
      OR ai.court_orders LIKE CONCAT('%', REPLACE(ri.court_order, '/20', '/'), '%')))
      OR (ri.address IS NOT NULL
      AND (ri.address = ai.parsed_address
      OR ri.address = ai.prepared_addrees)))
  GROUP BY ri.id_payment,
           ri.num_d,
           ri.date_d,
           ri.payer_name,
           ri.payer_inn,
           ri.sum_corrected,
           ri.sum_original,
           ri.purpose,
           ri.kbk,
           ri.prev_kbk,
           ri.note,
           ri.account,
           ri.address,
           ri.court_order,
           ri._estatebratsk_oid;
END
$$

DELIMITER ;

--
-- Создать таблицу `sequence`
--
CREATE TABLE IF NOT EXISTS sequence (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(50) NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 120713001,
AVG_ROW_LENGTH = 16384,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать функцию `f_nextval`
--
CREATE FUNCTION f_nextval (`seq_name` varchar(255))
RETURNS int(10) UNSIGNED
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
  UPDATE sequence
  SET id = LAST_INSERT_ID(id + 1)
  WHERE name = seq_name;
  RETURN LAST_INSERT_ID();
END
$$

DELIMITER ;

--
-- Создать таблицу `log_archive`
--
CREATE TABLE IF NOT EXISTS log_archive (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  `table` varchar(255) NOT NULL,
  id_key int(11) NOT NULL COMMENT 'Первичный ключ изменяемой записи в таблице',
  field_name varchar(255) NOT NULL,
  field_old_value text DEFAULT NULL,
  field_new_value text DEFAULT NULL,
  operation_type varchar(255) NOT NULL,
  operation_time datetime NOT NULL,
  user_name varchar(255) NOT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 72734949,
AVG_ROW_LENGTH = 104,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `date_index` для объекта типа таблица `log_archive`
--
ALTER TABLE log_archive
ADD INDEX date_index (operation_time);

DELIMITER $$

--
-- Создать событие `log_archive_event`
--
CREATE EVENT IF NOT EXISTS log_archive_event
	ON SCHEDULE EVERY '1' DAY
	STARTS '2016-01-15 15:00:00'
	DO 
BEGIN
  SET @datetime = NOW();
  INSERT INTO log_archive
  SELECT *
  FROM log l
  WHERE l.operation_time < DATE_SUB(@datetime, INTERVAL 3 MONTH);
  DELETE FROM log
  WHERE operation_time < DATE_SUB(@datetime, INTERVAL 3 MONTH);
  END
$$

ALTER EVENT log_archive_event
	ENABLE
$$

DELIMITER ;

--
-- Создать представление `v_kladr_regions`
--
CREATE
VIEW v_kladr_regions
AS
SELECT DISTINCT
  SUBSTR(`sn`.`CODE`, 1, (CHAR_LENGTH(`sn`.`CODE`) - 1)) AS `id_region`,
  `sn`.`NAME` AS `region`
FROM `kladr`.`kladr` `sn`
WHERE ((`sn`.`CODE` LIKE '380000050%')
AND (`sn`.`SOCR` = 'жилрайон'));

--
-- Создать таблицу `_unbinded_payment_claim_from_log`
--
CREATE TABLE IF NOT EXISTS _unbinded_payment_claim_from_log (
  id_key int(11) NOT NULL COMMENT 'Первичный ключ изменяемой записи в таблице',
  operation_time datetime NOT NULL,
  id_payment int(11) DEFAULT NULL,
  id_charge int(11) DEFAULT NULL,
  id_claim int(11) DEFAULT NULL,
  bind_date date DEFAULT NULL,
  tenancy_value decimal(12, 2) DEFAULT NULL,
  penalty_value decimal(12, 2) DEFAULT NULL,
  dgi_value decimal(12, 2) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 496,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_unbinded_payment_charge_from_log`
--
CREATE TABLE IF NOT EXISTS _unbinded_payment_charge_from_log (
  id_key int(11) NOT NULL COMMENT 'Первичный ключ изменяемой записи в таблице',
  operation_time datetime NOT NULL,
  id_payment int(11) DEFAULT NULL,
  id_charge int(11) DEFAULT NULL,
  id_claim int(11) DEFAULT NULL,
  bind_date date DEFAULT NULL,
  tenancy_value decimal(12, 2) DEFAULT NULL,
  penalty_value decimal(12, 2) DEFAULT NULL,
  dgi_value decimal(12, 2) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 528,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_ufk_payments`
--
CREATE TABLE IF NOT EXISTS _ufk_payments (
  num int(11) DEFAULT NULL,
  date date DEFAULT NULL,
  payer varchar(150) DEFAULT NULL,
  sum double(10, 3) DEFAULT NULL,
  purpose varchar(250) DEFAULT NULL,
  mo varchar(50) DEFAULT NULL,
  dist varchar(150) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 742,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_sep_report`
--
CREATE TABLE IF NOT EXISTS _sep_report (
  num_d varchar(255) DEFAULT NULL COMMENT '№ платежного документа / № распоряжения',
  date_d_str varchar(10) DEFAULT NULL,
  payer_name varchar(2000) DEFAULT NULL COMMENT 'Наименование плательщика',
  sum decimal(13, 2) DEFAULT NULL,
  purpose varchar(500) DEFAULT NULL COMMENT 'Назначение платежа',
  note varchar(31) DEFAULT NULL,
  account_info text DEFAULT NULL,
  group_index int DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 771,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_sep_payments`
--
CREATE TABLE IF NOT EXISTS _sep_payments (
  id_payment int(11) NOT NULL DEFAULT 0,
  sum decimal(12, 2) NOT NULL COMMENT 'Сумма платежа',
  kbk varchar(20) DEFAULT NULL COMMENT 'КБК',
  account_info text DEFAULT NULL,
  sum_posted decimal(65, 2) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 238,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_sep_other`
--
CREATE TABLE IF NOT EXISTS _sep_other (
  id_payment int(11) NOT NULL DEFAULT 0,
  num_d varchar(255) DEFAULT NULL,
  date_d date DEFAULT NULL,
  sum decimal(12, 2) NOT NULL DEFAULT 0.00,
  purpose varchar(500) DEFAULT NULL,
  payer_name text DEFAULT NULL,
  tenancy_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  penalty_value decimal(12, 2) NOT NULL DEFAULT 0.00
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 390,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_p_tenants`
--
CREATE TABLE IF NOT EXISTS _p_tenants (
  id_account int(11) NOT NULL,
  tenant varchar(255) DEFAULT NULL COMMENT 'Наниматель'
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 108,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_pkk`
--
CREATE TABLE IF NOT EXISTS _pkk (
  id_charge int(11) NOT NULL DEFAULT 0,
  id_account int(11) NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  balance_pkk decimal(12, 2) DEFAULT 0.00,
  charging_pkk decimal(12, 2) DEFAULT 0.00,
  recalc_pkk decimal(12, 2) DEFAULT 0.00,
  payment_pkk decimal(12, 2) DEFAULT 0.00,
  balance_output_pkk decimal(12, 2) DEFAULT 0.00
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 84,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `_pkk_idx` для объекта типа таблица `_pkk`
--
ALTER TABLE _pkk
ADD INDEX _pkk_idx (id_charge);

--
-- Создать таблицу `_payment_report`
--
CREATE TABLE IF NOT EXISTS _payment_report (
  num_d varchar(255) DEFAULT NULL COMMENT '№ платежного документа / № распоряжения',
  date_d_str varchar(10) DEFAULT NULL,
  payer_name varchar(2000) DEFAULT NULL COMMENT 'Наименование плательщика',
  sum decimal(13, 2) DEFAULT NULL,
  purpose varchar(500) DEFAULT NULL COMMENT 'Назначение платежа',
  note varchar(31) DEFAULT NULL,
  account_info text DEFAULT NULL,
  group_index int DEFAULT NULL,
  id_payment int(11) NOT NULL DEFAULT 0
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 1110,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_padun`
--
CREATE TABLE IF NOT EXISTS _padun (
  id_charge int(11) NOT NULL DEFAULT 0,
  id_account int(11) NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  balance_padun decimal(12, 2) DEFAULT 0.00,
  charging_padun decimal(12, 2) DEFAULT 0.00,
  recalc_padun decimal(12, 2) DEFAULT 0.00,
  payment_padun decimal(12, 2) DEFAULT 0.00,
  balance_output_padun decimal(12, 2) DEFAULT 0.00
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 119,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `_padun_idx` для объекта типа таблица `_padun`
--
ALTER TABLE _padun
ADD INDEX _padun_idx (id_charge);

--
-- Создать таблицу `_last_charge_date_info`
--
CREATE TABLE IF NOT EXISTS _last_charge_date_info (
  date datetime DEFAULT NULL COMMENT 'Дата, на которую заносятся данные о платежах',
  id_account int(11) NOT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 75,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_kumi_accounts_address_infix`
--
CREATE TABLE IF NOT EXISTS _kumi_accounts_address_infix (
  id_account int(11) NOT NULL DEFAULT 0,
  infix varchar(55) NOT NULL DEFAULT '',
  address text DEFAULT NULL,
  total_area double NOT NULL DEFAULT 0,
  post_index varchar(6) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 189,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `_kumi_accounts_address_infix_idx` для объекта типа таблица `_kumi_accounts_address_infix`
--
ALTER TABLE _kumi_accounts_address_infix
ADD INDEX _kumi_accounts_address_infix_idx (id_account, infix);

--
-- Создать таблицу `_fias_postal_codes`
--
CREATE TABLE IF NOT EXISTS _fias_postal_codes (
  id_building int(11) NOT NULL DEFAULT 0,
  AOGUID varchar(36) DEFAULT NULL,
  HOUSEGUID varchar(36) DEFAULT NULL,
  POSTALCODE varchar(6) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 125,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_dist_sep_payments`
--
CREATE TABLE IF NOT EXISTS _dist_sep_payments (
  id_assoc int(11) NOT NULL DEFAULT 0,
  id_payment int(11) NOT NULL DEFAULT 0,
  id_charge int(11) NOT NULL DEFAULT 0,
  date date NOT NULL DEFAULT '0000-00-00',
  tenancy_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  penalty_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  dgi_value decimal(12, 2) DEFAULT NULL,
  pkk_value decimal(12, 2) DEFAULT NULL,
  padun_value decimal(12, 2) DEFAULT NULL,
  id_display_charge int(11) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 92,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_dist_aug_payments`
--
CREATE TABLE IF NOT EXISTS _dist_aug_payments (
  id_assoc int(11) NOT NULL DEFAULT 0,
  id_payment int(11) NOT NULL DEFAULT 0,
  id_charge int(11) NOT NULL DEFAULT 0,
  date date NOT NULL DEFAULT '0000-00-00',
  tenancy_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  penalty_value decimal(12, 2) NOT NULL DEFAULT 0.00,
  dgi_value decimal(12, 2) DEFAULT NULL,
  pkk_value decimal(12, 2) DEFAULT NULL,
  padun_value decimal(12, 2) DEFAULT NULL,
  id_display_charge int(11) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 92,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_distr_error_payments`
--
CREATE TABLE IF NOT EXISTS _distr_error_payments (
  id_payment int(11) NOT NULL DEFAULT 0,
  id_parent_payment int(11) DEFAULT NULL,
  id_group int(11) DEFAULT NULL COMMENT 'Идентификатор группы платежей',
  id_source int(11) NOT NULL COMMENT 'Источник информации',
  guid varchar(36) DEFAULT NULL COMMENT 'GUID платежа',
  id_payment_doc_code int(11) DEFAULT NULL,
  num_d varchar(255) DEFAULT NULL COMMENT '№ платежного документа / № распоряжения',
  date_d date DEFAULT NULL COMMENT 'Дата платежного документа / Дата распоряжения',
  date_in date DEFAULT NULL COMMENT 'Дата поступления в банк плательщика',
  date_e date DEFAULT NULL COMMENT 'Дата списания со счета плательщика / Дата исполнения распоряжения',
  date_pay date DEFAULT NULL COMMENT 'Срок платежа',
  id_payment_kind int(11) DEFAULT NULL COMMENT 'Вид платежа',
  order_pay int(11) DEFAULT NULL COMMENT 'Очередность платежа',
  id_operation_type int(11) DEFAULT NULL COMMENT 'Вид операции',
  sum decimal(12, 2) NOT NULL COMMENT 'Сумма платежа',
  uin varchar(25) DEFAULT NULL COMMENT 'УИН',
  id_purpose int(11) DEFAULT NULL COMMENT 'Назначение платежа кодовое',
  purpose varchar(500) DEFAULT NULL COMMENT 'Назначение платежа',
  kbk varchar(20) DEFAULT NULL COMMENT 'КБК',
  id_kbk_type int(11) DEFAULT NULL COMMENT 'Тип КБК',
  target_code varchar(25) DEFAULT NULL COMMENT 'Код цели',
  okato varchar(20) DEFAULT NULL COMMENT 'Код ОКТМО',
  id_payment_reason int(11) DEFAULT NULL COMMENT 'Показатель основания платежа',
  num_d_indicator varchar(15) DEFAULT NULL COMMENT 'Показатель номера документа',
  date_d_indicator date DEFAULT NULL COMMENT 'Показатель даты документа',
  id_payer_status int(11) DEFAULT NULL COMMENT 'Статус составителя расчетного документа',
  payer_inn varchar(12) DEFAULT NULL COMMENT 'ИНН плательщика',
  payer_kpp varchar(12) DEFAULT NULL COMMENT 'КПП плательщика',
  payer_name varchar(2000) DEFAULT NULL COMMENT 'Наименование плательщика',
  payer_account varchar(20) DEFAULT NULL COMMENT 'Счет плательщика',
  payer_bank_bik varchar(9) DEFAULT NULL COMMENT 'БИК банка плательщика',
  payer_bank_name varchar(160) DEFAULT NULL COMMENT 'Наименование банка плательщика',
  payer_bank_account varchar(20) DEFAULT NULL COMMENT 'Коррсчет банк плательщика',
  recipient_inn varchar(12) DEFAULT NULL COMMENT 'ИНН получателя',
  recipient_kpp varchar(12) DEFAULT NULL COMMENT 'КПП получателя',
  recipient_name varchar(2000) DEFAULT NULL COMMENT 'Наименование получателя',
  recipient_account varchar(20) DEFAULT NULL COMMENT 'Счет получателя',
  recipient_bank_bik varchar(9) DEFAULT NULL COMMENT 'БИК банка получателя',
  recipient_bank_name varchar(160) DEFAULT NULL COMMENT 'Наименование банка получателя',
  recipient_bank_account varchar(20) DEFAULT NULL COMMENT 'Коррсчет банк получателя',
  description varchar(1024) DEFAULT NULL COMMENT 'Описание платежа (с указанием ЛС/ПИР/Адреса)',
  date_enroll_ufk date DEFAULT NULL COMMENT 'Дата зачисления на счет УФК',
  is_posted tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Признак разноски',
  is_consolidated tinyint(1) NOT NULL DEFAULT 0,
  deleted tinyint(1) NOT NULL DEFAULT 0,
  _estatebratsk_oid varchar(12) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 1260,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_diff_charge_total_bks_chargin_per_process`
--
CREATE TABLE IF NOT EXISTS _diff_charge_total_bks_chargin_per_process (
  id_process int(11) NOT NULL,
  total_charging_tenancy decimal(34, 2) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 55,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_diff_charge_state_3`
--
CREATE TABLE IF NOT EXISTS _diff_charge_state_3 (
  id_process int(11) NOT NULL DEFAULT 0,
  account varchar(255) NOT NULL,
  k_address text DEFAULT NULL,
  bks_tenant varchar(255) DEFAULT NULL COMMENT 'Наниматель',
  k_tenant varchar(355) DEFAULT NULL,
  registration_num varchar(255) DEFAULT NULL COMMENT 'Номер договора найма',
  bks_total_tenancy_per_process decimal(12, 2) DEFAULT NULL,
  k_total_tenancy_per_process double(21, 4) DEFAULT NULL,
  bks_charging_tenancy decimal(12, 2) DEFAULT NULL,
  k_payment double(21, 4) DEFAULT NULL,
  fraction decimal(10, 4) NOT NULL DEFAULT 1.0000,
  coeff decimal(18, 6) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 376,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_diff_charge_state_2`
--
CREATE TABLE IF NOT EXISTS _diff_charge_state_2 (
  id_account int(11) NOT NULL DEFAULT 0,
  id_process int(11) NOT NULL,
  account varchar(255) NOT NULL,
  k_address text DEFAULT NULL,
  bks_address varchar(255) DEFAULT NULL COMMENT 'Исходный адрес',
  bks_charging_tenancy decimal(12, 2) DEFAULT NULL,
  bks_charging_penalties decimal(12, 2) DEFAULT NULL,
  bks_balance_output_tenancy decimal(12, 2) DEFAULT NULL,
  bks_balance_output_penalties decimal(12, 2) DEFAULT NULL,
  bks_tenant varchar(255) DEFAULT NULL COMMENT 'Наниматель',
  k_tenant varchar(355) DEFAULT NULL,
  bks_total_tenancy_per_process decimal(12, 2) DEFAULT NULL,
  k_total_tenancy_per_process double(21, 4) DEFAULT NULL,
  coeff decimal(18, 6) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 478,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_diff_charge_state_1`
--
CREATE TABLE IF NOT EXISTS _diff_charge_state_1 (
  id_account int(11) NOT NULL DEFAULT 0,
  id_process int(11) NOT NULL,
  account varchar(255) NOT NULL,
  k_address text DEFAULT NULL,
  bks_address varchar(255) DEFAULT NULL COMMENT 'Исходный адрес',
  bks_charging_tenancy decimal(12, 2) DEFAULT NULL,
  bks_charging_penalties decimal(12, 2) DEFAULT NULL,
  bks_balance_output_tenancy decimal(12, 2) DEFAULT NULL,
  bks_balance_output_penalties decimal(12, 2) DEFAULT NULL,
  bks_tenant varchar(255) DEFAULT NULL COMMENT 'Наниматель',
  k_tenant varchar(355) DEFAULT NULL,
  bks_total_tenancy_per_process decimal(12, 2) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 481,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `_dgi`
--
CREATE TABLE IF NOT EXISTS _dgi (
  id_charge int(11) NOT NULL DEFAULT 0,
  id_account int(11) NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  balance_dgi decimal(12, 2) NOT NULL,
  charging_dgi decimal(12, 2) NOT NULL,
  recalc_dgi decimal(12, 2) NOT NULL,
  payment_dgi decimal(12, 2) NOT NULL,
  balance_output_dgi decimal(12, 2) NOT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 77,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `_dgi_idx` для объекта типа таблица `_dgi`
--
ALTER TABLE _dgi
ADD INDEX _dgi_idx (id_charge);

--
-- Создать таблицу `priv_contractor_warrant_templates`
--
CREATE TABLE IF NOT EXISTS priv_contractor_warrant_templates (
  id_template int(11) NOT NULL AUTO_INCREMENT,
  warrant_text varchar(2000) NOT NULL,
  id_category int(11) DEFAULT NULL,
  PRIMARY KEY (id_template)
)
ENGINE = INNODB,
AUTO_INCREMENT = 93,
AVG_ROW_LENGTH = 847,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `preparers`
--
CREATE TABLE IF NOT EXISTS preparers (
  id_preparer int(11) NOT NULL AUTO_INCREMENT,
  preparer_name varchar(255) NOT NULL,
  `position` varchar(255) DEFAULT NULL,
  short_position varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_preparer)
)
ENGINE = INNODB,
AUTO_INCREMENT = 14,
AVG_ROW_LENGTH = 1820,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `notify_tenancy_print_log`
--
CREATE TABLE IF NOT EXISTS notify_tenancy_print_log (
  id_log int(11) NOT NULL AUTO_INCREMENT,
  notify_type varchar(255) NOT NULL,
  id_process int(11) NOT NULL,
  date datetime NOT NULL,
  user varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_log)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3596,
AVG_ROW_LENGTH = 144,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `log_invoice_generator`
--
CREATE TABLE IF NOT EXISTS log_invoice_generator (
  id int(11) NOT NULL AUTO_INCREMENT,
  id_account int(11) NOT NULL,
  account_type int(11) NOT NULL DEFAULT 1,
  create_date datetime NOT NULL,
  on_date date NOT NULL,
  emails text DEFAULT NULL,
  result_code int(11) DEFAULT NULL,
  sender_login varchar(255) DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 754,
AVG_ROW_LENGTH = 135,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `log_invoice_generator_before_insert`
--
CREATE TRIGGER log_invoice_generator_before_insert
BEFORE INSERT
ON log_invoice_generator
FOR EACH ROW
BEGIN
  SET NEW.sender_login = SUBSTRING(USER(), 1, LOCATE('@', USER()) - 1);
END
$$

DELIMITER ;

--
-- Создать таблицу `lawyers`
--
CREATE TABLE IF NOT EXISTS lawyers (
  id_lawyer int(11) NOT NULL AUTO_INCREMENT,
  snp varchar(255) NOT NULL,
  post varchar(255) NOT NULL,
  PRIMARY KEY (id_lawyer)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_payments_setting_sets`
--
CREATE TABLE IF NOT EXISTS kumi_payments_setting_sets (
  id_setting_set int(11) NOT NULL AUTO_INCREMENT,
  code_ubp varchar(8) DEFAULT NULL,
  name_ubp varchar(2000) DEFAULT NULL,
  account_ubp varchar(11) DEFAULT NULL,
  name_grs varchar(2000) DEFAULT NULL,
  glava_grs varchar(3) DEFAULT NULL,
  okpo_fo varchar(8) DEFAULT NULL,
  name_fo varchar(2000) DEFAULT NULL,
  account_fo varchar(11) DEFAULT NULL,
  code_tofk varchar(4) DEFAULT NULL,
  name_tofk varchar(2000) DEFAULT NULL,
  name_budget varchar(512) DEFAULT NULL,
  budget_level varchar(1) DEFAULT NULL,
  PRIMARY KEY (id_setting_set)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_key_rates`
--
CREATE TABLE IF NOT EXISTS kumi_key_rates (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  start_date date NOT NULL,
  value decimal(10, 2) NOT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 94,
AVG_ROW_LENGTH = 910,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_kbk_descriptions`
--
CREATE TABLE IF NOT EXISTS kumi_kbk_descriptions (
  id_kbk_description int(11) NOT NULL AUTO_INCREMENT,
  kbk varchar(20) NOT NULL,
  description varchar(1024) NOT NULL,
  PRIMARY KEY (id_kbk_description)
)
ENGINE = INNODB,
AUTO_INCREMENT = 25,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `kumi_accounts_address_infix`
--
CREATE TABLE IF NOT EXISTS kumi_accounts_address_infix (
  id_record int(11) NOT NULL AUTO_INCREMENT,
  id_account int(11) NOT NULL,
  infix varchar(256) NOT NULL,
  address varchar(1024) NOT NULL,
  total_area double DEFAULT NULL,
  post_index varchar(6) DEFAULT NULL,
  PRIMARY KEY (id_record)
)
ENGINE = INNODB,
AUTO_INCREMENT = 98821,
AVG_ROW_LENGTH = 188,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `IDX_kumi_accounts_address_infi` для объекта типа таблица `kumi_accounts_address_infix`
--
ALTER TABLE kumi_accounts_address_infix
ADD INDEX IDX_kumi_accounts_address_infi (infix (255), id_account);

--
-- Создать внешний ключ
--
ALTER TABLE kumi_accounts_address_infix
ADD CONSTRAINT FK_kumi_accounts_address_infix FOREIGN KEY (id_account)
REFERENCES kumi_accounts (id_account) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `employers`
--
CREATE TABLE IF NOT EXISTS employers (
  id_employer int(11) NOT NULL AUTO_INCREMENT,
  employer varchar(255) NOT NULL,
  PRIMARY KEY (id_employer)
)
ENGINE = INNODB,
AUTO_INCREMENT = 69,
AVG_ROW_LENGTH = 303,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `district_committees_pre_conctract_preambles`
--
CREATE TABLE IF NOT EXISTS district_committees_pre_conctract_preambles (
  id_preamble int(11) NOT NULL AUTO_INCREMENT,
  name varchar(255) NOT NULL,
  preamble varchar(4096) NOT NULL,
  PRIMARY KEY (id_preamble)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `district_committees`
--
CREATE TABLE IF NOT EXISTS district_committees (
  id_committee int(11) NOT NULL AUTO_INCREMENT,
  name_nominative varchar(255) NOT NULL,
  name_genetive varchar(255) NOT NULL,
  name_prepositional varchar(255) NOT NULL,
  head_snp_genetive varchar(255) NOT NULL,
  head_post_genetive varchar(255) NOT NULL,
  head_snp varchar(255) DEFAULT NULL,
  head_post varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_committee)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `act_type_document`
--
CREATE TABLE IF NOT EXISTS act_type_document (
  id int(11) NOT NULL AUTO_INCREMENT,
  act_file_type varchar(50) NOT NULL,
  name varchar(50) NOT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 10,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать функцию `f_trigrammer`
--
CREATE FUNCTION f_trigrammer (address varchar(1024))
RETURNS varchar(4096) CHARSET utf8
BEGIN
  SET @buffer = '___';
  SET @address = address;
  SET @result = '';
  WHILE (CHAR_LENGTH(@address) > 0) DO
    SET @char = SUBSTRING(@address, 1, 1);
    SET @address = SUBSTRING(@address, 2);
    SET @buffer = CONCAT(SUBSTRING(@buffer, 2), @char);
    SET @result = CONCAT(@result, ' ', @buffer);
  END WHILE;
  SET @buffer = CONCAT(SUBSTRING(@buffer, 2), '_');
  SET @result = CONCAT(@result, ' ', @buffer);
  SET @buffer = CONCAT(SUBSTRING(@buffer, 2), '_');
  SET @result = CONCAT(@result, ' ', @buffer);
  RETURN @result;
END
$$

--
-- Создать функцию `f_account_from_purpose`
--
CREATE FUNCTION f_account_from_purpose (purpose varchar(500))
RETURNS varchar(255) CHARSET utf8
BEGIN
  DECLARE result varchar(255);
  DECLARE firstIndex int;
  DECLARE delimeter char;
  DECLARE offset int;
  DECLARE tempstr varchar(50);

  SET firstIndex = (SELECT
      LOCATE('ЛИЦЕВОЙ СЧЕТ', purpose));
  SET delimeter = ';';
  SET offset = 13;
  IF firstIndex = 0 THEN
    SET firstIndex = (SELECT
        LOCATE('лс ', purpose));
    IF (firstIndex <> 0) THEN
      SET offset = 3;
    END IF;
  END IF;

  IF firstIndex = 0 THEN
    SET firstIndex = (SELECT
        LOCATE('л/с', purpose));
    /* SET delimeter = '.'; 
    SET offset = 4; */

    SET offset = IF(LOCATE('л/сч', purpose) <> 0, 5, 4);
    SET tempstr = SUBSTR(purpose, firstIndex + offset, 10);
    SET delimeter = IF(LOCATE('.', SUBSTR(purpose, firstIndex + offset, 10)) <> 0, '.', ' ');
  END IF;

  IF firstIndex <> 0 THEN
    SET tempstr = SUBSTR(purpose, firstIndex + offset);
    /* Почему-то пробел  в substring_index не хочет работать */
    IF delimeter = ' ' THEN
      SET result = SUBSTRING_INDEX(tempstr, ' ', 1);
    ELSE
      SET result = SUBSTRING_INDEX(tempstr, delimeter, 1);
    END IF;
    RETURN TRIM(result);
  ELSE
    RETURN NULL;
  END IF;

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