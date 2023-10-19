--
-- Скрипт сгенерирован Devart dbForge Studio for SQL Server, Версия 5.5.327.0
-- Домашняя страница продукта: http://www.devart.com/ru/dbforge/sql/studio
-- Дата скрипта: 19.10.2023 16:49:26
-- Версия сервера: 10.50.6220
--



USE MSZ
GO

IF DB_NAME() <> N'MSZ' SET NOEXEC ON
GO

--
-- Создать таблицу [dbo].[Mszs]
--
PRINT (N'Создать таблицу [dbo].[Mszs]')
GO
CREATE TABLE dbo.Mszs (
  Id int IDENTITY,
  Name nvarchar(max) NOT NULL,
  Guid nvarchar(max) NOT NULL,
  NextRevisionId int NULL,
  PreviousRevisionId int NULL,
  CreatedDate datetime2 NOT NULL DEFAULT ('0001-01-01T00:00:00.0000000'),
  Creator nvarchar(max) NOT NULL DEFAULT (N''),
  PreviousGuid nvarchar(max) NULL,
  Inactive bit NOT NULL DEFAULT (0),
  CONSTRAINT PK_Mszs PRIMARY KEY CLUSTERED (Id)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[Categories]
--
PRINT (N'Создать таблицу [dbo].[Categories]')
GO
CREATE TABLE dbo.Categories (
  Id int IDENTITY,
  MszId int NOT NULL,
  Name nvarchar(max) NOT NULL,
  Guid nvarchar(max) NOT NULL,
  CONSTRAINT PK_Categories PRIMARY KEY CLUSTERED (Id)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_Categories_MszId] для объекта типа таблица [dbo].[Categories]
--
PRINT (N'Создать индекс [IX_Categories_MszId] для объекта типа таблица [dbo].[Categories]')
GO
CREATE INDEX IX_Categories_MszId
  ON dbo.Categories (MszId)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_Categories_Mszs_MszId] для объекта типа таблица [dbo].[Categories]
--
PRINT (N'Создать внешний ключ [FK_Categories_Mszs_MszId] для объекта типа таблица [dbo].[Categories]')
GO
ALTER TABLE dbo.Categories
  ADD CONSTRAINT FK_Categories_Mszs_MszId FOREIGN KEY (MszId) REFERENCES dbo.Mszs (Id) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[KinshipRelation]
--
PRINT (N'Создать таблицу [dbo].[KinshipRelation]')
GO
CREATE TABLE dbo.KinshipRelation (
  Id int IDENTITY,
  KinshipTypeCode varchar(100) NOT NULL,
  NameRelations varchar(100) NOT NULL,
  CONSTRAINT PK_KinshipRelation_Id PRIMARY KEY CLUSTERED (Id)
)
ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[Genders]
--
PRINT (N'Создать таблицу [dbo].[Genders]')
GO
CREATE TABLE dbo.Genders (
  Id int IDENTITY,
  Name nvarchar(max) NOT NULL,
  CONSTRAINT PK_Genders PRIMARY KEY CLUSTERED (Id)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[AssigmentForms]
--
PRINT (N'Создать таблицу [dbo].[AssigmentForms]')
GO
CREATE TABLE dbo.AssigmentForms (
  Id int IDENTITY,
  Name nvarchar(max) NOT NULL,
  CONSTRAINT PK_AssigmentForms PRIMARY KEY CLUSTERED (Id)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[Receivers]
--
PRINT (N'Создать таблицу [dbo].[Receivers]')
GO
CREATE TABLE dbo.Receivers (
  Id int IDENTITY,
  Surname nvarchar(max) NOT NULL,
  Name nvarchar(max) NOT NULL,
  Patronymic nvarchar(max) NULL,
  GenderId int NOT NULL,
  BirthDate datetime2 NOT NULL,
  Snils nvarchar(max) NOT NULL,
  Address nvarchar(max) NULL,
  Phone nvarchar(max) NULL,
  MszId int NOT NULL,
  CategoryId int NOT NULL,
  DecisionDate datetime2 NOT NULL,
  DecisionNumber nvarchar(max) NULL,
  StartDate datetime2 NOT NULL,
  EndDate datetime2 NULL,
  AssigmentFormId int NOT NULL,
  Amount decimal(18, 2) NOT NULL,
  EquivalentAmount decimal(18, 2) NULL,
  Uuid nvarchar(max) NOT NULL,
  PrevRevisionId int NULL,
  NextRevisionId int NULL,
  CreatedDate datetime2 NOT NULL DEFAULT ('0001-01-01T00:00:00.0000000'),
  Creator nvarchar(max) NOT NULL DEFAULT (N''),
  IsDeleted bit NOT NULL DEFAULT (0),
  CONSTRAINT PK_Receivers PRIMARY KEY CLUSTERED (Id)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_Receivers_AssigmentFormId] для объекта типа таблица [dbo].[Receivers]
--
PRINT (N'Создать индекс [IX_Receivers_AssigmentFormId] для объекта типа таблица [dbo].[Receivers]')
GO
CREATE INDEX IX_Receivers_AssigmentFormId
  ON dbo.Receivers (AssigmentFormId)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_Receivers_CategoryId] для объекта типа таблица [dbo].[Receivers]
--
PRINT (N'Создать индекс [IX_Receivers_CategoryId] для объекта типа таблица [dbo].[Receivers]')
GO
CREATE INDEX IX_Receivers_CategoryId
  ON dbo.Receivers (CategoryId)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_Receivers_GenderId] для объекта типа таблица [dbo].[Receivers]
