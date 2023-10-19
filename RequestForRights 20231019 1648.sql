--
-- Скрипт сгенерирован Devart dbForge Studio for SQL Server, Версия 5.5.327.0
-- Домашняя страница продукта: http://www.devart.com/ru/dbforge/sql/studio
-- Дата скрипта: 19.10.2023 16:48:37
-- Версия сервера: 12.00.6024
--



USE RequestForRights
GO

IF DB_NAME() <> N'RequestForRights' SET NOEXEC ON
GO

--
-- Создать таблицу [dbo].[sysdiagrams]
--
PRINT (N'Создать таблицу [dbo].[sysdiagrams]')
GO
CREATE TABLE dbo.sysdiagrams (
  name sysname NOT NULL,
  principal_id int NOT NULL,
  diagram_id int IDENTITY,
  version int NULL,
  definition varbinary(max) NULL,
  PRIMARY KEY CLUSTERED (diagram_id),
  CONSTRAINT UK_principal_name UNIQUE (principal_id, name)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[ResourceResponsibleDepartments]
--
PRINT (N'Создать таблицу [dbo].[ResourceResponsibleDepartments]')
GO
CREATE TABLE dbo.ResourceResponsibleDepartments (
  IdResourceResponsibleDepartment int IDENTITY,
  Name nvarchar(max) NOT NULL,
  CONSTRAINT [PK_dbo.ResourceResponsibleDepartments] PRIMARY KEY CLUSTERED (IdResourceResponsibleDepartment)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[ResourceInformationTypes]
--
PRINT (N'Создать таблицу [dbo].[ResourceInformationTypes]')
GO
CREATE TABLE dbo.ResourceInformationTypes (
  IdResourceInformationType int IDENTITY,
  Name nvarchar(512) NOT NULL,
  CONSTRAINT [PK_dbo.ResourceInformationTypes] PRIMARY KEY CLUSTERED (IdResourceInformationType)
)
ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[ResourceGroups]
--
PRINT (N'Создать таблицу [dbo].[ResourceGroups]')
GO
CREATE TABLE dbo.ResourceGroups (
  IdResourceGroup int IDENTITY,
  Name nvarchar(512) NOT NULL,
  Description nvarchar(max) NULL,
  Deleted bit NOT NULL DEFAULT (0),
  CONSTRAINT [PK_dbo.ResourceGroups] PRIMARY KEY CLUSTERED (IdResourceGroup)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[RequestUsers]
--
PRINT (N'Создать таблицу [dbo].[RequestUsers]')
GO
CREATE TABLE dbo.RequestUsers (
  IdRequestUser int IDENTITY,
  Login nvarchar(256) NULL,
  Snp nvarchar(512) NOT NULL,
  Post nvarchar(512) NULL,
  Phone nvarchar(512) NULL,
  Department nvarchar(512) NOT NULL,
  Unit nvarchar(512) NULL,
  Office nvarchar(512) NULL,
  Deleted bit NOT NULL,
  IsActive bit NOT NULL DEFAULT (1),
  CONSTRAINT [PK_dbo.RequestUsers] PRIMARY KEY CLUSTERED (IdRequestUser)
)
ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[RequestTypes]
--
PRINT (N'Создать таблицу [dbo].[RequestTypes]')
GO
CREATE TABLE dbo.RequestTypes (
  IdRequestType int IDENTITY,
  Name nvarchar(512) NOT NULL,
  CONSTRAINT [PK_dbo.RequestTypes] PRIMARY KEY CLUSTERED (IdRequestType)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IDX_RequestTypes_Name] для объекта типа таблица [dbo].[RequestTypes]
--
PRINT (N'Создать индекс [IDX_RequestTypes_Name] для объекта типа таблица [dbo].[RequestTypes]')
GO
CREATE INDEX IDX_RequestTypes_Name
  ON dbo.RequestTypes (Name)
  ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[RequestStateTypes]
--
PRINT (N'Создать таблицу [dbo].[RequestStateTypes]')
GO
CREATE TABLE dbo.RequestStateTypes (
  IdRequestStateType int IDENTITY,
  Name nvarchar(512) NOT NULL,
  CONSTRAINT [PK_dbo.RequestStateTypes] PRIMARY KEY CLUSTERED (IdRequestStateType)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IDX_RequestStateTypes_Name] для объекта типа таблица [dbo].[RequestStateTypes]
--
PRINT (N'Создать индекс [IDX_RequestStateTypes_Name] для объекта типа таблица [dbo].[RequestStateTypes]')
GO
CREATE INDEX IDX_RequestStateTypes_Name
  ON dbo.RequestStateTypes (Name)
  ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[RequestRightGrantTypes]
--
PRINT (N'Создать таблицу [dbo].[RequestRightGrantTypes]')
GO
CREATE TABLE dbo.RequestRightGrantTypes (
  IdRequestRightGrantType int IDENTITY,
  Name nvarchar(512) NOT NULL,
  CONSTRAINT [PK_dbo.RequestRightGrantTypes] PRIMARY KEY CLUSTERED (IdRequestRightGrantType)
)
ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[RequestAgreementTypes]
--
PRINT (N'Создать таблицу [dbo].[RequestAgreementTypes]')
GO
CREATE TABLE dbo.RequestAgreementTypes (
  IdAgreementType int IDENTITY,
  Name nvarchar(max) NOT NULL,
  CONSTRAINT [PK_dbo.RequestAgreementTypes] PRIMARY KEY CLUSTERED (IdAgreementType)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[RequestAgreementStates]
--
PRINT (N'Создать таблицу [dbo].[RequestAgreementStates]')
GO
CREATE TABLE dbo.RequestAgreementStates (
  IdAgreementState int IDENTITY,
  Name nvarchar(max) NOT NULL,
  CONSTRAINT [PK_dbo.RequestAgreementStates] PRIMARY KEY CLUSTERED (IdAgreementState)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[Departments]
--
PRINT (N'Создать таблицу [dbo].[Departments]')
GO
CREATE TABLE dbo.Departments (
  IdDepartment int IDENTITY,
  Name nvarchar(512) NOT NULL,
  IdParentDepartment int NULL,
  Deleted bit NOT NULL DEFAULT (0),
  TaxPayerNumber nvarchar(max) NULL,
  OfficialNameLongRu nvarchar(max) NULL,
  OfficialNameShortRu nvarchar(max) NULL,
  OfficialNameLongEn nvarchar(max) NULL,
  OfficialNameShortEn nvarchar(max) NULL,
  SelfAddressIndex nvarchar(6) NULL,
  SelfAddressRegion nvarchar(max) NULL,
  SelfAddressArea nvarchar(max) NULL,
  SelfAddressCity nvarchar(max) NULL,
  SelfAddressStreet nvarchar(max) NULL,
  SelfAddressHouse nvarchar(max) NULL,
  СontrolOrgAddressesAreEqualSelfAddress bit NOT NULL DEFAULT (0),
  ControlOrgAddressIndex nvarchar(6) NULL,
  ControlOrgAddressRegion nvarchar(max) NULL,
  ControlOrgAddressArea nvarchar(max) NULL,
  ControlOrgAddressCity nvarchar(max) NULL,
  ControlOrgAddressStreet nvarchar(max) NULL,
  ControlOrgAddressHouse nvarchar(max) NULL,
  IsAlienDepartment bit NOT NULL DEFAULT (0),
  CONSTRAINT [PK_dbo.Departments] PRIMARY KEY CLUSTERED (IdDepartment)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdParentDepartment] для объекта типа таблица [dbo].[Departments]
--
PRINT (N'Создать индекс [IX_IdParentDepartment] для объекта типа таблица [dbo].[Departments]')
GO
CREATE INDEX IX_IdParentDepartment
  ON dbo.Departments (IdParentDepartment)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.Departments_dbo.Departments_IdParentDepartment] для объекта типа таблица [dbo].[Departments]
--
PRINT (N'Создать внешний ключ [FK_dbo.Departments_dbo.Departments_IdParentDepartment] для объекта типа таблица [dbo].[Departments]')
GO
ALTER TABLE dbo.Departments
  ADD CONSTRAINT [FK_dbo.Departments_dbo.Departments_IdParentDepartment] FOREIGN KEY (IdParentDepartment) REFERENCES dbo.Departments (IdDepartment)
GO

--
-- Создать таблицу [dbo].[Resources]
--
PRINT (N'Создать таблицу [dbo].[Resources]')
GO
CREATE TABLE dbo.Resources (
  IdResource int IDENTITY,
  Name nvarchar(512) NOT NULL,
  Description nvarchar(max) NULL,
  IdResourceGroup int NOT NULL,
  Deleted bit NOT NULL DEFAULT (0),
  IdOwnerDepartment int NOT NULL DEFAULT (0),
  IdOperatorDepartment int NOT NULL,
  EmailAdministrator nvarchar(max) NULL,
  IdResourceInformationType int NULL,
  PersonalInfoDescription nvarchar(max) NULL,
  HasNotInternetAccess bit NOT NULL DEFAULT (0),
  InnControlSubject nvarchar(max) NULL,
  IdResourceResponsibleDepartment int NULL,
  IsDelegable bit NOT NULL DEFAULT (0),
  CONSTRAINT [PK_dbo.Resources] PRIMARY KEY CLUSTERED (IdResource)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdOperatorDepartment] для объекта типа таблица [dbo].[Resources]
--
PRINT (N'Создать индекс [IX_IdOperatorDepartment] для объекта типа таблица [dbo].[Resources]')
GO
CREATE INDEX IX_IdOperatorDepartment
  ON dbo.Resources (IdOperatorDepartment)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdOwnerDepartment] для объекта типа таблица [dbo].[Resources]
--
PRINT (N'Создать индекс [IX_IdOwnerDepartment] для объекта типа таблица [dbo].[Resources]')
GO
CREATE INDEX IX_IdOwnerDepartment
  ON dbo.Resources (IdOwnerDepartment)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResourceGroup] для объекта типа таблица [dbo].[Resources]
--
PRINT (N'Создать индекс [IX_IdResourceGroup] для объекта типа таблица [dbo].[Resources]')
GO
CREATE INDEX IX_IdResourceGroup
  ON dbo.Resources (IdResourceGroup)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResourceInformationType] для объекта типа таблица [dbo].[Resources]
--
PRINT (N'Создать индекс [IX_IdResourceInformationType] для объекта типа таблица [dbo].[Resources]')
GO
CREATE INDEX IX_IdResourceInformationType
  ON dbo.Resources (IdResourceInformationType)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResourceResponsibleDepartment] для объекта типа таблица [dbo].[Resources]
--
PRINT (N'Создать индекс [IX_IdResourceResponsibleDepartment] для объекта типа таблица [dbo].[Resources]')
GO
CREATE INDEX IX_IdResourceResponsibleDepartment
  ON dbo.Resources (IdResourceResponsibleDepartment)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.Resources_dbo.Departments_IdDepartment] для объекта типа таблица [dbo].[Resources]
--
PRINT (N'Создать внешний ключ [FK_dbo.Resources_dbo.Departments_IdDepartment] для объекта типа таблица [dbo].[Resources]')
GO
ALTER TABLE dbo.Resources
  ADD CONSTRAINT [FK_dbo.Resources_dbo.Departments_IdDepartment] FOREIGN KEY (IdOwnerDepartment) REFERENCES dbo.Departments (IdDepartment)
GO

--
-- Создать внешний ключ [FK_dbo.Resources_dbo.Departments_IdOperatorDepartment] для объекта типа таблица [dbo].[Resources]
--
PRINT (N'Создать внешний ключ [FK_dbo.Resources_dbo.Departments_IdOperatorDepartment] для объекта типа таблица [dbo].[Resources]')
GO
ALTER TABLE dbo.Resources
  ADD CONSTRAINT [FK_dbo.Resources_dbo.Departments_IdOperatorDepartment] FOREIGN KEY (IdOperatorDepartment) REFERENCES dbo.Departments (IdDepartment)
GO

--
-- Создать внешний ключ [FK_dbo.Resources_dbo.ResourceGroups_IdResourceGroup] для объекта типа таблица [dbo].[Resources]
--
PRINT (N'Создать внешний ключ [FK_dbo.Resources_dbo.ResourceGroups_IdResourceGroup] для объекта типа таблица [dbo].[Resources]')
GO
ALTER TABLE dbo.Resources
  ADD CONSTRAINT [FK_dbo.Resources_dbo.ResourceGroups_IdResourceGroup] FOREIGN KEY (IdResourceGroup) REFERENCES dbo.ResourceGroups (IdResourceGroup)
GO

--
-- Создать внешний ключ [FK_dbo.Resources_dbo.ResourceInformationTypes_IdResourceInformationType] для объекта типа таблица [dbo].[Resources]
--
PRINT (N'Создать внешний ключ [FK_dbo.Resources_dbo.ResourceInformationTypes_IdResourceInformationType] для объекта типа таблица [dbo].[Resources]')
GO
ALTER TABLE dbo.Resources
  ADD CONSTRAINT [FK_dbo.Resources_dbo.ResourceInformationTypes_IdResourceInformationType] FOREIGN KEY (IdResourceInformationType) REFERENCES dbo.ResourceInformationTypes (IdResourceInformationType)
