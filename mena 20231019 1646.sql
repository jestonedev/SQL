--
-- Скрипт сгенерирован Devart dbForge Studio for MySQL, Версия 7.4.201.0
-- Домашняя страница продукта: http://www.devart.com/ru/dbforge/mysql/studio
-- Дата скрипта: 19.10.2023 16:46:35
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

DROP DATABASE IF EXISTS mena;

CREATE DATABASE IF NOT EXISTS mena
CHARACTER SET utf8
COLLATE utf8_general_ci;

--
-- Установка базы данных по умолчанию
--
USE mena;

--
-- Создать таблицу `document_signers`
--
CREATE TABLE IF NOT EXISTS document_signers (
  id_document int(11) NOT NULL AUTO_INCREMENT,
  id_contract int(11) UNSIGNED NOT NULL,
  id_agreement_signer int(11) DEFAULT 2,
  id_order_boss int(11) DEFAULT 5,
  id_order_commitet_signer int(11) DEFAULT 2,
  id_order_verify_lawer int(11) DEFAULT 4,
  id_order_verify_boss int(11) DEFAULT 6,
  id_order_worker int(11) DEFAULT 3,
  id_invite_signer int(11) DEFAULT 2,
  id_invite_worker int(11) DEFAULT 3,
  id_notify_signer int(11) DEFAULT 2,
  id_notify_worker int(11) DEFAULT 3,
  id_rasp_boss int(11) DEFAULT 5,
  id_rasp_verify int(11) DEFAULT 6,
  id_rasp_lawer int(11) DEFAULT 4,
  id_rasp_executor int(11) DEFAULT 3,
  PRIMARY KEY (id_document)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3916,
AVG_ROW_LENGTH = 83,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `UK_document_signers_id_contrac` для объекта типа таблица `document_signers`
--
ALTER TABLE document_signers
ADD UNIQUE INDEX UK_document_signers_id_contrac (id_contract);

--
-- Создать таблицу `contracts`
--
CREATE TABLE IF NOT EXISTS contracts (
  id_contract int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_delegate tinyint(4) UNSIGNED NOT NULL DEFAULT 1,
  id_executor tinyint(3) UNSIGNED NOT NULL DEFAULT 3,
  id_apartment_side1 int(11) UNSIGNED DEFAULT NULL,
  id_apartment_side2 int(11) UNSIGNED DEFAULT NULL,
  id_apartment_side12 int(11) UNSIGNED DEFAULT NULL,
  pre_contract_date datetime DEFAULT NULL,
  id_pre_contract_issued tinyint(4) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'кто выдает предварительные договора',
  id_contract_reason int(11) NOT NULL DEFAULT 1,
  contract_Registration_date datetime DEFAULT NULL,
  agreement_registration_date datetime DEFAULT NULL,
  id_agreement_represent int(11) UNSIGNED DEFAULT NULL,
  pre_contract_number varchar(20) DEFAULT NULL,
  order_number varchar(20) DEFAULT NULL,
  order_date datetime DEFAULT NULL,
  was_deleted tinyint(1) NOT NULL DEFAULT 0,
  last_change_date datetime NOT NULL DEFAULT '1986-11-15 00:00:00',
  last_change_user varchar(50) NOT NULL DEFAULT 'bad_user',
  filing_date datetime DEFAULT NULL COMMENT 'дата подачи заявления',
  eviction_required tinyint(1) DEFAULT 0,
  PRIMARY KEY (id_contract)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3862,
AVG_ROW_LENGTH = 250,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Договора';

--
-- Создать индекс `IDX_contracts` для объекта типа таблица `contracts`
--
ALTER TABLE contracts
ADD INDEX IDX_contracts (id_apartment_side1, id_apartment_side2);

DELIMITER $$

--
-- Создать триггер `contracts_insert`
--
CREATE TRIGGER contracts_insert
AFTER INSERT
ON contracts
FOR EACH ROW
BEGIN
  INSERT INTO document_signers (id_contract)
    VALUES (new.id_contract);
END
$$

--
-- Создать триггер `contracts_log_ins`
--
CREATE TRIGGER contracts_log_ins
BEFORE INSERT
ON contracts
FOR EACH ROW
BEGIN
  SET new.last_change_date = NOW();
  SET new.last_change_user = USER();
END
$$

--
-- Создать триггер `contracts_log_upd`
--
CREATE TRIGGER contracts_log_upd
BEFORE UPDATE
ON contracts
FOR EACH ROW
BEGIN
  SET new.last_change_date = NOW();
  SET new.last_change_user = USER();
END
$$

--
-- Создать триггер `contracts_upd_workers`
--
CREATE TRIGGER contracts_upd_workers
AFTER UPDATE
ON contracts
FOR EACH ROW
BEGIN
/*update document_signers
  set id_order_worker=new.id_executor,
      id_invite_worker=new.id_executor,
      id_notify_worker=new.id_executor
  where id_contract=new.id_contract;*/
END
$$

DELIMITER ;

--
-- Создать внешний ключ
--
ALTER TABLE document_signers
ADD CONSTRAINT FK_document_signers_contracts_id_contract FOREIGN KEY (id_contract)
REFERENCES contracts (id_contract) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Создать таблицу `template_variables`
--
CREATE TABLE IF NOT EXISTS template_variables (
  id_template_variable int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_template_variable_meta int(11) UNSIGNED NOT NULL,
  id_object int(11) UNSIGNED NOT NULL,
  value varchar(255) NOT NULL,
  PRIMARY KEY (id_template_variable)
)
ENGINE = INNODB,
AUTO_INCREMENT = 43808,
AVG_ROW_LENGTH = 56,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `FK_template_variable_meta` для объекта типа таблица `template_variables`
--
ALTER TABLE template_variables
ADD INDEX FK_template_variable_meta (id_template_variable_meta);

--
-- Создать индекс `UK_template_variables` для объекта типа таблица `template_variables`
--
ALTER TABLE template_variables
ADD UNIQUE INDEX UK_template_variables (id_object, id_template_variable_meta);

--
-- Создать таблицу `template_variables_meta`
--
CREATE TABLE IF NOT EXISTS template_variables_meta (
  id_template_variable_meta int(11) NOT NULL AUTO_INCREMENT,
  id_template int(11) NOT NULL,
  pattern varchar(255) NOT NULL,
  label varchar(255) NOT NULL,
  type varchar(255) NOT NULL DEFAULT 'edit',
  PRIMARY KEY (id_template_variable_meta)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1420,
AVG_ROW_LENGTH = 81,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать индекс `UK_template_variables_meta` для объекта типа таблица `template_variables_meta`
--
ALTER TABLE template_variables_meta
ADD UNIQUE INDEX UK_template_variables_meta (id_template, pattern);

DELIMITER $$

--
-- Создать функцию `get_template_var`
--
CREATE FUNCTION get_template_var (id_template_in int, id_object_in int, var_pattern varchar(255))
RETURNS varchar(255) CHARSET utf8
BEGIN
  DECLARE rez varchar(255);
  SET rez = (SELECT
      VALUE
    FROM template_variables tv
      LEFT JOIN template_variables_meta tvm
        ON tvm.id_template_variable_meta = tv.id_template_variable_meta
        AND id_object = id_object_in
    WHERE pattern = var_pattern);
  RETURN rez;
END
$$

--
-- Создать функцию `get_template_fio`
--
CREATE FUNCTION get_template_fio (id_template_in int, id_object_in int, var_pattern varchar(255))
RETURNS varchar(255) CHARSET utf8
BEGIN
  DECLARE rez varchar(255);
  SET rez = (SELECT
      tv.value
    FROM template_variables tv
      LEFT JOIN template_variables_meta tvm
        ON tvm.id_template_variable_meta = tv.id_template_variable_meta
        AND tv.id_object = id_object_in
    WHERE tvm.id_template = id_template_in
    AND tvm.pattern = var_pattern);
  RETURN rez;
END
$$

DELIMITER ;

--
-- Создать таблицу `sp_warrant_template`
--
CREATE TABLE IF NOT EXISTS sp_warrant_template (
  id_warrant_template int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  warrant_template_name varchar(2000) DEFAULT NULL,
  warrant_template varchar(2000) DEFAULT NULL,
  id_warrant_template_type smallint(6) DEFAULT NULL,
  wasDeleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_warrant_template)
)
ENGINE = INNODB,
AUTO_INCREMENT = 483,
AVG_ROW_LENGTH = 835,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `template_OnDelete`
--
CREATE TRIGGER template_OnDelete
BEFORE DELETE
ON sp_warrant_template
FOR EACH ROW
BEGIN
  DELETE
    FROM template_variables_meta
  WHERE id_template = old.id_warrant_template;
END
$$

--
-- Создать функцию `template`
--
CREATE FUNCTION template (id_template_in int, id_object_in int)
RETURNS varchar(4000) CHARSET utf8
BEGIN
  DECLARE done integer DEFAULT 0;
  DECLARE str varchar(2000);
  DECLARE tmp varchar(2000);
  DECLARE template_var varchar(4000);
  DECLARE CURSOR1 CURSOR FOR
  SELECT
    pattern,
    IFNULL(`value`, '') AS value
  FROM template_variables_meta tvm
    LEFT JOIN template_variables tv
      ON tvm.id_template_variable_meta = tv.id_template_variable_meta
  WHERE id_template = id_template_in
  AND id_object = id_object_in;

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

  SET template_var = (SELECT
      TRIM(warrant_template)
    FROM sp_warrant_template swt
    WHERE id_warrant_template = id_template_in);

  OPEN CURSOR1;

  WHILE done = 0 DO
    FETCH CURSOR1 INTO tmp, str;
    SET template_var = REPLACE(template_var, tmp, str);
  -- SELECT REPLACE(template_var, tmp, str) INTO template_var;
  END WHILE;

  CLOSE CURSOR1;
  /*
  IF isnull(template_var) THEN
  SET template_var=(SELECT TRIM(warrant_template_name) FROM sp_warrant_template swt
  WHERE id_warrant_template = id_template_in);
  END IF;
  */
  RETURN template_var;
END
$$

--
-- Создать процедуру `contract`
--
CREATE PROCEDURE contract ()
BEGIN
  SELECT
    id_warrant_template AS a,
    warrant_template_name,
    warrant_template,
    CASE WHEN id_warrant_template_type = 10 THEN (SELECT
              warrant_template
            FROM sp_warrant_template
            WHERE id_warrant_template = a + 2
            AND id_warrant_template_type = 10) END AS pole
  FROM sp_warrant_template
  WHERE id_warrant_template_type = 10
  GROUP BY warrant_template_name;
END
$$

DELIMITER ;

--
-- Создать таблицу `warrant_apartment`
--
CREATE TABLE IF NOT EXISTS warrant_apartment (
  id_warrant_apartment int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_warrant_template int(11) UNSIGNED NOT NULL,
  id_apartment int(11) UNSIGNED NOT NULL,
  PRIMARY KEY (id_warrant_apartment)
)
ENGINE = INNODB,
AUTO_INCREMENT = 14937,
AVG_ROW_LENGTH = 52,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Основание собстенности на ж.п.';

--
-- Создать индекс `IDX_warrant_apartment` для объекта типа таблица `warrant_apartment`
--
ALTER TABLE warrant_apartment
ADD INDEX IDX_warrant_apartment (id_warrant_template, id_apartment);

--
-- Создать индекс `IDX_warrant_apartment_id_apartment` для объекта типа таблица `warrant_apartment`
--
ALTER TABLE warrant_apartment
ADD INDEX IDX_warrant_apartment_id_apartment (id_apartment);

--
-- Создать представление `v_warrant_apartment_side2`
--
CREATE
VIEW v_warrant_apartment_side2
AS
SELECT
  `wa`.`id_warrant_apartment` AS `id_warrant_apartment`,
  `template`(`wa`.`id_warrant_template`, `wa`.`id_warrant_apartment`) AS `warrant_apartment_txt`,
  `wa`.`id_warrant_template` AS `id_warrant_template`,
  `wa`.`id_apartment` AS `id_apartment`
FROM ((`warrant_apartment` `wa`
  JOIN `contracts` `c`
    ON ((`wa`.`id_apartment` = `c`.`id_apartment_side2`)))
  JOIN `sp_warrant_template` `swt`
    ON ((`wa`.`id_warrant_template` = `swt`.`id_warrant_template`)));

--
-- Создать представление `v_warrant_apartment_side12`
--
CREATE
VIEW v_warrant_apartment_side12
AS
SELECT
  `wa`.`id_warrant_apartment` AS `id_warrant_apartment`,
  IFNULL(`template`(`wa`.`id_warrant_template`, `wa`.`id_warrant_apartment`), `swt`.`warrant_template_name`) AS `warrant_apartment_txt`,
  `wa`.`id_warrant_template` AS `id_warrant_template`,
  `wa`.`id_apartment` AS `id_apartment`
FROM ((`warrant_apartment` `wa`
  JOIN `contracts` `c`
    ON ((`wa`.`id_apartment` = `c`.`id_apartment_side12`)))
  JOIN `sp_warrant_template` `swt`
    ON ((`wa`.`id_warrant_template` = `swt`.`id_warrant_template`)));

--
-- Создать представление `v_warrant_apartment_side1`
--
CREATE
VIEW v_warrant_apartment_side1
AS
SELECT
  `wa`.`id_warrant_apartment` AS `id_warrant_apartment`,
  IFNULL(`template`(`wa`.`id_warrant_template`, `wa`.`id_warrant_apartment`), `swt`.`warrant_template_name`) AS `warrant_apartment_txt`,
  `wa`.`id_warrant_template` AS `id_warrant_template`,
  `wa`.`id_apartment` AS `id_apartment`
FROM ((`warrant_apartment` `wa`
  JOIN `contracts` `c`
    ON ((`wa`.`id_apartment` = `c`.`id_apartment_side1`)))
  JOIN `sp_warrant_template` `swt`
    ON ((`wa`.`id_warrant_template` = `swt`.`id_warrant_template`)));

--
-- Создать таблицу `apartments`
--
CREATE TABLE IF NOT EXISTS apartments (
  id_apartment int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_apartment_type tinyint(3) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'тип жп',
  id_street varchar(17) NOT NULL DEFAULT '00000000000000000' COMMENT 'улица',
  house varchar(5) DEFAULT NULL COMMENT 'дом',
  flat varchar(10) DEFAULT NULL COMMENT 'квартира',
  `index` varchar(15) DEFAULT NULL,
  total_area decimal(8, 2) DEFAULT NULL COMMENT 'общая площадь',
  part varchar(5) NOT NULL DEFAULT '1' COMMENT 'доля',
  living_area decimal(8, 2) DEFAULT NULL COMMENT 'жилая плошадь',
  house_floor varchar(5) DEFAULT NULL COMMENT 'этажность дома',
  floor varchar(5) DEFAULT NULL COMMENT 'этаж',
  inventory_number varchar(50) DEFAULT NULL COMMENT 'кадастровый номер',
  room_count varchar(5) DEFAULT NULL COMMENT 'кол-во комнат',
  room varchar(5) DEFAULT NULL COMMENT 'комната',
  cadastral_price decimal(19, 2) DEFAULT NULL,
  disaster_housing tinyint(1) DEFAULT 0,
  PRIMARY KEY (id_apartment)
)
ENGINE = INNODB,
AUTO_INCREMENT = 7752,
AVG_ROW_LENGTH = 122,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Квартиры';

--
-- Создать индекс `IDX_apartments` для объекта типа таблица `apartments`
--
ALTER TABLE apartments
ADD INDEX IDX_apartments (id_street, house);

--
-- Создать представление `v_contract_side2_warrants`
--
CREATE
VIEW v_contract_side2_warrants
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  GROUP_CONCAT(`vwa2`.`warrant_apartment_txt` SEPARATOR ', ') AS `side2_warrants`
FROM ((`contracts` `c`
  LEFT JOIN `apartments` `a2`
    ON ((`c`.`id_apartment_side2` = `a2`.`id_apartment`)))
  LEFT JOIN `v_warrant_apartment_side2` `vwa2`
    ON ((`vwa2`.`id_apartment` = `a2`.`id_apartment`)))
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_info_contracts`
--
CREATE
VIEW v_info_contracts
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  `kladr`.`get_street_name_for_kladr_without_socr`(`a1`.`id_street`) AS `street1`,
  `a1`.`house` AS `house1`,
  `a1`.`flat` AS `flat1`,
  `kladr`.`get_street_name_for_kladr_without_socr`(`a2`.`id_street`) AS `street2`,
  `a2`.`house` AS `house2`,
  `a2`.`flat` AS `flat2`,
  `vcs2w`.`side2_warrants` AS `side2_warrants`
FROM (((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`apartments` `a1`
    ON ((`a1`.`id_apartment` = `c`.`id_apartment_side1`)))
  LEFT JOIN `mena`.`apartments` `a2`
    ON ((`a2`.`id_apartment` = `c`.`id_apartment_side2`)))
  LEFT JOIN `mena`.`v_contract_side2_warrants` `vcs2w`
    ON ((`vcs2w`.`id_contract` = `c`.`id_contract`)))
ORDER BY `c`.`id_contract`;

--
-- Создать представление `v_apart_id_contract`
--
CREATE
VIEW v_apart_id_contract
AS
SELECT
  `a`.`id_apartment` AS `id_apartment`,
  `a`.`id_apartment_type` AS `id_apartment_type`,
  `a`.`id_street` AS `id_street`,
  `a`.`house` AS `house`,
  `a`.`flat` AS `flat`,
  `a`.`index` AS `index`,
  `a`.`total_area` AS `total_area`,
  `a`.`part` AS `part`,
  `a`.`living_area` AS `living_area`,
  `a`.`house_floor` AS `house_floor`,
  `a`.`floor` AS `floor`,
  `a`.`inventory_number` AS `inventory_number`,
  `a`.`room_count` AS `room_count`,
  `a`.`room` AS `room`,
  `c`.`id_contract` AS `id_contract`,
  `vcs2w`.`side2_warrants` AS `side2_warrants`
FROM ((`apartments` `a`
  LEFT JOIN `contracts` `c`
    ON ((`c`.`id_apartment_side2` = `a`.`id_apartment`)))
  LEFT JOIN `v_contract_side2_warrants` `vcs2w`
    ON ((`vcs2w`.`id_contract` = `c`.`id_contract`)))
WHERE (`c`.`was_deleted` = 0);

--
-- Создать представление `v_contract_side12_warrants`
--
CREATE
VIEW v_contract_side12_warrants
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  GROUP_CONCAT(`vwa1`.`warrant_apartment_txt` SEPARATOR ', ') AS `side12_warrants`
FROM ((`contracts` `c`
  LEFT JOIN `apartments` `a12`
    ON ((`c`.`id_apartment_side12` = `a12`.`id_apartment`)))
  LEFT JOIN `v_warrant_apartment_side12` `vwa1`
    ON ((`vwa1`.`id_apartment` = `a12`.`id_apartment`)))
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_contract_side1_warrants`
--
CREATE
VIEW v_contract_side1_warrants
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  GROUP_CONCAT(`vwa1`.`warrant_apartment_txt` SEPARATOR ', ') AS `side1_warrants`
FROM ((`contracts` `c`
  LEFT JOIN `apartments` `a1`
    ON ((`c`.`id_apartment_side1` = `a1`.`id_apartment`)))
  LEFT JOIN `v_warrant_apartment_side1` `vwa1`
    ON ((`vwa1`.`id_apartment` = `a1`.`id_apartment`)))
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_report`
--
CREATE
VIEW v_report
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  `kladr`.`get_street_name_for_kladr`(`a2`.`id_street`) AS `street_side2`,
  `a2`.`house` AS `house2`,
  `a2`.`flat` AS `flat2`,
  `a2`.`total_area` AS `total_area2`,
  `a1`.`total_area` AS `total_area`,
  `kladr`.`get_street_name_for_kladr`(`a1`.`id_street`) AS `street_side1`,
  `a1`.`house` AS `house1`,
  `a1`.`flat` AS `flat1`
FROM ((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`apartments` `a1`
    ON ((`a1`.`id_apartment` = `c`.`id_apartment_side1`)))
  LEFT JOIN `mena`.`apartments` `a2`
    ON ((`a2`.`id_apartment` = `c`.`id_apartment_side2`)))
  LEFT JOIN `mena`.`v_contract_side1_warrants` `vcs1w`
    ON ((`vcs1w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side2_warrants` `vcs2w`
    ON ((`vcs2w`.`id_contract` = `c`.`id_contract`)))
ORDER BY `c`.`id_contract`;

--
-- Создать представление `v_contract_dksr_side1_warrant`
--
CREATE
VIEW v_contract_dksr_side1_warrant
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  GROUP_CONCAT(`vwa1`.`warrant_apartment_txt` SEPARATOR ', ') AS `side1_warrants`
FROM ((`contracts` `c`
  LEFT JOIN `apartments` `a1`
    ON ((`c`.`id_apartment_side1` = `a1`.`id_apartment`)))
  LEFT JOIN `v_warrant_apartment_side1` `vwa1`
    ON ((`vwa1`.`id_apartment` = `a1`.`id_apartment`)))
WHERE (`vwa1`.`id_warrant_template` = 284)
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_apart_name`
--
CREATE
VIEW v_apart_name
AS
SELECT
  `a`.`id_apartment` AS `id_apartment`,
  `a`.`id_street` AS `id_street`,
  `kladr`.`get_street_name_for_kladr_without_socr`(`a`.`id_street`) AS `street_name`,
  `a`.`house` AS `house`,
  `a`.`flat` AS `flat`
FROM `mena`.`apartments` `a`
ORDER BY `a`.`id_apartment`;

--
-- Создать таблицу `sp_delegate`
--
CREATE TABLE IF NOT EXISTS sp_delegate (
  id_delegate tinyint(4) NOT NULL AUTO_INCREMENT,
  fio varchar(100) NOT NULL,
  birth datetime NOT NULL,
  passport_seria varchar(10) NOT NULL,
  passport_num varchar(10) NOT NULL,
  passport_issued varchar(255) NOT NULL,
  passport_isssued_date datetime NOT NULL,
  id_template smallint(6) NOT NULL,
  PRIMARY KEY (id_delegate)
)
ENGINE = INNODB,
AUTO_INCREMENT = 11,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Справочник представителей комитета';

--
-- Создать представление `v_contract_delegate_warrant`
--
CREATE
VIEW v_contract_delegate_warrant
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  `template`(`sd`.`id_template`, `sd`.`id_delegate`) AS `delegate_warrant`
FROM (`contracts` `c`
  LEFT JOIN `sp_delegate` `sd`
    ON ((`c`.`id_delegate` = `sd`.`id_delegate`)));

--
-- Создать таблицу `persons`
--
CREATE TABLE IF NOT EXISTS persons (
  id_person int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_apartment int(11) UNSIGNED DEFAULT NULL,
  id_person_status smallint(6) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'заявитель',
  id_contractor tinyint(4) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'участник договора',
  portion varchar(5) NOT NULL DEFAULT '1' COMMENT 'доля в собственности',
  family varchar(50) NOT NULL,
  name varchar(50) NOT NULL,
  father varchar(50) DEFAULT NULL,
  sex tinyint(1) DEFAULT NULL,
  birth datetime DEFAULT NULL,
  born_place varchar(255) DEFAULT NULL,
  id_document smallint(6) UNSIGNED NOT NULL DEFAULT 255,
  document_seria varchar(8) DEFAULT NULL,
  document_number varchar(8) DEFAULT NULL,
  document_issued varchar(255) DEFAULT NULL COMMENT 'кем выдан',
  id_document_issued int(10) UNSIGNED DEFAULT NULL COMMENT 'код органа выдавшего документ',
  document_issuer_code varchar(7) DEFAULT NULL,
  document_date date DEFAULT NULL COMMENT 'когда выдан ',
  id_registration_street varchar(17) DEFAULT NULL,
  registration_house varchar(5) DEFAULT NULL COMMENT 'улица регистрации',
  regiostration_flat varchar(10) DEFAULT NULL COMMENT 'кв регистрации',
  registration_index varchar(6) DEFAULT NULL COMMENT 'индекс регистрации',
  registration_room varchar(5) DEFAULT NULL,
  snils varchar(14) DEFAULT NULL,
  phone varchar(255) DEFAULT NULL COMMENT 'телефон',
  id_template int(11) UNSIGNED DEFAULT NULL,
  last_change_user varchar(250) NOT NULL DEFAULT 'bad user',
  last_change_date datetime NOT NULL DEFAULT '1986-11-15 00:00:00',
  was_deleted tinyint(1) DEFAULT 0,
  PRIMARY KEY (id_person)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5218,
AVG_ROW_LENGTH = 367,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать триггер `persons_log_ins`
--
CREATE TRIGGER persons_log_ins
BEFORE INSERT
ON persons
FOR EACH ROW
BEGIN
  SET new.last_change_date = NOW();
  SET new.last_change_user = USER();
END
$$

--
-- Создать триггер `persons_log_upd`
--
CREATE TRIGGER persons_log_upd
BEFORE UPDATE
ON persons
FOR EACH ROW
BEGIN
  SET new.last_change_date = NOW();
  SET new.last_change_user = USER();
END
$$

--
-- Создать функцию `get_part_in_decimal`
--
CREATE FUNCTION get_part_in_decimal (par_id_person int)
RETURNS decimal(10, 8)
BEGIN
  DECLARE res decimal(10, 8);
  SET res = (SELECT
      IF(x.Multiplier = 0, X.Divider, CONVERT(x.Multiplier / x.Divider, decimal(10, 8))) AS Result
    FROM (SELECT
        CAST(SUBSTR(t.portion, 1, LOCATE('/', t.portion) - 1) AS decimal) AS Multiplier,
        CAST(SUBSTR(t.portion, LOCATE('/', t.portion) + 1, LOCATE(' ', CONCAT(t.portion, ' '))) AS decimal) AS Divider
      FROM persons t
      WHERE t.id_person = par_id_person) x);
  RETURN res;
END
$$

DELIMITER ;

--
-- Создать представление `v_reason_address`
--
CREATE
VIEW v_reason_address
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  CONCAT(`kladr`.`get_street_for_kladr`(`a`.`id_street`), IFNULL(CONCAT(', д.', `a`.`house`), ''), IFNULL(CONCAT(', кв.', `a`.`flat`), '')) AS `s1`,
  CONCAT(`kladr`.`get_street_for_kladr`(`a12`.`id_street`), IFNULL(CONCAT(', д.', `a12`.`house`), ''), IFNULL(CONCAT(', кв.', `a12`.`flat`), '')) AS `s12`,
  CONCAT(`kladr`.`get_street_for_kladr`(`a2`.`id_street`), IFNULL(CONCAT(', д.', `a2`.`house`), ''), IFNULL(CONCAT(', кв.', `a2`.`flat`), '')) AS `s2`,
  GROUP_CONCAT(CONCAT(IFNULL(`p`.`family`, ''), IFNULL(CONCAT(' ', `p`.`name`), ''), IFNULL(CONCAT(' ', `p`.`father`), '')) SEPARATOR ',') AS `persons`,
  `a`.`id_street` AS `id_street`,
  `a`.`house` AS `house`,
  `a`.`flat` AS `flat`,
  `a`.`id_apartment` AS `id_apartment`
FROM ((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`apartments` `a`
    ON ((`c`.`id_apartment_side1` = `a`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `a2`
    ON ((`c`.`id_apartment_side2` = `a2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `a12`
    ON ((`c`.`id_apartment_side12` = `a12`.`id_apartment`)))
  LEFT JOIN `mena`.`persons` `p`
    ON (((`p`.`id_apartment` = `a2`.`id_apartment`)
    AND (`p`.`was_deleted` = 0))))
WHERE (`c`.`was_deleted` = 0)
GROUP BY `c`.`id_contract`
ORDER BY `c`.`id_contract`;

--
-- Создать представление `v_portion_count_by_id_contract`
--
CREATE
VIEW v_portion_count_by_id_contract
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  COUNT(0) AS `Count`
FROM ((`contracts` `c`
  LEFT JOIN `apartments` `a`
    ON ((`c`.`id_apartment_side2` = `a`.`id_apartment`)))
  LEFT JOIN `persons` `p`
    ON ((`a`.`id_apartment` = `p`.`id_apartment`)))
WHERE ((TRIM(`p`.`portion`) <> '1')
AND (`c`.`was_deleted` = 0)
AND (`p`.`was_deleted` = 0))
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_persons_contract_count`
--
CREATE
VIEW v_persons_contract_count
AS
SELECT
  `persons`.`id_apartment` AS `id_apartment`,
  COUNT(0) AS `cnt`,
  (COUNT(0) + 3) AS `copies`,
  (COUNT(0) + 4) AS `copies_redemp`
FROM `persons`
WHERE (`persons`.`was_deleted` = 0)
GROUP BY `persons`.`id_apartment`;

--
-- Создать представление `v_persons_contract_sex`
--
CREATE
VIEW v_persons_contract_sex
AS
SELECT
  `pcnt`.`id_apartment` AS `id_apartment`,
  `pcnt`.`cnt` AS `cnt`,
  (CASE WHEN ISNULL(`p`.`id_apartment`) THEN 'именуемые' WHEN (`p`.`sex` = 0) THEN 'именуемая' WHEN (`p`.`sex` = 1) THEN 'именуемый' END) AS `persons_imn`,
  (CASE WHEN ISNULL(`p`.`id_apartment`) THEN 'им' WHEN (`p`.`sex` = 0) THEN 'ей' WHEN (`p`.`sex` = 1) THEN 'ему' END) AS `persons_prt`
FROM (`v_persons_contract_count` `pcnt`
  LEFT JOIN `persons` `p`
    ON (((`p`.`id_apartment` = `pcnt`.`id_apartment`)
    AND (`pcnt`.`cnt` = 1)
    AND (`p`.`was_deleted` = 0))));

--
-- Создать представление `v_apartment_residents`
--
CREATE
VIEW v_apartment_residents
AS
SELECT
  `a`.`id_apartment` AS `id_apartment`,
  GROUP_CONCAT(CONCAT_WS(' ', CONCAT_WS(' ', `p`.`family`, `p`.`name`), `p`.`father`) SEPARATOR ', ') AS `apartment_residents`
FROM ((`persons` `p`
  JOIN `apartments` `a`
    ON (((`p`.`id_registration_street` = `a`.`id_street`)
    AND (UCASE(TRIM(`p`.`registration_house`)) = UCASE(TRIM(`a`.`house`)))
    AND (UCASE(TRIM(`p`.`regiostration_flat`)) = UCASE(TRIM(`a`.`flat`))))))
  JOIN `contracts` `c`
    ON ((`c`.`id_apartment_side1` = `a`.`id_apartment`)));

--
-- Создать представление `v_address_search_2`
--
CREATE
VIEW v_address_search_2
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  `kladr`.`get_street_for_kladr`(`a`.`id_street`) AS `s1`,
  IFNULL(`a`.`house`, '') AS `house1`,
  IFNULL(`a`.`flat`, '') AS `flat1`,
  `kladr`.`get_street_for_kladr`(`a1`.`id_street`) AS `s2`,
  IFNULL(`a1`.`house`, '') AS `house2`,
  IFNULL(`a1`.`flat`, '') AS `flat2`,
  CONCAT(`kladr`.`get_street_for_kladr`(`a`.`id_street`), IFNULL(CONCAT(', д.', `a`.`house`), ''), IFNULL(CONCAT(', кв.', `a`.`flat`), '')) AS `street1`,
  CONCAT(`kladr`.`get_street_for_kladr`(`a1`.`id_street`), IFNULL(CONCAT(', д.', `a1`.`house`), ''), IFNULL(CONCAT(', кв.', `a1`.`flat`), '')) AS `street2`,
  GROUP_CONCAT(CONCAT(IFNULL(`p`.`family`, ''), IFNULL(CONCAT(' ', `p`.`name`), ''), IFNULL(CONCAT(' ', `p`.`father`), '')) SEPARATOR ',') AS `persons`,
  `c`.`contract_Registration_date` AS `reg_date`
FROM (((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`apartments` `a`
    ON ((`c`.`id_apartment_side1` = `a`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `a1`
    ON ((`c`.`id_apartment_side2` = `a1`.`id_apartment`)))
  LEFT JOIN `mena`.`persons` `p`
    ON (((`p`.`id_apartment` = `a1`.`id_apartment`)
    AND (`p`.`was_deleted` = 0))))
WHERE (`c`.`was_deleted` = 0)
GROUP BY `c`.`id_contract`
ORDER BY IF(((`s1` = '') OR ISNULL(`s1`)), 1, 0), `s1`, `house1`, `flat1`;

--
-- Создать представление `v_address_search`
--
CREATE
VIEW v_address_search
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  CONCAT(`kladr`.`get_street_for_kladr`(`a`.`id_street`), IFNULL(CONCAT(', д.', `a`.`house`), ''), IFNULL(CONCAT(', кв.', `a`.`flat`), '')) AS `s1`,
  CONCAT(`kladr`.`get_street_for_kladr`(`a12`.`id_street`), IFNULL(CONCAT(', д.', `a12`.`house`), ''), IFNULL(CONCAT(', кв.', `a12`.`flat`), '')) AS `s12`,
  CONCAT(`kladr`.`get_street_for_kladr`(`a1`.`id_street`), IFNULL(CONCAT(', д.', `a1`.`house`), ''), IFNULL(CONCAT(', кв.', `a1`.`flat`), '')) AS `s2`,
  GROUP_CONCAT(CONCAT(IFNULL(`p`.`family`, ''), IFNULL(CONCAT(' ', `p`.`name`), ''), IFNULL(CONCAT(' ', `p`.`father`), '')) SEPARATOR ',') AS `persons`
FROM ((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`apartments` `a`
    ON ((`c`.`id_apartment_side1` = `a`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `a1`
    ON ((`c`.`id_apartment_side2` = `a1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `a12`
    ON ((`c`.`id_apartment_side12` = `a12`.`id_apartment`)))
  LEFT JOIN `mena`.`persons` `p`
    ON (((`p`.`id_apartment` = `a1`.`id_apartment`)
    AND (`p`.`was_deleted` = 0))))
WHERE (`c`.`was_deleted` = 0)
GROUP BY `c`.`id_contract`
ORDER BY `c`.`id_contract`;

--
-- Создать таблицу `red_organization`
--
CREATE TABLE IF NOT EXISTS red_organization (
  id_organization int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  name varchar(500) DEFAULT NULL,
  PRIMARY KEY (id_organization)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `red_evaluation`
--
CREATE TABLE IF NOT EXISTS red_evaluation (
  id_rEvaluation int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_apartment int(11) UNSIGNED DEFAULT NULL,
  id_org int(11) UNSIGNED DEFAULT NULL,
  rEvaluation_price varchar(50) DEFAULT NULL COMMENT 'c этой ценой ничего не происходит, потому, думаю, можно извращнуться',
  was_deleted tinyint(1) DEFAULT 0,
  PRIMARY KEY (id_rEvaluation)
)
ENGINE = INNODB,
AUTO_INCREMENT = 408,
AVG_ROW_LENGTH = 150,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать представление `v_redevaluation`
--
CREATE
VIEW v_redevaluation
AS
SELECT
  `re`.`id_rEvaluation` AS `id_rEvaluation`,
  `re`.`id_apartment` AS `id_apartment`,
  CONCAT('- ', `ro`.`name`, IF((`re`.`id_org` = 4), ' $sbr$', ' ')) AS `con_roname`,
  IFNULL(`re`.`rEvaluation_price`, '') AS `con_rEval`,
  `ro`.`name` AS `ro_name`,
  `re`.`rEvaluation_price` AS `re_price`
FROM (`red_evaluation` `re`
  LEFT JOIN `red_organization` `ro`
    ON ((`re`.`id_org` = `ro`.`id_organization`)))
WHERE (`re`.`was_deleted` = 0)
ORDER BY `re`.`id_rEvaluation`;

--
-- Создать таблицу `sp_document_issued`
--
CREATE TABLE IF NOT EXISTS sp_document_issued (
  id_document_issued int(11) NOT NULL AUTO_INCREMENT,
  document_issued varchar(255) NOT NULL COMMENT 'Кем выдан',
  PRIMARY KEY (id_document_issued)
)
ENGINE = INNODB,
AUTO_INCREMENT = 344,
AVG_ROW_LENGTH = 224,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `sp_document`
--
CREATE TABLE IF NOT EXISTS sp_document (
  id_document smallint(6) NOT NULL AUTO_INCREMENT,
  document varchar(50) NOT NULL DEFAULT '' COMMENT 'наименование документа',
  PRIMARY KEY (id_document)
)
ENGINE = INNODB,
AUTO_INCREMENT = 256,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать представление `v_persons_agreement`
--
CREATE
VIEW v_persons_agreement
AS
SELECT
  `p`.`id_apartment` AS `id_apartment`,
  `p`.`id_person` AS `id_person`,
  CONCAT_WS(' ', CONCAT_WS(' ', `p`.`family`, `p`.`name`), `p`.`father`) AS `snp`,
  CONCAT(DATE_FORMAT(`p`.`birth`, '%d.%m.%Y'), ' года рождения') AS `born_date`,
  CONCAT(CONCAT(CONCAT(CONCAT(LCASE(`sd`.`document`), ' серии ', `p`.`document_seria`), ' № ', `p`.`document_number`), ', выданный ', IFNULL(`de`.`document_issued`, '')), ',дата выдачи ', DATE_FORMAT(`p`.`document_date`, '%d.%m.%Y')) AS `document_info`,
  CONCAT(CONCAT(CONCAT('место регистрации ', `kladr`.`get_full_street_for_kladr`(`p`.`id_registration_street`)), ', дом ', `p`.`registration_house`), ', квартира ', `p`.`regiostration_flat`, IFNULL(CONCAT(', комната ', `p`.`registration_room`), '')) AS `reg_address`,
  `template`(`p`.`id_template`, `p`.`id_person`) AS `warrant`,
  `get_template_var`(`p`.`id_template`, `p`.`id_person`, '@fio@') AS `warrant_fio`
FROM ((`mena`.`persons` `p`
  LEFT JOIN `mena`.`sp_document` `sd`
    ON ((`p`.`id_document` = `sd`.`id_document`)))
  LEFT JOIN `mena`.`sp_document_issued` `de`
    ON ((`p`.`id_document_issued` = `de`.`id_document_issued`)))
WHERE ((`p`.`id_contractor` = 1)
AND (`p`.`was_deleted` = 0));

--
-- Создать представление `v_persons`
--
CREATE
VIEW v_persons
AS
SELECT
  `p`.`id_apartment` AS `id_apartment`,
  `p`.`id_person` AS `id_person`,
  CONCAT_WS(' ', CONCAT_WS(' ', `p`.`family`, `p`.`name`), IFNULL(`p`.`father`, '')) AS `snp`,
  CONCAT(DATE_FORMAT(`p`.`birth`, '%d.%m.%Y'), ' года рождения') AS `born_date`,
  IF((ISNULL(`p`.`born_place`) OR (TRIM(`p`.`born_place`) = '')), NULL, CONCAT('место рождения ', `p`.`born_place`)) AS `born_place`,
  CONCAT(CONCAT(CONCAT(CONCAT(LCASE(`sd`.`document`), ' серии ', `p`.`document_seria`), ' № ', `p`.`document_number`), ' выдан ', DATE_FORMAT(`p`.`document_date`, '%d.%m.%Y')), ' ', IFNULL(`de`.`document_issued`, '')) AS `document_info`,
  CONCAT(CONCAT(CONCAT('место регистрации: ', `kladr`.`get_full_street_for_kladr`(`p`.`id_registration_street`)), ', дом ', `p`.`registration_house`), ', квартира ', `p`.`regiostration_flat`, IFNULL(CONCAT(', комната ', `p`.`registration_room`), '')) AS `reg_address`,
  CONCAT(CONCAT(CONCAT('', `kladr`.`get_street_name_for_kladr`(`p`.`id_registration_street`)), ', д. ', `p`.`registration_house`), ', кв. ', `p`.`regiostration_flat`, IFNULL(CONCAT(', ком. ', `p`.`registration_room`), '')) AS `reg_address_short`,
  `template`(`p`.`id_template`, `p`.`id_person`) AS `warrant`,
  `get_template_fio`(`p`.`id_template`, `p`.`id_person`, '@fio@') AS `warrant_fio`,
  CONCAT(SUBSTR(`swt`.`warrant_template`, 1, (LOCATE('@', `swt`.`warrant_template`) - 1)), `get_template_fio`(`p`.`id_template`, `p`.`id_person`, '@fio@')) AS `warrant_short`,
  (CASE WHEN (`p`.`sex` = 0) THEN 'Гражданка Российской Федерации' WHEN (`p`.`sex` = 1) THEN 'Гражданин Российской Федерации' END) AS `citizen`,
  (CASE WHEN (`p`.`sex` = 0) THEN 'гражданка Российской Федерации' WHEN (`p`.`sex` = 1) THEN 'гражданин Российской Федерации' END) AS `citizen_pre`
FROM (((`mena`.`persons` `p`
  LEFT JOIN `mena`.`sp_document` `sd`
    ON ((`p`.`id_document` = `sd`.`id_document`)))
  LEFT JOIN `mena`.`sp_document_issued` `de`
    ON ((`p`.`id_document_issued` = `de`.`id_document_issued`)))
  LEFT JOIN `mena`.`sp_warrant_template` `swt`
    ON ((`p`.`id_template` = `swt`.`id_warrant_template`)))
WHERE ((`p`.`id_contractor` = 1)
AND (`p`.`was_deleted` = 0));

--
-- Создать представление `v_contract_participants_info`
--
CREATE
VIEW v_contract_participants_info
AS
SELECT
  `vp`.`id_apartment` AS `id_apartment`,
  `vp`.`id_person` AS `id_person`,
  CONCAT(CONCAT(CONCAT('$b$$i$гр. РФ$/i$ ', `vp`.`snp`, '$/b$'), IF(ISNULL(`vp`.`born_date`), '', CONCAT(', ', `vp`.`born_date`)), IF(ISNULL(`vp`.`born_place`), '', CONCAT(', ', `vp`.`born_place`))), IF(ISNULL(`vp`.`document_info`), '', CONCAT(', ', `vp`.`document_info`)), IF(ISNULL(`vp`.`warrant`), '', CONCAT(', ', `vp`.`warrant`))) AS `person`,
  CONCAT(CONCAT(CONCAT('гр. Российской Федерации ', `vp`.`snp`), IF(ISNULL(`vp`.`born_date`), '', CONCAT(', ', `vp`.`born_date`)), IF(ISNULL(`vp`.`born_place`), '', CONCAT(', ', `vp`.`born_place`))), IF(ISNULL(`vp`.`document_info`), '', CONCAT(', ', `vp`.`document_info`))) AS `person_dksr`,
  CONCAT('$b$', `vp`.`snp`, '$/b$', IF(ISNULL(`vp`.`warrant`), '', CONCAT(',$br$', `vp`.`warrant`))) AS `snp`,
  `vp`.`snp` AS `snp_request`,
  IF(ISNULL(`vp`.`warrant`), '', `vp`.`warrant`) AS `warrant`,
  `vp`.`reg_address` AS `reg_address`,
  `vp`.`citizen` AS `citizen`,
  CONCAT(CONCAT(CONCAT('$b$', `vp`.`citizen_pre`, '$/b$ ', `vp`.`snp`), IF(ISNULL(`vp`.`born_date`), '', CONCAT(', ', `vp`.`born_date`)), IF(ISNULL(`vp`.`born_place`), '', CONCAT(', ', `vp`.`born_place`))), IF(ISNULL(`vp`.`document_info`), '', CONCAT(', ', `vp`.`document_info`)), IF(ISNULL(`vp`.`reg_address`), '', CONCAT(', ', `vp`.`reg_address`)), IF(ISNULL(`vp`.`warrant`), '', CONCAT(', ', `vp`.`warrant`))) AS `pre_person`,
  CONCAT('проживает и состоит на регистрационном учёте ', CONCAT(`vp`.`citizen_pre`, ' ', `vp`.`snp`)) AS `reg_person`
FROM `mena`.`v_persons` `vp`;

--
-- Создать представление `v_contract_part_info`
--
CREATE
VIEW v_contract_part_info
AS
SELECT
  `vp`.`id_apartment` AS `id_apartment`,
  `vp`.`id_person` AS `id_person`,
  `vp`.`snp` AS `snp`,
  `vp`.`reg_address_short` AS `reg_address_short`,
  CONCAT(CONCAT(`vp`.`snp`, IF(ISNULL(`vp`.`born_date`), '', CONCAT(', ', `vp`.`born_date`))), IF(ISNULL(`vp`.`document_info`), '', CONCAT(', ', `vp`.`document_info`)), IF(ISNULL(`vp`.`reg_address`), '', CONCAT(', ', `vp`.`reg_address`))) AS `person`
FROM `mena`.`v_persons` `vp`;

--
-- Создать представление `v_agreement`
--
CREATE
VIEW v_agreement
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  GROUP_CONCAT(CONCAT(CONCAT(`p`.`family`, ' ', `p`.`name`), ' ', `p`.`father`) SEPARATOR ', ') AS `persons_fio`,
  CONCAT(CONCAT(IFNULL(`kladr`.`get_street_name_for_kladr`(`p`.`id_registration_street`), ''), IFNULL(CONCAT(', дом ', `p`.`registration_house`), '')), IFNULL(CONCAT(', квартира ', `p`.`regiostration_flat`), ''), IFNULL(CONCAT(', комната ', `p`.`registration_room`), '')) AS `reg_address`,
  DATE_FORMAT(`p`.`birth`, '%d.%m.%Y') AS `dofb`,
  CONCAT('серия ', `p`.`document_seria`, ' № ', `p`.`document_number`) AS `passport`,
  `p`.`document_issued` AS `issued`,
  `p`.`document_date` AS `doc_date`,
  GROUP_CONCAT(`vcpi`.`person` SEPARATOR '; ') AS `persons`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`as2`.`id_street`), ', дом ', `as2`.`house`), IFNULL(CONCAT(', квартира ', `as2`.`flat`), ''), IF((`as2`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as2`.`room`), ''))) AS `side2_address`
FROM ((((`mena`.`persons` `p`
  LEFT JOIN `mena`.`apartments` `as1`
    ON ((`p`.`id_apartment` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`contracts` `c`
    ON ((`c`.`id_apartment_side2` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as2`
    ON ((`c`.`id_apartment_side2` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`v_contract_part_info` `vcpi`
    ON ((`vcpi`.`id_apartment` = `as2`.`id_apartment`)))
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_agreement_participants_info`
--
CREATE
VIEW v_agreement_participants_info
AS
SELECT
  `vp`.`id_apartment` AS `id_apartment`,
  `vp`.`id_person` AS `id_person`,
  CONCAT(CONCAT(CONCAT('гр. РФ $b$', `vp`.`snp`, '$/b$'), IF(ISNULL(`vp`.`document_info`), '', CONCAT(', ', `vp`.`document_info`)), IF(ISNULL(`vp`.`reg_address`), '', CONCAT(', ', `vp`.`reg_address`))), IF(ISNULL(`vp`.`warrant`), '', CONCAT(', ', `vp`.`warrant`, ','))) AS `person`
FROM `mena`.`v_persons` `vp`;

--
-- Создать таблицу `info_f`
--
CREATE TABLE IF NOT EXISTS info_f (
  `№ п/п` varchar(255) DEFAULT NULL,
  street2 varchar(255) DEFAULT NULL,
  house2 varchar(255) DEFAULT NULL,
  flat2 varchar(255) DEFAULT NULL,
  total2 varchar(10) DEFAULT NULL,
  countP varchar(255) DEFAULT NULL,
  FIO varchar(255) DEFAULT NULL,
  totS varchar(255) DEFAULT NULL,
  totS2 varchar(10) DEFAULT NULL,
  street1 varchar(255) DEFAULT NULL,
  house1 varchar(255) DEFAULT NULL,
  flat1 varchar(255) DEFAULT NULL,
  predost varchar(255) DEFAULT NULL,
  osnov varchar(255) DEFAULT NULL,
  contract varchar(255) DEFAULT NULL,
  limited varchar(255) DEFAULT NULL,
  request varchar(20) DEFAULT NULL,
  readyDate varchar(20) DEFAULT NULL,
  notifyDate varchar(20) DEFAULT NULL,
  Info varchar(255) DEFAULT NULL,
  warrants varchar(1500) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 400,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `info_temp`
--
CREATE TABLE IF NOT EXISTS info_temp (
  street2 varchar(255) DEFAULT NULL,
  house2 varchar(255) DEFAULT NULL,
  flat2 varchar(255) DEFAULT NULL,
  totalS2 varchar(10) DEFAULT NULL,
  countP varchar(255) DEFAULT NULL,
  FIO varchar(255) DEFAULT NULL,
  totalS1 varchar(10) DEFAULT NULL,
  street1 varchar(255) DEFAULT NULL,
  house1 varchar(255) DEFAULT NULL,
  flat1 varchar(255) DEFAULT NULL,
  predost varchar(255) DEFAULT NULL,
  osnov varchar(255) DEFAULT NULL,
  contract varchar(255) DEFAULT NULL,
  limited varchar(255) DEFAULT NULL,
  request varchar(20) DEFAULT NULL,
  readyDate varchar(20) DEFAULT NULL,
  notifyDate varchar(20) DEFAULT NULL,
  Info varchar(255) DEFAULT NULL,
  warrants varchar(1500) DEFAULT NULL,
  id_info int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (id_info)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1466,
AVG_ROW_LENGTH = 400,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `info`
--
CREATE TABLE IF NOT EXISTS info (
  `№ п/п` int(11) DEFAULT NULL,
  `Месторасположения: г. Братск, улица` varchar(255) DEFAULT NULL,
  `№ жилого дома (жд)` varchar(255) DEFAULT NULL,
  `№ жилого помещения (жп)` varchar(255) DEFAULT NULL,
  `Год ввода в
эксплуатацию` int(11) DEFAULT NULL,
  `Тип здания
(деревянное, щитовое)` varchar(255) DEFAULT NULL,
  `Занимаемая Sобщ.жп,м2` double(10, 3) DEFAULT NULL,
  `К-во чел, проживающих в ЖП` int(11) DEFAULT NULL,
  `Ф.И.О.` varchar(255) DEFAULT NULL,
  `Тех.состояние
(аварийное), А` varchar(255) DEFAULT NULL,
  `Предоставляемая Sобщ,м2` double(10, 3) DEFAULT NULL,
  `Предполагаемый 
адрес переселения: г. Братск, улица` varchar(255) DEFAULT NULL,
  `№жд` varchar(255) DEFAULT NULL,
  `№жп` int(11) DEFAULT NULL,
  `№ постановления о мене` varchar(255) DEFAULT NULL,
  `Дата договора мены` varchar(255) DEFAULT NULL,
  `Дата постановления о мене` varchar(255) DEFAULT NULL,
  `Дата подачи заявления на мену (найм)` varchar(255) DEFAULT NULL,
  id_contract int(11) DEFAULT NULL,
  id_predost tinyint(3) UNSIGNED NOT NULL,
  `Основание проживания (регистрация в Росреестре, № от ДСН)` int(11) DEFAULT NULL,
  `Дата совершения сделки по столбцу 12` date DEFAULT NULL,
  `Договор о порядке и условиях переселения (основание для прож` varchar(255) DEFAULT NULL,
  `Дата  рег/договора по столбцу 14` date DEFAULT NULL,
  `копии переданы в КГС (договор+акт)` int(11) DEFAULT NULL,
  `Ограничение на сделки (по столбцу 12)` varchar(255) DEFAULT NULL,
  `Примечание 1` varchar(2000) DEFAULT NULL,
  `Инфо по направленным уведомлениям` datetime DEFAULT NULL,
  `Телефоны граждан` varchar(500) DEFAULT NULL,
  `Информация по снятию с регистрации по старому адресу` varchar(500) DEFAULT NULL,
  `Дата заявки на оценку МЖП для мены` date DEFAULT NULL,
  `Информация по оценке` varchar(255) DEFAULT NULL,
  `Дата изготовления ОК оценки МЖП` date DEFAULT NULL,
  `Дата заселения в новостройку` date DEFAULT NULL,
  id_street varchar(17) DEFAULT NULL,
  id_apart int(11) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 315,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать представление `v_info_temp`
--
CREATE
VIEW v_info_temp
AS
SELECT
  `info_temp`.`id_info` AS `id_info`,
  `info_temp`.`street2` AS `street2`,
  `info_temp`.`house2` AS `house2`,
  `info_temp`.`flat2` AS `flat2`,
  `info_temp`.`totalS2` AS `totalS2`,
  `info_temp`.`countP` AS `countP`,
  `info_temp`.`FIO` AS `FIO`,
  `info_temp`.`totalS1` AS `totalS1`,
  `info_temp`.`street1` AS `street1`,
  `info_temp`.`house1` AS `house1`,
  `info_temp`.`flat1` AS `flat1`,
  `info_temp`.`predost` AS `predost`,
  `info_temp`.`osnov` AS `osnov`,
  `info_temp`.`contract` AS `contract`,
  `info_temp`.`limited` AS `limited`,
  `info_temp`.`request` AS `request`,
  `info_temp`.`readyDate` AS `readyDate`,
  `info_temp`.`notifyDate` AS `notifyDate`,
  `info_temp`.`Info` AS `Info`,
  `info_temp`.`warrants` AS `warrants`,
  CONCAT('ул. ', TRIM(`info_temp`.`street2`), ', д. ', TRIM(`info_temp`.`house2`), IFNULL(CONCAT(', кв. ', TRIM(`info_temp`.`flat2`)), '')) AS `s2`,
  CONCAT('ул. ', TRIM(`info_temp`.`street1`), ', д. ', TRIM(`info_temp`.`house1`), IFNULL(CONCAT(', кв. ', TRIM(`info_temp`.`flat1`)), '')) AS `s1`
FROM `info_temp`;

--
-- Создать представление `v_info_f`
--
CREATE
VIEW v_info_f
AS
SELECT
  `inf`.`street2` AS `street2`,
  `inf`.`house2` AS `house2`,
  `inf`.`flat2` AS `flat2`,
  `inf`.`total2` AS `total2`,
  `inf`.`countP` AS `countP`,
  `inf`.`FIO` AS `FIO`,
  `inf`.`totS` AS `totS`,
  `inf`.`totS2` AS `totS2`,
  `inf`.`street1` AS `street1`,
  `inf`.`house1` AS `house1`,
  `inf`.`flat1` AS `flat1`,
  `inf`.`predost` AS `predost`,
  `inf`.`osnov` AS `osnov`,
  `inf`.`contract` AS `contract`,
  `inf`.`limited` AS `limited`,
  `inf`.`request` AS `request`,
  `inf`.`readyDate` AS `readyDate`,
  `inf`.`notifyDate` AS `notifyDate`,
  `inf`.`Info` AS `Info`,
  `inf`.`warrants` AS `warrants`
FROM `info_f` `inf`;

--
-- Создать представление `v_info`
--
CREATE
VIEW v_info
AS
SELECT
  `it`.`street2` AS `street2`,
  `it`.`house2` AS `house2`,
  `it`.`flat2` AS `flat2`,
  `it`.`totalS2` AS `totalS2`,
  `it`.`countP` AS `countP`,
  `it`.`FIO` AS `FIO`,
  `it`.`totalS1` AS `totalS1`,
  `it`.`street1` AS `street1`,
  `it`.`house1` AS `house1`,
  `it`.`flat1` AS `flat1`,
  `it`.`predost` AS `predost`,
  `it`.`osnov` AS `osnov`,
  `it`.`contract` AS `contract`,
  `it`.`limited` AS `limited`,
  `it`.`request` AS `request`,
  `it`.`readyDate` AS `readyDate`,
  `it`.`notifyDate` AS `notifyDate`,
  `it`.`Info` AS `Info`,
  `it`.`id_info` AS `id_info`,
  IFNULL(`vic`.`side2_warrants`, 'документы граждане предоставляют нотариусу при сделке') AS `warrants`
FROM (`mena`.`info_temp` `it`
  JOIN `mena`.`v_info_contracts` `vic`)
WHERE ((`it`.`street1` = `vic`.`street1`)
AND (`it`.`street2` = `vic`.`street2`)
AND (`it`.`house1` = `vic`.`house1`)
AND (`it`.`house2` = `vic`.`house2`)
AND (`it`.`flat1` = `vic`.`flat1`)
AND (`it`.`flat2` = `vic`.`flat2`));

--
-- Создать таблицу `sp_apartment_type`
--
CREATE TABLE IF NOT EXISTS sp_apartment_type (
  id_apartment_type tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT,
  apartment_type varchar(255) NOT NULL,
  apartment_type_rod varchar(255) NOT NULL,
  apartment_type_plur varchar(255) NOT NULL,
  PRIMARY KEY (id_apartment_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Справочник Типов ЖП';

--
-- Создать таблицу `land`
--
CREATE TABLE IF NOT EXISTS land (
  id_land int(11) NOT NULL AUTO_INCREMENT,
  id_apartment int(11) DEFAULT NULL,
  id_street varchar(17) NOT NULL,
  house varchar(5) DEFAULT NULL,
  inventory_number varchar(50) DEFAULT NULL,
  total_area decimal(8, 2) DEFAULT NULL,
  resolution_number varchar(255) DEFAULT NULL,
  resolution_date datetime DEFAULT NULL,
  PRIMARY KEY (id_land)
)
ENGINE = INNODB,
AUTO_INCREMENT = 335,
AVG_ROW_LENGTH = 173,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Земельные участки';

--
-- Создать представление `v_order_info_test`
--
CREATE
VIEW v_order_info_test
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  CONCAT(CONCAT(IF((`l`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`l`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`l`.`id_street`)), ', ', `l`.`house`)) AS `land_adress`,
  IF(ISNULL(`a1`.`flat`), 'жилого помещения', 'жилого помещения') AS `place1`,
  IF(ISNULL(`a2`.`flat`), 'жилое помещение', 'жилое помещение') AS `place2`,
  DATE_FORMAT(`c`.`order_date`, '%d.%m.%Y') AS `order_date`,
  `c`.`order_number` AS `order_number`,
  DATE_FORMAT(`c`.`agreement_registration_date`, '%d.%m.%Y') AS `agreement_registration_date`,
  CONCAT(CONCAT(IF((`a1`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a1`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a1`.`id_street`)), ', дом ', `a1`.`house`), IF((IFNULL(`a1`.`flat`, '') = ''), '', CONCAT(', квартира ', `a1`.`flat`)), IF((`a1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `a1`.`room`), ''))) AS `side1_address`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), CONCAT(CONCAT(' и жилого помещения, расположенного по адресу: ', IF((`a12`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a12`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a12`.`id_street`)), ', дом ', `a12`.`house`), IF((IFNULL(`a12`.`flat`, '') = ''), '', CONCAT(', квартира ', `a12`.`flat`)), IF((`a12`.`room` = 0), '', IFNULL(CONCAT(', комната ', `a12`.`room`), ''))), ',') AS `side12_address`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), CONCAT(CONCAT(' а) Российская Федерация, ', IF((`a1`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a1`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a1`.`id_street`)), ', дом ', `a1`.`house`), IF((IFNULL(`a1`.`flat`, '') = ''), '', CONCAT(', квартира ', `a1`.`flat`)), IF((`a1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `a1`.`room`), '')), ';$br$'), CONCAT(CONCAT('Российская Федерация, ', IF((`a1`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a1`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a1`.`id_street`)), ', дом ', `a1`.`house`), IF((IFNULL(`a1`.`flat`, '') = ''), '', CONCAT(', квартира ', `a1`.`flat`)), IF((`a1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `a1`.`room`), '')), '')) AS `side1_address2`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), CONCAT(CONCAT(' б) Российская Федерация, ', IF((`a12`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a12`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a12`.`id_street`)), ', дом ', `a12`.`house`), IF((IFNULL(`a12`.`flat`, '') = ''), '', CONCAT(', квартира ', `a12`.`flat`)), IF((`a12`.`room` = 0), '', IFNULL(CONCAT(', комната ', `a12`.`room`), '')), ';'), ', из реестра муниципального имущества города Братска;') AS `side12_address2`,
  CONCAT(CONCAT(IF((`a2`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a2`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a2`.`id_street`)), ', дом ', `a2`.`house`), IF((IFNULL(`a2`.`flat`, '') = ''), '', CONCAT(', квартира ', `a2`.`flat`)), IF((`a2`.`room` = 0), '', IFNULL(CONCAT(', комната ', `a2`.`room`), ''))) AS `side2_address`,
  `a1`.`inventory_number` AS `side1_inventory_number`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), CONCAT(' (кадастровый номер', `a12`.`inventory_number`, ')'), '') AS `side12_inventory_number`,
  `a2`.`inventory_number` AS `side2_inventory_number`,
  `a1`.`total_area` AS `side1_total_area_num`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), CONCAT(', общей площадью ', `a12`.`total_area`), '') AS `side12_total_area_num`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), ' ($side12_total_area_string$) кв. м', '') AS `side12_total_area`,
  `a2`.`total_area` AS `side2_total_area_num`,
  IFNULL(`a1`.`total_area`, 0) AS `side1_total_area_string`,
  IFNULL(`a12`.`total_area`, 0) AS `side12_total_area_string`,
  IFNULL(`a2`.`total_area`, 0) AS `side2_total_area_string`,
  IF((IFNULL(`a1`.`living_area`, 0) > 0), ', жилой площадью $side1_living_area_num$ ($side1_living_area_string$) кв. м', '') AS `side1_living_area`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), IF((IFNULL(`a12`.`living_area`, 0) > 0), ', жилой площадью $side12_living_area_num$ ($side12_living_area_string$) кв. м', ''), '') AS `side12_living_area`,
  IF((IFNULL(`a2`.`living_area`, 0) > 0), ', жилой площадью $side2_living_area_num$ ($side2_living_area_string$) кв. м', '') AS `side2_living_area`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`a1`.`living_area`, '.', ','))) AS `side1_living_area_num`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`a12`.`living_area`, '.', ','))), '') AS `side12_living_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`a2`.`living_area`, '.', ','))) AS `side2_living_area_num`,
  IFNULL(`a1`.`living_area`, 0) AS `side1_living_area_string`,
  IFNULL(`a12`.`living_area`, 0) AS `side12_living_area_string`,
  IFNULL(`a2`.`living_area`, 0) AS `side2_living_area_string`,
  IF((IFNULL(`a1`.`room_count`, 0) > 0), ', состоящего из $side1_room_count$ $room_count1$', '') AS `side1_room_counts`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), '', ', принадлежащего на праве собственности муниципальному образованию города Братска') AS `pref_side1`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), CONCAT(IF((IFNULL(`a12`.`room_count`, 0) > 0), ', состоящего из $side12_room_count$ $room_count1$', ''), ', принадлежащих на праве собственности муниципальному образованию города Братска,'), '') AS `side12_room_counts`,
  IF((IFNULL(`a2`.`room_count`, 0) > 0), ', состоящее из $side2_room_count$ $room_count2$', '') AS `side2_room_counts`,
  IFNULL(`a1`.`room_count`, 0) AS `side1_room_count`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), IFNULL(`a12`.`room_count`, 0), '') AS `side12_room_count`,
  IFNULL(`a2`.`room_count`, 0) AS `side2_room_count`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), 'исключить из реестра муниципального имущества города Братска жилые помещения, расположенные по следующим адресам:$br$', 'исключить жилое помещение, расположенное по адресу:') AS `point4`,
  IF(ISNULL(`l`.`id_land`), 'принадлежащее', 'принадлежащие') AS `owner_plural`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельный участок, расположенный по адресу: Российская Федерация, $land_adress$') AS `land`,
  IF(ISNULL(`l`.`id_land`), 'принадлежащее', 'принадлежащих') AS `tmpl_owner_plural`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельного участка, расположенного по адресу: Российская Федерация, $land_adress$') AS `tmpl_land`,
  IF(ISNULL(`l`.`id_land`), '', ' (кадастровый номер $land_inventory$)') AS `land_inventory_postfix`,
  `l`.`inventory_number` AS `land_inventory`,
  IF(ISNULL(`l`.`id_land`), '', ', общей площадью $land_area$ ($land_area_txt$) кв. м') AS `land_area_postfix`,
  `l`.`total_area` AS `land_area`,
  `l`.`total_area` AS `land_area_txt`
FROM ((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`apartments` `a1`
    ON ((`c`.`id_apartment_side1` = `a1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `a2`
    ON ((`c`.`id_apartment_side2` = `a2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `a12`
    ON ((`c`.`id_apartment_side12` = `a12`.`id_apartment`)))
  LEFT JOIN `mena`.`land` `l`
    ON ((`a2`.`id_apartment` = `l`.`id_apartment`)))
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_contract_dksr_old`
--
CREATE
VIEW v_contract_dksr_old
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'по адресу: Российская Федерация, $side1_address$ (кадастровый номер $side1_inventory_number$)$side1_room_postfix$', 'по адресам:$br$ а) Российская Федерация, $side1_address$ (кадастровый номер $side1_inventory_number$)$side1_room_postfix$; $br$ б) Российская Федерация, $side12_address$ (кадастровый номер $side12_inventory_number$)$side12_room_postfix$') AS `p1`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'по адресу: Российская Федерация, $side1_address$', ': $br$ a) Российская Федерация, $side1_address$; $br$ б) Российская Федерация, $side2_address$') AS `act_p1`,
  (CASE WHEN (`as1`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as1`.`room_count`, 0) > 0), ', состоящее из $side1_room_count$ комнат', '') END) AS `side1_room_postfix`,
  (CASE WHEN (`as2`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as2`.`room_count`, 0) > 0), ', состоящее из $side2_room_count$ комнат', '') END) AS `side2_room_postfix`,
  (CASE WHEN (`as12`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as12`.`room_count`, 0) > 0), ', состоящее из $side12_room_count$ комнат', '') END) AS `side12_room_postfix`,
  `c`.`id_apartment_side1` AS `id_apartment_side1`,
  `c`.`id_apartment_side2` AS `id_apartment_side2`,
  IF(ISNULL(`l`.`id_land`), '.', ', и земельный участок по адресу: Российская Федерация, $land_adress$ (кадастровый номер $side2land_inventory_number$)') AS `land_postfix`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельный участок по адресу: Российская Федерация, $land_adress$') AS `land_postfix2`,
  CONCAT(CONCAT(IF((`l`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`l`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`l`.`id_street`)), ', ', `l`.`house`)) AS `land_adress`,
  `l`.`inventory_number` AS `side2land_inventory_number`,
  GROUP_CONCAT(`vcpi`.`person_dksr` SEPARATOR ', ') AS `persons`,
  CONCAT(CONCAT(IF((`as1`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as1`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as1`.`id_street`)), ', дом ', `as1`.`house`), IFNULL(CONCAT(', квартира ', `as1`.`flat`), ''), IF((`as1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as1`.`room`), ''))) AS `side1_address`,
  CONCAT(CONCAT(IF((`as2`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as2`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as2`.`id_street`)), ', дом ', `as2`.`house`), IFNULL(CONCAT(', квартира ', `as2`.`flat`), ''), IF((`as2`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as2`.`room`), ''))) AS `side2_address`,
  CONCAT(CONCAT(IF((`as12`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as12`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as12`.`id_street`)), ', дом ', `as12`.`house`), IFNULL(CONCAT(', квартира ', `as12`.`flat`), ''), IF((`as12`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as12`.`room`), ''))) AS `side12_address`,
  IF(ISNULL(`c`.`id_apartment_side12`), '', `vcs12w`.`side12_warrants`) AS `side12_warrants`,
  `vcs2w`.`side2_warrants` AS `side2_warrants`,
  `vcds1w`.`side1_warrants` AS `side1_warrants`,
  IFNULL(`as1`.`room_count`, 0) AS `side1_room_count`,
  IFNULL(`as2`.`room_count`, 0) AS `side2_room_count`,
  IFNULL(`as12`.`room_count`, 0) AS `side12_room_count`,
  `as1`.`inventory_number` AS `side1_inventory_number`,
  `as2`.`inventory_number` AS `side2_inventory_number`,
  `as12`.`inventory_number` AS `side12_inventory_number`
FROM ((((((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`apartments` `as1`
    ON ((`c`.`id_apartment_side1` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as2`
    ON ((`c`.`id_apartment_side2` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as12`
    ON ((`c`.`id_apartment_side12` = `as12`.`id_apartment`)))
  LEFT JOIN `mena`.`v_contract_participants_info` `vcpi`
    ON ((`vcpi`.`id_apartment` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`land` `l`
    ON ((`as2`.`id_apartment` = `l`.`id_apartment`)))
  LEFT JOIN `mena`.`v_contract_side2_warrants` `vcs2w`
    ON ((`vcs2w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side12_warrants` `vcs12w`
    ON ((`vcs12w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_dksr_side1_warrant` `vcds1w`
    ON ((`vcds1w`.`id_contract` = `c`.`id_contract`)))
WHERE (`c`.`was_deleted` = 0)
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_contract_dksr`
--
CREATE
VIEW v_contract_dksr
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'по адресу: Российская Федерация, $side1_address$ (кадастровый номер $side1_inventory_number$)$side1_room_postfix$', 'по адресам:$br$ а) Российская Федерация, $side1_address$ (кадастровый номер $side1_inventory_number$)$side1_room_postfix$; $br$ б) Российская Федерация, $side12_address$ (кадастровый номер $side12_inventory_number$)$side12_room_postfix$') AS `p1`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'по адресу: Российская Федерация, $side1_address$', ': $br$ a) Российская Федерация, $side1_address$; $br$ б) Российская Федерация, $side2_address$') AS `act_p1`,
  (CASE WHEN (`as1`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as1`.`room_count`, 0) > 0), ', состоящее из $side1_room_count$ комнат', '') END) AS `side1_room_postfix`,
  (CASE WHEN (`as2`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as2`.`room_count`, 0) > 0), ', состоящее из $side2_room_count$ комнат', '') END) AS `side2_room_postfix`,
  (CASE WHEN (`as12`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as12`.`room_count`, 0) > 0), ', состоящее из $side12_room_count$ комнат', '') END) AS `side12_room_postfix`,
  `c`.`id_apartment_side1` AS `id_apartment_side1`,
  `c`.`id_apartment_side2` AS `id_apartment_side2`,
  IF(ISNULL(`l`.`id_land`), '.', ', и земельный участок по адресу: Российская Федерация, $land_adress$ (кадастровый номер $side2land_inventory_number$)') AS `land_postfix`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельный участок по адресу: Российская Федерация, $land_adress$') AS `land_postfix2`,
  CONCAT(CONCAT(IF((`l`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`l`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`l`.`id_street`)), ', ', `l`.`house`)) AS `land_adress`,
  `l`.`inventory_number` AS `side2land_inventory_number`,
  CONCAT(CONCAT(IF((`as1`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as1`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as1`.`id_street`)), ', дом ', `as1`.`house`), IFNULL(CONCAT(', квартира ', `as1`.`flat`), ''), IF((`as1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as1`.`room`), ''))) AS `side1_address`,
  CONCAT(CONCAT(IF((`as2`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as2`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as2`.`id_street`)), ', дом ', `as2`.`house`), IFNULL(CONCAT(', квартира ', `as2`.`flat`), ''), IF((`as2`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as2`.`room`), ''))) AS `side2_address`,
  CONCAT(CONCAT(IF((`as12`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as12`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as12`.`id_street`)), ', дом ', `as12`.`house`), IFNULL(CONCAT(', квартира ', `as12`.`flat`), ''), IF((`as12`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as12`.`room`), ''))) AS `side12_address`,
  IF(ISNULL(`c`.`id_apartment_side12`), '', `vcs12w`.`side12_warrants`) AS `side12_warrants`,
  `vcs2w`.`side2_warrants` AS `side2_warrants`,
  `vcds1w`.`side1_warrants` AS `side1_warrants`,
  IFNULL(`as1`.`room_count`, 0) AS `side1_room_count`,
  IFNULL(`as2`.`room_count`, 0) AS `side2_room_count`,
  IFNULL(`as12`.`room_count`, 0) AS `side12_room_count`,
  `as1`.`inventory_number` AS `side1_inventory_number`,
  `as2`.`inventory_number` AS `side2_inventory_number`,
  `as12`.`inventory_number` AS `side12_inventory_number`
FROM (((((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`apartments` `as1`
    ON ((`c`.`id_apartment_side1` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as2`
    ON ((`c`.`id_apartment_side2` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as12`
    ON ((`c`.`id_apartment_side12` = `as12`.`id_apartment`)))
  LEFT JOIN `mena`.`land` `l`
    ON ((`as2`.`id_apartment` = `l`.`id_apartment`)))
  LEFT JOIN `mena`.`v_contract_side2_warrants` `vcs2w`
    ON ((`vcs2w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side12_warrants` `vcs12w`
    ON ((`vcs12w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_dksr_side1_warrant` `vcds1w`
    ON ((`vcds1w`.`id_contract` = `c`.`id_contract`)))
WHERE (`c`.`was_deleted` = 0)
GROUP BY `c`.`id_contract`;

--
-- Создать таблицу `bank_info`
--
CREATE TABLE IF NOT EXISTS bank_info (
  id_bank int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_apartment int(11) UNSIGNED NOT NULL,
  account varchar(255) DEFAULT NULL,
  account_holder varchar(255) DEFAULT NULL,
  bank varchar(1000) DEFAULT NULL,
  sum decimal(19, 2) DEFAULT NULL,
  was_deleted int(1) DEFAULT 0,
  sum_string varchar(500) DEFAULT NULL,
  PRIMARY KEY (id_bank)
)
ENGINE = INNODB,
AUTO_INCREMENT = 192,
AVG_ROW_LENGTH = 524,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать представление `v_bank_count`
--
CREATE
VIEW v_bank_count
AS
SELECT
  `bi`.`id_apartment` AS `id_apartment`,
  COUNT(0) AS `cnt`
FROM `bank_info` `bi`
WHERE (`bi`.`was_deleted` = 0)
GROUP BY `bi`.`id_apartment`;

--
-- Создать таблицу `sp_pre_contract_issued`
--
CREATE TABLE IF NOT EXISTS sp_pre_contract_issued (
  id_pre_contract_issued tinyint(4) UNSIGNED NOT NULL AUTO_INCREMENT,
  pre_contract_name varchar(1024) NOT NULL,
  pre_contract_name_short varchar(50) NOT NULL,
  PRIMARY KEY (id_pre_contract_issued)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'кто выдает предварительные договора';

--
-- Создать таблицу `sp_signer`
--
CREATE TABLE IF NOT EXISTS sp_signer (
  id_signer int(11) NOT NULL AUTO_INCREMENT,
  post varchar(255) NOT NULL,
  post_genitive varchar(255) DEFAULT NULL,
  family varchar(50) NOT NULL,
  name varchar(50) NOT NULL,
  father varchar(50) NOT NULL,
  phone varchar(20) DEFAULT NULL,
  id_signer_type int(11) NOT NULL COMMENT 'Тип подписывальщика:
1 - Глава администрации, его зам
2 - Глава комитета, его зам
3 - Юрист
4 - Составитель документа',
  short_post_2 varchar(255) DEFAULT NULL COMMENT 'Сокращение должности, костыль ***',
  short_post varchar(255) DEFAULT NULL COMMENT 'Сокращение должности, вариант 2',
  PRIMARY KEY (id_signer)
)
ENGINE = INNODB,
AUTO_INCREMENT = 34,
AVG_ROW_LENGTH = 1260,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать представление `v_warrant template`
--
CREATE
VIEW `v_warrant template`
AS
SELECT
  `ss`.`id_signer` AS `id_order_boss`,
  IF((`ss`.`id_signer` = 6), 'Урезалова', IF((`ss`.`id_signer` = 14), 'Серебренников', 'Остальные')) AS `warrant_template_add`
FROM (`sp_warrant_template` `swt`
  JOIN `sp_signer` `ss`);

--
-- Создать представление `v_rasp_info_signers`
--
CREATE
VIEW v_rasp_info_signers
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  `ss`.`id_signer` AS `rasp_boss_signer_id`,
  `ss`.`post` AS `rasp_boss_signer_post`,
  CONCAT(CONCAT(`ss`.`family`, ' ', `ss`.`name`), ' ', `ss`.`father`) AS `rasp_boss_signer_fio`,
  `ss1`.`post` AS `rasp_verify_post`,
  CONCAT(CONCAT(`ss1`.`family`, ' ', `ss1`.`name`), ' ', `ss1`.`father`) AS `rasp_verify_signer_fio`,
  `ss2`.`post` AS `rasp_lawer_post`,
  CONCAT(CONCAT(`ss2`.`family`, ' ', `ss2`.`name`), ' ', `ss2`.`father`) AS `rasp_lawer_signer_fio`,
  `ss3`.`phone` AS `signer_worker_phone`,
  CONCAT(CONCAT(`ss3`.`family`, ' ', `ss3`.`name`), ' ', `ss3`.`father`) AS `signer_worker_fio`,
  YEAR(NOW()) AS `order_year`
FROM (((((`contracts` `c`
  LEFT JOIN `document_signers` `ds`
    ON ((`ds`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `sp_signer` `ss`
    ON ((`ds`.`id_rasp_boss` = `ss`.`id_signer`)))
  LEFT JOIN `sp_signer` `ss1`
    ON ((`ds`.`id_rasp_verify` = `ss1`.`id_signer`)))
  LEFT JOIN `sp_signer` `ss2`
    ON ((`ds`.`id_rasp_lawer` = `ss2`.`id_signer`)))
  LEFT JOIN `sp_signer` `ss3`
    ON ((`ds`.`id_rasp_executor` = `ss3`.`id_signer`)))
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_order_info_signers`
--
CREATE
VIEW v_order_info_signers
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  `ss`.`id_signer` AS `order_boss_signer_id`,
  `ss`.`post` AS `order_boss_signer_post`,
  CONCAT(CONCAT(`ss`.`family`, ' ', `ss`.`name`), ' ', `ss`.`father`) AS `order_boss_signer_fio`,
  `ss1`.`post` AS `order_commitet_signer_post`,
  CONCAT(CONCAT(`ss1`.`family`, ' ', `ss1`.`name`), ' ', `ss1`.`father`) AS `order_commitet_signer_fio`,
  `ss2`.`post` AS `order_verify_lawer_post`,
  CONCAT(CONCAT(`ss2`.`family`, ' ', `ss2`.`name`), ' ', `ss2`.`father`) AS `order_verify_lawer_fio`,
  `ss3`.`post` AS `order_verify_boss_post`,
  CONCAT(CONCAT(`ss3`.`family`, ' ', `ss3`.`name`), ' ', `ss3`.`father`) AS `order_verify_boss_fio`,
  CONCAT(CONCAT(`ss4`.`family`, ' ', `ss4`.`name`), ' ', `ss4`.`father`) AS `order_worker_fio`,
  `ss4`.`phone` AS `order_worker_phone`,
  YEAR(NOW()) AS `order_year`
FROM ((((((`contracts` `c`
  LEFT JOIN `document_signers` `ds`
    ON ((`ds`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `sp_signer` `ss`
    ON ((`ds`.`id_order_boss` = `ss`.`id_signer`)))
  LEFT JOIN `sp_signer` `ss1`
    ON ((`ds`.`id_order_commitet_signer` = `ss1`.`id_signer`)))
  LEFT JOIN `sp_signer` `ss2`
    ON ((`ds`.`id_order_verify_lawer` = `ss2`.`id_signer`)))
  LEFT JOIN `sp_signer` `ss3`
    ON ((`ds`.`id_order_verify_boss` = `ss3`.`id_signer`)))
  LEFT JOIN `sp_signer` `ss4`
    ON ((`ds`.`id_order_worker` = `ss4`.`id_signer`)))
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_invite_info`
--
CREATE
VIEW v_invite_info
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  CONCAT(CONCAT(`p`.`family`, ' ', `p`.`name`), ' ', `p`.`father`) AS `person_fio_genitive`,
  CONCAT(CONCAT(`kladr`.`get_street_name_for_kladr`(`p`.`id_registration_street`), ', дом ', `p`.`registration_house`), ', кв. ', `p`.`regiostration_flat`, ', ком. ', `p`.`registration_room`) AS `registration_address`,
  `kladr`.`get_city_for_kladr`(`p`.`id_registration_street`) AS `registration_city`,
  `p`.`registration_index` AS `registration_index`,
  `ss`.`short_post` AS `invite_signer_post`,
  CONCAT(CONCAT(`ss`.`family`, ' ', `ss`.`name`), ' ', `ss`.`father`) AS `invite_signer_fio`,
  CONCAT(CONCAT(`ss1`.`family`, ' ', `ss1`.`name`), ' ', `ss1`.`father`) AS `invite_worker_fio`,
  `ss1`.`phone` AS `invite_worker_phone`
FROM (((((`mena`.`persons` `p`
  LEFT JOIN `mena`.`apartments` `a`
    ON ((`p`.`id_apartment` = `a`.`id_apartment`)))
  LEFT JOIN `mena`.`contracts` `c`
    ON ((`c`.`id_apartment_side2` = `a`.`id_apartment`)))
  LEFT JOIN `mena`.`document_signers` `ds`
    ON ((`c`.`id_contract` = `ds`.`id_contract`)))
  LEFT JOIN `mena`.`sp_signer` `ss`
    ON ((`ds`.`id_invite_signer` = `ss`.`id_signer`)))
  LEFT JOIN `mena`.`sp_signer` `ss1`
    ON ((`ds`.`id_invite_worker` = `ss1`.`id_signer`)))
WHERE (`p`.`id_person_status` = 1);

--
-- Создать таблицу `sp_contract_reasons`
--
CREATE TABLE IF NOT EXISTS sp_contract_reasons (
  id_contract_reason int(11) NOT NULL AUTO_INCREMENT,
  template varchar(255) NOT NULL,
  PRIMARY KEY (id_contract_reason)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'contract_reasons';

--
-- Создать таблицу `sp_copykgc`
--
CREATE TABLE IF NOT EXISTS sp_copykgc (
  id_copy tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT,
  copy varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  PRIMARY KEY (id_copy)
)
ENGINE = INNODB,
AUTO_INCREMENT = 4,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Копии переданы в КГС';

--
-- Создать таблицу `sp_predost`
--
CREATE TABLE IF NOT EXISTS sp_predost (
  id_predost tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT,
  predost varchar(255) NOT NULL,
  PRIMARY KEY (id_predost)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Предоставление ж.п.';

--
-- Создать таблицу `additional`
--
CREATE TABLE IF NOT EXISTS additional (
  `№PP` int(11) DEFAULT NULL,
  street varchar(255) DEFAULT NULL,
  house varchar(5) DEFAULT NULL,
  flat varchar(10) DEFAULT NULL,
  godVvod varchar(5) DEFAULT NULL,
  typeZdanie varchar(5) DEFAULT NULL,
  t_area1 double DEFAULT NULL,
  cntCivil int(11) DEFAULT NULL,
  FIO varchar(255) DEFAULT NULL,
  tehsost varchar(255) DEFAULT NULL,
  t_area2 double DEFAULT NULL,
  street_mun varchar(255) DEFAULT NULL,
  house_mun varchar(5) DEFAULT NULL,
  flat_mun varchar(10) DEFAULT NULL,
  id_predost tinyint(3) DEFAULT NULL,
  id_osnovanie varchar(255) DEFAULT NULL,
  dateOsnov varchar(255) DEFAULT NULL,
  dogPor varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateDogPor date DEFAULT NULL,
  dateMena varchar(255) DEFAULT NULL,
  dogMena varchar(255) DEFAULT NULL,
  datePodMena varchar(255) DEFAULT NULL,
  id_copy int(11) DEFAULT NULL,
  ogranichenie varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  Npostanovl varchar(255) DEFAULT NULL,
  datePost varchar(255) DEFAULT NULL,
  primechanie varchar(2000) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateUvedom varchar(255) DEFAULT NULL,
  phoneCivil varchar(500) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  InfoSnyatUchet varchar(500) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateEvualation date DEFAULT NULL,
  infoEvualation varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateEvualDone date DEFAULT NULL,
  dateZaselenie date DEFAULT NULL,
  proIsk varchar(255) DEFAULT NULL,
  iskSudKumi varchar(255) DEFAULT NULL,
  iskSudPr varchar(255) DEFAULT NULL,
  id_osnovPro varchar(255) DEFAULT NULL,
  id_street varchar(17) DEFAULT NULL,
  id_street1 varchar(17) DEFAULT NULL,
  id_apart int(11) DEFAULT NULL,
  id_apart1 int(11) DEFAULT NULL,
  id_contract int(11) DEFAULT NULL,
  id_addit int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  predost varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_addit)
)
ENGINE = INNODB,
AUTO_INCREMENT = 756,
AVG_ROW_LENGTH = 371,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
ROW_FORMAT = DYNAMIC;

--
-- Создать представление `v_additional`
--
CREATE
VIEW v_additional
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  `a`.`№PP` AS `npp`,
  `kladr`.`get_street_name_for_kladr`(`a`.`id_street`) AS `street_side2`,
  `a`.`house` AS `house2`,
  `a`.`flat` AS `flat2`,
  `a1`.`total_area` AS `total_area2`,
  `a`.`cntCivil` AS `countCivil`,
  `a`.`FIO` AS `FIO`,
  `a2`.`total_area` AS `total_area`,
  `a`.`street_mun` AS `street_side1`,
  `a`.`house_mun` AS `house1`,
  `a`.`flat_mun` AS `flat1`,
  `sp`.`predost` AS `predost`,
  `a`.`id_osnovanie` AS `osnovanie`,
  `a`.`dateOsnov` AS `dateOsnovanie`,
  `a`.`dogPor` AS `dogPor`,
  DATE_FORMAT(`a`.`dateDogPor`, '%d.%m.%Y') AS `dateDogPor`,
  DATE_FORMAT(`c`.`contract_Registration_date`, '%d.%m.%Y') AS `contract_date`,
  `sc`.`copy` AS `copy`,
  `a`.`ogranichenie` AS `ogranichenie`,
  DATE_FORMAT(`c`.`filing_date`, '%d.%m.%Y') AS `filing_date`,
  `c`.`order_number` AS `order_number`,
  DATE_FORMAT(`c`.`order_date`, '%d.%m.%Y') AS `order_date`,
  `a`.`primechanie` AS `primechanie`,
  `a`.`dateUvedom` AS `dateUvedom`,
  `a`.`phoneCivil` AS `phoneCivil`,
  `a`.`InfoSnyatUchet` AS `infoUchet`,
  DATE_FORMAT(`a`.`dateEvualation`, '%d.%m.%Y') AS `dateEvual`,
  `a`.`infoEvualation` AS `infoEvual`,
  DATE_FORMAT(`a`.`dateEvualDone`, '%d.%m.%Y') AS `dateEvualDone`,
  DATE_FORMAT(`a`.`dateZaselenie`, '%d.%m.%Y') AS `dateZaselenie`
FROM (((((`mena`.`additional` `a`
  LEFT JOIN `mena`.`contracts` `c`
    ON ((`c`.`id_contract` = `a`.`id_contract`)))
  LEFT JOIN `mena`.`apartments` `a1`
    ON ((`a1`.`id_apartment` = `a`.`id_apart1`)))
  LEFT JOIN `mena`.`apartments` `a2`
    ON ((`a2`.`id_apartment` = `a`.`id_apart`)))
  LEFT JOIN `mena`.`sp_predost` `sp`
    ON ((`sp`.`id_predost` = `a`.`id_predost`)))
  LEFT JOIN `mena`.`sp_copykgc` `sc`
    ON ((`sc`.`id_copy` = `a`.`id_copy`)))
ORDER BY `a`.`id_addit`;

--
-- Создать таблицу `sp_signer2`
--
CREATE TABLE IF NOT EXISTS sp_signer2 (
  id_signer int(11) NOT NULL AUTO_INCREMENT,
  post varchar(255) NOT NULL,
  post_genitive varchar(255) DEFAULT NULL,
  family varchar(50) NOT NULL,
  name varchar(50) NOT NULL,
  father varchar(50) NOT NULL,
  phone varchar(20) DEFAULT NULL,
  id_signer_type int(11) NOT NULL COMMENT 'Тип подписывальщика:
1 - Глава администрации, его зам
2 - Глава комитета, его зам
3 - Юрист
4 - Составитель документа',
  short_post_2 varchar(255) DEFAULT NULL COMMENT 'Сокращение должности, костыль ***',
  short_post varchar(255) DEFAULT NULL COMMENT 'Сокращение должности, вариант 2',
  PRIMARY KEY (id_signer)
)
ENGINE = INNODB,
AUTO_INCREMENT = 26,
AVG_ROW_LENGTH = 1260,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать представление `view1`
--
CREATE
VIEW view1
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  GROUP_CONCAT(CONCAT(CONCAT(`p`.`family`, ' ', `p`.`name`), ' ', `p`.`father`) SEPARATOR ', ') AS `person_fio_genetive`,
  CONCAT(CONCAT(IFNULL(`kladr`.`get_street_name_for_kladr`(`p`.`id_registration_street`), ''), IFNULL(CONCAT(', дом ', `p`.`registration_house`), '')), IFNULL(CONCAT(', квартира ', `p`.`regiostration_flat`), ''), IFNULL(CONCAT(', комната ', `p`.`registration_room`), '')) AS `registration_address`,
  CONCAT(CONCAT(IFNULL(`kladr`.`get_full_street_for_kladr`(`p`.`id_registration_street`), ''), IFNULL(CONCAT(', дом ', `p`.`registration_house`), '')), IFNULL(CONCAT(', квартира ', `p`.`regiostration_flat`), ''), IFNULL(CONCAT(', комната ', `p`.`registration_room`), '')) AS `registration_full_address`,
  `kladr`.`get_city_for_kladr`(`p`.`id_registration_street`) AS `registration_city`,
  `p`.`registration_index` AS `registration_index`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`a1`.`id_street`), ', дом ', `a1`.`house`), IFNULL(CONCAT(', квартира ', IF((`a1`.`flat` = ''), NULL, `a1`.`flat`)), '')) AS `side1_address`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`a2`.`id_street`), ', дом ', `a2`.`house`), IFNULL(CONCAT(', квартира ', IF((`a2`.`flat` = ''), NULL, `a2`.`flat`)), '')) AS `side2_address`,
  `ss`.`short_post` AS `notify_signer_post`,
  CONCAT(CONCAT(`ss`.`family`, ' ', `ss`.`name`), ' ', `ss`.`father`) AS `notify_signer_fio`,
  CONCAT(CONCAT(`ss1`.`family`, ' ', `ss1`.`name`), ' ', `ss1`.`father`) AS `notify_worker_fio`,
  `ss1`.`phone` AS `notify_worker_phone`
FROM ((((((`mena`.`persons` `p`
  LEFT JOIN `mena`.`apartments` `a1`
    ON ((`p`.`id_apartment` = `a1`.`id_apartment`)))
  LEFT JOIN `mena`.`contracts` `c`
    ON ((`c`.`id_apartment_side2` = `a1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `a2`
    ON ((`c`.`id_apartment_side1` = `a2`.`id_apartment`)))
  LEFT JOIN `mena`.`document_signers` `ds`
    ON ((`c`.`id_contract` = `ds`.`id_contract`)))
  LEFT JOIN `mena`.`sp_signer2` `ss`
    ON ((`ds`.`id_notify_signer` = `ss`.`id_signer`)))
  LEFT JOIN `mena`.`sp_signer2` `ss1`
    ON ((`ds`.`id_notify_worker` = `ss1`.`id_signer`)))
WHERE ((`p`.`id_person_status` = 1)
AND (`c`.`id_contract` = 196));

--
-- Создать представление `v_notify_info`
--
CREATE
VIEW v_notify_info
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  CONCAT(CONCAT(`p`.`family`, ' ', `p`.`name`), ' ', `p`.`father`) AS `person_fio_genetive_`,
  GROUP_CONCAT(CONCAT(CONCAT(`p`.`family`, ' ', `p`.`name`), ' ', `p`.`father`) SEPARATOR ', ') AS `person_fio_genetive`,
  CONCAT(CONCAT(IFNULL(`kladr`.`get_street_name_for_kladr`(`p`.`id_registration_street`), ''), IFNULL(CONCAT(', дом ', `p`.`registration_house`), '')), IFNULL(CONCAT(', квартира ', `p`.`regiostration_flat`), ''), IFNULL(CONCAT(', комната ', `p`.`registration_room`), '')) AS `registration_address`,
  CONCAT(CONCAT(IFNULL(`kladr`.`get_full_street_for_kladr`(`p`.`id_registration_street`), ''), IFNULL(CONCAT(', дом ', `p`.`registration_house`), '')), IFNULL(CONCAT(', квартира ', `p`.`regiostration_flat`), ''), IFNULL(CONCAT(', комната ', `p`.`registration_room`), '')) AS `registration_full_address`,
  `kladr`.`get_city_for_kladr`(`p`.`id_registration_street`) AS `registration_city`,
  `p`.`registration_index` AS `registration_index`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`a1`.`id_street`), ', дом ', `a1`.`house`), IFNULL(CONCAT(', квартира ', IF((`a1`.`flat` = ''), NULL, `a1`.`flat`)), '')) AS `side1_address`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`a2`.`id_street`), ', дом ', `a2`.`house`), IFNULL(CONCAT(', квартира ', IF((`a2`.`flat` = ''), NULL, `a2`.`flat`)), '')) AS `side2_address`,
  `ss`.`short_post` AS `notify_signer_post`,
  CONCAT(CONCAT(`ss`.`family`, ' ', `ss`.`name`), ' ', `ss`.`father`) AS `notify_signer_fio`,
  CONCAT(CONCAT(`ss1`.`family`, ' ', `ss1`.`name`), ' ', `ss1`.`father`) AS `notify_worker_fio`,
  `ss1`.`phone` AS `notify_worker_phone`,
  `a1`.`id_street` AS `id_street1`,
  `a2`.`id_street` AS `id_street2`
FROM ((((((`mena`.`persons` `p`
  LEFT JOIN `mena`.`apartments` `a1`
    ON ((`p`.`id_apartment` = `a1`.`id_apartment`)))
  LEFT JOIN `mena`.`contracts` `c`
    ON ((`c`.`id_apartment_side2` = `a1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `a2`
    ON ((`c`.`id_apartment_side1` = `a2`.`id_apartment`)))
  LEFT JOIN `mena`.`document_signers` `ds`
    ON ((`c`.`id_contract` = `ds`.`id_contract`)))
  LEFT JOIN `mena`.`sp_signer2` `ss`
    ON ((`ds`.`id_notify_signer` = `ss`.`id_signer`)))
  LEFT JOIN `mena`.`sp_signer2` `ss1`
    ON ((`ds`.`id_notify_worker` = `ss1`.`id_signer`)))
WHERE (`p`.`id_person_status` = 1);

--
-- Создать таблицу `sp_person_status`
--
CREATE TABLE IF NOT EXISTS sp_person_status (
  id_person_status int(11) NOT NULL AUTO_INCREMENT,
  status varchar(50) DEFAULT NULL,
  PRIMARY KEY (id_person_status)
)
ENGINE = INNODB,
AUTO_INCREMENT = 65,
AVG_ROW_LENGTH = 256,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать процедуру `ins`
--
CREATE PROCEDURE ins (IN in_text varchar(255))
BEGIN
  INSERT INTO sp_person_status
    VALUES (in_text);
END
$$

DELIMITER ;

--
-- Создать таблицу `sp_process_status`
--
CREATE TABLE IF NOT EXISTS sp_process_status (
  id_process_status tinyint(4) NOT NULL AUTO_INCREMENT,
  process_status varchar(255) NOT NULL,
  process_status_template varchar(255) NOT NULL,
  step varchar(5) NOT NULL,
  PRIMARY KEY (id_process_status)
)
ENGINE = INNODB,
AUTO_INCREMENT = 14,
AVG_ROW_LENGTH = 1260,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Справочник состояния договора';

--
-- Создать таблицу `contract_status_history`
--
CREATE TABLE IF NOT EXISTS contract_status_history (
  id_history_status int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_contract int(11) UNSIGNED NOT NULL COMMENT 'код договора',
  id_process_status tinyint(4) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'код статуса',
  status_date datetime NOT NULL COMMENT 'дата статуса',
  PRIMARY KEY (id_history_status)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3512,
AVG_ROW_LENGTH = 71,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'История статусов к договорам';

--
-- Создать индекс `IDX_contract_status_history_id_contract` для объекта типа таблица `contract_status_history`
--
ALTER TABLE contract_status_history
ADD INDEX IDX_contract_status_history_id_contract (id_contract);

DELIMITER $$

--
-- Создать функцию `get_process_status_for_contract`
--
CREATE FUNCTION get_process_status_for_contract (par_id_contract int)
RETURNS varchar(255) CHARSET utf8
BEGIN
  DECLARE res varchar(255);
  SET res = (SELECT
      REPLACE(CONCAT(sps.step, ')', sps.process_status_template), '@date@', DATE_FORMAT(IFNULL(status_date, ''), '%d.%m.%Y'))
    FROM contract_status_history
      LEFT JOIN sp_process_status sps USING (id_process_status)
    WHERE id_contract = par_id_contract
    ORDER BY id_process_status DESC LIMIT 1);
  RETURN res;
END
$$

DELIMITER ;

--
-- Создать таблицу `sp_evaluator`
--
CREATE TABLE IF NOT EXISTS sp_evaluator (
  id_evaluator int(11) NOT NULL AUTO_INCREMENT,
  evaluator_name varchar(50) NOT NULL COMMENT 'название оценщика',
  evaluator_boss varchar(255) NOT NULL COMMENT 'В лице ',
  PRIMARY KEY (id_evaluator)
)
ENGINE = INNODB,
AUTO_INCREMENT = 6,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Оценщики';

--
-- Создать таблицу `apartment_evaluations`
--
CREATE TABLE IF NOT EXISTS apartment_evaluations (
  id_apartment_evaluation int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_apartment int(11) UNSIGNED NOT NULL,
  id_evaluator smallint(5) UNSIGNED DEFAULT NULL,
  evaluation_number varchar(255) DEFAULT NULL,
  evaluation_price decimal(19, 2) DEFAULT NULL,
  evaluation_date datetime DEFAULT NULL,
  PRIMARY KEY (id_apartment_evaluation)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1383,
AVG_ROW_LENGTH = 80,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'оценка квартир';

DELIMITER $$

--
-- Создать функцию `get_evaluation_for_apartment`
--
CREATE FUNCTION get_evaluation_for_apartment (par_id_apartment int)
RETURNS varchar(255) CHARSET utf8
BEGIN
  DECLARE rez varchar(255);
  SET rez = (SELECT
      CONCAT(IFNULL(e.evaluator_name, ''), IFNULL(CONCAT(': ', ae.evaluation_price, ' руб.'), '')) AS evaluation
    FROM apartment_evaluations ae
      LEFT
      JOIN sp_evaluator e
        ON ae.id_evaluator = e.id_evaluator
    WHERE id_apartment = par_id_apartment);
  RETURN rez;
END
$$

--
-- Создать процедуру `copyContract`
--
CREATE PROCEDURE copyContract (IN ContractID int, OUT NewContractID int)
BEGIN
  DECLARE id_new_side1,
          id_new_side2 int;
  DECLARE done int DEFAULT 0;
  -- Person variables
  DECLARE var_id_person,
          var_id_new_person int;
  DECLARE var_id_document_issued,
          var_id_template int;
  DECLARE var_id_person_status,
          var_id_document smallint;
  DECLARE var_id_contractor,
          var_was_deleted,
          var_sex tinyint;
  DECLARE var_document_issued,
          var_born_place,
          var_phone varchar(255);
  DECLARE var_family,
          var_name,
          var_father varchar(50);
  DECLARE var_id_registration_street varchar(17);
  DECLARE var_regiostration_flat varchar(10);
  DECLARE var_document_seria,
          var_document_number varchar(8);
  DECLARE var_registration_index varchar(6);
  DECLARE var_registration_house,
          var_portion varchar(5);
  DECLARE var_birth datetime;
  DECLARE var_document_date date;
  -- Apartment variables
  DECLARE var_id_warrant_apartment,
          var_id_new_warrant_apartment,
          var_id_warrant_template int;
  -- Person cursor declaration
  DECLARE persons_cursor CURSOR FOR
  SELECT
    p.id_person,
    p.id_person_status,
    p.id_contractor,
    p.family,
    p.`name`,
    p.father,
    p.birth,
    p.id_document,
    p.document_seria,
    p.document_number,
    p.document_issued,
    p.id_document_issued,
    p.document_date,
    p.born_place,
    p.id_registration_street,
    p.registration_house,
    p.regiostration_flat,
    p.registration_index,
    p.id_template,
    p.portion,
    p.was_deleted,
    p.phone,
    p.sex
  FROM persons p
  WHERE p.id_apartment = @id_side2;
  -- Apartment1 cursor declaration
  DECLARE apartment1_cursor CURSOR FOR
  SELECT
    wa.id_warrant_apartment,
    wa.id_warrant_template
  FROM warrant_apartment wa
  WHERE wa.id_apartment = @id_side1;
  -- Apartment2 cursor declaration
  DECLARE apartment2_cursor CURSOR FOR
  SELECT
    wa.id_warrant_apartment,
    wa.id_warrant_template
  FROM warrant_apartment wa
  WHERE wa.id_apartment = @id_side2;
  -- Handler declaration
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
  -- Insert contract info
  INSERT INTO contracts (id_delegate,
  id_executor,
  id_apartment_side1,
  id_apartment_side2,
  pre_contract_date,
  id_pre_contract_issued,
  id_contract_reason,
  contract_Registration_date,
  agreement_registration_date,
  id_agreement_represent,
  pre_contract_number,
  order_number,
  order_date,
  was_deleted,
  filing_date)
    SELECT
      c.id_delegate,
      c.id_executor,
      @id_side1 := c.id_apartment_side1,
      @id_side2 := c.id_apartment_side2,
      c.pre_contract_date,
      c.id_pre_contract_issued,
      c.id_contract_reason,
      c.contract_Registration_date,
      c.agreement_registration_date,
      NULL AS id_agreement_represent, -- ?
      c.pre_contract_number,
      c.order_number,
      c.order_date,
      0 AS was_deleted,
      NULL AS filing_date
    FROM contracts c
    WHERE c.id_contract = ContractID;
  SET NewContractID = LAST_INSERT_ID();
  -- Insert/Update apartment_side1 info
  INSERT INTO apartments (id_apartment_type,
  id_street,
  house,
  flat,
  total_area,
  part,
  living_area,
  house_floor,
  `floor`,
  inventory_number,
  room_count)
    SELECT
      a.id_apartment_type,
      a.id_street,
      a.house,
      a.flat,
      a.total_area,
      a.part,
      a.living_area,
      a.house_floor,
      a.`floor`,
      a.inventory_number,
      a.room_count
    FROM apartments a
    WHERE a.id_apartment = @id_side1;
  SET id_new_side1 = LAST_INSERT_ID();
  -- Insert/Update apartment_side2 info
  INSERT INTO apartments (id_apartment_type,
  id_street,
  house,
  flat,
  total_area,
  part,
  living_area,
  house_floor,
  `floor`,
  inventory_number,
  room_count)
    SELECT
      a.id_apartment_type,
      a.id_street,
      a.house,
      a.flat,
      a.total_area,
      a.part,
      a.living_area,
      a.house_floor,
      a.`floor`,
      a.inventory_number,
      a.room_count
    FROM apartments a
    WHERE a.id_apartment = @id_side2;
  SET id_new_side2 = LAST_INSERT_ID();
  -- Update contract apartments sides info
  UPDATE contracts
  SET id_apartment_side1 = id_new_side1,
      id_apartment_side2 = id_new_side2
  WHERE id_contract = NewContractID;
  -- Insert evaluations side1
  INSERT INTO apartment_evaluations (id_apartment,
  id_evaluator,
  evaluation_number,
  evaluation_price,
  evaluation_date)
    SELECT
      id_new_side1,
      ae.id_evaluator,
      ae.evaluation_number,
      ae.evaluation_price,
      ae.evaluation_date
    FROM apartment_evaluations ae
    WHERE ae.id_apartment = @id_side1;
  -- Insert evaluations side2
  INSERT INTO apartment_evaluations (id_apartment,
  id_evaluator,
  evaluation_number,
  evaluation_price,
  evaluation_date)
    SELECT
      id_new_side2,
      ae.id_evaluator,
      ae.evaluation_number,
      ae.evaluation_price,
      ae.evaluation_date
    FROM apartment_evaluations ae
    WHERE ae.id_apartment = @id_side2;
  -- Documents signers insert
  DELETE
    FROM document_signers
  WHERE id_contract = NewContractID;
  INSERT INTO document_signers (id_contract,
  id_agreement_signer,
  id_order_boss,
  id_order_commitet_signer,
  id_order_verify_lawer,
  id_order_verify_boss,
  id_order_worker,
  id_invite_signer,
  id_invite_worker,
  id_notify_signer,
  id_notify_worker)
    SELECT
      NewContractID,
      id_agreement_signer,
      id_order_boss,
      id_order_commitet_signer,
      id_order_verify_lawer,
      id_order_verify_boss,
      id_order_worker,
      id_invite_signer,
      id_invite_worker,
      id_notify_signer,
      id_notify_worker
    FROM document_signers ds
    WHERE ds.id_contract = ContractID;
  -- Person warrants variables copy
  OPEN persons_cursor;
  WHILE done = 0 DO
    FETCH persons_cursor INTO
    var_id_person,
    var_id_person_status,
    var_id_contractor,
    var_family,
    var_name,
    var_father,
    var_birth,
    var_id_document,
    var_document_seria,
    var_document_number,
    var_document_issued,
    var_id_document_issued,
    var_document_date,
    var_born_place,
    var_id_registration_street,
    var_registration_house,
    var_regiostration_flat,
    var_registration_index,
    var_id_template,
    var_portion,
    var_was_deleted,
    var_phone,
    var_sex;
    IF (done = 0) THEN
      INSERT INTO persons (id_apartment,
      id_person_status,
      id_contractor,
      family,
      `name`,
      father,
      birth,
      id_document,
      document_seria,
      document_number,
      document_issued,
      id_document_issued,
      document_date,
      born_place,
      id_registration_street,
      registration_house,
      regiostration_flat,
      registration_index,
      id_template,
      portion,
      was_deleted,
      phone,
      sex)
        VALUES (id_new_side2, var_id_person_status, var_id_contractor, var_family, var_name, var_father, var_birth, var_id_document, var_document_seria, var_document_number, var_document_issued, var_id_document_issued, var_document_date, var_born_place, var_id_registration_street, var_registration_house, var_regiostration_flat, var_registration_index, var_id_template, var_portion, var_was_deleted, var_phone, var_sex);
      SET var_id_new_person = LAST_INSERT_ID();
      INSERT INTO template_variables (id_template_variable_meta, id_object, `value`)
        SELECT
          tv.id_template_variable_meta,
          var_id_new_person,
          tv.`value`
        FROM template_variables tv
        WHERE (id_template_variable_meta IN (SELECT
            tvm.id_template_variable_meta
          FROM template_variables_meta tvm
          WHERE tvm.id_template = var_id_template))
        AND tv.id_object = var_id_person;
    END IF;
  END WHILE;
  CLOSE persons_cursor;
  -- Apartment warrants copy
  SET done = 0;
  OPEN apartment1_cursor;
  WHILE done = 0 DO
    FETCH apartment1_cursor INTO
    var_id_warrant_apartment, var_id_warrant_template;
    IF (done = 0) THEN
      INSERT INTO warrant_apartment (id_warrant_template,
      id_apartment)
        VALUES (var_id_warrant_template, id_new_side1);
      SET var_id_new_warrant_apartment = LAST_INSERT_ID();
      INSERT INTO template_variables (id_template_variable_meta, id_object, `value`)
        SELECT
          tv.id_template_variable_meta,
          var_id_new_warrant_apartment,
          tv.`value`
        FROM template_variables tv
        WHERE (id_template_variable_meta IN (SELECT
            tvm.id_template_variable_meta
          FROM template_variables_meta tvm
          WHERE tvm.id_template = var_id_warrant_template))
        AND tv.id_object = var_id_warrant_apartment;
    END IF;
  END WHILE;
  CLOSE apartment1_cursor;

  SET done = 0;
  OPEN apartment2_cursor;
  WHILE done = 0 DO
    FETCH apartment2_cursor INTO
    var_id_warrant_apartment, var_id_warrant_template;
    IF (done = 0) THEN
      INSERT INTO warrant_apartment (id_warrant_template,
      id_apartment)
        VALUES (var_id_warrant_template, id_new_side2);
      SET var_id_new_warrant_apartment = LAST_INSERT_ID();
      INSERT INTO template_variables (id_template_variable_meta, id_object, `value`)
        SELECT
          tv.id_template_variable_meta,
          var_id_new_warrant_apartment,
          tv.`value`
        FROM template_variables tv
        WHERE (id_template_variable_meta IN (SELECT
            tvm.id_template_variable_meta
          FROM template_variables_meta tvm
          WHERE tvm.id_template = var_id_warrant_template))
        AND tv.id_object = var_id_warrant_apartment;
    END IF;
  END WHILE;
  CLOSE apartment2_cursor;
END
$$

DELIMITER ;

--
-- Создать представление `v_rasp_owner`
--
CREATE
VIEW v_rasp_owner
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  `ae`.`evaluation_price` AS `evaluation_price`,
  GROUP_CONCAT(CONCAT(CONCAT(`p`.`family`, ' ', `p`.`name`), ' ', `p`.`father`) SEPARATOR ', $br$') AS `person_fio`,
  CONCAT(CONCAT(IF((`a2`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a2`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a2`.`id_street`)), ', дом ', `a2`.`house`), IFNULL(CONCAT(', квартира ', IF((`a2`.`flat` = ''), NULL, `a2`.`flat`)), ''), IFNULL(CONCAT(', комната ', IF((`a2`.`room` = ''), NULL, `a2`.`room`)), '')) AS `address`,
  `kladr`.`get_street_name_for_kladr`(`a2`.`id_street`) AS `street2`,
  `a2`.`house` AS `house2`,
  `a2`.`flat` AS `flat2`
FROM (((`mena`.`persons` `p`
  LEFT JOIN `mena`.`apartments` `a2`
    ON ((`p`.`id_apartment` = `a2`.`id_apartment`)))
  LEFT JOIN `mena`.`contracts` `c`
    ON ((`c`.`id_apartment_side2` = `a2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `ae`
    ON ((`ae`.`id_apartment` = `a2`.`id_apartment`)))
WHERE ((`c`.`was_deleted` = 0)
AND (`p`.`was_deleted` = 0))
GROUP BY `c`.`id_contract`
ORDER BY `street2`, (`a2`.`house` + 0), (`a2`.`flat` + 0);

--
-- Создать представление `v_precontract_old`
--
CREATE
VIEW v_precontract_old
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  IF((`c`.`eviction_required` = 1), 'Сторона 2 обязуется снять с регистрационного учета по месту жительства в жилом помещении по адресу: $side2_address$, всех лиц в течение ___ месяцев с даты заключения договора.', 'В аварийном жилом помещении, расположенном по адресу: $side2_address$, (кадастровый номер $side2_inventory_number$), никто не проживает и на регистрационном учете не состоит.') AS `p5_1`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'по адресу: $side1_address$ (кадастровый номер $side1_inventory_number$), общей площадью $side1_total_area_num$ ($side1_total_area_string$) кв. м', 'по адресам:$br$ а) $side1_address$ (кадастровый номер $side1_inventory_number$), общей площадью $side1_total_area_num$ ($side1_total_area_string$) кв. м.; $br$ б) $side12_address$ (кадастровый номер $side12_inventory_number$), общей площадью $side12_total_area_num$ ($side12_total_area_string$) кв. м') AS `p1`,
  (CASE WHEN (`as2`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as2`.`room_count`, 0) > 0), ' и состоит из $side2_room_count$ комнат', '') END) AS `side2_room_postfix`,
  `as2`.`floor` AS `floor`,
  `c`.`id_apartment_side1` AS `id_apartment_side1`,
  `c`.`id_apartment_side2` AS `id_apartment_side2`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельный участок по адресу: $land_adress$ (кадастровый номер $side2land_inventory_number$)') AS `land_postfix`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельный участок по адресу: $land_adress$') AS `land_postfix2`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`l`.`id_street`), ', ', `l`.`house`)) AS `land_adress`,
  `l`.`inventory_number` AS `side2land_inventory_number`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) > 0), ', $contract_registration_date_string$', '_______________201__года') AS `contract_registration_date_string_`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) > 0), ' $contract_registration_date$', '_____________') AS `contract_registration_date_`,
  DATE_FORMAT(`c`.`contract_Registration_date`, '%d.%m.%Y') AS `contract_registration_date`,
  DATE_FORMAT(`c`.`contract_Registration_date`, '%d.%m.%Y') AS `contract_registration_date_string`,
  REPLACE(REPLACE(`cr`.`template`, '@date@', DATE_FORMAT(`c`.`order_date`, '%d.%m.%Y')), '@number@', `c`.`order_number`) AS `contract_reason`,
  `sd`.`fio` AS `delegate_fio`,
  `sd`.`fio` AS `delegate_fio_rod`,
  DATE_FORMAT(`sd`.`birth`, '%d.%m.%Y') AS `delegate_birth`,
  `sd`.`passport_seria` AS `delegate_passport_seria`,
  `sd`.`passport_num` AS `delegate_passport_num`,
  `sd`.`passport_issued` AS `delegate_passport_issued`,
  DATE_FORMAT(`sd`.`passport_isssued_date`, '%d.%m.%Y') AS `delegate_passport_issued_date`,
  GROUP_CONCAT(`vcpi`.`pre_person` SEPARATOR ', ') AS `persons`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`as1`.`id_street`), ', дом ', `as1`.`house`), IFNULL(CONCAT(', квартира ', `as1`.`flat`), ''), IF((`as1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as1`.`room`), ''))) AS `side1_address`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`as2`.`id_street`), ', дом ', `as2`.`house`), IFNULL(CONCAT(', квартира ', `as2`.`flat`), ''), IF((`as2`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as2`.`room`), ''))) AS `side2_address`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`as12`.`id_street`), ', дом ', `as12`.`house`), IFNULL(CONCAT(', квартира ', `as12`.`flat`), ''), IF((`as12`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as12`.`room`), ''))) AS `side12_address`,
  IF(ISNULL(`as1`.`inventory_number`), '_________________', '$side1_invent_number$') AS `side1_inventory_number`,
  IF(ISNULL(`as2`.`inventory_number`), '_________________', '$side2_invent_number$') AS `side2_inventory_number`,
  IF(ISNULL(`as12`.`inventory_number`), '_________________', '$side12_invent_number$') AS `side12_inventory_number`,
  `as1`.`inventory_number` AS `side1_invent_number`,
  `as2`.`inventory_number` AS `side2_invent_number`,
  `as12`.`inventory_number` AS `side12_invent_number`,
  IFNULL(`as1`.`floor`, 0) AS `side1_floor`,
  IFNULL(`as2`.`floor`, 1) AS `side2_floor`,
  IFNULL(`as1`.`room_count`, 0) AS `side1_room_count`,
  IFNULL(`as2`.`room_count`, 0) AS `side2_room_count`,
  IFNULL(`as12`.`room_count`, 0) AS `side12_room_count`,
  IFNULL(`aes1`.`evaluation_price`, 0) AS `side1_evaluation_price_num`,
  IFNULL(`aes2`.`evaluation_price`, 0) AS `side2_evaluation_price_num`,
  IFNULL(`aes1`.`evaluation_price`, 0) AS `side1_evaluation_price_string`,
  IFNULL(`aes2`.`evaluation_price`, 0) AS `side2_evaluation_price_string`,
  `vcdw`.`delegate_warrant` AS `delegate_warrant`,
  `vcs1w`.`side1_warrants` AS `side1_warrants`,
  IF(ISNULL(`c`.`id_apartment_side12`), '', `vcs12w`.`side12_warrants`) AS `side12_warrants`,
  `vcs2w`.`side2_warrants` AS `side2_warrants`,
  `spci`.`pre_contract_name` AS `pre_contract_name`,
  IFNULL(`l`.`total_area`, 0) AS `land_total_area`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as1`.`total_area`, '.', ','))) AS `side1_total_area_num`,
  IFNULL(`as1`.`total_area`, 0) AS `side1_total_area_string`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as12`.`total_area`, '.', ','))) AS `side12_total_area_num`,
  IFNULL(`as12`.`total_area`, 0) AS `side12_total_area_string`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as2`.`total_area`, '.', ','))) AS `side2_total_area_num`,
  IFNULL(`as2`.`total_area`, 0) AS `side2_total_area_string`
FROM ((((((((((((((((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`sp_contract_reasons` `cr`
    ON ((`c`.`id_contract_reason` = `cr`.`id_contract_reason`)))
  LEFT JOIN `mena`.`sp_pre_contract_issued` `spci`
    ON ((`c`.`id_pre_contract_issued` = `spci`.`id_pre_contract_issued`)))
  LEFT JOIN `mena`.`sp_delegate` `sd`
    ON ((`c`.`id_delegate` = `sd`.`id_delegate`)))
  LEFT JOIN `mena`.`apartments` `as1`
    ON ((`c`.`id_apartment_side1` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as2`
    ON ((`c`.`id_apartment_side2` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as12`
    ON ((`c`.`id_apartment_side12` = `as12`.`id_apartment`)))
  LEFT JOIN `mena`.`v_contract_participants_info` `vcpi`
    ON ((`vcpi`.`id_apartment` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `aes1`
    ON ((`aes1`.`id_apartment` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `aes2`
    ON ((`aes2`.`id_apartment` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`v_apartment_residents` `var`
    ON ((`as1`.`id_apartment` = `var`.`id_apartment`)))
  LEFT JOIN `mena`.`v_portion_count_by_id_contract` `vpcc`
    ON ((`c`.`id_contract` = `vpcc`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_delegate_warrant` `vcdw`
    ON ((`c`.`id_contract` = `vcdw`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side1_warrants` `vcs1w`
    ON ((`vcs1w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side2_warrants` `vcs2w`
    ON ((`vcs2w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side12_warrants` `vcs12w`
    ON ((`vcs12w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`sp_apartment_type` `sat1`
    ON ((`as1`.`id_apartment_type` = `sat1`.`id_apartment_type`)))
  LEFT JOIN `mena`.`sp_apartment_type` `sat2`
    ON ((`as2`.`id_apartment_type` = `sat2`.`id_apartment_type`)))
  LEFT JOIN `mena`.`land` `l`
    ON ((`as2`.`id_apartment` = `l`.`id_apartment`)))
WHERE (`c`.`was_deleted` = 0)
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_precontract`
--
CREATE
VIEW v_precontract
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  IF((`c`.`eviction_required` = 1), 'Сторона 2 обязуется снять с регистрационного учета по месту жительства в жилом помещении по адресу: $side2_address$, всех лиц в течение ___ месяцев с даты заключения договора.', 'В аварийном жилом помещении, расположенном по адресу: $side2_address$, (кадастровый номер $side2_inventory_number$), никто не проживает и на регистрационном учете не состоит.') AS `p5_1`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'по адресу: $side1_address$ (кадастровый номер $side1_inventory_number$), общей площадью $side1_total_area_num$ ($side1_total_area_string$) кв. м', 'по адресам:$br$ а) $side1_address$ (кадастровый номер $side1_inventory_number$), общей площадью $side1_total_area_num$ ($side1_total_area_string$) кв. м.; $br$ б) $side12_address$ (кадастровый номер $side12_inventory_number$), общей площадью $side12_total_area_num$ ($side12_total_area_string$) кв. м') AS `p1`,
  (CASE WHEN (`as2`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as2`.`room_count`, 0) > 0), ' и состоит из $side2_room_count$ комнат', '') END) AS `side2_room_postfix`,
  `as2`.`floor` AS `floor`,
  `c`.`id_apartment_side1` AS `id_apartment_side1`,
  `c`.`id_apartment_side2` AS `id_apartment_side2`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельный участок по адресу: $land_adress$ (кадастровый номер $side2land_inventory_number$)') AS `land_postfix`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельный участок по адресу: $land_adress$') AS `land_postfix2`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`l`.`id_street`), ', ', `l`.`house`)) AS `land_adress`,
  `l`.`inventory_number` AS `side2land_inventory_number`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) > 0), ', $contract_registration_date_string$', '_______________201__года') AS `contract_registration_date_string_`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) > 0), ' $contract_registration_date$', '_____________') AS `contract_registration_date_`,
  DATE_FORMAT(`c`.`contract_Registration_date`, '%d.%m.%Y') AS `contract_registration_date`,
  DATE_FORMAT(`c`.`contract_Registration_date`, '%d.%m.%Y') AS `contract_registration_date_string`,
  REPLACE(REPLACE(`cr`.`template`, '@date@', DATE_FORMAT(`c`.`order_date`, '%d.%m.%Y')), '@number@', `c`.`order_number`) AS `contract_reason`,
  `sd`.`fio` AS `delegate_fio`,
  `sd`.`fio` AS `delegate_fio_rod`,
  DATE_FORMAT(`sd`.`birth`, '%d.%m.%Y') AS `delegate_birth`,
  `sd`.`passport_seria` AS `delegate_passport_seria`,
  `sd`.`passport_num` AS `delegate_passport_num`,
  `sd`.`passport_issued` AS `delegate_passport_issued`,
  DATE_FORMAT(`sd`.`passport_isssued_date`, '%d.%m.%Y') AS `delegate_passport_issued_date`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`as1`.`id_street`), ', дом ', `as1`.`house`), IFNULL(CONCAT(', квартира ', `as1`.`flat`), ''), IF((`as1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as1`.`room`), ''))) AS `side1_address`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`as2`.`id_street`), ', дом ', `as2`.`house`), IFNULL(CONCAT(', квартира ', `as2`.`flat`), ''), IF((`as2`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as2`.`room`), ''))) AS `side2_address`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`as12`.`id_street`), ', дом ', `as12`.`house`), IFNULL(CONCAT(', квартира ', `as12`.`flat`), ''), IF((`as12`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as12`.`room`), ''))) AS `side12_address`,
  IF(ISNULL(`as1`.`inventory_number`), '_________________', '$side1_invent_number$') AS `side1_inventory_number`,
  IF(ISNULL(`as2`.`inventory_number`), '_________________', '$side2_invent_number$') AS `side2_inventory_number`,
  IF(ISNULL(`as12`.`inventory_number`), '_________________', '$side12_invent_number$') AS `side12_inventory_number`,
  `as1`.`inventory_number` AS `side1_invent_number`,
  `as2`.`inventory_number` AS `side2_invent_number`,
  `as12`.`inventory_number` AS `side12_invent_number`,
  IFNULL(`as1`.`floor`, 0) AS `side1_floor`,
  IFNULL(`as2`.`floor`, 1) AS `side2_floor`,
  IFNULL(`as1`.`room_count`, 0) AS `side1_room_count`,
  IFNULL(`as2`.`room_count`, 0) AS `side2_room_count`,
  IFNULL(`as12`.`room_count`, 0) AS `side12_room_count`,
  IFNULL(`aes1`.`evaluation_price`, 0) AS `side1_evaluation_price_num`,
  IFNULL(`aes2`.`evaluation_price`, 0) AS `side2_evaluation_price_num`,
  IFNULL(`aes1`.`evaluation_price`, 0) AS `side1_evaluation_price_string`,
  IFNULL(`aes2`.`evaluation_price`, 0) AS `side2_evaluation_price_string`,
  `vcdw`.`delegate_warrant` AS `delegate_warrant`,
  `vcs1w`.`side1_warrants` AS `side1_warrants`,
  IF(ISNULL(`c`.`id_apartment_side12`), '', `vcs12w`.`side12_warrants`) AS `side12_warrants`,
  `vcs2w`.`side2_warrants` AS `side2_warrants`,
  `spci`.`pre_contract_name` AS `pre_contract_name`,
  IFNULL(`l`.`total_area`, 0) AS `land_total_area`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as1`.`total_area`, '.', ','))) AS `side1_total_area_num`,
  IFNULL(`as1`.`total_area`, 0) AS `side1_total_area_string`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as12`.`total_area`, '.', ','))) AS `side12_total_area_num`,
  IFNULL(`as12`.`total_area`, 0) AS `side12_total_area_string`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as2`.`total_area`, '.', ','))) AS `side2_total_area_num`,
  IFNULL(`as2`.`total_area`, 0) AS `side2_total_area_string`
FROM (((((((((((((((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`sp_contract_reasons` `cr`
    ON ((`c`.`id_contract_reason` = `cr`.`id_contract_reason`)))
  LEFT JOIN `mena`.`sp_pre_contract_issued` `spci`
    ON ((`c`.`id_pre_contract_issued` = `spci`.`id_pre_contract_issued`)))
  LEFT JOIN `mena`.`sp_delegate` `sd`
    ON ((`c`.`id_delegate` = `sd`.`id_delegate`)))
  LEFT JOIN `mena`.`apartments` `as1`
    ON ((`c`.`id_apartment_side1` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as2`
    ON ((`c`.`id_apartment_side2` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as12`
    ON ((`c`.`id_apartment_side12` = `as12`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `aes1`
    ON ((`aes1`.`id_apartment` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `aes2`
    ON ((`aes2`.`id_apartment` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`v_apartment_residents` `var`
    ON ((`as1`.`id_apartment` = `var`.`id_apartment`)))
  LEFT JOIN `mena`.`v_portion_count_by_id_contract` `vpcc`
    ON ((`c`.`id_contract` = `vpcc`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_delegate_warrant` `vcdw`
    ON ((`c`.`id_contract` = `vcdw`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side1_warrants` `vcs1w`
    ON ((`vcs1w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side2_warrants` `vcs2w`
    ON ((`vcs2w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side12_warrants` `vcs12w`
    ON ((`vcs12w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`sp_apartment_type` `sat1`
    ON ((`as1`.`id_apartment_type` = `sat1`.`id_apartment_type`)))
  LEFT JOIN `mena`.`sp_apartment_type` `sat2`
    ON ((`as2`.`id_apartment_type` = `sat2`.`id_apartment_type`)))
  LEFT JOIN `mena`.`land` `l`
    ON ((`as2`.`id_apartment` = `l`.`id_apartment`)))
WHERE (`c`.`was_deleted` = 0)
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_portions_evaluation`
--
CREATE
VIEW v_portions_evaluation
AS
SELECT
  `ae`.`id_apartment` AS `id_apartment`,
  `p`.`id_person` AS `id_person`,
  `ae`.`evaluation_number` AS `eval_number`,
  `ae`.`evaluation_price` AS `eval_price`,
  `ae`.`evaluation_date` AS `eval_date`,
  `p`.`portion` AS `portion`,
  IF((`p`.`portion` = '1'), '1', CAST((LEFT(`p`.`portion`, (LOCATE('/', `p`.`portion`) - 1)) / REPLACE(RIGHT(`p`.`portion`, LOCATE('/', `p`.`portion`)), '/', '')) AS decimal(10, 9))) AS `decimal_portion`
FROM (`apartment_evaluations` `ae`
  LEFT JOIN `persons` `p`
    ON ((`ae`.`id_apartment` = `p`.`id_apartment`)));

--
-- Создать представление `v_order_info`
--
CREATE
VIEW v_order_info
AS
SELECT
  CONCAT(CONCAT(IF((`l`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`l`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`l`.`id_street`)), ', ', `l`.`house`)) AS `land_adress`,
  IF(ISNULL(`a1`.`flat`), 'жилого помещения', 'жилого помещения') AS `place1`,
  IF(ISNULL(`a2`.`flat`), 'жилое помещение', 'жилое помещение') AS `place2`,
  `c`.`id_contract` AS `id_contract`,
  DATE_FORMAT(`c`.`order_date`, '%d.%m.%Y') AS `order_date`,
  `c`.`order_number` AS `order_number`,
  DATE_FORMAT(`c`.`agreement_registration_date`, '%d.%m.%Y') AS `agreement_registration_date`,
  CONCAT(CONCAT(IF((`a1`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a1`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a1`.`id_street`)), ', дом ', `a1`.`house`), IF((IFNULL(`a1`.`flat`, '') = ''), '', CONCAT(', квартира ', `a1`.`flat`)), IF((`a1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `a1`.`room`), ''))) AS `side1_address`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), CONCAT(CONCAT(' и жилого помещения, расположенного по адресу: ', IF((`a12`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a12`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a12`.`id_street`)), ', дом ', `a12`.`house`), IF((IFNULL(`a12`.`flat`, '') = ''), '', CONCAT(', квартира ', `a12`.`flat`)), IF((`a12`.`room` = 0), '', IFNULL(CONCAT(', комната ', `a12`.`room`), ''))), ',') AS `side12_address`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), CONCAT(CONCAT(' а) Российская Федерация, ', IF((`a1`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a1`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a1`.`id_street`)), ', дом ', `a1`.`house`), IF((IFNULL(`a1`.`flat`, '') = ''), '', CONCAT(', квартира ', `a1`.`flat`)), IF((`a1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `a1`.`room`), '')), ';$br$'), CONCAT(CONCAT('Российская Федерация, ', IF((`a1`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a1`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a1`.`id_street`)), ', дом ', `a1`.`house`), IF((IFNULL(`a1`.`flat`, '') = ''), '', CONCAT(', квартира ', `a1`.`flat`)), IF((`a1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `a1`.`room`), '')), '')) AS `side1_address2`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), CONCAT(CONCAT(' б) Российская Федерация, ', IF((`a12`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a12`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a12`.`id_street`)), ', дом ', `a12`.`house`), IF((IFNULL(`a12`.`flat`, '') = ''), '', CONCAT(', квартира ', `a12`.`flat`)), IF((`a12`.`room` = 0), '', IFNULL(CONCAT(', комната ', `a12`.`room`), '')), ';'), ', из реестра муниципального имущества города Братска;') AS `side12_address2`,
  CONCAT(CONCAT(IF((`a2`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`a2`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`a2`.`id_street`)), ', дом ', `a2`.`house`), IF((IFNULL(`a2`.`flat`, '') = ''), '', CONCAT(', квартира ', `a2`.`flat`)), IF((`a2`.`room` = 0), '', IFNULL(CONCAT(', комната ', `a2`.`room`), ''))) AS `side2_address`,
  `a1`.`inventory_number` AS `side1_inventory_number`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), CONCAT(' (кадастровый номер', `a12`.`inventory_number`, ')'), '') AS `side12_inventory_number`,
  `a2`.`inventory_number` AS `side2_inventory_number`,
  `a1`.`total_area` AS `side1_total_area_num`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), CONCAT(', общей площадью ', `a12`.`total_area`), '') AS `side12_total_area_num`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), ' ($side12_total_area_string$) кв. м', '') AS `side12_total_area`,
  `a2`.`total_area` AS `side2_total_area_num`,
  IFNULL(`a1`.`total_area`, 0) AS `side1_total_area_string`,
  IFNULL(`a12`.`total_area`, 0) AS `side12_total_area_string`,
  IFNULL(`a2`.`total_area`, 0) AS `side2_total_area_string`,
  IF((IFNULL(`a1`.`living_area`, 0) > 0), ', жилой площадью $side1_living_area_num$ ($side1_living_area_string$) кв. м', '') AS `side1_living_area`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), IF((IFNULL(`a12`.`living_area`, 0) > 0), ', жилой площадью $side12_living_area_num$ ($side12_living_area_string$) кв. м', ''), '') AS `side12_living_area`,
  IF((IFNULL(`a2`.`living_area`, 0) > 0), ', жилой площадью $side2_living_area_num$ ($side2_living_area_string$) кв. м', '') AS `side2_living_area`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`a1`.`living_area`, '.', ','))) AS `side1_living_area_num`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`a12`.`living_area`, '.', ','))), '') AS `side12_living_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`a2`.`living_area`, '.', ','))) AS `side2_living_area_num`,
  IFNULL(`a1`.`living_area`, 0) AS `side1_living_area_string`,
  IFNULL(`a12`.`living_area`, 0) AS `side12_living_area_string`,
  IFNULL(`a2`.`living_area`, 0) AS `side2_living_area_string`,
  IF((IFNULL(`a1`.`room_count`, 0) > 0), ', состоящего из $side1_room_count$ $room_count1$', '') AS `side1_room_counts`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), '', ', принадлежащего на праве собственности муниципальному образованию города Братска') AS `pref_side1`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), CONCAT(IF((IFNULL(`a12`.`room_count`, 0) > 0), ', состоящего из $side12_room_count$ $room_count1$', ''), ', принадлежащих на праве собственности муниципальному образованию города Братска,'), '') AS `side12_room_counts`,
  IF((IFNULL(`a2`.`room_count`, 0) > 0), ', состоящее из $side2_room_count$ $room_count2$', '') AS `side2_room_counts`,
  IFNULL(`a1`.`room_count`, 0) AS `side1_room_count`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), IFNULL(`a12`.`room_count`, 0), '') AS `side12_room_count`,
  IFNULL(`a2`.`room_count`, 0) AS `side2_room_count`,
  IFNULL(`ae1`.`evaluation_price`, 0) AS `side1_evaluation_price`,
  IFNULL(`ae12`.`evaluation_price`, 0) AS `side12_evaluation_price`,
  IFNULL(`ae2`.`evaluation_price`, 0) AS `side2_evaluation_price`,
  IF((IFNULL(`c`.`id_apartment_side12`, 0) > 0), 'исключить из реестра муниципального имущества города Братска жилые помещения, расположенные по следующим адресам:$br$', 'исключить жилое помещение, расположенное по адресу:') AS `point4`,
  `ss`.`post` AS `order_boss_signer_post`,
  CONCAT(CONCAT(`ss`.`family`, ' ', `ss`.`name`), ' ', `ss`.`father`) AS `order_boss_signer_fio`,
  `ss`.`id_signer` AS `order_boss_signer_id`,
  `ss1`.`post` AS `order_commitet_signer_post`,
  CONCAT(CONCAT(`ss1`.`family`, ' ', `ss1`.`name`), ' ', `ss1`.`father`) AS `order_commitet_signer_fio`,
  `ss2`.`post` AS `order_verify_lawer_post`,
  CONCAT(CONCAT(`ss2`.`family`, ' ', `ss2`.`name`), ' ', `ss2`.`father`) AS `order_verify_lawer_fio`,
  `ss3`.`post` AS `order_verify_boss_post`,
  CONCAT(CONCAT(`ss3`.`family`, ' ', `ss3`.`name`), ' ', `ss3`.`father`) AS `order_verify_boss_fio`,
  CONCAT(CONCAT(`ss4`.`family`, ' ', `ss4`.`name`), ' ', `ss4`.`father`) AS `order_worker_fio`,
  `ss4`.`phone` AS `order_worker_phone`,
  YEAR(NOW()) AS `order_year`,
  IF((COUNT(0) > 1), 'им', IF((SUBSTR(`p`.`snp`, (CHAR_LENGTH(`p`.`snp`) - 2), 3) = 'вна'), 'ей', IF((LCASE(SUBSTR(`p`.`snp`, (CHAR_LENGTH(`p`.`snp`) - 3), 4)) = 'кызы'), 'ей', 'ему'))) AS `person_sex`,
  IF((IFNULL(`vpcc`.`Count`, 0) > 0), 'общей долевой собственности', 'собственности') AS `type_of_ownership`,
  IF((IFNULL(`vpcc`.`Count`, 0) > 0), 'заявления', 'заявление') AS `order_plural`,
  `ss1`.`family` AS `represent_surname`,
  IF(ISNULL(`l`.`id_land`), 'принадлежащее', 'принадлежащие') AS `owner_plural`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельный участок, расположенный по адресу: Российская Федерация, $land_adress$') AS `land`,
  IF(ISNULL(`l`.`id_land`), 'принадлежащее', 'принадлежащих') AS `tmpl_owner_plural`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельного участка, расположенного по адресу: Российская Федерация, $land_adress$') AS `tmpl_land`,
  IF(ISNULL(`l`.`id_land`), '', ' (кадастровый номер $land_inventory$)') AS `land_inventory_postfix`,
  `l`.`inventory_number` AS `land_inventory`,
  IF(ISNULL(`l`.`id_land`), '', ', общей площадью $land_area$ ($land_area_txt$) кв. м') AS `land_area_postfix`,
  `l`.`total_area` AS `land_area`,
  `l`.`total_area` AS `land_area_txt`
FROM (((((((((((((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`apartments` `a1`
    ON ((`c`.`id_apartment_side1` = `a1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `a2`
    ON ((`c`.`id_apartment_side2` = `a2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `a12`
    ON ((`c`.`id_apartment_side12` = `a12`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `ae1`
    ON ((`ae1`.`id_apartment` = `a1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `ae2`
    ON ((`ae2`.`id_apartment` = `a2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `ae12`
    ON ((`ae12`.`id_apartment` = `a12`.`id_apartment`)))
  LEFT JOIN `mena`.`document_signers` `ds`
    ON ((`ds`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`sp_signer` `ss`
    ON ((`ds`.`id_order_boss` = `ss`.`id_signer`)))
  LEFT JOIN `mena`.`sp_signer` `ss1`
    ON ((`ds`.`id_order_commitet_signer` = `ss1`.`id_signer`)))
  LEFT JOIN `mena`.`sp_signer` `ss2`
    ON ((`ds`.`id_order_verify_lawer` = `ss2`.`id_signer`)))
  LEFT JOIN `mena`.`sp_signer` `ss3`
    ON ((`ds`.`id_order_verify_boss` = `ss3`.`id_signer`)))
  LEFT JOIN `mena`.`sp_signer` `ss4`
    ON ((`ds`.`id_order_worker` = `ss4`.`id_signer`)))
  LEFT JOIN `mena`.`v_persons` `p`
    ON ((`p`.`id_apartment` = `a2`.`id_apartment`)))
  LEFT JOIN `mena`.`v_portion_count_by_id_contract` `vpcc`
    ON ((`vpcc`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`land` `l`
    ON ((`a2`.`id_apartment` = `l`.`id_apartment`)))
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_contract_info_multi_old`
--
CREATE
VIEW v_contract_info_multi_old
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  IF((`c`.`eviction_required` = 1), 'СТОРОНЫ гарантируют, что $p5_change$ на момент подписания настоящего договора никому не проданы, не заложены, в споре и под арестом не состоят, в аренду не сданы.', 'СТОРОНЫ гарантируют, что $p5_change$ на момент подписания настоящего договора никому не проданы, не заложены, в споре и под арестом не состоят, в аренду не сданы, свободны от любых прав и притязаний со стороны третьих лиц.') AS `p5`,
  IF((`c`.`eviction_required` = 1), 'СТОРОНА 2 обязуется снять с регистрационного учета по месту жительства в жилом помещении по адресу: $b$Российская Федерация, $side2_address$$/b$, всех лиц в течение ___ месяцев с даты заключения договора.', 'В жилом помещении по адресу: $b$Российская Федерация, $side2_address$$/b$, никто не проживает и на регистрационном учете не состоит.') AS `p6`,
  IF((ISNULL(`aes1`.`id_apartment_evaluation`) OR ISNULL(`aes2`.`id_apartment_evaluation`) OR (`c`.`id_apartment_side12` IS NOT NULL)), 'Жилые помещения, подлежащие мене по настоящему договору, признаются равноценными', 'По соглашению СТОРОН жилое помещение по адресу: $b$Российская Федерация, $side1_address$$/b$, оценивается в $side1_evaluation_price_num$ ($side1_evaluation_price_string$) рублей, жилое помещение по адресу: $b$Российская Федерация, $side2_address$$/b$, оценивается в $side2_evaluation_price_num$ ($side2_evaluation_price_string$) рублей. Мена признается равноценной') AS `p3`,
  IF(ISNULL(`l`.`id_land`), IF(((`as1`.`part` = '1') AND (`as2`.`part` = '1')), 'жилых помещений', 'долей в праве общей долевой собственности на квартиры'), '') AS `pole`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'по адресу: $b$$i$Российская Федерация, $side1_address$ (кадастровый номер $side1_inventory_number$)$/i$$/b$, общей площадью $side1_total_area_num$ ($side1_total_area_string$) кв. м$side1_living_area$$side1_room_postfix$', 'по адресам:$br$ а) $b$$i$Российская Федерация, $side1_address$ (кадастровый номер $side1_inventory_number$),$/i$$/b$ общей площадью $side1_total_area_num$ ($side1_total_area_string$) кв. м$side1_living_area$$side1_room_postfix$; $br$ б) $b$$i$Российская Федерация, $side12_address$ (кадастровый номер $side12_inventory_number$),$/i$$/b$ общей площадью $side12_total_area_num$ ($side12_total_area_string$) кв. м$side12_living_area$$side12_room_postfix$') AS `p1`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'Данное жилое помещение является', 'Данные жилые помещения являются ') AS `p1_2`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'по адресу: $b$$i$Российская Федерация, $side1_address$$/i$$/b$', ': $br$ a) $b$$i$Российская Федерация, $side1_address$;$/i$$/b$ $br$ б)$b$$i$ Российская Федерация, $side2_address$$/i$$/b$') AS `act_p1`,
  (CASE WHEN (`as1`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as1`.`room_count`, 0) > 0), ', состоящее из $side1_room_count$ комнат', '') END) AS `side1_room_postfix`,
  (CASE WHEN (`as2`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as2`.`room_count`, 0) > 0), ', состоящее из $side2_room_count$ комнат', '') END) AS `side2_room_postfix`,
  (CASE WHEN (`as12`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as12`.`room_count`, 0) > 0), ', состоящее из $side12_room_count$ комнат', '') END) AS `side12_room_postfix`,
  `c`.`id_apartment_side1` AS `id_apartment_side1`,
  `c`.`id_apartment_side2` AS `id_apartment_side2`,
  IF(ISNULL(`l`.`id_land`), '.', ', и земельный участок по адресу: $b$$i$Российская Федерация, $land_adress$ (кадастровый номер $side2land_inventory_number$), общей площадью $side2land_living_area_num$ ($side2land_living_area_string$) кв. м.$/i$$/b$') AS `land_postfix`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельный участок по адресу: $b$$i$Российская Федерация, $land_adress$$/i$$/b$') AS `land_postfix2`,
  CONCAT(CONCAT(IF((`l`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`l`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`l`.`id_street`)), ', ', `l`.`house`)) AS `land_adress`,
  `l`.`inventory_number` AS `side2land_inventory_number`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`l`.`total_area`, '.', ','))) AS `side2land_living_area_num`,
  IFNULL(`l`.`total_area`, 0) AS `side2land_living_area_string`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) > 0), '$contract_registration_date_string$', '') AS `contract_registration_date_string_`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) = 0), '«___» ___________201__', '') AS `contract_registration_date_string_2`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) > 0), ' $contract_registration_date$', '«___» ___________201__') AS `contract_registration_date_`,
  DATE_FORMAT(`c`.`contract_Registration_date`, '%d.%m.%Y') AS `contract_registration_date`,
  DATE_FORMAT(`c`.`contract_Registration_date`, '%d.%m.%Y') AS `contract_registration_date_string`,
  IF((IFNULL(`c`.`filing_date`, 0) = 0), '_____________', DATE_FORMAT(`c`.`filing_date`, '%d.%m.%Y')) AS `contract_filling_date_string`,
  REPLACE(REPLACE(`cr`.`template`, '@date@', DATE_FORMAT(`c`.`order_date`, '%d.%m.%Y')), '@number@', `c`.`order_number`) AS `contract_reason`,
  IF((IFNULL(`c`.`order_number`, 0) = 0), '«___» _______201__ ', DATE_FORMAT(`c`.`order_date`, '%d.%m.%Y')) AS `order_date`,
  IF((IFNULL(`c`.`order_number`, 0) = 0), '_____', `c`.`order_number`) AS `order_number`,
  `sd`.`fio` AS `delegate_fio`,
  `sd`.`fio` AS `delegate_fio_rod`,
  DATE_FORMAT(`sd`.`birth`, '%d.%m.%Y') AS `delegate_birth`,
  `sd`.`passport_seria` AS `delegate_passport_seria`,
  `sd`.`passport_num` AS `delegate_passport_num`,
  `sd`.`passport_issued` AS `delegate_passport_issued`,
  DATE_FORMAT(`sd`.`passport_isssued_date`, '%d.%m.%Y') AS `delegate_passport_issued_date`,
  GROUP_CONCAT(`vcpi`.`person` SEPARATOR ', ') AS `persons`,
  IF(ISNULL(`c`.`id_apartment_side12`), '$side1_apartment_type_rod$', '$side1_apartment_type_ch$ ') AS `side1_ap_type`,
  IF((`as1`.`part` = '1'), CONCAT(`sat1`.`apartment_type_rod`, ' (далее - жилое помещение)'), CONCAT(`as1`.`part`, ' доли в праве общей долевой собственности на ', `sat1`.`apartment_type_rod`, ' (далее - жилое помещение)')) AS `side1_apartment_type_rod`,
  IF((`as2`.`part` = '1'), CONCAT(`sat2`.`apartment_type_rod`, ' (далее - жилое помещение)'), CONCAT(`as2`.`part`, ' доли в праве общей долевой собственности на ', `sat2`.`apartment_type_rod`, ' (далее - жилое помещение)')) AS `side2_apartment_type_rod`,
  IF((`as1`.`part` = '1'), CONCAT(`sat1`.`apartment_type_plur`, ' (далее - жилые помещения) по адресам'), CONCAT(`as1`.`part`, ' доли в праве общей долевой собственности на ', `sat1`.`apartment_type_plur`, ' (далее - жилые помещения) по адресам')) AS `side1_apartment_type_ch`,
  IF((`as2`.`part` = '1'), IF(ISNULL(`l`.`id_land`), 'Данное жилое помещение принадлежит', 'Данное жилое помещение и земельный участок принадлежат'), CONCAT('В данном жилом помещении ', `as2`.`part`, ' доли принадлежат')) AS `side2_own`,
  IF(ISNULL(`c`.`id_apartment_side12`), '$side1_apartment_type$', '$side12_apartment_type$') AS `p4`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'по адресу: $b$$i$Российская Федерация, $side1_address$,$/i$$/b$ переходит в $type_of_ownership$ $b$$i$$owner_ships$$/i$$/b$', 'по адресам: $br$ а) $b$$i$Российская Федерация, $side1_address$;$/i$$/b$ $br$ б) $b$$i$Российская Федерация, $side12_address$,$/i$$/b$ переходят в $type_of_ownership$ $b$$i$$owner_ships$$/i$$/b$') AS `p4_2`,
  IF((`as1`.`part` = '1'), 'жилое помещение', CONCAT(`as1`.`part`, ' доли в праве общей долевой собственности на квартиру')) AS `side1_apartment_type`,
  IF((`as2`.`part` = '1'), 'жилое помещение', CONCAT(`as2`.`part`, ' доли в праве общей долевой собственности на квартиру')) AS `side2_apartment_type`,
  IF((`as2`.`part` = '1'), 'Жилое помещение', CONCAT(`as2`.`part`, ' доли в праве общей долевой собственности на квартиру')) AS `side2_apartment_type_fc`,
  IF((`as12`.`part` = '1'), 'жилые помещения', CONCAT(`as12`.`part`, ' доли в праве общей долевой собственности на квартиру')) AS `side12_apartment_type`,
  IF(((`as1`.`part` = '1') AND (`as2`.`part` = '1')), ' обмениваемые жилые помещения', 'меняемые доли в праве общей долевой собственности на жилые помещения') AS `p5_change`,
  CONCAT(CONCAT(IF((`as1`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as1`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as1`.`id_street`)), ', дом ', `as1`.`house`), IFNULL(CONCAT(', квартира ', `as1`.`flat`), ''), IF((`as1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as1`.`room`), ''))) AS `side1_address`,
  CONCAT(CONCAT(IF((`as2`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as2`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as2`.`id_street`)), ', дом ', `as2`.`house`), IFNULL(CONCAT(', квартира ', `as2`.`flat`), ''), IF((`as2`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as2`.`room`), ''))) AS `side2_address`,
  CONCAT(CONCAT(IF((`as12`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as12`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as12`.`id_street`)), ', дом ', `as12`.`house`), IFNULL(CONCAT(', квартира ', `as12`.`flat`), ''), IF((`as12`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as12`.`room`), ''))) AS `side12_address`,
  `as1`.`inventory_number` AS `side1_inventory_number`,
  `as2`.`inventory_number` AS `side2_inventory_number`,
  `as12`.`inventory_number` AS `side12_inventory_number`,
  IFNULL(`as1`.`floor`, 0) AS `side1_floor`,
  IFNULL(`as2`.`floor`, 0) AS `side2_floor`,
  IFNULL(`as1`.`room_count`, 0) AS `side1_room_count`,
  IFNULL(`as2`.`room_count`, 0) AS `side2_room_count`,
  IFNULL(`as12`.`room_count`, 0) AS `side12_room_count`,
  IF((IFNULL(`as1`.`living_area`, 0) > 0), ', жилой площадью $side1_living_area_num$ ($side1_living_area_string$) кв. м.', '') AS `side1_living_area`,
  IF((IFNULL(`as2`.`living_area`, 0) > 0), ', жилой площадью $side2_living_area_num$ ($side2_living_area_string$) кв. м.', '') AS `side2_living_area`,
  IF((IFNULL(`as12`.`living_area`, 0) > 0), ', жилой площадью $side12_living_area_num$ ($side12_living_area_string$) кв. м.', '') AS `side12_living_area`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as1`.`living_area`, '.', ','))) AS `side1_living_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as12`.`living_area`, '.', ','))) AS `side12_living_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as2`.`living_area`, '.', ','))) AS `side2_living_area_num`,
  IFNULL(`as1`.`living_area`, 0) AS `side1_living_area_string`,
  IFNULL(`as12`.`living_area`, 0) AS `side12_living_area_string`,
  IFNULL(`as2`.`living_area`, 0) AS `side2_living_area_string`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as1`.`total_area`, '.', ','))) AS `side1_total_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as12`.`total_area`, '.', ','))) AS `side12_total_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as2`.`total_area`, '.', ','))) AS `side2_total_area_num`,
  IFNULL(`as1`.`total_area`, 0) AS `side1_total_area_string`,
  IFNULL(`as12`.`total_area`, 0) AS `side12_total_area_string`,
  IFNULL(`as2`.`total_area`, 0) AS `side2_total_area_string`,
  IFNULL(`aes1`.`evaluation_price`, 0) AS `side1_evaluation_price_num`,
  IFNULL(`aes2`.`evaluation_price`, 0) AS `side2_evaluation_price_num`,
  IFNULL(`aes1`.`evaluation_price`, 0) AS `side1_evaluation_price_string`,
  IFNULL(`aes2`.`evaluation_price`, 0) AS `side2_evaluation_price_string`,
  IF(ISNULL(`var`.`apartment_residents`), 'никто не проживает и на регистрационном учете не состоит', 'проживает и состоит на регистрационном учете') AS `side1_has_reg_persons`,
  CONCAT(' ', `var`.`apartment_residents`) AS `side1_reg_persons`,
  IF((IFNULL(`vpcc`.`Count`, 0) > 0), 'общую долевую собственность', 'собственность') AS `type_of_ownership`,
  `vcdw`.`delegate_warrant` AS `delegate_warrant`,
  `vcs1w`.`side1_warrants` AS `side1_warrants`,
  IF(ISNULL(`c`.`id_apartment_side12`), '', `vcs12w`.`side12_warrants`) AS `side12_warrants`,
  `vcs2w`.`side2_warrants` AS `side2_warrants`,
  `spci`.`pre_contract_name` AS `pre_contract_name`,
  IFNULL(`l`.`total_area`, 0) AS `land_total_area`
FROM ((((((((((((((((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`sp_contract_reasons` `cr`
    ON ((`c`.`id_contract_reason` = `cr`.`id_contract_reason`)))
  LEFT JOIN `mena`.`sp_pre_contract_issued` `spci`
    ON ((`c`.`id_pre_contract_issued` = `spci`.`id_pre_contract_issued`)))
  LEFT JOIN `mena`.`sp_delegate` `sd`
    ON ((`c`.`id_delegate` = `sd`.`id_delegate`)))
  LEFT JOIN `mena`.`apartments` `as1`
    ON ((`c`.`id_apartment_side1` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as2`
    ON ((`c`.`id_apartment_side2` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as12`
    ON ((`c`.`id_apartment_side12` = `as12`.`id_apartment`)))
  LEFT JOIN `mena`.`v_contract_participants_info` `vcpi`
    ON ((`vcpi`.`id_apartment` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `aes1`
    ON ((`aes1`.`id_apartment` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `aes2`
    ON ((`aes2`.`id_apartment` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`v_apartment_residents` `var`
    ON ((`as1`.`id_apartment` = `var`.`id_apartment`)))
  LEFT JOIN `mena`.`v_portion_count_by_id_contract` `vpcc`
    ON ((`c`.`id_contract` = `vpcc`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_delegate_warrant` `vcdw`
    ON ((`c`.`id_contract` = `vcdw`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side1_warrants` `vcs1w`
    ON ((`vcs1w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side2_warrants` `vcs2w`
    ON ((`vcs2w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side12_warrants` `vcs12w`
    ON ((`vcs12w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`sp_apartment_type` `sat1`
    ON ((`as1`.`id_apartment_type` = `sat1`.`id_apartment_type`)))
  LEFT JOIN `mena`.`sp_apartment_type` `sat2`
    ON ((`as2`.`id_apartment_type` = `sat2`.`id_apartment_type`)))
  LEFT JOIN `mena`.`land` `l`
    ON ((`as2`.`id_apartment` = `l`.`id_apartment`)))
WHERE (`c`.`was_deleted` = 0)
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_contract_info_multi`
--
CREATE
VIEW v_contract_info_multi
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  IF((`c`.`eviction_required` = 1), 'СТОРОНЫ гарантируют, что $p5_change$ на момент подписания настоящего договора никому не проданы, не заложены, в споре и под арестом не состоят, в аренду не сданы.', 'СТОРОНЫ гарантируют, что $p5_change$ на момент подписания настоящего договора никому не проданы, не заложены, в споре и под арестом не состоят, в аренду не сданы, свободны от любых прав и притязаний со стороны третьих лиц.') AS `p5`,
  IF((`c`.`eviction_required` = 1), 'СТОРОНА 2 обязуется снять с регистрационного учета по месту жительства в жилом помещении по адресу: $b$Российская Федерация, $side2_address$$/b$, всех лиц в течение 15 календарных дней с даты заключения договора.', 'В жилом помещении по адресу: $b$Российская Федерация, $side2_address$$/b$, никто не проживает и на регистрационном учете не состоит.') AS `p6`,
  IF((ISNULL(`aes1`.`id_apartment_evaluation`) OR ISNULL(`aes2`.`id_apartment_evaluation`) OR (`c`.`id_apartment_side12` IS NOT NULL)), 'Жилые помещения, подлежащие мене по настоящему договору, признаются равноценными', 'По соглашению СТОРОН жилое помещение по адресу: $b$Российская Федерация, $side1_address$$/b$, оценивается в $side1_evaluation_price_num$ ($side1_evaluation_price_string$) рублей, жилое помещение по адресу: $b$Российская Федерация, $side2_address$$/b$, оценивается в $side2_evaluation_price_num$ ($side2_evaluation_price_string$) рублей. Мена признается равноценной') AS `p3`,
  IF(ISNULL(`l`.`id_land`), IF(((`as1`.`part` = '1') AND (`as2`.`part` = '1')), 'жилых помещений', 'долей в праве общей долевой собственности на квартиры'), '') AS `pole`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'по адресу: $b$$i$Российская Федерация, $side1_address$ (кадастровый номер $side1_inventory_number$)$/i$$/b$, общей площадью $side1_total_area_num$ ($side1_total_area_string$) кв. м$side1_living_area$$side1_room_postfix$', 'по адресам:$br$ а) $b$$i$Российская Федерация, $side1_address$ (кадастровый номер $side1_inventory_number$),$/i$$/b$ общей площадью $side1_total_area_num$ ($side1_total_area_string$) кв. м$side1_living_area$$side1_room_postfix$; $br$ б) $b$$i$Российская Федерация, $side12_address$ (кадастровый номер $side12_inventory_number$),$/i$$/b$ общей площадью $side12_total_area_num$ ($side12_total_area_string$) кв. м$side12_living_area$$side12_room_postfix$') AS `p1`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'Данное жилое помещение является', 'Данные жилые помещения являются ') AS `p1_2`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'по адресу: $b$$i$Российская Федерация, $side1_address$$/i$$/b$', ': $br$ a) $b$$i$Российская Федерация, $side1_address$;$/i$$/b$ $br$ б)$b$$i$ Российская Федерация, $side2_address$$/i$$/b$') AS `act_p1`,
  (CASE WHEN (`as1`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as1`.`room_count`, 0) > 0), ', состоящее из $side1_room_count$ комнат', '') END) AS `side1_room_postfix`,
  (CASE WHEN (`as2`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as2`.`room_count`, 0) > 0), ', состоящее из $side2_room_count$ комнат', '') END) AS `side2_room_postfix`,
  (CASE WHEN (`as12`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as12`.`room_count`, 0) > 0), ', состоящее из $side12_room_count$ комнат', '') END) AS `side12_room_postfix`,
  `c`.`id_apartment_side1` AS `id_apartment_side1`,
  `c`.`id_apartment_side2` AS `id_apartment_side2`,
  IF(ISNULL(`l`.`id_land`), '.', ', и земельный участок по адресу: $b$$i$Российская Федерация, $land_adress$ (кадастровый номер $side2land_inventory_number$), общей площадью $side2land_living_area_num$ ($side2land_living_area_string$) кв. м.$/i$$/b$') AS `land_postfix`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельный участок по адресу: $b$$i$Российская Федерация, $land_adress$$/i$$/b$') AS `land_postfix2`,
  CONCAT(CONCAT(IF((`l`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`l`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`l`.`id_street`)), ', ', `l`.`house`)) AS `land_adress`,
  `l`.`inventory_number` AS `side2land_inventory_number`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`l`.`total_area`, '.', ','))) AS `side2land_living_area_num`,
  IFNULL(`l`.`total_area`, 0) AS `side2land_living_area_string`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) > 0), '$contract_registration_date_string$', '') AS `contract_registration_date_string_`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) = 0), '«___» ___________201__', '') AS `contract_registration_date_string_2`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) > 0), ' $contract_registration_date$', '«___» ___________201__') AS `contract_registration_date_`,
  DATE_FORMAT(`c`.`contract_Registration_date`, '%d.%m.%Y') AS `contract_registration_date`,
  DATE_FORMAT(`c`.`contract_Registration_date`, '%d.%m.%Y') AS `contract_registration_date_string`,
  IF((IFNULL(`c`.`filing_date`, 0) = 0), '_____________', DATE_FORMAT(`c`.`filing_date`, '%d.%m.%Y')) AS `contract_filling_date_string`,
  IF((IFNULL(`c`.`filing_date`, 0) = 0), '_____________', DATE_FORMAT(`c`.`filing_date`, '%d.%m.%Y')) AS `contract_filling_date`,
  REPLACE(REPLACE(`cr`.`template`, '@date@', DATE_FORMAT(`c`.`order_date`, '%d.%m.%Y')), '@number@', `c`.`order_number`) AS `contract_reason`,
  IF((IFNULL(`c`.`order_number`, 0) = 0), '«___» _______201__ ', DATE_FORMAT(`c`.`order_date`, '%d.%m.%Y')) AS `order_date`,
  IF((IFNULL(`c`.`order_number`, 0) = 0), '_____', `c`.`order_number`) AS `order_number`,
  `sd`.`fio` AS `delegate_fio`,
  `sd`.`fio` AS `delegate_fio_rod`,
  DATE_FORMAT(`sd`.`birth`, '%d.%m.%Y') AS `delegate_birth`,
  `sd`.`passport_seria` AS `delegate_passport_seria`,
  `sd`.`passport_num` AS `delegate_passport_num`,
  `sd`.`passport_issued` AS `delegate_passport_issued`,
  DATE_FORMAT(`sd`.`passport_isssued_date`, '%d.%m.%Y') AS `delegate_passport_issued_date`,
  IF(ISNULL(`c`.`id_apartment_side12`), '$side1_apartment_type_rod$', '$side1_apartment_type_ch$ ') AS `side1_ap_type`,
  IF((`as1`.`part` = '1'), CONCAT(`sat1`.`apartment_type_rod`, ' (далее - жилое помещение)'), CONCAT(`as1`.`part`, ' доли в праве общей долевой собственности на ', `sat1`.`apartment_type_rod`, ' (далее - жилое помещение)')) AS `side1_apartment_type_rod`,
  IF((`as2`.`part` = '1'), CONCAT(`sat2`.`apartment_type_rod`, ' (далее - жилое помещение)'), CONCAT(`as2`.`part`, ' доли в праве общей долевой собственности на ', `sat2`.`apartment_type_rod`, ' (далее - жилое помещение)')) AS `side2_apartment_type_rod`,
  IF((`as1`.`part` = '1'), CONCAT(`sat1`.`apartment_type_plur`, ' (далее - жилые помещения) по адресам'), CONCAT(`as1`.`part`, ' доли в праве общей долевой собственности на ', `sat1`.`apartment_type_plur`, ' (далее - жилые помещения) по адресам')) AS `side1_apartment_type_ch`,
  IF((`as2`.`part` = '1'), IF(ISNULL(`l`.`id_land`), 'Данное жилое помещение принадлежит', 'Данное жилое помещение и земельный участок принадлежат'), CONCAT('В данном жилом помещении ', `as2`.`part`, ' доли принадлежат')) AS `side2_own`,
  IF(ISNULL(`c`.`id_apartment_side12`), '$side1_apartment_type$', '$side12_apartment_type$') AS `p4`,
  IF(ISNULL(`c`.`id_apartment_side12`), 'по адресу: $b$$i$Российская Федерация, $side1_address$,$/i$$/b$ переходит в $type_of_ownership$ $b$$i$$owner_ships$$/i$$/b$', 'по адресам: $br$ а) $b$$i$Российская Федерация, $side1_address$;$/i$$/b$ $br$ б) $b$$i$Российская Федерация, $side12_address$,$/i$$/b$ переходят в $type_of_ownership$ $b$$i$$owner_ships$$/i$$/b$') AS `p4_2`,
  IF((`as1`.`part` = '1'), 'жилое помещение', CONCAT(`as1`.`part`, ' доли в праве общей долевой собственности на квартиру')) AS `side1_apartment_type`,
  IF((`as2`.`part` = '1'), 'жилое помещение', CONCAT(`as2`.`part`, ' доли в праве общей долевой собственности на квартиру')) AS `side2_apartment_type`,
  IF((`as2`.`part` = '1'), 'Жилое помещение', CONCAT(`as2`.`part`, ' доли в праве общей долевой собственности на квартиру')) AS `side2_apartment_type_fc`,
  IF((`as12`.`part` = '1'), 'жилые помещения', CONCAT(`as12`.`part`, ' доли в праве общей долевой собственности на квартиру')) AS `side12_apartment_type`,
  IF(((`as1`.`part` = '1') AND (`as2`.`part` = '1')), ' обмениваемые жилые помещения', 'меняемые доли в праве общей долевой собственности на жилые помещения') AS `p5_change`,
  CONCAT(CONCAT(IF((`as1`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as1`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as1`.`id_street`)), ', дом ', `as1`.`house`), IFNULL(CONCAT(', квартира ', `as1`.`flat`), ''), IF((`as1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as1`.`room`), ''))) AS `side1_address`,
  CONCAT(CONCAT(IF((`as2`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as2`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as2`.`id_street`)), ', дом ', `as2`.`house`), IFNULL(CONCAT(', квартира ', `as2`.`flat`), ''), IF((`as2`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as2`.`room`), ''))) AS `side2_address`,
  CONCAT(CONCAT(IF((`as12`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as12`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as12`.`id_street`)), ', дом ', `as12`.`house`), IFNULL(CONCAT(', квартира ', `as12`.`flat`), ''), IF((`as12`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as12`.`room`), ''))) AS `side12_address`,
  `as1`.`inventory_number` AS `side1_inventory_number`,
  `as2`.`inventory_number` AS `side2_inventory_number`,
  `as12`.`inventory_number` AS `side12_inventory_number`,
  IFNULL(`as1`.`floor`, 0) AS `side1_floor`,
  IFNULL(`as2`.`floor`, 0) AS `side2_floor`,
  IFNULL(`as1`.`room_count`, 0) AS `side1_room_count`,
  IFNULL(`as2`.`room_count`, 0) AS `side2_room_count`,
  IFNULL(`as12`.`room_count`, 0) AS `side12_room_count`,
  IF((IFNULL(`as1`.`living_area`, 0) > 0), ', жилой площадью $side1_living_area_num$ ($side1_living_area_string$) кв. м.', '') AS `side1_living_area`,
  IF((IFNULL(`as2`.`living_area`, 0) > 0), ', жилой площадью $side2_living_area_num$ ($side2_living_area_string$) кв. м.', '') AS `side2_living_area`,
  IF((IFNULL(`as12`.`living_area`, 0) > 0), ', жилой площадью $side12_living_area_num$ ($side12_living_area_string$) кв. м.', '') AS `side12_living_area`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as1`.`living_area`, '.', ','))) AS `side1_living_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as12`.`living_area`, '.', ','))) AS `side12_living_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as2`.`living_area`, '.', ','))) AS `side2_living_area_num`,
  IFNULL(`as1`.`living_area`, 0) AS `side1_living_area_string`,
  IFNULL(`as12`.`living_area`, 0) AS `side12_living_area_string`,
  IFNULL(`as2`.`living_area`, 0) AS `side2_living_area_string`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as1`.`total_area`, '.', ','))) AS `side1_total_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as12`.`total_area`, '.', ','))) AS `side12_total_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as2`.`total_area`, '.', ','))) AS `side2_total_area_num`,
  IFNULL(`as1`.`total_area`, 0) AS `side1_total_area_string`,
  IFNULL(`as12`.`total_area`, 0) AS `side12_total_area_string`,
  IFNULL(`as2`.`total_area`, 0) AS `side2_total_area_string`,
  IFNULL(`aes1`.`evaluation_price`, 0) AS `side1_evaluation_price_num`,
  IFNULL(`aes2`.`evaluation_price`, 0) AS `side2_evaluation_price_num`,
  IFNULL(`aes1`.`evaluation_price`, 0) AS `side1_evaluation_price_string`,
  IFNULL(`aes2`.`evaluation_price`, 0) AS `side2_evaluation_price_string`,
  IF(ISNULL(`var`.`apartment_residents`), 'никто не проживает и на регистрационном учете не состоит', 'проживает и состоит на регистрационном учете') AS `side1_has_reg_persons`,
  CONCAT(' ', `var`.`apartment_residents`) AS `side1_reg_persons`,
  IF((IFNULL(`vpcc`.`Count`, 0) > 0), 'общую долевую собственность', 'собственность') AS `type_of_ownership`,
  `vcdw`.`delegate_warrant` AS `delegate_warrant`,
  `vcs1w`.`side1_warrants` AS `side1_warrants`,
  IF(ISNULL(`c`.`id_apartment_side12`), '', `vcs12w`.`side12_warrants`) AS `side12_warrants`,
  `vcs2w`.`side2_warrants` AS `side2_warrants`,
  `spci`.`pre_contract_name` AS `pre_contract_name`,
  IFNULL(`l`.`total_area`, 0) AS `land_total_area`