--
PRINT (N'Создать индекс [IX_Receivers_GenderId] для объекта типа таблица [dbo].[Receivers]')
GO
CREATE INDEX IX_Receivers_GenderId
  ON dbo.Receivers (GenderId)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_Receivers_MszId] для объекта типа таблица [dbo].[Receivers]
--
PRINT (N'Создать индекс [IX_Receivers_MszId] для объекта типа таблица [dbo].[Receivers]')
GO
CREATE INDEX IX_Receivers_MszId
  ON dbo.Receivers (MszId)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_Receivers_AssigmentForms_AssigmentFormId] для объекта типа таблица [dbo].[Receivers]
--
PRINT (N'Создать внешний ключ [FK_Receivers_AssigmentForms_AssigmentFormId] для объекта типа таблица [dbo].[Receivers]')
GO
ALTER TABLE dbo.Receivers
  ADD CONSTRAINT FK_Receivers_AssigmentForms_AssigmentFormId FOREIGN KEY (AssigmentFormId) REFERENCES dbo.AssigmentForms (Id)
GO

--
-- Создать внешний ключ [FK_Receivers_Categories_CategoryId] для объекта типа таблица [dbo].[Receivers]
--
PRINT (N'Создать внешний ключ [FK_Receivers_Categories_CategoryId] для объекта типа таблица [dbo].[Receivers]')
GO
ALTER TABLE dbo.Receivers
  ADD CONSTRAINT FK_Receivers_Categories_CategoryId FOREIGN KEY (CategoryId) REFERENCES dbo.Categories (Id)
GO

--
-- Создать внешний ключ [FK_Receivers_Genders_GenderId] для объекта типа таблица [dbo].[Receivers]
--
PRINT (N'Создать внешний ключ [FK_Receivers_Genders_GenderId] для объекта типа таблица [dbo].[Receivers]')
GO
ALTER TABLE dbo.Receivers
  ADD CONSTRAINT FK_Receivers_Genders_GenderId FOREIGN KEY (GenderId) REFERENCES dbo.Genders (Id)
GO

--
-- Создать внешний ключ [FK_Receivers_Mszs_MszId] для объекта типа таблица [dbo].[Receivers]
--
PRINT (N'Создать внешний ключ [FK_Receivers_Mszs_MszId] для объекта типа таблица [dbo].[Receivers]')
GO
ALTER TABLE dbo.Receivers
  ADD CONSTRAINT FK_Receivers_Mszs_MszId FOREIGN KEY (MszId) REFERENCES dbo.Mszs (Id)
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--
-- Создать процедуру [dbo].[ActualizateReceiversMszIds]
--
GO
PRINT (N'Создать процедуру [dbo].[ActualizateReceiversMszIds]')
GO
CREATE PROCEDURE dbo.ActualizateReceiversMszIds
AS
UPDATE r
SET r.MszId = m.NextRevisionId
FROM Receivers r
  JOIN Mszs m ON r.MszId = m.Id