GO

--
-- Создать внешний ключ [FK_dbo.Resources_dbo.ResourceResponsibleDepartments_IdResourceResponsibleDepartment] для объекта типа таблица [dbo].[Resources]
--
PRINT (N'Создать внешний ключ [FK_dbo.Resources_dbo.ResourceResponsibleDepartments_IdResourceResponsibleDepartment] для объекта типа таблица [dbo].[Resources]')
GO
ALTER TABLE dbo.Resources
  ADD CONSTRAINT [FK_dbo.Resources_dbo.ResourceResponsibleDepartments_IdResourceResponsibleDepartment] FOREIGN KEY (IdResourceResponsibleDepartment) REFERENCES dbo.ResourceResponsibleDepartments (IdResourceResponsibleDepartment)
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--
-- Создать представление [dbo].[v_ResourceOperator]
--
GO
PRINT (N'Создать представление [dbo].[v_ResourceOperator]')
GO
CREATE view dbo.v_ResourceOperator
as
SELECT top 1000 r.[IdResource]
      ,r.[Name]
      ,r.[Description]
,d.name as OperatorDepartment
      /*,[IdResourceGroup]
      ,[Deleted]
      ,[IdOwnerDepartment]
      ,[IdOperatorDepartment]
      ,[EmailAdministrator]
      ,[IdResourceInformationType]
      ,[PersonalInfoDescription]
      ,[HasNotInternetAccess]
      ,[InnControlSubject]*/
  FROM [dbo].[Resources] r
inner join dbo.Departments d on d.IdDepartment=r.[IdOperatorDepartment]
order by r.[IdResource]
GO

--
-- Создать таблицу [dbo].[ResourceRights]
--
PRINT (N'Создать таблицу [dbo].[ResourceRights]')
GO
CREATE TABLE dbo.ResourceRights (
  IdResourceRight int IDENTITY,
  Name nvarchar(512) NOT NULL,
  Description nvarchar(max) NULL,
  IdResource int NOT NULL,
  Deleted bit NOT NULL DEFAULT (0),
  CONSTRAINT [PK_dbo.ResourceRights] PRIMARY KEY CLUSTERED (IdResourceRight)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceRights]
--
PRINT (N'Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceRights]')
GO
CREATE INDEX IX_IdResource
  ON dbo.ResourceRights (IdResource)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.ResourceRights_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceRights]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceRights_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceRights]')
GO
ALTER TABLE dbo.ResourceRights
  ADD CONSTRAINT [FK_dbo.ResourceRights_dbo.Resources_IdResource] FOREIGN KEY (IdResource) REFERENCES dbo.Resources (IdResource) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[ResourceOwnerPersons]
--
PRINT (N'Создать таблицу [dbo].[ResourceOwnerPersons]')
GO
CREATE TABLE dbo.ResourceOwnerPersons (
  IdResourceOwnerPerson int IDENTITY,
  Post nvarchar(max) NULL,
  Surname nvarchar(max) NULL,
  Name nvarchar(max) NULL,
  Patronimic nvarchar(max) NULL,
  IdResource int NOT NULL,
  Deleted bit NOT NULL,
  CONSTRAINT [PK_dbo.ResourceOwnerPersons] PRIMARY KEY CLUSTERED (IdResourceOwnerPerson)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceOwnerPersons]
--
PRINT (N'Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceOwnerPersons]')
GO
CREATE INDEX IX_IdResource
  ON dbo.ResourceOwnerPersons (IdResource)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.ResourceOwnerPersons_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceOwnerPersons]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceOwnerPersons_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceOwnerPersons]')
GO
ALTER TABLE dbo.ResourceOwnerPersons
  ADD CONSTRAINT [FK_dbo.ResourceOwnerPersons_dbo.Resources_IdResource] FOREIGN KEY (IdResource) REFERENCES dbo.Resources (IdResource) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[ResourceOperatorPersons]
--
PRINT (N'Создать таблицу [dbo].[ResourceOperatorPersons]')
GO
CREATE TABLE dbo.ResourceOperatorPersons (
  IdResourceOperatorPerson int IDENTITY,
  Post nvarchar(max) NULL,
  Surname nvarchar(max) NULL,
  Name nvarchar(max) NULL,
  Patronimic nvarchar(max) NULL,
  IdResource int NOT NULL,
  Deleted bit NOT NULL,
  CONSTRAINT [PK_dbo.ResourceOperatorPersons] PRIMARY KEY CLUSTERED (IdResourceOperatorPerson)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceOperatorPersons]
--
PRINT (N'Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceOperatorPersons]')
GO
CREATE INDEX IX_IdResource
  ON dbo.ResourceOperatorPersons (IdResource)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.ResourceOperatorPersons_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceOperatorPersons]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceOperatorPersons_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceOperatorPersons]')
GO
ALTER TABLE dbo.ResourceOperatorPersons
  ADD CONSTRAINT [FK_dbo.ResourceOperatorPersons_dbo.Resources_IdResource] FOREIGN KEY (IdResource) REFERENCES dbo.Resources (IdResource) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[ResourceInternetAddresses]
--
PRINT (N'Создать таблицу [dbo].[ResourceInternetAddresses]')
GO
CREATE TABLE dbo.ResourceInternetAddresses (
  IdResourceInternetAddress int IDENTITY,
  IdResource int NOT NULL,
  NetName nvarchar(max) NULL,
  DeviceNumber nvarchar(max) NULL,
  DeviceIpAddress nvarchar(15) NULL,
  GateIpAddress nvarchar(15) NULL,
  DhcpIpAddress nvarchar(15) NULL,
  IsDynamicIpAddress bit NOT NULL,
  DomainNames nvarchar(max) NULL,
  DomainIpAddress nvarchar(15) NULL,
  Deleted bit NOT NULL,
  CONSTRAINT [PK_dbo.ResourceInternetAddresses] PRIMARY KEY CLUSTERED (IdResourceInternetAddress)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceInternetAddresses]
--
PRINT (N'Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceInternetAddresses]')
GO
CREATE INDEX IX_IdResource
  ON dbo.ResourceInternetAddresses (IdResource)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.ResourceInternetAddresses_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceInternetAddresses]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceInternetAddresses_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceInternetAddresses]')
GO
ALTER TABLE dbo.ResourceInternetAddresses
  ADD CONSTRAINT [FK_dbo.ResourceInternetAddresses_dbo.Resources_IdResource] FOREIGN KEY (IdResource) REFERENCES dbo.Resources (IdResource) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[ResourceDeviceAddresses]
--
PRINT (N'Создать таблицу [dbo].[ResourceDeviceAddresses]')
GO
CREATE TABLE dbo.ResourceDeviceAddresses (
  IdResource int NOT NULL,
  Name nvarchar(max) NULL,
  AddressIndex nvarchar(6) NULL,
  AddressRegion nvarchar(max) NULL,
  AddressArea nvarchar(max) NULL,
  AddressCity nvarchar(max) NULL,
  AddressStreet nvarchar(max) NULL,
  AddressHouse nvarchar(32) NULL,
  Deleted bit NOT NULL,
  IdResourceDeviceAddress int IDENTITY,
  CONSTRAINT [PK_dbo.ResourceDeviceAddresses] PRIMARY KEY CLUSTERED (IdResourceDeviceAddress)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceDeviceAddresses]
--
PRINT (N'Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceDeviceAddresses]')
GO
CREATE INDEX IX_IdResource
  ON dbo.ResourceDeviceAddresses (IdResource)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.ResourceDeviceAddresses_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceDeviceAddresses]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceDeviceAddresses_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceDeviceAddresses]')
GO
ALTER TABLE dbo.ResourceDeviceAddresses
  ADD CONSTRAINT [FK_dbo.ResourceDeviceAddresses_dbo.Resources_IdResource] FOREIGN KEY (IdResource) REFERENCES dbo.Resources (IdResource) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[RequestAllowedResourceDepartments]
--
PRINT (N'Создать таблицу [dbo].[RequestAllowedResourceDepartments]')
GO
CREATE TABLE dbo.RequestAllowedResourceDepartments (
  IdResource int NOT NULL,
  IdDepartment int NOT NULL,
  CONSTRAINT [PK_dbo.RequestAllowedResourceDepartments] PRIMARY KEY CLUSTERED (IdResource, IdDepartment)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdDepartment] для объекта типа таблица [dbo].[RequestAllowedResourceDepartments]
--
PRINT (N'Создать индекс [IX_IdDepartment] для объекта типа таблица [dbo].[RequestAllowedResourceDepartments]')
GO
CREATE INDEX IX_IdDepartment
  ON dbo.RequestAllowedResourceDepartments (IdDepartment)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[RequestAllowedResourceDepartments]
--
PRINT (N'Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[RequestAllowedResourceDepartments]')
GO
CREATE INDEX IX_IdResource
  ON dbo.RequestAllowedResourceDepartments (IdResource)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.RequestAllowedResourceDepartments_dbo.Departments_IdDepartment] для объекта типа таблица [dbo].[RequestAllowedResourceDepartments]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestAllowedResourceDepartments_dbo.Departments_IdDepartment] для объекта типа таблица [dbo].[RequestAllowedResourceDepartments]')
GO
ALTER TABLE dbo.RequestAllowedResourceDepartments
  ADD CONSTRAINT [FK_dbo.RequestAllowedResourceDepartments_dbo.Departments_IdDepartment] FOREIGN KEY (IdDepartment) REFERENCES dbo.Departments (IdDepartment)
GO

--
-- Создать внешний ключ [FK_dbo.RequestAllowedResourceDepartments_dbo.Resources_IdResource] для объекта типа таблица [dbo].[RequestAllowedResourceDepartments]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestAllowedResourceDepartments_dbo.Resources_IdResource] для объекта типа таблица [dbo].[RequestAllowedResourceDepartments]')
GO
ALTER TABLE dbo.RequestAllowedResourceDepartments
  ADD CONSTRAINT [FK_dbo.RequestAllowedResourceDepartments_dbo.Resources_IdResource] FOREIGN KEY (IdResource) REFERENCES dbo.Resources (IdResource) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[AclUsers]
--
PRINT (N'Создать таблицу [dbo].[AclUsers]')
GO
CREATE TABLE dbo.AclUsers (
  IdUser int IDENTITY,
  Login nvarchar(256) NOT NULL,
  Deleted bit NOT NULL DEFAULT (0),
  IdDepartment int NOT NULL DEFAULT (0),
  Snp nvarchar(256) NOT NULL DEFAULT (''),
  Email nvarchar(256) NOT NULL DEFAULT (''),
  Phone nvarchar(256) NULL DEFAULT (''),
  DateCreated datetime NOT NULL DEFAULT (getdate()),
  CONSTRAINT [PK_dbo.AclUsers] PRIMARY KEY CLUSTERED (IdUser)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IDX_AclUser] для объекта типа таблица [dbo].[AclUsers]
--
PRINT (N'Создать индекс [IDX_AclUser] для объекта типа таблица [dbo].[AclUsers]')
GO
CREATE UNIQUE INDEX IDX_AclUser
  ON dbo.AclUsers (Login)
  ON [PRIMARY]
GO

--
-- Создать индекс [IDX_AclUsers_Snp] для объекта типа таблица [dbo].[AclUsers]
--
PRINT (N'Создать индекс [IDX_AclUsers_Snp] для объекта типа таблица [dbo].[AclUsers]')
GO
CREATE INDEX IDX_AclUsers_Snp
  ON dbo.AclUsers (Snp)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdDepartment] для объекта типа таблица [dbo].[AclUsers]
--
PRINT (N'Создать индекс [IX_IdDepartment] для объекта типа таблица [dbo].[AclUsers]')
GO
CREATE INDEX IX_IdDepartment
  ON dbo.AclUsers (IdDepartment)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.AclUsers_dbo.Departments_Department_IdDepartment] для объекта типа таблица [dbo].[AclUsers]
--
PRINT (N'Создать внешний ключ [FK_dbo.AclUsers_dbo.Departments_Department_IdDepartment] для объекта типа таблица [dbo].[AclUsers]')
GO
ALTER TABLE dbo.AclUsers
  ADD CONSTRAINT [FK_dbo.AclUsers_dbo.Departments_Department_IdDepartment] FOREIGN KEY (IdDepartment) REFERENCES dbo.Departments (IdDepartment)
GO

--
-- Создать представление [dbo].[v_DepartmentsUsers]
--
GO
PRINT (N'Создать представление [dbo].[v_DepartmentsUsers]')
GO
CREATE view dbo.v_DepartmentsUsers as
select top 200 d.name 
, u.login
, u.Snp
,u.phone
from dbo.Departments d
inner join dbo.AclUsers u on u.IdDepartment=d.IdDepartment
order by d.name
GO