FROM (((((((((((((((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`sp_contract_reasons` `cr`
    ON ((`c`.`id_contract_reason` = `cr`.`id_contract_reason`)))
  LEFT JOIN `mena`.`sp_pre_contract_issued` `spci`
    ON ((`c`.`id_pre_contract_issued` = `spci`.`id_pre_contract_issued`)))
  LEFT JOIN `mena`.`sp_delegate` `sd`
    ON ((`c`.`id_delegate` = `sd`.`id_delegate`)))
  LEFT JOIN `mena`.`apartments` `as1`
    ON ((`c`.`id_apartment_side1` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as2`
    ON ((`c`.`id_apartment_side2` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as12`
    ON ((`c`.`id_apartment_side12` = `as12`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `aes1`
    ON ((`aes1`.`id_apartment` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `aes2`
    ON ((`aes2`.`id_apartment` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`v_apartment_residents` `var`
    ON ((`as1`.`id_apartment` = `var`.`id_apartment`)))
  LEFT JOIN `mena`.`v_portion_count_by_id_contract` `vpcc`
    ON ((`c`.`id_contract` = `vpcc`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_delegate_warrant` `vcdw`
    ON ((`c`.`id_contract` = `vcdw`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side1_warrants` `vcs1w`
    ON ((`vcs1w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side2_warrants` `vcs2w`
    ON ((`vcs2w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side12_warrants` `vcs12w`
    ON ((`vcs12w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`sp_apartment_type` `sat1`
    ON ((`as1`.`id_apartment_type` = `sat1`.`id_apartment_type`)))
  LEFT JOIN `mena`.`sp_apartment_type` `sat2`
    ON ((`as2`.`id_apartment_type` = `sat2`.`id_apartment_type`)))
  LEFT JOIN `mena`.`land` `l`
    ON ((`as2`.`id_apartment` = `l`.`id_apartment`)))
WHERE (`c`.`was_deleted` = 0)
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_contract_info`
--
CREATE
VIEW v_contract_info
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  IF((`c`.`eviction_required` = 1), 'СТОРОНЫ гарантируют, что $p5_change$ на момент подписания настоящего договора никому не проданы, не заложены, в споре и под арестом не состоят, в аренду не сданы.', 'СТОРОНЫ гарантируют, что $p5_change$ на момент подписания настоящего договора никому не проданы, не заложены, в споре и под арестом не состоят, в аренду не сданы, свободны от любых прав и притязаний со стороны третьих лиц.') AS `p5`,
  IF((`c`.`eviction_required` = 1), 'СТОРОНА 2 обязуется снять с регистрационного учета по месту жительства в жилом помещении по адресу: $b$Российская Федерация, $side2_address$$/b$, всех лиц в течение ___ месяцев с даты заключения договора.', 'В жилом помещении по адресу: $b$Российская Федерация, $side2_address$$/b$, никто не проживает и на регистрационном учете не состоит.') AS `p6`,
  IF((ISNULL(`aes1`.`id_apartment_evaluation`) OR ISNULL(`aes2`.`id_apartment_evaluation`)), 'Жилые помещения, подлежащие мене по настоящему договору, признаются равноценными', 'По соглашению СТОРОН жилое помещение по адресу: $b$Российская Федерация, $side1_address$$/b$, оценивается в $side1_evaluation_price_num$ ($side1_evaluation_price_string$) рублей, жилое помещение по адресу: $b$Российская Федерация, $side2_address$$/b$, оценивается в $side2_evaluation_price_num$ ($side2_evaluation_price_string$) рублей. Мена признается равноценной') AS `p3`,
  IF(ISNULL(`l`.`id_land`), IF(((`as1`.`part` = '1') AND (`as2`.`part` = '1')), 'жилых помещений', 'долей в праве общей долевой собственности на квартиры'), '') AS `pole`,
  (CASE WHEN (`as1`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as1`.`room_count`, 0) > 0), ', состоящее из $side1_room_count$ комнат', '') END) AS `side1_room_postfix`,
  (CASE WHEN (`as2`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as2`.`room_count`, 0) > 0), ', состоящее из $side2_room_count$ комнат', '') END) AS `side2_room_postfix`,
  (CASE WHEN (`as12`.`id_apartment_type` = 4) THEN '' ELSE IF((IFNULL(`as12`.`room_count`, 0) > 0), ', состоящее из $side12_room_count$ комнат', '') END) AS `side12_room_postfix`,
  `c`.`id_apartment_side1` AS `id_apartment_side1`,
  `c`.`id_apartment_side2` AS `id_apartment_side2`,
  IF(ISNULL(`l`.`id_land`), '.', ', и земельный участок по адресу: $b$$i$Российская Федерация, $land_adress$ (кадастровый номер $side2land_inventory_number$), общей площадью $side2land_living_area_num$ ($side2land_living_area_string$) кв. м.$/i$$/b$') AS `land_postfix`,
  IF(ISNULL(`l`.`id_land`), '', ', и земельный участок по адресу: $b$$i$Российская Федерация, $land_adress$$/i$$/b$') AS `land_postfix2`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`l`.`id_street`), ', ', `l`.`house`)) AS `land_adress`,
  `l`.`inventory_number` AS `side2land_inventory_number`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`l`.`total_area`, '.', ','))) AS `side2land_living_area_num`,
  IFNULL(`l`.`total_area`, 0) AS `side2land_living_area_string`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) > 0), ', $contract_registration_date_string$', '') AS `contract_registration_date_string_`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) = 0), '«___» ___________201__года', '') AS `contract_registration_date_string_2`,
  IF((IFNULL(`c`.`contract_Registration_date`, 0) > 0), ' $contract_registration_date$', '_____________') AS `contract_registration_date_`,
  DATE_FORMAT(`c`.`contract_Registration_date`, '%d.%m.%Y') AS `contract_registration_date`,
  DATE_FORMAT(`c`.`contract_Registration_date`, '%d.%m.%Y') AS `contract_registration_date_string`,
  REPLACE(REPLACE(`cr`.`template`, '@date@', DATE_FORMAT(`c`.`order_date`, '%d.%m.%Y')), '@number@', `c`.`order_number`) AS `contract_reason`,
  `sd`.`fio` AS `delegate_fio`,
  `sd`.`fio` AS `delegate_fio_rod`,
  DATE_FORMAT(`sd`.`birth`, '%d.%m.%Y') AS `delegate_birth`,
  `sd`.`passport_seria` AS `delegate_passport_seria`,
  `sd`.`passport_num` AS `delegate_passport_num`,
  `sd`.`passport_issued` AS `delegate_passport_issued`,
  DATE_FORMAT(`sd`.`passport_isssued_date`, '%d.%m.%Y') AS `delegate_passport_issued_date`,
  GROUP_CONCAT(`vcpi`.`person` SEPARATOR ', ') AS `persons`,
  IF((`as1`.`part` = '1'), CONCAT(`sat1`.`apartment_type_rod`, ' (далее - жилое помещение)'), CONCAT(`as1`.`part`, ' доли в праве общей долевой собственности на ', `sat1`.`apartment_type_rod`, ' (далее - жилое помещение)')) AS `side1_apartment_type_rod`,
  IF((`as2`.`part` = '1'), CONCAT(`sat2`.`apartment_type_rod`, ' (далее - жилое помещение)'), CONCAT(`as2`.`part`, ' доли в праве общей долевой собственности на ', `sat2`.`apartment_type_rod`, ' (далее - жилое помещение)')) AS `side2_apartment_type_rod`,
  IF((`as1`.`part` = '1'), CONCAT(`sat1`.`apartment_type_plur`, ' (далее - жилые помещения) по адресам'), CONCAT(`as1`.`part`, ' доли в праве общей долевой собственности на ', `sat1`.`apartment_type_plur`, ' (далее - жилые помещения) по адресам')) AS `side1_apartment_type_ch`,
  IF((`as2`.`part` = '1'), IF(ISNULL(`l`.`id_land`), 'Данное жилое помещение принадлежит', 'Данное жилое помещение и земельный участок принадлежат'), CONCAT('В данном жилом помещении ', `as2`.`part`, ' доли принадлежат')) AS `side2_own`,
  IF((`as1`.`part` = '1'), 'жилое помещение', CONCAT(`as1`.`part`, ' доли в праве общей долевой собственности на квартиру')) AS `side1_apartment_type`,
  IF((`as2`.`part` = '1'), 'жилое помещение', CONCAT(`as2`.`part`, ' доли в праве общей долевой собственности на квартиру')) AS `side2_apartment_type`,
  IF((`as2`.`part` = '1'), 'Жилое помещение', CONCAT(`as2`.`part`, ' доли в праве общей долевой собственности на квартиру')) AS `side2_apartment_type_fc`,
  IF((`as12`.`part` = '1'), 'жилые помещения', CONCAT(`as12`.`part`, ' доли в праве общей долевой собственности на квартиру')) AS `side12_apartment_type`,
  IF(((`as1`.`part` = '1') AND (`as2`.`part` = '1')), ' обмениваемые жилые помещения', 'меняемые доли в праве общей долевой собственности на жилые помещения') AS `p5_change`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`as1`.`id_street`), ', дом ', `as1`.`house`), IFNULL(CONCAT(', квартира ', `as1`.`flat`), ''), IF((`as1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as1`.`room`), ''))) AS `side1_address`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`as2`.`id_street`), ', дом ', `as2`.`house`), IFNULL(CONCAT(', квартира ', `as2`.`flat`), ''), IF((`as2`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as2`.`room`), ''))) AS `side2_address`,
  CONCAT(CONCAT(`kladr`.`get_full_street_for_kladr`(`as12`.`id_street`), ', дом ', `as12`.`house`), IFNULL(CONCAT(', квартира ', `as12`.`flat`), ''), IF((`as12`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as12`.`room`), ''))) AS `side12_address`,
  `as1`.`inventory_number` AS `side1_inventory_number`,
  `as2`.`inventory_number` AS `side2_inventory_number`,
  `as12`.`inventory_number` AS `side12_inventory_number`,
  IFNULL(`as1`.`floor`, 0) AS `side1_floor`,
  IFNULL(`as2`.`floor`, 0) AS `side2_floor`,
  IFNULL(`as1`.`room_count`, 0) AS `side1_room_count`,
  IFNULL(`as2`.`room_count`, 0) AS `side2_room_count`,
  IFNULL(`as12`.`room_count`, 0) AS `side12_room_count`,
  IF((IFNULL(`as1`.`living_area`, 0) > 0), ', жилой площадью $side1_living_area_num$ ($side1_living_area_string$) кв. м.', '') AS `side1_living_area`,
  IF((IFNULL(`as2`.`living_area`, 0) > 0), ', жилой площадью $side2_living_area_num$ ($side2_living_area_string$) кв. м.', '') AS `side2_living_area`,
  IF((IFNULL(`as12`.`living_area`, 0) > 0), ', жилой площадью $side12_living_area_num$ ($side12_living_area_string$) кв. м.', '') AS `side12_living_area`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as1`.`living_area`, '.', ','))) AS `side1_living_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as12`.`living_area`, '.', ','))) AS `side12_living_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as2`.`living_area`, '.', ','))) AS `side2_living_area_num`,
  IFNULL(`as1`.`living_area`, 0) AS `side1_living_area_string`,
  IFNULL(`as12`.`living_area`, 0) AS `side12_living_area_string`,
  IFNULL(`as2`.`living_area`, 0) AS `side2_living_area_string`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as1`.`total_area`, '.', ','))) AS `side1_total_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as12`.`total_area`, '.', ','))) AS `side12_total_area_num`,
  TRIM(TRAILING ',' FROM TRIM(TRAILING '0' FROM REPLACE(`as2`.`total_area`, '.', ','))) AS `side2_total_area_num`,
  IFNULL(`as1`.`total_area`, 0) AS `side1_total_area_string`,
  IFNULL(`as12`.`total_area`, 0) AS `side12_total_area_string`,
  IFNULL(`as2`.`total_area`, 0) AS `side2_total_area_string`,
  IFNULL(`aes1`.`evaluation_price`, 0) AS `side1_evaluation_price_num`,
  IFNULL(`aes2`.`evaluation_price`, 0) AS `side2_evaluation_price_num`,
  IFNULL(`aes1`.`evaluation_price`, 0) AS `side1_evaluation_price_string`,
  IFNULL(`aes2`.`evaluation_price`, 0) AS `side2_evaluation_price_string`,
  IF(ISNULL(`var`.`apartment_residents`), 'никто не проживает и на регистрационном учете не состоит', 'проживает и состоит на регистрационном учете') AS `side1_has_reg_persons`,
  CONCAT(' ', `var`.`apartment_residents`) AS `side1_reg_persons`,
  IF((IFNULL(`vpcc`.`Count`, 0) > 0), 'общую долевую собственность', 'собственность') AS `type_of_ownership`,
  `vcdw`.`delegate_warrant` AS `delegate_warrant`,
  `vcs1w`.`side1_warrants` AS `side1_warrants`,
  `vcs12w`.`side12_warrants` AS `side12_warrants`,
  `vcs2w`.`side2_warrants` AS `side2_warrants`,
  `spci`.`pre_contract_name` AS `pre_contract_name`,
  IFNULL(`l`.`total_area`, 0) AS `land_total_area`