WHERE m.NextRevisionId IS NOT NULL; 

UPDATE r
SET r.CategoryId = (SELECT c1.Id FROM Categories c1 WHERE c1.MszId = m.Id AND c1.Name = c.Name)
FROM Receivers r
  JOIN Mszs m ON r.MszId = m.Id
  JOIN Categories c ON r.CategoryId = c.Id
WHERE m.NextRevisionId IS NULL AND m.Id <> c.MszId AND EXISTS(SELECT c1.Id FROM Categories c1 WHERE c1.MszId = m.Id AND c1.Name = c.Name);
GO

--
-- Создать таблицу [dbo].[ReasonPerson]
--
PRINT (N'Создать таблицу [dbo].[ReasonPerson]')
GO
CREATE TABLE dbo.ReasonPerson (
  Id int IDENTITY,
  Surname nvarchar(max) NOT NULL,
  Name nvarchar(max) NOT NULL,
  Patronymic nvarchar(max) NULL,
  GenderId int NOT NULL,
  BirthDate datetime2 NOT NULL,
  Snils nvarchar(max) NOT NULL,
  ReceiverId int NOT NULL,
  KinshipRelationId int NULL,
  CONSTRAINT PK_ReasonPerson PRIMARY KEY CLUSTERED (Id)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_ReasonPerson_GenderId] для объекта типа таблица [dbo].[ReasonPerson]
--
PRINT (N'Создать индекс [IX_ReasonPerson_GenderId] для объекта типа таблица [dbo].[ReasonPerson]')
GO
CREATE INDEX IX_ReasonPerson_GenderId
  ON dbo.ReasonPerson (GenderId)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_ReasonPerson_KinshipId] для объекта типа таблица [dbo].[ReasonPerson]
--
PRINT (N'Создать индекс [IX_ReasonPerson_KinshipId] для объекта типа таблица [dbo].[ReasonPerson]')
GO
CREATE INDEX IX_ReasonPerson_KinshipId
  ON dbo.ReasonPerson (KinshipRelationId)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_ReasonPerson_ReceiverId] для объекта типа таблица [dbo].[ReasonPerson]
--
PRINT (N'Создать индекс [IX_ReasonPerson_ReceiverId] для объекта типа таблица [dbo].[ReasonPerson]')
GO
CREATE INDEX IX_ReasonPerson_ReceiverId
  ON dbo.ReasonPerson (ReceiverId)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_ReasonPerson_Genders_GenderId] для объекта типа таблица [dbo].[ReasonPerson]
--
PRINT (N'Создать внешний ключ [FK_ReasonPerson_Genders_GenderId] для объекта типа таблица [dbo].[ReasonPerson]')
GO
ALTER TABLE dbo.ReasonPerson
  ADD CONSTRAINT FK_ReasonPerson_Genders_GenderId FOREIGN KEY (GenderId) REFERENCES dbo.Genders (Id)
GO

--
-- Создать внешний ключ [FK_ReasonPerson_KinshipRelation_Id] для объекта типа таблица [dbo].[ReasonPerson]
--
PRINT (N'Создать внешний ключ [FK_ReasonPerson_KinshipRelation_Id] для объекта типа таблица [dbo].[ReasonPerson]')
GO
ALTER TABLE dbo.ReasonPerson
  ADD CONSTRAINT FK_ReasonPerson_KinshipRelation_Id FOREIGN KEY (KinshipRelationId) REFERENCES dbo.KinshipRelation (Id)
GO

--
-- Создать внешний ключ [FK_ReasonPerson_Receivers_ReceiverId] для объекта типа таблица [dbo].[ReasonPerson]
--
PRINT (N'Создать внешний ключ [FK_ReasonPerson_Receivers_ReceiverId] для объекта типа таблица [dbo].[ReasonPerson]')
GO
ALTER TABLE dbo.ReasonPerson
  ADD CONSTRAINT FK_ReasonPerson_Receivers_ReceiverId FOREIGN KEY (ReceiverId) REFERENCES dbo.Receivers (Id) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[AclUsers]