--
-- Создать таблицу [dbo].[Requests]
--
PRINT (N'Создать таблицу [dbo].[Requests]')
GO
CREATE TABLE dbo.Requests (
  IdRequest int IDENTITY,
  Description nvarchar(max) NULL,
  IdUser int NOT NULL,
  IdRequestType int NOT NULL,
  Deleted bit NOT NULL,
  CurrentRequestStateDate datetime NULL DEFAULT ('1900-01-01T00:00:00.000'),
  IdCurrentRequestStateType int NULL,
  CONSTRAINT [PK_dbo.Requests] PRIMARY KEY CLUSTERED (IdRequest)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IDX_Requests_CurrentRequestStateDate] для объекта типа таблица [dbo].[Requests]
--
PRINT (N'Создать индекс [IDX_Requests_CurrentRequestStateDate] для объекта типа таблица [dbo].[Requests]')
GO
CREATE INDEX IDX_Requests_CurrentRequestStateDate
  ON dbo.Requests (CurrentRequestStateDate)
  ON [PRIMARY]
GO

--
-- Создать индекс [IDX_Requests_IdRequestType] для объекта типа таблица [dbo].[Requests]
--
PRINT (N'Создать индекс [IDX_Requests_IdRequestType] для объекта типа таблица [dbo].[Requests]')
GO
CREATE INDEX IDX_Requests_IdRequestType
  ON dbo.Requests (IdRequestType)
  ON [PRIMARY]
GO

--
-- Создать индекс [IDX_Requests_IdUser] для объекта типа таблица [dbo].[Requests]
--
PRINT (N'Создать индекс [IDX_Requests_IdUser] для объекта типа таблица [dbo].[Requests]')
GO
CREATE INDEX IDX_Requests_IdUser
  ON dbo.Requests (IdUser)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdCurrentRequestStateType] для объекта типа таблица [dbo].[Requests]
--
PRINT (N'Создать индекс [IX_IdCurrentRequestStateType] для объекта типа таблица [dbo].[Requests]')
GO
CREATE INDEX IX_IdCurrentRequestStateType
  ON dbo.Requests (IdCurrentRequestStateType)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.Requests_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[Requests]
--
PRINT (N'Создать внешний ключ [FK_dbo.Requests_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[Requests]')
GO
ALTER TABLE dbo.Requests
  ADD CONSTRAINT [FK_dbo.Requests_dbo.AclUsers_IdUser] FOREIGN KEY (IdUser) REFERENCES dbo.AclUsers (IdUser)
GO

--
-- Создать внешний ключ [FK_dbo.Requests_dbo.RequestStateTypes_IdCurrentRequestStateType] для объекта типа таблица [dbo].[Requests]
--
PRINT (N'Создать внешний ключ [FK_dbo.Requests_dbo.RequestStateTypes_IdCurrentRequestStateType] для объекта типа таблица [dbo].[Requests]')
GO
ALTER TABLE dbo.Requests
  ADD CONSTRAINT [FK_dbo.Requests_dbo.RequestStateTypes_IdCurrentRequestStateType] FOREIGN KEY (IdCurrentRequestStateType) REFERENCES dbo.RequestStateTypes (IdRequestStateType)
GO

--
-- Создать внешний ключ [FK_dbo.Requests_dbo.RequestTypes_IdRequestType] для объекта типа таблица [dbo].[Requests]
--
PRINT (N'Создать внешний ключ [FK_dbo.Requests_dbo.RequestTypes_IdRequestType] для объекта типа таблица [dbo].[Requests]')
GO
ALTER TABLE dbo.Requests
  ADD CONSTRAINT [FK_dbo.Requests_dbo.RequestTypes_IdRequestType] FOREIGN KEY (IdRequestType) REFERENCES dbo.RequestTypes (IdRequestType)
GO

--
-- Создать таблицу [dbo].[RequestUserLastSeens]
--
PRINT (N'Создать таблицу [dbo].[RequestUserLastSeens]')
GO
CREATE TABLE dbo.RequestUserLastSeens (
  IdRequestUserLastSeen int IDENTITY,
  DateOfLastSeen datetime NOT NULL,
  IdUser int NOT NULL,
  IdRequest int NOT NULL,
  CONSTRAINT [PK_dbo.RequestUserLastSeens] PRIMARY KEY CLUSTERED (IdRequestUserLastSeen)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IDX_RequestUserLastSeen_IdRequest_IdUser] для объекта типа таблица [dbo].[RequestUserLastSeens]
--
PRINT (N'Создать индекс [IDX_RequestUserLastSeen_IdRequest_IdUser] для объекта типа таблица [dbo].[RequestUserLastSeens]')
GO
CREATE INDEX IDX_RequestUserLastSeen_IdRequest_IdUser
  ON dbo.RequestUserLastSeens (IdRequest, IdUser)
  ON [PRIMARY]
GO

--
-- Создать индекс [IDX_RequestUserLastSeens_IdUser] для объекта типа таблица [dbo].[RequestUserLastSeens]
--
PRINT (N'Создать индекс [IDX_RequestUserLastSeens_IdUser] для объекта типа таблица [dbo].[RequestUserLastSeens]')
GO
CREATE INDEX IDX_RequestUserLastSeens_IdUser
  ON dbo.RequestUserLastSeens (IdUser)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.RequestUserLastSeens_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[RequestUserLastSeens]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestUserLastSeens_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[RequestUserLastSeens]')
GO
ALTER TABLE dbo.RequestUserLastSeens
  ADD CONSTRAINT [FK_dbo.RequestUserLastSeens_dbo.AclUsers_IdUser] FOREIGN KEY (IdUser) REFERENCES dbo.AclUsers (IdUser)
GO

--
-- Создать внешний ключ [FK_dbo.RequestUserLastSeens_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestUserLastSeens]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestUserLastSeens_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestUserLastSeens]')
GO
ALTER TABLE dbo.RequestUserLastSeens
  ADD CONSTRAINT [FK_dbo.RequestUserLastSeens_dbo.Requests_IdRequest] FOREIGN KEY (IdRequest) REFERENCES dbo.Requests (IdRequest) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[RequestUserAssocs]
--
PRINT (N'Создать таблицу [dbo].[RequestUserAssocs]')
GO
CREATE TABLE dbo.RequestUserAssocs (
  IdRequestUserAssoc int IDENTITY,
  IdRequest int NOT NULL,
  IdRequestUser int NOT NULL,
  Deleted bit NOT NULL,
  Description nvarchar(max) NULL,
  CONSTRAINT [PK_dbo.RequestUserAssocs] PRIMARY KEY CLUSTERED (IdRequestUserAssoc)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdRequest] для объекта типа таблица [dbo].[RequestUserAssocs]
--
PRINT (N'Создать индекс [IX_IdRequest] для объекта типа таблица [dbo].[RequestUserAssocs]')
GO
CREATE INDEX IX_IdRequest
  ON dbo.RequestUserAssocs (IdRequest)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdRequestUser] для объекта типа таблица [dbo].[RequestUserAssocs]
--
PRINT (N'Создать индекс [IX_IdRequestUser] для объекта типа таблица [dbo].[RequestUserAssocs]')
GO
CREATE INDEX IX_IdRequestUser
  ON dbo.RequestUserAssocs (IdRequestUser)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.RequestUserAssocs_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestUserAssocs]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestUserAssocs_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestUserAssocs]')
GO
ALTER TABLE dbo.RequestUserAssocs
  ADD CONSTRAINT [FK_dbo.RequestUserAssocs_dbo.Requests_IdRequest] FOREIGN KEY (IdRequest) REFERENCES dbo.Requests (IdRequest) ON DELETE CASCADE
GO

--
-- Создать внешний ключ [FK_dbo.RequestUserAssocs_dbo.Users_IdRequestUser] для объекта типа таблица [dbo].[RequestUserAssocs]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestUserAssocs_dbo.Users_IdRequestUser] для объекта типа таблица [dbo].[RequestUserAssocs]')
GO
ALTER TABLE dbo.RequestUserAssocs
  ADD CONSTRAINT [FK_dbo.RequestUserAssocs_dbo.Users_IdRequestUser] FOREIGN KEY (IdRequestUser) REFERENCES dbo.RequestUsers (IdRequestUser) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[RequestUserRightAssocs]
--
PRINT (N'Создать таблицу [dbo].[RequestUserRightAssocs]')
GO
CREATE TABLE dbo.RequestUserRightAssocs (
  IdAssoc int IDENTITY,
  IdResourceRight int NOT NULL,
  IdRequestRightGrantType int NOT NULL,
  Deleted bit NOT NULL,
  Descirption nvarchar(max) NULL,
  IdRequestUserAssoc int NOT NULL DEFAULT (0),
  GrantedFrom datetime NULL,
  GrantedTo datetime NULL,
  CONSTRAINT [PK_dbo.RequestUserRightAssocs] PRIMARY KEY CLUSTERED (IdAssoc)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IDX_RequestUserRightAssocs_IdRequestRightGrantType] для объекта типа таблица [dbo].[RequestUserRightAssocs]
--
PRINT (N'Создать индекс [IDX_RequestUserRightAssocs_IdRequestRightGrantType] для объекта типа таблица [dbo].[RequestUserRightAssocs]')
GO
CREATE INDEX IDX_RequestUserRightAssocs_IdRequestRightGrantType
  ON dbo.RequestUserRightAssocs (IdRequestRightGrantType)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdRequestUserAssoc] для объекта типа таблица [dbo].[RequestUserRightAssocs]
--
PRINT (N'Создать индекс [IX_IdRequestUserAssoc] для объекта типа таблица [dbo].[RequestUserRightAssocs]')
GO
CREATE INDEX IX_IdRequestUserAssoc
  ON dbo.RequestUserRightAssocs (IdRequestUserAssoc, Deleted)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResourceRight_IdRequestRightGrantType_Deleted] для объекта типа таблица [dbo].[RequestUserRightAssocs]
--
PRINT (N'Создать индекс [IX_IdResourceRight_IdRequestRightGrantType_Deleted] для объекта типа таблица [dbo].[RequestUserRightAssocs]')
GO
CREATE INDEX IX_IdResourceRight_IdRequestRightGrantType_Deleted
  ON dbo.RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.RequestUserRightAssocs_dbo.RequestRightGrantTypes_IdRequestRightGrantType] для объекта типа таблица [dbo].[RequestUserRightAssocs]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestUserRightAssocs_dbo.RequestRightGrantTypes_IdRequestRightGrantType] для объекта типа таблица [dbo].[RequestUserRightAssocs]')
GO
ALTER TABLE dbo.RequestUserRightAssocs
  ADD CONSTRAINT [FK_dbo.RequestUserRightAssocs_dbo.RequestRightGrantTypes_IdRequestRightGrantType] FOREIGN KEY (IdRequestRightGrantType) REFERENCES dbo.RequestRightGrantTypes (IdRequestRightGrantType)
GO

--
-- Создать внешний ключ [FK_dbo.RequestUserRightAssocs_dbo.RequestUserAssocs_IdRequestUserAssoc] для объекта типа таблица [dbo].[RequestUserRightAssocs]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestUserRightAssocs_dbo.RequestUserAssocs_IdRequestUserAssoc] для объекта типа таблица [dbo].[RequestUserRightAssocs]')
GO
ALTER TABLE dbo.RequestUserRightAssocs
  ADD CONSTRAINT [FK_dbo.RequestUserRightAssocs_dbo.RequestUserAssocs_IdRequestUserAssoc] FOREIGN KEY (IdRequestUserAssoc) REFERENCES dbo.RequestUserAssocs (IdRequestUserAssoc) ON DELETE CASCADE
GO

--
-- Создать внешний ключ [FK_dbo.RequestUserRightAssocs_dbo.ResourceRights_IdResourceRight] для объекта типа таблица [dbo].[RequestUserRightAssocs]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestUserRightAssocs_dbo.ResourceRights_IdResourceRight] для объекта типа таблица [dbo].[RequestUserRightAssocs]')
GO
ALTER TABLE dbo.RequestUserRightAssocs
  ADD CONSTRAINT [FK_dbo.RequestUserRightAssocs_dbo.ResourceRights_IdResourceRight] FOREIGN KEY (IdResourceRight) REFERENCES dbo.ResourceRights (IdResourceRight)
GO

--
-- Создать таблицу [dbo].[DelegationRequestUsersExtInfo]
--
PRINT (N'Создать таблицу [dbo].[DelegationRequestUsersExtInfo]')
GO
CREATE TABLE dbo.DelegationRequestUsersExtInfo (
  IdRequestUserAssoc int NOT NULL,
  IdDelegateToUser int NOT NULL,
  DelegateFromDate datetime NOT NULL,
  DelegateToDate datetime NOT NULL,
  Deleted bit NOT NULL,
  CONSTRAINT [PK_dbo.DelegationRequestUsersExtInfo] PRIMARY KEY CLUSTERED (IdRequestUserAssoc)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdDelegateToUser] для объекта типа таблица [dbo].[DelegationRequestUsersExtInfo]