FROM ((((((((((((((((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`sp_contract_reasons` `cr`
    ON ((`c`.`id_contract_reason` = `cr`.`id_contract_reason`)))
  LEFT JOIN `mena`.`sp_pre_contract_issued` `spci`
    ON ((`c`.`id_pre_contract_issued` = `spci`.`id_pre_contract_issued`)))
  LEFT JOIN `mena`.`sp_delegate` `sd`
    ON ((`c`.`id_delegate` = `sd`.`id_delegate`)))
  LEFT JOIN `mena`.`apartments` `as1`
    ON ((`c`.`id_apartment_side1` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as2`
    ON ((`c`.`id_apartment_side2` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as12`
    ON ((`c`.`id_apartment_side12` = `as12`.`id_apartment`)))
  LEFT JOIN `mena`.`v_contract_participants_info` `vcpi`
    ON ((`vcpi`.`id_apartment` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `aes1`
    ON ((`aes1`.`id_apartment` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `aes2`
    ON ((`aes2`.`id_apartment` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`v_apartment_residents` `var`
    ON ((`as1`.`id_apartment` = `var`.`id_apartment`)))
  LEFT JOIN `mena`.`v_portion_count_by_id_contract` `vpcc`
    ON ((`c`.`id_contract` = `vpcc`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_delegate_warrant` `vcdw`
    ON ((`c`.`id_contract` = `vcdw`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side1_warrants` `vcs1w`
    ON ((`vcs1w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side2_warrants` `vcs2w`
    ON ((`vcs2w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side12_warrants` `vcs12w`
    ON ((`vcs12w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`sp_apartment_type` `sat1`
    ON ((`as1`.`id_apartment_type` = `sat1`.`id_apartment_type`)))
  LEFT JOIN `mena`.`sp_apartment_type` `sat2`
    ON ((`as2`.`id_apartment_type` = `sat2`.`id_apartment_type`)))
  LEFT JOIN `mena`.`land` `l`
    ON ((`as2`.`id_apartment` = `l`.`id_apartment`)))
WHERE (`c`.`was_deleted` = 0)
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_agreement_info`
--
CREATE
VIEW v_agreement_info
AS
SELECT
  `c`.`id_contract` AS `id_contract`,
  DATE_FORMAT(`c`.`agreement_registration_date`, '%d.%m.%Y') AS `agreement_registration_date`,
  `c`.`pre_contract_number` AS `pre_contract_number`,
  DATE_FORMAT(`c`.`pre_contract_date`, '%d.%m.%Y') AS `pre_contract_date`,
  GROUP_CONCAT(`vapi`.`person` SEPARATOR ', ') AS `persons`,
  CONCAT(CONCAT(IF((`as1`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as1`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as1`.`id_street`)), ', дом ', `as1`.`house`), ' квартира ', `as1`.`flat`, IF((`as1`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as1`.`room`), ''))) AS `side1_address`,
  CONCAT(CONCAT(IF((`as2`.`id_street` = 38000005006000200), REPLACE(`kladr`.`get_full_street_for_kladr`(`as2`.`id_street`), '20', 'XX'), `kladr`.`get_full_street_for_kladr`(`as2`.`id_street`)), ', дом ', `as2`.`house`), ' квартира ', `as2`.`flat`, IF((`as2`.`room` = 0), '', IFNULL(CONCAT(', комната ', `as2`.`room`), ''))) AS `side2_address`,
  IF((IFNULL(`as2`.`room_count`, 0) > 0), 'состоящей из $side2_room_count$ комнат(ы),', '') AS `side2_room_counts`,
  IF((IFNULL(`as1`.`room_count`, 0) > 0), 'состоящая из $side1_room_count$ комнат(ы),', '') AS `side1_room_counts`,
  IF((IFNULL(`as1`.`living_area`, 0) > 0), 'жилой площадью $side1_living_area$ кв. м, ', '') AS `side1_living_area2`,
  IF((IFNULL(`as2`.`living_area`, 0) > 0), 'жилой площадью $side2_living_area$ кв. м, ', '') AS `side2_living_area2`,
  IFNULL(`as1`.`room_count`, 0) AS `side1_room_count`,
  IFNULL(`as2`.`room_count`, 0) AS `side2_room_count`,
  IFNULL(`as1`.`total_area`, 0) AS `side1_total_area`,
  IFNULL(`as2`.`total_area`, 0) AS `side2_total_area`,
  IFNULL(`as1`.`living_area`, 0) AS `side1_living_area`,
  IFNULL(`as2`.`living_area`, 0) AS `side2_living_area`,
  IFNULL(`aes1`.`evaluation_price`, 0) AS `side1_evaluation_price`,
  IFNULL(`aes2`.`evaluation_price`, 0) AS `side2_evaluation_price`,
  `aes1`.`evaluation_number` AS `side1_evaluation_number`,
  `aes2`.`evaluation_number` AS `side2_evaluation_number`,
  `se1`.`evaluator_name` AS `side1_evaluator`,
  `se2`.`evaluator_name` AS `side2_evaluator`,
  `se1`.`evaluator_boss` AS `side1_evaluator_boss`,
  `se2`.`evaluator_boss` AS `side2_evaluator_boss`,
  `ss`.`short_post_2` AS `agreement_signer_post`,
  CONCAT(CONCAT(`ss`.`family`, ' ', `ss`.`name`), ' ', `ss`.`father`) AS `agreement_signer_fio`,
  CONCAT('«___» ___________ ', DATE_FORMAT(NOW(), '%Y'), ' года') AS `sign_date`,
  IF((IFNULL(`vpcc`.`Count`, 0) > 0), 'общей долевой собственностью', 'собственностью') AS `type_of_ownership`,
  `ss`.`post_genitive` AS `represent_post_genitive`,
  CONCAT(CONCAT(`ss`.`family`, ' ', `ss`.`name`), ' ', `ss`.`father`) AS `represent_fio_genitive`,
  `vcs2w`.`side2_warrants` AS `apartment_warrants`,
  `spci`.`pre_contract_name` AS `pre_contract_name`
FROM (((((((((((((`mena`.`contracts` `c`
  LEFT JOIN `mena`.`sp_contract_reasons` `cr`
    ON ((`c`.`id_contract_reason` = `cr`.`id_contract_reason`)))
  LEFT JOIN `mena`.`apartments` `as1`
    ON ((`c`.`id_apartment_side1` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartments` `as2`
    ON ((`c`.`id_apartment_side2` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`v_agreement_participants_info` `vapi`
    ON ((`vapi`.`id_apartment` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `aes1`
    ON ((`aes1`.`id_apartment` = `as1`.`id_apartment`)))
  LEFT JOIN `mena`.`apartment_evaluations` `aes2`
    ON ((`aes2`.`id_apartment` = `as2`.`id_apartment`)))
  LEFT JOIN `mena`.`sp_evaluator` `se1`
    ON ((`se1`.`id_evaluator` = `aes1`.`id_evaluator`)))
  LEFT JOIN `mena`.`sp_evaluator` `se2`
    ON ((`se2`.`id_evaluator` = `aes2`.`id_evaluator`)))
  LEFT JOIN `mena`.`document_signers` `ds`
    ON ((`c`.`id_contract` = `ds`.`id_contract`)))
  LEFT JOIN `mena`.`sp_signer` `ss`
    ON ((`ds`.`id_agreement_signer` = `ss`.`id_signer`)))
  LEFT JOIN `mena`.`v_portion_count_by_id_contract` `vpcc`
    ON ((`vpcc`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`v_contract_side2_warrants` `vcs2w`
    ON ((`vcs2w`.`id_contract` = `c`.`id_contract`)))
  LEFT JOIN `mena`.`sp_pre_contract_issued` `spci`
    ON ((`c`.`id_pre_contract_issued` = `spci`.`id_pre_contract_issued`)))
GROUP BY `c`.`id_contract`;

--
-- Создать представление `v_kladr_streets`
--
CREATE
VIEW v_kladr_streets
AS
SELECT
  `sn`.`CODE` AS `id_street`,
  IF((`sn`.`CODE` = '38000005006000200'), 'жилрайон. Порожский, ул. XX Партсъезда', IF((`sn`.`CODE` LIKE '38000005%'), SUBSTR(`sn`.`street_name`, (CHAR_LENGTH('Иркутская обл., г. Братск, ') + 1)), `sn`.`street_name`)) AS `street_name`,
  IF((`sn`.`CODE` = '38000005006000200'), 'жилой район Порожский, улица XX Партсъезда', REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(IF((`sn`.`CODE` LIKE '38000005%'), SUBSTR(`sn`.`street_name`, (CHAR_LENGTH('Иркутская обл., г. Братск, ') + 1)), `sn`.`street_name`), 'пер.', 'переулок'), 'мкр.', 'микрорайон'), 'ул.', 'улица'), 'б-р.', 'бульвар'), 'пр-кт.', 'проспект'), 'проезд.', 'проезд'), 'обл.', 'область'), 'г.', 'город'), 'жилрайон.', 'жилой район'), 'кв-л.', 'квартал')) AS `street_long`
FROM `kladr`.`street_name` `sn`
WHERE ((`sn`.`CODE` LIKE '38000005%')
OR (`sn`.`CODE` IN ('38001002000020700', '38000015000001300', '38000015000012800', '38000015000012900', '38001002000006800')))
ORDER BY (NOT ((`sn`.`CODE` LIKE '38000005%'))), IF((`sn`.`CODE` = '38000005006000200'), 'жилрайон. Порожский, ул. XX Партсъезда', IF((`sn`.`CODE` LIKE '38000005%'), SUBSTR(`sn`.`street_name`, (CHAR_LENGTH('Иркутская обл., г. Братск, ') + 1)), `sn`.`street_name`));

--
-- Создать таблицу `sp_warrant_template_copy`
--
CREATE TABLE IF NOT EXISTS sp_warrant_template_copy (
  id_warrant_template int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  warrant_template_name varchar(2000) DEFAULT NULL,
  warrant_template varchar(2000) DEFAULT NULL,
  id_warrant_template_type smallint(6) DEFAULT NULL,
  wasDeleted tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_warrant_template)
)
ENGINE = INNODB,
AUTO_INCREMENT = 156,
AVG_ROW_LENGTH = 835,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `sp_warant_template_type`
--
CREATE TABLE IF NOT EXISTS sp_warant_template_type (
  id_warant_template_type tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT,
  warant_template_type varchar(60) NOT NULL,
  PRIMARY KEY (id_warant_template_type)
)
ENGINE = INNODB,
AUTO_INCREMENT = 12,
AVG_ROW_LENGTH = 1638,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'типы шаблонов доверенностей';

--
-- Создать таблицу `sp_signer_proxy`
--
CREATE TABLE IF NOT EXISTS sp_signer_proxy (
  id_signer_proxy int(11) NOT NULL AUTO_INCREMENT,
  id_signer int(11) DEFAULT NULL,
  birth date DEFAULT NULL,
  born_place varchar(255) DEFAULT NULL,
  citizen varchar(255) DEFAULT NULL,
  document_seria varchar(8) DEFAULT NULL,
  document_number varchar(8) DEFAULT NULL,
  document varchar(255) DEFAULT NULL,
  document_issued varchar(255) DEFAULT NULL,
  document_date date DEFAULT NULL,
  document_issuer_code varchar(7) DEFAULT NULL,
  address varchar(255) DEFAULT NULL,
  phone varchar(11) DEFAULT NULL,
  email varchar(50) DEFAULT NULL,
  proxy varchar(255) DEFAULT NULL,
  snils varchar(14) DEFAULT NULL,
  PRIMARY KEY (id_signer_proxy)
)
ENGINE = INNODB,
AUTO_INCREMENT = 2,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `sp_room_count`
--
CREATE TABLE IF NOT EXISTS sp_room_count (
  id_room_count tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT,
  room_count_skl varchar(20) NOT NULL,
  PRIMARY KEY (id_room_count)
)
ENGINE = INNODB,
AUTO_INCREMENT = 7,
AVG_ROW_LENGTH = 2730,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `sp_reason`
--
CREATE TABLE IF NOT EXISTS sp_reason (
  id_reason int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  reason_name varchar(512) NOT NULL DEFAULT '',
  reason_template varchar(512) NOT NULL DEFAULT '',
  PRIMARY KEY (id_reason)
)
ENGINE = INNODB,
AUTO_INCREMENT = 6,
AVG_ROW_LENGTH = 3276,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Основание владения';

--
-- Создать таблицу `sp_osnovanie`
--
CREATE TABLE IF NOT EXISTS sp_osnovanie (
  id_osnovanie int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  osnovanie varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  PRIMARY KEY (id_osnovanie)
)
ENGINE = INNODB,
AUTO_INCREMENT = 8,
AVG_ROW_LENGTH = 3276,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Основание проживания';

--
-- Создать таблицу `sp_contractor`
--
CREATE TABLE IF NOT EXISTS sp_contractor (
  id_contractor tinyint(4) NOT NULL AUTO_INCREMENT,
  contractor varchar(20) NOT NULL,
  contractor_short varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (id_contractor)
)
ENGINE = INNODB,
AUTO_INCREMENT = 3,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'справочник участник/неучастник';

--
-- Создать таблицу `proxy`
--
CREATE TABLE IF NOT EXISTS proxy (
  id_proxy int(11) NOT NULL AUTO_INCREMENT,
  start_date date DEFAULT NULL,
  end_date date DEFAULT NULL,
  id_trustee int(11) DEFAULT NULL,
  proxy varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_proxy)
)
ENGINE = INNODB,
AUTO_INCREMENT = 10,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `print_param_values`
--
CREATE TABLE IF NOT EXISTS print_param_values (
  id_print_params int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  print_param_name varchar(50) NOT NULL,
  print_param_value varchar(50) NOT NULL,
  id_contract int(11) UNSIGNED NOT NULL,
  id_print_type tinyint(3) UNSIGNED NOT NULL,
  PRIMARY KEY (id_print_params)
)
ENGINE = INNODB,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `print_params`
--
CREATE TABLE IF NOT EXISTS print_params (
  id_print_param int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  param_name varchar(50) DEFAULT NULL,
  param_type varchar(255) DEFAULT NULL,
  getter varchar(8000) DEFAULT NULL,
  setter varchar(8000) DEFAULT NULL,
  pos_left smallint(5) UNSIGNED NOT NULL DEFAULT 10,
  pos_top smallint(5) UNSIGNED DEFAULT NULL,
  width smallint(5) UNSIGNED NOT NULL DEFAULT 100,
  param_caption varchar(255) NOT NULL DEFAULT 'Параметр',
  PRIMARY KEY (id_print_param)
)
ENGINE = INNODB,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `operations_log`
--
CREATE TABLE IF NOT EXISTS operations_log (
  id_operation int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  user_name varchar(50) NOT NULL,
  operation_time datetime NOT NULL,
  operation varchar(2048) NOT NULL,
  parameters varchar(2048) NOT NULL,
  PRIMARY KEY (id_operation)
)
ENGINE = INNODB,
AUTO_INCREMENT = 141912,
AVG_ROW_LENGTH = 371,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `info_mena2`
--
CREATE TABLE IF NOT EXISTS info_mena2 (
  `№ п/п` int(11) DEFAULT NULL,
  `Месторасположения: г. Братск, улица` varchar(255) DEFAULT NULL,
  `№ жилого дома (жд)` varchar(255) DEFAULT NULL,
  `№ жилого помещения (жп)` varchar(255) DEFAULT NULL,
  `Год ввода в
эксплуатацию` varchar(255) DEFAULT NULL,
  `Тип здания
(деревянное, щитовое)` varchar(255) DEFAULT NULL,
  `Занимаемая Sобщ.жп,м2` double(10, 3) DEFAULT NULL,
  `К-во чел, проживающих в ЖП` varchar(255) DEFAULT NULL,
  `Ф.И.О.` varchar(255) DEFAULT NULL,
  `Тех.состояние
(аварийное), А` varchar(255) DEFAULT NULL,
  `Предоставляемая Sобщ,м2` varchar(255) DEFAULT NULL,
  `Предлагаемый 
адрес переселения: г. Братск, улица` varchar(255) DEFAULT NULL,
  `№жд` varchar(255) DEFAULT NULL,
  `№жп` varchar(255) DEFAULT NULL,
  `Предоставление жп (по мене -мена, по соц.найму -с/найм)` varchar(255) DEFAULT NULL,
  `Основание проживания (регистрация в Росреестре, № от ДСН)` varchar(255) DEFAULT NULL,
  `Дата совершения сделки по столбцу 12` varchar(255) DEFAULT NULL,
  `Договор о порядке и условиях переселения (основание для прож` varchar(255) DEFAULT NULL,
  `Дата  рег/договора по Договору о порядке` varchar(255) DEFAULT NULL,
  `Дата проекта  договора мены` varchar(255) DEFAULT NULL,
  `Договор мены подписан гражданами (подписан/не подписан)` varchar(255) DEFAULT NULL,
  `Дата подачи заявления на мену` varchar(255) DEFAULT NULL,
  `переданы в КГС (договор+акт)` varchar(255) DEFAULT NULL,
  `Ограничение на сделки (по столбцу 12)` varchar(255) DEFAULT NULL,
  `№ постановления о мене` varchar(255) DEFAULT NULL,
  `Дата постановления о мене` varchar(255) DEFAULT NULL,
  `Примечание 1` varchar(255) DEFAULT NULL,
  `Инфо по направленным уведомлениям` varchar(255) DEFAULT NULL,
  `Телефоны граждан` varchar(255) DEFAULT NULL,
  `Информация по снятию с регистрации по старому адресу` varchar(255) DEFAULT NULL,
  `Дата заявки на оценку МЖП для мены` varchar(255) DEFAULT NULL,
  `Информация по оценке` varchar(255) DEFAULT NULL,
  `Дата изготовления ОК оценки МЖП` varchar(255) DEFAULT NULL,
  `Дата заселения в новостройку` varchar(255) DEFAULT NULL,
  `Подготовлены проекты исков, иск есть` varchar(255) DEFAULT NULL,
  `Иски поданы в суд КУМИ` varchar(255) DEFAULT NULL,
  `Иски поданы в суд пр/упр` varchar(255) DEFAULT NULL,
  `Основание проживания (регистрация в Росреестре, № от ДСН)1` varchar(255) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 539,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `info_mena`
--
CREATE TABLE IF NOT EXISTS info_mena (
  `№PP` int(11) DEFAULT NULL,
  street varchar(255) DEFAULT NULL,
  house varchar(5) DEFAULT NULL,
  flat varchar(10) DEFAULT NULL,
  godVvod varchar(5) DEFAULT NULL,
  typeZdanie varchar(5) DEFAULT NULL,
  t_area1 double DEFAULT NULL,
  cntCivil int(11) DEFAULT NULL,
  FIO varchar(255) DEFAULT NULL,
  tehsost varchar(255) DEFAULT NULL,
  t_area2 double DEFAULT NULL,
  street_mun varchar(255) DEFAULT NULL,
  house_mun varchar(5) DEFAULT NULL,
  flat_mun varchar(10) DEFAULT NULL,
  id_predost tinyint(3) DEFAULT NULL,
  osnovanie varchar(255) DEFAULT NULL,
  dateOsnov varchar(255) DEFAULT NULL,
  dogPor varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateDogPor date DEFAULT NULL,
  dateMena varchar(255) DEFAULT NULL,
  dogMena varchar(255) DEFAULT NULL,
  datePodMena varchar(255) DEFAULT NULL,
  id_copy int(11) DEFAULT NULL,
  ogranichenie varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  Npostanovl varchar(255) DEFAULT NULL,
  datePost varchar(255) DEFAULT NULL,
  primechanie varchar(2000) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateUvedom varchar(255) DEFAULT NULL,
  phoneCivil varchar(500) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  InfoSnyatUchet varchar(500) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateEvualation date DEFAULT NULL,
  infoEvualation varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateEvualDone date DEFAULT NULL,
  dateZaselenie date DEFAULT NULL,
  proIsk varchar(255) DEFAULT NULL,
  iskSudKumi varchar(255) DEFAULT NULL,
  iskSudPr varchar(255) DEFAULT NULL,
  id_osnovanie varchar(255) DEFAULT NULL,
  id_street varchar(17) DEFAULT NULL,
  id_street1 varchar(17) DEFAULT NULL,
  id_apart int(11) DEFAULT NULL,
  id_apart1 int(11) DEFAULT NULL,
  id_contract int(11) DEFAULT NULL,
  id_addit int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  predost varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_addit)
)
ENGINE = INNODB,
AUTO_INCREMENT = 487,
AVG_ROW_LENGTH = 505,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
ROW_FORMAT = DYNAMIC;

--
-- Создать таблицу `info_2017`
--
CREATE TABLE IF NOT EXISTS info_2017 (
  street1 varchar(255) DEFAULT NULL,
  house1 varchar(10) DEFAULT NULL,
  flat1 varchar(10) DEFAULT NULL,
  totalS1 varchar(10) DEFAULT NULL,
  count varchar(10) DEFAULT NULL,
  FIO varchar(255) DEFAULT NULL,
  totalSap varchar(10) DEFAULT NULL,
  street2 varchar(255) DEFAULT NULL,
  house2 varchar(10) DEFAULT NULL,
  flat2 varchar(10) DEFAULT NULL,
  predost varchar(10) DEFAULT NULL,
  osnov varchar(255) DEFAULT NULL,
  contract varchar(255) DEFAULT NULL,
  limited varchar(255) DEFAULT NULL,
  dateRequest varchar(50) DEFAULT NULL,
  dateReady varchar(50) DEFAULT NULL,
  dateNotify varchar(50) DEFAULT NULL,
  Info varchar(255) DEFAULT NULL,
  Warrant varchar(1000) DEFAULT NULL,
  id_apartment_side1 varchar(17) DEFAULT NULL,
  id_apartment_side2 varchar(17) DEFAULT NULL,
  id_contract int(11) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 415,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `info2_copy`
--
CREATE TABLE IF NOT EXISTS info2_copy (
  `п/п` varchar(255) DEFAULT NULL,
  `Месторасположения: г. Братск, улица` varchar(255) DEFAULT NULL,
  `№дома` varchar(255) DEFAULT NULL,
  `№жп` varchar(255) DEFAULT NULL,
  `Год ввода в
эксплуатацию` varchar(255) DEFAULT NULL,
  `Тип здания
(деревянное, щитовое)` varchar(255) DEFAULT NULL,
  `Занимаемая Sобщ,м2` varchar(255) DEFAULT NULL,
  `К-во чел, проживающих в ЖП` varchar(255) DEFAULT NULL,
  `Ф.И.О.` varchar(255) DEFAULT NULL,
  `Тех.состояние
(аварийное), А` varchar(255) DEFAULT NULL,
  `Предоставляемая Sобщ,м2` varchar(255) DEFAULT NULL,
  `Предполагаемый 
адрес переселения: г. Братск, улица` varchar(255) DEFAULT NULL,
  `№дома1` varchar(255) DEFAULT NULL,
  `№жп1` varchar(255) DEFAULT NULL,
  id_contract int(11) DEFAULT NULL,
  `Способ предоставления жп (по мене -мена, по соц.найму -с/най` varchar(255) DEFAULT NULL,
  `Основание проживания (регистрация в Росреестре, № от ДСН)` varchar(255) DEFAULT NULL,
  `Дата  по столбцу 12` date DEFAULT NULL,
  `Договор о порядке и условиях переселения (основание проживан` varchar(255) DEFAULT NULL,
  `Дата  по столбцу 14` date DEFAULT NULL,
  `копии переданы в КГС (договор+акт)` varchar(255) DEFAULT NULL,
  `Ограничение на сделки (по столбцу 12)` varchar(255) DEFAULT NULL,
  `Примечание 1` varchar(2000) DEFAULT NULL,
  `Примечание 2` varchar(2000) DEFAULT NULL,
  `Телефоны граждан` varchar(500) DEFAULT NULL,
  `Информация по снятию с регистрации по старому адресу` varchar(255) DEFAULT NULL,
  `Дата заявки на оценку МЖП для мены` date DEFAULT NULL,
  `Информация по оценке` varchar(255) DEFAULT NULL,
  `Дата изготовления ОК оценки МЖП (по столбцу 20)` date DEFAULT NULL,
  `Дата заселения в новостройку` date DEFAULT NULL,
  `№ постановления о мене` varchar(255) DEFAULT NULL,
  `Дата постановления о мене` varchar(255) DEFAULT NULL,
  id_street varchar(17) DEFAULT NULL,
  id_apart int(11) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `info2`
--
CREATE TABLE IF NOT EXISTS info2 (
  `п/п` varchar(255) DEFAULT NULL,
  `Месторасположения: г. Братск, улица` varchar(255) DEFAULT NULL,
  `№дома` varchar(255) DEFAULT NULL,
  `№жп` varchar(255) DEFAULT NULL,
  `Год ввода в
эксплуатацию` varchar(255) DEFAULT NULL,
  `Тип здания
(деревянное, щитовое)` varchar(255) DEFAULT NULL,
  `Занимаемая Sобщ,м2` varchar(255) DEFAULT NULL,
  `К-во чел, проживающих в ЖП` varchar(255) DEFAULT NULL,
  `Ф.И.О.` varchar(255) DEFAULT NULL,
  `Тех.состояние
(аварийное), А` varchar(255) DEFAULT NULL,
  `Предоставляемая Sобщ,м2` varchar(255) DEFAULT NULL,
  `Предполагаемый 
адрес переселения: г. Братск, улица` varchar(255) DEFAULT NULL,
  `№дома1` varchar(255) DEFAULT NULL,
  `№жп1` varchar(255) DEFAULT NULL,
  id_contract int(11) DEFAULT NULL,
  `Способ предоставления жп (по мене -мена, по соц.найму -с/най` tinyint(3) DEFAULT NULL,
  `Основание проживания (регистрация в Росреестре, № от ДСН)` varchar(255) DEFAULT NULL,
  `Дата  по столбцу 12` date DEFAULT NULL,
  `Договор о порядке и условиях переселения (основание проживан` varchar(255) DEFAULT NULL,
  `Дата  по столбцу 14` date DEFAULT NULL,
  `копии переданы в КГС (договор+акт)` int(11) DEFAULT NULL,
  `Ограничение на сделки (по столбцу 12)` varchar(255) DEFAULT NULL,
  `Примечание 1` varchar(2000) DEFAULT NULL,
  `Примечание 2` varchar(2000) DEFAULT NULL,
  `Телефоны граждан` varchar(500) DEFAULT NULL,
  `Информация по снятию с регистрации по старому адресу` varchar(255) DEFAULT NULL,
  `Дата заявки на оценку МЖП для мены` date DEFAULT NULL,
  `Информация по оценке` varchar(255) DEFAULT NULL,
  `Дата изготовления ОК оценки МЖП (по столбцу 20)` date DEFAULT NULL,
  `Дата заселения в новостройку` date DEFAULT NULL,
  `№ постановления о мене` varchar(255) DEFAULT NULL,
  `Дата постановления о мене` varchar(255) DEFAULT NULL,
  id_street varchar(17) DEFAULT NULL,
  id_apart int(11) DEFAULT NULL,
  id_street2 varchar(17) DEFAULT NULL,
  adress2 varchar(255) DEFAULT NULL
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

--
-- Создать таблицу `contracts_2203`
--
CREATE TABLE IF NOT EXISTS contracts_2203 (
  id_contract int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_delegate tinyint(4) UNSIGNED NOT NULL DEFAULT 1,
  id_executor tinyint(3) UNSIGNED NOT NULL DEFAULT 3,
  id_apartment_side1 int(11) UNSIGNED DEFAULT NULL,
  id_apartment_side2 int(11) UNSIGNED DEFAULT NULL,
  pre_contract_date datetime DEFAULT NULL,
  id_pre_contract_issued tinyint(4) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'кто выдает предварительные договора',
  id_contract_reason int(11) NOT NULL DEFAULT 1,
  contract_Registration_date datetime DEFAULT NULL,
  agreement_registration_date datetime DEFAULT NULL,
  id_agreement_represent int(11) UNSIGNED DEFAULT NULL,
  pre_contract_number varchar(20) DEFAULT NULL,
  order_number varchar(20) DEFAULT NULL,
  order_date datetime DEFAULT NULL,
  was_deleted tinyint(1) NOT NULL DEFAULT 0,
  last_change_date datetime NOT NULL DEFAULT '1986-11-15 00:00:00',
  last_change_user varchar(50) NOT NULL DEFAULT 'bad_user',
  filing_date datetime DEFAULT NULL COMMENT 'дата подачи заявления',
  eviction_required tinyint(1) DEFAULT 0,
  PRIMARY KEY (id_contract)
)
ENGINE = INNODB,
AUTO_INCREMENT = 918,
AVG_ROW_LENGTH = 250,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Договора';

--
-- Создать индекс `IDX_contracts` для объекта типа таблица `contracts_2203`
--
ALTER TABLE contracts_2203
ADD INDEX IDX_contracts (id_apartment_side1, id_apartment_side2);

--
-- Создать таблицу `connections`
--
CREATE TABLE IF NOT EXISTS connections (
  id_connection int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  user_name varchar(50) NOT NULL,
  action_date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  action tinyint(1) NOT NULL COMMENT '1-вход; 0-выход',
  PRIMARY KEY (id_connection)
)
ENGINE = INNODB,
AUTO_INCREMENT = 22048,
AVG_ROW_LENGTH = 46,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'История соединений клиентов';

--
-- Создать таблицу `apartment_redemption`
--
CREATE TABLE IF NOT EXISTS apartment_redemption (
  id_apartment_redemption int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_apartment int(11) UNSIGNED NOT NULL,
  date_redemption datetime DEFAULT NULL,
  was_deleted int(1) DEFAULT 0,
  PRIMARY KEY (id_apartment_redemption)
)
ENGINE = INNODB,
AUTO_INCREMENT = 455,
AVG_ROW_LENGTH = 41,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Выкупная информация';

--
-- Создать таблицу `additional_a`
--
CREATE TABLE IF NOT EXISTS additional_a (
  id_addit int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_contract int(11) UNSIGNED NOT NULL,
  id_predost tinyint(3) UNSIGNED NOT NULL,
  id_osnovanie varchar(255) DEFAULT NULL,
  dateOsnov varchar(255) DEFAULT NULL,
  dogPor varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateDogPor date DEFAULT NULL,
  id_copy int(11) DEFAULT NULL,
  ogranichenie varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  primechanie varchar(2000) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateUvedom varchar(255) DEFAULT NULL,
  phoneCivil varchar(500) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  infoSnyatUchet varchar(500) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateEvualation date DEFAULT NULL,
  infoEvualation varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateEvualDone date DEFAULT NULL,
  dateZaselenie date DEFAULT NULL,
  id_street varchar(17) DEFAULT NULL,
  id_apart int(11) DEFAULT NULL,
  house varchar(5) DEFAULT NULL,
  flat varchar(10) DEFAULT NULL,
  cntCivil int(11) DEFAULT NULL,
  FIO varchar(255) DEFAULT NULL,
  street1 varchar(255) DEFAULT NULL,
  house1 varchar(5) DEFAULT NULL,
  flat1 varchar(10) DEFAULT NULL,
  t_area2 double(10, 3) DEFAULT NULL,
  t_area1 double(10, 3) DEFAULT NULL,
  `№PP` int(11) DEFAULT NULL,
  id_street1 varchar(17) DEFAULT NULL,
  id_apart1 int(11) DEFAULT NULL,
  PRIMARY KEY (id_addit)
)
ENGINE = INNODB,
AUTO_INCREMENT = 532,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Дополнительная информация',
ROW_FORMAT = DYNAMIC;

--
-- Создать таблицу `additional_1501_f`
--
CREATE TABLE IF NOT EXISTS additional_1501_f (
  id_addit int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  id_contract int(11) UNSIGNED NOT NULL,
  id_predost tinyint(3) UNSIGNED NOT NULL,
  id_osnovanie varchar(255) DEFAULT NULL,
  dateOsnov varchar(255) DEFAULT NULL,
  dogPor varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateDogPor date DEFAULT NULL,
  id_copy int(11) DEFAULT NULL,
  ogranichenie varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  primechanie varchar(2000) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateUvedom varchar(255) DEFAULT NULL,
  phoneCivil varchar(500) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  infoSnyatUchet varchar(500) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateEvualation date DEFAULT NULL,
  infoEvualation varchar(255) CHARACTER SET cp1251 COLLATE cp1251_general_ci DEFAULT NULL,
  dateEvualDone date DEFAULT NULL,
  dateZaselenie date DEFAULT NULL,
  id_street varchar(17) DEFAULT NULL,
  id_apart int(11) DEFAULT NULL,
  house varchar(5) DEFAULT NULL,
  flat varchar(10) DEFAULT NULL,
  cntCivil int(11) DEFAULT NULL,
  FIO varchar(255) DEFAULT NULL,
  street1 varchar(255) DEFAULT NULL,
  house1 varchar(5) DEFAULT NULL,
  flat1 varchar(10) DEFAULT NULL,
  t_area2 double(10, 3) DEFAULT NULL,
  t_area1 double(10, 3) DEFAULT NULL,
  `№PP` int(11) DEFAULT NULL,
  id_street1 varchar(17) DEFAULT NULL,
  id_apart1 int(11) DEFAULT NULL,
  PRIMARY KEY (id_addit)
)
ENGINE = INNODB,
AUTO_INCREMENT = 532,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8,
COLLATE utf8_general_ci,
COMMENT = 'Дополнительная информация',
ROW_FORMAT = DYNAMIC;

--
-- Создать таблицу `acl_users`
--
CREATE TABLE IF NOT EXISTS acl_users (
  id_user int(11) NOT NULL AUTO_INCREMENT,
  user_name varchar(255) NOT NULL,
  password varchar(255) DEFAULT NULL,
  PRIMARY KEY (id_user)
)
ENGINE = INNODB,
AUTO_INCREMENT = 111,
AVG_ROW_LENGTH = 16384,
CHARACTER SET utf8,
COLLATE utf8_general_ci;

DELIMITER $$

--
-- Создать функцию `get_warrant_for_person`
--
CREATE FUNCTION get_warrant_for_person (par_id_warrant int)
RETURNS varchar(255) CHARSET utf8
BEGIN
  DECLARE res varchar(255);
  SET res = (SELECT
      CONCAT('доверенность ', IFNULL(CONCAT('№ ', wp.warrant_number, ' '), ''), IFNULL(CONCAT('от ', DATE_FORMAT(wp.warrant_date, '%d.%m.%Y'), ' '), ''), IFNULL(CONCAT('в лице ', wp.warrant_fio), ''))
    FROM warrant_person wp
    WHERE wp.id_warrant_person = par_id_warrant LIMIT 1);
  RETURN res;

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