--
PRINT (N'Создать таблицу [dbo].[AclUsers]')
GO
CREATE TABLE dbo.AclUsers (
  Id int IDENTITY,
  Login nvarchar(max) NOT NULL,
  EgissoId nvarchar(max) NULL,
  CONSTRAINT PK_AclUsers PRIMARY KEY CLUSTERED (Id)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[AclPrivilege]
--
PRINT (N'Создать таблицу [dbo].[AclPrivilege]')
GO
CREATE TABLE dbo.AclPrivilege (
  Id int IDENTITY,
  Name nvarchar(max) NOT NULL,
  CONSTRAINT PK_AclPrivilege PRIMARY KEY CLUSTERED (Id)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[AclUserPrivilege]
--
PRINT (N'Создать таблицу [dbo].[AclUserPrivilege]')
GO
CREATE TABLE dbo.AclUserPrivilege (
  UserId int NOT NULL,
  PrivilegeId int NOT NULL,
  MszId int NOT NULL DEFAULT (0),
  CONSTRAINT PK_AclUserPrivilege PRIMARY KEY CLUSTERED (UserId, PrivilegeId, MszId)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IX_AclUserPrivilege_MszId] для объекта типа таблица [dbo].[AclUserPrivilege]
--
PRINT (N'Создать индекс [IX_AclUserPrivilege_MszId] для объекта типа таблица [dbo].[AclUserPrivilege]')
GO
CREATE INDEX IX_AclUserPrivilege_MszId
  ON dbo.AclUserPrivilege (MszId)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_AclUserPrivilege_PrivilegeId] для объекта типа таблица [dbo].[AclUserPrivilege]
--
PRINT (N'Создать индекс [IX_AclUserPrivilege_PrivilegeId] для объекта типа таблица [dbo].[AclUserPrivilege]')
GO
CREATE INDEX IX_AclUserPrivilege_PrivilegeId
  ON dbo.AclUserPrivilege (PrivilegeId)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_AclUserPrivilege_AclPrivilege_PrivilegeId] для объекта типа таблица [dbo].[AclUserPrivilege]
--
PRINT (N'Создать внешний ключ [FK_AclUserPrivilege_AclPrivilege_PrivilegeId] для объекта типа таблица [dbo].[AclUserPrivilege]')
GO
ALTER TABLE dbo.AclUserPrivilege
  ADD CONSTRAINT FK_AclUserPrivilege_AclPrivilege_PrivilegeId FOREIGN KEY (PrivilegeId) REFERENCES dbo.AclPrivilege (Id)
GO

--
-- Создать внешний ключ [FK_AclUserPrivilege_AclUsers_UserId] для объекта типа таблица [dbo].[AclUserPrivilege]
--
PRINT (N'Создать внешний ключ [FK_AclUserPrivilege_AclUsers_UserId] для объекта типа таблица [dbo].[AclUserPrivilege]')
GO
ALTER TABLE dbo.AclUserPrivilege
  ADD CONSTRAINT FK_AclUserPrivilege_AclUsers_UserId FOREIGN KEY (UserId) REFERENCES dbo.AclUsers (Id) ON DELETE CASCADE
GO

--
-- Создать внешний ключ [FK_AclUserPrivilege_Mszs_MszId] для объекта типа таблица [dbo].[AclUserPrivilege]
--
PRINT (N'Создать внешний ключ [FK_AclUserPrivilege_Mszs_MszId] для объекта типа таблица [dbo].[AclUserPrivilege]')
GO
ALTER TABLE dbo.AclUserPrivilege
  ADD CONSTRAINT FK_AclUserPrivilege_Mszs_MszId FOREIGN KEY (MszId) REFERENCES dbo.Mszs (Id) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[__EFMigrationsHistory]
--
PRINT (N'Создать таблицу [dbo].[__EFMigrationsHistory]')
GO
CREATE TABLE dbo.__EFMigrationsHistory (
  MigrationId nvarchar(150) NOT NULL,
  ProductVersion nvarchar(32) NOT NULL,
  CONSTRAINT PK___EFMigrationsHistory PRIMARY KEY CLUSTERED (MigrationId)
)
ON [PRIMARY]
GO
SET NOEXEC OFF
GO