--
PRINT (N'Создать индекс [IX_IdDelegateToUser] для объекта типа таблица [dbo].[DelegationRequestUsersExtInfo]')
GO
CREATE INDEX IX_IdDelegateToUser
  ON dbo.DelegationRequestUsersExtInfo (IdDelegateToUser)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdRequestUserAssoc] для объекта типа таблица [dbo].[DelegationRequestUsersExtInfo]
--
PRINT (N'Создать индекс [IX_IdRequestUserAssoc] для объекта типа таблица [dbo].[DelegationRequestUsersExtInfo]')
GO
CREATE INDEX IX_IdRequestUserAssoc
  ON dbo.DelegationRequestUsersExtInfo (IdRequestUserAssoc)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.DelegationRequestUsersExtInfo_dbo.RequestUserAssocs_IdRequestUserAssoc] для объекта типа таблица [dbo].[DelegationRequestUsersExtInfo]
--
PRINT (N'Создать внешний ключ [FK_dbo.DelegationRequestUsersExtInfo_dbo.RequestUserAssocs_IdRequestUserAssoc] для объекта типа таблица [dbo].[DelegationRequestUsersExtInfo]')
GO
ALTER TABLE dbo.DelegationRequestUsersExtInfo
  ADD CONSTRAINT [FK_dbo.DelegationRequestUsersExtInfo_dbo.RequestUserAssocs_IdRequestUserAssoc] FOREIGN KEY (IdRequestUserAssoc) REFERENCES dbo.RequestUserAssocs (IdRequestUserAssoc)
GO

--
-- Создать внешний ключ [FK_dbo.DelegationRequestUsersExtInfo_dbo.RequestUsers_IdDelegateToUser] для объекта типа таблица [dbo].[DelegationRequestUsersExtInfo]
--
PRINT (N'Создать внешний ключ [FK_dbo.DelegationRequestUsersExtInfo_dbo.RequestUsers_IdDelegateToUser] для объекта типа таблица [dbo].[DelegationRequestUsersExtInfo]')
GO
ALTER TABLE dbo.DelegationRequestUsersExtInfo
  ADD CONSTRAINT [FK_dbo.DelegationRequestUsersExtInfo_dbo.RequestUsers_IdDelegateToUser] FOREIGN KEY (IdDelegateToUser) REFERENCES dbo.RequestUsers (IdRequestUser) ON DELETE CASCADE
GO

--
-- Создать процедуру [dbo].[UpdateGrantDates]
--
GO
PRINT (N'Создать процедуру [dbo].[UpdateGrantDates]')
GO
CREATE PROCEDURE dbo.UpdateGrantDates
AS 
  DECLARE @IdAssoc INT, 
    @IdResourceRight INT,
    @IdRequestRightGrantType INT,
    @IdRequestUser INT,
    @IdRequest INT,
    @CurrentRequestStateDate DATETIME,
    @DelegateFromDate DATETIME,
    @DelegateToDate DATETIME,
    @RevokeDate DATETIME, 
    @DismissDate DATETIME;

  DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
  	SELECT rura.IdAssoc, 
  rura.IdResourceRight, 
  rura.IdRequestRightGrantType,
  rua.IdRequestUser,
  r.IdRequest,
  r.CurrentRequestStateDate,
  druei.DelegateFromDate,
  druei.DelegateToDate
FROM dbo.RequestUserRightAssocs rura
  INNER JOIN RequestUserAssocs rua ON rura.IdRequestUserAssoc = rua.IdRequestUserAssoc
  INNER JOIN Requests r ON rua.IdRequest = r.IdRequest
  LEFT JOIN DelegationRequestUsersExtInfo druei ON rua.IdRequestUserAssoc = druei.IdRequestUserAssoc
WHERE rura.Deleted <> 1 AND r.IdCurrentRequestStateType = 4 AND rua.Deleted <> 1 AND r.Deleted <> 1
  AND (druei.Deleted  IS NULL OR druei.Deleted <> 1) AND rura.IdRequestRightGrantType IN (1, 3);
  
  CREATE TABLE #TmpAssocDates (IdAssoc INT, GrantedFrom DATETIME, GrantedTo DateTime);

  OPEN cur
  
  FETCH NEXT FROM cur INTO @IdAssoc, @IdResourceRight,
    @IdRequestRightGrantType, @IdRequestUser, @IdRequest,
    @CurrentRequestStateDate, @DelegateFromDate, @DelegateToDate;
  
  WHILE @@FETCH_STATUS = 0 BEGIN
  	IF(@IdRequestRightGrantType = 1) 
    BEGIN
      SET @RevokeDate = NULL;
      SET @DismissDate = NULL;
      SELECT @RevokeDate = MIN(r.CurrentRequestStateDate) FROM dbo.RequestUserRightAssocs rura
        INNER JOIN RequestUserAssocs rua ON rura.IdRequestUserAssoc = rua.IdRequestUserAssoc
        INNER JOIN Requests r ON rua.IdRequest = r.IdRequest
      WHERE rura.Deleted <> 1 AND r.IdCurrentRequestStateType = 4 AND 
        rua.Deleted <> 1 AND r.Deleted <> 1 AND r.IdRequestType IN (1, 2) AND 
        rura.IdRequestRightGrantType = 2 AND
        rua.IdRequestUser = @IdRequestUser AND 
        rura.IdResourceRight = @IdResourceRight AND
        r.CurrentRequestStateDate > @CurrentRequestStateDate;
      
      SELECT @DismissDate = MIN(r.CurrentRequestStateDate) 
      FROM RequestUserAssocs rua
        INNER JOIN Requests r ON rua.IdRequest = r.IdRequest
      WHERE r.IdCurrentRequestStateType = 4 AND 
        rua.Deleted <> 1 AND r.Deleted <> 1 AND r.IdRequestType = 3 AND 
        rua.IdRequestUser = @IdRequestUser AND r.CurrentRequestStateDate > @CurrentRequestStateDate;

      INSERT INTO #TmpAssocDates VALUES(@IdAssoc, @CurrentRequestStateDate, 
        CASE WHEN (@RevokeDate IS NULL OR @RevokeDate > @DismissDate) 
          THEN @DismissDate 
          WHEN (@DismissDate IS NULL OR @DismissDate >= @RevokeDate) THEN @RevokeDate END);
    END
    ELSE IF (@IdRequestRightGrantType = 3)
    BEGIN
      INSERT INTO #TmpAssocDates VALUES(@IdAssoc, @DelegateFromDate, @DelegateToDate);
    END;
  
  	FETCH NEXT FROM cur INTO @IdAssoc, @IdResourceRight,
      @IdRequestRightGrantType, @IdRequestUser, @IdRequest,
      @CurrentRequestStateDate, @DelegateFromDate, @DelegateToDate;
  
  END
  
  CLOSE cur
  DEALLOCATE cur

  UPDATE rura
  SET rura.GrantedFrom = tad.GrantedFrom, rura.GrantedTo = tad.GrantedTo
  FROM #TmpAssocDates tad INNER JOIN RequestUserRightAssocs rura ON tad.IdAssoc = rura.IdAssoc;

  DROP TABLE #TmpAssocDates;
GO

--
-- Создать процедуру [dbo].[CheckGrantDates]
--
GO
PRINT (N'Создать процедуру [dbo].[CheckGrantDates]')
GO
CREATE PROCEDURE dbo.CheckGrantDates
AS 
  DECLARE @IdAssoc INT, 
    @IdResourceRight INT,
    @IdRequestRightGrantType INT,
    @IdRequestUser INT,
    @IdRequest INT,
    @CurrentRequestStateDate DATETIME,
    @DelegateFromDate DATETIME,
    @DelegateToDate DATETIME,
    @GrantedFromDate DATETIME,
    @GrantedToDate DATETIME,
    @RevokeDate DATETIME, 
    @DismissDate DATETIME;

  DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
  	SELECT rura.IdAssoc, 
  rura.IdResourceRight, 
  rura.IdRequestRightGrantType,
  rua.IdRequestUser,
  r.IdRequest,
  r.CurrentRequestStateDate,
  druei.DelegateFromDate,
  druei.DelegateToDate
FROM dbo.RequestUserRightAssocs rura
  INNER JOIN RequestUserAssocs rua ON rura.IdRequestUserAssoc = rua.IdRequestUserAssoc
  INNER JOIN Requests r ON rua.IdRequest = r.IdRequest
  LEFT JOIN DelegationRequestUsersExtInfo druei ON rua.IdRequestUserAssoc = druei.IdRequestUserAssoc
WHERE rura.Deleted <> 1 AND r.IdCurrentRequestStateType = 4 AND rua.Deleted <> 1 AND r.Deleted <> 1
  AND (druei.Deleted  IS NULL OR druei.Deleted <> 1) AND rura.IdRequestRightGrantType IN (1, 3);

  DECLARE cur2 CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
  SELECT rura.IdAssoc, 
  rura.IdResourceRight, 
  rura.IdRequestRightGrantType,
  rua.IdRequestUser,
  r.IdRequest,
  r.CurrentRequestStateDate,
  rura.GrantedFrom,
  rura.GrantedTo
FROM dbo.RequestUserRightAssocs rura
  INNER JOIN RequestUserAssocs rua ON rura.IdRequestUserAssoc = rua.IdRequestUserAssoc
  INNER JOIN Requests r ON rua.IdRequest = r.IdRequest
WHERE rura.Deleted <> 1 AND r.IdCurrentRequestStateType = 4 AND rua.Deleted <> 1 AND r.Deleted <> 1
  AND rura.IdRequestRightGrantType IN (1, 3) AND r.IdRequestType IN (1, 2)
  AND rura.GrantedTo IS NOT NULL;
  
  CREATE TABLE #TmpAssocDates  (IdAssoc INT, GrantedFrom DATETIME, GrantedTo DateTime);
  CREATE TABLE #TmpAssocDates2 (IdAssoc INT, GrantedFrom DATETIME, GrantedTo DateTime);

  OPEN cur
  
  FETCH NEXT FROM cur INTO @IdAssoc, @IdResourceRight,
    @IdRequestRightGrantType, @IdRequestUser, @IdRequest,
    @CurrentRequestStateDate, @DelegateFromDate, @DelegateToDate;
  
  WHILE @@FETCH_STATUS = 0 BEGIN
  	IF(@IdRequestRightGrantType = 1) 
    BEGIN
      SET @RevokeDate = NULL;
      SET @DismissDate = NULL;
      SELECT @RevokeDate = MIN(r.CurrentRequestStateDate) FROM dbo.RequestUserRightAssocs rura
        INNER JOIN RequestUserAssocs rua ON rura.IdRequestUserAssoc = rua.IdRequestUserAssoc
        INNER JOIN Requests r ON rua.IdRequest = r.IdRequest
      WHERE rura.Deleted <> 1 AND r.IdCurrentRequestStateType = 4 AND 
        rua.Deleted <> 1 AND r.Deleted <> 1 AND r.IdRequestType IN (1, 2) AND 
        rura.IdRequestRightGrantType = 2 AND
        rua.IdRequestUser = @IdRequestUser AND 
        rura.IdResourceRight = @IdResourceRight AND
        r.CurrentRequestStateDate > @CurrentRequestStateDate;
      
      SELECT @DismissDate = MIN(r.CurrentRequestStateDate) 
      FROM RequestUserAssocs rua
        INNER JOIN Requests r ON rua.IdRequest = r.IdRequest
      WHERE r.IdCurrentRequestStateType = 4 AND 
        rua.Deleted <> 1 AND r.Deleted <> 1 AND r.IdRequestType = 3 AND 
        rua.IdRequestUser = @IdRequestUser AND r.CurrentRequestStateDate > @CurrentRequestStateDate;

      INSERT INTO #TmpAssocDates VALUES(@IdAssoc, @CurrentRequestStateDate, 
        CASE WHEN (@RevokeDate IS NULL OR @RevokeDate > @DismissDate) 
          THEN @DismissDate 
          WHEN (@DismissDate IS NULL OR @DismissDate >= @RevokeDate) THEN @RevokeDate END);
    END
    ELSE IF (@IdRequestRightGrantType = 3)
    BEGIN
      INSERT INTO #TmpAssocDates VALUES(@IdAssoc, @DelegateFromDate, @DelegateToDate);
    END;
  
  	FETCH NEXT FROM cur INTO @IdAssoc, @IdResourceRight,
      @IdRequestRightGrantType, @IdRequestUser, @IdRequest,
      @CurrentRequestStateDate, @DelegateFromDate, @DelegateToDate;
  
  END
  
  CLOSE cur
  DEALLOCATE cur

  OPEN cur2
  
  FETCH NEXT FROM cur2 INTO @IdAssoc, @IdResourceRight,
    @IdRequestRightGrantType, @IdRequestUser, @IdRequest,
    @CurrentRequestStateDate, @GrantedFromDate, @GrantedToDate;

  WHILE @@FETCH_STATUS = 0 BEGIN
    SET @RevokeDate = NULL;
    SET @DismissDate = NULL;
    SELECT @RevokeDate = MIN(r.CurrentRequestStateDate) FROM dbo.RequestUserRightAssocs rura
      INNER JOIN RequestUserAssocs rua ON rura.IdRequestUserAssoc = rua.IdRequestUserAssoc
      INNER JOIN Requests r ON rua.IdRequest = r.IdRequest
    WHERE rura.Deleted <> 1 AND r.IdCurrentRequestStateType = 4 AND 
      rua.Deleted <> 1 AND r.Deleted <> 1 AND r.IdRequestType IN (1, 2) AND 
      rura.IdRequestRightGrantType = 2 AND
      rua.IdRequestUser = @IdRequestUser AND 
      rura.IdResourceRight = @IdResourceRight AND
      r.CurrentRequestStateDate > @CurrentRequestStateDate;
    
    SELECT @DismissDate = MIN(r.CurrentRequestStateDate) 
    FROM RequestUserAssocs rua
      INNER JOIN Requests r ON rua.IdRequest = r.IdRequest
    WHERE r.IdCurrentRequestStateType = 4 AND 
      rua.Deleted <> 1 AND r.Deleted <> 1 AND r.IdRequestType = 3 AND 
      rua.IdRequestUser = @IdRequestUser AND r.CurrentRequestStateDate > @CurrentRequestStateDate;

    IF (@RevokeDate IS NULL AND @DismissDate IS NULL)
    BEGIN
      INSERT INTO #TmpAssocDates2 VALUES(@IdAssoc, @CurrentRequestStateDate, NULL);
    END

    FETCH NEXT FROM cur2 INTO @IdAssoc, @IdResourceRight,
        @IdRequestRightGrantType, @IdRequestUser, @IdRequest,
        @CurrentRequestStateDate, @GrantedFromDate, @GrantedToDate;
  END
  
  CLOSE cur2
  DEALLOCATE cur2

  SELECT rua.IdRequest, rua.IdRequestUser, rura.IdAssoc,
    rura.GrantedFrom AS SettedGrantedFrom, rura.GrantedTo AS SettedGrantedTo,
    tad.GrantedFrom AS ActualGrantedFrom, tad.GrantedTo AS ActualGrantedTo
  FROM #TmpAssocDates tad INNER JOIN RequestUserRightAssocs rura ON tad.IdAssoc = rura.IdAssoc
    INNER JOIN RequestUserAssocs rua ON rura.IdRequestUserAssoc = rua.IdRequestUserAssoc
  WHERE rura.Deleted <> 1 AND 
    ((rura.GrantedFrom IS NULL AND tad.GrantedFrom IS NOT NULL) OR 
     (rura.GrantedFrom IS NOT NULL AND tad.GrantedFrom IS NULL) OR 
     (rura.GrantedTo IS NULL AND tad.GrantedTo IS NOT NULL) OR
     (rura.GrantedTo IS NOT NULL AND tad.GrantedTo IS NULL) OR
      rura.GrantedFrom <> tad.GrantedFrom OR rura.GrantedTo <> tad.GrantedTo)
  UNION ALL
  SELECT rua.IdRequest, rua.IdRequestUser, rura.IdAssoc,
    rura.GrantedFrom AS SettedGrantedFrom, rura.GrantedTo AS SettedGrantedTo,
    tad.GrantedFrom AS ActualGrantedFrom, tad.GrantedTo AS ActualGrantedTo
  FROM #TmpAssocDates2 tad INNER JOIN RequestUserRightAssocs rura ON tad.IdAssoc = rura.IdAssoc
    INNER JOIN RequestUserAssocs rua ON rura.IdRequestUserAssoc = rua.IdRequestUserAssoc
  WHERE rura.Deleted <> 1;


  DROP TABLE #TmpAssocDates;
  DROP TABLE #TmpAssocDates2;
