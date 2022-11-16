--CLEANING DATA SQL PROJECT
SELECT *
FROM [Portfolio Project]..Nashville_Housing


--STANDARDIZING DATE FORMAT
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM [Portfolio Project]..Nashville_Housing


UPDATE [Portfolio Project]..Nashville_Housing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nashville_Housing
ADD SaleDateConverted Date;

UPDATE [Portfolio Project]..Nashville_Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM [Portfolio Project]..Nashville_Housing

--POPULATING PROPERTY ADDRESS DATA

SELECT PropertyAddress
FROM [Portfolio Project]..Nashville_housing

--Looking at WHERE Property Address is NULL

SELECT PropertyAddress
FROM [Portfolio Project]..Nashville_housing
WHERE PropertyAddress IS NULL

SELECT * 
FROM [Portfolio Project]..Nashville_housing
ORDER BY parcelID

--Joining the table with itself on ParcelID, using UniqueID as a unique identifier

SELECT *
FROM [Portfolio Project]..Nashville_housing a
JOIN [Portfolio Project]..Nashville_housing b
ON a.parcelID =b.parcelID
AND a.uniqueID <> b.uniqueID

--Replacing Null addresses in table 'a' with the address values in address column in table 'b'
SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
FROM [Portfolio Project]..Nashville_housing a
JOIN [Portfolio Project]..Nashville_housing b
ON a.parcelID =b.parcelID
AND a.uniqueID <> b.uniqueID
WHERE a.propertyaddress IS NULL

--Updating the table, thereby replacing all Null address values in table'a' address column 
--with the values from address column in table'b'

UPDATE a
SET Propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
FROM [Portfolio Project]..Nashville_housing a
JOIN [Portfolio Project]..Nashville_housing b
ON a.parcelID =b.parcelID
AND a.uniqueID <> b.uniqueID
WHERE a.propertyaddress IS NULL

--SEPARATING ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM [Portfolio Project]..Nashville_Housing

--Showing where the comma is placed in the PropertyAddress Column
SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress)
FROM [Portfolio Project]..Nashville_Housing

-- Removing the comma in each of the field in the PropertyAddress Column
SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address

FROM [Portfolio Project]..Nashville_Housing

--Using parsename to separate each Address from City

SELECT 
PARSENAME (REPLACE (PropertyAddress, ',', '.'), 2) as Address_Split,
PARSENAME (REPLACE (PropertyAddress, ',', '.'), 1) as City_Split
FROM [Portfolio Project]..Nashville_Housing


--Updating Table adding Address_Split Column

ALTER TABLE [Portfolio Project]..Nashville_Housing
Add Address_Split Nvarchar(255)

UPDATE [Portfolio Project]..Nashville_Housing
SET Address_Split =PARSENAME (REPLACE (PropertyAddress, ',', '.'), 2) 



SELECT *
FROM [Portfolio Project]..Nashville_Housing

--Updating Table adding City_Split Column

ALTER TABLE [Portfolio Project]..Nashville_Housing
Add City_Split Nvarchar(255)

UPDATE [Portfolio Project]..Nashville_Housing
SET City_Split =PARSENAME (REPLACE (PropertyAddress, ',', '.'), 1) 

--Splitting the OwnerAddress Column

SELECT 
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3) as Owner_Address,
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2) as State,
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1) as State_Code

FROM [Portfolio Project]..Nashville_Housing

--Updating Table adding Owner_Address Column 

ALTER TABLE [Portfolio Project]..Nashville_Housing
Add Owner_Address Nvarchar(255)

UPDATE [Portfolio Project]..Nashville_Housing
SET Owner_Address = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3)

SELECT *
FROM [Portfolio Project]..Nashville_Housing

--Updating Table adding State Column
ALTER TABLE [Portfolio Project]..Nashville_Housing
Add State Nvarchar(255)

UPDATE [Portfolio Project]..Nashville_Housing
SET State = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2)

SELECT *
FROM [Portfolio Project]..Nashville_Housing

--Updating Table adding State_Code Column
ALTER TABLE [Portfolio Project]..Nashville_Housing
Add State_Code Nvarchar(255)

UPDATE [Portfolio Project]..Nashville_Housing
SET State_Code = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1)


SELECT *
FROM [Portfolio Project]..Nashville_Housing
ORDER BY STATE DESC

--CHANGE Y AND N TO YES AND NO IN SOLD AS VACANT COLUMN

SELECT DISTINCT SoldAsVacant,  COUNT(SoldAsVacant)
FROM [Portfolio Project]..Nashville_Housing
GROUP BY SoldasVAcant
ORDER BY 2

--Writing a Case Statement For the SoldAsVacant Column

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldASVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM [Portfolio Project]..Nashville_Housing

--Updating Table to replace all Y and N to Yes and No in the SoldAsVacant Column

UPDATE [Portfolio Project]..Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVAcant = 'Y' THEN 'Yes'
WHEN SoldASVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

SELECT *
FROM [Portfolio Project]..Nashville_housing


--REMOVING DUPLICATES
WITH ROW_NUM_CTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			   UniqueID) ROW_NUM
FROM [Portfolio Project]..Nashville_Housing
)
DELETE
FROM ROW_NUM_CTE
WHERE ROW_NUM > 1

--Checking if there are still Duplicates
WITH ROW_NUM_CTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			   UniqueID) ROW_NUM
FROM [Portfolio Project]..Nashville_Housing
)
SELECT *
FROM ROW_NUM_CTE
WHERE ROW_NUM > 1


--DELETE UNUSED COLUMNS
--Deleting Columns: OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
SELECT *
FROM [Portfolio Project]..Nashville_Housing

ALTER TABLE [Portfolio Project]..Nashville_Housing
DROP COLUMN OwnerAddress, TaxDIstrict, PropertyAddress, SaleDate