GO

--
-- Создать таблицу [dbo].[RequestStates]
--
PRINT (N'Создать таблицу [dbo].[RequestStates]')
GO
CREATE TABLE dbo.RequestStates (
  IdRequestState int IDENTITY,
  IdRequestStateType int NOT NULL,
  IdRequest int NOT NULL,
  Date datetime NOT NULL,
  Deleted bit NOT NULL,
  CONSTRAINT [PK_dbo.RequestStates] PRIMARY KEY CLUSTERED (IdRequestState)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IDX_RequestStates_IdRequestStateType] для объекта типа таблица [dbo].[RequestStates]
--
PRINT (N'Создать индекс [IDX_RequestStates_IdRequestStateType] для объекта типа таблица [dbo].[RequestStates]')
GO
CREATE INDEX IDX_RequestStates_IdRequestStateType
  ON dbo.RequestStates (IdRequestStateType)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_RequestStates] для объекта типа таблица [dbo].[RequestStates]
--
PRINT (N'Создать индекс [IX_RequestStates] для объекта типа таблица [dbo].[RequestStates]')
GO
CREATE INDEX IX_RequestStates
  ON dbo.RequestStates (IdRequest, IdRequestState, IdRequestStateType, Date)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_RequestStates_IdRequest_IdRequestStateType_Date_Deleted] для объекта типа таблица [dbo].[RequestStates]
--
PRINT (N'Создать индекс [IX_RequestStates_IdRequest_IdRequestStateType_Date_Deleted] для объекта типа таблица [dbo].[RequestStates]')
GO
CREATE INDEX IX_RequestStates_IdRequest_IdRequestStateType_Date_Deleted
  ON dbo.RequestStates (Deleted)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.RequestStates_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestStates]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestStates_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestStates]')
GO
ALTER TABLE dbo.RequestStates
  ADD CONSTRAINT [FK_dbo.RequestStates_dbo.Requests_IdRequest] FOREIGN KEY (IdRequest) REFERENCES dbo.Requests (IdRequest) ON DELETE CASCADE
GO

--
-- Создать внешний ключ [FK_dbo.RequestStates_dbo.RequestStateTypes_IdRequestStateType] для объекта типа таблица [dbo].[RequestStates]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestStates_dbo.RequestStateTypes_IdRequestStateType] для объекта типа таблица [dbo].[RequestStates]')
GO
ALTER TABLE dbo.RequestStates
  ADD CONSTRAINT [FK_dbo.RequestStates_dbo.RequestStateTypes_IdRequestStateType] FOREIGN KEY (IdRequestStateType) REFERENCES dbo.RequestStateTypes (IdRequestStateType)
GO

--
-- Создать процедуру [dbo].[import_universal]
--
GO
PRINT (N'Создать процедуру [dbo].[import_universal]')
GO
CREATE PROCEDURE dbo.import_universal
AS 
DECLARE @max_users_per_request INT
DECLARE @current_users_per_request INT
DECLARE @request_id INT
DECLARE @request_user_id INT
DECLARE @request_user_assoc_id INT
DECLARE @resource_right_id INT
DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
	SELECT t.IdRequestUser, t.IdRight
	FROM dbo._tmp t
SET @current_users_per_request = 10;
SET @max_users_per_request = 10;

OPEN cur        
FETCH NEXT FROM cur INTO @request_user_id, @resource_right_id
        
WHILE @@FETCH_STATUS = 0 BEGIN
  IF(@max_users_per_request = @current_users_per_request)
  BEGIN
    INSERT INTO Requests (Description, IdUser, IdRequestType, Deleted, CurrentRequestStateDate, IdCurrentRequestStateType)
    VALUES ('Реорганизация сетевых папок КГ', 1, 2, 0, CAST('2017-06-10' AS DATETIME), 4);
    SET @request_id = @@identity
    INSERT INTO RequestStates (IdRequestStateType, IdRequest, Date, Deleted)
    VALUES (4, @request_id, CAST('2017-06-10' AS DATETIME), 0);
    SET @current_users_per_request = 0
  END;
  SET @current_users_per_request = @current_users_per_request + 1;
  
  INSERT INTO RequestUserAssocs (IdRequest, IdRequestUser, Deleted, Description)
  VALUES (@request_id, @request_user_id, 0, NULL);
  SET @request_user_assoc_id = @@identity
  
  INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
  VALUES (@resource_right_id, 1, 0, NULL, @request_user_assoc_id);

	FETCH NEXT FROM cur INTO @request_user_id, @resource_right_id

END

CLOSE cur
DEALLOCATE cur
GO

--
-- Создать процедуру [dbo].[import_letograf]
--
GO
PRINT (N'Создать процедуру [dbo].[import_letograf]')
GO
CREATE PROCEDURE dbo.import_letograf
AS 
DECLARE @login_var VARCHAR(512)
DECLARE @roles_var VARCHAR(1024)
DECLARE @max_users_per_request INT
DECLARE @current_users_per_request INT
DECLARE @request_id INT
DECLARE @request_user_id INT
DECLARE @request_user_assoc_id INT
DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
	SELECT login, roles
	FROM dbo.__let_users_2_v2
SET @current_users_per_request = 10;
SET @max_users_per_request = 10;

OPEN cur        
FETCH NEXT FROM cur INTO @login_var, @roles_var
        
WHILE @@FETCH_STATUS = 0 BEGIN
  IF(@max_users_per_request = @current_users_per_request)
  BEGIN
    INSERT INTO Requests (Description, IdUser, IdRequestType, Deleted)
    VALUES (NULL, 1, 2, 0);
    SET @request_id = @@identity
    INSERT INTO RequestStates (IdRequestStateType, IdRequest, Date, Deleted)
    VALUES (4, @request_id, CAST('2017-04-01' AS DATETIME), 0);
    SET @current_users_per_request = 0
  END;
  SET @current_users_per_request = @current_users_per_request + 1;
  SELECT TOP 1 @request_user_id = ru.IdRequestUser
  FROM RequestUsers ru
  WHERE ru.Deleted <> 1 AND LOWER(ru.Login) = @login_var;
  
  INSERT INTO RequestUserAssocs (IdRequest, IdRequestUser, Deleted, Description)
  VALUES (@request_id, @request_user_id, 0, NULL);
  SET @request_user_assoc_id = @@identity
  
  IF (CHARINDEX('Ответственный за ведение справочника контрагентов', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (142, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Оператор', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (143, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Делопроизводитель мэра (МПА)', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (144, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Контролер делопроизводства', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (145, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Контролер ОГ и МУ', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (146, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Ответственные за просмотр всех МПА', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (147, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Делопроизводитель для регистрации МУ', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (148, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Руководитель', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (149, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Делопроизводитель', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (150, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Специалист информационно-аналитического отдела', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (151, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Специалист', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (152, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Специалист ответственный за формирование отчетов', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (696, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Доступ к документам подразделения', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (700, 1, 0, NULL, @request_user_assoc_id);
  END

  IF (CHARINDEX('Доступ к документам отдела', @roles_var) <> 0)
  BEGIN
    INSERT INTO RequestUserRightAssocs (IdResourceRight, IdRequestRightGrantType, Deleted, Descirption, IdRequestUserAssoc)
    VALUES (701, 1, 0, NULL, @request_user_assoc_id);
  END

	FETCH NEXT FROM cur INTO @login_var, @roles_var

END

CLOSE cur
DEALLOCATE cur
GO

--
-- Создать представление [dbo].[v_RequestsLastState]
--
GO
PRINT (N'Создать представление [dbo].[v_RequestsLastState]')
GO
CREATE VIEW dbo.v_RequestsLastState 
AS SELECT rs4.*
FROM 
RequestStates rs4 JOIN 
(
SELECT rs.IdRequest, MAX(rs.IdRequestState) AS IdRequestState
FROM RequestStates rs
WHERE rs.Deleted <> 1
GROUP BY rs.IdRequest) rs ON rs.IdRequestState = rs4.IdRequestState
GO

--
-- Создать представление [dbo].[v_LastExcludeRequestByUser]
--
GO
PRINT (N'Создать представление [dbo].[v_LastExcludeRequestByUser]')
GO
CREATE VIEW dbo.v_LastExcludeRequestByUser 
AS SELECT rua.IdRequestUser, v.Date, MAX(r.IdRequest) AS IdRequest
FROM Requests r
  INNER JOIN RequestUserAssocs rua ON r.IdRequest = rua.IdRequest
  INNER JOIN v_RequestsLastState rs ON r.IdRequest = rs.IdRequest
  INNER JOIN (SELECT MAX(rs.Date) AS Date, rua.IdRequestUser
FROM Requests r
  INNER JOIN RequestUserAssocs rua ON r.IdRequest = rua.IdRequest
  INNER JOIN v_RequestsLastState rs ON r.IdRequest = rs.IdRequest
WHERE r.Deleted <> 1 AND r.IdRequestType = 3 AND rua.Deleted <> 1
  AND rs.IdRequestStateType = 4
GROUP BY rua.IdRequestUser) v ON rua.IdRequestUser = v.IdRequestUser AND rs.Date = v.Date
WHERE r.Deleted <> 1 AND r.IdRequestType = 3 AND rua.Deleted <> 1
  AND rs.IdRequestStateType = 4
GROUP BY rua.IdRequestUser, v.Date
GO

--
-- Создать представление [dbo].[v_LastChangeRightsRequestByUser]
--
GO
PRINT (N'Создать представление [dbo].[v_LastChangeRightsRequestByUser]')
GO
CREATE VIEW dbo.v_LastChangeRightsRequestByUser 
AS SELECT rua.IdRequestUser, v.Date, MAX(r.IdRequest) AS IdRequest
FROM Requests r
  INNER JOIN RequestUserAssocs rua ON r.IdRequest = rua.IdRequest
  INNER JOIN v_RequestsLastState rs ON r.IdRequest = rs.IdRequest
  INNER JOIN (SELECT MAX(rs.Date) AS Date, rua.IdRequestUser
FROM Requests r
  INNER JOIN RequestUserAssocs rua ON r.IdRequest = rua.IdRequest
  INNER JOIN v_RequestsLastState rs ON r.IdRequest = rs.IdRequest
WHERE r.Deleted <> 1 AND r.IdRequestType <> 3 AND rua.Deleted <> 1
  AND rs.IdRequestStateType = 4
GROUP BY rua.IdRequestUser) v ON rua.IdRequestUser = v.IdRequestUser AND rs.Date = v.Date
WHERE r.Deleted <> 1 AND r.IdRequestType <> 3 AND rua.Deleted <> 1
  AND rs.IdRequestStateType = 4
GROUP BY rua.IdRequestUser, v.Date
GO

--
-- Создать таблицу [dbo].[RequestGlpiAssocs]
--
PRINT (N'Создать таблицу [dbo].[RequestGlpiAssocs]')
GO
CREATE TABLE dbo.RequestGlpiAssocs (
  IdRequest int NOT NULL,
  IdGlpiTicket int NOT NULL,
  CONSTRAINT [PK_dbo.RequestGlpiAssocs] PRIMARY KEY CLUSTERED (IdRequest, IdGlpiTicket)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdRequest] для объекта типа таблица [dbo].[RequestGlpiAssocs]
--
PRINT (N'Создать индекс [IX_IdRequest] для объекта типа таблица [dbo].[RequestGlpiAssocs]')
GO
CREATE INDEX IX_IdRequest
  ON dbo.RequestGlpiAssocs (IdRequest)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.RequestGlpiAssocs_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestGlpiAssocs]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestGlpiAssocs_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestGlpiAssocs]')
GO
ALTER TABLE dbo.RequestGlpiAssocs
  ADD CONSTRAINT [FK_dbo.RequestGlpiAssocs_dbo.Requests_IdRequest] FOREIGN KEY (IdRequest) REFERENCES dbo.Requests (IdRequest) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[RequestExtComments]
--
PRINT (N'Создать таблицу [dbo].[RequestExtComments]')
GO
CREATE TABLE dbo.RequestExtComments (
  IdComment int IDENTITY,
  Comment nvarchar(max) NOT NULL,
  DateOfWriting datetime NOT NULL,
  IdRequest int NOT NULL,
  IdUser int NOT NULL,
  CONSTRAINT [PK_dbo.RequestExtComments] PRIMARY KEY CLUSTERED (IdComment)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdRequest] для объекта типа таблица [dbo].[RequestExtComments]
--
PRINT (N'Создать индекс [IX_IdRequest] для объекта типа таблица [dbo].[RequestExtComments]')
GO
CREATE INDEX IX_IdRequest
  ON dbo.RequestExtComments (IdRequest)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[RequestExtComments]
--
PRINT (N'Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[RequestExtComments]')
GO
CREATE INDEX IX_IdUser
  ON dbo.RequestExtComments (IdUser)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.RequestExtComments_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[RequestExtComments]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestExtComments_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[RequestExtComments]')
GO
ALTER TABLE dbo.RequestExtComments
  ADD CONSTRAINT [FK_dbo.RequestExtComments_dbo.AclUsers_IdUser] FOREIGN KEY (IdUser) REFERENCES dbo.AclUsers (IdUser)
GO

--
-- Создать внешний ключ [FK_dbo.RequestExtComments_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestExtComments]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestExtComments_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestExtComments]')
GO
ALTER TABLE dbo.RequestExtComments
  ADD CONSTRAINT [FK_dbo.RequestExtComments_dbo.Requests_IdRequest] FOREIGN KEY (IdRequest) REFERENCES dbo.Requests (IdRequest) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[RequestExtCommentNotifications]
--
PRINT (N'Создать таблицу [dbo].[RequestExtCommentNotifications]')
GO
CREATE TABLE dbo.RequestExtCommentNotifications (
  IdNotification int IDENTITY,
  DateModification datetime NOT NULL,
  IdComment int NOT NULL,
  IdUser int NOT NULL,
  CONSTRAINT [PK_dbo.RequestExtCommentNotifications] PRIMARY KEY CLUSTERED (IdNotification)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdComment] для объекта типа таблица [dbo].[RequestExtCommentNotifications]
--
PRINT (N'Создать индекс [IX_IdComment] для объекта типа таблица [dbo].[RequestExtCommentNotifications]')
GO
CREATE INDEX IX_IdComment
  ON dbo.RequestExtCommentNotifications (IdComment)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[RequestExtCommentNotifications]
--
PRINT (N'Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[RequestExtCommentNotifications]')
GO
CREATE INDEX IX_IdUser
  ON dbo.RequestExtCommentNotifications (IdUser)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.RequestExtCommentNotifications_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[RequestExtCommentNotifications]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestExtCommentNotifications_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[RequestExtCommentNotifications]')
GO
ALTER TABLE dbo.RequestExtCommentNotifications
  ADD CONSTRAINT [FK_dbo.RequestExtCommentNotifications_dbo.AclUsers_IdUser] FOREIGN KEY (IdUser) REFERENCES dbo.AclUsers (IdUser) ON DELETE CASCADE
GO

--
-- Создать внешний ключ [FK_dbo.RequestExtCommentNotifications_dbo.RequestExtComments_IdComment] для объекта типа таблица [dbo].[RequestExtCommentNotifications]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestExtCommentNotifications_dbo.RequestExtComments_IdComment] для объекта типа таблица [dbo].[RequestExtCommentNotifications]')
GO
ALTER TABLE dbo.RequestExtCommentNotifications
  ADD CONSTRAINT [FK_dbo.RequestExtCommentNotifications_dbo.RequestExtComments_IdComment] FOREIGN KEY (IdComment) REFERENCES dbo.RequestExtComments (IdComment) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[RequestExecutors]
--
PRINT (N'Создать таблицу [dbo].[RequestExecutors]')
GO
CREATE TABLE dbo.RequestExecutors (
  IdRequest int NOT NULL,
  Login nvarchar(256) NOT NULL,
  AlexApplicRequestNum int NOT NULL DEFAULT (0),
  CONSTRAINT [PK_dbo.RequestExecutors] PRIMARY KEY CLUSTERED (IdRequest, Login, AlexApplicRequestNum)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdRequest] для объекта типа таблица [dbo].[RequestExecutors]
--
PRINT (N'Создать индекс [IX_IdRequest] для объекта типа таблица [dbo].[RequestExecutors]')
GO
CREATE INDEX IX_IdRequest
  ON dbo.RequestExecutors (IdRequest)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.RequestExecutors_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestExecutors]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestExecutors_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestExecutors]')
GO
ALTER TABLE dbo.RequestExecutors
  ADD CONSTRAINT [FK_dbo.RequestExecutors_dbo.Requests_IdRequest] FOREIGN KEY (IdRequest) REFERENCES dbo.Requests (IdRequest) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[RequestAgreements]
--
PRINT (N'Создать таблицу [dbo].[RequestAgreements]')
GO
CREATE TABLE dbo.RequestAgreements (
  IdRequestAgreement int IDENTITY,
  AgreementDescription nvarchar(max) NULL,
  AgreementDate datetime NULL,
  IdUser int NOT NULL,
  IdRequest int NOT NULL,
  IdAgreementState int NOT NULL,
  IdAgreementType int NOT NULL,
  SendDate datetime NULL,
  SendDescription nvarchar(max) NULL,
  CONSTRAINT [PK_dbo.RequestAgreements] PRIMARY KEY CLUSTERED (IdRequestAgreement)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdAgreementState] для объекта типа таблица [dbo].[RequestAgreements]
--
PRINT (N'Создать индекс [IX_IdAgreementState] для объекта типа таблица [dbo].[RequestAgreements]')
GO
CREATE INDEX IX_IdAgreementState
  ON dbo.RequestAgreements (IdAgreementState)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdAgreementType] для объекта типа таблица [dbo].[RequestAgreements]
--
PRINT (N'Создать индекс [IX_IdAgreementType] для объекта типа таблица [dbo].[RequestAgreements]')
GO
CREATE INDEX IX_IdAgreementType
  ON dbo.RequestAgreements (IdAgreementType)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdRequest] для объекта типа таблица [dbo].[RequestAgreements]
--
PRINT (N'Создать индекс [IX_IdRequest] для объекта типа таблица [dbo].[RequestAgreements]')
GO
CREATE INDEX IX_IdRequest
  ON dbo.RequestAgreements (IdRequest)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[RequestAgreements]
--
PRINT (N'Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[RequestAgreements]')
GO
CREATE INDEX IX_IdUser
  ON dbo.RequestAgreements (IdUser)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.RequestAgreements_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[RequestAgreements]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestAgreements_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[RequestAgreements]')
GO
ALTER TABLE dbo.RequestAgreements
  ADD CONSTRAINT [FK_dbo.RequestAgreements_dbo.AclUsers_IdUser] FOREIGN KEY (IdUser) REFERENCES dbo.AclUsers (IdUser)
GO

--
-- Создать внешний ключ [FK_dbo.RequestAgreements_dbo.RequestAgreementStates_IdAgreementState] для объекта типа таблица [dbo].[RequestAgreements]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestAgreements_dbo.RequestAgreementStates_IdAgreementState] для объекта типа таблица [dbo].[RequestAgreements]')
GO
ALTER TABLE dbo.RequestAgreements
  ADD CONSTRAINT [FK_dbo.RequestAgreements_dbo.RequestAgreementStates_IdAgreementState] FOREIGN KEY (IdAgreementState) REFERENCES dbo.RequestAgreementStates (IdAgreementState)
GO

--
-- Создать внешний ключ [FK_dbo.RequestAgreements_dbo.RequestAgreementTypes_IdAgreementType] для объекта типа таблица [dbo].[RequestAgreements]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestAgreements_dbo.RequestAgreementTypes_IdAgreementType] для объекта типа таблица [dbo].[RequestAgreements]')
GO
ALTER TABLE dbo.RequestAgreements
  ADD CONSTRAINT [FK_dbo.RequestAgreements_dbo.RequestAgreementTypes_IdAgreementType] FOREIGN KEY (IdAgreementType) REFERENCES dbo.RequestAgreementTypes (IdAgreementType)
GO

--
-- Создать внешний ключ [FK_dbo.RequestAgreements_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestAgreements]
--
PRINT (N'Создать внешний ключ [FK_dbo.RequestAgreements_dbo.Requests_IdRequest] для объекта типа таблица [dbo].[RequestAgreements]')
GO
ALTER TABLE dbo.RequestAgreements
  ADD CONSTRAINT [FK_dbo.RequestAgreements_dbo.Requests_IdRequest] FOREIGN KEY (IdRequest) REFERENCES dbo.Requests (IdRequest) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[AclDepartments]
--
PRINT (N'Создать таблицу [dbo].[AclDepartments]')
GO
CREATE TABLE dbo.AclDepartments (
  IdUser int NOT NULL,
  IdDepartment int NOT NULL,
  CONSTRAINT [PK_dbo.AclDepartments] PRIMARY KEY CLUSTERED (IdUser, IdDepartment)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdDepartment] для объекта типа таблица [dbo].[AclDepartments]
--
PRINT (N'Создать индекс [IX_IdDepartment] для объекта типа таблица [dbo].[AclDepartments]')
GO
CREATE INDEX IX_IdDepartment
  ON dbo.AclDepartments (IdDepartment)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[AclDepartments]
--
PRINT (N'Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[AclDepartments]')
GO
CREATE INDEX IX_IdUser
  ON dbo.AclDepartments (IdUser)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.AclDepartments_dbo.AclUsers_IdDepartment] для объекта типа таблица [dbo].[AclDepartments]
--
PRINT (N'Создать внешний ключ [FK_dbo.AclDepartments_dbo.AclUsers_IdDepartment] для объекта типа таблица [dbo].[AclDepartments]')
GO
ALTER TABLE dbo.AclDepartments
  ADD CONSTRAINT [FK_dbo.AclDepartments_dbo.AclUsers_IdDepartment] FOREIGN KEY (IdUser) REFERENCES dbo.AclUsers (IdUser) ON DELETE CASCADE
GO

--
-- Создать внешний ключ [FK_dbo.AclDepartments_dbo.Departments_IdUser] для объекта типа таблица [dbo].[AclDepartments]
--
PRINT (N'Создать внешний ключ [FK_dbo.AclDepartments_dbo.Departments_IdUser] для объекта типа таблица [dbo].[AclDepartments]')
GO
ALTER TABLE dbo.AclDepartments
  ADD CONSTRAINT [FK_dbo.AclDepartments_dbo.Departments_IdUser] FOREIGN KEY (IdDepartment) REFERENCES dbo.Departments (IdDepartment) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[AclAgreementResources]
--
PRINT (N'Создать таблицу [dbo].[AclAgreementResources]')
GO
CREATE TABLE dbo.AclAgreementResources (
  IdResource int NOT NULL,
  IdUser int NOT NULL,
  CONSTRAINT [PK_dbo.AclAgreementResources] PRIMARY KEY CLUSTERED (IdResource, IdUser)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[AclAgreementResources]
--
PRINT (N'Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[AclAgreementResources]')
GO
CREATE INDEX IX_IdResource
  ON dbo.AclAgreementResources (IdResource)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[AclAgreementResources]
--
PRINT (N'Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[AclAgreementResources]')
GO
CREATE INDEX IX_IdUser
  ON dbo.AclAgreementResources (IdUser)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.AclAgreementResources_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[AclAgreementResources]
--
PRINT (N'Создать внешний ключ [FK_dbo.AclAgreementResources_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[AclAgreementResources]')
GO
ALTER TABLE dbo.AclAgreementResources
  ADD CONSTRAINT [FK_dbo.AclAgreementResources_dbo.AclUsers_IdUser] FOREIGN KEY (IdUser) REFERENCES dbo.AclUsers (IdUser) ON DELETE CASCADE
GO

--
-- Создать внешний ключ [FK_dbo.AclAgreementResources_dbo.Resources_IdResource] для объекта типа таблица [dbo].[AclAgreementResources]
--
PRINT (N'Создать внешний ключ [FK_dbo.AclAgreementResources_dbo.Resources_IdResource] для объекта типа таблица [dbo].[AclAgreementResources]')
GO
ALTER TABLE dbo.AclAgreementResources
  ADD CONSTRAINT [FK_dbo.AclAgreementResources_dbo.Resources_IdResource] FOREIGN KEY (IdResource) REFERENCES dbo.Resources (IdResource) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[AclAgreementResourceRights]
--
PRINT (N'Создать таблицу [dbo].[AclAgreementResourceRights]')
GO
CREATE TABLE dbo.AclAgreementResourceRights (
  IdResourceRight int NOT NULL,
  IdUser int NOT NULL,
  CONSTRAINT [PK_dbo.AclAgreementResourceRights] PRIMARY KEY CLUSTERED (IdResourceRight, IdUser)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResourceRight] для объекта типа таблица [dbo].[AclAgreementResourceRights]
--
PRINT (N'Создать индекс [IX_IdResourceRight] для объекта типа таблица [dbo].[AclAgreementResourceRights]')
GO
CREATE INDEX IX_IdResourceRight
  ON dbo.AclAgreementResourceRights (IdResourceRight)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[AclAgreementResourceRights]
--
PRINT (N'Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[AclAgreementResourceRights]')
GO
CREATE INDEX IX_IdUser
  ON dbo.AclAgreementResourceRights (IdUser)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.AclAgreementResourceRights_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[AclAgreementResourceRights]
--
PRINT (N'Создать внешний ключ [FK_dbo.AclAgreementResourceRights_dbo.AclUsers_IdUser] для объекта типа таблица [dbo].[AclAgreementResourceRights]')
GO
ALTER TABLE dbo.AclAgreementResourceRights
  ADD CONSTRAINT [FK_dbo.AclAgreementResourceRights_dbo.AclUsers_IdUser] FOREIGN KEY (IdUser) REFERENCES dbo.AclUsers (IdUser) ON DELETE CASCADE
GO

--
-- Создать внешний ключ [FK_dbo.AclAgreementResourceRights_dbo.ResourceRights_IdResourceRight] для объекта типа таблица [dbo].[AclAgreementResourceRights]
--
PRINT (N'Создать внешний ключ [FK_dbo.AclAgreementResourceRights_dbo.ResourceRights_IdResourceRight] для объекта типа таблица [dbo].[AclAgreementResourceRights]')
GO
ALTER TABLE dbo.AclAgreementResourceRights
  ADD CONSTRAINT [FK_dbo.AclAgreementResourceRights_dbo.ResourceRights_IdResourceRight] FOREIGN KEY (IdResourceRight) REFERENCES dbo.ResourceRights (IdResourceRight) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[ActFiles]
--
PRINT (N'Создать таблицу [dbo].[ActFiles]')
GO
CREATE TABLE dbo.ActFiles (
  IdFile int IDENTITY,
  FileOriginalName nvarchar(max) NULL,
  FileContent varbinary(max) NULL,
  FileContentType nvarchar(max) NULL,
  CONSTRAINT [PK_dbo.ActFiles] PRIMARY KEY CLUSTERED (IdFile)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[ResourceUsingActs]
--
PRINT (N'Создать таблицу [dbo].[ResourceUsingActs]')
GO
CREATE TABLE dbo.ResourceUsingActs (
  IdResourceUsingAct int IDENTITY,
  IdResource int NOT NULL,
  ActType nvarchar(max) NULL,
  ActName nvarchar(max) NULL,
  ActDate datetime NULL,
  ActNumber nvarchar(max) NULL,
  IdFile int NULL DEFAULT (0),
  Deleted bit NOT NULL DEFAULT (0),
  CONSTRAINT [PK_dbo.ResourceUsingActs] PRIMARY KEY CLUSTERED (IdResourceUsingAct)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdFile] для объекта типа таблица [dbo].[ResourceUsingActs]
--
PRINT (N'Создать индекс [IX_IdFile] для объекта типа таблица [dbo].[ResourceUsingActs]')
GO
CREATE INDEX IX_IdFile
  ON dbo.ResourceUsingActs (IdFile)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceUsingActs]
--
PRINT (N'Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceUsingActs]')
GO
CREATE INDEX IX_IdResource
  ON dbo.ResourceUsingActs (IdResource)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.ResourceUsingActs_dbo.ActFiles_IdFile] для объекта типа таблица [dbo].[ResourceUsingActs]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceUsingActs_dbo.ActFiles_IdFile] для объекта типа таблица [dbo].[ResourceUsingActs]')
GO
ALTER TABLE dbo.ResourceUsingActs
  ADD CONSTRAINT [FK_dbo.ResourceUsingActs_dbo.ActFiles_IdFile] FOREIGN KEY (IdFile) REFERENCES dbo.ActFiles (IdFile)
GO

--
-- Создать внешний ключ [FK_dbo.ResourceUsingActs_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceUsingActs]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceUsingActs_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceUsingActs]')
GO
ALTER TABLE dbo.ResourceUsingActs
  ADD CONSTRAINT [FK_dbo.ResourceUsingActs_dbo.Resources_IdResource] FOREIGN KEY (IdResource) REFERENCES dbo.Resources (IdResource) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[ResourceOwnerPersonActs]
--
PRINT (N'Создать таблицу [dbo].[ResourceOwnerPersonActs]')
GO
CREATE TABLE dbo.ResourceOwnerPersonActs (
  IdResourceOwnerPersonAct int IDENTITY,
  IdResourceOwnerPerson int NOT NULL,
  ActType nvarchar(max) NULL,
  ActName nvarchar(max) NULL,
  ActDate datetime NULL,
  ActNumber nvarchar(max) NULL,
  IdFile int NULL DEFAULT (0),
  Deleted bit NOT NULL DEFAULT (0),
  CONSTRAINT [PK_dbo.ResourceOwnerPersonActs] PRIMARY KEY CLUSTERED (IdResourceOwnerPersonAct)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdFile] для объекта типа таблица [dbo].[ResourceOwnerPersonActs]
--
PRINT (N'Создать индекс [IX_IdFile] для объекта типа таблица [dbo].[ResourceOwnerPersonActs]')
GO
CREATE INDEX IX_IdFile
  ON dbo.ResourceOwnerPersonActs (IdFile)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResourceOwnerPerson] для объекта типа таблица [dbo].[ResourceOwnerPersonActs]
--
PRINT (N'Создать индекс [IX_IdResourceOwnerPerson] для объекта типа таблица [dbo].[ResourceOwnerPersonActs]')
GO
CREATE INDEX IX_IdResourceOwnerPerson
  ON dbo.ResourceOwnerPersonActs (IdResourceOwnerPerson)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.ResourceOwnerPersonActs_dbo.ActFiles_IdFile] для объекта типа таблица [dbo].[ResourceOwnerPersonActs]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceOwnerPersonActs_dbo.ActFiles_IdFile] для объекта типа таблица [dbo].[ResourceOwnerPersonActs]')
GO
ALTER TABLE dbo.ResourceOwnerPersonActs
  ADD CONSTRAINT [FK_dbo.ResourceOwnerPersonActs_dbo.ActFiles_IdFile] FOREIGN KEY (IdFile) REFERENCES dbo.ActFiles (IdFile)
GO

--
-- Создать внешний ключ [FK_dbo.ResourceOwnerPersonActs_dbo.ResourceOwnerPersons_IdResourceOwnerPerson] для объекта типа таблица [dbo].[ResourceOwnerPersonActs]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceOwnerPersonActs_dbo.ResourceOwnerPersons_IdResourceOwnerPerson] для объекта типа таблица [dbo].[ResourceOwnerPersonActs]')
GO
ALTER TABLE dbo.ResourceOwnerPersonActs
  ADD CONSTRAINT [FK_dbo.ResourceOwnerPersonActs_dbo.ResourceOwnerPersons_IdResourceOwnerPerson] FOREIGN KEY (IdResourceOwnerPerson) REFERENCES dbo.ResourceOwnerPersons (IdResourceOwnerPerson) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[ResourceOperatorPersonActs]
--
PRINT (N'Создать таблицу [dbo].[ResourceOperatorPersonActs]')
GO
CREATE TABLE dbo.ResourceOperatorPersonActs (
  IdResourceOperatorPersonAct int IDENTITY,
  IdResourceOperatorPerson int NOT NULL,
  ActType nvarchar(max) NULL,
  ActName nvarchar(max) NULL,
  ActDate datetime NULL,
  ActNumber nvarchar(max) NULL,
  IdFile int NULL DEFAULT (0),
  Deleted bit NOT NULL DEFAULT (0),
  CONSTRAINT [PK_dbo.ResourceOperatorPersonActs] PRIMARY KEY CLUSTERED (IdResourceOperatorPersonAct)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdFile] для объекта типа таблица [dbo].[ResourceOperatorPersonActs]
--
PRINT (N'Создать индекс [IX_IdFile] для объекта типа таблица [dbo].[ResourceOperatorPersonActs]')
GO
CREATE INDEX IX_IdFile
  ON dbo.ResourceOperatorPersonActs (IdFile)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResourceOperatorPerson] для объекта типа таблица [dbo].[ResourceOperatorPersonActs]
--
PRINT (N'Создать индекс [IX_IdResourceOperatorPerson] для объекта типа таблица [dbo].[ResourceOperatorPersonActs]')
GO
CREATE INDEX IX_IdResourceOperatorPerson
  ON dbo.ResourceOperatorPersonActs (IdResourceOperatorPerson)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.ResourceOperatorPersonActs_dbo.ActFiles_IdFile] для объекта типа таблица [dbo].[ResourceOperatorPersonActs]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceOperatorPersonActs_dbo.ActFiles_IdFile] для объекта типа таблица [dbo].[ResourceOperatorPersonActs]')
GO
ALTER TABLE dbo.ResourceOperatorPersonActs
  ADD CONSTRAINT [FK_dbo.ResourceOperatorPersonActs_dbo.ActFiles_IdFile] FOREIGN KEY (IdFile) REFERENCES dbo.ActFiles (IdFile)
GO

--
-- Создать внешний ключ [FK_dbo.ResourceOperatorPersonActs_dbo.ResourceOperatorPersons_IdResourceOperatorPerson] для объекта типа таблица [dbo].[ResourceOperatorPersonActs]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceOperatorPersonActs_dbo.ResourceOperatorPersons_IdResourceOperatorPerson] для объекта типа таблица [dbo].[ResourceOperatorPersonActs]')
GO
ALTER TABLE dbo.ResourceOperatorPersonActs
  ADD CONSTRAINT [FK_dbo.ResourceOperatorPersonActs_dbo.ResourceOperatorPersons_IdResourceOperatorPerson] FOREIGN KEY (IdResourceOperatorPerson) REFERENCES dbo.ResourceOperatorPersons (IdResourceOperatorPerson) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[ResourceOperatorActs]
--
PRINT (N'Создать таблицу [dbo].[ResourceOperatorActs]')
GO
CREATE TABLE dbo.ResourceOperatorActs (
  IdResourceOperatorAct int IDENTITY,
  IdResource int NOT NULL,
  ActType nvarchar(max) NULL,
  ActName nvarchar(max) NULL,
  ActDate datetime NULL,
  ActNumber nvarchar(max) NULL,
  IdFile int NULL DEFAULT (0),
  Deleted bit NOT NULL DEFAULT (0),
  CONSTRAINT [PK_dbo.ResourceOperatorActs] PRIMARY KEY CLUSTERED (IdResourceOperatorAct)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdFile] для объекта типа таблица [dbo].[ResourceOperatorActs]
--
PRINT (N'Создать индекс [IX_IdFile] для объекта типа таблица [dbo].[ResourceOperatorActs]')
GO
CREATE INDEX IX_IdFile
  ON dbo.ResourceOperatorActs (IdFile)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceOperatorActs]
--
PRINT (N'Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceOperatorActs]')
GO
CREATE INDEX IX_IdResource
  ON dbo.ResourceOperatorActs (IdResource)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.ResourceOperatorActs_dbo.ActFiles_IdFile] для объекта типа таблица [dbo].[ResourceOperatorActs]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceOperatorActs_dbo.ActFiles_IdFile] для объекта типа таблица [dbo].[ResourceOperatorActs]')
GO
ALTER TABLE dbo.ResourceOperatorActs
  ADD CONSTRAINT [FK_dbo.ResourceOperatorActs_dbo.ActFiles_IdFile] FOREIGN KEY (IdFile) REFERENCES dbo.ActFiles (IdFile)
GO

--
-- Создать внешний ключ [FK_dbo.ResourceOperatorActs_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceOperatorActs]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceOperatorActs_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceOperatorActs]')
GO
ALTER TABLE dbo.ResourceOperatorActs
  ADD CONSTRAINT [FK_dbo.ResourceOperatorActs_dbo.Resources_IdResource] FOREIGN KEY (IdResource) REFERENCES dbo.Resources (IdResource) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[ResourceAuthorityActs]
--
PRINT (N'Создать таблицу [dbo].[ResourceAuthorityActs]')
GO
CREATE TABLE dbo.ResourceAuthorityActs (
  IdResourceAuthorityAct int IDENTITY,
  IdResource int NOT NULL,
  ActType nvarchar(max) NULL,
  ActName nvarchar(max) NULL,
  ActDate datetime NULL,
  ActNumber nvarchar(max) NULL,
  IdFile int NULL DEFAULT (0),
  Deleted bit NOT NULL DEFAULT (0),
  CONSTRAINT [PK_dbo.ResourceAuthorityActs] PRIMARY KEY CLUSTERED (IdResourceAuthorityAct)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdFile] для объекта типа таблица [dbo].[ResourceAuthorityActs]
--
PRINT (N'Создать индекс [IX_IdFile] для объекта типа таблица [dbo].[ResourceAuthorityActs]')
GO
CREATE INDEX IX_IdFile
  ON dbo.ResourceAuthorityActs (IdFile)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceAuthorityActs]
--
PRINT (N'Создать индекс [IX_IdResource] для объекта типа таблица [dbo].[ResourceAuthorityActs]')
GO
CREATE INDEX IX_IdResource
  ON dbo.ResourceAuthorityActs (IdResource)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.ResourceAuthorityActs_dbo.ActFiles_IdFile] для объекта типа таблица [dbo].[ResourceAuthorityActs]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceAuthorityActs_dbo.ActFiles_IdFile] для объекта типа таблица [dbo].[ResourceAuthorityActs]')
GO
ALTER TABLE dbo.ResourceAuthorityActs
  ADD CONSTRAINT [FK_dbo.ResourceAuthorityActs_dbo.ActFiles_IdFile] FOREIGN KEY (IdFile) REFERENCES dbo.ActFiles (IdFile)
GO

--
-- Создать внешний ключ [FK_dbo.ResourceAuthorityActs_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceAuthorityActs]
--
PRINT (N'Создать внешний ключ [FK_dbo.ResourceAuthorityActs_dbo.Resources_IdResource] для объекта типа таблица [dbo].[ResourceAuthorityActs]')
GO
ALTER TABLE dbo.ResourceAuthorityActs
  ADD CONSTRAINT [FK_dbo.ResourceAuthorityActs_dbo.Resources_IdResource] FOREIGN KEY (IdResource) REFERENCES dbo.Resources (IdResource) ON DELETE CASCADE
GO

--
-- Создать таблицу [dbo].[AclRoles]
--
PRINT (N'Создать таблицу [dbo].[AclRoles]')
GO
CREATE TABLE dbo.AclRoles (
  IdRole int IDENTITY,
  Name nvarchar(256) NOT NULL,
  CONSTRAINT [PK_dbo.AclRoles] PRIMARY KEY CLUSTERED (IdRole)
)
ON [PRIMARY]
GO

--
-- Создать таблицу [dbo].[AclUserAclRoles]
--
PRINT (N'Создать таблицу [dbo].[AclUserAclRoles]')
GO
CREATE TABLE dbo.AclUserAclRoles (
  IdUser int NOT NULL,
  IdRole int NOT NULL,
  CONSTRAINT [PK_dbo.AclUserAclRoles] PRIMARY KEY CLUSTERED (IdUser, IdRole)
)
ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdRole] для объекта типа таблица [dbo].[AclUserAclRoles]
--
PRINT (N'Создать индекс [IX_IdRole] для объекта типа таблица [dbo].[AclUserAclRoles]')
GO
CREATE INDEX IX_IdRole
  ON dbo.AclUserAclRoles (IdRole)
  ON [PRIMARY]
GO

--
-- Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[AclUserAclRoles]
--
PRINT (N'Создать индекс [IX_IdUser] для объекта типа таблица [dbo].[AclUserAclRoles]')
GO
CREATE INDEX IX_IdUser
  ON dbo.AclUserAclRoles (IdUser)
  ON [PRIMARY]
GO

--
-- Создать внешний ключ [FK_dbo.AclUserAclRoles_dbo.AclRoles_IdUser] для объекта типа таблица [dbo].[AclUserAclRoles]
--
PRINT (N'Создать внешний ключ [FK_dbo.AclUserAclRoles_dbo.AclRoles_IdUser] для объекта типа таблица [dbo].[AclUserAclRoles]')
GO
ALTER TABLE dbo.AclUserAclRoles
  ADD CONSTRAINT [FK_dbo.AclUserAclRoles_dbo.AclRoles_IdUser] FOREIGN KEY (IdRole) REFERENCES dbo.AclRoles (IdRole) ON DELETE CASCADE
GO

--
-- Создать внешний ключ [FK_dbo.AclUserAclRoles_dbo.AclUsers_IdRole] для объекта типа таблица [dbo].[AclUserAclRoles]
--
PRINT (N'Создать внешний ключ [FK_dbo.AclUserAclRoles_dbo.AclUsers_IdRole] для объекта типа таблица [dbo].[AclUserAclRoles]')
GO
ALTER TABLE dbo.AclUserAclRoles
  ADD CONSTRAINT [FK_dbo.AclUserAclRoles_dbo.AclUsers_IdRole] FOREIGN KEY (IdUser) REFERENCES dbo.AclUsers (IdUser) ON DELETE CASCADE
GO

--
-- Создать процедуру [dbo].[SendRequestCompletedMail]
--
GO
PRINT (N'Создать процедуру [dbo].[SendRequestCompletedMail]')
GO
CREATE PROCEDURE dbo.SendRequestCompletedMail(@IdRequest INT)
AS 
DECLARE @RequestType NVARCHAR(MAX);
DECLARE @RequestDescription NVARCHAR(MAX);
DECLARE @IdRequester INT;
DECLARE @RequesterLogin NVARCHAR(MAX);
DECLARE @Snp NVARCHAR(MAX);
DECLARE @Email NVARCHAR(MAX);
DECLARE @EmailSubject NVARCHAR(MAX);
DECLARE @EmailSubjectTemplate NVARCHAR(MAX);
DECLARE @EmailBody NVARCHAR(MAX);
DECLARE @EmailBodyTemplate NVARCHAR(MAX);

DECLARE DispatchersCursor CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
SELECT au.Snp, au.Email
FROM AclUsers au
WHERE au.Deleted <> 1 AND au.IdUser IN (
  SELECT auar.IdUser 
  FROM AclUserAclRoles auar 
  WHERE auar.IdRole = 4
  ) AND au.Email IS NOT NULL AND au.Email <> '';

SELECT
  @RequestType = rt.Name, 
  @RequestDescription = REPLACE(COALESCE(r.Description, ''), CHAR(13),'<br>'),
  @Snp = au.Snp,
  @RequesterLogin = au.Login,
  @IdRequester = au.IdUser,
  @Email = au.Email
FROM Requests r
  INNER JOIN RequestTypes rt ON r.IdRequestType = rt.IdRequestType
  INNER JOIN AclUsers au ON r.IdUser = au.IdUser
WHERE r.IdRequest = @IdRequest;
SELECT @EmailSubjectTemplate = ' №'+ CAST(@IdRequest AS NVARCHAR(MAX))+' '+LOWER(@RequestType)+' выполнена';
SELECT @EmailSubject = 'Ваша заявка'+ @EmailSubjectTemplate;
SELECT @EmailBodyTemplate = 'Здравствуйте, {0}!<br>{1}.'+
  '<br><br><b>Описание:</b><br>'+@RequestDescription+
  '<br><br><b>Ссылка:</b> <a href="http://rqrights/Request/Detail/'+
  CAST(@IdRequest AS NVARCHAR(MAX))+'">http://rqrights/Request/Detail/'+CAST(@IdRequest AS NVARCHAR(MAX))+'</a>';

SET @EmailBody = REPLACE(REPLACE(@EmailBodyTemplate, '{0}', @Snp), '{1}', @EmailSubject)

EXEC msdb.dbo.sp_send_dbmail 
    @profile_name = 'RequestForRights Mail',
    @recipients = @Email,
    @body = @EmailBody,
    @subject = @EmailSubject,
    @body_format= 'HTML';

OPEN DispatchersCursor

FETCH NEXT FROM DispatchersCursor INTO @Snp, @Email

SELECT @EmailSubject = 'Заявка'+@EmailSubjectTemplate;

WHILE @@FETCH_STATUS = 0 BEGIN
  SET @EmailBody = REPLACE(REPLACE(@EmailBodyTemplate, '{0}', @Snp),'{1}', @EmailSubject)
  EXEC msdb.dbo.sp_send_dbmail 
      @profile_name = 'RequestForRights Mail',
      @recipients = @Email,
      @body = @EmailBody,
      @subject = @EmailSubject,
      @body_format= 'HTML';
	FETCH NEXT FROM DispatchersCursor INTO @Snp, @Email
END

CLOSE DispatchersCursor
DEALLOCATE DispatchersCursor
GO

--
-- Создать таблицу [dbo].[__MigrationHistory]
--
PRINT (N'Создать таблицу [dbo].[__MigrationHistory]')
GO
CREATE TABLE dbo.__MigrationHistory (
  MigrationId nvarchar(150) NOT NULL,
  ContextKey nvarchar(300) NOT NULL,
  Model varbinary(max) NOT NULL,
  ProductVersion nvarchar(32) NOT NULL,
  CONSTRAINT [PK_dbo.__MigrationHistory] PRIMARY KEY CLUSTERED (MigrationId, ContextKey)
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Создать функцию [dbo].[fn_diagramobjects]
--
GO
PRINT (N'Создать функцию [dbo].[fn_diagramobjects]')
GO


	CREATE FUNCTION dbo.fn_diagramobjects() 
	RETURNS int
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		declare @id_upgraddiagrams		int
		declare @id_sysdiagrams			int
		declare @id_helpdiagrams		int
		declare @id_helpdiagramdefinition	int
		declare @id_creatediagram	int
		declare @id_renamediagram	int
		declare @id_alterdiagram 	int 
		declare @id_dropdiagram		int
		declare @InstalledObjects	int

		select @InstalledObjects = 0

		select 	@id_upgraddiagrams = object_id(N'dbo.sp_upgraddiagrams'),
			@id_sysdiagrams = object_id(N'dbo.sysdiagrams'),
			@id_helpdiagrams = object_id(N'dbo.sp_helpdiagrams'),
			@id_helpdiagramdefinition = object_id(N'dbo.sp_helpdiagramdefinition'),
			@id_creatediagram = object_id(N'dbo.sp_creatediagram'),
			@id_renamediagram = object_id(N'dbo.sp_renamediagram'),
			@id_alterdiagram = object_id(N'dbo.sp_alterdiagram'), 
			@id_dropdiagram = object_id(N'dbo.sp_dropdiagram')

		if @id_upgraddiagrams is not null
			select @InstalledObjects = @InstalledObjects + 1
		if @id_sysdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 2
		if @id_helpdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 4
		if @id_helpdiagramdefinition is not null
			select @InstalledObjects = @InstalledObjects + 8
		if @id_creatediagram is not null
			select @InstalledObjects = @InstalledObjects + 16
		if @id_renamediagram is not null
			select @InstalledObjects = @InstalledObjects + 32
		if @id_alterdiagram  is not null
			select @InstalledObjects = @InstalledObjects + 64
		if @id_dropdiagram is not null
			select @InstalledObjects = @InstalledObjects + 128
		
		return @InstalledObjects 
	END
	
GO
SET NOEXEC OFF
GO